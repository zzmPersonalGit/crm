package com.zzm.crm.workbench.mapper;

import com.zzm.crm.workbench.pojo.Customer;
import org.apache.ibatis.annotations.Param;

import java.util.List;
import java.util.Map;

public interface CustomerMapper {

    /**
     * 插入新客户
     * @param row
     * @return
     */
    int insertCustomerForOrigin(Customer row);

    /**
     * 查询客户是否已经存在
     * @param name
     * @return
     */
    Customer selectOriginByAccurateName(String name);

    /**
     * 模糊查询客户信息
     */
    List<String> selectModifyNameByFuzzyName(String fuzzyName);

    /**
     * 更新客户信息
     * @param row
     * @return
     */
    int updateByPrimaryKey(Customer row);

    /**
     * 根据参数查询客户列表
     * @param map
     * @return
     */
    List<Customer> selectCustomerByConditionForPage(Map<Object, Object> map);

    /**
     * 根据参数查询符合条件的客户列表总记录数
     * @param map
     * @return
     */
    int selectCountOfCustomerForPage(Map<Object, Object> map);

    /**
     * 根据ID列表删除真实客户信息
     * @param ids
     * @return
     */
    int deleteCustomerByIds(String[] ids);

    /**
     * 根据ID查询客户信息
     * @param id
     * @return
     */
    Customer selectCustomerById(String id);

    /**
     * 根据客户ID查询客户详情
     * @param id
     * @return
     */
    Customer selectDetailInfoById(String id);

    /**
     * 查询所有客户
     * @return
     */
    List<Customer> selectAll();

    /**
     * 根据客户的ID查询信息
     * @param customerName
     * @return
     */
    Customer selectOriginById(@Param("id") String customerName);

}
