package com.zzm.crm.workbench.service.impl;

import com.zzm.crm.commons.constants.Constans;
import com.zzm.crm.commons.pojo.ReturnChartObject;
import com.zzm.crm.commons.utils.DateFormatUtil;
import com.zzm.crm.commons.utils.UUIDUtil;
import com.zzm.crm.settings.pojo.User;
import com.zzm.crm.workbench.pojo.Activity;
import com.zzm.crm.workbench.pojo.Customer;
import com.zzm.crm.workbench.pojo.Transaction;
import com.zzm.crm.workbench.pojo.TransactionHistory;
import com.zzm.crm.workbench.mapper.CustomerMapper;
import com.zzm.crm.workbench.mapper.TransactionHistoryMapper;
import com.zzm.crm.workbench.mapper.TransactionMapper;
import com.zzm.crm.workbench.mapper.TransactionRemarkMapper;
import com.zzm.crm.workbench.service.TransactionRemarkService;
import com.zzm.crm.workbench.service.TransactionService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Date;
import java.util.List;
import java.util.Map;

@Transactional
@Service
public class TransactionServiceImpl implements TransactionService {
    @Autowired
    private CustomerMapper customerMapper;
    @Autowired
    private TransactionMapper transactionMapper;
    @Autowired
    private TransactionHistoryMapper transactionHistoryMapper;
    @Autowired
    private TransactionRemarkService transactionRemarkService;
    @Autowired
    private TransactionRemarkMapper transactionRemarkMapper;

    @Override
    public void saveTransactionUseTran(Map<String, Object> map) {
        User user = (User) map.get(Constans.SESSION_LOGIN_INF);
        String customerName = (String) map.get("customerName");

        //检验客户是否为空，为空则新建
        Customer customer = customerMapper.selectOriginById(customerName);
        if (customer==null){
            customer = new Customer();
            customer.setId(UUIDUtil.getUUID());
            customer.setCreateBy(user.getId());
            customer.setCreateTime(DateFormatUtil.formatDateTime(new Date()));
            customerMapper.insertCustomerForOrigin(customer);
        }

        //创建交易pojo后插入relation里
        Transaction transaction = new Transaction();

        //设置参数
        transaction.setId(UUIDUtil.getUUID());
        transaction.setCreateBy(user.getId());
        transaction.setCreateTime(DateFormatUtil.formatDateTime(new Date()));
        transaction.setOwner(((String) map.get("owner")));
        transaction.setMoney(((String) map.get("money")));
        transaction.setName(((String) map.get("name")));
        transaction.setExpectedDate(((String) map.get("expectedDate")));
        transaction.setCustomerId(customer.getId());
        transaction.setStage(((String) map.get("stage")));
        transaction.setPossibility(((String) map.get("possibility")));
        transaction.setSource(((String) map.get("source")));
        transaction.setActivityId(((String) map.get("activityId")));
        transaction.setContactsId(((String) map.get("contactsId")));
        transaction.setDescription(((String) map.get("description")));
        transaction.setContactSummary(((String) map.get("contactSummary")));
        transaction.setNextContactTime(((String) map.get("nextContactTime")));
        transaction.setTransactionType(((String) map.get("transactionType")));

        transactionMapper.insertOriginData(transaction);

        //把该次内容插入交易历史表里面
        TransactionHistory transactionHistory = new TransactionHistory();
        transactionHistory.setId(UUIDUtil.getUUID());
        transactionHistory.setCreateBy(user.getId());
        transactionHistory.setCreateTime(DateFormatUtil.formatDateTime(new Date()));
        transactionHistory.setStage(((String) map.get("stage")));
        transactionHistory.setMoney(((String) map.get("money")));
        transactionHistory.setExpectedDate(((String) map.get("expectedDate")));
        transactionHistory.setTranId(transaction.getId());
        transactionHistoryMapper.insertOriginData(transactionHistory);
    }

    @Override
    public Transaction queryModifyDataByPrimaryKey(String id) {
        return transactionMapper.selectModifyDataByPrimaryKey(id);
    }

    @Override
    public List<Transaction> queryTransactionByConditionForPage(Map<Object, Object> map) {
        return transactionMapper.findTransactionPageInfo(map);
    }

    @Override
    public String queryIsCompleteByTranId(String id) {
        return transactionMapper.queryStage(id);
    }

    @Override
    public Activity queryActivityInfoByTranId(String id) {
        return transactionMapper.queryActivityById(id);
    }

    @Override
    public int editTranscation(Transaction transaction) {
        // 更新交易信息，则还要更新一下交易历史记录
        // 还要更新交易记录表,把该次内容插入交易历史表里面
        TransactionHistory transactionHistory = new TransactionHistory();
        transactionHistory.setId(UUIDUtil.getUUID());
        transactionHistory.setCreateBy(transaction.getEditBy());
        transactionHistory.setCreateTime(DateFormatUtil.formatDateTime(new Date()));
        transactionHistory.setStage(transaction.getStage());
        transaction.setPossibility(transaction.getPossibility());
        transactionHistory.setMoney(transaction.getMoney());
        transactionHistory.setExpectedDate(transaction.getExpectedDate());
        transactionHistory.setTranId(transaction.getId());
        transactionHistoryMapper.insertOriginData(transactionHistory);
        return transactionMapper.updateTran(transaction);
    }

    @Override
    public Transaction selectById(String id) {
        return transactionMapper.findById(id);
    }

    @Override
    public int deleteByIds(String[] ids) {
        // 删除跟交易活动相关的所有备注，删除交易相关的历史记录
        for(String id:ids) {
            // TODO 1:删除交易的备注信息
            transactionRemarkMapper.deleteByTranId(id);

            // TODO 2:删除交易的历史记录
            transactionHistoryMapper.deleteByTranId(id);
        }

        // TODO 3:批量删除交易的信息
        return transactionMapper.deleteTranscationByIds(ids);
    }

    @Override
    public int queryCountOfTransactionForPage(Map<Object, Object> map) {
        return transactionMapper.findTransactionPageInfoNum(map);
    }

    @Override
    public int deleteById(String transcationId) {
        return transactionMapper.deleteByPrimaryKey(transcationId);
    }

    @Override
    public List<ReturnChartObject> queryReturnChartPojoByGroupByStage() {
        return transactionMapper.selectReturnChartPojoByGroupByStage();
    }
}
