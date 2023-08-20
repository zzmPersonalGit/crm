package com.zzm.crm.web.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

import java.util.logging.Logger;

@Controller
public class IndexController {
    Logger log = Logger.getLogger("controller.web.com.zzm.crm.IndexController");

    @RequestMapping("/")
    public String showIndex(){
        log.info("收到/请求,跳转Index页");
        return "index";
    }
}
