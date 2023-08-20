package com.zzm.crm.commons.utils;
import java.security.MessageDigest;

/**
 * @author ZZX
 * @version 1.0.0
 * @date 2023:05:05 16:12:02
 */
public class EncryptUtil {
    public static String encryptMD5(String data) {
        try {
            // 判断数据的合法性
            if (data == null) {
                throw new RuntimeException("数据不能为NULL");
            }
            // 获取MD5算法
            MessageDigest md5 = MessageDigest.getInstance("MD5");
            // 加入要获取摘要的数据
            md5.update(data.getBytes());
            // 获取数据的信息摘要
            byte[] resultBytes = md5.digest();
            // 将字节数组转化为16进制,取得原始长度
            return fromBytesToHex(resultBytes).substring(0,data.length());
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }

    /**
     * 将给定的字节数组，转化为16进制数据
     */
    private static String fromBytesToHex(byte[] resultBytes) {
        StringBuilder builder = new StringBuilder();
        for (byte resultByte : resultBytes) {
            if (Integer.toHexString(0xFF & resultByte).length() == 1) {
                builder.append("0").append(
                        Integer.toHexString(0xFF & resultByte));
            } else {
                builder.append(Integer.toHexString(0xFF & resultByte));
            }
        }
        return builder.toString();
    }
}
