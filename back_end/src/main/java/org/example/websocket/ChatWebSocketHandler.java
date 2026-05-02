package org.example.websocket;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.example.entity.ChatMessage;
import org.example.service.ChatMessageService;
import org.example.service.RedisService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;
import org.springframework.web.socket.CloseStatus;
import org.springframework.web.socket.TextMessage;
import org.springframework.web.socket.WebSocketSession;
import org.springframework.web.socket.handler.TextWebSocketHandler;

import java.io.IOException;
import java.util.Map;

@Component
public class ChatWebSocketHandler extends TextWebSocketHandler {

    private static final Logger log = LoggerFactory.getLogger(ChatWebSocketHandler.class);

    private final ChatMessageService chatMessageService;
    private final WebSocketSessionManager sessionManager;
    private final RedisService redisService;
    private final ObjectMapper objectMapper;

    public ChatWebSocketHandler(ChatMessageService chatMessageService, WebSocketSessionManager sessionManager, RedisService redisService) {
        this.chatMessageService = chatMessageService;
        this.sessionManager = sessionManager;
        this.redisService = redisService;
        this.objectMapper = new ObjectMapper();
    }

    @Override
    public void afterConnectionEstablished(WebSocketSession session) throws Exception {
        Long userId = getUserId(session);
        if (userId != null) {
            sessionManager.addSession(userId, session);
            log.info("WebSocket connected: userId={}", userId);
        }
    }

    @Override
    protected void handleTextMessage(WebSocketSession session, TextMessage message) throws Exception {
        Long senderId = getUserId(session);
        if (senderId == null) {
            session.close(CloseStatus.NOT_ACCEPTABLE);
            return;
        }

        try {
            Map<String, Object> payload = objectMapper.readValue(message.getPayload(), Map.class);

            String type = payload.get("type") != null ? payload.get("type").toString() : null;
            if ("PING".equalsIgnoreCase(type)) {
                sessionManager.refreshOnline(senderId);
                safeSend(session, "{\"type\":\"PONG\"}");
                return;
            }

            Long receiverId = Long.valueOf(payload.get("receiverId").toString());
            String content = payload.get("content").toString();

            ChatMessage saved = chatMessageService.saveMessage(senderId, receiverId, content);

            try {
                redisService.incrUnread(receiverId, senderId);
            } catch (Exception e) {
                log.warn("Redis incrUnread failed: {}", e.getMessage());
            }

            Map<String, Object> response = Map.of(
                    "msgId", saved.getMsgId(),
                    "senderId", saved.getSenderId(),
                    "receiverId", saved.getReceiverId(),
                    "content", saved.getContent(),
                    "sendTime", saved.getSendTime().toString(),
                    "chatType", saved.getChatType(),
                    "msgType", saved.getMsgType()
            );

            String json = objectMapper.writeValueAsString(response);

            WebSocketSession receiverSession = sessionManager.getSession(receiverId);
            if (receiverSession != null && receiverSession.isOpen()) {
                safeSend(receiverSession, json);
            }

            safeSend(session, json);
        } catch (Exception e) {
            log.error("handleTextMessage error: {}", e.getMessage());
        }
    }

    @Override
    public void afterConnectionClosed(WebSocketSession session, CloseStatus status) throws Exception {
        Long userId = getUserId(session);
        if (userId != null) {
            sessionManager.removeSession(userId);
            log.info("WebSocket closed: userId={}, status={}", userId, status);
        }
    }

    @Override
    public void handleTransportError(WebSocketSession session, Throwable exception) throws Exception {
        Long userId = getUserId(session);
        if (userId != null) {
            sessionManager.removeSession(userId);
        }
        if (session.isOpen()) {
            try {
                session.close(CloseStatus.SERVER_ERROR);
            } catch (IOException ignored) {}
        }
        log.warn("Transport error: userId={}, msg={}", userId, exception.getMessage());
    }

    private void safeSend(WebSocketSession session, String text) {
        if (session == null || !session.isOpen()) return;
        try {
            synchronized (session) {
                session.sendMessage(new TextMessage(text));
            }
        } catch (Exception e) {
            log.warn("safeSend failed: {}", e.getMessage());
        }
    }

    private Long getUserId(WebSocketSession session) {
        Object userId = session.getAttributes().get("userId");
        if (userId instanceof Long) {
            return (Long) userId;
        }
        return null;
    }
}
