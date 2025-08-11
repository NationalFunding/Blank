public class ChecklistController{
    public Credit_review__c creditReviewObj{get;set;}
    public List<Split_Funding__c> createCreditReviewSplitFundingRecords {get;set;}
    public List<Split_Funding__c> creditReviewSplitFundingList {get;set;}
    public List<CheckItemClass> CheckItems {get;set;}
    private String fields;
    private String id;

    //Constructor
    public ChecklistController(){
        CheckItems = new List<CheckItemClass>();
        id = ApexPages.currentPage().getParameters().get('id');
                fields = 'automation_notes_for_analyst__c, ';
                fields += 'ROS_Done_1__c, ';
                fields += 'ROS_Done_2__c, ';
                fields += 'ROS_Notes_1__c, ';
                fields += 'ROS_Notes_2__c, ';
                fields += 'BA_Stip_Notes_Official_Statements__c,';
                fields += 'BA_Stip_Notes_Competitor_on_Banks__c,';
                fields += 'BC_Stip_Notes_Website__c,';
                fields += 'BA_Stip_Notes_Deposits__c,';
                fields += 'BA_Stip_Notes_Balances__c,';
                fields += 'PF_Stip_Notes_Matching_Information__c,';
                fields += 'PF_Stip_Notes_Approvable_Credit__c,';
                fields += 'BC_Stip_Notes_TIB_Ownership_Industry__c,';
                fields += 'BC_Stip_Notes_UCC_Filings__c,';
                fields += 'BC_Stip_Notes_Approvable_Credit__c,';
                fields += 'BC_Stip_Notes_Paynet__c,';
                fields += 'BC_Stip_Notes_SIC_Code_Industry_Restrict__c,';
                fields += 'BC_Stip_Notes_Absentee_Ownership_Miami_D__c,';
                fields += 'BC_Stip_Notes_License__c,';
                fields += 'GSI_Stip_Notes_Google_Search__c,';
                fields += 'GSI_Stip_Notes_Business_Address__c,';
                fields += 'GSI_Stip_Notes_PO_Box_Address__c,';
                fields += 'GSI_Stip_Notes_Business_Number__c,';
                fields += 'GSI_Stip_Notes_Legal_Name__c,';
                fields += 'GSI_Stip_Notes_DBA__c,';
                fields += 'GSl_Stip_Notes_PG1__c,';
                fields += 'GSl_Stip_Notes_PG2__c,';
                fields += 'GSl_Stip_Notes_PG3__c,';
                fields += 'GIS_Stip_Notes_Miscellaneous_Search__c,';
                fields += 'FC_Stip_Notes_Signed_Application__c,';
                fields += 'FC_Stip_Notes_SOS__c,';
                fields += 'FC_Stip_Notes_Tax_Return__c,';
                fields += 'FC_Stip_Notes_Bank_Statements__c,';
                fields += 'FCStipNoteSDNSearchCompleted_Attached__c,';
                fields +=  'BA_Notes_Official_Statements__c,Status__c,Post_Audit__c,';
                fields += 'BA_Stip_Official_Statements__c,Credit_Approval_Notes__c,';
                fields += 'BA_Done_Official_Statements__c,';
                fields += 'BA_Notes_Deposits__c,';
                fields += 'BA_Stip_Deposits__c,';
                fields += 'BA_Done_Deposits__c,';
                fields += 'BA_Notes_Balances__c,';
                fields += 'BA_Stip_Balances__c,';
                fields += 'BA_Done_Balances__c,';
                fields += 'BC_Done_Lexis_Nexis__c,';
                fields += 'BC_Stip_Lexis_Nexis__c,';
                fields += 'BC_Stip_Notes_Lexis_Nexis__c,';
                fields += 'BC_Notes_Lexis_Nexis__c,';
                fields += 'BA_Notes_Competitor_on_Banks__c,';
                fields += 'BA_Stip_Competitor_on_Banks__c,';
                fields += 'BA_Done_Competitor_on_Banks__c,';
                fields += 'PF_Notes_Matching_Information__c,';
                fields += 'PF_Stip_Matching_Information__c,';
                fields += 'PF_Done_Matching_Information__c,';
                fields += 'PF_Notes_Bank_Address_Analysis__c,';
                fields += 'PF_Stip_Bank_Address_Analysis__c,';
                fields += 'PF_Done_Bank_Address_Analysis__c,';
                fields += 'PF_Notes_Approvable_Credit__c,';
                fields += 'PF_Stip_Approvable_Credit__c,';
                fields += 'PF_Done_Approvable_Credit__c,';
                fields += 'BC_Notes_TIB_Ownership_Industry__c,';
                fields += 'BC_Stip_TIB_Ownership_Industry__c,';
                fields += 'BC_Done_TIB_Ownership_Industry__c,';
                fields += 'BC_Notes_UCC_Filings__c,';
                fields += 'BC_Stip_UCC_Filings__c,';
                fields += 'BC_Done_UCC_Filings__c,';
                fields += 'BC_Notes_Approvable_Credit__c,';
                fields += 'BC_Stip_Approvable_Credit__c,';
                fields += 'BC_Done_Approvable_Credit__c,';
                fields += 'BC_Notes_Paynet__c,';
                fields += 'BC_Stip_Paynet__c,';
                fields += 'BC_Done_Paynet__c,';
                fields += 'BC_Notes_SIC_Code_Industry_Restric__c,';
                fields += 'BC_Stip_SIC_Code_Industry_Restrict__c,';
                fields += 'BC_Done_SIC_Code_Industry_Restrict__c,';
                fields += 'BC_Notes_Absentee_Ownership_Miami__c,';
                fields += 'BC_Stip_Absentee_Ownership_Miami_D__c,';
                fields += 'BC_Done_Absentee_Ownership_Miami_D__c,';
                fields += 'BC_Notes_Website__c,';
                fields += 'BC_Stip_Website__c,';
                fields += 'BC_Done_Website__c,';
                fields += 'BC_Notes_License__c,';
                fields += 'BC_Stip_License__c,';
                fields += 'BC_Done_License__c,';
                fields += 'FC_Notes_Signed_Application__c,';
                fields += 'FC_Stip_Signed_Application__c,';
                fields += 'FC_Done_Signed_Application__c,';
                fields += 'FC_Notes_SOS__c,';
                fields += 'FC_Stip_SOS__c,';
                fields += 'FC_Done_SOS__c,';
                fields += 'FC_Notes_Tax_Return__c,';
                fields += 'FC_Stip_Tax_Return__c,';
                fields += 'FC_Done_Tax_Return__c,';
                fields += 'FC_Notes_Bank_Statements__c,';
                fields += 'FC_Stip_Bank_Statements__c,';
                fields += 'FC_Done_Bank_Statements__c,';
                fields += 'FC_Notes_SDN_Search_Completed_Attached__c,';
                fields += 'FC_Stip_SDN_Search_Completed_Attached__c,';
                fields += 'FC_Done_SDN_Search_Completed_Attached__c,';
                fields += 'GSI_Notes_Google_Search__c,';
                fields += 'GSI_Name_on_Acct_Google_Search__c,';
                fields += 'GSI_Name_of_Search_Google_Search__c,';
                fields += 'GSI_Done_Google_Search__c,';
                fields += 'GSI_Notes_Business_Address__c,';
                fields += 'GSI_Name_on_Acct_Business_Address__c,';
                fields += 'GSI_Name_of_Search_Business_Address__c,';
                fields += 'GSI_Done_Business_Address__c,';
                fields += 'GSI_Notes_PO_Box_Address__c,';
                fields += 'GSI_Name_on_Acct_PO_Box_Address__c,';
                fields += 'GSI_Name_of_Search_PO_Box_Address__c,';
                fields += 'GSI_Done_PO_Box_Address__c,';
                fields += 'GSI_Notes_Business_Number__c,';
                fields += 'GSI_Name_on_Acct_Business_Number__c,';
                fields += 'GSI_Name_of_Search_Business_Number__c,';
                fields += 'GSI_Done_Business_Number__c,';
                fields += 'GSI_Notes_Legal_Name__c,';
                fields += 'GSI_Name_on_Acct_Legal_Name__c,';
                fields += 'GSI_Name_of_Search_Legal_Name__c,';
                fields += 'GSI_Done_Legal_Name__c,';
                fields += 'GSI_Notes_DBA__c,';
                fields += 'GSI_Name_on_Acct_DBA__c,';
                fields += 'GSI_Name_of_Search_DBA__c,';
                fields += 'GSI_Done_DBA__c,';
                fields += 'GSI_Notes_PG1__c,';
                fields += 'GSI_Name_on_Acct_PG1__c,';
                fields += 'GSI_Name_of_Search_PG1__c,';
                fields += 'GSI_Done_PG1__c,';
                fields += 'GSI_Notes_PG2__c,';
                fields += 'GSI_Name_on_Acct_PG2__c,';
                fields += 'GSI_Name_of_Search_PG2__c,';
                fields += 'GSI_Done_PG2__c,';
                fields += 'GSI_Notes_PG3__c,';
                fields += 'GSI_Name_on_Acct_PG3__c,';
                fields += 'GSI_Name_of_Search_PG3__c,';
                fields += 'GSI_Done_PG3__c,';
                fields += 'PG1__r.name,';
                fields += 'PG2__r.name,';
                fields += 'PG3__r.name,';
                fields += 'PG1__c,';
                fields += 'PG2__c,';
                fields += 'PG3__c,';
               // Stipulations Fields
                fields += 'Credit_Stip1__c,';
                fields += 'Credit_Stip_1_Reason__c,';
                fields += 'Credit_Stip2__c,';
                fields += 'Credit_Stip_2_Reason__c,';
                fields += 'Credit_Stip3__c,';
                fields += 'Credit_Stip_3_Reason__c,';
                fields += 'Credit_Stips_Other__c,';
                fields += 'Credit_Stips_Other_Reason__c,';
                fields += 'Credit_Stip_Funding_Requirement_1__c,';
                fields += 'Credit_Stip_Funding_Requirement_1_Reason__c,';
                fields += 'Credit_Stip_Funding_Requirement_2__c,';
                fields += 'Credit_Stip_Funding_Requirement_2_Reason__c,';
                fields += 'Credit_Stip_Funding_Requirement_3__c,';
                fields += 'Credit_Stip_Funding_Requirement_3_Reason__c,';
                fields += 'Credit_Stip_Funding_Requirement_Other__c,';
                fields += 'Stip_Funding_Requirement_Other_Reason__c,';
                fields += 'Opportunity__r.Physical_Address_1__c,';
                fields += 'Opportunity__r.Mailing_Address_1__c,';
                fields += 'Opportunity__r.Phone__c,';
                fields += 'Opportunity__r.Legal_Name__c,';
                fields += 'Opportunity__r.name,';
                fields += 'Account__r.Name,Account__r.Company_DBA__c,';
                fields += 'Opportunity__r.Physical_Address_City__c,';
                fields += 'Opportunity__r.Physical_Address_State__c,';
                fields += 'Opportunity__r.Mailing_Address_City__c,';
                fields += 'Opportunity__r.Mailing_Address_State__c,';
                fields += 'Bank_Analysis_Notes__c,';
                fields += 'Personal_Credit_Notes__c,';
                fields += 'Business_Credit_Notes__c,';
                fields += 'Verification_Notes__c,';
                fields += 'Google_Search_Notes__c,';
                fields += 'GIS_Notes_Miscellaneous_Search__c,';
                fields += 'GIS_Name_Miscellaneous_Search__c,';
                fields += 'GIS_Done_Miscellaneous_Search__c,';
                fields += 'GSI_Stip_Google_Search__c,';
                fields += 'GSI_Stip_Business_Address__c,';
                fields += 'GSI_Stip_PO_Box_Address__c,';
                fields += 'GSI_Stip_Business_Number__c,';
                fields += 'GSI_Stip_Legal_Name__c,';
                fields += 'GSI_Stip_DBA__c,';
                fields += 'GSI_Stip_PG1__c,';
                fields += 'GSI_Stip_PG2__c,';
                fields += 'GSI_Stip_PG3__c,';
                fields += 'GIS_Stip_Miscellaneous_Search__c,';
                fields += 'Final_Checklist_Notes__c,';
                fields += 'RR_Done_HIDCA_HIFCA__c,';
                fields += 'RR_Notes_HIDCA_HIFCA__c,';
                fields += 'RR_Stip_HIDCA_HIFCA__c,';
                fields += 'RR_Stip_Notes_HIDCA_HIFCA__c,';
                fields += 'RR_Done_Bounces_Mods__c,';
                fields += 'RR_Notes_Bounces_Mods__c,';
                fields += 'RR_Stip_Bounces_Mods__c,';
                fields += 'RR_Stip_Notes_Bounces_Mods__c,';
                fields += 'RR_Done_Paid_In_On_Current_Deal__c,';
                fields += 'RR_Notes_Paid_In_On_Current_Deal__c,';
                fields += 'RR_Done_Balance_on_Current_Deal__c,';
                fields += 'RR_Notes_Balance_on_Current_Deal__c,';
                fields += 'RR_Notes__c,';
                fields += 'Opportunity__c';

        creditReviewObj = Database.Query('select '+fields+', (SELECT Id, Payoff_Type__c, Lender__c, LenderLoan__c, Payoff_Loan_Number__c FROM Split_Funding__r) from Credit_review__c where id =: id');
        
        creditReviewSplitFundingList = new List<Split_Funding__c>( [SELECT Id, Payoff_Type__c, Lender__c, LenderLoan__c, Payoff_Loan_Number__c FROM Split_Funding__c WHERE Credit_Review__c = :creditReviewObj.Id]);
        createCreditReviewSplitFundingRecords = new List<Split_Funding__c>();

        CheckItems = fillItems(creditReviewObj);
    }

    public void addNewSplitFundingRow() {
        Split_Funding__c newSplitFundRecord = new Split_Funding__c();
        createCreditReviewSplitFundingRecords.add(newSplitFundRecord);
    }

    public void splitFundingList(){
        if(createCreditReviewSplitFundingRecords.size() > 0){
            List<Split_Funding__c> splitFundingList = new List<Split_Funding__c>();
            for(Split_Funding__c sf : createCreditReviewSplitFundingRecords){
                if(sf.Payoff_Type__c == null){
                    continue;
                }
                
                sf.Opportunity__c = creditReviewObj.Opportunity__c; 
                sf.Credit_Review__c = creditReviewObj.Id; 

                if(sf.Payoff_Type__c == 'Internal Payoff'){
                    sf.Payoff_Loan_Number__c = sf.LenderLoan__c;
                    sf.Recipient_Is_National_Funding__c = true;
                    sf.Lender__c = 'National Funding';
                } else if(sf.Payoff_Type__c == '3rd Party Payoff'){
                    sf.Lender__c = sf.LenderLoan__c;
                }
                splitFundingList.add(sf);
            } 
            insert splitFundingList;
        }
        //reset the list values to the newly updated values
        creditReviewSplitFundingList = [SELECT Id, LenderLoan__c, Payoff_Type__c, Lender__c, Payoff_Loan_Number__c FROM Split_Funding__c WHERE Credit_Review__c = :creditReviewObj.Id];
        createCreditReviewSplitFundingRecords = new List<Split_Funding__c>();
    }

    public pageReference saveRecord(){
        // Sometimes credit analysts open the checklist, start working on it, but decline the deal first, then finish and save the checklist.
        // Since credit review status is part of the view state, then saving the checklist overwrites any changes to the status
        // Therefore we refresh the status before doing the upsert
        Credit_Review__c cr_refresh = [SELECT Id, Status__c 
                                            FROM Credit_Review__C 
                                            WHERE Id =:creditReviewObj.id];
        creditReviewObj.Status__c = cr_refresh.Status__c;

        //inserting and resetting the split funding for new insert
        splitFundingList();

        // Save the checklist and stips 
        upsert creditReviewObj;
        CheckItems = fillItems(creditReviewObj);

        return null;
    }

    public void resetChecklist(){
          creditReviewObj = Database.Query('select '+fields+' from Credit_review__c where id =: id');
          CheckItems = fillItems(creditReviewObj);
    }
    public List<CheckItemClass> fillItems(Credit_review__c obj){
          List<CheckItemClass> Models = new List<CheckItemClass>();
          Models.add(new CheckItemClass('Official Statement, Matching Info, Beg/End Match (Bank Analysis)',obj.BA_Stip_Notes_Official_Statements__c,obj.BA_Stip_Official_Statements__c));
          Models.add(new CheckItemClass('Deposits (Bank Analysis)',obj.BA_Stip_Notes_Deposits__c,obj.BA_Stip_Deposits__c));
          Models.add(new CheckItemClass('Balances (Bank Analysis)',obj.BA_Stip_Notes_Balances__c,obj.BA_Stip_Balances__c));
          Models.add(new CheckItemClass('Competitor on Banks (Bank Analysis)',obj.BA_Stip_Notes_Competitor_on_Banks__c,obj.BA_Stip_Competitor_on_Banks__c));
          Models.add(new CheckItemClass('Matching Information (Personal Credit)',obj.PF_Stip_Notes_Matching_Information__c,obj.PF_Stip_Matching_Information__c));
          Models.add(new CheckItemClass('Bank Address Analysis (Personal Credit)',obj.PF_Notes_Bank_Address_Analysis__c,obj.PF_Stip_Bank_Address_Analysis__c));
          Models.add(new CheckItemClass('Approvable Credit (Personal Credit)',obj.PF_Stip_Notes_Approvable_Credit__c,obj.PF_Stip_Approvable_Credit__c));
          Models.add(new CheckItemClass('TIB / Ownership / Industry (Business Credit)',obj.BC_Stip_Notes_TIB_Ownership_Industry__c,obj.BC_Stip_TIB_Ownership_Industry__c));
          Models.add(new CheckItemClass('UCC Filings (Business Credit)',obj.BC_Stip_Notes_UCC_Filings__c,obj.BC_Stip_UCC_Filings__c));
          Models.add(new CheckItemClass('Approvable Credit (Business Credit)',obj.BC_Stip_Notes_Approvable_Credit__c,obj.BC_Stip_Approvable_Credit__c));
          Models.add(new CheckItemClass('Paynet (Business Credit)',obj.BC_Stip_Notes_Paynet__c,obj.BC_Stip_Paynet__c));
          Models.add(new CheckItemClass('SIC Code, Industry Restrictions? (Verification)',obj.BC_Stip_Notes_SIC_Code_Industry_Restrict__c,obj.BC_Stip_SIC_Code_Industry_Restrict__c));
          Models.add(new CheckItemClass('Absentee Ownership / Miami Dade? (Verification)',obj.BC_Stip_Notes_Absentee_Ownership_Miami_D__c,obj.BC_Stip_Absentee_Ownership_Miami_D__c));
          Models.add(new CheckItemClass('Website (Verification)',obj.BC_Stip_Notes_Website__c,obj.BC_Stip_Website__c));
          Models.add(new CheckItemClass('License (Verification)',obj.BC_Stip_Notes_License__c,obj.BC_Stip_License__c));
          Models.add(new CheckItemClass('Signed Application (Final Checklist)',obj.FC_Stip_Notes_Signed_Application__c,obj.FC_Stip_Signed_Application__c));
          Models.add(new CheckItemClass('SOS (Final Checklist)',obj.FC_Stip_Notes_SOS__c,obj.FC_Stip_SOS__c));
          Models.add(new CheckItemClass('Tax Return (Final Checklist)',obj.FC_Stip_Notes_Tax_Return__c,obj.FC_Stip_Tax_Return__c));
          Models.add(new CheckItemClass('Bank Statements (Final Checklist)',obj.FC_Stip_Notes_Bank_Statements__c,obj.FC_Stip_Bank_Statements__c));
          Models.add(new CheckItemClass('SDN Search Completed + Attached (Final Checklist)',obj.FCStipNoteSDNSearchCompleted_Attached__c,obj.FC_Stip_SDN_Search_Completed_Attached__c));
      
        
          Models.add(new CheckItemClass('Lexis Nexis', obj.BC_Stip_Notes_Lexis_Nexis__c,obj.BC_Stip_Lexis_Nexis__c));
        
          Models.add(new CheckItemClass('Account Name (Google Search Items)',obj.GSI_Stip_Notes_Google_Search__c,obj.GSI_Stip_Google_Search__c));
          Models.add(new CheckItemClass('Physical Address (Google Search Items)',obj.GSI_Stip_Notes_Business_Address__c,obj.GSI_Stip_Business_Address__c));
          Models.add(new CheckItemClass('Mailing Address (Google Search Items)',obj.GSI_Stip_Notes_PO_Box_Address__c,obj.GSI_Stip_PO_Box_Address__c));
          Models.add(new CheckItemClass('Business Number (Google Search Items)',obj.GSI_Stip_Notes_Business_Number__c,obj.GSI_Stip_Business_Number__c));
          Models.add(new CheckItemClass('Legal Name (Google Search Items)',obj.GSI_Stip_Notes_Legal_Name__c,obj.GSI_Stip_Legal_Name__c));
          Models.add(new CheckItemClass('DBA (Google Search Items)',obj.GSI_Stip_Notes_DBA__c,obj.GSI_Stip_DBA__c));

          Models.add(new CheckItemClass('HIDCA/HIFCA',obj.RR_Stip_Notes_HIDCA_HIFCA__c,obj.RR_Stip_HIDCA_HIFCA__c));
          Models.add(new CheckItemClass('Bounces/Mods',obj.RR_Stip_Notes_Bounces_Mods__c,obj.RR_Stip_Bounces_Mods__c));


        if(obj.PG1__c != null && obj.PG1__r.name != null) {
               Models.add(new CheckItemClass(obj.PG1__r.name + ' (Google Search Items)',obj.GSl_Stip_Notes_PG1__c,obj.GSI_Stip_PG1__c));               
          }
          if(obj.PG2__c != null && obj.PG2__r.name != null) {
               Models.add(new CheckItemClass(obj.PG2__r.name + ' (Google Search Items)',obj.GSl_Stip_Notes_PG2__c,obj.GSI_Stip_PG2__c));               
          }
          if(obj.PG3__c != null && obj.PG3__r.name != null) {
               Models.add(new CheckItemClass(obj.PG3__r.name + ' (Google Search Items)',obj.GSl_Stip_Notes_PG3__c,obj.GSI_Stip_PG3__c));               
          }

          Models.add(new CheckItemClass('Miscellaneous (Google Search Items)',obj.GIS_Stip_Notes_Miscellaneous_Search__c,obj.GIS_Stip_Miscellaneous_Search__c));


          return Models;
    }
    public class CheckItemClass{
          public string item {get;set;}
          public string notes {get;set;}
          public boolean flag {get;set;}
          public CheckItemClass(string i,string n,boolean f){
               this.item = i;
               this.notes = n;
               this.flag = f;
          }
    }
}