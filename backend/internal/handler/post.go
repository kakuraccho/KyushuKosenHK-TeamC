package handler

import (
	"errors"
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"github.com/kakuraccho/KyushuKosenHK-TeamC/backend/internal/model"
	"github.com/kakuraccho/KyushuKosenHK-TeamC/backend/internal/service"
)

type PostHandler struct {
	postSvc *service.PostService
}

func NewPostHandler(postSvc *service.PostService) *PostHandler {
	return &PostHandler{postSvc: postSvc}
}

type createPostRequest struct {
	VideoID    string `json:"video_id" binding:"required"`
	Content    string `json:"content" binding:"max=10000"`
	Visibility string `json:"visibility"`
}

func (h *PostHandler) Create(c *gin.Context) {
	userID := c.MustGet("user_id").(uuid.UUID)

	var req createPostRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	videoID, err := uuid.Parse(req.VideoID)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid video_id"})
		return
	}

	visibility := model.VisibilityPublic
	if req.Visibility != "" {
		switch model.VisibilityType(req.Visibility) {
		case model.VisibilityPublic, model.VisibilityFriends, model.VisibilityPrivate:
			visibility = model.VisibilityType(req.Visibility)
		default:
			c.JSON(http.StatusBadRequest, gin.H{"error": "visibility must be public, friends, or private"})
			return
		}
	}

	var content *string
	if req.Content != "" {
		content = &req.Content
	}

	post, err := h.postSvc.Create(c.Request.Context(), service.CreatePostInput{
		UserID:     userID,
		VideoID:    videoID,
		Content:    content,
		Visibility: visibility,
	})
	if err != nil {
		switch {
		case errors.Is(err, service.ErrVideoForbidden):
			c.JSON(http.StatusForbidden, gin.H{"error": "forbidden"})
		case errors.Is(err, service.ErrVideoNotFound):
			c.JSON(http.StatusNotFound, gin.H{"error": "video not found"})
		default:
			handleServiceError(c, err)
		}
		return
	}

	c.JSON(http.StatusCreated, gin.H{"data": post})
}

func (h *PostHandler) Feed(c *gin.Context) {
	userID := c.MustGet("user_id").(uuid.UUID)

	posts, err := h.postSvc.Feed(c.Request.Context(), userID)
	if err != nil {
		handleServiceError(c, err)
		return
	}

	c.JSON(http.StatusOK, gin.H{"data": posts})
}

func (h *PostHandler) Get(c *gin.Context) {
	requesterID := c.MustGet("user_id").(uuid.UUID)

	id, err := uuid.Parse(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid id"})
		return
	}

	post, err := h.postSvc.Get(c.Request.Context(), id, requesterID)
	if err != nil {
		switch {
		case errors.Is(err, service.ErrPostNotFound):
			c.JSON(http.StatusNotFound, gin.H{"error": "post not found"})
		case errors.Is(err, service.ErrPostForbidden):
			c.JSON(http.StatusForbidden, gin.H{"error": "forbidden"})
		default:
			handleServiceError(c, err)
		}
		return
	}

	c.JSON(http.StatusOK, gin.H{"data": post})
}

func (h *PostHandler) Delete(c *gin.Context) {
	userID := c.MustGet("user_id").(uuid.UUID)

	id, err := uuid.Parse(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid id"})
		return
	}

	if err := h.postSvc.Delete(c.Request.Context(), userID, id); err != nil {
		switch {
		case errors.Is(err, service.ErrPostNotFound):
			c.JSON(http.StatusNotFound, gin.H{"error": "post not found"})
		case errors.Is(err, service.ErrPostForbidden):
			c.JSON(http.StatusForbidden, gin.H{"error": "forbidden"})
		default:
			handleServiceError(c, err)
		}
		return
	}

	c.Status(http.StatusNoContent)
}
