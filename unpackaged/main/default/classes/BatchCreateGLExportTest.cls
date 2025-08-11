/**
 * BatchCreateGLExportTest class
 * @author CloudMyBiz (r)
 * @date 5/30/2023
 */

@IsTest
private class BatchCreateGLExportTest{
    
    @TestSetup static void setupMethod(){
        Test.startTest();
        insert new cmbls__GL_Transaction__c[]{
            new cmbls__GL_Transaction__c(cmbls__Date__c = System.today()),
            new cmbls__GL_Transaction__c(cmbls__Date__c = System.today()),
            new cmbls__GL_Transaction__c(cmbls__Date__c = System.today()),
            new cmbls__GL_Transaction__c(cmbls__Date__c = System.today())
        };
        
        Test.stopTest();
    }
    
    @IsTest
    static void behavior(){
        Test.startTest();
        Id jobId = Database.executeBatch(new BatchCreateGLExport());
        Test.stopTest();
        Assert.areEqual(1, [SELECT COUNT() FROM cmbls__GP_Batch__c WHERE Batch_Related_Id__c = :jobId AND cmbls__Status__c = 'Success']);
        Assert.areEqual(0, [SELECT COUNT() FROM cmbls__GL_Transaction__c WHERE cmbls__GP_Batch__c = NULL AND cmbls__Sent_to_GP__c = NULL]);
    }
    
    @IsTest
    static void schedule(){
        Test.startTest();
        String CRON_EXP = '0 0 23 * * ?';
        System.schedule('BatchCreateGLExport TEST', CRON_EXP, new BatchCreateGLExport());
        Test.stopTest();
    }
}