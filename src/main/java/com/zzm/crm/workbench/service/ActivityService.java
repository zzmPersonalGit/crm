package com.zzm.crm.workbench.service;

import com.zzm.crm.workbench.pojo.Activity;

import java.util.List;
import java.util.Map;

public interface ActivityService {

    /**
     * 保存市场活动
     * @param activity
     */
    void saveCreateActivity(Activity activity);

    /**
     * 批量导入市场活动
     * @param activityList
     * @return
     */
    int saveActivityByFile(List<Activity> activityList);

    /**
     * 查询市场活动的分页信息
     * @param map
     * @return
     */
    List<Activity> queryActivityByConditionForPage(Map<Object,Object> map);

    /**
     * 查询市场活动的分页信息的总记录数
     * @param map
     * @return
     */
    int queryCountOfActivityForPage(Map<Object,Object> map);

    /**
     * 根据ID数组删除对应的市场活动
     * @param ids
     * @return
     */
    int deleteActivityByIds(String[] ids);

    /**
     * 根据ID查询市场活动
     * @param id
     * @return
     */
    Activity queryActivityById(String id);

    /**
     * 更新市场活动
     * @param activity
     * @return
     */
    int editActivity(Activity activity);

    /**
     * 查询市场活动信息(导出市场活动)
     * @param ids
     * @return
     */
    List<Activity> queryActivityForExport(String[] ids);

    /**
     * 查询线索ID查询关联的市场活动
     * @param id
     * @return
     */
    List<Activity> queryActivityByClueId(String id);

    /**
     * 根据参数查询线索未关联的市场活动
     * @param map
     * @return
     */
    List<Activity> queryActivityForFuzzy(Map map);

    /**
     * 根据参数查询跟自己关联了的市场活动信息
     * @param map
     * @return
     */
    List<Activity> queryActivityFuzzyForConvert(Map map);

    /**
     * 根据联系人ID和参数搜索已经关联但是未创建交易的市场活动
     * @param value
     * @param contactsId
     * @return
     */
    List<Activity> queryModifyActivityFuzzyForSave(String value,String contactsId);

    /**
     * 根据联系人的ID查询市场活动的关联信息
     * @param contactsId
     * @return
     */
    List<Activity> findAllActivityInfoByContactsId(String contactsId);

    /**
     * 根据联系人的ID查询未关联的市场活动信息
     * @param map
     * @return
     */
    List<Activity> queryActivityForFuzzyByContactsId(Map<String, String> map);
}
