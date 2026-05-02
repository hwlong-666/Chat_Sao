package org.example.dto;

import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class AddFriendRequest {

    @NotNull(message = "好友ID不能为空")
    private Long friendId;
}
