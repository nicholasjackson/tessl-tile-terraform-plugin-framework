#!/usr/bin/env python3
"""Parse Claude stream-json output and display readable progress."""

import json
import sys

BLUE = "\033[34m"
GREEN = "\033[32m"
YELLOW = "\033[33m"
CYAN = "\033[36m"
DIM = "\033[2m"
BOLD = "\033[1m"
RESET = "\033[0m"

def format_tool_use(block):
    name = block.get("name", "")
    inp = block.get("input", {})

    if name == "Write":
        return f"  {BLUE}[Write]{RESET} {inp.get('file_path', '')}"
    elif name == "Edit":
        path = inp.get("file_path", "")
        old = inp.get("old_string", "")[:60].replace("\n", "\\n")
        return f"  {BLUE}[Edit]{RESET} {path}\n    {DIM}{old}...{RESET}"
    elif name == "Read":
        return f"  {BLUE}[Read]{RESET} {inp.get('file_path', '')}"
    elif name == "Bash":
        cmd = inp.get("command", "")[:200]
        return f"  {BLUE}[Bash]{RESET} {cmd}"
    elif name == "Glob":
        return f"  {BLUE}[Glob]{RESET} {inp.get('pattern', '')}"
    elif name == "Grep":
        return f"  {BLUE}[Grep]{RESET} {inp.get('pattern', '')} {DIM}{inp.get('glob', '')}{RESET}"
    else:
        return f"  {BLUE}[{name}]{RESET} {json.dumps(inp)[:200]}"

def format_tool_result(block):
    content = block.get("content", "")
    if isinstance(content, list):
        parts = []
        for c in content:
            if isinstance(c, dict):
                parts.append(c.get("text", ""))
            else:
                parts.append(str(c))
        content = "\n".join(parts)
    content = str(content).strip()
    if not content:
        return None
    # Show first few lines of result
    lines = content.split("\n")
    preview = "\n".join(lines[:5])
    if len(lines) > 5:
        preview += f"\n    {DIM}... ({len(lines) - 5} more lines){RESET}"
    return f"    {DIM}{preview}{RESET}"

for line in sys.stdin:
    line = line.strip()
    if not line:
        continue
    try:
        event = json.loads(line)
    except json.JSONDecodeError:
        continue

    etype = event.get("type", "")

    if etype == "assistant":
        message = event.get("message", {})
        for block in message.get("content", []):
            btype = block.get("type", "")
            if btype == "tool_use":
                print(format_tool_use(block), flush=True)
            elif btype == "text":
                text = block.get("text", "").strip()
                if text:
                    print(f"  {GREEN}{text}{RESET}", flush=True)
            elif btype == "tool_result":
                result = format_tool_result(block)
                if result:
                    print(result, flush=True)

    elif etype == "result":
        message = event.get("result", "").strip()
        if message:
            print(f"\n{BOLD}{CYAN}=== Claude finished ==={RESET}", flush=True)
            # Show last part of final message
            lines = message.split("\n")
            for l in lines[-20:]:
                print(f"  {l}", flush=True)
