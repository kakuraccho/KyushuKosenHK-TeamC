package handler

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"github.com/kakuraccho/KyushuKosenHK-TeamC/backend/internal/service"
)

type SessionHandler struct {
	sessionSvc *service.SessionService
}

func NewSessionHandler(sessionSvc *service.SessionService) *SessionHandler {
	return &SessionHandler{sessionSvc: sessionSvc}
}

type createSessionRequest struct {
	Duration    int  `json:"duration" binding:"required,min=1"`
	IsCompleted bool `json:"is_completed"`
}

func (h *SessionHandler) Create(c *gin.Context) {
	userID := c.MustGet("user_id").(uuid.UUID)

	var req createSessionRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	session, err := h.sessionSvc.Create(c.Request.Context(), service.CreateSessionInput{
		UserID:      userID,
		Duration:    req.Duration,
		IsCompleted: req.IsCompleted,
	})
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusCreated, gin.H{"data": session})
}

func (h *SessionHandler) List(c *gin.Context) {
	userID := c.MustGet("user_id").(uuid.UUID)

	sessions, err := h.sessionSvc.List(c.Request.Context(), userID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"data": sessions})
}
