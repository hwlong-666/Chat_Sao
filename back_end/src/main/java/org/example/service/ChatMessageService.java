package org.example.service;

import org.example.dto.ChatSessionVO;
import org.example.entity.ChatMessage;

import java.util.List;

public interface ChatMessageService {

    ChatMessage saveMessage(Long senderId, Long receiverId, String content);

    ChatMessage saveMessage(Long senderId, Long receiverId, String content, int msgType);

    List<ChatMessage> getChatHistory(Long userId1, Long userId2, int limit, int offset);

    List<ChatSessionVO> getChatSessions(Long userId);

    void markAsRead(Long userId, Long friendId);
}
