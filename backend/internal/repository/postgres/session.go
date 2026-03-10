package postgres

import (
	"context"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/kakuraccho/KyushuKosenHK-TeamC/backend/internal/model"
)

type sessionRepository struct {
	db *pgxpool.Pool
}

func NewSessionRepository(db *pgxpool.Pool) *sessionRepository {
	return &sessionRepository{db: db}
}

func (r *sessionRepository) Create(ctx context.Context, s *model.PomodoroSession) error {
	_, err := r.db.Exec(ctx,
		`INSERT INTO pomodoro_sessions (id, user_id, duration, is_completed, created_at)
		 VALUES ($1, $2, $3, $4, $5)`,
		s.ID, s.UserID, s.Duration, s.IsCompleted, s.CreatedAt,
	)
	return err
}

func (r *sessionRepository) ListByUserID(ctx context.Context, userID uuid.UUID) ([]*model.PomodoroSession, error) {
	rows, err := r.db.Query(ctx,
		`SELECT id, user_id, duration, is_completed, created_at
		 FROM pomodoro_sessions WHERE user_id = $1 ORDER BY created_at DESC`, userID,
	)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var sessions []*model.PomodoroSession
	for rows.Next() {
		s := &model.PomodoroSession{}
		if err := rows.Scan(&s.ID, &s.UserID, &s.Duration, &s.IsCompleted, &s.CreatedAt); err != nil {
			return nil, err
		}
		sessions = append(sessions, s)
	}
	return sessions, rows.Err()
}
