#!/usr/bin/env python3
"""Skill source tracker - manage skills from git repos with branch tracking."""

import argparse
import json
import re
import shutil
import subprocess
import sys
from datetime import datetime
from pathlib import Path
from typing import Optional
import yaml

SKILLS_DIR = Path.home() / ".config" / "opencode" / "skills"
LOCAL_MEMORY = Path(__file__).parent.parent / "local-memory.md"


def run_git(args: list, cwd: Optional[Path] = None, check: bool = True) -> str:
    """Run git command and return output."""
    result = subprocess.run(
        ["git"] + args, cwd=cwd, capture_output=True, text=True, check=False
    )
    if check and result.returncode != 0:
        raise RuntimeError(f"git {' '.join(args)} failed: {result.stderr}")
    return result.stdout.strip()


def load_memory() -> dict:
    """Load local-memory.md and parse YAML block."""
    if not LOCAL_MEMORY.exists():
        return {"managed_skills": {}, "meta": {}}

    content = LOCAL_MEMORY.read_text()
    # Extract YAML block
    yaml_match = re.search(r"```yaml\n(.*?)\n```", content, re.DOTALL)
    if yaml_match:
        return yaml.safe_load(yaml_match.group(1)) or {"managed_skills": {}, "meta": {}}
    return {"managed_skills": {}, "meta": {}}


def save_memory(data: dict) -> None:
    """Save data back to local-memory.md."""
    yaml_block = yaml.dump(data, default_flow_style=False, sort_keys=False)
    history = ""
    if LOCAL_MEMORY.exists():
        content = LOCAL_MEMORY.read_text()
        # Preserve history section
        history_match = re.search(r"\n## History\n.*", content, re.DOTALL)
        if history_match:
            history = history_match.group(0)

    LOCAL_MEMORY.write_text(f"```yaml\n{yaml_block}```\n{history}")


def get_remote_head(repo: str, branch: str) -> Optional[str]:
    """Get HEAD commit SHA from remote repo."""
    try:
        output = run_git(["ls-remote", repo, f"refs/heads/{branch}"], check=False)
        if output:
            return output.split()[0]
    except Exception:
        pass
    return None


def skill_update(name: str, force: bool = False) -> int:
    """Update skill to HEAD of tracked branch."""
    memory = load_memory()

    if name not in memory.get("managed_skills", {}):
        print(f"Error: '{name}' not in managed_skills. Use 'skill switch' to add.")
        return 1

    skill = memory["managed_skills"][name]
    repo = skill["source_repo"]
    branch = skill["source_branch"]
    current_sha = skill.get("commit_hash", "")

    # Check for updates
    remote_head = get_remote_head(repo, branch)
    if not remote_head:
        print(f"Error: Cannot fetch from {repo}")
        return 1

    if remote_head == current_sha and not force:
        print(f"'{name}' already at HEAD ({current_sha[:7]})")
        return 0

    # Clone and copy
    tmp_dir = Path("/tmp") / f"skill-{name}-{datetime.now().strftime('%Y%m%d%H%M%S')}"
    try:
        print(f"Cloning {repo} (branch: {branch})...")
        run_git(["clone", "--depth", "1", "--branch", branch, repo, str(tmp_dir)])

        skill_src = tmp_dir / ".opencode" / "skills" / name
        if not skill_src.exists():
            skill_src = tmp_dir / name

        if not (skill_src / "SKILL.md").exists():
            print(f"Error: No SKILL.md found for '{name}' in repo")
            return 1

        # Copy to skills dir
        dest = SKILLS_DIR / name
        if dest.exists():
            shutil.rmtree(dest)
        shutil.copytree(skill_src, dest)

        # Update memory
        skill["commit_hash"] = remote_head
        skill["last_updated"] = datetime.now().isoformat()
        save_memory(memory)

        print(f"Updated '{name}' to {remote_head[:7]}")
        return 0
    finally:
        if tmp_dir.exists():
            shutil.rmtree(tmp_dir)


