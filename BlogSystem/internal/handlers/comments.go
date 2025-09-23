package handlers

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"

	"github.com/86157/BlogSystem/internal/models"
	"github.com/86157/BlogSystem/internal/utils"
)

// 评论功能/创建评论
func CreateCommentHandler(db *gorm.DB) gin.HandlerFunc {
	return func(c *gin.Context) {
		postIDParam := c.Param("id")
		var post models.Post
		if err := db.First(&post, postIDParam).Error; err != nil {
			utils.JSON(c, http.StatusNotFound, "post not found", nil)
			return
		}
		var body struct {
			Content string `json:"content" binding:"required"`
		}
		if err := c.ShouldBindJSON(&body); err != nil {
			utils.JSON(c, http.StatusBadRequest, "invalid params", nil)
			return
		}
		uidI, _ := c.Get("user_id")
		uid := uidI.(uint)

		cm := models.Comment{
			Content: body.Content,
			UserID:  uid,
			PostID:  post.ID,
		}
		if err := db.Create(&cm).Error; err != nil {
			utils.JSON(c, http.StatusInternalServerError, "create comment failed", nil)
			return
		}
		utils.JSON(c, http.StatusOK, "ok", cm)
	}
}

// 获取评论
func ListCommentsHandler(db *gorm.DB) gin.HandlerFunc {
	return func(c *gin.Context) {
		postIDParam := c.Param("id")
		var comments []models.Comment
		if err := db.Where("post_id = ?", postIDParam).Find(&comments).Error; err != nil {
			utils.JSON(c, http.StatusInternalServerError, "db error", nil)
			return
		}
		utils.JSON(c, http.StatusOK, "ok", comments)
	}
}
