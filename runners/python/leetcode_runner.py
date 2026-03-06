import sys
import os
import json
import importlib.util
from collections import deque


class TreeNode:
    def __init__(self, val=0, left=None, right=None):
        self.val = val
        self.left = left
        self.right = right


class ListNode:
    def __init__(self, val=0, next=None):
        self.val = val
        self.next = next


def parse_value(raw, type_str):
    raw = raw.strip()
    if type_str == "int":
        return int(raw)
    elif type_str == "double":
        return float(raw)
    elif type_str == "boolean":
        return raw.lower() == "true"
    elif type_str == "String":
        return json.loads(raw) if raw.startswith('"') else raw
    elif type_str in ("int[]", "List<Integer>"):
        return json.loads(raw)
    elif type_str in ("int[][]", "List<List<Integer>>"):
        return json.loads(raw)
    elif type_str in ("String[]", "List<String>"):
        return json.loads(raw)
    elif type_str == "TreeNode":
        return build_tree(json.loads(raw))
    elif type_str == "ListNode":
        return build_list(json.loads(raw))
    else:
        raise ValueError(f"Unsupported type: {type_str}")


def serialize_value(value, type_str):
    if value is None:
        return "null"
    if type_str in ("int", "double"):
        return str(value)
    elif type_str == "boolean":
        return "true" if value else "false"
    elif type_str == "String":
        return json.dumps(value)
    elif type_str in ("int[]", "List<Integer>", "int[][]", "List<List<Integer>>",
                       "String[]", "List<String>"):
        return json.dumps(value, separators=(",", ":"))
    elif type_str == "TreeNode":
        return serialize_tree(value)
    elif type_str == "ListNode":
        return serialize_list(value)
    else:
        return str(value)


def build_tree(arr):
    if not arr or arr[0] is None:
        return None
    root = TreeNode(arr[0])
    queue = deque([root])
    i = 1
    while queue and i < len(arr):
        node = queue.popleft()
        if i < len(arr) and arr[i] is not None:
            node.left = TreeNode(arr[i])
            queue.append(node.left)
        i += 1
        if i < len(arr) and arr[i] is not None:
            node.right = TreeNode(arr[i])
            queue.append(node.right)
        i += 1
    return root


def serialize_tree(root):
    if not root:
        return "[]"
    result = []
    queue = deque([root])
    while queue:
        node = queue.popleft()
        if node:
            result.append(str(node.val))
            queue.append(node.left)
            queue.append(node.right)
        else:
            result.append("null")
    while result and result[-1] == "null":
        result.pop()
    return "[" + ",".join(result) + "]"


def build_list(arr):
    if not arr:
        return None
    head = ListNode(arr[0])
    curr = head
    for v in arr[1:]:
        curr.next = ListNode(v)
        curr = curr.next
    return head


def serialize_list(head):
    if not head:
        return "[]"
    vals = []
    curr = head
    while curr:
        vals.append(str(curr.val))
        curr = curr.next
    return "[" + ",".join(vals) + "]"


def main():
    if len(sys.argv) < 2:
        print("Usage: leetcode_runner.py <problem-directory>", file=sys.stderr)
        sys.exit(1)

    problem_dir = sys.argv[1]

    with open(os.path.join(problem_dir, "metadata.json")) as f:
        metadata = json.load(f)

    method_name = metadata["method"]
    params = metadata["params"]
    return_type = metadata["return"]

    with open(os.path.join(problem_dir, "input.txt")) as f:
        input_lines = [line.rstrip("\n") for line in f.readlines()]

    # Import solution module
    solution_path = os.path.join(problem_dir, "solution.py")
    spec = importlib.util.spec_from_file_location("solution", solution_path)
    mod = importlib.util.module_from_spec(spec)

    # Inject TreeNode and ListNode into the module's namespace before executing
    mod.TreeNode = TreeNode
    mod.ListNode = ListNode
    spec.loader.exec_module(mod)

    sol = mod.Solution()
    method = getattr(sol, method_name)

    arguments = []
    for i, param in enumerate(params):
        line = input_lines[i] if i < len(input_lines) else ""
        arguments.append(parse_value(line, param["type"]))

    result = method(*arguments)
    print(serialize_value(result, return_type))


if __name__ == "__main__":
    main()
