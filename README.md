# 🔥 DSA_fynte

> *Sharpen the blade. One problem at a time.*

A curated collection of **Data Structures & Algorithms** solutions from **Codeforces**, **LeetCode**, and **Educative**.

---

## 📂 Structure

```
DSA_fynte/
├── setup.sh / setup.cmd    # First-time dependency install
├── run.sh   / run.cmd      # Test runner (auto-detects language & platform)
├── new.sh   / new.cmd      # Problem scaffolding
├── runners/                # Shared LeetCode/Educative runners
│   ├── java/
│   ├── python/
│   ├── js/
│   └── cpp/
├── templates/
│   ├── leetcode/           # LeetCode-style templates (method-only, no I/O)
│   ├── educative/          # Educative-style templates (method-only, no I/O)
│   └── codeforces/         # Codeforces-style templates (stdin/stdout)
├── leetcode/
├── educative/
└── codeforces/
```

---

## 🚀 Quick Start

### 1. First-time setup (required after clone)
```bash
./setup.sh          # Git Bash / Linux / macOS
.\setup.cmd         # Windows PowerShell / CMD (same terminal)
```

### 2. Scaffold a new problem
```bash
./new.sh <platform> <problem-name> <lang>         # Git Bash
.\new.cmd <platform> <problem-name> <lang>         # Windows
```
- **platform:** `leetcode`, `educative`, or `codeforces`
- **problem-name:** kebab-case (e.g., `two-sum`)
- **lang:** `java`, `python`, `js`, or `cpp`

```bash
./new.sh leetcode two-sum cpp
./new.sh educative longest-substring python
./new.sh codeforces watermelon java
```

### 3. Write your solution

- **LeetCode / Educative**: method-only style + `metadata.json`
- **Codeforces**: stdin/stdout style

### 4. Add test data

- **LeetCode / Educative**: JSON input (one argument per line), JSON output
- **Codeforces**: raw stdin/stdout format

### 5. Run and validate
```bash
./run.sh <platform>/<problem-name>         # Git Bash
.\run.cmd <platform>/<problem-name>        # Windows PowerShell / CMD
```
```bash
.\run.cmd leetcode/two-sum
.\run.cmd educative/longest-substring
.\run.cmd codeforces/watermelon
```

---

## 📋 Supported Metadata Types (LeetCode / Educative)

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

## 🛠️ Tooling

`setup.sh` installs the required toolchain:

- Java (JDK)
- Python 3
- Node.js + npm
- C++ compiler (`g++`)
- npm project dependencies

---

## 📄 License

MIT License
