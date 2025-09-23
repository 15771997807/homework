package models

import (
	"time"

	"gorm.io/gorm"
)

type User struct {
	ID        uint   `gorm:"primaryKey"`
	Username  string `gorm:"uniqueIndex;size:64"`
	Password  string `gorm:"size:255"`
	Email     string `gorm:"size:128"`
	Posts     []Post
	Comments  []Comment
	CreatedAt time.Time
	UpdatedAt time.Time
	DeletedAt gorm.DeletedAt `gorm:"index"`
}

type Post struct {
	ID        uint   `gorm:"primaryKey"`
	Title     string `gorm:"size:255"`
	Content   string `gorm:"type:text"`
	UserID    uint
	User      User
	Comments  []Comment
	CreatedAt time.Time
	UpdatedAt time.Time
	DeletedAt gorm.DeletedAt `gorm:"index"`
}

type Comment struct {
	ID        uint   `gorm:"primaryKey"`
	Content   string `gorm:"type:text"`
	UserID    uint
	User      User
	PostID    uint
	CreatedAt time.Time
	DeletedAt gorm.DeletedAt `gorm:"index"`
}

func AutoMigrate(db *gorm.DB) error {
	return db.AutoMigrate(&User{}, &Post{}, &Comment{})
}
