package org.example.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import org.example.dto.FriendInfo;
import org.example.entity.FriendRelation;
import org.example.entity.UserInfo;
import org.example.mapper.FriendRelationMapper;
import org.example.mapper.UserInfoMapper;
import org.example.service.FriendRelationService;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

@Service
public class FriendRelationServiceImpl implements FriendRelationService {

    private final FriendRelationMapper friendRelationMapper;
    private final UserInfoMapper userInfoMapper;

    public FriendRelationServiceImpl(FriendRelationMapper friendRelationMapper, UserInfoMapper userInfoMapper) {
        this.friendRelationMapper = friendRelationMapper;
        this.userInfoMapper = userInfoMapper;
    }

    @Override
    public List<FriendInfo> searchUser(String username) {
        LambdaQueryWrapper<UserInfo> wrapper = new LambdaQueryWrapper<>();
        wrapper.like(UserInfo::getUsername, username)
                .select(UserInfo::getUserId, UserInfo::getUsername, UserInfo::getAvatarUrl);
        List<UserInfo> users = userInfoMapper.selectList(wrapper);

        List<FriendInfo> result = new ArrayList<>();
        for (UserInfo user : users) {
            FriendInfo info = new FriendInfo();
            info.setUserId(user.getUserId());
            info.setUsername(user.getUsername());
            info.setAvatarUrl(user.getAvatarUrl());
            result.add(info);
        }
        return result;
    }

    @Override
    public void addFriend(Long userId, Long friendId) {
        if (userId.equals(friendId)) {
            throw new RuntimeException("不能添加自己为好友");
        }

        UserInfo friend = userInfoMapper.selectById(friendId);
        if (friend == null) {
            throw new RuntimeException("目标用户不存在");
        }

        LambdaQueryWrapper<FriendRelation> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(FriendRelation::getUserId, userId)
                .eq(FriendRelation::getFriendId, friendId);
        FriendRelation existing = friendRelationMapper.selectOne(wrapper);

        if (existing != null) {
            if (existing.getStatus() == 1) {
                throw new RuntimeException("已经是好友了");
            }
            if (existing.getStatus() == 0) {
                throw new RuntimeException("已发送过好友请求，等待对方通过");
            }
            if (existing.getStatus() == 2) {
                existing.setStatus(0);
                friendRelationMapper.updateById(existing);
                return;
            }
            return;
        }

        FriendRelation relation = new FriendRelation();
        relation.setUserId(userId);
        relation.setFriendId(friendId);
        relation.setStatus(0);
        friendRelationMapper.insert(relation);
    }

    @Override
    public List<FriendInfo> getFriendRequests(Long userId) {
        LambdaQueryWrapper<FriendRelation> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(FriendRelation::getFriendId, userId)
                .eq(FriendRelation::getStatus, 0);
        List<FriendRelation> requests = friendRelationMapper.selectList(wrapper);

        List<FriendInfo> result = new ArrayList<>();
        for (FriendRelation req : requests) {
            UserInfo requester = userInfoMapper.selectById(req.getUserId());
            if (requester != null) {
                FriendInfo info = new FriendInfo();
                info.setUserId(requester.getUserId());
                info.setUsername(requester.getUsername());
                info.setAvatarUrl(requester.getAvatarUrl());
                result.add(info);
            }
        }
        return result;
    }

    @Override
    public void acceptFriend(Long userId, Long requesterId) {
        LambdaQueryWrapper<FriendRelation> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(FriendRelation::getUserId, requesterId)
                .eq(FriendRelation::getFriendId, userId)
                .eq(FriendRelation::getStatus, 0);
        FriendRelation request = friendRelationMapper.selectOne(wrapper);

        if (request == null) {
            throw new RuntimeException("好友请求不存在");
        }

        request.setStatus(1);
        friendRelationMapper.updateById(request);

        LambdaQueryWrapper<FriendRelation> reverseWrapper = new LambdaQueryWrapper<>();
        reverseWrapper.eq(FriendRelation::getUserId, userId)
                .eq(FriendRelation::getFriendId, requesterId);
        FriendRelation reverse = friendRelationMapper.selectOne(reverseWrapper);

        if (reverse != null) {
            reverse.setStatus(1);
            friendRelationMapper.updateById(reverse);
        } else {
            FriendRelation reverseRelation = new FriendRelation();
            reverseRelation.setUserId(userId);
            reverseRelation.setFriendId(requesterId);
            reverseRelation.setStatus(1);
            friendRelationMapper.insert(reverseRelation);
        }
    }

    @Override
    public void rejectFriend(Long userId, Long requesterId) {
        LambdaQueryWrapper<FriendRelation> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(FriendRelation::getUserId, requesterId)
                .eq(FriendRelation::getFriendId, userId)
                .eq(FriendRelation::getStatus, 0);
        FriendRelation request = friendRelationMapper.selectOne(wrapper);

        if (request == null) {
            throw new RuntimeException("好友请求不存在");
        }

        request.setStatus(2);
        friendRelationMapper.updateById(request);
    }

    @Override
    public List<FriendInfo> getFriendList(Long userId) {
        List<Map<String, Object>> rows = friendRelationMapper.selectFriendList(userId);

        List<FriendInfo> result = new ArrayList<>();
        for (Map<String, Object> row : rows) {
            FriendInfo info = new FriendInfo();
            info.setUserId(((Number) row.get("userId")).longValue());
            info.setUsername((String) row.get("username"));
            info.setAvatarUrl((String) row.get("avatarUrl"));
            result.add(info);
        }
        return result;
    }

    @Override
    public void removeFriend(Long userId, Long friendId) {
        LambdaQueryWrapper<FriendRelation> wrapper1 = new LambdaQueryWrapper<>();
        wrapper1.eq(FriendRelation::getUserId, userId)
                .eq(FriendRelation::getFriendId, friendId)
                .eq(FriendRelation::getStatus, 1);
        FriendRelation rel1 = friendRelationMapper.selectOne(wrapper1);

        if (rel1 == null) {
            throw new RuntimeException("不是好友关系");
        }
        friendRelationMapper.deleteById(rel1.getId());

        LambdaQueryWrapper<FriendRelation> wrapper2 = new LambdaQueryWrapper<>();
        wrapper2.eq(FriendRelation::getUserId, friendId)
                .eq(FriendRelation::getFriendId, userId)
                .eq(FriendRelation::getStatus, 1);
        FriendRelation rel2 = friendRelationMapper.selectOne(wrapper2);
        if (rel2 != null) {
            friendRelationMapper.deleteById(rel2.getId());
        }
    }
}
