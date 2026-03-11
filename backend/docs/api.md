# API 仕様書

## 概要

- **ベース URL**: `http://localhost:8080`
- **レスポンス形式**: JSON
- **成功時**: `{"data": ...}`
- **失敗時**: `{"error": "..."}`

## 認証

認証が必要なエンドポイントには `Authorization` ヘッダーを付与する。

```
Authorization: Bearer <Supabase JWT>
```

JWT は Supabase Auth でログイン後に取得したアクセストークンを使用する。

```js
const { data: { session } } = await supabase.auth.getSession()
const token = session.access_token
```

---

## エンドポイント一覧

| メソッド | パス | 認証 | 説明 |
|---|---|:---:|---|
| POST | `/api/v1/auth/signup` | - | ユーザー登録 |
| GET | `/api/v1/users/me/settings` | ✅ | ポモドーロ設定取得 |
| PUT | `/api/v1/users/me/settings` | ✅ | ポモドーロ設定更新 |
| POST | `/api/v1/sessions` | ✅ | ポモドーロセッション記録 |
| GET | `/api/v1/sessions` | ✅ | セッション一覧取得 |
| POST | `/api/v1/videos` | ✅ | 動画アップロード |
| GET | `/api/v1/videos` | ✅ | 動画一覧取得 |
| GET | `/api/v1/videos/:id` | ✅ | 動画取得 |
| POST | `/api/v1/posts` | ✅ | 投稿作成 |
| GET | `/api/v1/posts` | ✅ | フィード取得 |
| GET | `/api/v1/posts/:id` | ✅ | 投稿取得 |
| DELETE | `/api/v1/posts/:id` | ✅ | 投稿削除 |
| POST | `/api/v1/posts/:id/comments` | ✅ | コメント作成 |
| GET | `/api/v1/posts/:id/comments` | ✅ | コメント一覧取得 |
| DELETE | `/api/v1/posts/:id/comments/:comment_id` | ✅ | コメント削除 |
| POST | `/api/v1/friends/requests` | ✅ | フレンド申請送信 |
| GET | `/api/v1/friends/requests/pending` | ✅ | 受信中のフレンド申請一覧 |
| PATCH | `/api/v1/friends/requests/:id` | ✅ | フレンド申請への返答 |
| GET | `/api/v1/friends` | ✅ | フレンド一覧取得 |

---

## 認証

### ユーザー登録

Supabase Auth でアカウント作成後、バックエンドのユーザーレコードを登録する。
`id` には Supabase Auth が発行した UUID（`sub` クレームと同じ値）を渡す。

```
POST /api/v1/auth/signup
```

**認証**: 不要

**リクエスト**

```json
{
  "id":    "00000000-0000-0000-0000-000000000001",
  "name":  "山田太郎",
  "email": "yamada@example.com"
}
```

| フィールド | 型 | 必須 | 制約 | 説明 |
|---|---|:---:|---|---|
| `id` | string (UUID) | ✅ | UUID v4 形式 | Supabase Auth の UID |
| `name` | string | ✅ | 最大 255 文字 | 表示名 |
| `email` | string | ✅ | メール形式・最大 255 文字 | メールアドレス |

**レスポンス** `201 Created`

```json
{
  "data": {
    "id":         "00000000-0000-0000-0000-000000000001",
    "name":       "山田太郎",
    "email":      "yamada@example.com",
    "created_at": "2026-03-11T00:00:00Z"
  }
}
```

**エラー**

| ステータス | 原因 |
|---|---|
| 400 | フィールド不足・UUID 形式不正・メール形式不正・名前が 255 文字超 |
| 500 | 同一 ID または email が既に登録済み |

---

## ユーザー設定

### ポモドーロ設定取得

```
GET /api/v1/users/me/settings
```

**認証**: 必要

**リクエスト**: なし

**レスポンス** `200 OK`

```json
{
  "data": {
    "user_id":               "00000000-0000-0000-0000-000000000001",
    "time_pomodoro":         25,
    "time_short_break":      5,
    "time_long_break":       15,
    "is_auto_start_session": false,
    "long_break_interval":   4
  }
}
```

