package com.zzm.crm.workbench.web.controller;

import com.zzm.crm.settings.service.DicValueService;
import com.zzm.crm.settings.service.UserService;
import com.zzm.crm.workbench.pojo.*;
import com.zzm.crm.commons.constants.Constans;
import com.zzm.crm.commons.pojo.ReturnObjectMessage;
import com.zzm.crm.commons.utils.DateFormatUtil;
import com.zzm.crm.commons.utils.UUIDUtil;
import com.zzm.crm.settings.pojo.DicValue;
import com.zzm.crm.settings.pojo.User;
import com.zzm.crm.workbench.mapper.TransactionRemarkMapper;
import com.zzm.crm.workbench.service.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;
import java.util.*;
import java.util.logging.Logger;

@Controller
public class TransactionController {
    @Autowired
    private DicValueService dicValueService;
    @Autowired
    private UserService userService;
    @Autowired
    private ActivityService activityService;
    @Autowired
    private CustomerService customerService;
    @Autowired
    private TransactionService transactionService;
    @Autowired
    private TransactionRemarkService transactionRemarkService;
    @Autowired
    private TransactionHistoryService transactionHistoryService;
    @Autowired
    private ContactsService contactsService;
    @Autowired
    private TransactionRemarkMapper transactionRemarkMapper;

    private Logger log = Logger.getLogger("controller.web.workbench.com.zzm.crm.TransactionController");

    @RequestMapping("/workbench/transaction/toTranIndex")
    public String toTranIndex(HttpServletRequest request) {
        log.info("去往交易信息的首页");
        //需要携带三个字典值过去
        List<User> users = userService.queryAllUsers();
        List<DicValue> stage = dicValueService.queryDicValueGroupByDicType("stage");
        List<DicValue> transactionType = dicValueService.queryDicValueGroupByDicType("transactionType");
        List<DicValue> source = dicValueService.queryDicValueGroupByDicType("source");
        //存到域里面
        request.setAttribute("users", users);
        request.setAttribute("stage", stage);
        request.setAttribute("transactionType", transactionType);
        request.setAttribute("source", source);
        return "workbench/transaction/index";
    }

    @RequestMapping("/workbench/transaction/toSaveIndex")
    public String toSaveIndex(HttpServletRequest request, String id) {
        // 所有者
        List<User> userList = userService.queryAllUsers();
        // 阶段
        List<DicValue> stage = dicValueService.queryDicValueGroupByDicType("stage");
        // 类型
        List<DicValue> transactionType = dicValueService.queryDicValueGroupByDicType("transactionType");
        // 来源
        List<DicValue> source = dicValueService.queryDicValueGroupByDicType("source");

        // 存到域里面
        request.setAttribute("userList", userList);
        request.setAttribute("stage", stage);
        request.setAttribute("transactionType", transactionType);
        request.setAttribute("source", source);

        // 查询所有的客户名称
        List<Customer> customers = customerService.queryAll();
        request.setAttribute("customers", customers);

        if (id != null) {
            // 表明是展示数据
            Transaction transaction = transactionService.selectById(id);
            request.setAttribute("transaction", transaction);
            log.info("去往更新交易信息的首页");
            return "workbench/transaction/update";
        }

        log.info("去往保存交易信息的首页");
        return "workbench/transaction/save";
    }

    @RequestMapping("/workbench/transaction/fuzzyQueryForSave")
    @ResponseBody
    public Object fuzzyQueryForSave(String value, String contactsId) {
        log.info("根据联系人ID和参数搜索已经关联但是未创建交易的市场活动");
        System.out.println(value);
        System.out.println(contactsId);
        List<Activity> activityList = activityService.queryModifyActivityFuzzyForSave(value, contactsId);
        return activityList;
    }

    @RequestMapping("/workbench/transaction/optionValuePossible")
    @ResponseBody
    public Object optionValuePossible(String optionValue) {
        log.info("可能性展示");
        // 加载可能性的配置文件
        ResourceBundle bundle = ResourceBundle.getBundle("possible");
        String string = bundle.getString(optionValue);
        return string;
    }

