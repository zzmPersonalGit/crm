package com.zzm.crm.workbench.service;

import com.zzm.crm.workbench.pojo.TransactionRemark;

import java.util.List;

public interface TransactionRemarkService {
    /**
     * 根据交易ID查询交易备注信息
     * @param id
     * @return
     */
    List<TransactionRemark> queryModifyDataByTranId(String id);

    /**
     * 保存交易备注信息
     * @param remark
     * @return
     */
    int saveTranRemark(TransactionRemark remark);
}
