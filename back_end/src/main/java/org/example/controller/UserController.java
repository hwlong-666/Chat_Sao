package org.example.controller;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.example.common.Result;
import org.example.context.UserContext;
import org.example.dto.LoginRequest;
import org.example.dto.LoginResponse;
import org.example.dto.RegisterRequest;
import org.example.dto.UpdateProfileRequest;
import org.example.entity.UserInfo;
import org.example.service.UserInfoService;
import org.example.util.JwtUtil;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.io.IOException;
import java.util.UUID;

@RestController
@RequestMapping("/api/user")
@RequiredArgsConstructor
public class UserController {

    private final UserInfoService userInfoService;
    private final JwtUtil jwtUtil;

    @Value("${file.upload-dir:uploads}")
    private String uploadDir;

    @Value("${file.base-url:http://localhost:8081}")
    private String baseUrl;

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

    @GetMapping("/profile")
    public Result<UserInfo> getProfile() {
        Long userId = UserContext.getUserId();
        UserInfo user = userInfoService.getProfile(userId);
        if (user != null) {
            user.setPassword(null);
        }
        return Result.success(user);
    }

    @PutMapping("/profile")
    public Result<LoginResponse> updateProfile(@RequestBody UpdateProfileRequest request) {
        Long userId = UserContext.getUserId();
        userInfoService.updateProfile(userId, request.getUsername(), request.getAvatarUrl());

        UserInfo updatedUser = userInfoService.getById(userId);
        String newToken = jwtUtil.generateToken(userId, updatedUser.getUsername());

        LoginResponse response = LoginResponse.builder()
                .token(newToken)
                .userId(userId)
                .username(updatedUser.getUsername())
                .avatarUrl(updatedUser.getAvatarUrl())
                .build();

        return Result.success(response);
    }

    @PostMapping("/avatar")
    public Result<String> uploadAvatar(@RequestParam("file") MultipartFile file) {
        if (file.isEmpty()) {
            return Result.error(400, "文件不能为空");
        }

        String originalName = file.getOriginalFilename();
        String ext = "";
        if (originalName != null && originalName.contains(".")) {
            ext = originalName.substring(originalName.lastIndexOf("."));
        }
        String fileName = "avatar_" + UUID.randomUUID().toString().replace("-", "") + ext;

        File dir = new File(uploadDir);
        if (!dir.exists()) {
            dir.mkdirs();
        }

        File dest = new File(dir, fileName);
        try {
            file.transferTo(dest.getAbsoluteFile());
        } catch (IOException e) {
            return Result.error("头像上传失败");
        }

        String url = baseUrl + "/uploads/" + fileName;

        Long userId = UserContext.getUserId();
        userInfoService.updateProfile(userId, null, url);

        return Result.success(url);
    }
}