def skill_switch(name: str, repo: str, branch: str) -> int:
    """Switch skill to different source repo/branch."""
    tmp_dir = Path("/tmp") / f"skill-{name}-{datetime.now().strftime('%Y%m%d%H%M%S')}"
    try:
        print(f"Cloning {repo} (branch: {branch})...")
        run_git(["clone", "--depth", "1", "--branch", branch, repo, str(tmp_dir)])

        # Get actual SHA
        sha = run_git(["rev-parse", "HEAD"], cwd=tmp_dir)

        skill_src = tmp_dir / ".opencode" / "skills" / name
        if not skill_src.exists():
            skill_src = tmp_dir / name

        if not (skill_src / "SKILL.md").exists():
            print(f"Error: No SKILL.md found for '{name}' in repo")
            return 1

        # Copy to skills dir
        dest = SKILLS_DIR / name
        if dest.exists():
            shutil.rmtree(dest)
        shutil.copytree(skill_src, dest)

        # Update memory
        memory = load_memory()
        memory.setdefault("managed_skills", {})[name] = {
            "source_repo": repo,
            "source_branch": branch,
            "commit_hash": sha,
            "last_updated": datetime.now().isoformat(),
        }
        save_memory(memory)

        print(f"Switched '{name}' to {repo}@{branch} ({sha[:7]})")
        return 0
    except RuntimeError as e:
        print(f"Error: {e}")
        return 1
    finally:
        if tmp_dir.exists():
            shutil.rmtree(tmp_dir)


def skill_sources() -> int:
    """List all tracked skill sources."""
    memory = load_memory()
    skills = memory.get("managed_skills", {})

    if not skills:
        print("No managed skills.")
        return 0

    print(f"{'Skill':<20} {'Branch':<15} {'Commit':<8} {'Source'}")
    print("-" * 80)
    for name, data in sorted(skills.items()):
        repo = data.get("source_repo", "?")
        branch = data.get("source_branch", "?")
        sha = data.get("commit_hash", "?")[:7]
        # Shorten repo URL for display
        if "github.com" in repo:
            repo = repo.replace("https://github.com/", "")
            repo = repo.replace("git@github.com:", "")
        print(f"{name:<20} {branch:<15} {sha:<8} {repo}")

    return 0


def skill_status(name: Optional[str] = None) -> int:
    """Show sync status of skills."""
    memory = load_memory()
    skills = memory.get("managed_skills", {})

    if name:
        skills = {name: skills.get(name, {})} if name in skills else {}

    if not skills:
        print("No managed skills.")
        return 0

    print(f"{'Skill':<20} {'Status':<10} {'Local':<8} {'Remote'}")
    print("-" * 60)

    for skill_name, data in sorted(skills.items()):
        local_sha = data.get("commit_hash", "?")[:7]
        remote_head = get_remote_head(
            data.get("source_repo", ""), data.get("source_branch", "")
        )

        if not remote_head:
            status = "error"
            remote = "?"
        elif remote_head == data.get("commit_hash"):
            status = "synced"
            remote = remote_head[:7]
        else:
            status = "behind"
            remote = remote_head[:7]

        print(f"{skill_name:<20} {status:<10} {local_sha:<8} {remote}")

    return 0


def skill_update_all() -> int:
    """Update all managed skills."""
    memory = load_memory()
    skills = memory.get("managed_skills", {})

    if not skills:
        print("No managed skills.")
        return 0

    exit_code = 0
    for name in skills:
        print(f"\nUpdating '{name}'...")
        result = skill_update(name)
        if result != 0:
            exit_code = result

    return exit_code


def main():
    parser = argparse.ArgumentParser(description="Manage skills from git repos")
    subparsers = parser.add_subparsers(dest="command", required=True)

    # update
    upd = subparsers.add_parser("update", help="Update skill to HEAD of tracked branch")
    upd.add_argument("name", nargs="?", help="Skill name (omit for --all)")
    upd.add_argument("--all", action="store_true", help="Update all managed skills")
    upd.add_argument("--force", action="store_true", help="Force re-download")

    # switch
    sw = subparsers.add_parser("switch", help="Switch skill to different source")
    sw.add_argument("name", help="Skill name")
    sw.add_argument("repo", help="Git repository URL")
    sw.add_argument("branch", help="Branch name")

    # sources
    subparsers.add_parser("sources", help="List all tracked skill sources")

    # status
    st = subparsers.add_parser("status", help="Show sync status")
    st.add_argument("name", nargs="?", help="Skill name (omit for all)")

    args = parser.parse_args()

    if args.command == "update":
        if args.all:
            return skill_update_all()
        if not args.name:
            parser.error("Specify skill name or use --all")
        return skill_update(args.name, args.force)
    elif args.command == "switch":
        return skill_switch(args.name, args.repo, args.branch)
    elif args.command == "sources":
        return skill_sources()
    elif args.command == "status":
        return skill_status(args.name)

    return 0


if __name__ == "__main__":
    sys.exit(main())
