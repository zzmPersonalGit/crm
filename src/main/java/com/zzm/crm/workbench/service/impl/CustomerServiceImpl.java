package com.zzm.crm.workbench.service.impl;

import com.zzm.crm.workbench.pojo.Customer;
import com.zzm.crm.workbench.service.ContactsService;
import com.zzm.crm.workbench.mapper.ContactsMapper;
import com.zzm.crm.workbench.mapper.CustomerMapper;
import com.zzm.crm.workbench.mapper.CustomerRemarkMapper;
import com.zzm.crm.workbench.service.CustomerService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Map;

@Service
@Transactional
public class CustomerServiceImpl implements CustomerService {
    @Autowired
    private CustomerMapper customerMapper;
    @Autowired
    private ContactsService contactsService;
    @Autowired
    private CustomerRemarkMapper customerRemarkMapper;
    @Autowired
    private ContactsMapper contactsMapper;

    @Override
    public List<Customer> queryCustomerByConditionForPage(Map<Object, Object> map) {
        return customerMapper.selectCustomerByConditionForPage(map);
    }

    @Override
    public List<Customer> queryAll() {
        return customerMapper.selectAll();
    }

    @Override
    public Customer queryCustomerForDetailById(String id) {
        return customerMapper.selectDetailInfoById(id);
    }

    @Override
    public int editCustomer(Customer customer) {
        return customerMapper.updateByPrimaryKey(customer);
    }

    @Override
    public Customer queryCustomerById(String id) {
        return customerMapper.selectCustomerById(id);
    }

    @Override
    public int deleteCustomerByIds(String[] ids) {

        for (String id : ids) {
            // TODO 1:根据客户的ID删除备注信息
            customerRemarkMapper.deleteByCustomerId(id);

            // TODO 2:根据客户的ID删除下属联系人的信息【其中删除全部的联系人就把交易信息全部删除了】
            // TODO 2.1:根据客户的ID查询有哪些联系人ID列表信息
            List<String> contactsList = contactsMapper.getContactsIdListByCustomerId(id);
            if (contactsList.size() > 0) {
                String[] strings = contactsList.toArray(new String[contactsList.size()]);
                // TODO 2.2:删除联系人信息
                contactsService.deleteContactsByIds(strings);
            }
        }

        // TODO 3:删除客户自身的信息
        return customerMapper.deleteCustomerByIds(ids);
    }

    @Override
    public void saveCreateCustomer(Customer customer) {
        customerMapper.insertCustomerForOrigin(customer);
    }

    @Override
    public int queryCountOfCustomerForPage(Map<Object, Object> map) {
        return customerMapper.selectCountOfCustomerForPage(map);
    }

    @Override
    public List<String> queryModifyNameByFuzzyName(String fuzzyName) {
        return customerMapper.selectModifyNameByFuzzyName(fuzzyName);
    }
}
