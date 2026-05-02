package org.example.service.impl;

import org.example.dto.ChatSessionVO;
import org.example.entity.ChatMessage;
import org.example.mapper.ChatMessageMapper;
import org.example.mapper.FriendRelationMapper;
import org.example.service.ChatMessageService;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.*;

@Service
public class ChatMessageServiceImpl implements ChatMessageService {

    private final ChatMessageMapper chatMessageMapper;
    private final FriendRelationMapper friendRelationMapper;

    public ChatMessageServiceImpl(ChatMessageMapper chatMessageMapper, FriendRelationMapper friendRelationMapper) {
        this.chatMessageMapper = chatMessageMapper;
        this.friendRelationMapper = friendRelationMapper;
    }

    @Override
    public ChatMessage saveMessage(Long senderId, Long receiverId, String content) {
        ChatMessage msg = new ChatMessage();
        msg.setSenderId(senderId);
        msg.setReceiverId(receiverId);
        msg.setChatType(0);
        msg.setMsgType(0);
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
                    int unread = chatMessageMapper.countUnreadWithFriend(userId, otherId);
                    vo.setUnreadCount(unread);
                }
            }
        }

        return new ArrayList<>(sessionMap.values());
    }

    @Override
    public void markAsRead(Long userId, Long friendId) {
        chatMessageMapper.markAsRead(userId, friendId);
    }
}
