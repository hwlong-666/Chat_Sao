package org.example.controller;

import jakarta.validation.Valid;
import org.example.common.Result;
import org.example.context.UserContext;
import org.example.dto.AddFriendRequest;
import org.example.dto.FriendInfo;
import org.example.service.FriendRelationService;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/friend")
public class FriendRelationController {

    private final FriendRelationService friendRelationService;

    public FriendRelationController(FriendRelationService friendRelationService) {
        this.friendRelationService = friendRelationService;
    }

    @GetMapping("/search")
    public Result<List<FriendInfo>> searchUser(@RequestParam String username) {
        List<FriendInfo> users = friendRelationService.searchUser(username);
        return Result.success(users);
    }

    @PostMapping("/add")
    public Result<Void> addFriend(@Valid @RequestBody AddFriendRequest request) {
        Long userId = UserContext.getUserId();
        friendRelationService.addFriend(userId, request.getFriendId());
        return Result.success();
    }

    @GetMapping("/requests")
    public Result<List<FriendInfo>> getFriendRequests() {
        Long userId = UserContext.getUserId();
        List<FriendInfo> requests = friendRelationService.getFriendRequests(userId);
        return Result.success(requests);
    }

    @PostMapping("/accept")
    public Result<Void> acceptFriend(@Valid @RequestBody AddFriendRequest request) {
        Long userId = UserContext.getUserId();
        friendRelationService.acceptFriend(userId, request.getFriendId());
        return Result.success();
    }

    @PostMapping("/reject")
    public Result<Void> rejectFriend(@Valid @RequestBody AddFriendRequest request) {
        Long userId = UserContext.getUserId();
        friendRelationService.rejectFriend(userId, request.getFriendId());
        return Result.success();
    }

    @GetMapping("/list")
    public Result<List<FriendInfo>> getFriendList() {
        Long userId = UserContext.getUserId();
        List<FriendInfo> friends = friendRelationService.getFriendList(userId);
        return Result.success(friends);
    }
}
