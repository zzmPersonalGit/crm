package com.zzm.crm.workbench.mapper;

import com.zzm.crm.workbench.pojo.ContactsRemark;
import org.apache.ibatis.annotations.Param;

import java.util.List;

public interface ContactsRemarkMapper {


    /**
     * 删除联系人备注
     * @param id
     * @return
     */
    int deleteByPrimaryKey(String id);

    /**
     * 插入数据到联系人的备注表
     * @param list
     * @return
     */
    int insertOriginData(List<ContactsRemark> list);




    /**
     * 根据联系人ID删除备注信息
     * @param contactsId
     */
    void deleteByContactsId(@Param("id") String contactsId);

    /**
     * 根据联系人ID查看备注信息
     * @param id
     * @return
     */
    List<ContactsRemark> queryDetailByContactsId(String id);

    /**
     * 保存联系人备注信息
     * @param remark
     * @return
     */
    int saveContactsRemark(ContactsRemark remark);

    /**
     * 修改备注信息
     * @param remark
     * @return
     */
    int updateById(ContactsRemark remark);
}
