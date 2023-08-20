package com.zzm.crm.workbench.mapper;

import com.zzm.crm.workbench.pojo.ClueRemark;

import java.util.List;

public interface ClueRemarkMapper {
    /**
     * 删除线索的备注信息
     * @param id
     * @return
     */
    int deleteDataByClueId(String id);

    /**
     * 编辑线索备注
     * @param row
     * @return
     */
    int updateByPrimaryKey(ClueRemark row);

    /**
     * 查询线索的备注列表
     * @param id
     * @return
     */
    List<ClueRemark> selectClueRemarkByClueId(String id);

    /**
     * 根据线索的ID查询线索的备注信息
     * @param id
     * @return
     */
    List<ClueRemark> selectClueForOriginByClueId(String id);

    /**
     * 保存线索的备注
     * @param remark
     * @return
     */
    int insertClueRemark(ClueRemark remark);

    /**
     * 删除线索信息
     * @param id
     * @return
     */
    int deleteByPrimaryKey(String id);

    /**
     * 根据线索ID删除相关的备注信息
     * @param id
     */
    void deleteByClueId(String id);
}