    @RequestMapping("/workbench/transaction/typeaheadText")
    @ResponseBody
    public Object typeaheadText(String fuzzyName) {
        log.info("模糊查询客户信息");
        List<String> list = customerService.queryModifyNameByFuzzyName(fuzzyName);
        return list;
    }

    @RequestMapping("/workbench/transaction/saveTransaction")
    @ResponseBody
    public Object saveTransaction(@RequestParam Map<String, Object> map, HttpSession session) {
        log.info("保存交易信息");
        ReturnObjectMessage returnObjectMessage = new ReturnObjectMessage();
        map.put(Constans.SESSION_LOGIN_INF, session.getAttribute(Constans.SESSION_LOGIN_INF));
        try {
            transactionService.saveTransactionUseTran(map);
            returnObjectMessage.setCode(Constans.RETURN_OBJECT_SUCCESS);
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            return returnObjectMessage;
        }
    }

    @RequestMapping("/workbench/transaction/showTranDetail")
    public String saveTransaction(HttpServletRequest request, String id) {
        log.info("展示交易的细节信息");

        //查询三段交易信息，存到域里
        Transaction transaction = transactionService.queryModifyDataByPrimaryKey(id);
        List<TransactionRemark> transactionRemarkList = transactionRemarkService.queryModifyDataByTranId(id);
        List<TransactionHistory> transactionHistoryList = transactionHistoryService.selectModifyDataByTranId(id);
        // 查询是哪个市场活动
        Activity activity = transactionService.queryActivityInfoByTranId(id);

        //存到域里
        request.setAttribute("transaction", transaction);
        request.setAttribute("transactionRemarkList", transactionRemarkList);
        request.setAttribute("transactionHistoryList", transactionHistoryList);
        request.setAttribute("activity",activity);

        //第二次获取数据，获取全部阶段的数据值
        List<DicValue> stageList = dicValueService.queryDicValueGroupByDicType("stage");
        String tranStage = transaction.getStage();
        String tranStageId = "";
        for (int i = 0; i < stageList.size(); i++) {
            if (tranStage.equals(stageList.get(i).getValue())) {
                tranStageId = stageList.get(i).getOrderNo();
            }
        }

        //去得到可能性的值
        String possible = ResourceBundle.getBundle("possible").getString(transaction.getStage());
        Map<String, Object> map = new HashMap<>();
        map.put("tranStageId", tranStageId);
        map.put("possible", possible);
        request.setAttribute("toolMap", map);
        request.setAttribute("stageList", stageList);
        return "workbench/transaction/detail";
    }

    @RequestMapping("/workbench/transaction/deleteTranscationByIds")
    @ResponseBody
    public Object deleteTranscation(String[] id) {
        log.info("根据交易的ID列表删除交易信息");
        ReturnObjectMessage objectMessage = new ReturnObjectMessage();
        int ret = -1;
        try {
            ret = transactionService.deleteByIds(id);
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            if (ret >= 0) {
                objectMessage.setCode(Constans.RETURN_OBJECT_SUCCESS);
            }
            return objectMessage;
        }
    }

