package com.zzm.crm.workbench.web.controller;

import com.zzm.crm.settings.service.UserService;
import com.zzm.crm.workbench.pojo.Activity;
import com.zzm.crm.workbench.pojo.ActivityRemark;
import com.zzm.crm.commons.constants.Constans;
import com.zzm.crm.commons.pojo.ReturnObjectMessage;
import com.zzm.crm.commons.utils.CellValueUtil;
import com.zzm.crm.commons.utils.DateFormatUtil;
import com.zzm.crm.commons.utils.UUIDUtil;
import com.zzm.crm.settings.pojo.User;
import com.zzm.crm.workbench.mapper.ContactsActivityRelationMapper;
import com.zzm.crm.workbench.service.ActivityRemarkService;
import com.zzm.crm.workbench.service.ActivityService;
import org.apache.poi.hssf.usermodel.HSSFCell;
import org.apache.poi.hssf.usermodel.HSSFRow;
import org.apache.poi.hssf.usermodel.HSSFSheet;
import org.apache.poi.hssf.usermodel.HSSFWorkbook;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.*;
import java.util.logging.Logger;

@Controller
public class ActivityController {

    private Logger log = Logger.getLogger("controller.web.workbench.com.zzm.crm.ActivityController");

    @Autowired
    private UserService userService;

    @Autowired
    private ActivityService activityService;

    @Autowired
    private ActivityRemarkService activityRemarkService;

    @Autowired
    private ContactsActivityRelationMapper contactsActivityRelationMapper;

    @RequestMapping("/workbench/activity/toIndex")
    public String toIndex(HttpServletRequest request) {
        log.info("进入市场活动首页");

        // 返回所有的用户信息，便于后续添加所有者
        List<User> userList = userService.queryAllUsers();

        // 把所有用户的的信息存入request域
        request.setAttribute(Constans.SESSION_ACTIVITY_USERS, userList);
        return "workbench/activity/index";
    }

    @RequestMapping("/workbench/activity/saveActivity")
    @ResponseBody
    public Object saveActivity(Activity activity, HttpSession session) {
        log.info("添加市场活动");
        //二次封装数据
        activity.setId(UUIDUtil.getUUID());
        activity.setCreateTime(DateFormatUtil.formatDateTime(new Date()));
        //从会话域里面获取user数据
        User user = (User) session.getAttribute(Constans.SESSION_LOGIN_INF);
        activity.setCreateBy(user.getId());
        ReturnObjectMessage returnObjectMessage = new ReturnObjectMessage();
        try {
            //调用逻辑层的方法
            returnObjectMessage.setCode(Constans.RETURN_OBJECT_SUCCESS);
            activityService.saveCreateActivity(activity);
        } catch (Exception e) {
            returnObjectMessage.setCode(Constans.RETURN_OBJECT_FAILURE);
        }
        return returnObjectMessage;
    }

