/**
 * ACHTransactionIterator class
 * @author CloudMyBiz (r)
 * @date 14/07/2022
 * @description
 * @group 
 */

global inherited sharing class ACHTransactionIterator implements Iterable<SObject> {

    private String objectType;
    global static IteratorQueryType queryType;
    global enum IteratorQueryType {NOT_RESOLVED_ACH_TRANSACTIONS, SENT_TO_WF_ACH_TRANSACTIONS}

    public ACHTransactionIterator(String objectType){
        this.objectType = objectType;
    }

    global Iterator<SObject> iterator() {
        return new ACHTransactionIteratorIterable(this.objectType);
    }

    global inherited sharing class ACHTransactionIteratorIterable implements Iterator<SObject> {

        List<SObject> records { get; set; }
        Integer index { get; set; }
        private String objectType;

        global ACHTransactionIteratorIterable(String objectType) {
            this.records = new SObject[]{};
            this.objectType = objectType;
            switch on queryType{
                when NOT_RESOLVED_ACH_TRANSACTIONS{
                    this.records.addAll(ACHTransactionsSelector.getNotResolvedACHTransactions(this.objectType));
                }

                when SENT_TO_WF_ACH_TRANSACTIONS{
                    this.records.addAll(ACHTransactionsSelector.getSentToWFACHTransactions(this.objectType));
                }
            }

            this.index = 0;
        }

        global Boolean hasNext() {
            return index < records.size();
        }

        global SObject next() {
            this.index++;
            return this.records[this.index - 1];
        }
    }

}