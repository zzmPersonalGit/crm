package com.zzm.crm.workbench.service;

import com.zzm.crm.workbench.pojo.TransactionHistory;

import java.util.List;

public interface TransactionHistoryService {
    /**
     * 根据交易ID查询交易历史记录
     * @param id
     * @return
     */
    List<TransactionHistory> selectModifyDataByTranId(String id);
}
