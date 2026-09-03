package models

import "time"

type BaseModel struct {
	ID        string     `json:"id" db:"id"`
	IsActive  bool       `json:"is_active" db:"is_active"`
	CreatedBy string     `json:"created_by" db:"created_by"`
	CreatedAt time.Time  `json:"created_at" db:"created_at"`
	UpdatedBy *string    `json:"updated_by" db:"updated_by"`
	UpdatedAt *time.Time `json:"updated_at" db:"updated_at"`
	DeletedBy *string    `json:"deleted_by" db:"deleted_by"`
	DeletedAt *time.Time `json:"deleted_at" db:"deleted_at"`
}

func (b *BaseModel) GetID() string {
	return b.ID
}
