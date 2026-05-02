package org.example.controller;

import org.example.common.Result;
import org.example.context.UserContext;
import org.example.dto.ChatMessageVO;
import org.example.dto.ChatSessionVO;
import org.example.entity.ChatMessage;
import org.example.service.ChatMessageService;
import org.springframework.web.bind.annotation.*;

import java.util.ArrayList;
import java.util.List;

@RestController
@RequestMapping("/api/chat")
public class ChatController {

    private final ChatMessageService chatMessageService;

    public ChatController(ChatMessageService chatMessageService) {
        this.chatMessageService = chatMessageService;
    }

    @GetMapping("/sessions")
    public Result<List<ChatSessionVO>> getChatSessions() {
        Long userId = UserContext.getUserId();
        List<ChatSessionVO> sessions = chatMessageService.getChatSessions(userId);
        return Result.success(sessions);
    }

    @GetMapping("/history")
    public Result<List<ChatMessageVO>> getChatHistory(
            @RequestParam Long friendId,
            @RequestParam(defaultValue = "50") int limit,
            @RequestParam(defaultValue = "0") int offset) {
        Long userId = UserContext.getUserId();
        List<ChatMessage> messages = chatMessageService.getChatHistory(userId, friendId, limit, offset);

        List<ChatMessageVO> voList = new ArrayList<>();
        for (ChatMessage msg : messages) {
            ChatMessageVO vo = new ChatMessageVO();
            vo.setMsgId(msg.getMsgId());
            vo.setSenderId(msg.getSenderId());
            vo.setReceiverId(msg.getReceiverId());
            vo.setChatType(msg.getChatType());
            vo.setMsgType(msg.getMsgType());
            vo.setContent(msg.getContent());
            vo.setIsRead(msg.getIsRead());
            vo.setSendTime(msg.getSendTime() != null ? msg.getSendTime().toString() : null);
            voList.add(vo);
        }
        return Result.success(voList);
    }

    @PutMapping("/read")
    public Result<Void> markAsRead(@RequestParam Long friendId) {
        Long userId = UserContext.getUserId();
        chatMessageService.markAsRead(userId, friendId);
        return Result.success(null);
    }
}
