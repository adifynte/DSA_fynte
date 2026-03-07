import java.util.*;

public class Solution {
   public int[] nextPermutation(int[] nums) {
        int index = -1;
        int n = nums.length;

        for (int i = n - 1; i > 0; i--) {
            if (nums[i] > nums[i - 1]) {
                index = i-1;
                break;
            }
        }

        if (index > -1) {
            for (int i = n - 1; i > index; i--) {
                if (nums[i] > nums[index]) {
                    swap(nums, index, i);
                    break;
                }
            }
        }

        reverse(nums, index+1, n-1);
        return nums;
    }

    void swap( int[] nums, int i, int j) {
        int temp = nums[i];
        nums[i] = nums[j];
        nums[j] = temp;
    }

    void reverse( int[] nums, int i, int j) {
        while (i < j) {
            swap(nums, i, j);
            i+=1;
            j-=1;
        }
    }
}
