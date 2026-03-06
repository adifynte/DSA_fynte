#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

usage() {
    echo "Usage: ./new.sh <platform> <problem-name> <lang>"
    echo ""
    echo "  platform:     leetcode | codeforces"
    echo "  problem-name: kebab-case name (e.g., two-sum)"
    echo "  lang:         java | python | js"
    echo ""
    echo "Example: ./new.sh leetcode two-sum java"
    echo "         ./new.sh codeforces watermelon python"
    exit 1
}

if [ $# -ne 3 ]; then
    usage
fi

PLATFORM="$1"
PROBLEM="$2"
LANG="$3"

# Validate platform
if [[ "$PLATFORM" != "leetcode" && "$PLATFORM" != "codeforces" ]]; then
    echo "❌ Invalid platform: $PLATFORM (must be leetcode or codeforces)"
    exit 1
fi

# Validate language and set template file
case "$LANG" in
    java)
        TEMPLATE="templates/$PLATFORM/java/Solution.java"
        SOLUTION_FILE="Solution.java"
        ;;
    python)
        TEMPLATE="templates/$PLATFORM/python/solution.py"
        SOLUTION_FILE="solution.py"
        ;;
    js)
        TEMPLATE="templates/$PLATFORM/js/solution.js"
        SOLUTION_FILE="solution.js"
        ;;
    *)
        echo "❌ Invalid language: $LANG (must be java, python, or js)"
        exit 1
        ;;
esac

PROBLEM_DIR="$SCRIPT_DIR/$PLATFORM/$PROBLEM"

if [ -d "$PROBLEM_DIR" ]; then
    echo "⚠️  Directory already exists: $PLATFORM/$PROBLEM"
    echo "   Add your solution file or edit existing files."
    exit 1
fi

mkdir -p "$PROBLEM_DIR"
cp "$SCRIPT_DIR/$TEMPLATE" "$PROBLEM_DIR/$SOLUTION_FILE"
touch "$PROBLEM_DIR/input.txt"
touch "$PROBLEM_DIR/output.txt"

if [ "$PLATFORM" = "leetcode" ]; then
    cp "$SCRIPT_DIR/templates/leetcode/metadata.json" "$PROBLEM_DIR/metadata.json"
    echo "✅ Created $PLATFORM/$PROBLEM/"
    echo "   📄 $SOLUTION_FILE  — write your solution method here (LeetCode style)"
    echo "   📋 metadata.json   — fill in method name, params, and return type"
    echo "   📥 input.txt       — paste test input (one arg per line, JSON format)"
    echo "   📤 output.txt      — paste expected output (JSON format)"
else
    echo "✅ Created $PLATFORM/$PROBLEM/"
    echo "   📄 $SOLUTION_FILE  — write your solution here (stdin/stdout)"
    echo "   📥 input.txt       — paste test input"
    echo "   📤 output.txt      — paste expected output"
fi
echo ""
echo "Run:  ./run.sh $PLATFORM/$PROBLEM"
