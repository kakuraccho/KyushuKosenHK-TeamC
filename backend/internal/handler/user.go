package handler

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"github.com/kakuraccho/KyushuKosenHK-TeamC/backend/internal/model"
	"github.com/kakuraccho/KyushuKosenHK-TeamC/backend/internal/service"
)

type UserHandler struct {
	userSvc *service.UserService
}

func NewUserHandler(userSvc *service.UserService) *UserHandler {
	return &UserHandler{userSvc: userSvc}
}

func (h *UserHandler) GetSettings(c *gin.Context) {
	userID := c.MustGet("user_id").(uuid.UUID)

	settings, err := h.userSvc.GetSettings(c.Request.Context(), userID)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "settings not found"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"data": settings})
}

type updateSettingsRequest struct {
	TimePomodoro       int  `json:"time_pomodoro"`
	TimeShortBreak     int  `json:"time_short_break"`
	TimeLongBreak      int  `json:"time_long_break"`
	IsAutoStartSession bool `json:"is_auto_start_session"`
	LongBreakInterval  int  `json:"long_break_interval"`
}

func (h *UserHandler) UpdateSettings(c *gin.Context) {
	userID := c.MustGet("user_id").(uuid.UUID)

	var req updateSettingsRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	settings := &model.UserSettings{
		UserID:             userID,
		TimePomodoro:       req.TimePomodoro,
		TimeShortBreak:     req.TimeShortBreak,
		TimeLongBreak:      req.TimeLongBreak,
		IsAutoStartSession: req.IsAutoStartSession,
		LongBreakInterval:  req.LongBreakInterval,
	}

	if err := h.userSvc.UpdateSettings(c.Request.Context(), settings); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"data": settings})
}
