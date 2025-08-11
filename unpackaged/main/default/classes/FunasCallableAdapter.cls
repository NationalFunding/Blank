/**
 * FunasCallableAdapter class
 * @author CloudMyBiz (r)
 * @date 15/06/2022
 * @description
 * @group
 */

public class FunasCallableAdapter {

    Callable c;
    public Boolean loadClass(String classFullName){
        Boolean result = false;
        try{
             Type t = Type.forName(classFullName);
             c = (Callable) t.newInstance();
             result = true;
        }catch(Exception err){
            system.debug(err);
        }
        return result;
    }

    public Object call(String action, Map<String, Object> args){
        return c.call(action, args);
    }

    public Object call(String action, Object args){
        Map<String, Object> arguments = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(args));
        return call(action, arguments);
    }

    public static FunasCallableAdapter getController() {
        try {
            FunasCallableAdapter adapterController = new FunasCallableAdapter();
            adapterController.loadClass('funas.FUNASGlobalController');
            return adapterController;
        } catch (Exception ex) {
            throw new FunasException('Unable to load funas.FunasGlobalController, please make sure Funas Package v1.44 or later is installed.');
        }
    }

    public class FunasException extends Exception{}

}