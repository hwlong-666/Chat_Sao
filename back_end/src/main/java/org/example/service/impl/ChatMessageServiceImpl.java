package org.example.service.impl;

import org.example.dto.ChatSessionVO;
import org.example.entity.ChatMessage;
import org.example.mapper.ChatMessageMapper;
import org.example.mapper.FriendRelationMapper;
import org.example.service.ChatMessageService;
import org.example.service.RedisService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.*;

@Service
public class ChatMessageServiceImpl implements ChatMessageService {

    private static final Logger log = LoggerFactory.getLogger(ChatMessageServiceImpl.class);

    private final ChatMessageMapper chatMessageMapper;
    private final FriendRelationMapper friendRelationMapper;
    private final RedisService redisService;

    public ChatMessageServiceImpl(ChatMessageMapper chatMessageMapper, FriendRelationMapper friendRelationMapper, RedisService redisService) {
        this.chatMessageMapper = chatMessageMapper;
        this.friendRelationMapper = friendRelationMapper;
        this.redisService = redisService;
    }

    @Override
    public ChatMessage saveMessage(Long senderId, Long receiverId, String content) {
        return saveMessage(senderId, receiverId, content, 0);
    }

    @Override
    public ChatMessage saveMessage(Long senderId, Long receiverId, String content, int msgType) {
        ChatMessage msg = new ChatMessage();
        msg.setSenderId(senderId);
        msg.setReceiverId(receiverId);
        msg.setChatType(0);
        msg.setMsgType(msgType);
        msg.setContent(content);
        msg.setIsRead(0);
        msg.setSendTime(LocalDateTime.now());
        chatMessageMapper.insert(msg);
        return msg;
    }

    @Override
    public List<ChatMessage> getChatHistory(Long userId1, Long userId2, int limit, int offset) {
        return chatMessageMapper.selectChatHistory(userId1, userId2, limit, offset);
    }

    @Override
    public List<ChatSessionVO> getChatSessions(Long userId) {
        List<Map<String, Object>> friends = friendRelationMapper.selectFriendList(userId);
        if (friends == null || friends.isEmpty()) {
            return new ArrayList<>();
        }

        Map<Long, ChatSessionVO> sessionMap = new LinkedHashMap<>();
        for (Map<String, Object> friend : friends) {
            Long friendId = ((Number) friend.get("userId")).longValue();
            String username = (String) friend.get("username");
            ChatSessionVO vo = new ChatSessionVO();
            vo.setFriendId(friendId);
            vo.setFriendUsername(username != null ? username : "Unknown");
            vo.setLastMessage("");
            vo.setUnreadCount(0);
            vo.setLastTime("");
            sessionMap.put(friendId, vo);
        }

        List<ChatMessage> lastMessages = chatMessageMapper.selectLastMessages(userId);
        if (lastMessages != null) {
            for (ChatMessage msg : lastMessages) {
                Long otherId = msg.getSenderId().equals(userId) ? msg.getReceiverId() : msg.getSenderId();
                ChatSessionVO vo = sessionMap.get(otherId);
                if (vo != null) {
                    vo.setLastMessage(msg.getContent());
                    vo.setLastTime(msg.getSendTime() != null ? msg.getSendTime().toString() : "");
                    vo.setLastMsgType(msg.getMsgType());
                }
            }
        }

        Map<Long, Integer> redisUnread;
        try {
            redisUnread = redisService.getAllUnread(userId);
        } catch (Exception e) {
            log.warn("Redis getAllUnread failed: {}", e.getMessage());
            redisUnread = Collections.emptyMap();
        }
        for (Map.Entry<Long, ChatSessionVO> entry : sessionMap.entrySet()) {
            Long friendId = entry.getKey();
            ChatSessionVO vo = entry.getValue();
            Integer redisCount = redisUnread.get(friendId);
            if (redisCount != null && redisCount > 0) {
                vo.setUnreadCount(redisCount);
            } else {
                int dbCount = chatMessageMapper.countUnreadWithFriend(userId, friendId);
                vo.setUnreadCount(dbCount);
                if (dbCount > 0) {
                    try {
                        redisService.incrUnread(userId, friendId);
                    } catch (Exception ignored) {}
                }
            }
        }

        return new ArrayList<>(sessionMap.values());
    }

    @Override
    public void markAsRead(Long userId, Long friendId) {
        chatMessageMapper.markAsRead(userId, friendId);
        try {
            redisService.clearUnread(userId, friendId);
        } catch (Exception e) {
            log.warn("Redis clearUnread failed: {}", e.getMessage());
        }
    }
}
