package config

type Config struct {
	DSN       string
	JWTSecret string
}

func Load() *Config {
	return &Config{
		DSN:       "root:123456@tcp(127.0.0.1:3306)/blogdb?charset=utf8mb4&parseTime=True&loc=Local",
		JWTSecret: "my_secret_key",
	}
}
