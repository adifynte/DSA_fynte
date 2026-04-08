import json
import os
import re
import shutil
import subprocess
import sys
import tempfile


def parse_value(raw, type_str):
    raw = raw.strip()
    if type_str == "int":
        return int(raw)
    if type_str == "double":
        return float(raw)
    if type_str == "boolean":
        return raw.lower() == "true"
    if type_str == "String":
        return json.loads(raw) if raw.startswith('"') else raw
    if type_str in ("int[]", "List<Integer>", "int[][]", "List<List<Integer>>", "String[]", "List<String>"):
        return json.loads(raw)
    if type_str in ("TreeNode", "ListNode"):
        if raw.lower() == "null":
            return None
        return json.loads(raw)
    raise ValueError(f"Unsupported type: {type_str}")


def cpp_string_literal(value):
    return json.dumps(value)


def cpp_vector_int_literal(values):
    return "{" + ",".join(str(int(v)) for v in values) + "}"


def cpp_vector_string_literal(values):
    return "{" + ",".join(cpp_string_literal(str(v)) for v in values) + "}"


def cpp_vector_2d_int_literal(values):
    return "{" + ",".join(cpp_vector_int_literal(row) for row in values) + "}"


def cpp_vector_optional_int_literal(values):
    parts = []
    for v in values:
        if v is None:
            parts.append("std::nullopt")
        else:
            parts.append(str(int(v)))
    return "{" + ",".join(parts) + "}"


def double_literal(value):
    text = format(float(value), ".15g")
    if "e" not in text and "E" not in text and "." not in text:
        text += ".0"
    return text


def build_arg_declaration(param_type, value, idx):
    name = f"arg{idx}"
    if param_type == "int":
        return f"    int {name} = {int(value)};", name
    if param_type == "double":
        return f"    double {name} = {double_literal(value)};", name
    if param_type == "boolean":
        return f"    bool {name} = {'true' if value else 'false'};", name
    if param_type == "String":
        return f"    std::string {name} = {cpp_string_literal(str(value))};", name
    if param_type in ("int[]", "List<Integer>"):
        return f"    std::vector<int> {name} = {cpp_vector_int_literal(value)};", name
    if param_type in ("int[][]", "List<List<Integer>>"):
        return f"    std::vector<std::vector<int>> {name} = {cpp_vector_2d_int_literal(value)};", name
    if param_type in ("String[]", "List<String>"):
        return f"    std::vector<std::string> {name} = {cpp_vector_string_literal(value)};", name
    if param_type == "TreeNode":
        if value is None:
            return f"    TreeNode* {name} = nullptr;", name
        return f"    TreeNode* {name} = buildTree(std::vector<std::optional<int>>{cpp_vector_optional_int_literal(value)});", name
    if param_type == "ListNode":
        if value is None:
            return f"    ListNode* {name} = nullptr;", name
        return f"    ListNode* {name} = buildList(std::vector<int>{cpp_vector_int_literal(value)});", name
    raise ValueError(f"Unsupported type: {param_type}")


def result_serializer_call(return_type):
    if return_type == "int":
        return "std::to_string(result)"
    if return_type == "double":
        return "serializeDouble(result)"
    if return_type == "boolean":
        return '(result ? "true" : "false")'
    if return_type == "String":
        return "serializeString(result)"
    if return_type in ("int[]", "List<Integer>"):
        return "serializeIntVector(result)"
    if return_type in ("int[][]", "List<List<Integer>>"):
        return "serializeInt2DVector(result)"
    if return_type in ("String[]", "List<String>"):
        return "serializeStringVector(result)"
    if return_type == "TreeNode":
        return "serializeTree(result)"
    if return_type == "ListNode":
        return "serializeList(result)"
    raise ValueError(f"Unsupported return type: {return_type}")


