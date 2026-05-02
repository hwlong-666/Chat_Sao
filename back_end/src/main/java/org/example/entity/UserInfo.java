package org.example.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@TableName("user_info")
public class UserInfo {

    @TableId(type = IdType.AUTO)
    private Long userId;

    private String username;

    private String password;

    private String avatarUrl;

    private LocalDateTime createTime;

    private LocalDateTime updateTime;
}
