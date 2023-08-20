package com.zzm.crm.settings.mapper;

import com.zzm.crm.settings.pojo.DicValue;
import java.util.List;

public interface DicValueMapper {
    /**
     * 根据数据类型的类型来查询数据类型的列表
     * @param dicTypeCode
     * @return
     */
    List<DicValue> selectDicValueGroupByDicType(String dicTypeCode);
}
