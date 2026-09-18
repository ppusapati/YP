#!/usr/bin/env python3
"""Fail when a generated proto module is not re-exported from the TS barrel.

Why this exists
---------------
web/packages/proto/src/index.ts is hand-curated, and it has to be: 101 exported
names collide across the generated modules — four different
`AcknowledgeAlertRequest`s, three `AlertSeverity`s, two each of `CropCategory`,
`BoundingBox`, `Explanation` and `CertificationStatus` — so a blanket
`export *` of everything is not available even in principle.

Curation is why it drifted. Twenty-eight of forty-seven generated modules were
re-exported and nineteen were not, so eleven finished services — weather,
commerce, task, market, device, finance, planning, soil-lab, sustainability and
agronomy's two — could not be reached from the web app at all. Nothing failed:
an unexported module is not an error, it is an absence, and the only symptom is
a page nobody wrote.

The barrel now ends with one `export * as <name>Pb` per generated module, which
cannot collide and cannot be ambiguous. This checks that set is complete.

Usage:
    scripts/check-proto-barrel.py
"""

from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
BARREL = ROOT / "web" / "packages" / "proto" / "src" / "index.ts"
GEN = ROOT / "web" / "packages" / "proto" / "src" / "gen"

NAMESPACE_RE = re.compile(r"^export \* as (\w+) from '\./gen/([a-z_0-9]+)\.js';$", re.M)


def namespace_for(stem: str) -> str:
    """weather_pb -> weatherPb, ai_gateway_pb -> aiGatewayPb."""
    head, *rest = stem.split("_")
    return head + "".join(word.capitalize() for word in rest)


def main() -> int:
    if not GEN.is_dir():
        print(f"error: {GEN.relative_to(ROOT)} does not exist — run 'make proto-web'",
              file=sys.stderr)
        return 1

    generated = {p.stem for p in GEN.glob("*.ts")}
    if not generated:
        print(f"error: no generated modules in {GEN.relative_to(ROOT)}", file=sys.stderr)
        return 1

    text = BARREL.read_text()
    exported = {module: alias for alias, module in NAMESPACE_RE.findall(text)}

    problems: list[str] = []

    for stem in sorted(generated - set(exported)):
        problems.append(
            f"./gen/{stem}.js is generated and not re-exported — add\n"
            f"      export * as {namespace_for(stem)} from './gen/{stem}.js';"
        )

    for stem in sorted(set(exported) - generated):
        problems.append(
            f"./gen/{stem}.js is re-exported and no longer generated — remove it"
        )

    # A namespace whose name does not follow from its module is a namespace
    # nobody will guess, which is the same problem in a slower form.
    for stem, alias in sorted(exported.items()):
        expected = namespace_for(stem)
        if stem in generated and alias != expected:
            problems.append(
                f"./gen/{stem}.js is exported as '{alias}', expected '{expected}'"
            )

    if problems:
        print(f"\n{len(problems)} problem(s) in "
              f"{BARREL.relative_to(ROOT)}:\n", file=sys.stderr)
        for problem in problems:
            print(f"  - {problem}", file=sys.stderr)
        print("\nA module that is generated and not exported is a service the web "
              "app cannot\nreach, and nothing else in the build will say so.",
              file=sys.stderr)
        return 1

    print(f"ok: all {len(generated)} generated modules are re-exported")
    return 0


if __name__ == "__main__":
    sys.exit(main())
