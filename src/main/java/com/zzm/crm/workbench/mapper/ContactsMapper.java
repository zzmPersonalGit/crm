package com.zzm.crm.workbench.mapper;

import com.zzm.crm.workbench.pojo.Contacts;

import java.util.List;
import java.util.Map;

public interface ContactsMapper {
    /**
     * 根据ID删除联系人
     * @param id
     * @return
     */
    int deleteByPrimaryKey(String id);

    /**
     * 插入联系人
     * @param row
     * @return
     */
    int insertForOrigin(Contacts row);

    /**
     * 根据ID查询联系人信息
     * @param id
     * @return
     */
    Contacts selectByPrimaryKey(String id);

    /**
     * 修改联系人信息
     * @param row
     * @return
     */
    int updateByPrimaryKey(Contacts row);

    /**
     * 根据条件分页查询符合条件的总记录数
     * @param map
     * @return
     */
    int selectCountOfClueForPage(Map<Object, Object> map);

    /**
     * 根据条件分页查询符合条件
     * @param map
     * @return
     */
    List<Contacts> selectContactsByConditionForPage(Map<Object, Object> map);

    /**
     * 批量删除联系人
     * @param ids
     * @return
     */
    int deleteContactsByIds(String[] ids);

    /**
     * 根据ID查询联系人信息
     * @param id
     * @return
     */
    Contacts selectById(String id);


    /**
     * 根据联系人ID查询联系人信息
     * @param id
     * @return
     */
    Contacts queryContactById(String id);

    /**
     * 查询所有联系人
     * @return
     */
    List<Contacts> queryAll();

    /**
     * 根据客户ID查询联系人信息
     * @param customerId
     * @return
     */
    List<Contacts> getContactsInfoByCustomerId(String customerId);

    /**
     * 根据客户ID查询联系人ID列表
     * @param id
     * @return
     */
    List<String> getContactsIdListByCustomerId(String id);

}