    @RequestMapping("/workbench/activity/queryByConditionForPage")
    @ResponseBody
    public Object queryByConditionForPage(String name, String owner, String start_date, String end_date,
                                          Integer pageNo, Integer pageSize) {
        log.info("市场活动分页请求");
        // 封装数据为map
        Map<Object, Object> map = new HashMap<>();
        map.put("name", name);
        map.put("owner", owner);
        map.put("start_date", start_date);
        map.put("end_date", end_date);

        // 进一步处理数据后封装
        Integer beginIndex = (pageNo - 1) * pageSize;
        map.put("beginIndex", beginIndex);
        map.put("pageSize", pageSize);

        // 打包数据，返回JSON字符串给前端
        Map<String, Object> activityInformation = new HashMap<>();
        try {
            // 调用逻辑层的方法，返回市场活动集合和总条数
            List<Activity> activities = activityService.queryActivityByConditionForPage(map);
            int totalRows = activityService.queryCountOfActivityForPage(map);

            // 把市场活动的信息和总记录数存入返回的对象里
            activityInformation.put("activities", activities);
            activityInformation.put("totalRows", totalRows);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return activityInformation;
    }

    @RequestMapping("/workbench/activity/deleteActivityByIds")
    @ResponseBody
    public Object deleteActivityByIds(String[] id) {
        log.info("市场活动的删除");
        ReturnObjectMessage returnObjectMessage = new ReturnObjectMessage();
        returnObjectMessage.setCode(Constans.RETURN_OBJECT_FAILURE);
        returnObjectMessage.setMessage("删除功能调用失败...");
        try {
            int ret = activityService.deleteActivityByIds(id);
            if (ret > 0) {
                returnObjectMessage.setCode(Constans.RETURN_OBJECT_SUCCESS);
                returnObjectMessage.setMessage("删除成功...");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return returnObjectMessage;
    }

    @RequestMapping("/workbench/activity/queryActivityById")
    @ResponseBody
    public Object queryActivityById(String id) {
        log.info("根据ID查询市场活动");
        Activity activity = activityService.queryActivityById(id);
        return activity;
    }

    @RequestMapping("/workbench/activity/editActivity")
    @ResponseBody
    public Object editActivity(Activity activity, HttpSession session) {
        log.info("修改市场活动");
        //二次封装数据
        String editTime = DateFormatUtil.formatDateTime(new Date());
        User user = (User) session.getAttribute(Constans.SESSION_LOGIN_INF);
        String id = user.getId();
        activity.setEditTime(editTime);
        activity.setEditBy(id);

        //调用service层的方法，并且进行判断
        ReturnObjectMessage returnObjectMessage = new ReturnObjectMessage();
        returnObjectMessage.setCode(Constans.RETURN_OBJECT_FAILURE);
        returnObjectMessage.setMessage("修改功能调用失败...");
        try {
            int ret = activityService.editActivity(activity);
            if (ret > 0) {
                returnObjectMessage.setCode(Constans.RETURN_OBJECT_SUCCESS);
                returnObjectMessage.setMessage("修改功能调用成功...");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return returnObjectMessage;
    }

    @RequestMapping("/workbench/activity/fileDownload")
    public void fileDownloadExport(HttpServletResponse response, String[] id) throws IOException {
        log.info("导出市场活动的Excel数据");

        //拿到所有的市场活动
        List<Activity> activities = activityService.queryActivityForExport(id);

        //打包成为Excel
        HSSFWorkbook workbook = new HSSFWorkbook();
        HSSFSheet sheet = workbook.createSheet("市场活动明细列表");
        HSSFRow row = sheet.createRow(0);

        //创建表头
        HSSFCell cell = null;
        cell = row.createCell(0);
        cell.setCellValue("所有者");
        cell = row.createCell(1);
        cell.setCellValue("名称");
        cell = row.createCell(2);
        cell.setCellValue("开始时间");
        cell = row.createCell(3);
        cell.setCellValue("结束时间");
        cell = row.createCell(4);
        cell.setCellValue("花费");
        cell = row.createCell(5);
        cell.setCellValue("描述");
        cell = row.createCell(6);
        cell.setCellValue("创建时间");
        cell = row.createCell(7);
        cell.setCellValue("创建人");
        cell = row.createCell(8);
        cell.setCellValue("修改时间");
        cell = row.createCell(9);
        cell.setCellValue("修改人");

        //注入内容，拿到每个市场活动，写入Excel的数据里面
        for (int i = 0; i < activities.size(); i++) {
            row = sheet.createRow(i + 1);
            Activity activity = activities.get(i);
            //内容
            cell = row.createCell(0);
            cell.setCellValue(activity.getOwner());
            cell = row.createCell(1);
            cell.setCellValue(activity.getName());
            cell = row.createCell(2);
            cell.setCellValue(activity.getStartDate());
            cell = row.createCell(3);
            cell.setCellValue(activity.getEndDate());
            cell = row.createCell(4);
            cell.setCellValue(activity.getCost());
            cell = row.createCell(5);
            cell.setCellValue(activity.getDescription());
            cell = row.createCell(6);
            cell.setCellValue(activity.getCreateTime());
            cell = row.createCell(7);
            cell.setCellValue(activity.getCreateBy());
            cell = row.createCell(8);
            cell.setCellValue(activity.getEditTime());
            cell = row.createCell(9);
            cell.setCellValue(activity.getEditBy());
        }

        response.setContentType("application/octet-stream;charset=UTF-8");
        response.addHeader("Content-Disposition", "attachment;filename=activityList.xls");
        OutputStream os = response.getOutputStream();
        workbook.write(os);
        workbook.close();
    }

    @RequestMapping("/workbench/activity/importActivityModel")
    public void importActivityModel(HttpServletResponse response) throws IOException {
        log.info("模板文件的下载请求");
        response.setContentType("application/octet-stream;charset=UTF-8");
        response.addHeader("ConTent-Disposition", "attachment;filename=activityList.xls");
        OutputStream os = response.getOutputStream();

        HSSFWorkbook workbook = new HSSFWorkbook();
        HSSFSheet sheet = workbook.createSheet("市场活动模板");
        HSSFRow row = sheet.createRow(0);
        HSSFCell cell = null;
        cell = row.createCell(0);
        cell.setCellValue("市场活动名称");
        cell = row.createCell(1);
        cell.setCellValue("市场活动开始时间");
        cell = row.createCell(2);
        cell.setCellValue("市场活动结束时间");
        cell = row.createCell(3);
        cell.setCellValue("花费");
        cell = row.createCell(4);
        cell.setCellValue("描述");

        row = sheet.createRow(1);
        cell = row.createCell(0);
        cell.setCellValue("内江师范学院三食堂建设");
        cell = row.createCell(1);
        cell.setCellValue("2021-01-31");
        cell = row.createCell(2);
        cell.setCellValue("2022-01-31");
        cell = row.createCell(3);
        cell.setCellValue("500000");
        cell = row.createCell(4);
        cell.setCellValue("三食堂的成功建设将有效的解决学生吃饭的拥堵问题");

        workbook.write(os);
        workbook.close();
    }

    @RequestMapping("/workbench/activity/importActivityRowsByFile")
    @ResponseBody
    public Object importActivityRowsByFile(MultipartFile multipartFile, HttpSession session) {
        log.info("导入Excel文件,解析市场活动");
        ReturnObjectMessage returnObjectMessage = new ReturnObjectMessage();
        returnObjectMessage.setCode(Constans.RETURN_OBJECT_FAILURE);
        returnObjectMessage.setMessage("发生导入错误...");

        //拿到当前登录的用户，作为市场活动的所有者
        User user = (User) session.getAttribute(Constans.SESSION_LOGIN_INF);

        try {
            //拿到上传的文件流
            InputStream is = multipartFile.getInputStream();
            //创建Excel数据对象
            HSSFWorkbook workbook = new HSSFWorkbook(is);
            HSSFSheet sheet = workbook.getSheetAt(0);
            HSSFRow row = null;
            HSSFCell cell = null;

            //解析出来的市场活动对象就存放进去
            List<Activity> list = new ArrayList<>();
            //解析Excel文件
            for (int i = 1; i <= sheet.getLastRowNum(); i++) {
                row = sheet.getRow(i);
                //创建市场活动对象,赋值一些其它的字段
                Activity activity = new Activity();
                activity.setId(UUIDUtil.getUUID());
                activity.setOwner(user.getId());
                activity.setCreateTime(DateFormatUtil.formatDateTime(new Date()));
                activity.setCreateBy(user.getId());

                for (int y = 0; y < row.getLastCellNum(); y++) {
                    cell = row.getCell(y);
                    String cellValue = CellValueUtil.getCellValue(cell);
                    System.out.println(cellValue);
                    if (y == 0) {
                        activity.setName(cellValue);
                    } else if (y == 1) {
                        if (cellValue.contains("-")) {
                            activity.setStartDate(cellValue);
                        } else {
                            returnObjectMessage.setMessage("时间格式错误,正确格式为2021-12-21");
                            return returnObjectMessage;
                        }
                    } else if (y == 2) {
                        if (cellValue.contains("-")) {
                            activity.setEndDate(cellValue);
                        } else {
                            returnObjectMessage.setMessage("时间格式错误,正确格式为2021-12-21");
                            return returnObjectMessage;
                        }
                    } else if (y == 3) {
                        activity.setCost(cellValue);
                    } else if (y == 4) {
                        activity.setDescription(cellValue);
                    }
                }
                list.add(activity);
            }

            int count = activityService.saveActivityByFile(list);
            returnObjectMessage.setCode(Constans.RETURN_OBJECT_SUCCESS);
            returnObjectMessage.setMessage("导入市场活动的数量：" + count);
        } catch (IOException e) {
            throw new RuntimeException(e);
        } finally {
            return returnObjectMessage;
        }
    }

    @RequestMapping("/workbench/activity/toDetail")
    public String toDetail(HttpServletRequest request, String[] id) {
        log.info("进入市场活动的细节页面");
        //获取市场活动的内容
        List<Activity> activities = activityService.queryActivityForExport(id);
        Activity activity = activities.get(0);
        //获取对应市场活动的备注信息
        List<ActivityRemark> activityRemarks = activityRemarkService.queryDetailByActivityId(id[0]);
        //存到域中
        request.setAttribute("activity", activity);
        request.setAttribute("activityRemarks", activityRemarks);
        return "workbench/activity/detail";
    }

    @RequestMapping("/workbench/activity/createRemarkDetail")
    @ResponseBody
    public Object createRemarkDetail(HttpSession session, ActivityRemark remark) {
        log.info("添加市场活动的备注");
        //拿到登陆的用户
        User user = (User) session.getAttribute(Constans.SESSION_LOGIN_INF);
        ReturnObjectMessage returnObjectMessage = new ReturnObjectMessage();

        //赋值额外的信息
        remark.setId(UUIDUtil.getUUID());
        remark.setCreateTime(DateFormatUtil.formatDateTime(new Date()));
        remark.setCreateBy(user.getId());
        remark.setEditFlag("0");

        try {
            int count = activityRemarkService.saveActivityRemark(remark);
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

    @RequestMapping("/workbench/activity/deleteRemarkById")
    @ResponseBody
    public Object deleteRemarkById(String id) {
        log.info("删除市场活动备注的请求");
        ReturnObjectMessage objectMessage = new ReturnObjectMessage();
        try {
            int ret = activityRemarkService.deleteByPrimaryKey(id);
            if (ret >= 0) {
                objectMessage.setCode(Constans.RETURN_OBJECT_SUCCESS);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            return objectMessage;
        }
    }

    @RequestMapping("/workbench/activity/editActivityRemarkById")
    @ResponseBody
    public Object editActivityRemarkById(ActivityRemark remark, HttpSession session) {
        log.info("编辑市场活动备注的请求");
        User user = (User) session.getAttribute(Constans.SESSION_LOGIN_INF);
        remark.setEditTime(DateFormatUtil.formatDateTime(new Date()));
        remark.setEditFlag("1");
        remark.setEditBy(user.getId());

        ReturnObjectMessage objectMessage = new ReturnObjectMessage();
        try {
            int ret = activityRemarkService.editByPrimaryKey(remark);
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

    @RequestMapping("/workbench/activity/getActivityInfoByContactsId")
    @ResponseBody
    public Object queryActivityInfoByContactsId(String contactsId){
        log.info("根据联系人的ID查询市场活动关联信息");
        ReturnObjectMessage objectMessage = new ReturnObjectMessage();
        // 客户的交易信息
        List<Activity> transactions = activityService.findAllActivityInfoByContactsId(contactsId);
        objectMessage.setCode(Constans.RETURN_OBJECT_SUCCESS);
        objectMessage.setObject(transactions);
        return objectMessage;
    }

    @RequestMapping("/workbench/activity/deleteRelation")
    @ResponseBody
    public Object deleteActivityRelationInfoByContactsId(String activityId,String contactsId){
        log.info("解除市场活动和联系人的关联信息");
        ReturnObjectMessage objectMessage = new ReturnObjectMessage();
        contactsActivityRelationMapper.deleteRelation(activityId,contactsId);
        // 客户的交易信息

        objectMessage.setCode(Constans.RETURN_OBJECT_SUCCESS);
        return objectMessage;
    }
}
