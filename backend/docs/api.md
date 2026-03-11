# API 仕様

ベースURL: `http://localhost:8080`

認証が必要なエンドポイントは `Authorization: Bearer <JWT>` ヘッダーが必須。
JWT は Supabase Auth が発行したトークンを使用する。

---

## サインアップ

Supabase Auth でユーザー作成後、バックエンドのユーザーレコードを登録する。

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

| フィールド | 型 | 必須 | 説明 |
|---|---|:---:|---|
| `id` | string (UUID) | ✅ | Supabase Auth の UID（`sub` クレームと一致させること） |
| `name` | string | ✅ | 表示名 |
| `email` | string | ✅ | メールアドレス |

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
| 400 | フィールド不足・UUID形式不正・メール形式不正 |
| 500 | 同一 ID または email が既に登録済み |

---

## ユーザー設定取得

ログイン中のユーザーのポモドーロ設定を取得する。

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
| `time_pomodoro` | int | ポモドーロ時間（分） |
| `time_short_break` | int | 短い休憩時間（分） |
| `time_long_break` | int | 長い休憩時間（分） |
| `is_auto_start_session` | bool | セッション自動開始 |
| `long_break_interval` | int | 長い休憩までのセッション数 |

**エラー**

| ステータス | 原因 |
|---|---|
| 401 | JWT なし・不正 |
| 404 | 設定レコードが存在しない（signup 未実施） |

---

## ユーザー設定保存

ログイン中のユーザーのポモドーロ設定を更新する。存在しない場合は作成する。

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

| フィールド | 型 | 必須 | 説明 |
|---|---|:---:|---|
| `time_pomodoro` | int | ✅ | ポモドーロ時間（分） |
| `time_short_break` | int | ✅ | 短い休憩時間（分） |
| `time_long_break` | int | ✅ | 長い休憩時間（分） |
| `is_auto_start_session` | bool | ✅ | セッション自動開始 |
| `long_break_interval` | int | ✅ | 長い休憩までのセッション数 |

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
| 400 | リクエスト形式不正 |
| 401 | JWT なし・不正 |
| 500 | DB エラー |

---

## 動画の保存

動画ファイルを Supabase Storage にアップロードし、メタデータを DB に保存する。

```
POST /api/v1/videos
```

**認証**: 必要

**リクエスト**: `multipart/form-data`

| フィールド | 型 | 必須 | 説明 |
|---|---|:---:|---|
| `video` | file | ✅ | 動画ファイル |

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
    "id":            "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
    "user_id":       "00000000-0000-0000-0000-000000000001",
    "storage_url":   "https://mpecadlgzpatvoxuxluc.supabase.co/storage/v1/object/public/videos/...",
    "thumbnail_url": null,
    "duration":      null,
    "created_at":    "2026-03-11T00:00:00Z"
  }
}
```

**エラー**

| ステータス | 原因 |
|---|---|
| 400 | `video` フィールドなし |
| 401 | JWT なし・不正 |
| 500 | Storage アップロード失敗・DB エラー |

---

## 動画の投稿

保存済みの動画を SNS 投稿として公開する。

```
POST /api/v1/posts
```

**認証**: 必要

**リクエスト**

```json
{
  "video_id":   "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
  "content":    "今日の勉強記録です",
  "visibility": "public"
}
```

| フィールド | 型 | 必須 | 説明 |
|---|---|:---:|---|
| `video_id` | string (UUID) | ✅ | 投稿する動画の ID |
| `content` | string | | 本文（省略可） |
| `visibility` | string | | 公開範囲（省略時: `"public"`） |

**`visibility` の値**

| 値 | 説明 |
|---|---|
| `"public"` | 全体公開（デフォルト） |
| `"friends"` | フレンドのみ |
| `"private"` | 自分のみ |

**レスポンス** `201 Created`

```json
{
  "data": {
    "id":         "yyyyyyyy-yyyy-yyyy-yyyy-yyyyyyyyyyyy",
    "user_id":    "00000000-0000-0000-0000-000000000001",
    "video_id":   "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
    "content":    "今日の勉強記録です",
    "visibility": "public",
    "created_at": "2026-03-11T00:00:00Z"
  }
}
```

**エラー**

| ステータス | 原因 |
|---|---|
| 400 | `video_id` なし・UUID形式不正・`visibility` 値不正 |
| 401 | JWT なし・不正 |
| 500 | DB エラー |
