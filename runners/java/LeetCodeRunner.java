import java.io.*;
import java.lang.reflect.*;
import java.nio.file.*;
import java.util.*;
import java.util.regex.*;

public class LeetCodeRunner {

    public static void main(String[] args) throws Exception {
        if (args.length < 1) {
            System.err.println("Usage: LeetCodeRunner <problem-directory>");
            System.exit(1);
        }

        String problemDir = args[0];
        String metadataStr = new String(Files.readAllBytes(Paths.get(problemDir, "metadata.json")));
        Map<String, Object> metadata = parseJsonObject(metadataStr);

        String methodName = (String) metadata.get("method");
        List<Map<String, String>> params = parseParams(metadata.get("params"));
        String returnType = (String) metadata.get("return");

        List<String> inputLines = Files.readAllLines(Paths.get(problemDir, "input.txt"));

        Solution solution = new Solution();
        Method method = findMethod(solution.getClass(), methodName, params);

        Object[] arguments = new Object[params.size()];
        for (int i = 0; i < params.size(); i++) {
            String type = params.get(i).get("type");
            String line = i < inputLines.size() ? inputLines.get(i).trim() : "";
            arguments[i] = parseValue(line, type);
        }

        Object result = method.invoke(solution, arguments);
        System.out.println(serializeValue(result, returnType));
    }

    @SuppressWarnings("unchecked")
    private static List<Map<String, String>> parseParams(Object paramsObj) {
        List<Map<String, String>> result = new ArrayList<>();
        if (paramsObj instanceof List) {
            for (Object p : (List<?>) paramsObj) {
                if (p instanceof Map) {
                    Map<String, String> param = new HashMap<>();
                    for (Map.Entry<?, ?> e : ((Map<?, ?>) p).entrySet()) {
                        param.put(String.valueOf(e.getKey()), String.valueOf(e.getValue()));
                    }
                    result.add(param);
                }
            }
        }
        return result;
    }

    private static Method findMethod(Class<?> clazz, String name, List<Map<String, String>> params) {
        for (Method m : clazz.getDeclaredMethods()) {
            if (m.getName().equals(name) && m.getParameterCount() == params.size()) {
                return m;
            }
        }
        throw new RuntimeException("Method " + name + " with " + params.size() + " params not found in Solution");
    }

    private static Object parseValue(String input, String type) {
        input = input.trim();
        switch (type) {
            case "int": return Integer.parseInt(input);
            case "double": return Double.parseDouble(input);
            case "boolean": return Boolean.parseBoolean(input);
            case "String": return input.startsWith("\"") ? input.substring(1, input.length() - 1) : input;
            case "int[]": return parseIntArray(input);
            case "int[][]": return parseIntArray2D(input);
            case "String[]": return parseStringArray(input);
            case "List<Integer>": return parseIntList(input);
            case "List<String>": return parseStringList(input);
            case "List<List<Integer>>": return parseIntList2D(input);
            case "TreeNode": return buildTreeNode(input);
            case "ListNode": return buildListNode(input);
            default: throw new RuntimeException("Unsupported type: " + type);
        }
    }

    private static int[] parseIntArray(String s) {
        s = s.trim();
        if (s.equals("[]")) return new int[0];
        s = s.substring(1, s.length() - 1); // remove [ ]
        String[] parts = s.split(",");
        int[] arr = new int[parts.length];
        for (int i = 0; i < parts.length; i++) {
            arr[i] = Integer.parseInt(parts[i].trim());
        }
        return arr;
    }

    private static int[][] parseIntArray2D(String s) {
        s = s.trim();
        if (s.equals("[]")) return new int[0][];
        // Remove outer brackets
        s = s.substring(1, s.length() - 1).trim();
        List<int[]> rows = new ArrayList<>();
        int depth = 0;
        int start = -1;
        for (int i = 0; i < s.length(); i++) {
            char c = s.charAt(i);
            if (c == '[') {
                if (depth == 0) start = i;
                depth++;
            } else if (c == ']') {
                depth--;
                if (depth == 0) {
                    rows.add(parseIntArray(s.substring(start, i + 1)));
                }
            }
        }
        return rows.toArray(new int[0][]);
    }

    private static String[] parseStringArray(String s) {
        s = s.trim();
        if (s.equals("[]")) return new String[0];
        s = s.substring(1, s.length() - 1); // remove [ ]
        List<String> result = new ArrayList<>();
        Matcher m = Pattern.compile("\"([^\"]*)\"").matcher(s);
        while (m.find()) {
            result.add(m.group(1));
        }
        return result.toArray(new String[0]);
    }

