/**
 * InterestAccrualsSelector class
 * @author CloudMyBiz (r)
 * @date 9/6/2022
 * @description
 * @group 
 */

public inherited sharing class InterestAccrualsSelector{

    public static Map<Id, Decimal> getSumInterestAccrualsByRepayment(Set<Id> repaymentIds){
        Map<Id, Decimal> output = new Map<Id, Decimal>();
        AggregateResult[] records = [
            SELECT SUM(cmbls__Interest_Amount_for_Principal_for_Period__c) total, cmbls__Repayment__c repayment
            FROM cmbls__InterestAccrual__c
            WHERE cmbls__Repayment__c IN :repaymentIds
            GROUP BY cmbls__Repayment__c
        ];
        for(AggregateResult item :records) output.put((Id)item.get('repayment'), (Decimal)item.get('total'));
        return output;
    }
}