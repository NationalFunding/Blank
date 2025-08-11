/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────
* TITLE: Randomize
* DESCRIPTION: Generic Class that returns a randomized list of numbers
* @author         Olivia Porter       olivia.k.porter@gmail.com
* @created        01/2023
* @test class     RandomizeTest.cls
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* v1              <email>
* 0000-00-00      <Explanation of the change>
*/
public class Randomize {

    @InvocableMethod(label='Randomize Number List' description='Returns a list of randomized numbers.' category='Distribution_Skill__c')
    public static List<List<Integer>> getRandomizedNumberList(List<Integer> count) {
        List<List<Integer>> newNumbersListList = new List<List<Integer>>();
        List<Integer> newNumbersList;
        Set<Integer> randomizedNumbers = new Set<Integer>();
        if(count.size() == 1){ 
            Integer listSize = count[0]; //because of invocable method rules, we must pass a list from flow to apex but there will only ever be one value
            Integer startIndex = 1;
            while (randomizedNumbers.size() < listSize) {
                Integer intRandom = (Integer)(Math.random()*(listSize-startIndex+1)+startIndex); //removing negatives, decimals, duplicates, and zeros from list
                randomizedNumbers.add(intRandom);
            }
             newNumbersList = new List<Integer>(randomizedNumbers);
        } else {
            system.debug('something went wrong the list is larger than 1');
            newNumbersList = new List<Integer>();
        }
        newNumbersListList.add(newNumbersList);
        return newNumbersListList;
    }
}