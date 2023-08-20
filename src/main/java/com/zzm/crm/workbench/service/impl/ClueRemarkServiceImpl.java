package com.zzm.crm.workbench.service.impl;

import com.zzm.crm.workbench.pojo.ClueRemark;
import com.zzm.crm.workbench.mapper.ClueRemarkMapper;
import com.zzm.crm.workbench.service.ClueRemarkService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@Transactional
public class ClueRemarkServiceImpl implements ClueRemarkService {
    @Autowired
    private ClueRemarkMapper clueRemarkMapper;

    @Override
    public int editByPrimaryKey(ClueRemark remark) {
        return clueRemarkMapper.updateByPrimaryKey(remark);
    }

    @Override
    public int deleteByPrimaryKey(String id) {
        return clueRemarkMapper.deleteByPrimaryKey(id);
    }

    @Override
    public int saveClueRemark(ClueRemark remark) {
        return clueRemarkMapper.insertClueRemark(remark);
    }

    @Override
    public List<ClueRemark> queryClueRemarkByClueId(String id) {
        return clueRemarkMapper.selectClueRemarkByClueId(id);
    }
}
