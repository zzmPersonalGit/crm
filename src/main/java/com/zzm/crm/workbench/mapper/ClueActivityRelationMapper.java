package com.zzm.crm.workbench.mapper;

import com.zzm.crm.workbench.pojo.ClueActivityRelation;

import java.util.List;

public interface ClueActivityRelationMapper {

    /**
     * 删除市场活动和线索的关联关系
     * @param clueActivityRelation
     * @return
     */
    int deleteByClueAndActivityId(ClueActivityRelation clueActivityRelation);

    /**
     * 插入市场活动和线索的关联关系，市场活动是批量的
     * @param list
     * @return
     */
    int insertClueActivityRelationByIds(List<ClueActivityRelation> list);

    /**
     * 根据线索的ID查询线索和市场活动的关联信息列表
     * @param id
     * @return
     */
    List<ClueActivityRelation> selectOriginByClueId(String id);

    /**
     * 删除线索和市场活动的关联关系
     * @param id
     * @return
     */
    int deleteRelationByClueId(String id);

}