| フィールド | 型 | 説明 |
|---|---|---|
| `user_id` | string (UUID) | ユーザー ID |
| `time_pomodoro` | int | ポモドーロ時間（分） |
| `time_short_break` | int | 短い休憩時間（分） |
| `time_long_break` | int | 長い休憩時間（分） |
| `is_auto_start_session` | bool | セッション自動開始 |
| `long_break_interval` | int | 長い休憩に入るまでのセッション数 |

**エラー**

| ステータス | 原因 |
|---|---|
| 401 | JWT なし・不正・期限切れ |
| 404 | 設定レコードが存在しない（signup 未実施） |

---

### ポモドーロ設定更新

設定が存在しない場合は新規作成する（upsert）。

```
PUT /api/v1/users/me/settings
```

**認証**: 必要

**リクエスト**

```json
{
  "time_pomodoro":         50,
  "time_short_break":      10,
  "time_long_break":       20,
  "is_auto_start_session": true,
  "long_break_interval":   3
}
```

| フィールド | 型 | 必須 | 制約 | 説明 |
|---|---|:---:|---|---|
| `time_pomodoro` | int | ✅ | 1〜3600 | ポモドーロ時間（分） |
| `time_short_break` | int | ✅ | 1〜3600 | 短い休憩時間（分） |
| `time_long_break` | int | ✅ | 1〜3600 | 長い休憩時間（分） |
| `is_auto_start_session` | bool | ✅ | - | セッション自動開始 |
| `long_break_interval` | int | ✅ | 1〜100 | 長い休憩に入るまでのセッション数 |

**レスポンス** `200 OK`

```json
{
  "data": {
    "user_id":               "00000000-0000-0000-0000-000000000001",
    "time_pomodoro":         50,
    "time_short_break":      10,
    "time_long_break":       20,
    "is_auto_start_session": true,
    "long_break_interval":   3
  }
}
```

**エラー**

| ステータス | 原因 |
|---|---|
| 400 | フィールド不足・値が範囲外 |
| 401 | JWT なし・不正・期限切れ |
| 500 | DB エラー |

---

## ポモドーロセッション

### セッション記録

```
POST /api/v1/sessions
```

**認証**: 必要

**リクエスト**

```json
{
  "duration":     1500,
  "is_completed": true
}
```

| フィールド | 型 | 必須 | 制約 | 説明 |
|---|---|:---:|---|---|
| `duration` | int | ✅ | 1〜86400（秒） | セッション時間（秒） |
| `is_completed` | bool | | - | セッションが完了したか |

**レスポンス** `201 Created`

```json
{
  "data": {
    "id":           "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa",
    "user_id":      "00000000-0000-0000-0000-000000000001",
    "duration":     1500,
    "is_completed": true,
    "created_at":   "2026-03-11T06:00:00Z"
  }
}
```

**エラー**

| ステータス | 原因 |
|---|---|
| 400 | `duration` なし・範囲外（0 以下または 86400 超） |
| 401 | JWT なし・不正・期限切れ |
| 500 | DB エラー |

---

### セッション一覧取得

自分のセッション記録を新しい順に取得する。

```
GET /api/v1/sessions
```

**認証**: 必要

**リクエスト**: なし

**レスポンス** `200 OK`

```json
{
  "data": [
    {
      "id":           "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa",
      "user_id":      "00000000-0000-0000-0000-000000000001",
      "duration":     1500,
      "is_completed": true,
      "created_at":   "2026-03-11T06:00:00Z"
    }
  ]
}
```

**エラー**

| ステータス | 原因 |
|---|---|
| 401 | JWT なし・不正・期限切れ |
| 500 | DB エラー |

---

## 動画

### 動画アップロード

動画ファイルを Supabase Storage にアップロードし、メタデータを DB に保存する。

```
POST /api/v1/videos
Content-Type: multipart/form-data
```

**認証**: 必要

**リクエスト**

| フィールド | 型 | 必須 | 説明 |
|---|---|:---:|---|
| `video` | file | ✅ | 動画ファイル |

**制約**

- 最大ファイルサイズ: **100 MB**
- 対応フォーマット: `video/mp4`, `video/quicktime`（.mov）, `video/x-msvideo`（.avi）, `video/webm`

