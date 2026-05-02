package org.example.controller;

import org.example.common.Result;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.io.IOException;
import java.util.UUID;

@RestController
@RequestMapping("/api/file")
public class FileController {

    private static final Logger log = LoggerFactory.getLogger(FileController.class);

    @Value("${file.upload-dir:uploads}")
    private String uploadDir;

    @Value("${file.base-url:http://localhost:8081}")
    private String baseUrl;

    @PostMapping("/upload")
    public Result<String> upload(@RequestParam("file") MultipartFile file) {
        if (file.isEmpty()) {
            return Result.error(400, "文件不能为空");
        }

        String originalName = file.getOriginalFilename();
        String ext = "";
        if (originalName != null && originalName.contains(".")) {
            ext = originalName.substring(originalName.lastIndexOf("."));
        }
        String fileName = UUID.randomUUID().toString().replace("-", "") + ext;

        File dir = new File(uploadDir);
        if (!dir.exists()) {
            boolean created = dir.mkdirs();
            log.info("Create upload dir: {} -> {}", dir.getAbsolutePath(), created);
        }

        File dest = new File(dir, fileName);
        try {
            dest.setWritable(true);
            file.transferTo(dest.getAbsoluteFile());
            log.info("File saved: {}", dest.getAbsolutePath());
        } catch (IOException e) {
            log.error("文件保存失败: {}", e.getMessage(), e);
            return Result.error("文件保存失败");
        }

        String url = baseUrl + "/uploads/" + fileName;
        return Result.success(url);
    }
}
