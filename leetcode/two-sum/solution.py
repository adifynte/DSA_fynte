import sys
input = sys.stdin.readline

def solve():
    nums = list(map(int, input().split()))
    target = int(input())
    lookup = {}
    for i, num in enumerate(nums):
        complement = target - num
        if complement in lookup:
            print(lookup[complement], i)
            return
        lookup[num] = i

if __name__ == "__main__":
    solve()
