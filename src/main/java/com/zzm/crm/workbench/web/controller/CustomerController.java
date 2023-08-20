package com.zzm.crm.workbench.web.controller;

import com.zzm.crm.settings.service.DicValueService;
import com.zzm.crm.settings.service.UserService;
import com.zzm.crm.workbench.pojo.Contacts;
import com.zzm.crm.workbench.pojo.Customer;
import com.zzm.crm.workbench.pojo.CustomerRemark;
import com.zzm.crm.workbench.pojo.Transaction;
import com.zzm.crm.commons.constants.Constans;
import com.zzm.crm.commons.pojo.ReturnObjectMessage;
import com.zzm.crm.commons.utils.DateFormatUtil;
import com.zzm.crm.commons.utils.UUIDUtil;
import com.zzm.crm.settings.pojo.User;
import com.zzm.crm.workbench.mapper.ContactsMapper;
import com.zzm.crm.workbench.mapper.ContactsRemarkMapper;
import com.zzm.crm.workbench.mapper.CustomerRemarkMapper;
import com.zzm.crm.workbench.mapper.TransactionMapper;
import com.zzm.crm.workbench.service.ContactsService;
import com.zzm.crm.workbench.service.CustomerRemarkService;
import com.zzm.crm.workbench.service.CustomerService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.logging.Logger;

/**
 * @author ZZX
 * @version 1.0.0
 * @date 2023:05:07 10:50:56
 */

@Controller
public class CustomerController {
    Logger log = Logger.getLogger("controller.web.workbench.com.zzm.crm.CustomerController");

    @Autowired
    private CustomerService customerService;

    @Autowired
    private ContactsRemarkMapper contactsRemarkMapper;

    @Autowired
    private CustomerRemarkService customerRemarkService;

    @Autowired
    private CustomerRemarkMapper customerRemarkMapper;

    @Autowired
    private UserService userService;

    @Autowired
    private TransactionMapper transactionMapper;

    @Autowired
    private ContactsMapper contactsMapper;

    @Autowired
    private ContactsService contactsService;

    @Autowired
    private DicValueService dicValueService;

    @RequestMapping("/workbench/customer/toIndex")
    public String toIndex(HttpServletRequest request) {
        log.info("去往客户首页");
        //这里需要选择把动态的数据返回回去
        List<User> userList = userService.queryAllUsers();
        request.setAttribute(Constans.SESSION_ACTIVITY_USERS, userList);
        return "workbench/customer/index";
    }

