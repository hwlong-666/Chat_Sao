-- 1. 用户信息表
CREATE TABLE `user_info` (
        `user_id` BIGINT AUTO_INCREMENT PRIMARY KEY,
  `username` VARCHAR(50) NOT NULL UNIQUE COMMENT '登录账号',
        `password` VARCHAR(255) NOT NULL COMMENT '加密密码',
        `avatar_url` VARCHAR(255) DEFAULT NULL COMMENT '头像地址',
        `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP,
        `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户信息表';

-- 2. 好友关系表
CREATE TABLE `friend_relation` (
        `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
  `user_id` BIGINT NOT NULL COMMENT '主动添加方ID',
        `friend_id` BIGINT NOT NULL COMMENT '被添加方ID',
        `status` TINYINT DEFAULT 0 COMMENT '状态: 0-待通过, 1-已通过, 2-已拒绝',
        `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP,
UNIQUE KEY `uk_user_friend` (`user_id`, `friend_id`) -- 防止重复添加
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='好友关系表';

-- 3. 聊天记录表 (核心重灾区)
CREATE TABLE `chat_message` (
        `msg_id` BIGINT AUTO_INCREMENT PRIMARY KEY,
  `sender_id` BIGINT NOT NULL COMMENT '发送者ID',
        `receiver_id` BIGINT NOT NULL COMMENT '接收者ID (用户ID或群ID)',
        `chat_type` TINYINT NOT NULL DEFAULT 1 COMMENT '1-私聊, 2-群聊',
        `msg_type` TINYINT NOT NULL DEFAULT 1 COMMENT '1-文本, 2-图片, 3-语音',
        `content` TEXT NOT NULL COMMENT '消息内容 (若是图片/语音则存URL)',
        `is_read` TINYINT DEFAULT 0 COMMENT '0-未读, 1-已读 (仅私聊有效)',
        `send_time` DATETIME DEFAULT CURRENT_TIMESTAMP,
INDEX `idx_sender_receiver` (`sender_id`, `receiver_id`), -- 加速查询双方聊天记录
INDEX `idx_send_time` (`send_time`) -- 加速按时间排序
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='聊天记录表';

-- 4. 群组表 (如果你打算做群聊功能)
CREATE TABLE `chat_group` (
        `group_id` BIGINT AUTO_INCREMENT PRIMARY KEY,
  `group_name` VARCHAR(100) NOT NULL,
  `owner_id` BIGINT NOT NULL COMMENT '群主ID',
        `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='群组表';

-- 5. 群成员映射表
CREATE TABLE `group_member` (
        `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
  `group_id` BIGINT NOT NULL,
        `user_id` BIGINT NOT NULL,
        `join_time` DATETIME DEFAULT CURRENT_TIMESTAMP,
UNIQUE KEY `uk_group_user` (`group_id`, `user_id`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='群成员表';