package com.zzm.crm.settings.service;


import com.zzm.crm.settings.pojo.DicValue;

import java.util.List;

public interface DicValueService {
    /**
     * 根据数据字典的类型来查询数据字典的列表
     * @param dicTypeCode
     * @return
     */
    List<DicValue> queryDicValueGroupByDicType(String dicTypeCode);
}
