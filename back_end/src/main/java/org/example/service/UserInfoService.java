package org.example.service;

import com.baomidou.mybatisplus.extension.service.IService;
import org.example.entity.UserInfo;

public interface UserInfoService extends IService<UserInfo> {

    void register(String username, String password);

    String login(String username, String password);

    void updateProfile(Long userId, String username, String avatarUrl);

    UserInfo getProfile(Long userId);
}
