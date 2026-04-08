@echo off
setlocal
:: Wrapper so Windows users can type: run leetcode/two-sum
:: and see output in the SAME terminal (no new Git Bash window).

set "BASH="
if exist "C:\Program Files\Git\bin\bash.exe" (
    set "BASH=C:\Program Files\Git\bin\bash.exe"
) else if exist "C:\Program Files (x86)\Git\bin\bash.exe" (
    set "BASH=C:\Program Files (x86)\Git\bin\bash.exe"
) else (
    echo ERROR: Git Bash not found. Install Git for Windows or run in Git Bash directly.
    exit /b 1
)

"%BASH%" -lc "cd '%~dp0' && ./run.sh %*"
