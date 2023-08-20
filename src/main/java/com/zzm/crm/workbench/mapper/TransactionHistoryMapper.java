package com.zzm.crm.workbench.mapper;

import com.zzm.crm.workbench.pojo.TransactionHistory;

import java.util.List;

public interface TransactionHistoryMapper {

    /**
     * 插入交易记录信息
     * @param row
     * @return
     */
    int insertOriginData(TransactionHistory row);


    /**
     * 根据交易ID查询交易历史记录
     * @param id
     * @return
     */
    List<TransactionHistory> selectModifyDataByTranId(String id);


    /**
     * 根据交易ID删除交易的历史信息
     * @param id
     */
    void deleteByTranId(String id);
}
