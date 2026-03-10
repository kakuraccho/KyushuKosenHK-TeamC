# FocusLapse Backend

ポモドーロ×タイムラプス撮影を融合した学習SNSアプリ「FocusLapse」のバックエンド。

---

## 技術スタック

| 用途 | ライブラリ/サービス |
|---|---|
| HTTPフレームワーク | Gin |
| 認証 | Supabase Auth（JWT検証: `golang-jwt/jwt`） |
| DB ドライバ | `jackc/pgx/v5` |
| DB マイグレーション | `golang-migrate/migrate` |
| ストレージ | Supabase Storage（REST API経由） |
| 環境変数 | `joho/godotenv` |
| テスト | 標準 `testing` + `testify` |

---

## セットアップ

### 1. 環境変数

```bash
cp .env.example .env
# .env を編集して各値を設定
```

| 変数名 | 説明 |
|---|---|
| `DATABASE_URL` | PostgreSQL接続文字列 |
| `SUPABASE_URL` | Supabase プロジェクトURL |
| `SUPABASE_JWT_SECRET` | JWT検証用シークレット |
| `SUPABASE_SERVICE_ROLE_KEY` | Supabase Storage操作用キー |
| `PORT` | サーバーポート（デフォルト: 8080） |

### 2. DBマイグレーション

```bash
migrate -path db/migrations -database "$DATABASE_URL" up
```

### 3. 起動

```bash
# 通常起動
go run ./cmd/server/main.go

# ホットリロード (Air)
air -c .air.toml
```

---

## ビルド & テスト

```bash
# ビルド
go build ./...

# テスト
go test ./...

# lint
golangci-lint run

# フォーマット
gofmt -w .
```

---

## ディレクトリ構成

```
.
├── cmd/
│   └── server/
│       └── main.go          # エントリーポイント
├── internal/
│   ├── handler/             # HTTPハンドラー (薄く保つ)
│   │   ├── auth.go
│   │   ├── user.go
│   │   ├── session.go
│   │   ├── video.go
│   │   ├── post.go
│   │   └── friend.go
│   ├── middleware/
│   │   └── auth.go          # Supabase JWT検証ミドルウェア
│   ├── model/               # DBのstruct定義
│   │   └── *.go
│   ├── repository/          # DB操作 (interfaceで抽象化)
│   │   ├── interface.go
│   │   └── postgres/
│   │       └── *.go
│   ├── service/             # ビジネスロジック
│   │   └── *.go
│   ├── storage/             # Supabase Storage クライアント
│   │   └── supabase.go
│   └── router/
│       └── router.go        # ルーティング設定
├── db/
│   └── migrations/          # SQLマイグレーションファイル
├── .env.example
├── go.mod
└── go.sum
```

---

## APIエンドポイント

### 認証

| Method | Path | 認証 | 説明 |
|--------|------|:----:|------|
| POST | `/api/v1/auth/signup` | 不要 | ユーザー登録 |

### ユーザー設定

| Method | Path | 説明 |
|--------|------|------|
| GET | `/api/v1/users/me/settings` | 設定取得 |
| PUT | `/api/v1/users/me/settings` | 設定更新 |

### ポモドーロセッション

| Method | Path | 説明 |
|--------|------|------|
| POST | `/api/v1/sessions` | セッション記録 |
| GET | `/api/v1/sessions` | セッション一覧取得 |

### 動画

| Method | Path | 説明 |
|--------|------|------|
| POST | `/api/v1/videos` | 動画アップロード（Multipart） |
| GET | `/api/v1/videos` | 動画一覧取得 |
| GET | `/api/v1/videos/:id` | 動画詳細取得 |

### 投稿

| Method | Path | 説明 |
|--------|------|------|
| POST | `/api/v1/posts` | 投稿作成 |
| GET | `/api/v1/posts` | フィード取得（公開範囲フィルタ） |
| GET | `/api/v1/posts/:id` | 投稿詳細取得 |

### フレンド

| Method | Path | 説明 |
|--------|------|------|
| POST | `/api/v1/friends/requests` | フレンド申請 |
| GET | `/api/v1/friends/requests/pending` | 受信した申請一覧 |
| PATCH | `/api/v1/friends/requests/:id` | 申請の承認/拒否 |
| GET | `/api/v1/friends` | フレンド一覧 |

---

## 認証

```
Authorization: Bearer <Supabase JWT>
```

- `SUPABASE_JWT_SECRET` でHMAC-SHA256検証
- 検証成功後、`sub` クレーム（UUID）をリクエストコンテキストに格納
- `/api/v1/auth/signup` のみ認証スキップ

---

## レスポンス規約

```jsonc
// 成功
{ "data": { ... } }

// エラー
{ "error": "message" }
```

| ステータス | 用途 |
|-----------|------|
| 200 | 取得・更新成功 |
| 201 | 作成成功 |
| 400 | バリデーションエラー |
| 401 | 認証エラー |
| 403 | 権限エラー |
| 404 | リソース不存在 |
| 500 | サーバーエラー |

---

## データベース設計

```sql
CREATE TABLE users (
  id          UUID PRIMARY KEY,  -- Supabase Auth の sub と一致
  name        VARCHAR NOT NULL,
  email       VARCHAR UNIQUE NOT NULL,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE user_settings (
  user_id              UUID PRIMARY KEY REFERENCES users(id),
  time_pomodoro        INTEGER NOT NULL DEFAULT 25,  -- 分
  time_short_break     INTEGER NOT NULL DEFAULT 5,
  time_long_break      INTEGER NOT NULL DEFAULT 15,
  is_auto_start_session BOOLEAN NOT NULL DEFAULT false,
  long_break_interval  INTEGER NOT NULL DEFAULT 4
);

CREATE TABLE pomodoro_sessions (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id      UUID NOT NULL REFERENCES users(id),
  duration     INTEGER NOT NULL,  -- 秒
  is_completed BOOLEAN NOT NULL,
  created_at   TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE videos (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id       UUID NOT NULL REFERENCES users(id),
  storage_url   VARCHAR NOT NULL,
  thumbnail_url VARCHAR,
  duration      INTEGER,  -- 秒
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TYPE visibility_type AS ENUM ('public', 'friends', 'private');

CREATE TABLE posts (
  id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id    UUID NOT NULL REFERENCES users(id),
  video_id   UUID NOT NULL REFERENCES videos(id),
  content    TEXT,
  visibility visibility_type NOT NULL DEFAULT 'public',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TYPE friendship_status AS ENUM ('pending', 'accepted', 'blocked');

CREATE TABLE friendships (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  follower_id  UUID NOT NULL REFERENCES users(id),
  following_id UUID NOT NULL REFERENCES users(id),
  status       friendship_status NOT NULL DEFAULT 'pending',
  created_at   TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (follower_id, following_id)
);
```

---

## TODO

- 動画バリデーション: サイズ上限・許容フォーマット
- フィードのソートロジック（フレンド投稿と公開投稿の混在方法）
- サムネイル自動生成（ffmpeg連携 or クライアント側生成）
- レート制限
