package com.zzm.crm.workbench.service;

import com.zzm.crm.workbench.pojo.Customer;

import java.util.List;
import java.util.Map;

public interface CustomerService {
    /**
     * 模糊查询客户信息
     * @param fuzzyName
     * @return
     */
    List<String> queryModifyNameByFuzzyName(String fuzzyName);

    /**
     * 根据参数查询客户列表信息
     * @param map
     * @return
     */
    List<Customer> queryCustomerByConditionForPage(Map<Object, Object> map);

    /**
     * 根据参数查询符合条件的客户列表总记录数
     * @param map
     * @return
     */
    int queryCountOfCustomerForPage(Map<Object, Object> map);

    /**
     * 保存客户信息
     * @param customer
     */
    void saveCreateCustomer(Customer customer);

    /**
     * 删除真实客户
     * @param ids
     * @return
     */
    int deleteCustomerByIds(String[] ids);

    /**
     * 根据ID查询客户信息
     * @param id
     * @return
     */
    Customer queryCustomerById(String id);

    /**
     * 修改客户信息
     * @param customer
     * @return
     */
    int editCustomer(Customer customer);

    /**
     * 根据客户ID查询客户的信息
     * @param id
     * @return
     */
    Customer queryCustomerForDetailById(String id);

    /**
     * 查询所有的客户信息
     * @return
     */
    List<Customer> queryAll();
}
