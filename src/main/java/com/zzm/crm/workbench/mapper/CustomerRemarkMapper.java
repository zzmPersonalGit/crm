package com.zzm.crm.workbench.mapper;

import com.zzm.crm.workbench.pojo.CustomerRemark;

import java.util.List;

public interface CustomerRemarkMapper {
    /**
     * 删除备注
     * @param id
     * @return
     */
    int deleteByPrimaryKey(String id);

    /**
     * 插入数据到客户的备注表
     * @param list
     * @return
     */
    int insertOriginData(List<CustomerRemark> list);


    /**
     * 根据客户ID查询客户的备注信息
     * @param id
     * @return
     */
    List<CustomerRemark> selectDetailByCustomerId(String id);

    /**
     * 根据客户ID删除客户的备注信息
     * @param id
     */
    void deleteByCustomerId(String id);

    /**
     * 保存备注信息
     * @param remark
     * @return
     */
    int saveCustomerRemark(CustomerRemark remark);

    /**
     * 根据ID更新备注信息
     * @param remark
     * @return
     */
    int updateById(CustomerRemark remark);
}
