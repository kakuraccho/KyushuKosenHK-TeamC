package postgres_test

import (
	"context"
	"testing"
	"time"

	"github.com/google/uuid"
	"github.com/kakuraccho/KyushuKosenHK-TeamC/backend/internal/model"
	"github.com/kakuraccho/KyushuKosenHK-TeamC/backend/internal/repository/postgres"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func skipIfNoDB(t *testing.T) {
	t.Helper()
	if testDB == nil {
		t.Skip("DATABASE_URL not set")
	}
}

// TestDBConnection は DB への接続疎通を確認する。
func TestDBConnection(t *testing.T) {
	skipIfNoDB(t)

	err := testDB.Ping(context.Background())
	require.NoError(t, err, "DB に接続できること")
}

// TestUserCRUD はユーザーの作成・取得・削除を確認する。
func TestUserCRUD(t *testing.T) {
	skipIfNoDB(t)
	ctx := context.Background()
	repo := postgres.NewUserRepository(testDB)

	user := &model.User{
		ID:        uuid.New(),
		Name:      "テストユーザー",
		Email:     "test-" + uuid.New().String() + "@example.com",
		CreatedAt: time.Now().Truncate(time.Millisecond),
	}

	t.Cleanup(func() {
		_, _ = testDB.Exec(ctx, "DELETE FROM users WHERE id = $1", user.ID)
	})

	// 作成
	err := repo.Create(ctx, user)
	require.NoError(t, err, "ユーザー作成")

	// 取得
	found, err := repo.FindByID(ctx, user.ID)
	require.NoError(t, err, "ユーザー取得")
	assert.Equal(t, user.Name, found.Name)
	assert.Equal(t, user.Email, found.Email)
}

// TestUserSettingsCRUD はユーザー設定の作成・取得・更新を確認する。
func TestUserSettingsCRUD(t *testing.T) {
	skipIfNoDB(t)
	ctx := context.Background()
	repo := postgres.NewUserRepository(testDB)

	// 先にユーザーを作成（FK制約）
	user := &model.User{
		ID:        uuid.New(),
		Name:      "設定テスト",
		Email:     "settings-" + uuid.New().String() + "@example.com",
		CreatedAt: time.Now(),
	}
	require.NoError(t, repo.Create(ctx, user))

	t.Cleanup(func() {
		_, _ = testDB.Exec(ctx, "DELETE FROM user_settings WHERE user_id = $1", user.ID)
		_, _ = testDB.Exec(ctx, "DELETE FROM users WHERE id = $1", user.ID)
	})

	// デフォルト設定を作成
	settings := &model.UserSettings{
		UserID:             user.ID,
		TimePomodoro:       25,
		TimeShortBreak:     5,
		TimeLongBreak:      15,
		IsAutoStartSession: false,
		LongBreakInterval:  4,
	}
	err := repo.UpsertSettings(ctx, settings)
	require.NoError(t, err, "設定作成")

	// 取得して確認
	got, err := repo.GetSettings(ctx, user.ID)
	require.NoError(t, err)
	assert.Equal(t, 25, got.TimePomodoro)

	// 更新
	settings.TimePomodoro = 50
	err = repo.UpsertSettings(ctx, settings)
	require.NoError(t, err, "設定更新")

	got, err = repo.GetSettings(ctx, user.ID)
	require.NoError(t, err)
	assert.Equal(t, 50, got.TimePomodoro)
}

// TestSessionCRUD はポモドーロセッションの作成・一覧取得を確認する。
func TestSessionCRUD(t *testing.T) {
	skipIfNoDB(t)
	ctx := context.Background()
	userRepo := postgres.NewUserRepository(testDB)
	sessionRepo := postgres.NewSessionRepository(testDB)

	user := &model.User{
		ID:        uuid.New(),
		Name:      "セッションテスト",
		Email:     "session-" + uuid.New().String() + "@example.com",
		CreatedAt: time.Now(),
	}
	require.NoError(t, userRepo.Create(ctx, user))

	t.Cleanup(func() {
		_, _ = testDB.Exec(ctx, "DELETE FROM pomodoro_sessions WHERE user_id = $1", user.ID)
		_, _ = testDB.Exec(ctx, "DELETE FROM users WHERE id = $1", user.ID)
	})

	session := &model.PomodoroSession{
		ID:          uuid.New(),
		UserID:      user.ID,
		Duration:    1500,
		IsCompleted: true,
		CreatedAt:   time.Now(),
	}
	err := sessionRepo.Create(ctx, session)
	require.NoError(t, err, "セッション作成")

	list, err := sessionRepo.ListByUserID(ctx, user.ID)
	require.NoError(t, err)
	require.Len(t, list, 1)
	assert.Equal(t, 1500, list[0].Duration)
	assert.True(t, list[0].IsCompleted)
}
