package com.zzm.crm.workbench.web.controller;

import com.zzm.crm.commons.pojo.ReturnChartObject;
import com.zzm.crm.workbench.service.TransactionService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import java.util.List;
import java.util.logging.Logger;

@Controller
public class ChartController {
    Logger log = Logger.getLogger("controller.web.workbench.com.zzm.crm.ChartController");

    @Autowired
    private TransactionService transactionService;

    @RequestMapping("/workbench/chart/transaction/toCharIndex")
    public String toCharIndex(){
        log.info("去往图表信息首页");
        return "workbench/chart/transaction/index";
    }

    @RequestMapping("/workbench/chart/transaction/returnCharPojo")
    @ResponseBody
    public Object returnCharPojo(){
        log.info("返回图表相关数据");
        List<ReturnChartObject> chartDataList = transactionService.queryReturnChartPojoByGroupByStage();
        return chartDataList;
    }
}
