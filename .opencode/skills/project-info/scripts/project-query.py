#!/usr/bin/env python3
"""Project README query interface.

Usage:
  ./project-query.py <project_path> <query_type>
  ./project-query.py invalidate <project_path>
"""

import argparse
import json
import os
import subprocess
import sys
from datetime import datetime, timedelta
from pathlib import Path

CACHE_FILE = (
    Path.home() / ".local" / "share" / "opencode" / "project-info" / "cache.json"
)
CACHE_TTL = timedelta(hours=1)


class ProjectQuery:
    """Lazy README information extractor with caching."""

    def __init__(self, project_path: Path):
        self.project = project_path
        self.readme = self._find_readme()
        self.cache = self._load_cache()

    def _find_readme(self) -> Path | None:
        """Find README file in project directory."""
        candidates = [
            self.project / "README.md",
            self.project / "readme.md",
            self.project / "docs" / "README.md",
        ]
        for path in candidates:
            if path.exists():
                return path
        return None

    def _load_cache(self) -> dict:
        """Load cache from disk."""
        if not CACHE_FILE.exists():
            return {}
        return json.loads(CACHE_FILE.read_text())

    def _save_cache(self, data: dict) -> None:
        """Save cache to disk."""
        CACHE_FILE.parent.mkdir(parents=True, exist_ok=True)
        CACHE_FILE.write_text(json.dumps(data, indent=2))

    def _is_cache_valid(self, cache_key: str) -> bool:
        """Check if cache entry is still valid."""
        if cache_key not in self.cache:
            return False
        cached_at = datetime.fromisoformat(self.cache[cache_key]["cached_at"])
        return datetime.now() - cached_at < CACHE_TTL

    def _extract_via_explore(self, query_type: str) -> dict:
        if not self.readme:
            return {"error": f"No README found in {self.project}"}

        sections_map = {
            "install": "installation",
            "usage": "usage examples and commands",
            "commands": "CLI commands and API",
            "badges": "status badges and CI",
            "all": "complete project overview",
        }

        section = sections_map.get(query_type, "overview")

        prompt = f"""Extract project information from README.

README path: {self.readme}
Section to extract: {section} (full context)

Return as JSON:
{{
  "name": "project name from title",
  "description": "brief description",
  "install": "installation commands",
  "usage": "usage examples",
  "commands": "available commands",
  "badges": "status/CI badges",
  "links": "documentation and repo links"
}}"""

        try:
            result = subprocess.run(
                ["meta-skill", "explore"],
                input=prompt,
                capture_output=True,
                text=True,
                timeout=30,
            )
            if result.returncode != 0:
                return {"error": f"Explore agent failed: {result.stderr[:200]}"}
            return json.loads(result.stdout)
        except subprocess.TimeoutExpired:
            return {"error": "Query timeout"}
        except Exception as e:
            return {"error": f"Failed to query: {e}"}

    def query(self, query_type: str) -> dict:
        cache_key = f"{self.project}:{query_type}"

        if self._is_cache_valid(cache_key):
            return self.cache[cache_key]

        result = self._extract_via_explore(query_type)

        if "error" not in result:
            result["cached_at"] = datetime.now().isoformat()
            self.cache[cache_key] = result
            self._save_cache(self.cache)

        return result

    def invalidate(self) -> None:
        """Clear cache for this project."""
        cache_key = f"{self.project}:"
        self.cache = {
            k: v for k, v in self.cache.items() if not k.startswith(cache_key)
        }
        self._save_cache(self.cache)


def main():
    parser = argparse.ArgumentParser(description="Lazy project information extractor")
    parser.add_argument(
        "command", choices=["query", "invalidate", "ls"], help="Command to run"
    )
    parser.add_argument("project", nargs="?", type=Path, help="Project path")
    parser.add_argument(
        "query_type",
        nargs="?",
        choices=["install", "usage", "commands", "badges", "all"],
        help="Information to extract",
    )
    args = parser.parse_args()

    if args.command == "query":
        if not args.project or not args.query_type:
            print("Error: project and query_type required for 'query' command")
            sys.exit(1)
        q = ProjectQuery(args.project)
        result = q.query(args.query_type)
        print(json.dumps(result, indent=2))
        sys.exit(0 if "error" not in result else 1)

    elif args.command == "invalidate":
        if not args.project:
            print("Error: project path required for 'invalidate' command")
            sys.exit(1)
        q = ProjectQuery(args.project)
        q.invalidate()
        print(f"Cache cleared for {args.project}")
        sys.exit(0)

    elif args.command == "ls":
        cache = ProjectQuery(Path("."))._load_cache()
        print(json.dumps(cache, indent=2))
        sys.exit(0)


if __name__ == "__main__":
    main()