def generate_cpp(method_name, params, return_type, arguments):
    if not re.match(r"^[A-Za-z_][A-Za-z0-9_]*$", method_name):
        raise ValueError(f"Invalid C++ method name: {method_name}")

    arg_lines = []
    arg_names = []
    for idx, (param, arg) in enumerate(zip(params, arguments)):
        line, name = build_arg_declaration(param["type"], arg, idx)
        arg_lines.append(line)
        arg_names.append(name)

    call_args = ", ".join(arg_names)
    serializer = result_serializer_call(return_type)

    main_lines = [
        "int main() {",
        "    Solution solution;",
    ]
    main_lines.extend(arg_lines)
    main_lines.append(f"    auto result = solution.{method_name}({call_args});")
    main_lines.append(f"    std::cout << {serializer} << std::endl;")
    main_lines.append("    return 0;")
    main_lines.append("}")

    helpers = r'''#include <algorithm>
#include <cstdio>
#include <iomanip>
#include <iostream>
#include <optional>
#include <queue>
#include <sstream>
#include <string>
#include <vector>

struct ListNode {
    int val;
    ListNode* next;
    ListNode() : val(0), next(nullptr) {}
    explicit ListNode(int x) : val(x), next(nullptr) {}
    ListNode(int x, ListNode* next) : val(x), next(next) {}
};

struct TreeNode {
    int val;
    TreeNode* left;
    TreeNode* right;
    TreeNode() : val(0), left(nullptr), right(nullptr) {}
    explicit TreeNode(int x) : val(x), left(nullptr), right(nullptr) {}
    TreeNode(int x, TreeNode* left, TreeNode* right) : val(x), left(left), right(right) {}
};

TreeNode* buildTree(const std::vector<std::optional<int>>& arr) {
    if (arr.empty() || !arr[0].has_value()) {
        return nullptr;
    }
    TreeNode* root = new TreeNode(arr[0].value());
    std::queue<TreeNode*> q;
    q.push(root);
    size_t i = 1;
    while (!q.empty() && i < arr.size()) {
        TreeNode* node = q.front();
        q.pop();
        if (i < arr.size() && arr[i].has_value()) {
            node->left = new TreeNode(arr[i].value());
            q.push(node->left);
        }
        ++i;
        if (i < arr.size() && arr[i].has_value()) {
            node->right = new TreeNode(arr[i].value());
            q.push(node->right);
        }
        ++i;
    }
    return root;
}

ListNode* buildList(const std::vector<int>& arr) {
    if (arr.empty()) {
        return nullptr;
    }
    ListNode* head = new ListNode(arr[0]);
    ListNode* curr = head;
    for (size_t i = 1; i < arr.size(); ++i) {
        curr->next = new ListNode(arr[i]);
        curr = curr->next;
    }
    return head;
}

std::string escapeJsonString(const std::string& value) {
    std::string out;
    for (unsigned char c : value) {
        switch (c) {
            case '"': out += "\\\""; break;
            case '\\': out += "\\\\"; break;
            case '\b': out += "\\b"; break;
            case '\f': out += "\\f"; break;
            case '\n': out += "\\n"; break;
            case '\r': out += "\\r"; break;
            case '\t': out += "\\t"; break;
            default:
                if (c < 0x20) {
                    char buf[7];
                    std::snprintf(buf, sizeof(buf), "\\u%04x", static_cast<int>(c));
                    out += buf;
                } else {
                    out += static_cast<char>(c);
                }
        }
    }
    return out;
}

std::string serializeString(const std::string& value) {
    return "\"" + escapeJsonString(value) + "\"";
}

std::string serializeDouble(double value) {
    std::ostringstream oss;
    oss << std::setprecision(15) << value;
    std::string out = oss.str();
    if (out.find('.') == std::string::npos && out.find('e') == std::string::npos && out.find('E') == std::string::npos) {
        out += ".0";
    }
    return out;
}

std::string serializeIntVector(const std::vector<int>& arr) {
    std::ostringstream oss;
    oss << "[";
    for (size_t i = 0; i < arr.size(); ++i) {
        if (i > 0) oss << ",";
        oss << arr[i];
    }
    oss << "]";
    return oss.str();
}

std::string serializeInt2DVector(const std::vector<std::vector<int>>& arr) {
    std::ostringstream oss;
    oss << "[";
    for (size_t i = 0; i < arr.size(); ++i) {
        if (i > 0) oss << ",";
        oss << serializeIntVector(arr[i]);
    }
    oss << "]";
    return oss.str();
}

std::string serializeStringVector(const std::vector<std::string>& arr) {
    std::ostringstream oss;
    oss << "[";
    for (size_t i = 0; i < arr.size(); ++i) {
        if (i > 0) oss << ",";
        oss << serializeString(arr[i]);
    }
    oss << "]";
    return oss.str();
}

std::string serializeTree(TreeNode* root) {
    if (!root) {
        return "[]";
    }
    std::vector<std::string> out;
    std::queue<TreeNode*> q;
    q.push(root);
    while (!q.empty()) {
        TreeNode* node = q.front();
        q.pop();
        if (!node) {
            out.push_back("null");
            continue;
        }
        out.push_back(std::to_string(node->val));
        q.push(node->left);
        q.push(node->right);
    }
    while (!out.empty() && out.back() == "null") {
        out.pop_back();
    }
    std::ostringstream oss;
    oss << "[";
    for (size_t i = 0; i < out.size(); ++i) {
        if (i > 0) oss << ",";
        oss << out[i];
    }
    oss << "]";
    return oss.str();
}

std::string serializeList(ListNode* head) {
    std::ostringstream oss;
    oss << "[";
    bool first = true;
    while (head) {
        if (!first) oss << ",";
        oss << head->val;
        head = head->next;
        first = false;
    }
    oss << "]";
    return oss.str();
}
'''

    return "\n".join(
        [
            helpers,
            '#include "solution.cpp"',
            "",
            "\n".join(main_lines),
            "",
        ]
    )


