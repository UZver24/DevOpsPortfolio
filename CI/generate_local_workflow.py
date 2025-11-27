#!/usr/bin/env python3
"""Create a safe copy of the main workflow for local act runs."""

from __future__ import annotations

import re
import shutil
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / ".github/workflows/ci.yml"
TARGET = ROOT / "CI/ci.local.yml"


def normalize_name(raw: str) -> str:
    raw = raw.strip()
    if (raw.startswith('"') and raw.endswith('"')) or (
        raw.startswith("'") and raw.endswith("'")
    ):
        raw = raw[1:-1]
    return raw or "шаг без названия"


def main() -> None:
    if not SOURCE.exists():
        raise FileNotFoundError(f"Не найден основной workflow: {SOURCE}")

    lines = SOURCE.read_text(encoding="utf-8").splitlines()
    result: list[str] = []

    current_step = "шаг без названия"
    skip_indent: int | None = None
    drop_with_for_step = False

    for line in lines:
        indent = len(line) - len(line.lstrip(" "))

        if skip_indent is not None:
            if not line.strip() or indent > skip_indent:
                # Всё ещё внутри блока предыдущего run/with.
                continue
            skip_indent = None
            # Выпали из блока — обрабатываем строку как обычно.

        name_match = re.match(r"^(\s*)- name:\s*(.+)$", line)
        if name_match:
            current_step = normalize_name(name_match.group(2))
            drop_with_for_step = False
            result.append(line)
            continue

        if re.match(r"^\s*working-directory:\s*", line):
            # В контейнере act путь репозитория отличается, поэтому рабочую директорию убираем.
            continue

        run_match = re.match(r"^(\s*)run:\s*(.*)$", line)
        if run_match:
            leading = run_match.group(1)
            tail = run_match.group(2).strip()
            safe_echo = f'{leading}run: echo "[mock] {current_step}"'
            result.append(safe_echo)

            if tail.startswith("|") or tail.startswith(">"):
                skip_indent = indent
            continue

        uses_match = re.match(r"^(\s*)uses:\s*(.+)$", line)
        if uses_match:
            leading = uses_match.group(1)
            result.append(f'{leading}run: echo "[mock uses] {current_step}"')
            drop_with_for_step = True
            continue

        if drop_with_for_step:
            with_match = re.match(r"^(\s*)with:\s*(.*)$", line)
            if with_match:
                skip_indent = indent
                continue

        result.append(line)

    TARGET.write_text("\n".join(result) + "\n", encoding="utf-8")
    print(f"Локальный workflow сохранён в {TARGET}")

    act_path = shutil.which("act")
    if act_path is None:
        print("⚠️  Утилита act не найдена в PATH — пропускаю запуск.", file=sys.stderr)
        return

    print(f"▶️  Запускаю act через {act_path}:")
    try:
        subprocess.run(
            [act_path, "push", "-W", str(TARGET)],
            check=True,
        )
    except subprocess.CalledProcessError as exc:
        print(
            f"❌ act завершился с кодом {exc.returncode}. "
            "Проверьте логи выше.",
            file=sys.stderr,
        )


if __name__ == "__main__":
    main()

