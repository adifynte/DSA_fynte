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
else
    echo -e "${RED}❌ No solution file found in $1${NC}"
    echo "   Expected one of: Solution.java, solution.py, solution.js"
    exit 1
fi

echo -e "${YELLOW}▶ Running $1 ($LANG)${NC}"

# Create temp file for actual output
ACTUAL_OUTPUT=$(mktemp)
trap "rm -f $ACTUAL_OUTPUT" EXIT

# Run the solution
case "$LANG" in
    java)
        # Compile
        if ! javac "$PROBLEM_PATH/Solution.java" 2>&1; then
            echo -e "${RED}❌ Compilation failed${NC}"
            exit 1
        fi
        # Run
        java -cp "$PROBLEM_PATH" Solution < "$INPUT_FILE" > "$ACTUAL_OUTPUT" 2>&1
        # Clean up .class files
        rm -f "$PROBLEM_PATH"/*.class
        ;;
    python)
        python3 "$PROBLEM_PATH/solution.py" < "$INPUT_FILE" > "$ACTUAL_OUTPUT" 2>&1
        ;;
    js)
        node "$PROBLEM_PATH/solution.js" < "$INPUT_FILE" > "$ACTUAL_OUTPUT" 2>&1
        ;;
esac

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
