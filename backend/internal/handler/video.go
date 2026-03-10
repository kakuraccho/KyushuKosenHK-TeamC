package handler

import (
	"io"
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"github.com/kakuraccho/KyushuKosenHK-TeamC/backend/internal/service"
)

const maxVideoSize = 100 << 20 // 100MB

type VideoHandler struct {
	videoSvc *service.VideoService
}

func NewVideoHandler(videoSvc *service.VideoService) *VideoHandler {
	return &VideoHandler{videoSvc: videoSvc}
}

func (h *VideoHandler) Upload(c *gin.Context) {
	userID := c.MustGet("user_id").(uuid.UUID)

	c.Request.Body = http.MaxBytesReader(c.Writer, c.Request.Body, maxVideoSize)

	file, header, err := c.Request.FormFile("video")
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "video file required"})
		return
	}
	defer file.Close()

	data, err := io.ReadAll(file)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "file too large or unreadable"})
		return
	}

	video, err := h.videoSvc.Upload(c.Request.Context(), userID, header.Filename, data)
	if err != nil {
		handleServiceError(c, err)
		return
	}

	c.JSON(http.StatusCreated, gin.H{"data": video})
}

func (h *VideoHandler) List(c *gin.Context) {
	userID := c.MustGet("user_id").(uuid.UUID)

	videos, err := h.videoSvc.List(c.Request.Context(), userID)
	if err != nil {
		handleServiceError(c, err)
		return
	}

	c.JSON(http.StatusOK, gin.H{"data": videos})
}

func (h *VideoHandler) Get(c *gin.Context) {
	id, err := uuid.Parse(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid id"})
		return
	}

	video, err := h.videoSvc.Get(c.Request.Context(), id)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "video not found"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"data": video})
}
