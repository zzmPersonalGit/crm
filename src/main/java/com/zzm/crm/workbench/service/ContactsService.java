package com.zzm.crm.workbench.service;

import com.zzm.crm.workbench.pojo.Contacts;

import java.util.List;
import java.util.Map;

/**
 * @author ZZX
 * @version 1.0.0
 * @date 2023:05:09 09:00:01
 */

public interface ContactsService {
    /**
     * 根据条件进行分页查询
     * @param map
     * @return
     */
    List<Contacts> queryClueByConditionForPage(Map<Object, Object> map);

    /**
     * 根据条件查询符合条件的总记录数
     * @param map
     * @return
     */
    int queryCountOfClueForPage(Map<Object, Object> map);

    /**
     * 保存联系人
     * @param contacts
     * @return
     */
    int saveContacts(Contacts contacts);

    /**
     * 批量删除联系人
     * @param ids
     * @return
     */
    int deleteContactsByIds(String[] ids);

    /**
     * 根据联系人ID查询联系人信息
     * @param id
     * @return
     */
    Contacts queryContactsById(String id);

    /**
     * 修改联系人信息
     * @param contacts
     * @return
     */
    int editContacts(Contacts contacts);

    /**
     * 根据客户删除联系人信息
     * @param id
     */
    void deleteByCustomerId(String id);

    /**
     * 根据联系人ID查询联系人信息
     * @param id
     * @return
     */
    Contacts queryContactsForDetailById(String id);

    /**
     * 查询所有联系人
     * @return
     */
    List<Contacts> queryAll();

    /**
     * 根据客户ID查找联系人
     * @param customerId
     * @return
     */
    List<Contacts> queryByCustomerId(String customerId);

    /**
     * 根据ID删除联系人
     * @param contactsId
     * @return
     */
    int deleteById(String contactsId);

    /**
     * 修改交易根据交易ID查询公司下的联系人信息
     * @param transcationId
     * @return
     */
    List<Contacts> queryByTransctionToCustomer(String transcationId);
}
