package com.zzm.crm.workbench.mapper;

import com.zzm.crm.workbench.pojo.Activity;
import org.apache.ibatis.annotations.Param;

import java.util.List;
import java.util.Map;

public interface ActivityMapper {
    /**
     * 批量删除市场活动
     * @param ids
     * @return
     */
    int deleteActivityByIds(String[] ids);

    /**
     * 插入市场活动信息
     * @param row
     * @return
     */
    int insertActivity(Activity row);

    /**
     * 批量导入市场活动
     * @param activityList
     * @return
     */
    int insertActivityByFile(List<Activity> activityList);

    /**
     * 分页查询市场活动信息
     * @param map
     * @return
     */
    List<Activity> selectActivityByConditionForPage(Map<Object,Object> map);

    /**
     * 分页查询市场活动信息总记录数
     * @param map
     * @return
     */
    int selectCountOfActivityForPage(Map<Object,Object> map);

    /**
     * 根据ID查询市场活动信息
     * @param id
     * @return
     */
    Activity selectActivityById(String id);

    /**
     * 更新市场活动
     * @param activity
     * @return
     */
    int updateActivity(Activity activity);

    /**
     * 查询市场活动的信息(导出市场活动)
     * @param ids
     * @return
     */
    List<Activity> selectActivityForExport(String[] ids);

    /**
     * 根据线索的ID查询关联的市场活动列表
     * @param id
     * @return
     */
    List<Activity> selectActivityByClueId(String id);

    /**
     * 根据参数查询未关联的市场活动
     * @param map
     * @return
     */
    List<Activity> selectActivityForFuzzy(Map map);

    /**
     * 根据参数查询跟自己关联了的市场活动信息
     * @param map
     * @return
     */
    List<Activity> selectActivityFuzzyForConvert(Map map);

    /**
     * 根据联系人ID和参数搜索已经关联但是未创建交易的市场活动
     * @param value
     * @param contactsId
     * @return
     */
    List<Activity> selectModifyActivityFuzzyForSave(@Param("value") String value, @Param("contactsId") String contactsId);

    /**
     * 根据联系人的ID查询市场活动的关联信息
     * @param contactsId
     * @return
     */
    List<Activity> selectAllActivityInfoByContactsId(String contactsId);

    /**
     * 根据联系人的ID查询未关联的市场活动信息
     * @param map
     * @return
     */
    List<Activity> selectAllNoRelationActivityInfoByContactsId(Map<String, String> map);
}
