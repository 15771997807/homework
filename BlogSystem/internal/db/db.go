package db

import (
	"gorm.io/driver/mysql"
	"gorm.io/gorm"

	"github.com/86157/BlogSystem/internal/config"
)

func Connect(cfg *config.Config) (*gorm.DB, error) {
	db, err := gorm.Open(mysql.Open(cfg.DSN), &gorm.Config{})
	if err != nil {
		return nil, err
	}
	return db, nil
}
