package com.zzm.crm.workbench.mapper;

import com.zzm.crm.commons.pojo.ReturnChartObject;
import com.zzm.crm.workbench.pojo.Activity;
import com.zzm.crm.workbench.pojo.Transaction;

import java.util.List;
import java.util.Map;

public interface TransactionMapper {
    /**
     * 根据交易ID删除交易
     * @param id
     * @return
     */
    int deleteByPrimaryKey(String id);

    /**
     * 插入交易信息
     * @param row
     * @return
     */
    int insertOriginData(Transaction row);

    /**
     * 根据交易ID查询交易详细信息
     * @param id
     * @return
     */
    Transaction selectModifyDataByPrimaryKey(String id);

    /**
     * 查询图表的相关数据
     * @return
     */
    List<ReturnChartObject> selectReturnChartPojoByGroupByStage();

    /**
     * 根据客户ID查询交易记录
     * @param id
     * @return
     */
    List<Transaction> findAllTranByCustomerId(String id);

    /**
     * 根据联系人ID查询交易记录
     * @param contactsId
     * @return
     */
    List<Transaction> findAllTranByonContactsId(String contactsId);

    /**
     * 分页查询交易信息
     * @param map
     * @return
     */
    List<Transaction> findTransactionPageInfo(Map<Object, Object> map);

    /**
     * 查询符合分页条件的总记录数
     * @param map
     * @return
     */
    int findTransactionPageInfoNum(Map<Object, Object> map);

    /**
     * 删除交易记录
     * @param id
     * @return
     */
    int deleteTranscationByIds(String[] id);

    /**
     * 根据ID查询信息
     * @param id
     * @return
     */
    Transaction findById(String id);

    /**
     * 更新交易信息
     * @param transaction
     * @return
     */
    int updateTran(Transaction transaction);

    /**
     * 根据交易ID得到客户ID
     * @param transcationId
     * @return
     */
    String getCustomerIdByTranscationId(String transcationId);

    /**
     * 根据联系人的ID找到对应的交易信息ID列表
     * @return
     */
    List<String> findAllTranIdListByContactsId(String id);

    /**
     * 根据交易ID查询市场活动信息
     * @param id
     * @return
     */
    Activity queryActivityById(String id);

    /**
     * 根据交易ID查询阶段
     * @param id
     * @return
     */
    String queryStage(String id);
}
