public with sharing class oppGMCalcUtil {

    public static list<string> summary;
    
    public oppGMCalcUtil(Opportunity[] opps){
        calculate(opps,queryAccounts(collectLenderAccountIds(opps)));
        
        debug();
    }
    
    /**
    * Query accounts for opportunities.
    */
    private static  Set<Id> collectLenderAccountIds(Opportunity[] opps){        
        Set<Id>ret; 
        for(Opportunity opp : opps){
            if(opp.Lender_Account__c != null){
                if(ret==null)
                ret = new Set<Id>();
                ret.add(opp.Lender_Account__c);
            }
        }
        
        return ret;
    }
    
    /**
    * Build map of accounts.
    */ 
    private static Map<Id,Account> queryAccounts(Set<Id> ids){
        Map<Id,Account> ret;
        
        if(ids!=null){
            ret = new Map<Id,Account>();
            
            // 6/28 walter - get the account and the child records for Lender_Lost_Margin__c, FPC_Lender_Split_Points__c
            
            for(Account acct : [Select Id,Lender_Max_Points__c,Lender_Interest_Settlement_Criteria__c, Lender_Discount_Number_of_Payments__c, Lender_Computation__c, Lender_Charge_Interim_Rent__c, Actuals_Split_Points_High__c, Actuals_Split_Points_Low__c, Lender_Interest_Settlement_Start__c, 
            (Select Id, IsDeleted, Name, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, Account__c, Lost_Margin_Criteria__c, Rate__c, Low_Dollar_Lost_Margin__c, High_Dollar_Lost_Margin__c, Max_Points__c 
            From Lender_Lost_Margin__r), 
            (Select Id, IsDeleted, Name, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, Account__c, Split_Points_Criteria__c, Rate__c, Low_Equipment_Cost__c, High_Equipment_Cost__c, Split_Points_High__c, Split_Points_Low__c 
            From FPC_Lender_Split_Points__r)
            From Account where id =:ids])
            {
                System.debug('@@@@@@@ VALUE CHECK LENDRE'+acct);
                ret.put(acct.id,acct);
            }
        }
        return ret;
    }
    
    /**
    * Calculate.
    */
    private static void calculate(Opportunity[] opps,Map<Id,Account> accountsMap){
        for(Opportunity aOpp : opps){           
            Account lender = accountsMap.get(aOpp.Lender_Account__c);
            System.debug('!!!!LENDER VALUE'+lender);
            System.debug('!!!!Opps  VALUE'+aOpp);
            // One summary for all calculations for each opportunity
            summary = new list<string>();
                    
            if(aOpp.Actual_Buy_Rate__c==null)
                aOpp.Actual_Buy_Rate__c = 0;
            
            if(aOpp.Actual_Equip_Cost__c==null)
                aOpp.Actual_Equip_Cost__c = 0.00;

            calcDiscountTermForActual(aOpp);            
            calcInterestSettlementDaysForActual(aOpp, lender);
            calcDiscountPv(aOpp,lender);    
            
            
            // 5/12 - walter - was not found in original        
            calcSplitMargin(aOpp,lender);

            // 5/28/12 walter - found this was never turned on in my version
            calcLostMargin(aOpp,lender);
            
            calcIntSettlementForActual(aOpp,lender);
            
            calcNetProceedsForActual(aOpp,lender);
            calcDifferenceForActual(aOpp);  
            
            // 5/28/12 walter - found this was never turned on in my version
            calcAdvancedPayments(aOpp,lender);
                        
            calcActualFpcMargin(aOpp,lender);   
            calcNetMarginForActual(aOpp);           
            calcInterimRent(aOpp,lender);                          

            // ACTUAL_AMT_OFFERED__c
            // Double margin = (UtilityTools.getDoubleValFromDecimal(aOpp.Actual_FPC_Margin__c))*100/15;
            // aOpp.ACTUAL_AMT_OFFERED__c = String.valueOf(margin);
                
            aOpp.FlagToClickCalculateActuals__c = false;
        }
    }

    /**
    * Discounted_Term_For_Actual__c
    * 
    * If [Num Discounted Pmts] > 0 then [Term] –[Num Discounted Pmts] else [Term]
    */
    static void calcDiscountTermForActual(Opportunity aOpp){
        if(aOpp.Num_Discounted_Pmts_For_Actual__c>0){
            aOpp.Discounted_Term_For_Actual__c = aOpp.Actual_Term__c - aOpp.Num_Discounted_Pmts_For_Actual__c;
        }else{
            aOpp.Discounted_Term_For_Actual__c = aOpp.Actual_Term__c;
        }
        System.debug('aOpp.Num_Discounted_Pmts_For_Actual__c is [' + aOpp.Num_Discounted_Pmts_For_Actual__c +']');
        System.debug('aOpp.Actual_Term__c is [' + aOpp.Actual_Term__c +']');
        System.debug('aOpp.Num_Discounted_Pmts_For_Actual__c is [' + aOpp.Num_Discounted_Pmts_For_Actual__c +']');
        System.debug('aOpp.Discounted_Term_For_Actual__c is [' + aOpp.Discounted_Term_For_Actual__c +']');
        summary.add('aOpp.Discounted_Term_For_Actual__c is [' + aOpp.Discounted_Term_For_Actual__c +']');   
    }
    
    /**
    * Interest_Settlement_Days_For_Actual__c
    *
    * [Commencement Date] – [Fund Date]
    
    */
    
   /* static void calcInterestSettlementDaysForActual(Opportunity aOpp){
        if(aOpp.Commencement_Date_For_Actual__c!=null && aOpp.Fund_Date_For_Actual__c!=null)
           aOpp.Interest_Settlement_Days_For_Actual__c = aOpp.Fund_Date_For_Actual__c.date().daysBetween(aOpp.Commencement_Date_For_Actual__c.date());
        System.debug('aOpp.Interest_Settlement_Days_For_Actual__c is [' +  aOpp.Interest_Settlement_Days_For_Actual__c +']');
        summary.add('aOpp.Interest_Settlement_Days_For_Actual__c is [' +  aOpp.Interest_Settlement_Days_For_Actual__c +']');        
    }*/      //  [Commented By Archana(25/9/2012)]
    
    static void calcInterestSettlementDaysForActual(Opportunity aOpp, Account lender){
        if (aOpp.Fund_Date_For_Actual__c != null)  {
            if(aOpp.Commencement_Date_For_Actual__c!=null && lender.Lender_Interest_Settlement_Start__c == 'Fund Date - 1'){
                aOpp.Interest_Settlement_Days_For_Actual__c = (aOpp.Fund_Date_For_Actual__c.date().daysBetween(aOpp.Commencement_Date_For_Actual__c.date()))-1;
            }
            else { aOpp.Interest_Settlement_Days_For_Actual__c = (aOpp.Fund_Date_For_Actual__c.date().daysBetween(aOpp.Commencement_Date_For_Actual__c.date())); }
            System.debug('aOpp.Interest_Settlement_Days_For_Actual__c is [' +  aOpp.Interest_Settlement_Days_For_Actual__c +']');
            summary.add('aOpp.Interest_Settlement_Days_For_Actual__c is [' +  aOpp.Interest_Settlement_Days_For_Actual__c +']');        
        }
    } 
            
    /**
    * PRESENT VALUE - walter
    *
    * http://en.wikipedia.org/wiki/Time_value_of_money
    * 
    * The formula below calculates the current value of a stream of equal payments made at regular intervals over a specified period of time. 
    * This value is referred to as the present value (PV) of an annuity.
    *
    * Equiv to excel as: PV(rate,num compound payments,payment amount);
    *
    * @double pmt = periodic payment amount / - monthly payment
    * @double i = interest rate / actual buy rate
    * @integer n = number of componding periods / (lease term - # advanced payments)
    *
    * @return string pv = present value
    */
    public static double getJavaPVa(decimal p,decimal io,integer n){        
        double pmt = UtilityTools.getDoubleValFromDecimal(p);
        double i = UtilityTools.getDoubleValFromDecimal(io);
        double v = math.pow((1 + i),-n);
        double pv = pmt*(1-v)/i;
        system.debug('Present Value: ' +pv);
        return pv;
    }
    
    /*
    * Discount Present Value.
    *
    * IF LENDER.[Computation] = “Lease Rate Factor” THEN
    * [Discount PV] = [Monthly Payment] / [Buy Rate];  - Currently Functional
    * ELSE
    * [PVBuyRate] = [Buy Rate]/12;      // Variable to make the formula readable
    * [Discount PV] = [Monthly Payment]*((1+[PVBuyRate])^[Discounted Term]-1)/(([PVBuyRate])*(1+[PVBuyRate])^[Discounted Term]);
    * END IF;
    */
    static void calcDiscountPv(Opportunity aOpp,Account lender){
        // aOpp.Discount_PV_Overwrite__c
        // True = User overwrites the PV and remainder of calcs are executed based on user input value.  False = Trigger runs all calculations including PV.
        if(!aOpp.Discount_PV_Overwrite__c){
            if(lender!=null)
                if(lender.Lender_Computation__c=='Lease Rate Factor'){
                    if(aOpp.Actual_Buy_Rate__c!=0) // remove divide 100 for Actual_Buy_Rate__c 
                    aOpp.Discount_PV_For_Actual__c = UtilityTools.getDoubleValFromDecimal(aOpp.Actual_Monthly_Payment__c)/UtilityTools.getDoubleValFromDecimal(aOpp.Actual_Buy_Rate__c);
                }else{
                    // this logic block includes lender.Lender_Computation__c == "Buy Rate Percentage" as an example
                    
                    // 5/2012 change - when calculating the percentage for interest
                    // the actual buy rate is entered as 14.00000 , which is %1400, so we do 1400 / 100 to get 14 or %14
                    Decimal buyRate = aOpp.Actual_Buy_Rate__c / 100;
                    
                    Double PVBuyRate = UtilityTools.getDoubleValFromDecimal(buyRate)/(12);
                    
                    if(PVBuyRate!=0)//{
                        aOpp.Discount_PV_For_Actual__c = UtilityTools.getDoubleValFromDecimal(aOpp.Actual_Monthly_Payment__c) * (Math.pow(UtilityTools.getDoubleValFromDecimal(1+PVBuyRate), UtilityTools.getDoubleValFromDecimal(aOpp.Discounted_Term_For_Actual__c))-1)/(PVBuyRate *  Math.pow(UtilityTools.getDoubleValFromDecimal(1+PVBuyRate), UtilityTools.getDoubleValFromDecimal(aOpp.Discounted_Term_For_Actual__c)));
                    //}else{
                    //  aOpp.addError('The Actual Buy Rate is required to Calculate Actuals (Discount PV).  Please enter an Actual Buy Rate value');
                    //  return;
                    //}
                                
                    // another method to test the discountPv calc...
                    // Double rate = UtilityTools.getDoubleValFromDecimal(aOpp.Actual_Buy_Rate__c)/(12);
                    // Double periodicPaymentAmount = UtilityTools.getDoubleValFromDecimal(aOpp.Actual_Monthly_Payment__c);                 
                    // Integer numPayments = Integer.valueOf((aOpp.Actual_Term__c-aOpp.Num_Discounted_Pmts_For_Actual__c));
                    // aOpp.Discount_PV_For_Actual__c = getJavaPva(periodicPaymentAmount,rate,numPayments);
                }
        }                   
            
        summary.add('aOpp.Discount_PV_For_Actual__c is ['+aOpp.Discount_PV_For_Actual__c+']');
    }
    
    /**
    * Split Margin.
    *
    * IF ([Discount PV] – [Equip Cost]) > (LENDER.[Split Points Low] * [Equip Cost])
    * AND ([Discount PV] – [Equip Cost]) > (LENDER.[Split Points High] * [Equip Cost]) THEN
    * (
    * IF ([Discount PV] – [Equip Cost]) > (LENDER.[Split Points High] * [Equip Cost]) THEN
    * [Split Margin] = ((LENDER.[Split Points High] * [Equip Cost]) - (LENDER.[Split Points Low] * [Equip Cost])) / 2;
    * ELSE
    * [Split Margin] = (([Discount PV] * [Equip Cost]) - (LENDER.[Split Points Low] * [Equip Cost])) / 2;
    * )
    */  
    static void calcSplitMargin(Opportunity aOpp,Account lender){
        
        Decimal discountPv = aOpp.Discount_PV_For_Actual__c;
        Decimal equipCost = aOpp.Actual_Equip_Cost__c;

        // 6/28 walter - get the low and high split points from the child object FPC_Lender_Split_Points__c instead of a field on the lender/account
        //Decimal splitPointsHigh = lender.actuals_split_points_high__c;
        //Decimal splitPointsLow = lender.actuals_split_points_low__c;
        Decimal splitPointsHigh;
        Decimal splitPointsLow;
        
        for(FPC_Lender_Split_Points__c f : lender.FPC_Lender_Split_Points__r){
            
            system.debug('Split Margin: processing... ' +f.id);
            system.debug('Split Margin: equipCost... ' +equipCost);
            system.debug('Split Margin: f.Low_Equipment_Cost__c... ' +f.Low_Equipment_Cost__c);
            system.debug('Split Margin: f.Low_Equipment_Cost__c... ' +f.High_Equipment_Cost__c);
            
            // if Opportunity equipment cost is within the high and low equipment cost range
            if( (equipCost >= f.Low_Equipment_Cost__c) && (equipCost <= f.High_Equipment_Cost__c) ){
            
                system.debug('Split Margin: (equipCost > f.Low_Equipment_Cost__c) && (equipCost < f.High_Equipment_Cost__c) ... TRUE');
                
                // get the low and high split points
                splitPointsLow = f.Split_Points_Low__c;
                splitPointsHigh = f.Split_Points_High__c;
            
            }else{
                system.debug('Split Margin: (equipCost > f.Low_Equipment_Cost__c) && (equipCost < f.High_Equipment_Cost__c) ... FALSE');
            }           
        }
        
        if(discountPv==null)
            discountPv = 0.0;
        if(splitPointsHigh==null)
            splitPointsHigh = 0.0;
        if(splitPointsLow==null)
            splitPointsLow = 0.0;
        if(equipCost==null)
            equipCost = 0.0;            
        if(splitPointsHigh != null)
            splitPointsHigh = splitPointsHigh/100;      
        if(splitPointsLow != null)
            splitPointsLow = splitPointsLow/100;
            
        system.debug('Split Margin: discountPv is ' +discountPv);
        system.debug('Split Margin: equipCost is ' +equipCost);
        system.debug('Split Margin: splitPointsHigh is ' +splitPointsHigh);
        system.debug('Split Margin: splitPointsLow is ' +splitPointsLow);
    
        system.debug('Split Margin: (discountPv - equipCost) is  ' +(discountPv - equipCost));  
        system.debug('Split Margin: (splitPointsLow * equipCost) is ' +(splitPointsLow * equipCost));       
        system.debug('Split Margin: (splitPointsHigh * equipCost) is ' +(splitPointsHigh * equipCost));     
        
        // 7/13 travis change
        //if(((discountPv - equipCost) > (splitPointsLow * equipCost)) && ((discountPv - equipCost) < (splitPointsHigh * equipCost))){      
        if(((discountPv - equipCost) > (splitPointsLow * equipCost)) || ((discountPv - equipCost) > (splitPointsHigh * equipCost))){            
            system.debug('Split Margin Logic Block 1');
            
            if((discountPv - equipCost) > (splitPointsHigh * equipCost)){
                system.debug('Split Margin Logic Block 2');
                
                aOpp.Actual_Split_Margin__c = ( (splitPointsHigh * equipCost) - (splitPointsLow * equipCost)) / 2;
            }else{
                system.debug('Split Margin Logic Block 3');
                
                // 7/13 travis change
                //aOpp.Actual_Split_Margin__c = ((discountPv * equipCost) - (splitPointsLow * equipCost)) / 2;
                  aOpp.Actual_Split_Margin__c = ((discountPv - equipCost) - (splitPointsLow * equipCost)) / 2;
            }
        } 
        
        // if we end up with no value set it to zero
        if(aOpp.Actual_Split_Margin__c == null)
            aOpp.Actual_Split_Margin__c = 0.0;
                
        summary.add('aOpp.Actual_Split_Margin__c is ['+aOpp.Actual_Split_Margin__c+']');
        system.debug('Split Margin: Opp Actual Split Margin is ' +aOpp.Actual_Split_Margin__c);
    }
    
    /**
    * Lost Margin.  
    *
    * IF ([Discount PV] – [Equip Cost]) > (LENDER.[Max Points] * [Equip Cost]) THEN
    * [Lost Margin] = ([Discount PV]-[Equip Cost])-(LENDER.[Max Points]*[Equip Cost]);
    * ELSE
    * [Lost Margin] = 0;
    * END IF;
    */
    static void calcLostMargin(Opportunity aOpp,Account lender){
        
        Decimal equipCost = aOpp.Actual_Equip_Cost__c;
        
        // 6/28 walter - get the max points from the child record FPC_Lost_Margin__c
        //Decimal maxPoints = lender.Lender_Max_Points__c;      
        Decimal maxPoints;      
        
        for(FPC_Lost_Margin__c f : lender.Lender_Lost_Margin__r){
            system.debug('Lost Margin: lender.Lender_Lost_Margin__r... ' +f);
            system.debug('Lost Margin: equipCost... ' +equipCost);
            system.debug('Lost Margin: f.Low_Dollar_Lost_Margin__c... ' +f.Low_Dollar_Lost_Margin__c);
            system.debug('Lost Margin: f.High_Dollar_Lost_Margin__c... ' +f.High_Dollar_Lost_Margin__c);
                        
            // if Opportunity equipment cost is within the low dollar and high dollar range
            if((equipCost >= f.Low_Dollar_Lost_Margin__c) && (equipCost <= f.High_Dollar_Lost_Margin__c)){
                system.debug('(equipCost > f.Low_Dollar_Lost_Margin__c) && (equipCost < f.High_Dollar_Lost_Margin__c)... TRUE');
                maxPoints = f.Max_Points__c;
                break;
            }else{
                system.debug('(equipCost > f.Low_Dollar_Lost_Margin__c) && (equipCost < f.High_Dollar_Lost_Margin__c)... FALSE');
            }
        }       
        
        if(maxPoints==null)
            maxPoints=0;
        
        if(aOpp.Discount_PV_For_Actual__c==null)
            aOpp.Discount_PV_For_Actual__c =0;
            
        if(lender!=null){
            if((aOpp.Discount_PV_For_Actual__c - equipCost)>((maxPoints/100) * equipCost)){
                aOpp.Lost_Margin_For_Actual__c = aOpp.Discount_PV_For_Actual__c - equipCost - (maxPoints/100)* equipCost;
            }else{
                aOpp.Lost_Margin_For_Actual__c = 0;
            }
        }
       
        System.debug('aOpp.Discount_PV_For_Actual__c is [' +  aOpp.Discount_PV_For_Actual__c +']');
        System.debug('equipCost is [' +  equipCost +']');
        System.debug('maxPoints is [' +  maxPoints +']');
        System.debug('aOpp.Discount_PV_For_Actual__c - equipCost is [' +  (aOpp.Discount_PV_For_Actual__c - equipCost) +']');
        System.debug('(maxPoints/100) * equipCost is [' +  (maxPoints/100) * equipCost +']');
        summary.add('aOpp.Lost_Margin_For_Actual__c is ['+aOpp.Lost_Margin_For_Actual__c+']');
    }
    
    /**
    * Int. Settlement.
    *
    * SELECT CASE LENDER.[Interest Settlement Criteria]
    * CASE “None”
    * [Int. Settlement] = 0;
    * CASE “Equipment Cost”
    * [Int. Settlement] = ([Buy Rate]/365*[Equip Cost]*[Interest Settlement Days]);
    * CASE “Stream Minus Lost/Split”  
    * [Int Settlement] =(([BuyRate]/365)*([Discount PV]-[Split Margin]-[Lost Margin])*[Interest Settlement Days]);
    * END SELECT CASE;
    */
   /* static void calcIntSettlementForActual(Opportunity aOpp,Account lender){
        if(lender!=null)
            if(lender.Lender_Interest_Settlement_Criteria__c == 'None'){
                aOpp.Int_Settlement_For_Actual__c = 0;
            }else if(lender.Lender_Interest_Settlement_Criteria__c == 'Equipment Cost'){
                aOpp.Int_Settlement_For_Actual__c = (aOpp.Actual_Buy_Rate__c/365) * aOpp.Actual_Equip_Cost__c * aOpp.Interest_Settlement_Days_For_Actual__c;
            }else if(lender.Lender_Interest_Settlement_Criteria__c == 'Stream Minus Lost'){
                aOpp.Int_Settlement_For_Actual__c = (aOpp.Actual_Buy_Rate__c/365) * (aOpp.Discount_PV_For_Actual__c  - aOpp.Lost_Margin_For_Actual__c) * aOpp.Interest_Settlement_Days_For_Actual__c;
            }else{
                aOpp.Int_Settlement_For_Actual__c = UtilityTools.getDoubleValFromDecimal(aOpp.Int_Settlement_For_Actual__c);
            }
    
        System.debug('aOpp.Int_Settlement_For_Actual__c is [' +  aOpp.Int_Settlement_For_Actual__c +']');
        summary.add('aOpp.Int_Settlement_For_Actual__c is [' +  aOpp.Int_Settlement_For_Actual__c +']');
    }*/  // [Commented By Archana(25/9/2012)]
    
    static void calcIntSettlementForActual(Opportunity aOpp,Account lender){
        if(lender!=null)
            if(lender.Lender_Interest_Settlement_Criteria__c == 'None'){
                aOpp.Int_Settlement_For_Actual__c = 0;
            }else if(lender.Lender_Interest_Settlement_Criteria__c == 'Equipment Cost'){
                aOpp.Int_Settlement_For_Actual__c = ((aOpp.Actual_Buy_Rate__c/100)/365) * (aOpp.Actual_Equip_Cost__c * aOpp.Interest_Settlement_Days_For_Actual__c);
            }else if(lender.Lender_Interest_Settlement_Criteria__c == 'Stream Minus Lost'){
                aOpp.Int_Settlement_For_Actual__c = (((aOpp.Actual_Buy_Rate__c/100)/365) * (aOpp.Discount_PV_For_Actual__c - aOpp.Actual_Split_Margin__c - aOpp.Lost_Margin_For_Actual__c) * aOpp.Interest_Settlement_Days_For_Actual__c);
            }else if(lender.Lender_Interest_Settlement_Criteria__c == 'Half of Interim Rent'){
                aOpp.Int_Settlement_For_Actual__c = (aOpp.Actual_Monthly_Payment__c /30 * aOpp.Interest_Settlement_Days_For_Actual__c) / 2;
            }
            // Half of Interim Rent criteria added by TR on 11/26/14.  Assigns half of interim rent as Interest Settlement.  Calculation provided by S.Bowlin. 
            
            else{
                aOpp.Int_Settlement_For_Actual__c = UtilityTools.getDoubleValFromDecimal(aOpp.Int_Settlement_For_Actual__c);
            }
    
        System.debug('aOpp.Int_Settlement_For_Actual__c is [' +  aOpp.Int_Settlement_For_Actual__c +']');
        summary.add('aOpp.Int_Settlement_For_Actual__c is [' +  aOpp.Int_Settlement_For_Actual__c +']');
    }
    
    /**
    * Net Proceeds. What we expect to make from the Lender.
    *
    * [Calc Net Proceeds] = [Discount PV] – [Int Settlement] – [Lender Doc Fee] –[Fee 1 Amount] – [Fee 2 Amount] – [Split Margin] – [Lost Margin] – [Equip Cost]
    */  
    static void calcNetProceedsForActual(Opportunity aOpp,Account lender){
        if(aOpp.Lender_Doc_Fee_For_Actual__c==null)
            aOpp.Lender_Doc_Fee_For_Actual__c = 0;
        if(aOpp.Int_Settlement_For_Actual__c==null)
            aOpp.Int_Settlement_For_Actual__c = 0;
        if(aOpp.Actual_Fee_1_Amt__c==null)
            aOpp.Actual_Fee_1_Amt__c = 0;
        if(aOpp.Actual_Fee_2_Amt__c==null)
            aOpp.Actual_Fee_2_Amt__c = 0;
        if(aOpp.Lost_Margin_For_Actual__c==null)
            aOpp.Lost_Margin_For_Actual__c = 0;
        if(aOpp.Actual_Equip_Cost__c==null)
            aOpp.Actual_Equip_Cost__c = 0;
        if(aOpp.Lender_Prefund_Fee__c == null)
            aOpp.Lender_Prefund_Fee__c = 0;
            
        // original
        //aOpp.Calc_Net_Proceeds_For_Actual__c = aOpp.Discount_PV_For_Actual__c - aOpp.Int_Settlement_For_Actual__c - aOpp.Lender_Doc_Fee_For_Actual__c - aOpp.Actual_Fee_1_Amt__c - aOpp.Actual_Fee_2_Amt__c - aOpp.Lost_Margin_For_Actual__c  - aOpp.Actual_Equip_Cost__c;
        
        // updated - walter
        // updated - Travis - Modify Calc Net Proceeds to include Lender Prefund fee as requested by Sarah Bowlin. new Formula is: Calc Net Proceeds = Disount PV - Interest Settlement - Lender Doc Fee - Actual Fee Amount 1 - Actual Fee Amount 2 - Actual Split Margin - Actual Lost Margin - Lender Prefund Fee - Actual Equipment Cost
        aOpp.Calc_Net_Proceeds_For_Actual__c = aOpp.Discount_PV_For_Actual__c - aOpp.Int_Settlement_For_Actual__c - aOpp.Lender_Doc_Fee_For_Actual__c - aOpp.Actual_Fee_1_Amt__c - aOpp.Actual_Fee_2_Amt__c - aOpp.Actual_Split_Margin__c - aOpp.Lost_Margin_For_Actual__c - aOpp.Lender_Prefund_Fee__c - aOpp.Actual_Equip_Cost__c;                                        
                                                    
        System.debug('aOpp.Calc_Net_Proceeds_For_Actual__c is [' +  aOpp.Calc_Net_Proceeds_For_Actual__c +']');
        summary.add('aOpp.Calc_Net_Proceeds_For_Actual__c is [' +  aOpp.Calc_Net_Proceeds_For_Actual__c +']');
    }
    
    /**
    * Difference.
    *
    * [Calc Net Proceeds] – [Actual Proceeds]
    */
    static void calcDifferenceForActual(Opportunity aOpp){
        if(aOpp.Calc_Net_Proceeds_For_Actual__c==null)
            aOpp.Calc_Net_Proceeds_For_Actual__c = 0;
        if(aOpp.Actual_Proceeds_For_Actual__c==null)
            aOpp.Actual_Proceeds_For_Actual__c = 0; 
        
        aOpp.Difference_For_Actual__c = aOpp.Calc_Net_Proceeds_For_Actual__c -aOpp.Actual_Proceeds_For_Actual__c;
        System.debug('aOpp.Difference_For_Actual__c is [' +  aOpp.Difference_For_Actual__c +']');
        summary.add('aOpp.Difference_For_Actual__c is [' +  aOpp.Difference_For_Actual__c +']');
    }
    
    /**
    * Advanced Payments.
    *   
    * IF LENDER.[Discount # Of Pmts] > 0 THEN
    * [Discount # Pmts] * [Monthly Pmt];
    * ELSE
    * 0;
    * END IF
    */
    
    /* 5/30/12
    * Clarified Version:
    * Advanced Payments (Oppurtunity.Advanced_Payments_For_Actual__c) = 
    * If(Lender Account.Lender_Discount_Number_of_Payments__c > 0, Opportunity.Num_Discounted_Pmts_For_Actual__c *Opportunity.Actual_Monthly_Payment__c, 0)
    */
    static void calcAdvancedPayments(Opportunity aOpp,Account lender){
        if( aOpp.Actual_Monthly_Payment__c==null)
             aOpp.Actual_Monthly_Payment__c=0;
             
        if(lender.Lender_Discount_Number_of_Payments__c > 0){
            
            // old
            //aOpp.Advanced_Payments_For_Actual__c = lender.Lender_Discount_Number_of_Payments__c * aOpp.Actual_Monthly_Payment__c;
            
            // 5/30/12 - travis updated
            aOpp.Advanced_Payments_For_Actual__c = aOpp.Num_Discounted_Pmts_For_Actual__c * aOpp.Actual_Monthly_Payment__c;
            
        }else{
            aOpp.Advanced_Payments_For_Actual__c = 0;
        }   
                
        summary.add('aOpp.Advanced_Payments_For_Actual__c is [' +  aOpp.Advanced_Payments_For_Actual__c +']');
    }
    
    /**
    * FPC Margin. 
    *
    * 5/24/12 David Vahdat
    * [Calc Net Proceeds] + [Doc Fee Collected] + [Advanced Payments]
    */
        
    /**
    * Clarified: FPC Margin(Oppty.FPC_Margin_For_Actual__c) = 
    * Calc Net Proceeds (Oppty.Calc_Net_Proceeds_For_Actual__c) + Doc Fee Collected(Oppty.Doc_Fee_Collected__c) + Advanced Payments(Oppty.Advanced_Payments_For_Actual__c)
    */
    static void calcActualFpcMargin(Opportunity aOpp,Account lender){
        
        // 5/24/12 remove original...
        // 12 Actual_FPC_Margin__c
        // SELECT   CASE LENDER.[Computation Method]
        //      CASE “Amount Offered”
        //          [Amount  Offered] * [Commission to FPC] ;
        //      CASE “Amount Collected”
        //          [Amount Collected] * [Commission to FPC];
        // Actual_Commission_To_FPC__c
        //
        //if(aOpp.Amount_Offered__c ==null)
        //aOpp.Amount_Offered__c =0;
        //if(aOpp.Actual_Commission_To_FPC__c ==null)
            //aOpp.Actual_Commission_To_FPC__c =0;
        if(aOpp.Amount_Collected__c ==null)
            aOpp.Amount_Collected__c =0;
        
        // old
        //if(lender != null && lender.Lender_Computation__c!=null)
        //{
        //  if(lender.Lender_Computation__c=='Amount Offered'){
        //      aOpp.Actual_FPC_Margin__c = aOpp.Amount_Offered__c *aOpp.Actual_Commission_To_FPC__c ;
        //  }else if(lender.Lender_Computation__c=='Amount Collected'){
        //      aOpp.Actual_FPC_Margin__c = aOpp.Amount_Collected__c * aOpp.Actual_Commission_To_FPC__c ;
        //  }
        //}
        
        // 5/24/12 David Vahdat updated
        //aOpp.Actual_FPC_Margin__c = aOpp.Calc_Net_Proceeds_For_Actual__c + aOpp.Amount_Collected__c +aOpp.Advanced_Payments_For_Actual__c;    
        
        // 5/30/12 - travis updated
        aOpp.Actual_FPC_Margin__c = aOpp.Calc_Net_Proceeds_For_Actual__c + aOpp.Doc_Fee_Collected__c + aOpp.Advanced_Payments_For_Actual__c;
        
        summary.add('aOpp.Actual_FPC_Margin__c is ['+aOpp.Actual_FPC_Margin__c+']');
    }
    
    /**
    * Net Margin.
    *
    * original
    * [Actual Proceeds] + [Advance Payments] + 100 (an internal doc fee) 
    *
    * 5/24/12 David Vahdat
    * [FPC Margin] – [Actual FPC Internal Doc Fee]
    *
    */
    /*static void calcNetMarginForActual(Opportunity aOpp){
        // change on 2011-5-3 by ted, recalculate the net margin field
        // Actual proceeds + advance payments  + Doc Fee Collected - Actual FPC Internal Doc Fee = net margin
        // aOpp.Net_Margin_For_Actual__c = UtilityTools.getDoubleValFromDecimal(aOpp.Actual_Proceeds_For_Actual__c) +UtilityTools.getDoubleValFromDecimal(aOpp.Advanced_Payments_For_Actual__c) - 100;

        if(aOpp.Doc_Fee_Collected__c == null)
            aOpp.Doc_Fee_Collected__c = 0;
        if(aOpp.Actual_FPC_Internal_Doc_Fee__c == null)
            aOpp.Actual_FPC_Internal_Doc_Fee__c = 0;
        
        // old  
        // aOpp.Net_Margin_For_Actual__c = UtilityTools.getDoubleValFromDecimal(aOpp.Actual_Proceeds_For_Actual__c) +UtilityTools.getDoubleValFromDecimal(aOpp.Advanced_Payments_For_Actual__c) +aOpp.Actual_FPC_Internal_Doc_Fee__c; //+ aOpp.Doc_Fee_Collected__c; // - aOpp.Actual_FPC_Internal_Doc_Fee__c   
        
        // 5/24/12 David Vahdat updated
        aOpp.Net_Margin_For_Actual__c = aOpp.Actual_FPC_Margin__c - aOpp.Actual_FPC_Internal_Doc_Fee__c;        
        summary.add('aOpp.Net_Margin_For_Actual__c is [' +  aOpp.Net_Margin_For_Actual__c +']');
    }*/    //[Commented By Archana(25/9/2012)]
    
    static void calcNetMarginForActual(Opportunity aOpp){
        // change on 2011-5-3 by ted, recalculate the net margin field
        // Actual proceeds + advance payments  + Doc Fee Collected - Actual FPC Internal Doc Fee = net margin
        // aOpp.Net_Margin_For_Actual__c = UtilityTools.getDoubleValFromDecimal(aOpp.Actual_Proceeds_For_Actual__c) +UtilityTools.getDoubleValFromDecimal(aOpp.Advanced_Payments_For_Actual__c) - 100;
        // Update by Travis 2014.1106 to set new field Lender Prefund Fee value if null to account for change in Net Margin Calc.    
        
        if(aOpp.Doc_Fee_Collected__c == null)
            aOpp.Doc_Fee_Collected__c = 0;
        if(aOpp.Actual_FPC_Internal_Doc_Fee__c == null)
            aOpp.Actual_FPC_Internal_Doc_Fee__c = 0;
        if(aOpp.Lender_Prefund_Fee__c == null)
            aOpp.Lender_Prefund_Fee__c = 0;
        if(aOpp.Rep_Exempt_Fees__c == null)
            aOpp.Rep_Exempt_Fees__c = 0;
        
        // old  
        // aOpp.Net_Margin_For_Actual__c = UtilityTools.getDoubleValFromDecimal(aOpp.Actual_Proceeds_For_Actual__c) +UtilityTools.getDoubleValFromDecimal(aOpp.Advanced_Payments_For_Actual__c) +aOpp.Actual_FPC_Internal_Doc_Fee__c; //+ aOpp.Doc_Fee_Collected__c; // - aOpp.Actual_FPC_Internal_Doc_Fee__c   
        
        // 5/24/12 David Vahdat updated
        // 11/6/14 Travis Rover Updated - Modify Net Margin as request by Sarah Bowlin. New formula is: Net Margin = Actual FPC Margin - Internal Doc Fee + Interest Settlement + Lender Prefund Fee + Rep Exempt Fees
        aOpp.Net_Margin_For_Actual__c = aOpp.Actual_FPC_Margin__c - aOpp.Actual_FPC_Internal_Doc_Fee__c + aOpp.Int_Settlement_For_Actual__c + aOpp.Lender_Prefund_Fee__c + aOpp.Rep_Exempt_Fees__c;        
        summary.add('aOpp.Net_Margin_For_Actual__c is [' +  aOpp.Net_Margin_For_Actual__c +']');
    }
    
    /**
    * Interim Rent.
    *
    * IF LENDER.[Charge Interim Rent] = True THEN
    * [Monthly Pmt]  / 30 * [Interest Settlement Days];
    * ELSE
    * 0;
    * END IF
    */
     
    static void calcInterimRent(Opportunity aOpp,Account lender){
        System.debug('@@@@@@Account Check VALUE'+aOpp.Account.Lender_Charge_Interim_Rent__c); 
        System.debug('@@@@@@Account Lender VALUE'+aOpp.Lender_Account__c); 
        if(aOpp.Lender_Account__c!=NULL &&lender.Lender_Charge_Interim_Rent__c == true){
            aOpp.Interim_Rent_For_Actual__c = ((aOpp.Actual_Monthly_Payment__c /30) * aOpp.Interest_Settlement_Days_For_Actual__c);
        }else{
                System.debug('########ELSE  VALUE'+aOpp.Interim_Rent_For_Actual__c);
            aOpp.Interim_Rent_For_Actual__c = 0.00;            
        }
        System.debug('aOpp.Interim_Rent_For_Actual__c is [' +  aOpp.Interim_Rent_For_Actual__c +']');
        summary.add('aOpp.Interim_Rent_For_Actual__c is [' +  aOpp.Interim_Rent_For_Actual__c +']');
    }
    

    /**
    * Debug Utility.
    */
    static void debug(){
        // DEBUG
        string theSummary = '';
        integer i = 1;
        for(string s :summary){
            theSummary += i +  ') ' + s +' \n';
            i++;
        }   
        system.debug('\n \n \n The Summary: \n \n \n'+theSummary);
    }
    
    
}