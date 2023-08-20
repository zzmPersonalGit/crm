package com.zzm.crm.workbench.web.controller;

import com.zzm.crm.settings.service.DicValueService;
import com.zzm.crm.settings.service.UserService;
import com.zzm.crm.workbench.pojo.Activity;
import com.zzm.crm.workbench.pojo.Clue;
import com.zzm.crm.workbench.pojo.ClueActivityRelation;
import com.zzm.crm.workbench.pojo.ClueRemark;
import com.zzm.crm.commons.constants.Constans;
import com.zzm.crm.commons.pojo.ReturnObjectMessage;
import com.zzm.crm.commons.utils.DateFormatUtil;
import com.zzm.crm.commons.utils.UUIDUtil;
import com.zzm.crm.settings.pojo.DicValue;
import com.zzm.crm.settings.pojo.User;
import com.zzm.crm.workbench.service.ActivityService;
import com.zzm.crm.workbench.service.ClueActivityRelationService;
import com.zzm.crm.workbench.service.ClueRemarkService;
import com.zzm.crm.workbench.service.ClueService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;
import java.util.*;
import java.util.logging.Logger;

@Controller
public class ClueController {
    private Logger log = Logger.getLogger("controller.web.workbench.com.zzm.crm.ClueController");
    @Autowired
    private DicValueService dicValueService;
    @Autowired
    private UserService userService;
    @Autowired
    private ClueService clueService;
    @Autowired
    private ClueRemarkService clueRemarkService;
    @Autowired
    private ActivityService activityService;
    @Autowired
    private ClueActivityRelationService clueActivityRelationService;

    @RequestMapping("/workbench/clue/toIndex")
    public String toClueIndex(HttpServletRequest request) {
        log.info("去往线索模块的首页");
        // 所有者，也就是所有的管理员用户
        List<User> users = userService.queryAllUsers();
        // 查询所有的称呼
        List<DicValue> appellation = dicValueService.queryDicValueGroupByDicType("appellation");
        // 查询所有的线索状态
        List<DicValue> clueState = dicValueService.queryDicValueGroupByDicType("clueState");
        // 查询所有的线索来源
        List<DicValue> source = dicValueService.queryDicValueGroupByDicType("source");

        // 把这些信息存入request域,方便JSP页面进行下拉框的选择
        request.setAttribute("users", users);
        request.setAttribute("appellation", appellation);
        request.setAttribute("clueState", clueState);
        request.setAttribute("source", source);
        return "workbench/clue/index";
    }

