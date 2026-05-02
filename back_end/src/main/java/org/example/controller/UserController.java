package org.example.controller;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.example.common.Result;
import org.example.dto.LoginRequest;
import org.example.dto.LoginResponse;
import org.example.dto.RegisterRequest;
import org.example.entity.UserInfo;
import org.example.service.UserInfoService;
import org.example.util.JwtUtil;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/user")
@RequiredArgsConstructor
public class UserController {

    private final UserInfoService userInfoService;
    private final JwtUtil jwtUtil;

    @PostMapping("/register")
    public Result<Void> register(@Valid @RequestBody RegisterRequest request) {
        userInfoService.register(request.getUsername(), request.getPassword());
        return Result.success();
    }

    @PostMapping("/login")
    public Result<LoginResponse> login(@Valid @RequestBody LoginRequest request) {
        String token = userInfoService.login(request.getUsername(), request.getPassword());

        Long userId = jwtUtil.getUserIdFromToken(token);
        String username = jwtUtil.getUsernameFromToken(token);

        UserInfo user = userInfoService.getById(userId);
        LoginResponse response = LoginResponse.builder()
                .token(token)
                .userId(userId)
                .username(username)
                .avatarUrl(user != null ? user.getAvatarUrl() : null)
                .build();

        return Result.success(response);
    }
}