    private static List<Integer> parseIntList(String s) {
        int[] arr = parseIntArray(s);
        List<Integer> list = new ArrayList<>();
        for (int v : arr) list.add(v);
        return list;
    }

    private static List<String> parseStringList(String s) {
        return Arrays.asList(parseStringArray(s));
    }

    private static List<List<Integer>> parseIntList2D(String s) {
        int[][] arr = parseIntArray2D(s);
        List<List<Integer>> result = new ArrayList<>();
        for (int[] row : arr) {
            List<Integer> list = new ArrayList<>();
            for (int v : row) list.add(v);
            result.add(list);
        }
        return result;
    }

    private static TreeNode buildTreeNode(String s) {
        s = s.trim();
        if (s.equals("[]") || s.equals("null")) return null;
        s = s.substring(1, s.length() - 1);
        String[] parts = s.split(",");
        if (parts.length == 0 || parts[0].trim().equals("null")) return null;

        TreeNode root = new TreeNode(Integer.parseInt(parts[0].trim()));
        Queue<TreeNode> queue = new LinkedList<>();
        queue.add(root);
        int i = 1;
        while (!queue.isEmpty() && i < parts.length) {
            TreeNode node = queue.poll();
            if (i < parts.length) {
                String val = parts[i].trim();
                if (!val.equals("null")) {
                    node.left = new TreeNode(Integer.parseInt(val));
                    queue.add(node.left);
                }
                i++;
            }
            if (i < parts.length) {
                String val = parts[i].trim();
                if (!val.equals("null")) {
                    node.right = new TreeNode(Integer.parseInt(val));
                    queue.add(node.right);
                }
                i++;
            }
        }
        return root;
    }

    private static ListNode buildListNode(String s) {
        int[] arr = parseIntArray(s);
        if (arr.length == 0) return null;
        ListNode head = new ListNode(arr[0]);
        ListNode curr = head;
        for (int i = 1; i < arr.length; i++) {
            curr.next = new ListNode(arr[i]);
            curr = curr.next;
        }
        return head;
    }

    @SuppressWarnings("unchecked")
    private static String serializeValue(Object value, String type) {
        if (value == null) return "null";
        switch (type) {
            case "int": case "double": case "boolean":
                return String.valueOf(value);
            case "String":
                return "\"" + value + "\"";
            case "int[]": {
                int[] arr = (int[]) value;
                StringBuilder sb = new StringBuilder("[");
                for (int i = 0; i < arr.length; i++) {
                    if (i > 0) sb.append(",");
                    sb.append(arr[i]);
                }
                sb.append("]");
                return sb.toString();
            }
            case "int[][]": {
                int[][] arr = (int[][]) value;
                StringBuilder sb = new StringBuilder("[");
                for (int i = 0; i < arr.length; i++) {
                    if (i > 0) sb.append(",");
                    sb.append(serializeValue(arr[i], "int[]"));
                }
                sb.append("]");
                return sb.toString();
            }
            case "String[]": {
                String[] arr = (String[]) value;
                StringBuilder sb = new StringBuilder("[");
                for (int i = 0; i < arr.length; i++) {
                    if (i > 0) sb.append(",");
                    sb.append("\"").append(arr[i]).append("\"");
                }
                sb.append("]");
                return sb.toString();
            }
            case "List<Integer>": {
                List<Integer> list = (List<Integer>) value;
                StringBuilder sb = new StringBuilder("[");
                for (int i = 0; i < list.size(); i++) {
                    if (i > 0) sb.append(",");
                    sb.append(list.get(i));
                }
                sb.append("]");
                return sb.toString();
            }
            case "List<String>": {
                List<String> list = (List<String>) value;
                StringBuilder sb = new StringBuilder("[");
                for (int i = 0; i < list.size(); i++) {
                    if (i > 0) sb.append(",");
                    sb.append("\"").append(list.get(i)).append("\"");
                }
                sb.append("]");
                return sb.toString();
            }
            case "List<List<Integer>>": {
                List<List<Integer>> list = (List<List<Integer>>) value;
                StringBuilder sb = new StringBuilder("[");
                for (int i = 0; i < list.size(); i++) {
                    if (i > 0) sb.append(",");
                    List<Integer> inner = list.get(i);
                    sb.append("[");
                    for (int j = 0; j < inner.size(); j++) {
                        if (j > 0) sb.append(",");
                        sb.append(inner.get(j));
                    }
                    sb.append("]");
                }
                sb.append("]");
                return sb.toString();
            }
            case "TreeNode": {
                return serializeTreeNode((TreeNode) value);
            }
            case "ListNode": {
                return serializeListNode((ListNode) value);
            }
            default:
                return String.valueOf(value);
        }
    }