    @RequestMapping("/workbench/customer/queryByConditionForPage")
    @ResponseBody
    public Object queryByConditionForPage(String name, String owner, String phone, String website,
                                          Integer pageNo, Integer pageSize) {
        log.info("客户信息分页请求");
        //封装数据
        Map<Object, Object> map = new HashMap<>();
        map.put("name", name);
        map.put("owner", owner);
        map.put("phone", phone);
        map.put("website", website);

        //进一步处理数据后封装
        Integer beginIndex = (pageNo - 1) * pageSize;
        map.put("beginIndex", beginIndex);
        map.put("pageSize", pageSize);
        //打包数据，返回JSON字符串给前端
        Map<String, Object> customerInformation = new HashMap<>();
        try {
            //调用逻辑层的方法，返回客户信息集合和总条数
            List<Customer> customers = customerService.queryCustomerByConditionForPage(map);
            int totalRows = customerService.queryCountOfCustomerForPage(map);
            customerInformation.put("customers", customers);
            customerInformation.put("totalRows", totalRows);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return customerInformation;
    }

    @RequestMapping("/workbench/customer/saveCustomer")
    @ResponseBody
    public Object saveCustomer(Customer customer, HttpSession session) {
        log.info("保存客户信息");
        //二次封装数据
        customer.setId(UUIDUtil.getUUID());
        customer.setCreateTime(DateFormatUtil.formatDateTime(new Date()));
        //从会话域里面获取user数据
        User user = (User) session.getAttribute(Constans.SESSION_LOGIN_INF);
        customer.setCreateBy(user.getId());
        ReturnObjectMessage returnObjectMessage = new ReturnObjectMessage();
        try {
            //调用逻辑层的方法
            returnObjectMessage.setCode(Constans.RETURN_OBJECT_SUCCESS);
            customerService.saveCreateCustomer(customer);
        } catch (Exception e) {
            returnObjectMessage.setCode(Constans.RETURN_OBJECT_FAILURE);
            returnObjectMessage.setMessage("添加新客户失败");
        }
        return returnObjectMessage;
    }

    @RequestMapping("/workbench/customer/deleteCustomerByIds")
    @ResponseBody
    public Object deleteCustomerByIds(String[] id) {
        log.info("客户信息的删除");
        ReturnObjectMessage returnObjectMessage = new ReturnObjectMessage();
        returnObjectMessage.setCode(Constans.RETURN_OBJECT_FAILURE);
        returnObjectMessage.setMessage("删除功能调用失败...");
        try {
            int ret = customerService.deleteCustomerByIds(id);
            if (ret > 0) {
                returnObjectMessage.setCode(Constans.RETURN_OBJECT_SUCCESS);
                returnObjectMessage.setMessage("删除成功...");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return returnObjectMessage;
    }

    @RequestMapping("/workbench/customer/queryCustomerById")
    @ResponseBody
    public Object queryCustomerById(String id) {
        log.info("根据ID查询客户信息");
        Customer customer = customerService.queryCustomerById(id);
        return customer;
    }

    @RequestMapping("/workbench/customer/editCustomer")
    @ResponseBody
    public Object editCustomer(Customer customer, HttpSession session) {
        log.info("修改客户信息");
        //二次封装数据
        String editTime = DateFormatUtil.formatDateTime(new Date());
        User user = (User) session.getAttribute(Constans.SESSION_LOGIN_INF);
        String id = user.getId();
        customer.setEditTime(editTime);
        customer.setEditBy(id);

        //调用service层的方法，并且进行判断
        ReturnObjectMessage returnObjectMessage = new ReturnObjectMessage();
        returnObjectMessage.setCode(Constans.RETURN_OBJECT_FAILURE);
        returnObjectMessage.setMessage("修改功能调用失败...");
        try {
            int ret = customerService.editCustomer(customer);
            if (ret > 0) {
                returnObjectMessage.setCode(Constans.RETURN_OBJECT_SUCCESS);
                returnObjectMessage.setMessage("修改功能调用成功...");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return returnObjectMessage;
    }

    @RequestMapping("/workbench/customer/toDetail")
    public String toDetail(HttpServletRequest request, String id) {
        log.info("进入客户的详情页面");
        // 客户信息
        Customer customer = customerService.queryCustomerForDetailById(id);
        // 客户备注信息
        List<CustomerRemark> customerRemarks = customerRemarkService.queryDetailByCustomerId(id);

        request.setAttribute("customer", customer);
        request.setAttribute("customerRemarks", customerRemarks);
        // 客户的信息存入域里面
        return "workbench/customer/detail";
    }

    @RequestMapping("/workbench/customer/createRemarkDetail")
    @ResponseBody
    public Object saveCustomerRemark(HttpSession session, CustomerRemark remark) {
        log.info("保存客户备注信息");
        User user = (User) session.getAttribute(Constans.SESSION_LOGIN_INF);
        ReturnObjectMessage returnObjectMessage = new ReturnObjectMessage();

        remark.setId(UUIDUtil.getUUID());
        remark.setCreateTime(DateFormatUtil.formatDateTime(new Date()));
        remark.setCreateBy(user.getId());
        remark.setEditFlag("0");

        try {
            int count = customerRemarkMapper.saveCustomerRemark(remark);
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

    @RequestMapping("/workbench/customer/deleteCustomerRemarkById")
    @ResponseBody
    public Object deleteCustomerRemark(String id) {
        log.info("删除客户备注信息");
        ReturnObjectMessage objectMessage = new ReturnObjectMessage();
        try {
            int ret = customerRemarkMapper.deleteByPrimaryKey(id);
            if (ret >= 0) {
                objectMessage.setCode(Constans.RETURN_OBJECT_SUCCESS);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            return objectMessage;
        }
    }

    @RequestMapping("/workbench/customer/getTranInfoByCustomerId")
    @ResponseBody
    public Object queryTranInfoByCustomerId(String customerId) {
        log.info("根据客户ID查询有关的交易信息");
        ReturnObjectMessage objectMessage = new ReturnObjectMessage();
        // 客户的交易信息
        List<Transaction> transactions = transactionMapper.findAllTranByCustomerId(customerId);
        objectMessage.setCode(Constans.RETURN_OBJECT_SUCCESS);
        objectMessage.setObject(transactions);
        return objectMessage;
    }

    @RequestMapping("/workbench/customer/editCustomerRemarkById")
    @ResponseBody
    public Object editActivityRemarkById(CustomerRemark remark, HttpSession session) {
        log.info("编辑客户备注的请求");
        User user = (User) session.getAttribute(Constans.SESSION_LOGIN_INF);
        remark.setEditTime(DateFormatUtil.formatDateTime(new Date()));
        remark.setEditFlag("1");
        remark.setEditBy(user.getId());

        ReturnObjectMessage objectMessage = new ReturnObjectMessage();
        try {
            int ret = customerRemarkMapper.updateById(remark);
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

    @RequestMapping("/workbench/customer/getContactsInfoByCustomerId")
    @ResponseBody
    public Object queryContactsInfoByCustomerId(String customerId) {
        log.info("根据客户ID查询联系人信息");
        ReturnObjectMessage objectMessage = new ReturnObjectMessage();
        // 联系人信息
        List<Contacts> contacts = contactsMapper.getContactsInfoByCustomerId(customerId);
        objectMessage.setCode(Constans.RETURN_OBJECT_SUCCESS);
        objectMessage.setObject(contacts);
        return objectMessage;
    }

    @RequestMapping("/workbench/customer/createTransactionData")
    @ResponseBody
    public Object createTrandataPare(HttpServletRequest request, String customerId) {
        log.info("去往保存交易信息的界面");
        return "workbench/transaction/save";
    }
}
