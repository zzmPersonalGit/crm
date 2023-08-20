package com.zzm.crm.workbench.service;

import com.zzm.crm.commons.pojo.ReturnChartObject;
import com.zzm.crm.workbench.pojo.Activity;
import com.zzm.crm.workbench.pojo.Transaction;

import java.util.List;
import java.util.Map;

public interface TransactionService {
    /**
     * 保存交易信息
     * @param map
     */
    void saveTransactionUseTran(Map<String,Object> map);

    /**
     * 根据交易ID查询交易详细信息
     * @param id
     * @return
     */
    Transaction queryModifyDataByPrimaryKey(String id);

    /**
     * 查询图表的相关数据
     * @return
     */
    List<ReturnChartObject> queryReturnChartPojoByGroupByStage();

    /**
     * 删除交易
     * @param transcationId
     * @return
     */
    int deleteById(String transcationId);

    /**
     * 分页查询交易信息
     * @param map
     * @return
     */
    List<Transaction> queryTransactionByConditionForPage(Map<Object, Object> map);

    /**
     * 查询符合分页的总记录数
     * @param map
     * @return
     */
    int queryCountOfTransactionForPage(Map<Object, Object> map);

    /**
     * 删除交易记录
     * @param id
     * @return
     */
    int deleteByIds(String[] id);

    /**
     * 根据ID查询信息
     * @param id
     * @return
     */
    Transaction selectById(String id);

    /**
     * 更新交易信息
     * @param transaction
     * @return
     */
    int editTranscation(Transaction transaction);

    /**
     * 根据交易ID查询是哪个市场活动
     * @param id
     * @return
     */
    Activity queryActivityInfoByTranId(String id);

    /**
     * 根据交易ID查询交易阶段
     * @param id
     * @return
     */
    String queryIsCompleteByTranId(String id);
}
