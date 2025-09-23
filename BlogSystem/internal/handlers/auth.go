package handlers

import (
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/golang-jwt/jwt/v4"
	"golang.org/x/crypto/bcrypt"
	"gorm.io/gorm"

	"github.com/86157/BlogSystem/internal/config"
	"github.com/86157/BlogSystem/internal/middleware"
	"github.com/86157/BlogSystem/internal/models"
	"github.com/86157/BlogSystem/internal/utils"
)

// 注册
func RegisterHandler(db *gorm.DB, cfg *config.Config) gin.HandlerFunc {
	return func(c *gin.Context) {
		var body struct {
			Username string `json:"username" binding:"required"`
			Password string `json:"password" binding:"required"`
			Email    string `json:"email"`
		}
		if err := c.ShouldBindJSON(&body); err != nil {
			utils.JSON(c, http.StatusBadRequest, "invalid params", nil)
			return
		}
		// 密码哈希
		hash, err := bcrypt.GenerateFromPassword([]byte(body.Password), bcrypt.DefaultCost)
		if err != nil {
			utils.JSON(c, http.StatusInternalServerError, "hash error", nil)
			return
		}
		u := models.User{
			Username: body.Username,
			Password: string(hash),
			Email:    body.Email,
		}
		if err := db.Create(&u).Error; err != nil {
			utils.JSON(c, http.StatusBadRequest, "create user failed", nil)
			return
		}
		utils.JSON(c, http.StatusOK, "ok", gin.H{"id": u.ID})
	}
}

// 登录
func LoginHandler(db *gorm.DB, cfg *config.Config) gin.HandlerFunc {
	return func(c *gin.Context) {
		var body struct {
			Username string `json:"username" binding:"required"`
			Password string `json:"password" binding:"required"`
		}
		if err := c.ShouldBindJSON(&body); err != nil {
			utils.JSON(c, http.StatusBadRequest, "invalid params", nil)
			return
		}
		var u models.User
		if err := db.Where("username = ?", body.Username).First(&u).Error; err != nil {
			if err == gorm.ErrRecordNotFound {
				utils.JSON(c, http.StatusUnauthorized, "invalid credentials", nil)
				return
			}
			utils.JSON(c, http.StatusInternalServerError, "db error", nil)
			return
		}
		// 校验密码
		if err := bcrypt.CompareHashAndPassword([]byte(u.Password), []byte(body.Password)); err != nil {
			utils.JSON(c, http.StatusUnauthorized, "invalid credentials", nil)
			return
		}
		// 签发 JWT
		claims := jwt.MapClaims{
			"user_id": u.ID,
			"exp":     time.Now().Add(time.Hour * 72).Unix(),
		}
		token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
		ss, err := token.SignedString([]byte(cfg.JWTSecret))
		if err != nil {
			utils.JSON(c, http.StatusInternalServerError, "token generate error", nil)
			return
		}
		utils.JSON(c, http.StatusOK, "ok", gin.H{"token": ss})
	}
}

// 暴露中间件构造，方便 main.go 使用
func JWTAuthMiddleware(cfg *config.Config) gin.HandlerFunc {
	return middleware.JWTAuthMiddleware(cfg.JWTSecret)
}
