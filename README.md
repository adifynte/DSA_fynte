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
├── run.sh                  # Test runner (auto-detects language)
├── new.sh                  # Problem scaffolding
├── templates/              # Boilerplate templates
│   ├── java/Solution.java
│   ├── python/solution.py
│   └── js/solution.js
├── leetcode/
│   └── <problem-name>/
│       ├── solution.py     # (or Solution.java / solution.js)
│       ├── input.txt
│       └── output.txt
└── codeforces/
    └── <problem-name>/
        ├── Solution.java
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
```

### 2. Write your solution
Open the generated solution file and implement the `solve()` function. Input is read from **stdin**, output goes to **stdout**.

### 3. Add test data
- Paste sample input into `input.txt`
- Paste expected output into `output.txt`

### 4. Run and validate
```bash
./run.sh <platform>/<problem-name>
```
```bash
./run.sh leetcode/two-sum
# ✅ PASS  or  ❌ FAIL (with diff)
```

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
