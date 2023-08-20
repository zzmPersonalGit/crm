package com.zzm.crm.workbench.web.controller;

import com.zzm.crm.settings.service.DicValueService;
import com.zzm.crm.settings.service.UserService;
import com.zzm.crm.workbench.mapper.ContactsActivityRelationMapper;
import com.zzm.crm.workbench.mapper.ContactsRemarkMapper;
import com.zzm.crm.workbench.mapper.TransactionMapper;
import com.zzm.crm.workbench.pojo.*;
import com.zzm.crm.commons.constants.Constans;
import com.zzm.crm.commons.pojo.ReturnObjectMessage;
import com.zzm.crm.commons.utils.DateFormatUtil;
import com.zzm.crm.commons.utils.UUIDUtil;
import com.zzm.crm.settings.pojo.DicValue;
import com.zzm.crm.settings.pojo.User;
import com.zzm.crm.workbench.service.ContactsService;
import com.zzm.crm.workbench.service.CustomerService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;
import java.util.*;
import java.util.logging.Logger;

/**
 * @author ZZX
 * @version 1.0.0
 * @date 2023:05:09 08:58:59
 */

@Controller
public class ContactsController {
    Logger log = Logger.getLogger("controller.web.workbench.com.zzm.crm.ContactsController");
    @Autowired
    private ContactsService contactsService;
    @Autowired
    private ContactsRemarkMapper contactsRemarkMapper;
    @Autowired
    private UserService userService;
    @Autowired
    private DicValueService dicValueService;
    @Autowired
    private CustomerService customerService;
    @Autowired
    private TransactionMapper transactionMapper;
    @Autowired
    private ContactsActivityRelationMapper contactsActivityRelationMapper;

    @RequestMapping("/workbench/contacts/toIndex")
    public String toIndex(HttpServletRequest request) {
        log.info("进入联系人页面");
        // 所有者，也就是所有的管理员用户
        List<User> users = userService.queryAllUsers();
        // 查询所有的称呼
        List<DicValue> appellation = dicValueService.queryDicValueGroupByDicType("appellation");
        // 查询所有的线索状态
        List<DicValue> clueState = dicValueService.queryDicValueGroupByDicType("clueState");
        // 查询所有的线索来源
        List<DicValue> source = dicValueService.queryDicValueGroupByDicType("source");
        // 查询所有的客户名称
        List<Customer> customers = customerService.queryAll();

        // 把这些信息存入request域,方便JSP页面进行下拉框的选择
        request.setAttribute("users", users);
        request.setAttribute("appellation", appellation);
        request.setAttribute("source", source);
        request.setAttribute("customers", customers);
        return "workbench/contacts/index";
    }

