package handlers

import (
	"net/http"

	"github.com/86157/BlogSystem/internal/utils"
	"github.com/gin-gonic/gin"
	"gorm.io/gorm"

	"github.com/86157/BlogSystem/internal/models"
)

// 创建文章（需要认证）
func CreatePostHandler(db *gorm.DB) gin.HandlerFunc {
	return func(c *gin.Context) {
		var body struct {
			Title   string `json:"title" binding:"required"`
			Content string `json:"content" binding:"required"`
		}
		if err := c.ShouldBindJSON(&body); err != nil {
			utils.JSON(c, http.StatusBadRequest, "invalid params", nil)
			return
		}
		uidI, ok := c.Get("user_id")
		if !ok {
			utils.JSON(c, http.StatusUnauthorized, "unauthorized", nil)
			return
		}
		uid := uidI.(uint)
		p := models.Post{
			Title:   body.Title,
			Content: body.Content,
			UserID:  uid,
		}
		if err := db.Create(&p).Error; err != nil {
			utils.JSON(c, http.StatusInternalServerError, "create post failed", nil)
			return
		}
		utils.JSON(c, http.StatusOK, "ok", p)
	}
}

// 获取单个文章
func GetPostHandler(db *gorm.DB) gin.HandlerFunc {
	return func(c *gin.Context) {
		id := c.Param("id")
		var p models.Post
		if err := db.Preload("Comments").Preload("User").First(&p, id).Error; err != nil {
			if err == gorm.ErrRecordNotFound {
				utils.JSON(c, http.StatusNotFound, "post not found", nil)
				return
			}
			utils.JSON(c, http.StatusInternalServerError, "db error", nil)
			return
		}
		utils.JSON(c, http.StatusOK, "ok", p)
	}
}

// 获取文章列表
func ListPostsHandler(db *gorm.DB) gin.HandlerFunc {
	return func(c *gin.Context) {
		var posts []models.Post
		if err := db.Preload("User").Find(&posts).Error; err != nil {
			utils.JSON(c, http.StatusInternalServerError, "db error", nil)
			return
		}
		utils.JSON(c, http.StatusOK, "ok", posts)
	}
}

// 更新文章/限作者本人
func UpdatePostHandler(db *gorm.DB) gin.HandlerFunc {
	return func(c *gin.Context) {
		id := c.Param("id")
		var body struct {
			Title   string `json:"title"`
			Content string `json:"content"`
		}
		if err := c.ShouldBindJSON(&body); err != nil {
			utils.JSON(c, http.StatusBadRequest, "invalid params", nil)
			return
		}
		var p models.Post
		if err := db.First(&p, id).Error; err != nil {
			utils.JSON(c, http.StatusNotFound, "post not found", nil)
			return
		}
		uidI, _ := c.Get("user_id")
		uid := uidI.(uint)
		if p.UserID != uid {
			utils.JSON(c, http.StatusForbidden, "not author", nil)
			return
		}
		// 更新
		if body.Title != "" {
			p.Title = body.Title
		}
		if body.Content != "" {
			p.Content = body.Content
		}
		if err := db.Save(&p).Error; err != nil {
			utils.JSON(c, http.StatusInternalServerError, "update failed", nil)
			return
		}
		utils.JSON(c, http.StatusOK, "ok", p)
	}
}

// 删除文章
func DeletePostHandler(db *gorm.DB) gin.HandlerFunc {
	return func(c *gin.Context) {
		id := c.Param("id")
		var p models.Post
		if err := db.First(&p, id).Error; err != nil {
			utils.JSON(c, http.StatusNotFound, "post not found", nil)
			return
		}
		uidI, _ := c.Get("user_id")
		uid := uidI.(uint)
		if p.UserID != uid {
			utils.JSON(c, http.StatusForbidden, "not author", nil)
			return
		}
		if err := db.Delete(&p).Error; err != nil {
			utils.JSON(c, http.StatusInternalServerError, "delete failed", nil)
			return
		}
		utils.JSON(c, http.StatusOK, "ok", nil)
	}
}
