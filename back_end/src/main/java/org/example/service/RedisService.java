package org.example.service;

import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.Map;
import java.util.Set;
import java.util.concurrent.TimeUnit;

@Service
public class RedisService {

    private final StringRedisTemplate redisTemplate;

    private static final String ONLINE_KEY_PREFIX = "user_online:";
    private static final String UNREAD_KEY_PREFIX = "im:unread:";
    private static final long ONLINE_TTL_SECONDS = 300;

    public RedisService(StringRedisTemplate redisTemplate) {
        this.redisTemplate = redisTemplate;
    }

    public void setOnline(Long userId) {
        String key = ONLINE_KEY_PREFIX + userId;
        redisTemplate.opsForValue().set(key, "1", ONLINE_TTL_SECONDS, TimeUnit.SECONDS);
    }

    public void setOffline(Long userId) {
        redisTemplate.delete(ONLINE_KEY_PREFIX + userId);
    }

    public boolean isOnline(Long userId) {
        String val = redisTemplate.opsForValue().get(ONLINE_KEY_PREFIX + userId);
        return "1".equals(val);
    }

    public void refreshOnline(Long userId) {
        String key = ONLINE_KEY_PREFIX + userId;
        String val = redisTemplate.opsForValue().get(key);
        if (val != null) {
            redisTemplate.expire(key, ONLINE_TTL_SECONDS, TimeUnit.SECONDS);
        }
    }

    public void incrUnread(Long receiverId, Long senderId) {
        String key = UNREAD_KEY_PREFIX + receiverId;
        redisTemplate.opsForHash().increment(key, senderId.toString(), 1);
    }

    public int getUnread(Long receiverId, Long senderId) {
        String key = UNREAD_KEY_PREFIX + receiverId;
        Object val = redisTemplate.opsForHash().get(key, senderId.toString());
        if (val != null) {
            return Integer.parseInt(val.toString());
        }
        return -1;
    }

    public Map<Long, Integer> getAllUnread(Long receiverId) {
        String key = UNREAD_KEY_PREFIX + receiverId;
        Map<Object, Object> entries = redisTemplate.opsForHash().entries(key);
        Map<Long, Integer> result = new HashMap<>();
        for (Map.Entry<Object, Object> entry : entries.entrySet()) {
            Long senderId = Long.parseLong(entry.getKey().toString());
            int count = Integer.parseInt(entry.getValue().toString());
            result.put(senderId, count);
        }
        return result;
    }

    public void clearUnread(Long receiverId, Long senderId) {
        String key = UNREAD_KEY_PREFIX + receiverId;
        redisTemplate.opsForHash().delete(key, senderId.toString());
    }

    public void clearAllUnread(Long receiverId, Set<Long> senderIds) {
        String key = UNREAD_KEY_PREFIX + receiverId;
        Object[] fields = senderIds.stream().map(Object::toString).toArray(Object[]::new);
        if (fields.length > 0) {
            redisTemplate.opsForHash().delete(key, fields);
        }
    }
}
