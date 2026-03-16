#!/usr/bin/env python3
"""Task queue CLI for .queue folder management."""

import argparse
import sys
from datetime import datetime
from pathlib import Path
import shutil

QUEUE_DIR = Path(".queue")
META_FILE = QUEUE_DIR / ".meta"
ARCHIVE_DIR = QUEUE_DIR / ".archive"


def ensure_queue() -> None:
    QUEUE_DIR.mkdir(exist_ok=True)
    ARCHIVE_DIR.mkdir(exist_ok=True)
    if not META_FILE.exists():
        META_FILE.write_text("next_id: 1\ncreated: " + datetime.now().strftime("%Y-%m-%d") + "\n")


def get_next_id() -> int:
    if not META_FILE.exists():
        return 1
    for line in META_FILE.read_text().splitlines():
        if line.startswith("next_id:"):
            return int(line.split(":")[1].strip())
    return 1


def increment_id() -> None:
    current = get_next_id()
    lines = []
    if META_FILE.exists():
        for line in META_FILE.read_text().splitlines():
            lines.append(f"next_id: {current + 1}" if line.startswith("next_id:") else line)
    else:
        lines = [f"next_id: {current + 1}", f"created: {datetime.now().strftime('%Y-%m-%d')}"]
    META_FILE.write_text("\n".join(lines) + "\n")


def find_task(task_id: str) -> Path | None:
    for folder in QUEUE_DIR.iterdir():
        if folder.is_dir() and folder.name.startswith(f"{task_id.zfill(3)}_"):
            return folder
    return None


def get_task_status(desc_path: Path) -> tuple[str, str]:
    content = desc_path.read_text()
    status, created = "pending", "?"
    for line in content.splitlines():
        if line.startswith("Status:"):
            status = line.split(":", 1)[1].strip()
        if line.startswith("Created:"):
            created = line.split(":", 1)[1].strip()[:10]
    return status, created


def cmd_new(args) -> None:
    ensure_queue()
    next_id = get_next_id()
    short_desc = args.short_desc.replace(" ", "-").lower()[:32]
    folder = QUEUE_DIR / f"{next_id:03d}_{short_desc}"
    folder.mkdir()

    desc_content = f"""# Task: {short_desc}
Created: {datetime.now().strftime("%Y-%m-%d %H:%M")}
Status: pending

## Intent
<what you want to accomplish>

## Context
<relevant files, constraints, dependencies>

## Acceptance Criteria
- [ ] <done criteria 1>
- [ ] <done criteria 2>
"""
    (folder / "desc.md").write_text(desc_content)
    increment_id()
    print(f"Created: {folder}/desc.md")


def cmd_load(args) -> None:
    ensure_queue()
    folder = find_task(args.id)
    if not folder:
        print(f"Task {args.id} not found", file=sys.stderr)
        sys.exit(1)

    desc = (folder / "desc.md").read_text()
    plan_path = folder / "plan.md"
    plan = plan_path.read_text() if plan_path.exists() else "# No plan yet\n"

    print(f"=== Task {folder.name} ===\n")
    print("--- desc.md ---")
    print(desc)
    print("\n--- plan.md ---")
    print(plan)


def cmd_plan(args) -> None:
    ensure_queue()
    folder = find_task(args.id)
    if not folder:
        print(f"Task {args.id} not found", file=sys.stderr)
        sys.exit(1)

    plan_path = folder / "plan.md"
    if not plan_path.exists():
        short_desc = folder.name.split("_", 1)[1] if "_" in folder.name else folder.name
        plan_content = f"""# Plan: {short_desc}
Updated: {datetime.now().strftime("%Y-%m-%d %H:%M")}

## Approach
<high-level strategy>

## Steps
- [ ] Step 1
- [ ] Step 2

## Notes
<iteration history>
"""
        plan_path.write_text(plan_content)
        print(f"Created: {plan_path}")
    else:
        print(f"Plan exists: {plan_path}")

    print("\n--- Current plan ---")
    print(plan_path.read_text())


def cmd_ls(args) -> None:
    ensure_queue()
    print(f"{'ID':<25} {'Status':<10} {'Created'}")
    print("-" * 50)

    for folder in sorted(QUEUE_DIR.iterdir()):
        if folder.is_dir() and folder.name != ".archive":
            desc_path = folder / "desc.md"
            if desc_path.exists():
                status, created = get_task_status(desc_path)
                print(f"{folder.name:<25} {status:<10} {created}")


def cmd_rm(args) -> None:
    ensure_queue()
    folder = find_task(args.id)
    if not folder:
        print(f"Task {args.id} not found", file=sys.stderr)
        sys.exit(1)

    has_plan = (folder / "plan.md").exists()
    if has_plan and not args.force:
        print(f"Task has plan.md. Use --force to delete.", file=sys.stderr)
        sys.exit(1)

    shutil.rmtree(folder)
    print(f"Removed: {folder}")


def cmd_done(args) -> None:
    ensure_queue()
    folder = find_task(args.id)
    if not folder:
        print(f"Task {args.id} not found", file=sys.stderr)
        sys.exit(1)

    desc_path = folder / "desc.md"
    if desc_path.exists():
        content = desc_path.read_text()
        lines = [
            f"Status: done" if line.startswith("Status:") else line for line in content.splitlines()
        ]
        desc_path.write_text("\n".join(lines))

    dest = ARCHIVE_DIR / folder.name
    shutil.move(str(folder), str(dest))
    print(f"Archived: {dest}")


def main():
    parser = argparse.ArgumentParser(description="Task queue management")
    subparsers = parser.add_subparsers(dest="command", required=True)

    p_new = subparsers.add_parser("new", help="Create new task")
    p_new.add_argument("short_desc", help="Short task description")
    p_new.set_defaults(func=cmd_new)

    p_load = subparsers.add_parser("load", help="Load task into context")
    p_load.add_argument("id", help="Task ID (e.g., 1 or 001)")
    p_load.set_defaults(func=cmd_load)

    p_plan = subparsers.add_parser("plan", help="Open/iterate on plan")
    p_plan.add_argument("id", help="Task ID")
    p_plan.set_defaults(func=cmd_plan)

    p_ls = subparsers.add_parser("ls", help="List tasks")
    p_ls.add_argument("--all", action="store_true", help="Include archived")
    p_ls.set_defaults(func=cmd_ls)

    p_rm = subparsers.add_parser("rm", help="Remove task")
    p_rm.add_argument("id", help="Task ID")
    p_rm.add_argument("--force", action="store_true", help="Force delete")
    p_rm.set_defaults(func=cmd_rm)

    p_done = subparsers.add_parser("done", help="Archive task")
    p_done.add_argument("id", help="Task ID")
    p_done.set_defaults(func=cmd_done)

    args = parser.parse_args()
    args.func(args)


if __name__ == "__main__":
    main()
