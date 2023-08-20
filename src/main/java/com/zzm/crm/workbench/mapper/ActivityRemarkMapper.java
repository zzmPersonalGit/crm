package com.zzm.crm.workbench.mapper;

import com.zzm.crm.workbench.pojo.ActivityRemark;

import java.util.List;

public interface ActivityRemarkMapper {
    /**
     * 删除市场活动备注
     * @param id
     * @return
     */
    int deleteByPrimaryKey(String id);

    /**
     * 插入市场活动的备注信息
     * @param activityRemark
     * @return
     */
    int insertActivityRemark(ActivityRemark activityRemark);

    /**
     * 根据市场活动的ID来查询市场活动的备注信息
     * @param id
     * @return
     */
    List<ActivityRemark> selectDetailByActivityId(String id);

    /**
     * 查询所有的市场活动备注信息
     * @return
     */
    List<ActivityRemark> selectAll();

    /**
     * 更新市场活动备注信息
     * @param activityRemark
     * @return
     */
    int updateByPrimaryKey(ActivityRemark activityRemark);

    /**
     * 根据市场活动ID删除市场活动备注信息
     * @param id
     */
    void deleteByActivityId(String id);
}
