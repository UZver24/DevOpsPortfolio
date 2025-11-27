#!/usr/bin/env python3
"""Generate Mermaid diagram from .github/workflows/ci.yml."""

from __future__ import annotations

import string
from pathlib import Path
from typing import Iterable

import yaml
from yaml.loader import SafeLoader

class PlainLoader(SafeLoader):
    pass

for ch in list(PlainLoader.yaml_implicit_resolvers):
    resolvers = PlainLoader.yaml_implicit_resolvers[ch]
    PlainLoader.yaml_implicit_resolvers[ch] = [
        (tag, regexp) for tag, regexp in resolvers if tag != "tag:yaml.org,2002:bool"
    ]

ROOT = Path(__file__).resolve().parents[1]
WORKFLOW_PATH = ROOT / ".github/workflows/ci.yml"
MERMAID_PATH = ROOT / ".github/workflows/ci.yml.mermaid"

STEP_HIGHLIGHT_COLOR = "#c8e6c9"
JOB_FILL_COLOR = "#fff3e0"
TRIGGERS_COLOR = "#e3f2fd"
ENV_COLOR = "#f3e5f5"


def format_label(text: str) -> str:
    return (
        text.replace("[", "(")
        .replace("]", ")")
        .replace('"', "")
        .replace("\n", "<br/>")
        .strip()
    )


def upper_letter(index: int) -> str:
    letters = string.ascii_uppercase
    if index < len(letters):
        return letters[index]
    # Fallback for many jobs: AA, AB, ...
    index -= len(letters)
    first = letters[index // len(letters)]
    second = letters[index % len(letters)]
    return f"{first}{second}"


def normalize_list(value) -> list[str]:
    if value is None:
        return []
    if isinstance(value, str):
        return [value]
    if isinstance(value, Iterable):
        return [str(v) for v in value]
    return [str(value)]


def build_triggers(on_section: dict) -> list[str]:
    lines = ['    subgraph Triggers["Триггеры"]']
    for event_name, config in on_section.items():
        label = event_name.replace("_", " ").title()
        branches = []
        if isinstance(config, dict):
            branches = config.get("branches") or []
        suffix = f" → {', '.join(branches)}" if branches else ""
        node_id = f"{event_name.title()}Event"
        lines.append(f"        {node_id}[{label}{suffix}]")
    lines.append("    end")
    return lines


def build_env(env_section: dict) -> list[str]:
    if not env_section:
        return []
    lines = ['    subgraph Env["Переменные окружения"]']
    for key, value in env_section.items():
        label = format_label(str(key))
        lines.append(f"        {key}[{label}]")
    lines.append("    end")
    return lines


def build_job_subgraph(job_idx: int, job_id: str, job_conf: dict) -> tuple[list[str], list[str], str]:
    job_node = f"Job{job_idx}"
    job_title = job_conf.get("name") or f"Job: {job_id}"
    lines = [f'    subgraph {job_node}["{job_title}"]', "        direction TB"]

    steps = []
    step_ids = []
    letter = upper_letter(job_idx - 1)
    for step_idx, step in enumerate(job_conf.get("steps", []), start=1):
        step_name = step.get("name")
        if not step_name:
            continue
        step_id = f"{letter}{step_idx}"
        step_label = format_label(step_name)
        lines.append(f"        {step_id}[{step_label}]")
        step_ids.append(step_id)
        steps.append(step_label)

    if len(step_ids) > 1:
        chain = " --> ".join(step_ids)
        lines.append(f"        {chain}")

    lines.append("    end")
    return lines, step_ids, job_node


def main() -> None:
    workflow = yaml.load(WORKFLOW_PATH.read_text(encoding="utf-8"), Loader=PlainLoader)

    mermaid_lines: list[str] = ["flowchart TB", ""]
    mermaid_lines.extend(build_triggers(workflow.get("on", {})))
    mermaid_lines.append("")
    mermaid_lines.extend(build_env(workflow.get("env", {})))
    mermaid_lines.append("")

    job_nodes: dict[str, str] = {}
    job_step_ids: dict[str, list[str]] = {}

    for idx, (job_id, job_conf) in enumerate(workflow.get("jobs", {}).items(), start=1):
        subgraph_lines, step_ids, job_node = build_job_subgraph(idx, job_id, job_conf)
        mermaid_lines.extend(subgraph_lines)
        mermaid_lines.append("")
        job_nodes[job_id] = job_node
        job_step_ids[job_node] = step_ids

    # Edges
    for job_id, job_node in job_nodes.items():
        needs = normalize_list(workflow["jobs"][job_id].get("needs"))
        if needs:
            for need in needs:
                need_node = job_nodes.get(need)
                if need_node:
                    mermaid_lines.append(f"    {need_node} --> {job_node}")
        else:
            mermaid_lines.append(f"    Triggers --> {job_node}")

    env_section = workflow.get("env")
    if env_section:
        for job_node in job_nodes.values():
            mermaid_lines.append(f"    Env --> {job_node}")

    mermaid_lines.append("")

    # Styles
    mermaid_lines.append(f"    style Triggers fill:{TRIGGERS_COLOR}")
    if env_section:
        mermaid_lines.append(f"    style Env fill:{ENV_COLOR}")
    for job_node in job_nodes.values():
        mermaid_lines.append(f"    style {job_node} fill:{JOB_FILL_COLOR}")
    for step_ids in job_step_ids.values():
        if step_ids:
            mermaid_lines.append(f"    style {step_ids[-1]} fill:{STEP_HIGHLIGHT_COLOR}")

    mermaid_lines.append("")

    MERMAID_PATH.write_text("\n".join(mermaid_lines), encoding="utf-8")
    print(f"Mermaid диаграмма обновлена: {MERMAID_PATH}")


if __name__ == "__main__":
    main()

