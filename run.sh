#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

usage() {
    echo "Usage: ./run.sh <platform>/<problem-name>"
    echo ""
    echo "Example: ./run.sh leetcode/two-sum"
    echo "         ./run.sh educative/longest-substring"
    echo "         ./run.sh codeforces/watermelon"
    exit 1
}

if [ $# -ne 1 ]; then
    usage
fi

PROBLEM_PATH="$SCRIPT_DIR/$1"

if [ ! -d "$PROBLEM_PATH" ]; then
    echo -e "${RED}❌ Directory not found: $1${NC}"
    exit 1
fi

INPUT_FILE="$PROBLEM_PATH/input.txt"
OUTPUT_FILE="$PROBLEM_PATH/output.txt"

if [ ! -f "$INPUT_FILE" ]; then
    echo -e "${RED}❌ input.txt not found in $1${NC}"
    exit 1
fi

if [ ! -f "$OUTPUT_FILE" ]; then
    echo -e "${RED}❌ output.txt not found in $1${NC}"
    exit 1
fi

# Detect platform
PLATFORM=$(echo "$1" | cut -d'/' -f1)
if [ "$PLATFORM" != "leetcode" ] && [ "$PLATFORM" != "educative" ] && [ "$PLATFORM" != "codeforces" ]; then
    echo -e "${RED}❌ Invalid platform: $PLATFORM${NC}"
    echo "   Expected one of: leetcode, educative, codeforces"
    exit 1
fi

# Prefer python3, fallback to python (must be executable, not just present in PATH)
if command -v python3 >/dev/null 2>&1 && python3 -c "import sys" >/dev/null 2>&1; then
    PYTHON_CMD="python3"
elif command -v python >/dev/null 2>&1 && python -c "import sys" >/dev/null 2>&1; then
    PYTHON_CMD="python"
else
    echo -e "${RED}❌ Python not found (requires a working python3 or python)${NC}"
    exit 1
fi

# Auto-detect language
LANG=""
SOLUTION_FILE=""

if [ -f "$PROBLEM_PATH/Solution.java" ]; then
    LANG="java"
    SOLUTION_FILE="Solution.java"
elif [ -f "$PROBLEM_PATH/solution.py" ]; then
    LANG="python"
    SOLUTION_FILE="solution.py"
elif [ -f "$PROBLEM_PATH/solution.js" ]; then
    LANG="js"
    SOLUTION_FILE="solution.js"
elif [ -f "$PROBLEM_PATH/solution.cpp" ]; then
    LANG="cpp"
    SOLUTION_FILE="solution.cpp"
else
    echo -e "${RED}❌ No solution file found in $1${NC}"
    echo "   Expected one of: Solution.java, solution.py, solution.js, solution.cpp"
    exit 1
fi

if [ "$LANG" = "cpp" ]; then
    if command -v g++ >/dev/null 2>&1; then
        CPP_CMD="g++"
    elif command -v clang++ >/dev/null 2>&1; then
        CPP_CMD="clang++"
    else
        echo -e "${RED}❌ C++ compiler not found (requires g++ or clang++)${NC}"
        exit 1
    fi
fi

if [ "$LANG" = "java" ]; then
    if ! command -v javac >/dev/null 2>&1; then
        # On Windows, winget installs JDK but may not update the current PATH
        for d in "/c/Program Files/Eclipse Adoptium"/*/bin "/c/Program Files/Java"/*/bin; do
            if [ -x "$d/javac.exe" ] || [ -x "$d/javac" ]; then
                export PATH="$PATH:$d"
                break
            fi
        done
    fi
    if ! command -v javac >/dev/null 2>&1 || ! command -v java >/dev/null 2>&1; then
        echo -e "${RED}❌ Java not found (requires javac + java in PATH)${NC}"
        echo "   Run ./setup.sh and then reopen your terminal."
        exit 1
    fi
fi

if [ "$LANG" = "js" ]; then
    if ! command -v node >/dev/null 2>&1; then
        echo -e "${RED}❌ Node.js not found (requires node in PATH)${NC}"
        echo "   Run ./setup.sh and then reopen your terminal."
        exit 1
    fi
fi

echo -e "${YELLOW}▶ Running $1 ($LANG)${NC}"

# Create temp file for actual output
ACTUAL_OUTPUT=$(mktemp)
trap "rm -f $ACTUAL_OUTPUT" EXIT

if [ "$PLATFORM" = "leetcode" ] || [ "$PLATFORM" = "educative" ]; then
    # LeetCode/Educative mode: use shared runners
    METADATA_FILE="$PROBLEM_PATH/metadata.json"
    if [ ! -f "$METADATA_FILE" ]; then
        echo -e "${RED}❌ metadata.json not found in $1${NC}"
        echo "   LeetCode/Educative problems require a metadata.json file."
        exit 1
    fi

    case "$LANG" in
        java)
            TEMP_DIR=$(mktemp -d)
            trap "rm -rf $TEMP_DIR; rm -f $ACTUAL_OUTPUT" EXIT
            cp "$SCRIPT_DIR/runners/java/LeetCodeRunner.java" "$TEMP_DIR/"
            cp "$SCRIPT_DIR/runners/java/TreeNode.java" "$TEMP_DIR/"
            cp "$SCRIPT_DIR/runners/java/ListNode.java" "$TEMP_DIR/"
            cp "$PROBLEM_PATH/Solution.java" "$TEMP_DIR/"
            if ! javac "$TEMP_DIR"/*.java 2>&1; then
                echo -e "${RED}❌ Compilation failed${NC}"
                exit 1
            fi
            java -cp "$TEMP_DIR" LeetCodeRunner "$PROBLEM_PATH" > "$ACTUAL_OUTPUT" 2>&1
            ;;
        python)
            "$PYTHON_CMD" "$SCRIPT_DIR/runners/python/leetcode_runner.py" "$PROBLEM_PATH" > "$ACTUAL_OUTPUT" 2>&1
            ;;
        js)
            node "$SCRIPT_DIR/runners/js/leetcode_runner.js" "$PROBLEM_PATH" > "$ACTUAL_OUTPUT" 2>&1
            ;;
        cpp)
            "$PYTHON_CMD" "$SCRIPT_DIR/runners/cpp/leetcode_runner.py" "$PROBLEM_PATH" > "$ACTUAL_OUTPUT" 2>&1
            ;;
    esac
else
    # Codeforces mode: stdin/stdout pipe
    case "$LANG" in
        java)
            if ! javac "$PROBLEM_PATH/Solution.java" 2>&1; then
                echo -e "${RED}❌ Compilation failed${NC}"
                exit 1
            fi
            java -cp "$PROBLEM_PATH" Solution < "$INPUT_FILE" > "$ACTUAL_OUTPUT" 2>&1
            rm -f "$PROBLEM_PATH"/*.class
            ;;
        python)
            "$PYTHON_CMD" "$PROBLEM_PATH/solution.py" < "$INPUT_FILE" > "$ACTUAL_OUTPUT" 2>&1
            ;;
        js)
            node "$PROBLEM_PATH/solution.js" < "$INPUT_FILE" > "$ACTUAL_OUTPUT" 2>&1
            ;;
        cpp)
            TEMP_DIR=$(mktemp -d)
            trap "rm -rf $TEMP_DIR; rm -f $ACTUAL_OUTPUT" EXIT
            if ! "$CPP_CMD" -std=c++17 -O2 -pipe "$PROBLEM_PATH/solution.cpp" -o "$TEMP_DIR/solution" 2>&1; then
                echo -e "${RED}❌ Compilation failed${NC}"
                exit 1
            fi
            "$TEMP_DIR/solution" < "$INPUT_FILE" > "$ACTUAL_OUTPUT" 2>&1
            ;;
    esac
fi

# Compare output (ignore trailing whitespace/newlines)
EXPECTED=$(sed -e 's/[[:space:]]*$//' "$OUTPUT_FILE" | sed -e '/^$/d')
ACTUAL=$(sed -e 's/[[:space:]]*$//' "$ACTUAL_OUTPUT" | sed -e '/^$/d')

if [ "$EXPECTED" = "$ACTUAL" ]; then
    echo -e "${GREEN}✅ PASS${NC}"
else
    echo -e "${RED}❌ FAIL${NC}"
    echo ""
    echo -e "${YELLOW}Expected:${NC}"
    echo "$EXPECTED"
    echo ""
    echo -e "${YELLOW}Actual:${NC}"
    echo "$ACTUAL"
    echo ""
    echo -e "${YELLOW}Diff:${NC}"
    diff <(echo "$EXPECTED") <(echo "$ACTUAL") || true
    exit 1
fi
