package com.zzm.crm.workbench.mapper;

import com.zzm.crm.workbench.pojo.TransactionRemark;

import java.util.List;

public interface TransactionRemarkMapper {
    /**
     * 删除交易备注信息
     * @param id
     * @return
     */
    int deleteByPrimaryKey(String id);

    /**
     * 批量插入交易的备注信息
     * @param list
     * @return
     */
    int insertOriginData(List<TransactionRemark> list);


    /**
     * 根据交易ID查询交易备注信息
     * @param id
     * @return
     */
    List<TransactionRemark> selectModifyDataByTranId(String id);

    /**
     * 根据交易ID删除交易的备注信息
     * @param id
     */
    void deleteByTranId(String id);

    /**
     * 保存交易备注信息
     * @param remark
     * @return
     */
    int insertTranRemark(TransactionRemark remark);

    /**
     * 编辑交易备注信息
     * @param remark
     * @return
     */
    int updateById(TransactionRemark remark);
}
