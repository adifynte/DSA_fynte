import java.util.*;
import java.io.*;

// 118. Pascal's Triangle
// Given an integer numRows, return the first numRows of Pascal's triangle.
// In Pascal's triangle, each number is the sum of the two numbers directly above it as shown:
// https://leetcode.com/problems/pascals-triangle/

public class Solution {
    public static void solve(Scanner sc, PrintWriter out) {
        int numRows = sc.nextInt();
         List<List<Integer>> finalArray = new ArrayList<>();
        for(int i = 1; i<=numRows; i++){
            List<Integer> currArr = new ArrayList<>();
            for(int j = 0; j<i; j++){
                if(j == 0 || j == i-1){
                    currArr.add(1);
                }else{
                    currArr.add(finalArray.get(i-2).get(j-1) + finalArray.get(i-2).get(j));
                }
            }
            finalArray.add(currArr);
        }
        out.println(finalArray.toString().replace(" ", ""));
    }

    public static void main(String[] args) {
        Scanner sc = new Scanner(System.in);
        PrintWriter out = new PrintWriter(System.out);
        solve(sc, out);
        out.flush();
        out.close();
    }
}
