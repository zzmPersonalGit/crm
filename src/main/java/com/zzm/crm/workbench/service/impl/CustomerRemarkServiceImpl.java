package com.zzm.crm.workbench.service.impl;

import com.zzm.crm.workbench.pojo.CustomerRemark;
import com.zzm.crm.workbench.mapper.CustomerRemarkMapper;
import com.zzm.crm.workbench.service.CustomerRemarkService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

/**
 * @author ZZX
 * @version 1.0.0
 * @date 2023:05:09 08:32:07
 */

@Service
public class CustomerRemarkServiceImpl implements CustomerRemarkService {
    @Autowired
    private CustomerRemarkMapper customerRemarkMapper;

    @Override
    public List<CustomerRemark> queryDetailByCustomerId(String id) {
        return customerRemarkMapper.selectDetailByCustomerId(id);
    }
}
