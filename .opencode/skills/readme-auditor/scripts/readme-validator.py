#!/usr/bin/env python3
"""README validator and updater script.

Usage:
  ./readme-validator.py check <readme_path>
  ./readme-validator.py audit
  ./readme-validator.py update <readme_path>
"""

import argparse
import json
import re
import subprocess
import sys
from pathlib import Path
from typing import Dict, List, Tuple

# Validation rules
ISSUE_PATTERNS = {
    "todo": re.compile(r"\b(TODO|FIXME|XXX)\b[:\s]*(.*)"),
    "broken_link": re.compile(r"\[([^\]]+)\]\((https?://[^\)]+\)"),
    "version": re.compile(r"v?\d+\.\d+\.\d+"),
    "empty_section": re.compile(r"^#+\s+(.*?)\s*$", re.MULTILINE),
    "badge": re.compile(r"\[!\[([^\]]+)\]\((https?://[^\)]+)\)"),
}


class ReadmeValidator:
    def __init__(self, path: Path):
        self.path = path
        self.issues: List[Dict] = []
        self.content = path.read_text()

    def check_todos(self) -> List[Dict]:
        """Check for unresolved TODO/FIXME markers."""
        issues = []
        for match in ISSUE_PATTERNS["todo"].finditer(self.content):
            issues.append(
                {
                    "type": "todo",
                    "line": self._line_number(match.start()),
                    "text": match.group(0),
                }
            )
        return issues

    def check_badges(self) -> List[Dict]:
        """Validate badge URLs."""
        issues = []
        for match in ISSUE_PATTERNS["badge"].finditer(self.content):
            url = match.group(2)
            if url.startswith("http://") and not url.startswith(
                "http://img.shields.io"
            ):
                issues.append(
                    {
                        "type": "insecure-badge",
                        "line": self._line_number(match.start()),
                        "text": f"Insecure HTTP badge: {match.group(1)}",
                    }
                )
        return issues

    def check_sections(self) -> List[Dict]:
        """Check for empty or malformed sections."""
        issues = []
        lines = self.content.split("\n")
        current_section = None
        empty_lines = 0

        for i, line in enumerate(lines):
            match = ISSUE_PATTERNS["empty_section"].match(line)
            if match:
                if current_section and empty_lines > 2:
                    issues.append(
                        {
                            "type": "empty-section",
                            "line": i - empty_lines,
                            "text": f"Section '{current_section}' has {empty_lines} empty lines",
                        }
                    )
                current_section = match.group(1)
                empty_lines = 0
            elif current_section and not line.strip():
                empty_lines += 1
            else:
                empty_lines = 0

        return issues

    def _line_number(self, pos: int) -> int:
        """Get line number from character position."""
        return self.content[:pos].count("\n") + 1

    def validate(self) -> Dict:
        """Run all checks and return results."""
        results = {
            "path": str(self.path),
            "total_issues": 0,
            "issues": {},
        }

        for check in [self.check_todos, self.check_badges, self.check_sections]:
            issues = check()
            issue_type = issues[0]["type"] if issues else "unknown"
            results["issues"][issue_type] = issues
            results["total_issues"] += len(issues)

        return results


def find_readmes(root: Path) -> List[Path]:
    """Find all README files in directory tree."""
    return list(root.rglob("README.md")) + list(root.rglob("readme.md"))


def main():
    parser = argparse.ArgumentParser(description="Validate and update README.md files")
    parser.add_argument(
        "command", choices=["check", "audit", "update"], help="Command to run"
    )
    parser.add_argument("path", nargs="?", type=Path, help="Path to README file")
    args = parser.parse_args()

    if args.command == "check":
        if not args.path:
            print("Error: path required for 'check' command")
            sys.exit(1)
        validator = ReadmeValidator(args.path)
        results = validator.validate()
        print(json.dumps(results, indent=2))
        sys.exit(0 if results["total_issues"] == 0 else 1)

    elif args.command == "audit":
        root = Path.cwd() if not args.path else args.path
        readmes = find_readmes(root)
        print(f"Auditing {len(readmes)} README files...")
        all_issues = 0
        for readme in readmes:
            validator = ReadmeValidator(readme)
            results = validator.validate()
            if results["total_issues"] > 0:
                print(f"\n{readme}: {results['total_issues']} issues")
                for issue_type, issues in results["issues"].items():
                    if issues:
                        print(f"  {issue_type}: {len(issues)}")
                        for issue in issues[:3]:  # Show first 3
                            print(f"    Line {issue['line']}: {issue['text'][:60]}")
                all_issues += results["total_issues"]
        print(f"\nTotal: {all_issues} issues across {len(readmes)} files")
        sys.exit(0)

    else:  # update
        print("Update command not implemented yet")
        sys.exit(1)


if __name__ == "__main__":
    main()
