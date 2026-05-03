package org.example.dto;

import lombok.Data;

@Data
public class UpdateProfileRequest {

    private String username;
    private String avatarUrl;
}
