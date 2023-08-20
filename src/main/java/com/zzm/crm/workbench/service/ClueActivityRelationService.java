package com.zzm.crm.workbench.service;

import com.zzm.crm.workbench.pojo.ClueActivityRelation;

import java.util.List;

public interface ClueActivityRelationService {
    /**
     * 保存市场活动和线索的关联关系，市场活动是批量的
     * @param list
     * @return
     */
    int saveClueActivityRelationByIds(List<ClueActivityRelation> list);

    /**
     * 解除市场活动和线索的关联关系
     * @param clueActivityRelation
     * @return
     */
    int deleteByClueAndActivityId(ClueActivityRelation clueActivityRelation);

    /**
     * 根据线索ID查看是否关联过市场活动
     * @param clueId
     * @return
     */
    List<ClueActivityRelation> queryIsRelation(String clueId);
}
