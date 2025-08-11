/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────
* TITLE: RandomizeTest
* DESCRIPTION: Test Class that covers Randomize.cls
* @author         Olivia Porter       olivia.k.porter@gmail.com
* @created        01/2023
*/
@isTest
public class RandomizeTest {

    @isTest
    public static void generateRandomNumbersTest() {
        Test.startTest();
        List<Integer> numList = new List<Integer>();
        numList.add(10);
        List<List<Integer>> intList = Randomize.getRandomizedNumberList(numList);
        System.assert(!intList[0].contains(0));
        System.assert(intList[0].size() == numList[0]);
        Test.stopTest();

    }
}