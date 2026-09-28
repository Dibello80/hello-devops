package com.angelo.hellodevops;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class HelloController {
    @GetMapping("/api/hello")
    public String hello() {
        return "Hello from Angelo's automated DevOps deployment!";
    }

    @GetMapping("/health")
    public String health() {
        return "UP";
    }
}
