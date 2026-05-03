package org.example.dto;

import lombok.Data;

@Data
public class ChatSessionVO {
    private Long friendId;
    private String friendUsername;
    private String friendAvatarUrl;
    private String lastMessage;
    private Integer lastMsgType;
    private Integer unreadCount;
    private String lastTime;
}
