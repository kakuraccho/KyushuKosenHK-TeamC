FROM golang:1.26-alpine

# ホットリロードツール「Air」のインストール
RUN go install github.com/air-verse/air@latest

WORKDIR /app

# 依存関係をコピーしてインストール（ビルド高速化のため）
COPY go.mod go.sum ./
RUN go mod download

# 全ソースコードをコピー
COPY . .

# Airを使って起動する
CMD ["air", "-c", ".air.toml"]