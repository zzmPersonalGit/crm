package com.zzm.crm.workbench.service.impl;

import com.zzm.crm.workbench.pojo.ActivityRemark;
import com.zzm.crm.workbench.service.ActivityRemarkService;
import com.zzm.crm.workbench.mapper.ActivityRemarkMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Transactional
@Service
public class ActivityRemarkServiceImpl implements ActivityRemarkService {

    @Autowired
    private ActivityRemarkMapper activityRemarkMapper;

    @Override
    public List<ActivityRemark> queryDetailByActivityId(String id) {
        return activityRemarkMapper.selectDetailByActivityId(id);
    }

    @Override
    public int saveActivityRemark(ActivityRemark activityRemark) {
        return activityRemarkMapper.insertActivityRemark(activityRemark);
    }

    @Override
    public int deleteByPrimaryKey(String id) {
        return activityRemarkMapper.deleteByPrimaryKey(id);
    }

    @Override
    public void deleteAllByActivityId(String id) {
        activityRemarkMapper.deleteByActivityId(id);
    }

    @Override
    public int editByPrimaryKey(ActivityRemark activityRemark) {
        return activityRemarkMapper.updateByPrimaryKey(activityRemark);
    }
}
