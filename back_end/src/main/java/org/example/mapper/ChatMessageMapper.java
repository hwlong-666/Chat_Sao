package org.example.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Select;
import org.apache.ibatis.annotations.Update;
import org.example.entity.ChatMessage;

import java.util.List;

@Mapper
public interface ChatMessageMapper extends BaseMapper<ChatMessage> {

    @Select("SELECT * FROM chat_message WHERE (sender_id = #{userId1} AND receiver_id = #{userId2}) OR (sender_id = #{userId2} AND receiver_id = #{userId1}) ORDER BY send_time ASC LIMIT #{limit} OFFSET #{offset}")
    List<ChatMessage> selectChatHistory(Long userId1, Long userId2, int limit, int offset);

    @Select("SELECT m.* FROM chat_message m INNER JOIN (" +
            "  SELECT MAX(msg_id) as max_id FROM chat_message " +
            "  WHERE sender_id = #{userId} OR receiver_id = #{userId}" +
            "  GROUP BY CASE WHEN sender_id = #{userId} THEN receiver_id ELSE sender_id END" +
            ") latest ON m.msg_id = latest.max_id ORDER BY m.send_time DESC")
    List<ChatMessage> selectLastMessages(Long userId);

    @Select("SELECT COUNT(*) FROM chat_message WHERE receiver_id = #{userId} AND is_read = 0")
    int countUnread(Long userId);

    @Select("SELECT COUNT(*) FROM chat_message WHERE receiver_id = #{userId} AND sender_id = #{friendId} AND is_read = 0")
    int countUnreadWithFriend(Long userId, Long friendId);

    @Update("UPDATE chat_message SET is_read = 1 WHERE receiver_id = #{userId} AND sender_id = #{friendId} AND is_read = 0")
    int markAsRead(Long userId, Long friendId);
}
