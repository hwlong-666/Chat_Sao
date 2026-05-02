package org.example.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Select;
import org.example.entity.FriendRelation;

import java.util.List;
import java.util.Map;

@Mapper
public interface FriendRelationMapper extends BaseMapper<FriendRelation> {

    @Select("SELECT fr.friend_id AS userId, ui.username, ui.avatar_url AS avatarUrl " +
            "FROM friend_relation fr " +
            "LEFT JOIN user_info ui ON fr.friend_id = ui.user_id " +
            "WHERE fr.user_id = #{userId} AND fr.status = 1 " +
            "UNION " +
            "SELECT fr.user_id AS userId, ui.username, ui.avatar_url AS avatarUrl " +
            "FROM friend_relation fr " +
            "LEFT JOIN user_info ui ON fr.user_id = ui.user_id " +
            "WHERE fr.friend_id = #{userId} AND fr.status = 1")
    List<Map<String, Object>> selectFriendList(Long userId);
}
