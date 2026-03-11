package postgres

import (
	"context"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/kakuraccho/KyushuKosenHK-TeamC/backend/internal/model"
)

type postRepository struct {
	db *pgxpool.Pool
}

func NewPostRepository(db *pgxpool.Pool) *postRepository {
	return &postRepository{db: db}
}

func (r *postRepository) Create(ctx context.Context, p *model.Post) error {
	_, err := r.db.Exec(ctx,
		`INSERT INTO posts (id, user_id, video_id, content, visibility, created_at)
		 VALUES ($1, $2, $3, $4, $5, $6)`,
		p.ID, p.UserID, p.VideoID, p.Content, p.Visibility, p.CreatedAt,
	)
	return err
}

func (r *postRepository) ListFeed(ctx context.Context, userID uuid.UUID) ([]*model.Post, error) {
	// friends の双方向チェック:
	//   - 自分が follower で accepted (自分が申請して相手が承認)
	//   - 自分が following で accepted (相手が申請して自分が承認)
	rows, err := r.db.Query(ctx,
		`SELECT id, user_id, video_id, content, visibility, created_at
		 FROM posts
		 WHERE visibility = 'public'
		    OR user_id = $1
		    OR (visibility = 'friends' AND user_id IN (
		         SELECT following_id FROM friendships
		         WHERE follower_id = $1 AND status = 'accepted'
		         UNION
		         SELECT follower_id FROM friendships
		         WHERE following_id = $1 AND status = 'accepted'
		       ))
		 ORDER BY created_at DESC`, userID,
	)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var posts []*model.Post
	for rows.Next() {
		p := &model.Post{}
		if err := rows.Scan(&p.ID, &p.UserID, &p.VideoID, &p.Content, &p.Visibility, &p.CreatedAt); err != nil {
			return nil, err
		}
		posts = append(posts, p)
	}
	return posts, rows.Err()
}

func (r *postRepository) FindByID(ctx context.Context, id uuid.UUID) (*model.Post, error) {
	p := &model.Post{}
	err := r.db.QueryRow(ctx,
		`SELECT id, user_id, video_id, content, visibility, created_at
		 FROM posts WHERE id = $1`, id,
	).Scan(&p.ID, &p.UserID, &p.VideoID, &p.Content, &p.Visibility, &p.CreatedAt)
	if err != nil {
		return nil, err
	}
	return p, nil
}

func (r *postRepository) Delete(ctx context.Context, id uuid.UUID) error {
	_, err := r.db.Exec(ctx, `DELETE FROM posts WHERE id = $1`, id)
	return err
}
