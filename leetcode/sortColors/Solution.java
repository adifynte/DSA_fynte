import java.util.*;

class Solution {
    public int[] sortColors(int[] nums) {
        int i = 0;
        int j = nums.length - 1;

        for (int k = i; k <= j;) {
            if (nums[k] == 0) {
                nums[k] = nums[i];
                nums[i] = 0;
                i += 1;
                k += 1;
            } else if (nums[k] == 2) {
                nums[k] = nums[j];
                nums[j] = 2;
                j -= 1;
            } else
                k += 1;
        }
        return nums;
    }
}