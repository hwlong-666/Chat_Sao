package org.example.websocket;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.example.entity.ChatMessage;
import org.example.service.ChatMessageService;
import org.springframework.stereotype.Component;
import org.springframework.web.socket.CloseStatus;
import org.springframework.web.socket.TextMessage;
import org.springframework.web.socket.WebSocketSession;
import org.springframework.web.socket.handler.TextWebSocketHandler;

import java.util.Map;

@Component
public class ChatWebSocketHandler extends TextWebSocketHandler {

    private final ChatMessageService chatMessageService;
    private final WebSocketSessionManager sessionManager;
    private final ObjectMapper objectMapper;

    public ChatWebSocketHandler(ChatMessageService chatMessageService, WebSocketSessionManager sessionManager) {
        this.chatMessageService = chatMessageService;
        this.sessionManager = sessionManager;
        this.objectMapper = new ObjectMapper();
    }

    @Override
    public void afterConnectionEstablished(WebSocketSession session) throws Exception {
        Long userId = getUserId(session);
        if (userId != null) {
            sessionManager.addSession(userId, session);
        }
    }

    @Override
    protected void handleTextMessage(WebSocketSession session, TextMessage message) throws Exception {
        Long senderId = getUserId(session);
        if (senderId == null) {
            session.close(CloseStatus.NOT_ACCEPTABLE);
            return;
        }

        Map<String, Object> payload = objectMapper.readValue(message.getPayload(), Map.class);
        Long receiverId = Long.valueOf(payload.get("receiverId").toString());
        String content = payload.get("content").toString();

        ChatMessage saved = chatMessageService.saveMessage(senderId, receiverId, content);

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
            receiverSession.sendMessage(new TextMessage(json));
        }

        session.sendMessage(new TextMessage(json));
    }

    @Override
    public void afterConnectionClosed(WebSocketSession session, CloseStatus status) throws Exception {
        Long userId = getUserId(session);
        if (userId != null) {
            sessionManager.removeSession(userId);
        }
    }

    @Override
    public void handleTransportError(WebSocketSession session, Throwable exception) throws Exception {
        Long userId = getUserId(session);
        if (userId != null) {
            sessionManager.removeSession(userId);
        }
        if (session.isOpen()) {
            session.close(CloseStatus.SERVER_ERROR);
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
