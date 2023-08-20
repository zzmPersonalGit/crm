package com.zzm.crm.workbench.service.impl;

import com.zzm.crm.workbench.pojo.Activity;
import com.zzm.crm.workbench.service.ActivityRemarkService;
import com.zzm.crm.workbench.service.ActivityService;
import com.zzm.crm.workbench.mapper.ActivityMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Map;

@Service
@Transactional
public class ActivityServiceImpl implements ActivityService {
    @Autowired
    private ActivityMapper activityMapper;

    @Autowired
    private ActivityRemarkService activityRemarkService;

    @Override
    public void saveCreateActivity(Activity activity) {
        activityMapper.insertActivity(activity);
    }

    @Override
    public int saveActivityByFile(List<Activity> activityList) {
        return activityMapper.insertActivityByFile(activityList);
    }

    /**
     * 分页查询市场活动信息
     *
     * @param map
     * @return
     */
    @Override
    public List<Activity> queryActivityByConditionForPage(Map<Object, Object> map) {
        return activityMapper.selectActivityByConditionForPage(map);
    }

    @Override
    public int queryCountOfActivityForPage(Map<Object, Object> map) {
        return activityMapper.selectCountOfActivityForPage(map);
    }

    @Override
    public int deleteActivityByIds(String[] ids) {
        // 根据市场活动的ID删除所有的市场活动备注信息
        for (String id : ids) {
            activityRemarkService.deleteAllByActivityId(id);
        }
        // 再删除市场活动的ID
        return activityMapper.deleteActivityByIds(ids);
    }

    @Override
    public Activity queryActivityById(String id) {
        return activityMapper.selectActivityById(id);
    }

    @Override
    public int editActivity(Activity activity) {
        return activityMapper.updateActivity(activity);
    }

    @Override
    public List<Activity> queryActivityForExport(String[] ids) {
        return activityMapper.selectActivityForExport(ids);
    }

    @Override
    public List<Activity> queryActivityByClueId(String id) {
        return activityMapper.selectActivityByClueId(id);
    }

    @Override
    public List<Activity> queryActivityForFuzzy(Map map) {
        return activityMapper.selectActivityForFuzzy(map);
    }

    @Override
    public List<Activity> queryActivityFuzzyForConvert(Map map) {
        return activityMapper.selectActivityFuzzyForConvert(map);
    }

    @Override
    public List<Activity> queryActivityForFuzzyByContactsId(Map<String, String> map) {
        return activityMapper.selectAllNoRelationActivityInfoByContactsId(map);
    }

    @Override
    public List<Activity> findAllActivityInfoByContactsId(String contactsId) {
        return activityMapper.selectAllActivityInfoByContactsId(contactsId);
    }

    @Override
    public List<Activity> queryModifyActivityFuzzyForSave(String value, String contactsId) {
        return activityMapper.selectModifyActivityFuzzyForSave(value, contactsId);
    }


}
