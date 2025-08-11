/**
 * FunasDTO class
 * @author CloudMyBiz (r)
 * @date 15/06/2022
 * @description
 * @group 
 */

public with sharing class FunasDTO {

    public class FunasSetup {

        public FunasDTO.FunasEvent[] events { get; set; }
        public FunasDTO.FunasLineItem[] lineItems { get; set; }

        public String compounding { get; set; } //= 'TVMonthlyCompound';
        public String computeMethod { get; set; } //= 'TVUSRuleAmortization';
        public String roundingMethod { get; set; } //= 'TVRoundingBallonAddNewPayment';
        public Boolean isActive { get; set; } //= true;
        public Double nominalRate { get; set; } //= 0.11;
        public Integer versionNo { get; set; } //= 1;
        public String yearLength { get; set; } //= '365';
        public String targetObjectId { get; set; }
        public Boolean shouldPersistObjects { get; set; }
    
        public FunasSetup() {}

        public FunasSetup(funas__Amortization_Schedule_Setup__c amortizationScheduleSetup, List<funas__Amortization_Schedule_Event__c> events) {
            this.events = new List<FunasDTO.FunasEvent>();
            this.setFunasScheduleSetup(amortizationScheduleSetup);
            for(funas__Amortization_Schedule_Event__c event : events){
                this.events.add(new FunasEvent(event));
            }
        }

        private void setFunasScheduleSetup(funas__Amortization_Schedule_Setup__c amortizationScheduleSetup){
            this.yearLength = amortizationScheduleSetup.funas__Year_Length__c;
            this.roundingMethod = amortizationScheduleSetup.funas__Remaining_Amount_Rounding_Method__c;
            this.targetObjectId = amortizationScheduleSetup.funas__TargetObjectId__c;
            this.nominalRate = amortizationScheduleSetup.funas__Nominal_Rate__c == null ? null : (amortizationScheduleSetup.funas__Nominal_Rate__c / 100);
            this.yearLength = amortizationScheduleSetup.funas__Year_Length__c;
            this.isActive = amortizationScheduleSetup.funas__Is_Active__c;
            this.compounding = amortizationScheduleSetup.funas__Compounding__c;
            this.shouldPersistObjects = true;
        }
    }

    public class FunasEvent {
        public Integer eventNumber { get; set; }
        public Double amount { get; set; }
        public Date startDate { get; set; }
        public Integer numberOfRepeats { get; set; }
        public Date endDate { get; set; }
        public String eventType { get; set; }
        public String period { get; set; }
        public Double rateChange { get; set; }

        public FunasEvent () {}
        public FunasEvent (funas__Amortization_Schedule_Event__c event) {
            this.startDate = event.funas__Start_Date__c;
            this.eventType = event.funas__Event_Type__c;
            this.period = event.funas__Period__c;
            this.numberOfRepeats = event.funas__Number_of_Repeats__c?.intValue();
            this.amount = event.funas__Amount__c;
        }
    }

    public class FunasLineItem {
        public Double amount { get; set; }
        public Double balance   { get; set; }
        public Double asDate { get; set; }
        public Double interest { get; set; }
        public Double lineNumber { get; set; }
        public Double lineType { get; set; }
        public Double paymentAmount { get; set; }
        public Double principal { get; set; }
        public Double rate { get; set; }
        public Double settled { get; set; }

        public FunasLineItem () {}
    }

}