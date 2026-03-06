const readline = require('readline');

const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout,
    terminal: false
});

const lines = [];

rl.on('line', (line) => {
    lines.push(line.trim());
});

rl.on('close', () => {
    solve(lines);
});

function solve(lines) {
    // TODO: Parse input from lines array, print output with console.log
    // Example:
    // const n = parseInt(lines[0]);
    // console.log(result);
}
