package org.example.service;

import org.example.dto.FriendInfo;

import java.util.List;

public interface FriendRelationService {

    List<FriendInfo> searchUser(String username);

    void addFriend(Long userId, Long friendId);

    List<FriendInfo> getFriendRequests(Long userId);

    void acceptFriend(Long userId, Long requesterId);

    void rejectFriend(Long userId, Long requesterId);

    List<FriendInfo> getFriendList(Long userId);
}
