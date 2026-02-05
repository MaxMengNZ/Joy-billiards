-- ============================================
-- Add Table Number to Battle Rooms
-- 为 Battle 房间添加台球桌编号
-- ============================================
-- This migration adds table_number field to battle_rooms table
-- 此迁移为 battle_rooms 表添加 table_number 字段
-- Table numbers: 3-12 (10 tables available)
-- ============================================

ALTER TABLE battle_rooms
ADD COLUMN IF NOT EXISTS table_number INTEGER CHECK (table_number >= 3 AND table_number <= 12);

COMMENT ON COLUMN battle_rooms.table_number IS 'Pool table number (3-12). NULL means no specific table assigned.';

CREATE INDEX IF NOT EXISTS idx_battle_rooms_table_number ON battle_rooms(table_number);
