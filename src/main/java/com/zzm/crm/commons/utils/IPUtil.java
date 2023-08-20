package com.zzm.crm.commons.utils;

import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * @author ZZX
 * @version 1.0.0
 * @date 2023:05:14 10:54:44
 */

public class IPUtil {
    public static boolean checkIp(String ipStr) {
        if("0:0:0:0:0:0:0:1".equals(ipStr)){
            return true;
        }
        String ip = "^(1\\d{2}|2[0-4]\\d|25[0-5]|[1-9]\\d|[1-9])\\."
                + "(00?\\d|1\\d{2}|2[0-4]\\d|25[0-5]|[1-9]\\d|\\d)\\."
                + "(00?\\d|1\\d{2}|2[0-4]\\d|25[0-5]|[1-9]\\d|\\d)\\."
                + "(00?\\d|1\\d{2}|2[0-4]\\d|25[0-5]|[1-9]\\d|\\d)$";
        Pattern pattern = Pattern.compile(ip);
        Matcher matcher = pattern.matcher(ipStr);
        return matcher.matches();
    }
}