    private static String serializeTreeNode(TreeNode root) {
        if (root == null) return "[]";
        List<String> result = new ArrayList<>();
        Queue<TreeNode> queue = new LinkedList<>();
        queue.add(root);
        while (!queue.isEmpty()) {
            TreeNode node = queue.poll();
            if (node == null) {
                result.add("null");
            } else {
                result.add(String.valueOf(node.val));
                queue.add(node.left);
                queue.add(node.right);
            }
        }
        // Remove trailing nulls
        while (!result.isEmpty() && result.get(result.size() - 1).equals("null")) {
            result.remove(result.size() - 1);
        }
        return "[" + String.join(",", result) + "]";
    }

    private static String serializeListNode(ListNode head) {
        if (head == null) return "[]";
        StringBuilder sb = new StringBuilder("[");
        ListNode curr = head;
        boolean first = true;
        while (curr != null) {
            if (!first) sb.append(",");
            sb.append(curr.val);
            curr = curr.next;
            first = false;
        }
        sb.append("]");
        return sb.toString();
    }

    // Minimal JSON parser for metadata.json
    @SuppressWarnings("unchecked")
    private static Map<String, Object> parseJsonObject(String json) {
        json = json.trim();
        Map<String, Object> map = new LinkedHashMap<>();
        if (!json.startsWith("{") || !json.endsWith("}")) return map;
        json = json.substring(1, json.length() - 1).trim();

        int i = 0;
        while (i < json.length()) {
            // Skip whitespace
            while (i < json.length() && Character.isWhitespace(json.charAt(i))) i++;
            if (i >= json.length()) break;

            // Parse key
            if (json.charAt(i) != '"') break;
            int keyStart = i + 1;
            int keyEnd = json.indexOf('"', keyStart);
            String key = json.substring(keyStart, keyEnd);
            i = keyEnd + 1;

            // Skip : and whitespace
            while (i < json.length() && (json.charAt(i) == ':' || Character.isWhitespace(json.charAt(i)))) i++;

            // Parse value
            Object[] parsed = parseJsonValue(json, i);
            map.put(key, parsed[0]);
            i = (int) parsed[1];

            // Skip comma and whitespace
            while (i < json.length() && (json.charAt(i) == ',' || Character.isWhitespace(json.charAt(i)))) i++;
        }
        return map;
    }

    private static Object[] parseJsonValue(String json, int start) {
        while (start < json.length() && Character.isWhitespace(json.charAt(start))) start++;
        char c = json.charAt(start);

        if (c == '"') {
            int end = json.indexOf('"', start + 1);
            return new Object[]{json.substring(start + 1, end), end + 1};
        } else if (c == '[') {
            List<Object> list = new ArrayList<>();
            int i = start + 1;
            while (i < json.length()) {
                while (i < json.length() && Character.isWhitespace(json.charAt(i))) i++;
                if (json.charAt(i) == ']') return new Object[]{list, i + 1};
                Object[] parsed = parseJsonValue(json, i);
                list.add(parsed[0]);
                i = (int) parsed[1];
                while (i < json.length() && (json.charAt(i) == ',' || Character.isWhitespace(json.charAt(i)))) i++;
            }
            return new Object[]{list, json.length()};
        } else if (c == '{') {
            int depth = 1;
            int i = start + 1;
            while (i < json.length() && depth > 0) {
                if (json.charAt(i) == '{') depth++;
                else if (json.charAt(i) == '}') depth--;
                i++;
            }
            String objStr = json.substring(start, i);
            return new Object[]{parseJsonObject(objStr), i};
        } else if (c == 't' || c == 'f') {
            boolean val = json.substring(start).startsWith("true");
            return new Object[]{val, start + (val ? 4 : 5)};
        } else if (c == 'n') {
            return new Object[]{null, start + 4};
        } else {
            // Number
            int i = start;
            while (i < json.length() && (Character.isDigit(json.charAt(i)) || json.charAt(i) == '.' || json.charAt(i) == '-')) i++;
            String numStr = json.substring(start, i);
            if (numStr.contains(".")) {
                return new Object[]{Double.parseDouble(numStr), i};
            }
            return new Object[]{Integer.parseInt(numStr), i};
        }
    }
}
