package postgres

import (
	"context"
	"errors"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/kakuraccho/KyushuKosenHK-TeamC/backend/internal/model"
	"github.com/kakuraccho/KyushuKosenHK-TeamC/backend/internal/repository"
)

type friendRepository struct {
	db *pgxpool.Pool
}

func NewFriendRepository(db *pgxpool.Pool) *friendRepository {
	return &friendRepository{db: db}
}

func (r *friendRepository) CreateRequest(ctx context.Context, f *model.Friendship) error {
	_, err := r.db.Exec(ctx,
		`INSERT INTO friendships (id, follower_id, following_id, status, created_at)
		 VALUES ($1, $2, $3, $4, $5)`,
		f.ID, f.FollowerID, f.FollowingID, f.Status, f.CreatedAt,
	)
	return err
}

func (r *friendRepository) ListPendingRequests(ctx context.Context, userID uuid.UUID) ([]*model.Friendship, error) {
	rows, err := r.db.Query(ctx,
		`SELECT id, follower_id, following_id, status, created_at
		 FROM friendships WHERE following_id = $1 AND status = 'pending'
		 ORDER BY created_at DESC`, userID,
	)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var friendships []*model.Friendship
	for rows.Next() {
		f := &model.Friendship{}
		if err := rows.Scan(&f.ID, &f.FollowerID, &f.FollowingID, &f.Status, &f.CreatedAt); err != nil {
			return nil, err
		}
		friendships = append(friendships, f)
	}
	return friendships, rows.Err()
}

func (r *friendRepository) FindByID(ctx context.Context, id uuid.UUID) (*model.Friendship, error) {
	f := &model.Friendship{}
	err := r.db.QueryRow(ctx,
		`SELECT id, follower_id, following_id, status, created_at
		 FROM friendships WHERE id = $1`, id,
	).Scan(&f.ID, &f.FollowerID, &f.FollowingID, &f.Status, &f.CreatedAt)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return nil, repository.ErrNotFound
		}
		return nil, err
	}
	return f, nil
}

func (r *friendRepository) UpdateStatus(ctx context.Context, id uuid.UUID, status model.FriendshipStatus) error {
	tag, err := r.db.Exec(ctx,
		`UPDATE friendships SET status = $1 WHERE id = $2`, status, id,
	)
	if err != nil {
		return err
	}
	if tag.RowsAffected() == 0 {
		return pgx.ErrNoRows
	}
	return nil
}

func (r *friendRepository) AreFriends(ctx context.Context, userA, userB uuid.UUID) (bool, error) {
	var exists bool
	err := r.db.QueryRow(ctx,
		`SELECT EXISTS (
		   SELECT 1 FROM friendships
		   WHERE status = 'accepted'
		     AND ((follower_id = $1 AND following_id = $2)
		       OR (follower_id = $2 AND following_id = $1))
		 )`, userA, userB,
	).Scan(&exists)
	return exists, err
}

func (r *friendRepository) ListFriends(ctx context.Context, userID uuid.UUID) ([]*model.Friendship, error) {
	rows, err := r.db.Query(ctx,
		`SELECT id, follower_id, following_id, status, created_at
		 FROM friendships
		 WHERE (follower_id = $1 OR following_id = $1) AND status = 'accepted'
		 ORDER BY created_at DESC`, userID,
	)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var friendships []*model.Friendship
	for rows.Next() {
		f := &model.Friendship{}
		if err := rows.Scan(&f.ID, &f.FollowerID, &f.FollowingID, &f.Status, &f.CreatedAt); err != nil {
			return nil, err
		}
		friendships = append(friendships, f)
	}
	return friendships, rows.Err()
}