**例（curl）**

```bash
curl -X POST http://localhost:8080/api/v1/videos \
  -H "Authorization: Bearer <JWT>" \
  -F "video=@/path/to/video.mp4"
```

**レスポンス** `201 Created`

```json
{
  "data": {
    "id":            "bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb",
    "user_id":       "00000000-0000-0000-0000-000000000001",
    "storage_url":   "https://<project>.supabase.co/storage/v1/object/public/videos/00000000.../bbbbbbbb....mp4",
    "thumbnail_url": null,
    "duration":      null,
    "created_at":    "2026-03-11T06:00:00Z"
  }
}
```

**エラー**

| ステータス | 原因 |
|---|---|
| 400 | `video` フィールドなし・非対応フォーマット・マルチパート形式不正 |
| 401 | JWT なし・不正・期限切れ |
| 413 | ファイルが 100 MB を超えている |
| 500 | Storage アップロード失敗・DB エラー |

---

### 動画一覧取得

自分がアップロードした動画を取得する。

```
GET /api/v1/videos
```

**認証**: 必要

**リクエスト**: なし

**レスポンス** `200 OK`

```json
{
  "data": [
    {
      "id":            "bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb",
      "user_id":       "00000000-0000-0000-0000-000000000001",
      "storage_url":   "https://<project>.supabase.co/storage/v1/object/public/videos/...",
      "thumbnail_url": null,
      "duration":      null,
      "created_at":    "2026-03-11T06:00:00Z"
    }
  ]
}
```

**エラー**

| ステータス | 原因 |
|---|---|
| 401 | JWT なし・不正・期限切れ |
| 500 | DB エラー |

---

### 動画取得

```
GET /api/v1/videos/:id
```

**認証**: 必要
**注意**: 自分がアップロードした動画のみ取得可能。

**レスポンス** `200 OK`

```json
{
  "data": {
    "id":            "bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb",
    "user_id":       "00000000-0000-0000-0000-000000000001",
    "storage_url":   "https://<project>.supabase.co/storage/v1/object/public/videos/...",
    "thumbnail_url": null,
    "duration":      null,
    "created_at":    "2026-03-11T06:00:00Z"
  }
}
```

**エラー**

| ステータス | 原因 |
|---|---|
| 400 | ID が UUID 形式でない |
| 401 | JWT なし・不正・期限切れ |
| 403 | 他のユーザーの動画にアクセスしようとした |
| 404 | 動画が存在しない |
| 500 | DB エラー |

---

## 投稿

### 投稿作成

アップロード済みの動画を SNS 投稿として公開する。
`video_id` には自分がアップロードした動画の ID を指定すること。

```
POST /api/v1/posts
```

**認証**: 必要

**リクエスト**

```json
{
  "video_id":   "bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb",
  "content":    "今日の勉強記録！集中できた",
  "visibility": "public"
}
```

| フィールド | 型 | 必須 | 制約 | 説明 |
|---|---|:---:|---|---|
| `video_id` | string (UUID) | ✅ | 自分の動画 ID | 投稿する動画 |
| `content` | string | | 最大 10000 文字 | 投稿本文（省略可） |
| `visibility` | string | | 下記参照 | 公開範囲（デフォルト: `"public"`） |

**`visibility` の値**

| 値 | 説明 |
|---|---|
| `"public"` | 全体公開（デフォルト） |
| `"friends"` | フレンドのみ閲覧可能 |
| `"private"` | 自分のみ閲覧可能 |

**レスポンス** `201 Created`

```json
{
  "data": {
    "id":         "cccccccc-cccc-cccc-cccc-cccccccccccc",
    "user_id":    "00000000-0000-0000-0000-000000000001",
    "video_id":   "bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb",
    "content":    "今日の勉強記録！集中できた",
    "visibility": "public",
    "created_at": "2026-03-11T06:00:00Z"
  }
}
```

**エラー**

| ステータス | 原因 |
|---|---|
| 400 | `video_id` なし・UUID 形式不正・`visibility` 値不正・本文が 10000 文字超 |
| 401 | JWT なし・不正・期限切れ |
| 403 | 他のユーザーの動画を指定した |
| 404 | 動画が存在しない |
| 500 | DB エラー |