def run_cpp(problem_dir):
    metadata_path = os.path.join(problem_dir, "metadata.json")
    solution_path = os.path.join(problem_dir, "solution.cpp")
    input_path = os.path.join(problem_dir, "input.txt")

    with open(metadata_path, encoding="utf-8") as f:
        metadata = json.load(f)

    method_name = metadata["method"]
    params = metadata["params"]
    return_type = metadata["return"]

    with open(input_path, encoding="utf-8") as f:
        lines = [line.rstrip("\n") for line in f.readlines()]

    arguments = []
    for i, param in enumerate(params):
        raw = lines[i] if i < len(lines) else ""
        arguments.append(parse_value(raw, param["type"]))

    compiler = shutil.which("g++") or shutil.which("clang++")
    if not compiler:
        raise RuntimeError("No C++ compiler found (requires g++ or clang++)")

    source = generate_cpp(method_name, params, return_type, arguments)

    with tempfile.TemporaryDirectory() as tmp:
        generated_cpp = os.path.join(tmp, "main.cpp")
        copied_solution = os.path.join(tmp, "solution.cpp")
        exe_name = "runner.exe" if os.name == "nt" else "runner"
        executable = os.path.join(tmp, exe_name)

        with open(generated_cpp, "w", encoding="utf-8", newline="\n") as f:
            f.write(source)
        shutil.copyfile(solution_path, copied_solution)

        compile_result = subprocess.run(
            [compiler, "-std=c++17", "-O2", "-pipe", generated_cpp, "-o", executable],
            cwd=tmp,
            capture_output=True,
            text=True,
        )
        if compile_result.returncode != 0:
            sys.stderr.write(compile_result.stderr)
            if compile_result.stdout:
                sys.stderr.write(compile_result.stdout)
            raise RuntimeError("Compilation failed")

        run_result = subprocess.run(
            [executable],
            cwd=tmp,
            capture_output=True,
            text=True,
        )
        if run_result.returncode != 0:
            if run_result.stderr:
                sys.stderr.write(run_result.stderr)
            if run_result.stdout:
                sys.stderr.write(run_result.stdout)
            raise RuntimeError("Execution failed")

        output = run_result.stdout.rstrip("\r\n")
        sys.stdout.write(output + "\n")


def main():
    if len(sys.argv) < 2:
        print("Usage: leetcode_runner.py <problem-directory>", file=sys.stderr)
        sys.exit(1)

    try:
        run_cpp(sys.argv[1])
    except Exception as e:
        print(str(e), file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
