package postgres

import (
	"context"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/kakuraccho/KyushuKosenHK-TeamC/backend/internal/model"
)

type videoRepository struct {
	db *pgxpool.Pool
}

func NewVideoRepository(db *pgxpool.Pool) *videoRepository {
	return &videoRepository{db: db}
}

func (r *videoRepository) Create(ctx context.Context, v *model.Video) error {
	_, err := r.db.Exec(ctx,
		`INSERT INTO videos (id, user_id, storage_url, thumbnail_url, duration, created_at)
		 VALUES ($1, $2, $3, $4, $5, $6)`,
		v.ID, v.UserID, v.StorageURL, v.ThumbnailURL, v.Duration, v.CreatedAt,
	)
	return err
}

func (r *videoRepository) ListByUserID(ctx context.Context, userID uuid.UUID) ([]*model.Video, error) {
	rows, err := r.db.Query(ctx,
		`SELECT id, user_id, storage_url, thumbnail_url, duration, created_at
		 FROM videos WHERE user_id = $1 ORDER BY created_at DESC`, userID,
	)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var videos []*model.Video
	for rows.Next() {
		v := &model.Video{}
		if err := rows.Scan(&v.ID, &v.UserID, &v.StorageURL, &v.ThumbnailURL, &v.Duration, &v.CreatedAt); err != nil {
			return nil, err
		}
		videos = append(videos, v)
	}
	return videos, rows.Err()
}

func (r *videoRepository) FindByID(ctx context.Context, id uuid.UUID) (*model.Video, error) {
	v := &model.Video{}
	err := r.db.QueryRow(ctx,
		`SELECT id, user_id, storage_url, thumbnail_url, duration, created_at
		 FROM videos WHERE id = $1`, id,
	).Scan(&v.ID, &v.UserID, &v.StorageURL, &v.ThumbnailURL, &v.Duration, &v.CreatedAt)
	if err != nil {
		return nil, err
	}
	return v, nil
}
