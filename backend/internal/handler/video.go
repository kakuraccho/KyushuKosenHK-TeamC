package handler

import (
	"bytes"
	"errors"
	"io"
	"net/http"
	"strings"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"github.com/kakuraccho/KyushuKosenHK-TeamC/backend/internal/service"
)

const maxVideoSize = 100 << 20 // 100MB

var allowedVideoMIME = map[string]bool{
	"video/mp4":       true,
	"video/quicktime": true, // .mov
	"video/x-msvideo": true, // .avi
	"video/webm":      true,
}

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
		msg := err.Error()
		switch {
		case strings.Contains(msg, "request body too large") || strings.Contains(msg, "multipart: message too large"):
			c.JSON(http.StatusRequestEntityTooLarge, gin.H{"error": "file exceeds maximum allowed size"})
		case strings.Contains(msg, "multipart:") || strings.Contains(msg, "unexpected EOF"):
			c.JSON(http.StatusBadRequest, gin.H{"error": "malformed multipart body"})
		default:
			c.JSON(http.StatusBadRequest, gin.H{"error": "video file required"})
		}
		return
	}
	defer file.Close()

	// MIME タイプを先頭 512 バイトで検出してホワイトリスト検証（全体をメモリに読み込まない）
	buf := make([]byte, 512)
	n, err := io.ReadFull(file, buf)
	if err != nil && err != io.ErrUnexpectedEOF {
		c.JSON(http.StatusBadRequest, gin.H{"error": "file too large or unreadable"})
		return
	}
	mimeType := http.DetectContentType(buf[:n])
	if !allowedVideoMIME[mimeType] {
		c.JSON(http.StatusBadRequest, gin.H{"error": "unsupported video format"})
		return
	}

	stream := io.MultiReader(bytes.NewReader(buf[:n]), file)
	video, err := h.videoSvc.Upload(c.Request.Context(), userID, mimeType, stream, header.Size)
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
	userID := c.MustGet("user_id").(uuid.UUID)

	id, err := uuid.Parse(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid id"})
		return
	}

	video, err := h.videoSvc.Get(c.Request.Context(), id, userID)
	if err != nil {
		switch {
		case errors.Is(err, service.ErrVideoNotFound):
			c.JSON(http.StatusNotFound, gin.H{"error": "video not found"})
		case errors.Is(err, service.ErrVideoForbidden):
			c.JSON(http.StatusForbidden, gin.H{"error": "forbidden"})
		default:
			handleServiceError(c, err)
		}
		return
	}

	c.JSON(http.StatusOK, gin.H{"data": video})
}
