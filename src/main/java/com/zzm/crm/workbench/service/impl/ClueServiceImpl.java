package com.zzm.crm.workbench.service.impl;

import com.zzm.crm.commons.constants.Constans;
import com.zzm.crm.commons.utils.DateFormatUtil;
import com.zzm.crm.commons.utils.UUIDUtil;
import com.zzm.crm.settings.pojo.User;
import com.zzm.crm.workbench.mapper.*;
import com.zzm.crm.workbench.pojo.*;

import com.zzm.crm.workbench.service.ClueService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Map;

@Service
@Transactional
public class ClueServiceImpl implements ClueService {
    @Autowired
    private ClueMapper clueMapper;
    @Autowired
    private ClueRemarkMapper clueRemarkMapper;
    @Autowired
    private CustomerMapper customerMapper;
    @Autowired
    private ContactsMapper contactsMapper;
    @Autowired
    private CustomerRemarkMapper customerRemarkMapper;
    @Autowired
    private ContactsRemarkMapper contactsRemarkMapper;
    @Autowired
    private ClueActivityRelationMapper clueActivityRelationMapper;
    @Autowired
    private ContactsActivityRelationMapper contactsActivityRelationMapper;
    @Autowired
    private TransactionMapper transactionMapper;
    @Autowired
    private TransactionRemarkMapper transactionRemarkMapper;
    @Autowired
    private TransactionHistoryMapper transactionHistoryMapper;


    @Override
    public int saveClue(Clue row) {
        return clueMapper.insertClue(row);
    }

    @Override
    public Clue queryClueByPrimaryKey(String id) {
        return clueMapper.selectClueByPrimaryKey(id);
    }

    @Override
    public List<Clue> queryClueByConditionForPage(Map<Object, Object> map) {
        return clueMapper.selectClueByConditionForPage(map);
    }

    @Override
    public int updateClueById(Clue clue) {
        return clueMapper.updateByPrimaryKey(clue);
    }

    @Override
    public Clue queryClueById(String id) {
        return clueMapper.selectById(id);
    }

    @Override
    public int deleteClueByIds(String[] ids) {
        for (String id : ids) {
            // 批量删除相关的备注信息
            clueRemarkMapper.deleteByClueId(id);
        }
        return clueMapper.deleteBatchByIds(ids);
    }

    @Override
    public int queryCountOfClueForPage(Map<Object, Object> map) {
        return clueMapper.selectCountOfClueForPage(map);
    }

