# FocusLapse Backend

ポモドーロ×タイムラプス撮影を融合した学習SNSアプリ「FocusLapse」のバックエンド。

---

## 技術スタック

| 用途 | ライブラリ/サービス |
|---|---|
| HTTPフレームワーク | Gin |
| 認証 | Supabase Auth（JWT検証: ES256 via JWKS） |
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
| `DATABASE_URL` | Supabase Transaction Pooler の接続文字列（port 6543） |
| `SUPABASE_URL` | Supabase プロジェクトURL |
| `SUPABASE_SERVICE_ROLE_KEY` | Supabase Storage操作用サービスロールキー |
| `SUPABASE_JWKS_URL` | JWT検証用JWKSエンドポイント |
| `PORT` | サーバーポート（デフォルト: 8080） |

### 2. DBマイグレーション

```bash
# golang-migrate CLI のインストール（未インストールの場合）
go install -tags 'pgx5' github.com/golang-migrate/migrate/v4/cmd/migrate@latest

# マイグレーション実行
migrate -path db/migrations \
  -database "pgx5://your-db-url?default_query_exec_mode=simple_protocol" \
  up
```

> Supabase の Transaction Pooler（port 6543）は prepared statement 非対応のため、
> `default_query_exec_mode=simple_protocol` が必要です。

### 3. サーバー起動

```bash
# 通常起動
go run ./cmd/server/main.go

# ホットリロード（Air が必要）
air -c .air.toml
```

---

## テスト

```bash
# 全テスト実行（キャッシュ無効）
go test ./... -count=1

# 特定パッケージのみ
go test ./internal/middleware/... -count=1 -v
go test ./internal/repository/postgres/... -count=1 -v

# テスト実行には .env が必要（DB接続テストのため）
# DBが使えない環境ではDBテストは自動スキップされます
```

テスト内容:

| テスト | 場所 |
|---|---|
| JWT認証ミドルウェア（ES256, 有効期限, 無効キー等） | `internal/middleware/auth_test.go` |
| DB接続確認、User/Settings/Session CRUD | `internal/repository/postgres/db_test.go` |

---

## ビルド & Lint

```bash
# ビルド
go build ./...

# lint（golangci-lint が必要）
golangci-lint run ./...

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
│   ├── handler/             # HTTPハンドラー（薄く保つ）
│   │   ├── auth.go
│   │   ├── comment.go
│   │   ├── errors.go
│   │   ├── friend.go
│   │   ├── post.go
│   │   ├── session.go
│   │   ├── user.go
│   │   └── video.go
│   ├── middleware/
│   │   ├── auth.go          # Supabase JWT検証ミドルウェア（ES256）
│   │   └── jwks.go          # JWKS公開鍵取得
│   ├── model/               # DBのstruct定義
│   │   ├── comment.go
│   │   ├── friend.go
│   │   ├── post.go
│   │   ├── session.go
│   │   ├── user.go
│   │   └── video.go
│   ├── repository/          # DB操作（interfaceで抽象化）
│   │   ├── interface.go
│   │   └── postgres/
│   │       ├── comment.go
│   │       ├── friend.go
│   │       ├── post.go
│   │       ├── session.go
│   │       ├── user.go
│   │       └── video.go
│   ├── service/             # ビジネスロジック
│   │   ├── comment.go
│   │   ├── friend.go
│   │   ├── post.go
│   │   ├── session.go
│   │   ├── user.go
│   │   └── video.go
│   ├── storage/             # Supabase Storage クライアント
│   │   └── supabase.go
│   └── router/
│       └── router.go        # ルーティング設定
├── db/
│   └── migrations/          # SQLマイグレーションファイル（001〜007）
├── .env.example
├── go.mod
└── go.sum
```

---

## APIエンドポイント

認証が必要なエンドポイントは `Authorization: Bearer <Supabase JWT>` ヘッダーが必要です。

### 認証

| Method | Path | 認証 | 説明 |
|--------|------|:----:|------|
| POST | `/api/v1/auth/signup` | 不要 | DBへのユーザー登録（Supabase Auth登録後に呼ぶ） |

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
| POST | `/api/v1/videos` | 動画アップロード（multipart/form-data, フィールド名: `video`） |
| GET | `/api/v1/videos` | 自分の動画一覧取得 |
| GET | `/api/v1/videos/:id` | 動画詳細取得 |

### 投稿

| Method | Path | 説明 |
|--------|------|------|
| POST | `/api/v1/posts` | 投稿作成 |
| GET | `/api/v1/posts` | フィード取得（公開範囲フィルタ付き） |
| GET | `/api/v1/posts/:id` | 投稿詳細取得 |
| DELETE | `/api/v1/posts/:id` | 投稿削除（投稿者本人のみ） |

### コメント

| Method | Path | 説明 |
|--------|------|------|
| POST | `/api/v1/posts/:id/comments` | コメント投稿 |
| GET | `/api/v1/posts/:id/comments` | コメント一覧取得 |
| DELETE | `/api/v1/posts/:id/comments/:comment_id` | コメント削除（投稿者本人のみ） |

### フレンド

| Method | Path | 説明 |
|--------|------|------|
| POST | `/api/v1/friends/requests` | フレンド申請 |
| GET | `/api/v1/friends/requests/pending` | 受信した申請一覧 |
| PATCH | `/api/v1/friends/requests/:id` | 申請の承認/拒否 |
| GET | `/api/v1/friends` | フレンド一覧 |

---

## 認証フロー

```
1. クライアント → Supabase Auth SDK
   supabase.auth.signUp({ email, password })
   → Supabase が auth.users に登録し JWT を返す

2. クライアント → このバックエンド
   POST /api/v1/auth/signup  (Authorization: Bearer <JWT>)
   { id: "<supabase-uuid>", name: "...", email: "..." }
   → public.users にプロフィール行を作成

3. 以後すべてのAPIリクエストに JWT を付与
   Authorization: Bearer <JWT>
```

JWT は ES256（ECDSA P-256）で署名されており、JWKS エンドポイントから取得した公開鍵で検証します。
検証成功後、`sub` クレーム（UUID）をリクエストコンテキストに `user_id` として格納します。

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
| 204 | 削除成功 |
| 400 | バリデーションエラー |
| 401 | 認証エラー |
| 403 | 権限エラー |
| 404 | リソース不存在 |
| 409 | 重複エラー（already exists） |
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
  user_id               UUID PRIMARY KEY REFERENCES users(id),
  time_pomodoro         INTEGER NOT NULL DEFAULT 25,
  time_short_break      INTEGER NOT NULL DEFAULT 5,
  time_long_break       INTEGER NOT NULL DEFAULT 15,
  is_auto_start_session BOOLEAN NOT NULL DEFAULT false,
  long_break_interval   INTEGER NOT NULL DEFAULT 4
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

CREATE TABLE comments (
  id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  post_id    UUID NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
  user_id    UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  content    TEXT NOT NULL CHECK (char_length(content) <= 10000),
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

- サムネイル自動生成（ffmpeg連携 or クライアント側生成）
- レート制限
- フィードのページネーション
