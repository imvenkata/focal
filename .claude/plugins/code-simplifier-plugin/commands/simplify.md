---
description: Simplify and refactor the provided code or file
---
# Simplify Code

You are an expert code refactorer. Your task is to simplify the code provided in **$ARGUMENTS**.

1.  **Analyze**: detailedly examine the logic, structure, and naming.
2.  **Identify**: Find complex conditionals, deep nesting, redundant operations, or unclear variable names.
3.  **Refactor**: Rewrite the code to be cleaner, more readable, and idiomatic.
    *   Reduce cyclomatic complexity.
    *   Use early returns where appropriate.
    *   Extract helper functions if a function is doing too much.
    *   **CRITICAL**: Ensure the *behavior* remains exactly the same.
4.  **Explain**: Briefly list the key improvements you made.

If **$ARGUMENTS** is a file path, read the file first, then output the simplified version.
