package com.zzm.crm.workbench.service;

import com.zzm.crm.workbench.pojo.ClueRemark;

import java.util.List;

public interface ClueRemarkService {
    /**
     * 查询线索的备注信息
     * @param id
     * @return
     */
    List<ClueRemark> queryClueRemarkByClueId(String id);

    /**
     * 保存线索的备注
     * @param remark
     * @return
     */
    int saveClueRemark(ClueRemark remark);

    /**
     * 根据ID删除备注信息
     * @param id
     * @return
     */
    int deleteByPrimaryKey(String id);

    /**
     * 编辑线索备注
     * @param remark
     * @return
     */
    int editByPrimaryKey(ClueRemark remark);
}
