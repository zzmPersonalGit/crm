package com.zzm.crm.settings.service.impl;

import com.zzm.crm.settings.service.DicValueService;
import com.zzm.crm.settings.mapper.DicValueMapper;
import com.zzm.crm.settings.pojo.DicValue;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Transactional
@Service
public class DicValueServiceImpl implements DicValueService {
    @Autowired
    private DicValueMapper dicValueMapper;
    @Override
    public List<DicValue> queryDicValueGroupByDicType(String dicTypeCode) {
        return dicValueMapper.selectDicValueGroupByDicType(dicTypeCode);
    }
}
