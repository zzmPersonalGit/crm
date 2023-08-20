package com.zzm.crm.workbench.mapper;

import com.zzm.crm.workbench.pojo.ContactsActivityRelation;
import org.apache.ibatis.annotations.Param;

import java.util.List;

public interface ContactsActivityRelationMapper {

    /**
     * 批量插入联系人和市场活动的关联关系
     * @param list
     * @return
     */
    int insertOriginData(List<ContactsActivityRelation> list);

    /**
     * 根据联系人ID删除联系人和市场活动关联关系
     * @param contactsId
     */
    void deleteByClueId(@Param("id") String contactsId);

    /**
     * 解除市场活动和联系人的关联关系
     * @param activityId
     * @param contactsId
     * @return
     */
    int deleteRelation(@Param("activityId") String activityId,
                       @Param("contactsId") String contactsId);

    /**
     * 根据联系人的ID删除所关联的市场活动
     * @param id
     */
    void deleteByContactsId(@Param("contactsId") String id);

    /**
     * 保存联系人和市场活动的关联关系
     * @param list
     * @return
     */
    int saveContactsActivityRelationByIds(List<ContactsActivityRelation> list);
}
