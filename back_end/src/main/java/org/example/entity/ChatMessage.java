package org.example.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@TableName("chat_message")
public class ChatMessage {

    @TableId(type = IdType.AUTO)
    private Long msgId;

    private Long senderId;

    private Long receiverId;

    private Integer chatType;

    private Integer msgType;

    private String content;

    private Integer isRead;

    private LocalDateTime sendTime;
}