---

### フィード取得

自分の投稿 + フレンドの公開投稿を新しい順に取得する。

```
GET /api/v1/posts
```

**認証**: 必要

**リクエスト**: なし

**レスポンス** `200 OK`

```json
{
  "data": [
    {
      "id":         "cccccccc-cccc-cccc-cccc-cccccccccccc",
      "user_id":    "00000000-0000-0000-0000-000000000001",
      "video_id":   "bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb",
      "content":    "今日の勉強記録！集中できた",
      "visibility": "public",
      "created_at": "2026-03-11T06:00:00Z"
    }
  ]
}
```

**エラー**

| ステータス | 原因 |
|---|---|
| 401 | JWT なし・不正・期限切れ |
| 500 | DB エラー |

---

### 投稿取得

公開範囲に応じてアクセス制御が行われる。

```
GET /api/v1/posts/:id
```

**認証**: 必要

**公開範囲によるアクセス制御**

| visibility | 閲覧可能なユーザー |
|---|---|
| `public` | 全員 |
| `friends` | 投稿者本人・フレンド |
| `private` | 投稿者本人のみ |

**レスポンス** `200 OK`

```json
{
  "data": {
    "id":         "cccccccc-cccc-cccc-cccc-cccccccccccc",
    "user_id":    "00000000-0000-0000-0000-000000000001",
    "video_id":   "bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb",
    "content":    "今日の勉強記録！集中できた",
    "visibility": "public",
    "created_at": "2026-03-11T06:00:00Z"
  }
}
```

**エラー**

| ステータス | 原因 |
|---|---|
| 400 | ID が UUID 形式でない |
| 401 | JWT なし・不正・期限切れ |
| 403 | 公開範囲外（`friends` または `private`）の投稿にアクセスした |
| 404 | 投稿が存在しない |
| 500 | DB エラー |

---

### 投稿削除

自分の投稿のみ削除可能。

```
DELETE /api/v1/posts/:id
```

**認証**: 必要

**リクエスト**: なし

**レスポンス** `204 No Content`

**エラー**

| ステータス | 原因 |
|---|---|
| 400 | ID が UUID 形式でない |
| 401 | JWT なし・不正・期限切れ |
| 403 | 他のユーザーの投稿を削除しようとした |
| 404 | 投稿が存在しない |
| 500 | DB エラー |

---

## コメント

### コメント作成

```
POST /api/v1/posts/:id/comments
```

**認証**: 必要

**リクエスト**

```json
{
  "content": "すごい集中力ですね！"
}
```

| フィールド | 型 | 必須 | 制約 | 説明 |
|---|---|:---:|---|---|
| `content` | string | ✅ | 最大 10000 文字 | コメント本文 |

**レスポンス** `201 Created`

```json
{
  "data": {
    "id":         "dddddddd-dddd-dddd-dddd-dddddddddddd",
    "post_id":    "cccccccc-cccc-cccc-cccc-cccccccccccc",
    "user_id":    "00000000-0000-0000-0000-000000000002",
    "content":    "すごい集中力ですね！",
    "created_at": "2026-03-11T07:00:00Z"
  }
}
```

**エラー**

| ステータス | 原因 |
|---|---|
| 400 | 投稿 ID が UUID 形式でない・`content` なし・10000 文字超 |
| 401 | JWT なし・不正・期限切れ |
| 404 | 投稿が存在しない |
| 500 | DB エラー |

---

### コメント一覧取得

```
GET /api/v1/posts/:id/comments
```

**認証**: 必要

**リクエスト**: なし

**レスポンス** `200 OK`

```json
{
  "data": [
    {
      "id":         "dddddddd-dddd-dddd-dddd-dddddddddddd",
      "post_id":    "cccccccc-cccc-cccc-cccc-cccccccccccc",
      "user_id":    "00000000-0000-0000-0000-000000000002",
      "content":    "すごい集中力ですね！",
      "created_at": "2026-03-11T07:00:00Z"
    }
  ]
}
```

**エラー**

| ステータス | 原因 |
|---|---|
| 400 | 投稿 ID が UUID 形式でない |
| 401 | JWT なし・不正・期限切れ |
| 500 | DB エラー |