    @RequestMapping("/workbench/clue/saveClue")
    @ResponseBody
    public Object saveClue(Clue clue, HttpSession session) {
        log.info("保存线索信息");
        User user = (User) session.getAttribute(Constans.SESSION_LOGIN_INF);
        ReturnObjectMessage objectMessage = new ReturnObjectMessage();
        //二次封装数据
        clue.setId(UUIDUtil.getUUID());
        clue.setCreateBy(user.getId());
        clue.setCreateTime(DateFormatUtil.formatDateTime(new Date()));
        //调用service层，插入数据
        try {
            int ret = clueService.saveClue(clue);
            if (ret >= 0) {
                objectMessage.setCode(Constans.RETURN_OBJECT_SUCCESS);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            return objectMessage;
        }
    }

    @RequestMapping("/workbench/clue/toDetail")
    public String toClueDetail(String id, HttpServletRequest request) {
        log.info("展示线索的细节");
        // 线索本身
        Clue clue = clueService.queryClueByPrimaryKey(id);
        // 线索备注
        List<ClueRemark> clueRemarkList = clueRemarkService.queryClueRemarkByClueId(id);
        // 关联的市场活动
        List<Activity> activityList = activityService.queryActivityByClueId(id);
        request.setAttribute("clue", clue);
        request.setAttribute("clueRemarkList", clueRemarkList);
        request.setAttribute("activityList", activityList);
        return "workbench/clue/detail";
    }

    @RequestMapping("/workbench/clue/fuzzyQueryActivity")
    @ResponseBody
    public Object fuzzyQueryActivity(String value, String clueId) {
        log.info("查询线索未关联的市场活动信息");
        ReturnObjectMessage message = new ReturnObjectMessage();
        Map<String, String> map = new HashMap<>();
        map.put("value", value);
        map.put("clueId", clueId);

        List<Activity> activityList = activityService.queryActivityForFuzzy(map);
        if (activityList.size() >= 0) {
            message.setCode(Constans.RETURN_OBJECT_SUCCESS);
            message.setObject(activityList);
        }
        return message;
    }

    @RequestMapping("/workbench/clue/fuzzyQueryActivityByContactsId")
    @ResponseBody
    public Object fuzzyQueryActivityByContactsId(String value, String contactsId) {
        log.info("查询联系人查看未关联的市场活动信息");
        ReturnObjectMessage message = new ReturnObjectMessage();
        Map<String, String> map = new HashMap<>();
        map.put("value", value);
        map.put("contactsId",contactsId);

        List<Activity> activityList = activityService.queryActivityForFuzzyByContactsId(map);
        if (activityList.size() >= 0) {
            message.setCode(Constans.RETURN_OBJECT_SUCCESS);
            message.setObject(activityList);
        }
        return message;
    }

    @RequestMapping("/workbench/clue/saveClueActivityRelationByIds")
    @ResponseBody
    public Object saveClueActivityRelationByIds(String[] activityId, String clueId) {
        log.info("线索关联市场活动");
        ReturnObjectMessage objectMessage = new ReturnObjectMessage();
        // 保存市场活动和线索关系的容器
        List<ClueActivityRelation> list = new ArrayList<>();
        for (String id : activityId) {
            // 创建线索和市场活动关系的对象
            ClueActivityRelation relation = new ClueActivityRelation();
            // 随机生成ID
            relation.setId(UUIDUtil.getUUID());
            // 设置市场活动值
            relation.setActivityId(id);
            // 设置线索值
            relation.setClueId(clueId);
            list.add(relation);
        }
        try {
            int ret = clueActivityRelationService.saveClueActivityRelationByIds(list);
            if (ret >= 0) {
                objectMessage.setCode(Constans.RETURN_OBJECT_SUCCESS);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            return objectMessage;
        }
    }

    @RequestMapping("/workbench/clue/queryActivityByClueId")
    @ResponseBody
    public Object queryActivityByClueId(String id) {
        log.info("根据线索ID查询关联的市场活动");
        ReturnObjectMessage returnObjectMessage = new ReturnObjectMessage();
        List<Activity> activityList = activityService.queryActivityByClueId(id);
        if (activityList.size() >= 0) {
            returnObjectMessage.setCode(Constans.RETURN_OBJECT_SUCCESS);
            returnObjectMessage.setObject(activityList);
        }
        return returnObjectMessage;
    }

    @RequestMapping("/workbench/clue/deleteActivityRelationForClue")
    @ResponseBody
    public Object deleteActivityRelationForClue(ClueActivityRelation clueActivityRelation) {
        log.info("解除市场活动和线索的关联关系");
        ReturnObjectMessage objectMessage = new ReturnObjectMessage();
        int ret = -1;
        try {
            ret = clueActivityRelationService.deleteByClueAndActivityId(clueActivityRelation);
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            if (ret >= 0) {
                objectMessage.setCode(Constans.RETURN_OBJECT_SUCCESS);
            }
            return objectMessage;
        }
    }

    @RequestMapping("/workbench/clue/toConvert")
    public String toConvert(String id, HttpServletRequest request) {
        log.info("点击线索转换的按钮");
        // 查询线索的信息
        Clue clue = clueService.queryClueByPrimaryKey(id);
        // 查询阶段信息
        List<DicValue> stage = dicValueService.queryDicValueGroupByDicType("stage");
        // 查询来源信息
        List<DicValue> source = dicValueService.queryDicValueGroupByDicType("source");
        // 新老业务的类型
        List<DicValue> transcationType = dicValueService.queryDicValueGroupByDicType("transactionType");
        request.setAttribute("clue", clue);
        request.setAttribute("stage", stage);
        request.setAttribute("source", source);
        request.setAttribute("transcationType", transcationType);
        return "workbench/clue/convert";
    }

    @RequestMapping("/workbench/clue/fuzzyQueryForConvert")
    @ResponseBody
    public Object fuzzyQueryForConvert(String clueId, String fuzzyText) {
        log.info("根据线索ID查询跟自己关联了的市场活动信息");
        ReturnObjectMessage returnObjectMessage = new ReturnObjectMessage();
        Map<String, Object> map = new HashMap<>();
        map.put("value", fuzzyText);
        map.put("clueId", clueId);
        List<Activity> activityList = null;
        try {
            activityList = activityService.queryActivityFuzzyForConvert(map);
            returnObjectMessage.setCode(Constans.RETURN_OBJECT_SUCCESS);
            returnObjectMessage.setObject(activityList);
        } catch (Exception e) {
            returnObjectMessage.setCode(Constans.RETURN_OBJECT_FAILURE);
            returnObjectMessage.setObject(activityList);
        }

        return returnObjectMessage;
    }

    @RequestMapping("/workbench/clue/clueConvertByConvertBtn")
    @ResponseBody
    public Object clueConvertByConvertBtn(String clueId, String isCreateTran, String money, String name,
                                          String expectedDate, String nextContactTime,String stage, String source, String activityId,
                                          String transcationType, String possibility, HttpSession session) {
        log.info("线索转换的请求");
        ReturnObjectMessage returnObjectMessage = new ReturnObjectMessage();

        Map<String, Object> map = new HashMap<>();
        map.put("clueId", clueId);
        map.put("isCreateTran", isCreateTran);
        map.put("money", money);
        map.put("name", name);
        map.put("expectedDate", expectedDate);
        map.put("nextContactTime", nextContactTime);
        map.put("stage", stage);
        map.put("source", source);
        map.put("activityId", activityId);
        map.put("transcationType", transcationType);
        map.put("possibility", possibility);
        map.put(Constans.SESSION_LOGIN_INF, session.getAttribute(Constans.SESSION_LOGIN_INF));

        try {
            // 调用service方法
            clueService.clueConvertByConvertBtn(map);
            returnObjectMessage.setCode(Constans.RETURN_OBJECT_SUCCESS);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return returnObjectMessage;
    }

    @ResponseBody
    @RequestMapping("workbench/clue/queryByConditionForPage")
    public Object queryByConditionForPage(String name, String owner, String source,
                                          String state, Integer pageNo, Integer pageSize) {
        log.info("查询线索的分页请求");

        //封装数据
        Map<Object, Object> map = new HashMap<>();
        map.put("name", name);
        map.put("owner", owner);
        map.put("source", source);
        map.put("state", state);
        Integer beginIndex = (pageNo - 1) * pageSize;
        map.put("beginIndex", beginIndex);
        map.put("pageSize", pageSize);

        //打包数据，返回JSON字符串给前端
        Map<String, Object> clueInformation = new HashMap<>();

        try {
            //调用逻辑层的方法，返回市场活动集合和总条数
            List<Clue> clues = clueService.queryClueByConditionForPage(map);
            int totalRows = clueService.queryCountOfClueForPage(map);
            clueInformation.put("clues", clues);
            clueInformation.put("totalRows", totalRows);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return clueInformation;
    }

    @RequestMapping("/workbench/clue/deleteclueByIds")
    @ResponseBody
    public Object deleteClueByIds(String[] id) {

        log.info("线索的删除");
        ReturnObjectMessage returnObjectMessage = new ReturnObjectMessage();
        returnObjectMessage.setCode(Constans.RETURN_OBJECT_FAILURE);
        returnObjectMessage.setMessage("删除功能调用失败...");
        try {
            int ret = clueService.deleteClueByIds(id);
            if (ret > 0) {
                returnObjectMessage.setCode(Constans.RETURN_OBJECT_SUCCESS);
                returnObjectMessage.setMessage("删除成功...");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return returnObjectMessage;
    }

    @RequestMapping("/workbench/clue/queryClueById")
    @ResponseBody
    public Object queryClueById(String id) {
        log.info("查询线索的信息");
        Clue clue = clueService.queryClueById(id);
        return clue;
    }

    @RequestMapping("/workbench/clue/updateClue")
    @ResponseBody
    public Object updateClueById(@RequestBody Clue clue, HttpSession session) {
        log.info("更新线索的信息");
        ReturnObjectMessage returnObjectMessage = new ReturnObjectMessage();

        User user = (User) session.getAttribute(Constans.SESSION_LOGIN_INF);
        clue.setEditBy(user.getId());
        clue.setEditTime(DateFormatUtil.formatDateTime(new Date()));

        int result = clueService.updateClueById(clue);
        if (result > 0) {
            returnObjectMessage.setCode(Constans.RETURN_OBJECT_SUCCESS);
            returnObjectMessage.setMessage("更新成功...");
        } else {
            returnObjectMessage.setCode(Constans.RETURN_OBJECT_FAILURE);
            returnObjectMessage.setMessage("更新失败...");
        }
        return returnObjectMessage;
    }

    @RequestMapping("/workbench/clue/createRemarkDetail")
    @ResponseBody
    public Object saveClueRemark(HttpSession session, ClueRemark remark) {
        log.info("保存线索备注");
        User user = (User) session.getAttribute(Constans.SESSION_LOGIN_INF);
        ReturnObjectMessage returnObjectMessage = new ReturnObjectMessage();

        remark.setId(UUIDUtil.getUUID());
        remark.setCreateTime(DateFormatUtil.formatDateTime(new Date()));
        remark.setCreateBy(user.getId());
        remark.setEditFlag("0");

        try {
            int count = clueRemarkService.saveClueRemark(remark);
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

    @RequestMapping("/workbench/clue/deleteClueRemarkById")
    @ResponseBody
    public Object deleteClueRemark(String id) {
        log.info("删除线索备注");
        ReturnObjectMessage objectMessage = new ReturnObjectMessage();
        try {
            int ret = clueRemarkService.deleteByPrimaryKey(id);
            if (ret >= 0) {
                objectMessage.setCode(Constans.RETURN_OBJECT_SUCCESS);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            return objectMessage;
        }
    }

    @RequestMapping("/workbench/clue/editClueRemarkById")
    @ResponseBody
    public Object editClueRemarkById(ClueRemark remark, HttpSession session) {
        log.info("编辑线索备注");
        User user = (User) session.getAttribute(Constans.SESSION_LOGIN_INF);
        remark.setEditTime(DateFormatUtil.formatDateTime(new Date()));
        remark.setEditFlag("1");
        remark.setEditBy(user.getId());

        ReturnObjectMessage objectMessage = new ReturnObjectMessage();
        try {
            int ret = clueRemarkService.editByPrimaryKey(remark);
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

    @RequestMapping("/workbench/clue/isRelation")
    @ResponseBody
    public Object isRelationActivity(String clueId) {
        log.info("根据线索ID查看是否关联过市场活动");
        ReturnObjectMessage objectMessage = new ReturnObjectMessage();
        try {
            List<ClueActivityRelation> list = clueActivityRelationService.queryIsRelation(clueId);
            if (list.size() > 0) {
                objectMessage.setCode(Constans.RETURN_OBJECT_SUCCESS);
            } else {
                objectMessage.setCode(Constans.RETURN_OBJECT_FAILURE);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            return objectMessage;
        }
    }
}
