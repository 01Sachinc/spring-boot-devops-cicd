package com.devops.cicd;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class DevopsApplication {

    public static void main(String[] args) {
        SpringApplication.run(DevopsApplication.class, args);
        System.out.println("====================================================================");
        System.out.println("   Enterprise DevOps CI/CD Spring Boot Application Started Successfully!   ");
        System.out.println("   Running on port: 8085                                            ");
        System.out.println("====================================================================");
    }
}
