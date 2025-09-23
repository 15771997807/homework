package main

import (
	"log"

	"github.com/86157/BlogSystem/internal/config"
	"github.com/86157/BlogSystem/internal/db"
	"github.com/86157/BlogSystem/internal/handlers"
	"github.com/86157/BlogSystem/internal/models"
	"github.com/gin-gonic/gin"
)

func main() {
	cfg := config.Load()
	database, err := db.Connect(cfg)
	if err != nil {
		log.Fatalf("连接数据库失败: %v", err)
	}
	// 自动迁移
	if err := models.AutoMigrate(database); err != nil {
		log.Fatalf("自动迁移失败: %v", err)
	}
	r := gin.Default()

	//路由
	r.POST("api/register", handlers.RegisterHandler(database, cfg))
	r.POST("api/login", handlers.LoginHandler(database, cfg))

	auth := r.Group("/api")
	auth.Use(handlers.JWTAuthMiddleware(cfg))
	{
		//文章管理
		auth.POST("/posts", handlers.CreatePostHandler(database))
		auth.GET("/posts/:id", handlers.GetPostHandler(database))
		auth.GET("/posts", handlers.ListPostsHandler(database))
		auth.PUT("/posts/:id", handlers.UpdatePostHandler(database))
		auth.DELETE("/posts/:id", handlers.DeletePostHandler(database))
		//评论管理
		auth.POST("/posts/:id/comments", handlers.CreateCommentHandler(database))
		auth.GET("/posts/:id/comments", handlers.ListCommentsHandler(database))
	}
	// 启动服务
	if err := r.Run(":8080"); err != nil {
		log.Fatalf("服务启动失败: %v", err)
	}
}
