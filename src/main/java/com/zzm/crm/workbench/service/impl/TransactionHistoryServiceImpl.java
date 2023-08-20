package com.zzm.crm.workbench.service.impl;

import com.zzm.crm.workbench.pojo.TransactionHistory;
import com.zzm.crm.workbench.mapper.TransactionHistoryMapper;
import com.zzm.crm.workbench.service.TransactionHistoryService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Transactional
@Service
public class TransactionHistoryServiceImpl implements TransactionHistoryService {
    @Autowired
    private TransactionHistoryMapper transactionHistoryMapper;

    @Override
    public List<TransactionHistory> selectModifyDataByTranId(String id) {
        return transactionHistoryMapper.selectModifyDataByTranId(id);
    }
}