    @Override
    public void clueConvertByConvertBtn(Map<String, Object> map) {
        // 拿到线索ID和登录用户
        String clueId = (String) map.get("clueId");
        User user = (User) map.get(Constans.SESSION_LOGIN_INF);

        // TODO 第一步:获取线索对象,得到客户和联系人的信息,分别存到表里
        Clue clue = clueMapper.selectClueOfOriginDetailByPrimaryKey(clueId);
        // TODO 1.1:第一张表,客户表的插入
        Customer customer = customerMapper.selectOriginByAccurateName(clue.getCompany());
        if (customer == null) {
            customer = new Customer();
            customer.setId(UUIDUtil.getUUID());
            customer.setOwner(user.getId());
            customer.setName(clue.getCompany());
            customer.setWebsite(clue.getWebsite());
            customer.setPhone(clue.getPhone());
            customer.setCreateTime(DateFormatUtil.formatDateTime(new Date()));
            customer.setCreateBy(user.getId());
            customer.setContactSummary(clue.getContactSummary());
            customer.setNextContactTime(clue.getNextContactTime());
            customer.setDescription(clue.getDescription());
            customer.setAddress(clue.getAddress());
            customerMapper.insertCustomerForOrigin(customer);
        }

        // TODO 1.2:第二张表,联系人表的插入
        Contacts contacts = new Contacts();
        contacts.setId(UUIDUtil.getUUID());
        contacts.setOwner(user.getId());
        contacts.setSource(clue.getSource());
        contacts.setCustomerId(customer.getId());
        contacts.setFullname(clue.getFullname());
        contacts.setAppellation(clue.getAppellation());
        contacts.setEmail(clue.getEmail());
        contacts.setMphone(clue.getMphone());
        contacts.setJob(clue.getJob());
        contacts.setCreateTime(DateFormatUtil.formatDateTime(new Date()));
        contacts.setCreateBy(user.getId());
        contacts.setDescription(clue.getDescription());
        contacts.setContactSummary(clue.getContactSummary());
        contacts.setNextContactTime(clue.getNextContactTime());
        contacts.setAddress(clue.getAddress());
        contactsMapper.insertForOrigin(contacts);


        // TODO 第二步:获取线索备注列表,将备注信息插入客户和联系人的备注信息里
        // TODO 根据线索的ID查询线索的备注信息
        List<ClueRemark> clueRemarkList = clueRemarkMapper.selectClueForOriginByClueId(clueId);
        if (clueRemarkList != null && clueRemarkList.size() > 0) {
            List<CustomerRemark> customerRemarkList = new ArrayList<>();
            List<ContactsRemark> contactsRemarkList = new ArrayList<>();
            CustomerRemark customerRemark = null;
            ContactsRemark contactsRemark = null;

            for (ClueRemark clueRemark : clueRemarkList) {
                // TODO 2.1:第三张表,插入到客户备注表
                customerRemark = new CustomerRemark();
                customerRemark.setId(UUIDUtil.getUUID());
                customerRemark.setNoteContent(clueRemark.getNoteContent());
                customerRemark.setCreateBy(clueRemark.getCreateBy());
                customerRemark.setCreateTime(clueRemark.getCreateTime());
                customerRemark.setEditBy(clueRemark.getEditBy());
                customerRemark.setEditTime(clueRemark.getEditTime());
                customerRemark.setEditFlag(clueRemark.getEditFlag());
                customerRemark.setCustomerId(customer.getId());
                customerRemarkList.add(customerRemark);

                // TODO 2.2:第四张表,插入到联系人备注表
                contactsRemark = new ContactsRemark();
                contactsRemark.setId(UUIDUtil.getUUID());
                contactsRemark.setNoteContent(clueRemark.getNoteContent());
                contactsRemark.setCreateBy(clueRemark.getCreateBy());
                contactsRemark.setCreateTime(clueRemark.getCreateTime());
                contactsRemark.setEditBy(clueRemark.getEditBy());
                contactsRemark.setEditTime(clueRemark.getEditTime());
                contactsRemark.setEditFlag(clueRemark.getEditFlag());
                contactsRemark.setContactsId(contacts.getId());
                contactsRemarkList.add(contactsRemark);
            }

            customerRemarkMapper.insertOriginData(customerRemarkList);
            contactsRemarkMapper.insertOriginData(contactsRemarkList);
        }

        // TODO 第三步:获取线索与市场活动的关系列表,得到联系人与市场活动联系的关系
        // TODO 根据线索的ID得到线索和市场活动的关联关系
        List<ClueActivityRelation> relationList = clueActivityRelationMapper.selectOriginByClueId(clueId);
        if (relationList != null && relationList.size() > 0) {
            List<ContactsActivityRelation> list = new ArrayList<>();
            ContactsActivityRelation contactsActivityRelation = null;
            for (ClueActivityRelation relation : relationList) {
                // 创建联系人和市场活动的关系对象
                contactsActivityRelation = new ContactsActivityRelation();
                contactsActivityRelation.setId(UUIDUtil.getUUID());
                contactsActivityRelation.setActivityId(relation.getActivityId());
                contactsActivityRelation.setContactsId(contacts.getId());
                list.add(contactsActivityRelation);
            }
            // 批量插入联系人和市场活动关联数据
            contactsActivityRelationMapper.insertOriginData(list);
        }

        //TODO 第四步:创建交易
        String isCreateTran = (String) map.get("isCreateTran");
        String money = (String) map.get("money");
        String name = (String) map.get("name");
        String expectedDate = (String) map.get("expectedDate");
        String nextContactTime = (String) map.get("nextContactTime");
        String stage = (String) map.get("stage");
        String source = (String) map.get("source");
        String activityId = (String) map.get("activityId");
        String transcationType = (String) map.get("transcationType");
        String possibility = (String) map.get("possibility");

        if ("true".equals(isCreateTran)) {
            // TODO 4.1:创建交易
            Transaction transaction = new Transaction();
            transaction.setId(UUIDUtil.getUUID());
            transaction.setOwner(user.getId());
            transaction.setMoney(money);
            transaction.setName(name);
            transaction.setExpectedDate(expectedDate);
            transaction.setNextContactTime(nextContactTime);
            transaction.setCustomerId(customer.getId());
            transaction.setStage(stage);
            transaction.setSource(source);
            transaction.setActivityId(activityId);
            transaction.setContactsId(contacts.getId());
            transaction.setPossibility(possibility);
            transaction.setTransactionType(transcationType);
            transaction.setCreateBy(user.getId());
            transaction.setCreateTime(DateFormatUtil.formatDateTime(new Date()));
            transactionMapper.insertOriginData(transaction);

            // 插入交易历史记录
            TransactionHistory transactionHistory = new TransactionHistory();
            transactionHistory.setId(UUIDUtil.getUUID());
            transactionHistory.setCreateBy(user.getId());
            transactionHistory.setCreateTime(DateFormatUtil.formatDateTime(new Date()));
            transactionHistory.setStage(stage);
            transactionHistory.setMoney(money);
            transactionHistory.setExpectedDate(expectedDate);
            transactionHistory.setTranId(transaction.getId());
            transactionHistoryMapper.insertOriginData(transactionHistory);

            // TODO 4.2:批量插入交易的备注信息
            if (clueRemarkList != null && clueRemarkList.size() > 0) {
                ArrayList<TransactionRemark> transactionRemarks = new ArrayList<>();
                TransactionRemark transactionRemark = null;
                for (ClueRemark clueRemark : clueRemarkList) {
                    transactionRemark = new TransactionRemark();
                    transactionRemark.setId(UUIDUtil.getUUID());
                    transactionRemark.setNoteContent(clueRemark.getNoteContent());
                    transactionRemark.setCreateBy(clueRemark.getCreateBy());
                    transactionRemark.setCreateTime(clueRemark.getCreateTime());
                    transactionRemark.setEditBy(clueRemark.getEditBy());
                    transactionRemark.setEditTime(clueRemark.getEditTime());
                    transactionRemark.setEditFlag(clueRemark.getEditFlag());
                    transactionRemark.setTranId(transaction.getId());
                    transactionRemarks.add(transactionRemark);
                }
                transactionRemarkMapper.insertOriginData(transactionRemarks);
            }
        }

        // TODO 第五步:删除线索相关的数据

        // TODO 5.1:删除线索和市场活动的关系
        clueActivityRelationMapper.deleteRelationByClueId(clueId);

        // TODO 5.2:删除线索的备注信息
        clueRemarkMapper.deleteDataByClueId(clueId);

        // TODO 5.3:删除线索自身的信息
        clueMapper.deleteDataByClueId(clueId);
    }
}
