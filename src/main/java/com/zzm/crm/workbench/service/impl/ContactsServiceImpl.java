package com.zzm.crm.workbench.service.impl;

import com.zzm.crm.workbench.mapper.ContactsActivityRelationMapper;
import com.zzm.crm.workbench.mapper.ContactsMapper;
import com.zzm.crm.workbench.mapper.ContactsRemarkMapper;
import com.zzm.crm.workbench.mapper.TransactionMapper;
import com.zzm.crm.workbench.pojo.Contacts;
import com.zzm.crm.workbench.service.ContactsService;
import com.zzm.crm.workbench.service.TransactionService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;

/**
 * @author ZZX
 * @version 1.0.0
 * @date 2023:05:09 09:03:02
 */

@Service
public class ContactsServiceImpl implements ContactsService {
    @Autowired
    private ContactsMapper contactsMapper;

    @Autowired
    private ContactsRemarkMapper contactsRemarkMapper;

    @Autowired
    private TransactionMapper transactionMapper;

    @Autowired
    private ContactsActivityRelationMapper contactsActivityRelationMapper;

    @Autowired
    private TransactionService transactionService;

    @Override
    public List<Contacts> queryByTransctionToCustomer(String transcationId) {
        // 先查询公司的信息
        String customerId = transactionMapper.getCustomerIdByTranscationId(transcationId);
        List<Contacts> contacts = contactsMapper.getContactsInfoByCustomerId(customerId);
        return contacts;
    }

    @Override
    public int deleteById(String contactsId) {
        return contactsMapper.deleteByPrimaryKey(contactsId);
    }

    @Override
    public List<Contacts> queryByCustomerId(String customerId) {
        return contactsMapper.getContactsInfoByCustomerId(customerId);
    }

    @Override
    public List<Contacts> queryAll() {
        return contactsMapper.queryAll();
    }

    @Override
    public Contacts queryContactsForDetailById(String id) {
        return contactsMapper.queryContactById(id);
    }

    @Override
    public void deleteByCustomerId(String id) {
        // 先得到联系人的ID列表
        List<Contacts> contactsList = contactsMapper.getContactsInfoByCustomerId(id);

        for (Contacts contacts : contactsList) {
            String contactsId = contacts.getId();
            // 删除联系人信息
            contactsMapper.deleteByPrimaryKey(contactsId);

            // 删除联系人的备注信息
            contactsRemarkMapper.deleteByContactsId(contactsId);

            // 删除联系人和市场活动的关联信息
            contactsActivityRelationMapper.deleteByClueId(contactsId);
        }
    }

    @Override
    public int editContacts(Contacts contacts) {
        return contactsMapper.updateByPrimaryKey(contacts);
    }

    @Override
    public Contacts queryContactsById(String id) {
        return contactsMapper.selectById(id);
    }

    @Override
    public int deleteContactsByIds(String[] ids) {
        for (String id : ids) {
            // TODO 1:根据联系人的ID删除联系人的备注信息
            contactsRemarkMapper.deleteByContactsId(id);

            // TODO 2:根据联系人ID删除联系人和市场活动的关联关系
            contactsActivityRelationMapper.deleteByContactsId(id);

            // TODO 3:根据联系人的ID找到对应的交易信息列表，删除该联系人负责的交易信息
            List<String> tranIds = transactionMapper.findAllTranIdListByContactsId(id);
            if(tranIds.size()>0) {
                String[] strings = tranIds.toArray(new String[tranIds.size()]);
                transactionService.deleteByIds(strings);
            }
        }

        // TODO 4:删除联系人自身的信息
        return contactsMapper.deleteContactsByIds(ids);
    }

    @Override
    public int saveContacts(Contacts contacts) {
        return contactsMapper.insertForOrigin(contacts);
    }

    @Override
    public int queryCountOfClueForPage(Map<Object, Object> map) {
        return contactsMapper.selectCountOfClueForPage(map);
    }

    @Override
    public List<Contacts> queryClueByConditionForPage(Map<Object, Object> map) {
        return contactsMapper.selectContactsByConditionForPage(map);
    }
}
