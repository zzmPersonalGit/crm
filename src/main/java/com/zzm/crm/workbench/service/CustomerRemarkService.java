package com.zzm.crm.workbench.service;

import com.zzm.crm.workbench.pojo.CustomerRemark;

import java.util.List;

/**
 * @author ZZX
 * @version 1.0.0
 * @date 2023:05:09 08:31:38
 */

public interface CustomerRemarkService {
    /**
     * 根据客户ID查询客户的备注信息
     * @param id
     * @return
     */
    List<CustomerRemark> queryDetailByCustomerId(String id);
}
