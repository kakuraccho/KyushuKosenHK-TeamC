package postgres

import (
	"context"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/kakuraccho/KyushuKosenHK-TeamC/backend/internal/model"
)

type commentRepository struct {
	db *pgxpool.Pool
}

func NewCommentRepository(db *pgxpool.Pool) *commentRepository {
	return &commentRepository{db: db}
}

func (r *commentRepository) Create(ctx context.Context, c *model.Comment) error {
	_, err := r.db.Exec(ctx,
		`INSERT INTO comments (id, post_id, user_id, content, created_at)
		 VALUES ($1, $2, $3, $4, $5)`,
		c.ID, c.PostID, c.UserID, c.Content, c.CreatedAt,
	)
	return err
}

func (r *commentRepository) ListByPostID(ctx context.Context, postID uuid.UUID) ([]*model.Comment, error) {
	rows, err := r.db.Query(ctx,
		`SELECT id, post_id, user_id, content, created_at
		 FROM comments WHERE post_id = $1 ORDER BY created_at ASC`, postID,
	)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var comments []*model.Comment
	for rows.Next() {
		c := &model.Comment{}
		if err := rows.Scan(&c.ID, &c.PostID, &c.UserID, &c.Content, &c.CreatedAt); err != nil {
			return nil, err
		}
		comments = append(comments, c)
	}
	return comments, rows.Err()
}

func (r *commentRepository) FindByID(ctx context.Context, id uuid.UUID) (*model.Comment, error) {
	c := &model.Comment{}
	err := r.db.QueryRow(ctx,
		`SELECT id, post_id, user_id, content, created_at
		 FROM comments WHERE id = $1`, id,
	).Scan(&c.ID, &c.PostID, &c.UserID, &c.Content, &c.CreatedAt)
	if err != nil {
		return nil, err
	}
	return c, nil
}

func (r *commentRepository) Delete(ctx context.Context, id uuid.UUID) error {
	_, err := r.db.Exec(ctx, `DELETE FROM comments WHERE id = $1`, id)
	return err
}
