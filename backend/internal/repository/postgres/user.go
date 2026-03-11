package postgres

import (
	"context"
	"fmt"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/kakuraccho/KyushuKosenHK-TeamC/backend/internal/model"
)

type userRepository struct {
	db *pgxpool.Pool
}

func NewUserRepository(db *pgxpool.Pool) *userRepository {
	return &userRepository{db: db}
}

func (r *userRepository) Create(ctx context.Context, user *model.User) error {
	_, err := r.db.Exec(ctx,
		`INSERT INTO users (id, name, email, created_at) VALUES ($1, $2, $3, $4)`,
		user.ID, user.Name, user.Email, user.CreatedAt,
	)
	return err
}

func (r *userRepository) FindByID(ctx context.Context, id uuid.UUID) (*model.User, error) {
	user := &model.User{}
	err := r.db.QueryRow(ctx,
		`SELECT id, name, email, created_at FROM users WHERE id = $1`, id,
	).Scan(&user.ID, &user.Name, &user.Email, &user.CreatedAt)
	if err != nil {
		return nil, fmt.Errorf("user not found: %w", err)
	}
	return user, nil
}

func (r *userRepository) GetSettings(ctx context.Context, userID uuid.UUID) (*model.UserSettings, error) {
	s := &model.UserSettings{}
	err := r.db.QueryRow(ctx,
		`SELECT user_id, time_pomodoro, time_short_break, time_long_break, is_auto_start_session, long_break_interval
		 FROM user_settings WHERE user_id = $1`, userID,
	).Scan(&s.UserID, &s.TimePomodoro, &s.TimeShortBreak, &s.TimeLongBreak, &s.IsAutoStartSession, &s.LongBreakInterval)
	if err != nil {
		return nil, fmt.Errorf("settings not found: %w", err)
	}
	return s, nil
}

func (r *userRepository) UpsertSettings(ctx context.Context, s *model.UserSettings) error {
	_, err := r.db.Exec(ctx,
		`INSERT INTO user_settings (user_id, time_pomodoro, time_short_break, time_long_break, is_auto_start_session, long_break_interval)
		 VALUES ($1, $2, $3, $4, $5, $6)
		 ON CONFLICT (user_id) DO UPDATE SET
		   time_pomodoro = EXCLUDED.time_pomodoro,
		   time_short_break = EXCLUDED.time_short_break,
		   time_long_break = EXCLUDED.time_long_break,
		   is_auto_start_session = EXCLUDED.is_auto_start_session,
		   long_break_interval = EXCLUDED.long_break_interval`,
		s.UserID, s.TimePomodoro, s.TimeShortBreak, s.TimeLongBreak, s.IsAutoStartSession, s.LongBreakInterval,
	)
	return err
}
