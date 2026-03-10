CREATE TABLE pomodoro_sessions (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id      UUID NOT NULL REFERENCES users(id),
  duration     INTEGER NOT NULL,
  is_completed BOOLEAN NOT NULL,
  created_at   TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
