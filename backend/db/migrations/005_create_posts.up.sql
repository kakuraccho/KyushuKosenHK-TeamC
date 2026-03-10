CREATE TYPE visibility_type AS ENUM ('public', 'friends', 'private');

CREATE TABLE posts (
  id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id    UUID NOT NULL REFERENCES users(id),
  video_id   UUID NOT NULL REFERENCES videos(id),
  content    TEXT,
  visibility visibility_type NOT NULL DEFAULT 'public',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
