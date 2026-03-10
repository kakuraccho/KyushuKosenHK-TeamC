package handler

import (
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
	Content    string `json:"content"`
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
		visibility = model.VisibilityType(req.Visibility)
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
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusCreated, gin.H{"data": post})
}

func (h *PostHandler) Feed(c *gin.Context) {
	userID := c.MustGet("user_id").(uuid.UUID)

	posts, err := h.postSvc.Feed(c.Request.Context(), userID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"data": posts})
}

func (h *PostHandler) Get(c *gin.Context) {
	id, err := uuid.Parse(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid id"})
		return
	}

	post, err := h.postSvc.Get(c.Request.Context(), id)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "post not found"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"data": post})
}