    @RequestMapping("/workbench/transcation/queryByConditionForPage")
    @ResponseBody
    public Object queryByConditionForPage(String name, String owner, String customerId, String contactsId,
                                          String source, String transactionType, String stage, Integer pageNo, Integer pageSize) {
        log.info("交易信息分页查询请求");
        // 封装数据为map
        Map<Object, Object> map = new HashMap<>();
        map.put("name", name);
        map.put("owner", owner);
        map.put("customerId", customerId);
        map.put("contactsId", contactsId);
        map.put("source", source);
        map.put("transactionType", transactionType);
        map.put("stage", stage);

        // 进一步处理数据后封装
        Integer beginIndex = (pageNo - 1) * pageSize;
        map.put("beginIndex", beginIndex);
        map.put("pageSize", pageSize);

        // 打包数据，返回JSON字符串给前端
        Map<String, Object> transcationInformation = new HashMap<>();
        try {
            // 调用逻辑层的方法，返回交易信息集合和总条数
            List<Transaction> transactions = transactionService.queryTransactionByConditionForPage(map);
            int totalRows = transactionService.queryCountOfTransactionForPage(map);

            // 把市场活动的信息和总记录数存入返回的对象里
            transcationInformation.put("transactions", transactions);
            transcationInformation.put("totalRows", totalRows);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return transcationInformation;
    }

    @RequestMapping("/workbench/transaction/editTransaction")
    @ResponseBody
    public Object editTran(Transaction transaction, HttpSession session) {
        log.info("更新交易信息");
        //二次封装数据
        String editTime = DateFormatUtil.formatDateTime(new Date());
        User user = (User) session.getAttribute(Constans.SESSION_LOGIN_INF);
        String id = user.getId();
        transaction.setEditTime(editTime);
        transaction.setEditBy(id);

        //调用service层的方法，并且进行判断
        ReturnObjectMessage returnObjectMessage = new ReturnObjectMessage();
        returnObjectMessage.setCode(Constans.RETURN_OBJECT_FAILURE);
        returnObjectMessage.setMessage("修改功能调用失败...");
        try {
            int ret = transactionService.editTranscation(transaction);
            if (ret > 0) {
                returnObjectMessage.setCode(Constans.RETURN_OBJECT_SUCCESS);
                returnObjectMessage.setMessage("修改功能调用成功...");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return returnObjectMessage;
    }

    @RequestMapping("/workbench/transaction/createRemarkDetail")
    @ResponseBody
    public Object createRemarkDetail(HttpSession session, TransactionRemark remark) {
        log.info("保存交易备注信息");
        //拿到登陆的用户
        User user = (User) session.getAttribute(Constans.SESSION_LOGIN_INF);
        ReturnObjectMessage returnObjectMessage = new ReturnObjectMessage();

        //赋值额外的信息
        remark.setId(UUIDUtil.getUUID());
        remark.setCreateTime(DateFormatUtil.formatDateTime(new Date()));
        remark.setCreateBy(user.getId());
        remark.setEditFlag("0");

        try {
            int count = transactionRemarkService.saveTranRemark(remark);
            if (count >= 0) {
                returnObjectMessage.setCode(Constans.RETURN_OBJECT_SUCCESS);
                returnObjectMessage.setObject(remark);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            return returnObjectMessage;
        }
    }

    @RequestMapping("/workbench/transaction/deleteRemarkDetail")
    @ResponseBody
    public Object deleteClueRemark(String id) {
        log.info("删除交易备注信息");
        ReturnObjectMessage objectMessage = new ReturnObjectMessage();
        try {
            int ret = transactionRemarkMapper.deleteByPrimaryKey(id);
            if (ret >= 0) {
                objectMessage.setCode(Constans.RETURN_OBJECT_SUCCESS);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            return objectMessage;
        }
    }

    @RequestMapping("/workbench/transaction/editTranRemarkById")
    @ResponseBody
    public Object editCustomerRemarkById(TransactionRemark remark, HttpSession session) {
        log.info("编辑交易备注信息");
        User user = (User) session.getAttribute(Constans.SESSION_LOGIN_INF);
        remark.setEditTime(DateFormatUtil.formatDateTime(new Date()));
        remark.setEditFlag("1");
        remark.setEditBy(user.getId());

        ReturnObjectMessage objectMessage = new ReturnObjectMessage();
        try {
            int ret = transactionRemarkMapper.updateById(remark);
            if (ret >= 0) {
                objectMessage.setCode(Constans.RETURN_OBJECT_SUCCESS);
                objectMessage.setObject(remark);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            return objectMessage;
        }
    }

    @RequestMapping("/workbench/transaction/queryIsComplete")
    @ResponseBody
    public Object queryIsCompleteByTranId(String id){
        log.info("查询交易是否成交");
        ReturnObjectMessage objectMessage = new ReturnObjectMessage();
        objectMessage.setCode(Constans.RETURN_OBJECT_SUCCESS);
        String stage = transactionService.queryIsCompleteByTranId(id);
        if("e17585d9458f4e4192a44650a37hy92b".equals(stage)){
            objectMessage.setObject(true);
        }else {
            objectMessage.setObject(false);
        }
        return objectMessage;
    }
}
