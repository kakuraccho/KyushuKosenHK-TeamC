CREATE TABLE videos (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id       UUID NOT NULL REFERENCES users(id),
  storage_url   VARCHAR NOT NULL,
  thumbnail_url VARCHAR,
  duration      INTEGER,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
