package com.zzm.crm.workbench.service;

import com.zzm.crm.workbench.pojo.Clue;

import java.util.List;
import java.util.Map;


public interface ClueService {
    /**
     * 保存线索
     * @param row
     * @return
     */
    int saveClue(Clue row);

    /**
     * 根据ID查询线索
     * @param id
     * @return
     */
    Clue queryClueByPrimaryKey(String id);

    /**
     * 根据参数进行线索转换
     * @param map
     */
    void clueConvertByConvertBtn(Map<String,Object> map);

    /**
     * 根据参数查询线索的列表
     * @param map
     * @return
     */
    List<Clue> queryClueByConditionForPage(Map<Object, Object> map);

    /**
     * 根据参数查询线索的列表的总记录数
     * @param map
     * @return
     */
    int queryCountOfClueForPage(Map<Object, Object> map);

    /**
     * 批量删除线索
     * @param ids
     * @return
     */
    int deleteClueByIds(String[] ids);

    /**
     * 根据线索ID查询线索的信息
     * @param id
     * @return
     */
    Clue queryClueById(String id);

    /**
     * 更新线索的信息
     * @param clue
     * @return
     */
    int updateClueById(Clue clue);
}