    @ResponseBody
    @RequestMapping("workbench/contacts/queryByConditionForPage")
    public Object queryByConditionForPage(String fullname, String owner, String source,
                                          String customerId, Integer pageNo, Integer pageSize) {
        log.info("查询联系人的分页请求");

        //封装数据
        Map<Object, Object> map = new HashMap<>();
        map.put("fullname", fullname);
        map.put("owner", owner);
        map.put("source", source);
        map.put("customerId", customerId);
        Integer beginIndex = (pageNo - 1) * pageSize;
        map.put("beginIndex", beginIndex);
        map.put("pageSize", pageSize);

        //打包数据，返回JSON字符串给前端
        Map<String, Object> contactsInformation = new HashMap<>();

        try {
            //调用逻辑层的方法，返回市场活动集合和总条数
            List<Contacts> clues = contactsService.queryClueByConditionForPage(map);
            int totalRows = contactsService.queryCountOfClueForPage(map);
            contactsInformation.put("contacts", clues);
            contactsInformation.put("totalRows", totalRows);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return contactsInformation;
    }

    @RequestMapping("/workbench/contacts/saveContacts")
    @ResponseBody
    public Object saveContacts(Contacts contacts, HttpSession session) {
        log.info("保存联系人信息");
        User user = (User) session.getAttribute(Constans.SESSION_LOGIN_INF);
        ReturnObjectMessage objectMessage = new ReturnObjectMessage();
        //二次封装数据
        contacts.setId(UUIDUtil.getUUID());
        contacts.setCreateBy(user.getId());
        contacts.setCreateTime(DateFormatUtil.formatDateTime(new Date()));
        //调用service层，插入数据
        try {
            int ret = contactsService.saveContacts(contacts);
            if (ret >= 0) {
                objectMessage.setCode(Constans.RETURN_OBJECT_SUCCESS);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            return objectMessage;
        }
    }

    @RequestMapping("/workbench/contacts/deleteContactsByIds")
    @ResponseBody
    public Object deleteContactsByIds(String[] id) {
        log.info("联系人的的删除请求");
        ReturnObjectMessage returnObjectMessage = new ReturnObjectMessage();
        returnObjectMessage.setCode(Constans.RETURN_OBJECT_FAILURE);
        returnObjectMessage.setMessage("删除功能调用失败...");
        try {
            // 根据联系人的ID列表删除联系人
            int ret = contactsService.deleteContactsByIds(id);
            if (ret > 0) {
                returnObjectMessage.setCode(Constans.RETURN_OBJECT_SUCCESS);
                returnObjectMessage.setMessage("删除成功...");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return returnObjectMessage;
    }

    @RequestMapping("/workbench/contacts/queryContactsById")
    @ResponseBody
    public Object queryContactsById(String id) {
        log.info("根据ID查询联系人信息");
        Contacts contacts = contactsService.queryContactsById(id);
        return contacts;
    }

    @RequestMapping("/workbench/contacts/editContacts")
    @ResponseBody
    public Object editContacts(Contacts contacts, HttpSession session) {
        log.info("修改联系人信息");

        //二次封装数据
        String editTime = DateFormatUtil.formatDateTime(new Date());
        User user = (User) session.getAttribute(Constans.SESSION_LOGIN_INF);
        String id = user.getId();
        contacts.setEditTime(editTime);
        contacts.setEditBy(id);

        //调用service层的方法，并且进行判断
        ReturnObjectMessage returnObjectMessage = new ReturnObjectMessage();
        returnObjectMessage.setCode(Constans.RETURN_OBJECT_FAILURE);
        returnObjectMessage.setMessage("修改功能调用失败...");
        try {
            int ret = contactsService.editContacts(contacts);
            if (ret > 0) {
                returnObjectMessage.setCode(Constans.RETURN_OBJECT_SUCCESS);
                returnObjectMessage.setMessage("修改功能调用成功...");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return returnObjectMessage;
    }

    @RequestMapping("/workbench/contacts/toDetail")
    public String toDetail(HttpServletRequest request, String id) {
        log.info("进入联系人的详情页面");
        // 联系人信息
        Contacts contacts = contactsService.queryContactsForDetailById(id);
        // 联系人备注信息
        List<ContactsRemark> contactsRemarks = contactsRemarkMapper.queryDetailByContactsId(id);

        // 客户备注信息
        request.setAttribute("contacts", contacts);
        request.setAttribute("contactsRemarks", contactsRemarks);
        return "workbench/contacts/detail";
    }

    @RequestMapping("/workbench/contacts/createRemarkDetail")
    @ResponseBody
    public Object saveClueRemark(HttpSession session, ContactsRemark remark) {
        log.info("保存联系人的备注信息");
        User user = (User) session.getAttribute(Constans.SESSION_LOGIN_INF);
        ReturnObjectMessage returnObjectMessage = new ReturnObjectMessage();

        remark.setId(UUIDUtil.getUUID());
        remark.setCreateTime(DateFormatUtil.formatDateTime(new Date()));
        remark.setCreateBy(user.getId());
        remark.setEditFlag("0");

        try {
            int count = contactsRemarkMapper.saveContactsRemark(remark);
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

    @RequestMapping("/workbench/contacts/deleteContactsRemarkById")
    @ResponseBody
    public Object deleteClueRemark(String id) {
        log.info("删除联系人备注");
        ReturnObjectMessage objectMessage = new ReturnObjectMessage();
        try {
            int ret = contactsRemarkMapper.deleteByPrimaryKey(id);
            if (ret >= 0) {
                objectMessage.setCode(Constans.RETURN_OBJECT_SUCCESS);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            return objectMessage;
        }
    }

    @RequestMapping("/workbench/contacts/editContactsemarkById")
    @ResponseBody
    public Object editCustomerRemarkById(ContactsRemark remark, HttpSession session) {
        log.info("编辑联系人备注的请求");
        User user = (User) session.getAttribute(Constans.SESSION_LOGIN_INF);
        remark.setEditTime(DateFormatUtil.formatDateTime(new Date()));
        remark.setEditFlag("1");
        remark.setEditBy(user.getId());

        ReturnObjectMessage objectMessage = new ReturnObjectMessage();
        try {
            int ret = contactsRemarkMapper.updateById(remark);
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

    @RequestMapping("/workbench/contacts/deleteContacts")
    @ResponseBody
    public Object deleteContacts(String contactsId) {
        log.info("根据ID删除联系人");
        ReturnObjectMessage objectMessage = new ReturnObjectMessage();
        int ret = -1;
        try {
            ret = contactsService.deleteById(contactsId);
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            if (ret >= 0) {
                objectMessage.setCode(Constans.RETURN_OBJECT_SUCCESS);
            }
            return objectMessage;
        }
    }

    @RequestMapping("/workbench/contacts/getTranInfoByContactsId")
    @ResponseBody
    public Object queryTranInfoByContactsId(String contactsId) {
        log.info("根据联系人ID查询交易信息");
        ReturnObjectMessage objectMessage = new ReturnObjectMessage();
        // 客户的交易信息
        List<Transaction> transactions = transactionMapper.findAllTranByonContactsId(contactsId);
        objectMessage.setCode(Constans.RETURN_OBJECT_SUCCESS);
        objectMessage.setObject(transactions);
        return objectMessage;
    }

    @RequestMapping("/workbench/contacts/queryByCustomerName")
    @ResponseBody
    public Object queryByCustomerId(String customerName) {
        log.info("新增交易时根据公司信息查询所属联系人的信息");
        ReturnObjectMessage objectMessage = new ReturnObjectMessage();
        // 客户的交易信息
        List<Contacts> contacts = contactsService.queryByCustomerId(customerName);
        objectMessage.setCode(Constans.RETURN_OBJECT_SUCCESS);
        objectMessage.setObject(contacts);
        return objectMessage;
    }

    @RequestMapping("/workbench/contacts/queryByTranscationId")
    @ResponseBody
    public Object queryByTranscationId(String id) {
        log.info("修改交易根据交易ID查询公司,进而查询公司下的联系人信息");
        ReturnObjectMessage objectMessage = new ReturnObjectMessage();
        // 客户的交易信息
        List<Contacts> contacts = contactsService.queryByTransctionToCustomer(id);
        objectMessage.setCode(Constans.RETURN_OBJECT_SUCCESS);
        objectMessage.setObject(contacts);
        return objectMessage;
    }

    @RequestMapping("/workbench/contacts/saveContactsActivityRelationByIds")
    @ResponseBody
    public Object saveContactsActivityRelationByIds(String[] activityId, String contactsId) {
        log.info("联系人关联市场活动");
        ReturnObjectMessage objectMessage = new ReturnObjectMessage();
        // 保存市场活动和联系人关系的容器
        List<ContactsActivityRelation> list = new ArrayList<>();
        for (String id : activityId) {
            // 创建联系人和市场活动关系的对象
            ContactsActivityRelation relation = new ContactsActivityRelation();
            // 随机生成ID
            relation.setId(UUIDUtil.getUUID());
            // 设置市场活动值
            relation.setActivityId(id);
            // 设置线索值
            relation.setContactsId(contactsId);
            list.add(relation);
        }
        try {
            int ret = contactsActivityRelationMapper.saveContactsActivityRelationByIds(list);
            if (ret >= 0) {
                objectMessage.setCode(Constans.RETURN_OBJECT_SUCCESS);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            return objectMessage;
        }
    }
}
