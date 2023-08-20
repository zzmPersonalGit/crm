package com.zzm.crm.workbench.service.impl;

import com.zzm.crm.workbench.pojo.TransactionRemark;
import com.zzm.crm.workbench.mapper.TransactionRemarkMapper;
import com.zzm.crm.workbench.service.TransactionRemarkService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
@Transactional
@Service
public class TransactionRemarkServiceImpl implements TransactionRemarkService {
    @Autowired
    private TransactionRemarkMapper transactionRemarkMapper;

    @Override
    public int saveTranRemark(TransactionRemark remark) {
        return transactionRemarkMapper.insertTranRemark(remark);
    }

    @Override
    public List<TransactionRemark> queryModifyDataByTranId(String id) {
        return transactionRemarkMapper.selectModifyDataByTranId(id);
    }
}