---

### コメント削除

自分が投稿したコメントのみ削除可能。

```
DELETE /api/v1/posts/:id/comments/:comment_id
```

**認証**: 必要

**リクエスト**: なし

**レスポンス** `204 No Content`

**エラー**

| ステータス | 原因 |
|---|---|
| 400 | コメント ID が UUID 形式でない |
| 401 | JWT なし・不正・期限切れ |
| 403 | 他のユーザーのコメントを削除しようとした |
| 404 | コメントが存在しない |
| 500 | DB エラー |

---

## フレンド

### フレンド申請送信

```
POST /api/v1/friends/requests
```

**認証**: 必要

**リクエスト**

```json
{
  "following_id": "00000000-0000-0000-0000-000000000002"
}
```

| フィールド | 型 | 必須 | 説明 |
|---|---|:---:|---|
| `following_id` | string (UUID) | ✅ | 申請先ユーザーの ID |

**レスポンス** `201 Created`

```json
{
  "data": {
    "id":           "eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee",
    "follower_id":  "00000000-0000-0000-0000-000000000001",
    "following_id": "00000000-0000-0000-0000-000000000002",
    "status":       "pending",
    "created_at":   "2026-03-11T08:00:00Z"
  }
}
```

**エラー**

| ステータス | 原因 |
|---|---|
| 400 | `following_id` なし・UUID 形式不正・自分自身への申請 |
| 401 | JWT なし・不正・期限切れ |
| 500 | DB エラー（重複申請など） |

---

### 受信中のフレンド申請一覧

自分宛ての未返答のフレンド申請を取得する。

```
GET /api/v1/friends/requests/pending
```

**認証**: 必要

**リクエスト**: なし

**レスポンス** `200 OK`

```json
{
  "data": [
    {
      "id":           "eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee",
      "follower_id":  "00000000-0000-0000-0000-000000000003",
      "following_id": "00000000-0000-0000-0000-000000000001",
      "status":       "pending",
      "created_at":   "2026-03-11T08:00:00Z"
    }
  ]
}
```

**エラー**

| ステータス | 原因 |
|---|---|
| 401 | JWT なし・不正・期限切れ |
| 500 | DB エラー |

---

### フレンド申請への返答

申請を承認（`accept: true`）または拒否（`accept: false`）する。
自分宛ての申請のみ操作可能。

```
PATCH /api/v1/friends/requests/:id
```

**認証**: 必要

**リクエスト**

```json
{
  "accept": true
}
```

| フィールド | 型 | 必須 | 説明 |
|---|---|:---:|---|
| `accept` | bool | ✅ | `true` で承認、`false` で拒否 |

**レスポンス** `200 OK`

```json
{
  "data": "ok"
}
```

**エラー**

| ステータス | 原因 |
|---|---|
| 400 | ID が UUID 形式でない |
| 401 | JWT なし・不正・期限切れ |
| 403 | 自分宛てではない申請を操作しようとした |
| 500 | DB エラー |

---

### フレンド一覧取得

承認済みのフレンドを取得する。

```
GET /api/v1/friends
```

**認証**: 必要

**リクエスト**: なし

**レスポンス** `200 OK`

```json
{
  "data": [
    {
      "id":           "eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee",
      "follower_id":  "00000000-0000-0000-0000-000000000001",
      "following_id": "00000000-0000-0000-0000-000000000002",
      "status":       "accepted",
      "created_at":   "2026-03-11T08:00:00Z"
    }
  ]
}
```

**エラー**

| ステータス | 原因 |
|---|---|
| 401 | JWT なし・不正・期限切れ |
| 500 | DB エラー |

---

## 共通エラーレスポンス

```json
{
  "error": "エラーメッセージ"
}
```

| ステータス | 意味 |
|---|---|
| 400 | リクエスト形式不正・バリデーションエラー |
| 401 | 認証エラー（JWT なし・期限切れ・署名不正） |
| 403 | 権限エラー（他人のリソースへのアクセス） |
| 404 | リソースが存在しない |
| 413 | ファイルサイズ超過（動画アップロード） |
| 500 | サーバー内部エラー |
