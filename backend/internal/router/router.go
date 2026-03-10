package router

import (
	"github.com/gin-gonic/gin"
	"github.com/kakuraccho/KyushuKosenHK-TeamC/backend/internal/handler"
	"github.com/kakuraccho/KyushuKosenHK-TeamC/backend/internal/middleware"
)

type Handlers struct {
	Auth    *handler.AuthHandler
	User    *handler.UserHandler
	Session *handler.SessionHandler
	Video   *handler.VideoHandler
	Post    *handler.PostHandler
	Friend  *handler.FriendHandler
}

func NewRouter(h Handlers, jwtSecret string) *gin.Engine {
	r := gin.Default()

	v1 := r.Group("/api/v1")

	// 認証不要
	auth := v1.Group("/auth")
	{
		auth.POST("/signup", h.Auth.Signup)
	}

	// 認証必要
	protected := v1.Group("")
	protected.Use(middleware.AuthMiddleware(jwtSecret))
	{
		// ユーザー設定
		users := protected.Group("/users/me")
		{
			users.GET("/settings", h.User.GetSettings)
			users.PUT("/settings", h.User.UpdateSettings)
		}

		// ポモドーロセッション
		sessions := protected.Group("/sessions")
		{
			sessions.POST("", h.Session.Create)
			sessions.GET("", h.Session.List)
		}

		// 動画
		videos := protected.Group("/videos")
		{
			videos.POST("", h.Video.Upload)
			videos.GET("", h.Video.List)
			videos.GET("/:id", h.Video.Get)
		}

		// 投稿
		posts := protected.Group("/posts")
		{
			posts.POST("", h.Post.Create)
			posts.GET("", h.Post.Feed)
			posts.GET("/:id", h.Post.Get)
		}

		// フレンド
		friends := protected.Group("/friends")
		{
			friends.POST("/requests", h.Friend.SendRequest)
			friends.GET("/requests/pending", h.Friend.ListPendingRequests)
			friends.PATCH("/requests/:id", h.Friend.RespondToRequest)
			friends.GET("", h.Friend.ListFriends)
		}
	}

	return r
}
