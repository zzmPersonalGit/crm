package com.zzm.crm.workbench.web.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

import java.util.logging.Logger;

@Controller
public class MainController {
    private Logger log = Logger.getLogger("controller.web.workbench.com.zzm.crm.MainController");
    @RequestMapping("workbench/main/toIndex")
    public String toIndex(){
        log.info("去往workbench/main/index");
        return "workbench/main/index";
    }
}
