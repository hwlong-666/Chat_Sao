package org.example.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@TableName("chat_group")
public class ChatGroup {

    @TableId(type = IdType.AUTO)
    private Long groupId;

    private String groupName;

    private Long ownerId;

    private LocalDateTime createTime;
}
