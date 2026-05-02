package org.example.websocket;

import org.example.service.RedisService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;
import org.springframework.web.socket.WebSocketSession;

import java.util.concurrent.ConcurrentHashMap;

@Component
public class WebSocketSessionManager {

    private static final Logger log = LoggerFactory.getLogger(WebSocketSessionManager.class);

    private final ConcurrentHashMap<Long, WebSocketSession> sessions = new ConcurrentHashMap<>();
    private final RedisService redisService;

    public WebSocketSessionManager(RedisService redisService) {
        this.redisService = redisService;
    }

    public void addSession(Long userId, WebSocketSession session) {
        sessions.put(userId, session);
        try {
            redisService.setOnline(userId);
        } catch (Exception e) {
            log.warn("Redis setOnline failed for user={}: {}", userId, e.getMessage());
        }
    }

    public void removeSession(Long userId) {
        sessions.remove(userId);
        try {
            redisService.setOffline(userId);
        } catch (Exception e) {
            log.warn("Redis setOffline failed for user={}: {}", userId, e.getMessage());
        }
    }

    public WebSocketSession getSession(Long userId) {
        return sessions.get(userId);
    }

    public boolean isOnline(Long userId) {
        WebSocketSession session = sessions.get(userId);
        if (session != null && session.isOpen()) {
            return true;
        }
        try {
            return redisService.isOnline(userId);
        } catch (Exception e) {
            return false;
        }
    }

    public void refreshOnline(Long userId) {
        try {
            redisService.refreshOnline(userId);
        } catch (Exception e) {
            log.warn("Redis refreshOnline failed for user={}: {}", userId, e.getMessage());
        }
    }
}
