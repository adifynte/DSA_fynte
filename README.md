# 🔥 DSA_fynte

> *Sharpen the blade. One problem at a time.*

A curated collection of **Data Structures & Algorithms** solutions from **Codeforces** and **LeetCode** — solved with clarity, optimized for performance, and documented for learning.

---

## 🎯 Goal

To consistently practice and master challenging algorithmic problems, build strong problem-solving intuition, and document the journey from brute force to optimal.

---

## 📂 Structure

```
DSA_fynte/
├── run.sh                  # Test runner (auto-detects language & platform)
├── new.sh                  # Problem scaffolding
├── runners/                # Shared LeetCode runners (input parsing, method invocation)
│   ├── java/
│   │   ├── LeetCodeRunner.java
│   │   ├── TreeNode.java
│   │   └── ListNode.java
│   ├── python/
│   │   └── leetcode_runner.py
│   └── js/
│       └── leetcode_runner.js
├── templates/
│   ├── leetcode/           # LeetCode-style templates (method-only, no I/O)
│   │   ├── java/Solution.java
│   │   ├── python/solution.py
│   │   ├── js/solution.js
│   │   └── metadata.json
│   └── codeforces/         # Codeforces-style templates (stdin/stdout)
│       ├── java/Solution.java
│       ├── python/solution.py
│       └── js/solution.js
├── leetcode/
│   └── <problem-name>/
│       ├── Solution.java   # (or solution.py / solution.js)
│       ├── metadata.json   # Method name, param types, return type
│       ├── input.txt       # JSON-format input (one arg per line)
│       └── output.txt      # JSON-format expected output
└── codeforces/
    └── <problem-name>/
        ├── Solution.java   # (or solution.py / solution.js)
        ├── input.txt
        └── output.txt
```

---

## 🚀 Quick Start

### 1. Scaffold a new problem
```bash
./new.sh <platform> <problem-name> <lang>
```
- **platform:** `leetcode` or `codeforces`
- **problem-name:** kebab-case (e.g., `two-sum`)
- **lang:** `java`, `python`, or `js`

```bash
./new.sh leetcode two-sum python
./new.sh codeforces watermelon java
```

### 2. Write your solution

**LeetCode** — Write just the solution method, exactly like on leetcode.com:
```java
// Solution.java
public class Solution {
    public int maxProfit(int[] prices) {
        // your solution here
    }
}
```
```python
# solution.py
class Solution:
    def twoSum(self, nums: List[int], target: int) -> List[int]:
        # your solution here
```

Then fill in `metadata.json` with the method signature:
```json
{
    "method": "maxProfit",
    "params": [
        { "name": "prices", "type": "int[]" }
    ],
    "return": "int"
}
```

**Codeforces** — Read from stdin, write to stdout (unchanged):
```java
public class Solution {
    public static void solve(Scanner sc, PrintWriter out) {
        // read input, write output
    }
}
```

### 3. Add test data

**LeetCode** — Use JSON format, one argument per line:
```
[7,1,5,3,6,4]
```
```
5
```

**Codeforces** — Use raw stdin/stdout format as on the site.

### 4. Run and validate
```bash
./run.sh <platform>/<problem-name>
```
```bash
./run.sh leetcode/two-sum
# ✅ PASS  or  ❌ FAIL (with diff)
```

---

## 📋 Supported LeetCode Types

The runners support parsing and serializing these types in `metadata.json`:

| Type | Example Input |
|------|--------------|
| `int` | `5` |
| `double` | `3.14` |
| `boolean` | `true` |
| `String` | `"hello"` |
| `int[]` | `[1,2,3]` |
| `int[][]` | `[[1,2],[3,4]]` |
| `String[]` | `["a","b"]` |
| `List<Integer>` | `[1,2,3]` |
| `List<String>` | `["a","b"]` |
| `List<List<Integer>>` | `[[1],[1,1]]` |
| `TreeNode` | `[1,2,3,null,5]` |
| `ListNode` | `[1,2,3,4]` |

---

## 🛠️ Requirements

- **Java** (JDK 11+) for Java solutions
- **Python 3** for Python solutions
- **Node.js** for JavaScript solutions

---

## 🏷️ Problem Tagging

Each solution includes:
- **Platform** (LeetCode / Codeforces)
- **Difficulty** (Easy / Medium / Hard / Rating)
- **Tags** (e.g., DP, Graph, BFS, Greedy)
- **Time & Space Complexity**
- **Approach Notes**

---

## 🧠 Key Topics

- Arrays & Strings
- Linked Lists & Stacks/Queues
- Trees & Graphs (BFS/DFS)
- Dynamic Programming
- Greedy Algorithms
- Binary Search
- Sliding Window & Two Pointers
- Bit Manipulation
- Segment Trees & Fenwick Trees

---

## 🚀 Getting Started

Clone and explore solutions:

```bash
git clone https://github.com/adifynte/DSA_fynte.git
cd DSA_fynte
```

---

## 📄 License

MIT License
