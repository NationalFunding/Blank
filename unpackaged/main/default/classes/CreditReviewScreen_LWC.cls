public with sharing class CreditReviewScreen_LWC {

    // @AuraEnabled(cacheable=true)
    public static Credit_Review__c getRecords(Id recordId){
        Credit_Review__c cr = [SELECT Accepts_CC__c,Account__c,Allowable_Exceptions__c,Allow_Review_Type_Update__c,All_EQF_Fico_Scores__c,All_Exception_Items__c,All_Mitigating_Factors__c,Amount_Requested__c,Analyst_Comment_1__c,Analyst_Comment_2__c,Analyst_Comment_3__c,Annual_Revenue__c,ApprovalRecomendationBy__c,Approval_Expiration_Date__c,Approval_Recomendation_By__c,Approval_Recommendation_Date__c,ApprovedBy__c,Approved_By__c,Approved_Date__c,Approved_Workflow_Fire__c,AutomatedCreditProcess__c,Automated_Approval_Issued_Date_Time__c,Automation_Notes_for_Analyst__c,AU_Review_Completed_By__c,AU_Review_Completed_Date__c,Average_Daily_Sales__c,Average_Number_of_Deposits__c,Average_Number_of_Negative_Days__c,Average_Number_of_NSF_s__c,Average_of_Average_Daily_Balance__c,Avg_Deposits_Amount__c,Bank_Acct_Last_4__c,Bank_Analysis_Notes__c,Bank_Entry_Complete_Date__c,Bank_Entry_Complete__c,Bank_Name__c,BA_Done_Balances__c,BA_Done_Competitor_on_Banks__c,BA_Done_Deposits__c,BA_Done_Official_Statements__c,BA_Notes_Balances__c,BA_Notes_Competitor_on_Banks__c,BA_Notes_Deposits__c,BA_Notes_Official_Statements__c,BA_Stip_Balances__c,BA_Stip_Competitor_on_Banks__c,BA_Stip_Deposits__c,BA_Stip_Notes_Balances__c,BA_Stip_Notes_Competitor_on_Banks__c,BA_Stip_Notes_Deposits__c,BA_Stip_Notes_Official_Statements__c,BA_Stip_Official_Statements__c,BC_Done_Absentee_Ownership_Miami_D__c,BC_Done_Approvable_Credit__c,BC_Done_Lexis_Nexis__c,BC_Done_License__c,BC_Done_Paynet__c,BC_Done_SIC_Code_Industry_Restrict__c,BC_Done_TIB_Ownership_Industry__c,BC_Done_UCC_Filings__c,BC_Done_Website__c,BC_Notes_Absentee_Ownership_Miami__c,BC_Notes_Approvable_Credit__c,BC_Notes_Lexis_Nexis__c,BC_Notes_License__c,BC_Notes_Paynet__c,BC_Notes_SIC_Code_Industry_Restric__c,BC_Notes_TIB_Ownership_Industry__c,BC_Notes_UCC_Filings__c,BC_Notes_Website__c,BC_Stip_Absentee_Ownership_Miami_D__c,BC_Stip_Approvable_Credit__c,BC_Stip_Lexis_Nexis__c,BC_Stip_License__c,BC_Stip_Notes_Absentee_Ownership_Miami_D__c,BC_Stip_Notes_Approvable_Credit__c,BC_Stip_Notes_Lexis_Nexis__c,BC_Stip_Notes_License__c,BC_Stip_Notes_Paynet__c,BC_Stip_Notes_SIC_Code_Industry_Restrict__c,BC_Stip_Notes_TIB_Ownership_Industry__c,BC_Stip_Notes_UCC_Filings__c,BC_Stip_Notes_Website__c,BC_Stip_Paynet__c,BC_Stip_SIC_Code_Industry_Restrict__c,BC_Stip_TIB_Ownership_Industry__c,BC_Stip_UCC_Filings__c,BC_Stip_Website__c,Beginning_Balance_Average__c,BK_Count__c,BK_Discharge_Date__c,BK_Open_Date__c,BK_Type__c,Blanket_UCC_Filed__c,BOFI_Deal__c,Broker_Account__c,Broker_Decline_Other_Reason__c,Broker_Decline_Reasons_Formula__c,Broker_Decline_Reasons__c,Broker_Preferred_Email__c,Broker_Tier__c,Business_Credit_Notes__c,Business_Loan_Approval_Template_Id__c,Business_Start_Date__c,CaseSafeId__c,Comments__c,Commercial_Decline_Other_Reason__c,Commercial_Decline_Reasons__c,Commercial_Prequalified__c,Commercial_Review_Completed_By__c,Commercial_Review_Completed_Date__c,Competitor_Review_Complete__c,Completed_By__c,Completed_Date__c,CreatedById,CreatedDate,Create_WC_Decision_Record__c,Credit_Approval_Notes__c,Credit_Review_2__c,Credit_Review_Label_for_Flow__c,Credit_Review_Version__c,Credit_Stip1__c,Credit_Stip2__c,Credit_Stip3__c,Credit_Stips_Other_Reason__c,Credit_Stips_Other__c,Credit_Stip_1_Reason__c,Credit_Stip_1__c,Credit_Stip_2_Reason__c,Credit_Stip_2__c,Credit_Stip_3_Reason__c,Credit_Stip_3__c,Credit_Stip_Funding_Requirement_1_Reason__c,Credit_Stip_Funding_Requirement_1__c,Credit_Stip_Funding_Requirement_2_Reason__c,Credit_Stip_Funding_Requirement_2__c,Credit_Stip_Funding_Requirement_3_Reason__c,Credit_Stip_Funding_Requirement_3__c,Credit_Stip_Funding_Requirement_Other__c,CR_Decline_Date__c,Deal_Flag__c,Deal_Origination__c,Deal_Type__c,DeclineReasons__c,Decline_Other_Reason__c,Decline_Reasons__c,Diamond_Recommended_Approval__c,Diamond_Review_Completed_By__c,Diamond_Review_Completed_Date__c,EFX_Business_Summary__c,eNoah_Review_Completed_By__c,eNoah_Review_Completed_Date__c,Experian_Transaction_Number__c,EXP_Business_Summary__c,FCStipNoteSDNSearchCompleted_Attached__c,FC_Done_Bank_Statements__c,FC_Done_SDN_Search_Completed_Attached__c,FC_Done_Signed_Application__c,FC_Done_SOS__c,FC_Done_Tax_Return__c,FC_Notes_Bank_Statements__c,FC_Notes_SDN_Search_Completed_Attached__c,FC_Notes_Signed_Application__c,FC_Notes_SOS__c,FC_Notes_Tax_Return__c,FC_Stip_Bank_Statements__c,FC_Stip_Notes_Bank_Statements__c,FC_Stip_Notes_Signed_Application__c,FC_Stip_Notes_SOS__c,FC_Stip_Notes_Tax_Return__c,FC_Stip_SDN_Search_Completed_Attached__c,FC_Stip_Signed_Application__c,FC_Stip_SOS__c,FC_Stip_Tax_Return__c,Final_Checklist_Notes__c,Financial_Analysis_By__c,Financial_Analysis_Date__c,Financial_Analysis__c,GIS_Done_Miscellaneous_Search__c,GIS_Name_Miscellaneous_Search__c,GIS_Notes_Miscellaneous_Search__c,GIS_Stip_Miscellaneous_Search__c,GIS_Stip_Notes_Miscellaneous_Search__c,Gold_Recommended_Approval__c,Google_Search_Notes__c,GSI_Done_Business_Address__c,GSI_Done_Business_Number__c,GSI_Done_DBA__c,GSI_Done_Google_Search__c,GSI_Done_Legal_Name__c,GSI_Done_PG1__c,GSI_Done_PG2__c,GSI_Done_PG3__c,GSI_Done_PO_Box_Address__c,GSI_Name_of_Search_Business_Address__c,GSI_Name_of_Search_Business_Number__c,GSI_Name_of_Search_DBA__c,GSI_Name_of_Search_Google_Search__c,GSI_Name_of_Search_Legal_Name__c,GSI_Name_of_Search_PG1__c,GSI_Name_of_Search_PG2__c,GSI_Name_of_Search_PG3__c,GSI_Name_of_Search_PO_Box_Address__c,GSI_Name_on_Acct_Business_Address__c,GSI_Name_on_Acct_Business_Number__c,GSI_Name_on_Acct_DBA__c,GSI_Name_on_Acct_Google_Search__c,GSI_Name_on_Acct_Legal_Name__c,GSI_Name_on_Acct_PG1__c,GSI_Name_on_Acct_PG2__c,GSI_Name_on_Acct_PG3__c,GSI_Name_on_Acct_PO_Box_Address__c,GSI_Notes_Business_Address__c,GSI_Notes_Business_Number__c,GSI_Notes_DBA__c,GSI_Notes_Google_Search__c,GSI_Notes_Legal_Name__c,GSI_Notes_Notes_PG3__c,GSI_Notes_PG1__c,GSI_Notes_PG2__c,GSI_Notes_PG3__c,GSI_Notes_PO_Box_Address__c,GSI_Stip_Business_Address__c,GSI_Stip_Business_Number__c,GSI_Stip_DBA__c,GSI_Stip_Google_Search__c,GSI_Stip_Legal_Name__c,GSI_Stip_Notes_Business_Address__c,GSI_Stip_Notes_Business_Number__c,GSI_Stip_Notes_DBA__c,GSI_Stip_Notes_Google_Search__c,GSI_Stip_Notes_Legal_Name__c,GSI_Stip_Notes_PG1__c,GSI_Stip_Notes_PG2__c,GSI_Stip_Notes_PG3__c,GSI_Stip_Notes_PO_Box_Address__c,GSI_Stip_PG1__c,GSI_Stip_PG2__c,GSI_Stip_PG3__c,GSI_Stip_PO_Box_Address__c,GSl_Stip_Notes_PG1__c,GSl_Stip_Notes_PG2__c,GSl_Stip_Notes_PG3__c,Guarantor_2_Conga_Formula__c,Half_Revenue__c,High_Risk_Transaction__c,Home_Based_Business__c,Id,Industry_Classification__c,Initial_Commercial_Review_Decision__c,Initial_Decline_By__c,Initial_Decline_Date__c,Internal_MID__c,IsDeleted,LastActivityDate,LastModifiedById,LastModifiedDate,LastReferencedDate,LastViewedDate,Loss_Percentage__c,Max_Approval_Amount__c,MAX_Experian_FICO__c,Max_FICO_Score__c,Max_Negative_Days_v2__c,Max_Negative_Days__c,Max_NSF_v2__c,Max_NSF__c,Max_Term__c,Max_Tier__c,Min_FICO_Score__c,Mitigating_Factor_1__c,Mitigating_Factor_2__c,Mitigating_Factor_3__c,Model_Decision_Score__c,Months_Under_10k_Deposits_v2__c,Months_Under_10k_Deposits__c,Month_to_Date_required_day_of_funding__c,MSA_Code__c,MSA_Name__c,Name,NF_Commercial_Portfolio__c,Number_of_Months_Reviewed_v2__c,Number_of_Months_Reviewed__c,OFAC_Match__c,Open_Judgements__c,Open_Judgments_Amount__c,Open_Liens_Amount__c,Open_Liens__c,Open_Public_Records_Balance__c,Open_Public_Records__c,Opportunity_Hyperlink__c,Opportunity_Owner_Email__c,Opportunity__c,Oppty_Legal_Name__c,OwnerId,Ownership_Verified__c,Paydex__c,Paynet__c,Personal_Credit_Notes__c,PF_Done_Approvable_Credit__c,PF_Done_Bank_Address_Analysis__c,PF_Done_Matching_Information__c,PF_Notes_Approvable_Credit__c,PF_Notes_Bank_Address_Analysis__c,PF_Notes_Matching_Information__c,PF_Stip_Approvable_Credit__c,PF_Stip_Bank_Address_Analysis__c,PF_Stip_Matching_Information__c,PF_Stip_Notes_Approvable_Credit__c,PF_Stip_Notes_Matching_Information__c,PG1Search__c,PG1_Cons_Risk_Summary__c,PG1_EQF_Cons_Summary__c,PG1_EXP_Cons_Summary__c,PG1__c,PG2Search__c,PG2_Cons_Risk_Summary__c,PG2_EQF_Cons_Summary__c,PG2_EXP_Cons_Summary__c,PG2__c,PG3Search__c,PG3_Cons_Risk_Summary__c,PG3_EQF_Cons_Summary__c,PG3_EXP_Cons_Summary__c,PG3__c,PG_1_BK_Discharge_Date__c,PG_1_Credit_Score__c,PG_1_EQF_Date__c,PG_1_EQF_Score__c,PG_1_EXP_Date__c,PG_1_EXP_Score__c,PG_1_IDA_Grade__c,PG_1_IDA_Score__c,PG_1_Judgement_Amount__c,PG_1_Mortgage_Issues__c,PG_1_Name__c,PG_1_Open_Public_Records__c,PG_1_Open_Public_Record_Balance__c,PG_1_Open_Tax_Liens__c,PG_1_Open_Tax_Lien_Amount__c,PG_1_Previous_BK__c,PG_2_BK_Discharge_Date__c,PG_2_Credit_Score__c,PG_2_EQF_Date__c,PG_2_EQF_Score__c,PG_2_EXP_Date__c,PG_2_EXP_Score__c,PG_2_IDA_Grade__c,PG_2_IDA_Score__c,PG_2_Judgement_Amount__c,PG_2_Mortgage_Issues__c,PG_2_Name__c,PG_2_Open_Public_Records__c,PG_2_Open_Public_Record_Balance__c,PG_2_Open_Tax_Liens__c,PG_2_Open_Tax_Lien_Amount__c,PG_2_Previous_BK__c,PG_3_BK_Discharge_Date__c,PG_3_Credit_Score__c,PG_3_EQF_Date__c,PG_3_EQF_Score__c,PG_3_EXP_Date__c,PG_3_EXP_Score__c,PG_3_IDA_Grade__c,PG_3_IDA_Score__c,PG_3_Judgement_Amount__c,PG_3_Open_Public_Records__c,PG_3_Open_Public_Record_Balance__c,PG_3_Open_Tax_Lien_Amount__c,PG_3_Previous_BK__c,PG_Name_Search__c,Platinum_Recommended_Approval__c,Policy_Exceptions__c,Policy_Exception_1__c,Policy_Exception_2__c,Policy_Exception_3__c,Policy_Exception_Categories__c,Post_Audit__c,Post_Funding_Audit_Notes__c,PreProcessing_Complete_Date__c,PreProcessing_Complete__c,Previous_Bankruptcy__c,Processing_Completed__c,Proof_of_Property_Ownership__c,Pt_Rev_Completed_By__c,PT_Rev_Completed_Date__c,Public_Records__c,Recent_UCC_Filings__c,Recommended_Approval__c,Recommended_Term__c,Rejected_By__c,Rejected_On__c,Related_Funding_Record__c,Retention_Pricing_Applicable__c,Review_Type__c,ROS_Done_1__c,ROS_Done_2__c,ROS_Notes_1__c,ROS_Notes_2__c,RR_Done_Balance_on_Current_Deal__c,RR_Done_Bounces_Mods__c,RR_Done_HIDCA_HIFCA__c,RR_Done_Paid_In_On_Current_Deal__c,RR_Notes_Balance_on_Current_Deal__c,RR_Notes_Bounces_Mods__c,RR_Notes_HIDCA_HIFCA__c,
                                    RR_Notes_Paid_In_On_Current_Deal__c,RR_Notes__c,RR_Stip_Bounces_Mods__c,RR_Stip_HIDCA_HIFCA__c,RR_Stip_Notes_Bounces_Mods__c,RR_Stip_Notes_HIDCA_HIFCA__c,Secondary_Review__c,Second_Review_Analyst__c,Second_Review_By__c,Second_Review_Date__c,Second_Review_From__c,Send_To_Syndication__c,SIC_Code__c,SIC_Name__c,SOS_Active_Complete__c,State__c,Status__c,Stips_Concatenate__c,Stip_Funding_Requirement_Other_Reason__c,Strong_Mitigating_Factors__c,Sum_of_Average_Daily_Balance_v2__c,Sum_of_Average_Daily_Balance__c,Sum_of_Counter_Deposits_Amount_v2__c,Sum_of_Counter_Deposits_Amount__c,Sum_of_Deposits_v2__c,Sum_of_Deposits__c,Sum_of_Negative_Days_v2__c,Sum_of_Negative_Days__c,Sum_of_NSF_s_v2__c,Sum_of_NSF_s__c,Sum_of_Other_Deposits_Amount_v2__c,Sum_of_Other_Deposits_Amount__c,Syndication_Decline_Reason__c,Syndication_Recommendation_Submitted__c,Syndication_Recommended_by__c,SystemModstamp,Tier_Decline_Reason__c,Time_In_Business__c,Total_Liens_Judgments__c,UW_Call_By__c,UW_Call_Date__c,UW_Call__c,Verification_Notes__c,WC_Decision_Bin__c,WC_Decision_Recomendation__c,WC_Decision_Record__c,Withdrawn_By__c,Withdrawn_On__c 
                                FROM Credit_Review__c 
                                WHERE Id = :recordId LIMIT 1]; //Opportunity__c
        return cr; 
    }

    @AuraEnabled(cacheable=true)
    public static SummaryModelClass individualBankTabSummaryTab(String recordId){
        List<MonthlyLedgerParent> MonthlyLedgerParents = new List<MonthlyLedgerParent>();

        //this needs to change to CR ID but leaving as Oppty for now just to test data return...
        Credit_Review__c cr = getRecords(recordId);
        recordId = cr.Id;

        SummaryModelClass summaryRecords = new SummaryModelClass();
        String endRangeDate;
        String startRangeDate;
        //=============================== Bank Tab Work Start ===================================
        // Bank name
        Map<String,Credit_Review_Bank_Summary__c> bankDataMap = new Map<string,Credit_Review_Bank_Summary__c>();
        // Bank Ids
        list<string> bankIds = new list<string>();
        // Bank_Summary Ids
        set<string> bankSummaryIds = new set<string>();
        for(Credit_Review_Bank_Summary__c bankSummaryObj : [SELECT Related_Bank_Data__c, Related_Bank_Data__r.Bank_Name__c, Related_Bank_Data__r.Account_Number__c, Id
                                                            FROM Credit_Review_Bank_Summary__c
                                                            WHERE Credit_Review__c = :recordId 
                                                            ORDER BY CreatedDate]){
            bankIds.add(bankSummaryObj.Related_Bank_Data__c);
            bankSummaryIds.add(bankSummaryObj.id);
            bankDataMap.put(bankSummaryObj.Related_Bank_Data__c,bankSummaryObj);
        }
        string fields='Id,';
        fields+='Bank_Monthly_Ledger__r.Avg_Daily_Balance__c,';
        fields+='Bank_Monthly_Ledger__r.Beginning_Balance__c,';
        fields+='Bank_Monthly_Ledger__r.Calendar_Month_Number__c,';
        fields+='Bank_Monthly_Ledger__r.Counter_Deposits__c,';
        fields+='Bank_Monthly_Ledger__r.Other_Deposits__c,';
        fields+='Bank_Monthly_Ledger__r.Deposits_Count__c,';
        fields+='Bank_Monthly_Ledger__r.Ending_Balance__c,';
        fields+='Bank_Monthly_Ledger__r.NSF_s__c,';
        fields+='Bank_Monthly_Ledger__r.Withdrawls__c,';
        fields+='Bank_Monthly_Ledger__r.Bank_Data__c,';
        fields+='Bank_Monthly_Ledger__r.Negative_Days__c,';
        fields+='Bank_Monthly_Ledger__r.Bank_Data__r.Bank_Name__c,';
        fields+='Beginning_Balance__c,';
        fields+='Deposits_Number__c,';
        fields+='Counter_Deposits__c,';
        fields+='Other_Deposits__c,';
        fields+='Withdrawls__c,';
        fields+='Ending_Balance__c,';
        fields+='Negative_Days__c,';
        fields+='NSF__c,';
        fields+='Deposits__c,';
        fields+='Avg_Daily_Balance__c,';
        fields+='Bank_Summary__c,';
        fields+='Month__c,';
        fields+='Month_Name__c,';
        fields+='Include_in_Averages__c,';
        fields+='Year__c,';
        fields+='sort_order__c,';
        fields+='Bank_Monthly_Ledger__c';


        // Add 31 days Fields
        for (Integer i = 1; i != 32; i++){
            fields += ', Day_'+i+'_Daily_Balance__c';
            fields += ', Bank_Monthly_Ledger__r.Day_'+i+'_Daily_Balance__c';
        }

        // Monthly List
        List<Credit_Review_Monthly_Ledger__c> bankMonthlyList = Database.query('SELECT '+fields+' FROM Credit_Review_Monthly_Ledger__c WHERE Bank_Summary__c in:bankSummaryIds ORDER by Sort_Order__c DESC');
        Map<String,List<Credit_Review_Monthly_Ledger__c>> bankMonthlyMap = new Map<String,List<Credit_Review_Monthly_Ledger__c>>();

        if(bankMonthlyList.size() > 0){
            endRangeDate = string.valueOf(bankMonthlyList[0].Sort_Order__c);
            startRangeDate = string.valueOf(bankMonthlyList[bankMonthlyList.size()-1].sort_order__c);
            endRangeDate = endRangeDate.substring(0,endRangeDate.lastIndexOf('-'));
            startRangeDate = startRangeDate.substring(0,startRangeDate.lastIndexOf('-'));
        }

        
        // This map For Summary Tab
        Map<String,List<Credit_Review_Monthly_Ledger__c>> summaryRecordMap = new Map<String,List<Credit_Review_Monthly_Ledger__c>>();
        for(Credit_Review_Monthly_Ledger__c monthlyLedgerObj : bankMonthlyList ){
            List<Credit_Review_Monthly_Ledger__c> tempList = bankMonthlyMap.get(monthlyLedgerObj.Bank_Monthly_Ledger__r.Bank_Data__c);
            if(tempList == null){
                tempList = new List<Credit_Review_Monthly_Ledger__c>();
            }
            tempList.add(monthlyLedgerObj);
            bankMonthlyMap.put(monthlyLedgerObj.Bank_Monthly_Ledger__r.Bank_Data__c,tempList);
        }

        Double summaryColumn1,summaryColumn3,summaryColumn4,summaryColumn5,summaryColumn6,summaryColumn9;
        Integer summaryColumn2,summaryColumn7,summaryColumn8;
        summaryColumn1=summaryColumn3=summaryColumn4=summaryColumn5=summaryColumn6=summaryColumn9=0.0;
        summaryColumn2=summaryColumn7=summaryColumn8=0;
        for(string  bankid : bankIds){
            List<MonthlyLedgerChild> childs = new List<MonthlyLedgerChild>();
            Decimal c1 = 0;
            Decimal c2 = 0;
            Decimal c3 = 0;
            Decimal c4 = 0;
            Decimal c5 = 0;
            Decimal c6 = 0;
            Decimal c9 = 0;
            Integer c7 = 0;
            Integer c8 = 0;
            Integer c1Avg = 0;
            Integer c2Avg = 0;
            Integer c3Avg = 0;
            Integer c4Avg = 0;
            Integer c5Avg = 0;
            Integer c6Avg = 0;
            Integer c7Avg = 0;
            Integer c8Avg = 0;
            Integer c9Avg = 0;
            // c1=c2=c3=c4=c5=c6=0.0;
            // c9=0.0;
            // c7=c8=c1Avg=c2Avg=c3Avg=c4Avg=c5Avg=c6Avg=c7Avg=c8Avg=c9Avg=0;

            if(bankMonthlyMap.get(bankid) != null){
                for(Credit_Review_Monthly_Ledger__c mlObj : bankMonthlyMap.get(bankid)){
                    childs.add(new MonthlyLedgerChild(mlObj));
                    if(mlObj.Include_in_Averages__c){
                        // Summary Tab Start
                        List<Credit_Review_Monthly_Ledger__c> crmlTemp = summaryRecordMap.get(String.valueOf(mlObj.sort_order__c));
                        if(crmlTemp == null){
                            crmlTemp = new List<Credit_Review_Monthly_Ledger__c>();
                        }
                        crmlTemp.add(mlObj);
                        summaryRecordMap.put(String.valueOf(mlObj.sort_order__c),crmlTemp);
                        // Summary Tab End

                        if(mlObj.Bank_Monthly_Ledger__r.Beginning_Balance__c != null){
                            c1 +=mlObj.Bank_Monthly_Ledger__r.Beginning_Balance__c;
                            c1Avg++;
                        }
                        if(mlObj.Bank_Monthly_Ledger__r.Deposits_Count__c != null){
                            c2 +=mlObj.Bank_Monthly_Ledger__r.Deposits_Count__c;
                            c2Avg++;
                        } 
                        if(mlObj.Bank_Monthly_Ledger__r.Counter_Deposits__c != null){
                            c3 +=mlObj.Bank_Monthly_Ledger__r.Counter_Deposits__c;
                            c3Avg++;
                        }
                        if(mlObj.Bank_Monthly_Ledger__r.Other_Deposits__c != null){
                            c4 +=mlObj.Bank_Monthly_Ledger__r.Other_Deposits__c;
                            c4Avg++;
                        }
                        if(mlObj.Bank_Monthly_Ledger__r.Withdrawls__c != null){
                            c5 +=mlObj.Bank_Monthly_Ledger__r.Withdrawls__c;
                            c5Avg++;
                        }
                        if(mlObj.Bank_Monthly_Ledger__r.Ending_Balance__c != null){
                            c6 +=mlObj.Bank_Monthly_Ledger__r.Ending_Balance__c;
                            c6Avg++;
                        }
                        if(mlObj.Bank_Monthly_Ledger__r.Negative_Days__c != null){
                            c7 += integer.valueOf(mlObj.Bank_Monthly_Ledger__r.Negative_Days__c);
                            c7Avg++;
                        }
                        if(mlObj.Bank_Monthly_Ledger__r.NSF_s__c != null){
                            c8 +=integer.valueOf(mlObj.Bank_Monthly_Ledger__r.NSF_s__c);
                            c8Avg++;
                        }
                        if(mlObj.Bank_Monthly_Ledger__r.Avg_Daily_Balance__c != null){
                            c9 +=mlObj.Bank_Monthly_Ledger__r.Avg_Daily_Balance__c;
                            c9Avg++;
                        }
                    }

                }
            }
            c1 = c1Avg < 1 ? c1 : c1/c1Avg;
            c2 = c2Avg < 1 ? c2 : c2/c2Avg;
            c3 = c3Avg < 1 ? c3 : c3/c3Avg;
            c4 = c4Avg < 1 ? c4 : c4/c4Avg;
            c5 = c5Avg < 1 ? c5 : c5/c5Avg;
            c6 = c6Avg < 1 ? c6 : c6/c6Avg;
            c7 = c7Avg < 1 ? c7 : c7/c7Avg;
            c8 = c8Avg < 1 ? c8 : c8/c8Avg;
            c9 = c9Avg < 1 ? c9 : c9/c9Avg;

            // Summary Avg Start
            summaryColumn1 +=c1;
            summaryColumn2 +=integer.valueOf(c2);
            summaryColumn3 +=c3;
            summaryColumn4 +=c4;
            summaryColumn5 +=c5;
            summaryColumn6 +=c6;
            summaryColumn7 +=c7;
            summaryColumn8 +=c8;
            summaryColumn9 +=c9;
            // Summary Avg End
            MonthlyLedgerParent parent = new MonthlyLedgerParent(bankDataMap.get(bankid).Related_Bank_Data__r.Account_Number__c,bankDataMap.get(bankid).id,bankid,bankDataMap.get(bankid).Related_Bank_Data__r.Bank_Name__c,childs,new BankMonthlyAverage(c1,c2,c3,c4,c5,c6,c7,c8,c9));
            MonthlyLedgerParents.add(parent);
        }
        //=============================== Bank Tab Work End ===================================

        //=============================== Summary Tab Work Start ===================================
        List<SummaryMonths> SummaryMonthList = new List<SummaryMonths>();

        for(String SummaryMonths : summaryRecordMap.keySet()){
            if(summaryRecordMap.get(SummaryMonths) != null){
                List<Credit_Review_Monthly_Ledger__c> CreditReviewMonthlyLedgerList = summaryRecordMap.get(SummaryMonths);
                Decimal sc1,sc2,sc3,sc4,sc5,sc6,sc9;
                Integer sc7,sc8;
                sc1=sc3=sc4=sc5=sc6=sc9=sc2=sc7=sc8=0;
                SummaryMonths SummaryMonthsObj = new SummaryMonths();
                SummaryMonthsObj.year = string.valueOf(CreditReviewMonthlyLedgerList[0].Year__c);
                SummaryMonthsObj.month = string.valueOf(CreditReviewMonthlyLedgerList[0].Month__c);
                SummaryMonthsObj.MonthName = string.valueOf(CreditReviewMonthlyLedgerList[0].Month_Name__c);

                for(Credit_Review_Monthly_Ledger__c summaryObj : CreditReviewMonthlyLedgerList){
                    if(summaryObj.Bank_Monthly_Ledger__r.Beginning_Balance__c != null){
                        sc1 +=summaryObj.Bank_Monthly_Ledger__r.Beginning_Balance__c;
                    }
                    if(summaryObj.Bank_Monthly_Ledger__r.Deposits_Count__c != null){
                        sc2 +=summaryObj.Bank_Monthly_Ledger__r.Deposits_Count__c;
                    }
                    if(summaryObj.Bank_Monthly_Ledger__r.Counter_Deposits__c != null){
                        sc3 +=summaryObj.Bank_Monthly_Ledger__r.Counter_Deposits__c;
                    }
                    if(summaryObj.Bank_Monthly_Ledger__r.Other_Deposits__c != null){
                        sc4 +=summaryObj.Bank_Monthly_Ledger__r.Other_Deposits__c;
                    }
                    if(summaryObj.Bank_Monthly_Ledger__r.Withdrawls__c != null){
                        sc5 +=summaryObj.Bank_Monthly_Ledger__r.Withdrawls__c;
                    }
                    if(summaryObj.Bank_Monthly_Ledger__r.Ending_Balance__c != null){
                        sc6 +=summaryObj.Bank_Monthly_Ledger__r.Ending_Balance__c;
                    }
                    if(summaryObj.Bank_Monthly_Ledger__r.Negative_Days__c != null){
                        sc7 += integer.valueOf(summaryObj.Bank_Monthly_Ledger__r.Negative_Days__c);
                    }
                    if(summaryObj.Bank_Monthly_Ledger__r.NSF_s__c != null){
                        sc8 +=integer.valueOf(summaryObj.Bank_Monthly_Ledger__r.NSF_s__c);
                    }
                    if(summaryObj.Bank_Monthly_Ledger__r.Avg_Daily_Balance__c != null){
                        sc9 +=summaryObj.Bank_Monthly_Ledger__r.Avg_Daily_Balance__c;
                    }
                }
                SummaryMonthsObj.Column1 =sc1;
                SummaryMonthsObj.Column2 = integer.valueOf(sc2);
                SummaryMonthsObj.Column3 =sc3;
                SummaryMonthsObj.Column4 =sc4;
                SummaryMonthsObj.Column5 =sc5;
                SummaryMonthsObj.Column6 =sc6;
                SummaryMonthsObj.Column7 =sc7;
                SummaryMonthsObj.Column8 =sc8;
                SummaryMonthsObj.Column9 =sc9;

                SummaryMonthList.add(SummaryMonthsObj);
            }
        }

        summaryRecords.BMA = new BankMonthlyAverage(summaryColumn1,summaryColumn2,summaryColumn3,summaryColumn4,summaryColumn5,summaryColumn6,summaryColumn7,summaryColumn8,summaryColumn9);
        summaryRecords.MonthlyLedgerParentsList = MonthlyLedgerParents;
        summaryRecords.SummaryMonths =SummaryMonthList;

        //=============================== Summary Tab Work End ===================================
        return summaryRecords;
    }

    public class SummaryModelClass{
        @AuraEnabled public BankMonthlyAverage BMA{get;set;}
        @AuraEnabled public List<SummaryMonths> SummaryMonths{get;set;}
        @AuraEnabled public List<MonthlyLedgerParent> MonthlyLedgerParentsList{get;set;}
        @AuraEnabled public List<MonthlyLedgerParent> MonthlyLedgerParents{get;set;}
    }

    public class SummaryMonths{
        @AuraEnabled public String Year{get;set;}
        @AuraEnabled public String Month{get;set;}
        @AuraEnabled public String MonthName{get;set;}
        @AuraEnabled public Double Column1{get;set;}
        @AuraEnabled public integer Column2{get;set;}
        @AuraEnabled public Double Column3{get;set;}
        @AuraEnabled public Double Column4{get;set;}
        @AuraEnabled public Double Column5{get;set;}
        @AuraEnabled public Double Column6{get;set;}
        @AuraEnabled public integer Column7{get;set;}
        @AuraEnabled public integer Column8{get;set;}
        @AuraEnabled public Double Column9{get;set;}
    }

    public class BankMonthlyAverage{
        @AuraEnabled public String Column1{get;set;}
        @AuraEnabled public integer Column2{get;set;}
        @AuraEnabled public String Column3{get;set;}
        @AuraEnabled public String Column4{get;set;}
        @AuraEnabled public String Column5{get;set;}
        @AuraEnabled public String Column6{get;set;}
        @AuraEnabled public integer Column7{get;set;}
        @AuraEnabled public integer Column8{get;set;}
        @AuraEnabled public String Column9{get;set;}
        public BankMonthlyAverage(Decimal d1,Decimal d2,Decimal d3,Decimal d4,Decimal d5,Decimal d6,integer d7,integer d8,Decimal d9){
            this.column1 = CreditReviewScreen_LWC.currency(string.valueOf(d1));
            this.column2 = Integer.valueOf(d2);
            this.column3 = CreditReviewScreen_LWC.currency(string.valueOf(d3));
            this.column4 = CreditReviewScreen_LWC.currency(string.valueOf(d4));
            this.column5 = CreditReviewScreen_LWC.currency(string.valueOf(d5));
            this.column6 = CreditReviewScreen_LWC.currency(string.valueOf(d6));
            this.column7 = d7;
            this.column8 = d8;
            this.column9 = CreditReviewScreen_LWC.currency(string.valueOf(d9));
        }
    }

    public static String currency(String input){
        if(input == null){return '0.00';}
        if(input.indexOf('.') == -1){input = input+'.00';}
        if(input.length() == 5){return input+'0';}
        String newValue = input.substring(input.indexOf('.'));
        newValue = String.valueOf(Decimal.valueOf(newValue).setScale(2));
        newValue = newValue.substring(newValue.indexOf('.'));
        input = input.substring(0,input.indexOf('.'));
        Integer sz = input.length();
        Integer n=0;
        for(Integer i = sz - 1;i > -1;i--){
            if(n!= 0 && math.mod(n,3) == 0)
                newValue = input.substring(i,i+1)+','+newValue;
            else
                    newValue = input.substring(i,i+1)+newValue;
            n++;
        }
        return newValue;
    }

    public class MonthlyLedgerChild {
        @AuraEnabled public Credit_Review_Monthly_Ledger__c Mr { get; set; }
        @AuraEnabled public Integer DaysInMonth { get; set; }
        @AuraEnabled public List<String> FieldNames { get; set; }
        public MonthlyLedgerChild(Credit_Review_Monthly_Ledger__c monRev) {
            system.debug('monRev::: ' + monRev);
            this.mr = monRev;//if there is no value we want to default to 0 or - 
            this.daysInMonth = Date.daysInMonth(Integer.valueOf(monRev.Year__c),Integer.valueOf(monRev.Month__c));
            this.fieldNames = new List<String>();
            for (Integer i = 1; i <= this.daysInMonth; i++)
                this.fieldNames.add('Day_'+i+'_Daily_Balance__c');
        }
    }

    public class MonthlyLedgerParent{
        @AuraEnabled public String BankId {get;set;}
        @AuraEnabled public String BankSummaryId {get;set;}
        @AuraEnabled public String TabName{get;set;}
        @AuraEnabled public List<MonthlyLedgerChild> Childs{get;set;}
        @AuraEnabled public BankMonthlyAverage Avg{get;set;}
        @AuraEnabled public String Account_Number {get;set;}
        public MonthlyLedgerParent(String AccountNumber, string s, string i,string t,List<MonthlyLedgerChild> c,BankMonthlyAverage a){
            this.Account_Number = AccountNumber;
            this.bankSummaryId = s;
            this.bankId = i;
            this.tabName = t;
            this.childs = c;
            this.avg = a;
        }
    }
}