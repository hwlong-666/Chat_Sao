package org.example.dto;

import lombok.Data;

@Data
public class ChatMessageVO {
    private Long msgId;
    private Long senderId;
    private Long receiverId;
    private Integer chatType;
    private Integer msgType;
    private String content;
    private Integer isRead;
    private String sendTime;
}
