const fs = require('fs');
const path = require('path');

// TreeNode definition
class TreeNode {
    constructor(val = 0, left = null, right = null) {
        this.val = val;
        this.left = left;
        this.right = right;
    }
}

// ListNode definition
class ListNode {
    constructor(val = 0, next = null) {
        this.val = val;
        this.next = next;
    }
}

// Make TreeNode and ListNode available globally so user solutions can reference them
global.TreeNode = TreeNode;
global.ListNode = ListNode;

function parseValue(raw, type) {
    raw = raw.trim();
    switch (type) {
        case 'int': return parseInt(raw, 10);
        case 'double': return parseFloat(raw);
        case 'boolean': return raw.toLowerCase() === 'true';
        case 'String': return raw.startsWith('"') ? JSON.parse(raw) : raw;
        case 'int[]':
        case 'List<Integer>':
        case 'int[][]':
        case 'List<List<Integer>>':
        case 'String[]':
        case 'List<String>':
            return JSON.parse(raw);
        case 'TreeNode': return buildTree(JSON.parse(raw));
        case 'ListNode': return buildList(JSON.parse(raw));
        default: throw new Error(`Unsupported type: ${type}`);
    }
}

function serializeValue(value, type) {
    if (value === null || value === undefined) return 'null';
    switch (type) {
        case 'int':
        case 'double':
        case 'boolean':
            return String(value);
        case 'String':
            return JSON.stringify(value);
        case 'int[]':
        case 'List<Integer>':
        case 'int[][]':
        case 'List<List<Integer>>':
        case 'String[]':
        case 'List<String>':
            return JSON.stringify(value);
        case 'TreeNode': return serializeTree(value);
        case 'ListNode': return serializeList(value);
        default: return String(value);
    }
}

function buildTree(arr) {
    if (!arr || !arr.length || arr[0] === null) return null;
    const root = new TreeNode(arr[0]);
    const queue = [root];
    let i = 1;
    while (queue.length && i < arr.length) {
        const node = queue.shift();
        if (i < arr.length && arr[i] !== null) {
            node.left = new TreeNode(arr[i]);
            queue.push(node.left);
        }
        i++;
        if (i < arr.length && arr[i] !== null) {
            node.right = new TreeNode(arr[i]);
            queue.push(node.right);
        }
        i++;
    }
    return root;
}

function serializeTree(root) {
    if (!root) return '[]';
    const result = [];
    const queue = [root];
    while (queue.length) {
        const node = queue.shift();
        if (node) {
            result.push(node.val);
            queue.push(node.left);
            queue.push(node.right);
        } else {
            result.push(null);
        }
    }
    while (result.length && result[result.length - 1] === null) result.pop();
    return '[' + result.map(v => v === null ? 'null' : String(v)).join(',') + ']';
}

function buildList(arr) {
    if (!arr || !arr.length) return null;
    const head = new ListNode(arr[0]);
    let curr = head;
    for (let i = 1; i < arr.length; i++) {
        curr.next = new ListNode(arr[i]);
        curr = curr.next;
    }
    return head;
}

function serializeList(head) {
    if (!head) return '[]';
    const vals = [];
    let curr = head;
    while (curr) {
        vals.push(curr.val);
        curr = curr.next;
    }
    return '[' + vals.join(',') + ']';
}

// Main
const problemDir = process.argv[2];
if (!problemDir) {
    console.error('Usage: leetcode_runner.js <problem-directory>');
    process.exit(1);
}

const metadata = JSON.parse(fs.readFileSync(path.join(problemDir, 'metadata.json'), 'utf8'));
const inputLines = fs.readFileSync(path.join(problemDir, 'input.txt'), 'utf8')
    .split('\n')
    .filter(line => line.trim() !== '');

const Solution = require(path.join(path.resolve(problemDir), 'solution.js'));
const sol = new Solution();
const method = sol[metadata.method].bind(sol);

const args = metadata.params.map((param, i) => {
    const line = i < inputLines.length ? inputLines[i] : '';
    return parseValue(line, param.type);
});

const result = method(...args);
console.log(serializeValue(result, metadata.return));
