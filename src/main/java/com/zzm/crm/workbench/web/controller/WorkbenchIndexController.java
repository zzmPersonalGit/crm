package com.zzm.crm.workbench.web.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

import java.util.logging.Logger;

@Controller
public class WorkbenchIndexController {
    private Logger log = Logger.getLogger("controller.web.workbench.com.zzm.crm.WorkbenchIndexController");
    @RequestMapping("workbench/toIndex")
    public String toIndex(){
        log.info("登录成功，去往workbench/main/index页面");
        return "workbench/index";
    }
}
