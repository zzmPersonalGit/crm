package com.zzm.crm.workbench.service;

import com.zzm.crm.workbench.pojo.ActivityRemark;

import java.util.List;

public interface ActivityRemarkService {
    /**
     * 根据市场活动的ID来查询对应的市场活动备注信息
     * @param id
     * @return
     */
    List<ActivityRemark> queryDetailByActivityId(String id);

    /**
     * 保存市场活动的备注信息
     * @param activityRemark
     * @return
     */
    int saveActivityRemark(ActivityRemark activityRemark);

    /**
     * 删除市场活动备注
     * @param id
     * @return
     */
    int deleteByPrimaryKey(String id);

    /**
     * 编辑市场活动备注信息
     * @param activityRemark
     * @return
     */
    int editByPrimaryKey(ActivityRemark activityRemark);

    /**
     * 根据市场活动的ID删除市场活动备注信息
     * @param id
     */
    void deleteAllByActivityId(String id);
}
