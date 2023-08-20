package com.zzm.crm.workbench.mapper;

import com.zzm.crm.workbench.pojo.Clue;

import java.util.List;
import java.util.Map;

public interface ClueMapper {
    /**
     * 根据ID删除线索信息
     * @param id
     * @return
     */
    int deleteDataByClueId(String id);

    /**
     * 插入线索
     * @param row
     * @return
     */
    int insertClue(Clue row);

    /**
     * 根据线索ID查询线索
     * @param id
     * @return
     */
    Clue selectClueByPrimaryKey(String id);

    /**
     * 更新线索的信息
     * @param row
     * @return
     */
    int updateByPrimaryKey(Clue row);

    /**
     * 根据线索ID得到线索信息
     * @param id
     * @return
     */
    Clue selectClueOfOriginDetailByPrimaryKey(String id);

    /**
     * 根据参数查询线索的列表
     * @param map
     * @return
     */
    List<Clue> selectClueByConditionForPage(Map<Object, Object> map);

    /**
     * 根据参数查询线索的列表的总记录数
     * @param map
     * @return
     */
    int selectCountOfClueForPage(Map<Object, Object> map);

    /**
     * 批量删除线索
     * @param ids
     * @return
     */
    int deleteBatchByIds(String[] ids);

    /**
     * 根据线索ID查询线索信息
     * @param id
     * @return
     */
    Clue selectById(String id);
}
