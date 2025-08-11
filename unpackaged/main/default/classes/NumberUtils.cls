/**
 * NumberUtils class
 * @author CloudMyBiz (r)
 * @date 05/07/2022
 * @description
 * @group 
 */

public with sharing class NumberUtils {

    public static Integer getInteger(Decimal value){
        if(value == null) return 0;
        try{
            return Integer.valueOf(value);
        }catch (Exception ex){
            return 0;
        }
    }

    public static Decimal getDecimal(Decimal val){
        return val == null ? 0 : val;
    }

}