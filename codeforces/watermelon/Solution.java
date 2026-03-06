import java.util.*;
import java.io.*;

public class Solution {
    public static void solve(Scanner sc, PrintWriter out) {
        int w = sc.nextInt();
        if (w > 2 && w % 2 == 0) {
            out.println("YES");
        } else {
            out.println("NO");
        }
    }

    public static void main(String[] args) {
        Scanner sc = new Scanner(System.in);
        PrintWriter out = new PrintWriter(System.out);
        solve(sc, out);
        out.flush();
        out.close();
    }
}
