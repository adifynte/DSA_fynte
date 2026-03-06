import java.util.*;

// 118. Pascal's Triangle
// Given an integer numRows, return the first numRows of Pascal's triangle.

public class Solution {
    public List<List<Integer>> generate(int numRows) {
        List<List<Integer>> finalArray = new ArrayList<>();
        for (int i = 1; i <= numRows; i++) {
            List<Integer> currArr = new ArrayList<>();
            for (int j = 0; j < i; j++) {
                if (j == 0 || j == i - 1) {
                    currArr.add(1);
                } else {
                    currArr.add(finalArray.get(i - 2).get(j - 1) + finalArray.get(i - 2).get(j));
                }
            }
            finalArray.add(currArr);
        }
        return finalArray;
    }
}
