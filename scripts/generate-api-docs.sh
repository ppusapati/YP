#!/usr/bin/env bash
#
# generate-api-docs.sh — keep docs/api/ in step with the protos.
#
# Usage:
#   ./scripts/generate-api-docs.sh            # scaffold a spec for any service
#                                             # that has none; never overwrite
#   ./scripts/generate-api-docs.sh --check    # fail if the specs and the protos
#                                             # disagree (used by CI)
#
# Requirements: bash, python3 with PyYAML.
#
# What changed, and why it works this way
# ---------------------------------------
# This used to hold a literal array of thirteen services and rewrite each one's
# spec from a skeleton. Both halves were wrong.
#
# The list was wrong in both directions at once. Nine services had a spec in
# docs/api/ that the script no longer regenerated, so editing their proto
# changed nothing and nothing said so; nine more had no spec at all. And every
# port in the array was off by one position — farm was listed on 8080, which is
# the gateway; field on 8081, which is farm — so each spec told a reader to POST
# to the next service along and get back an unimplemented method.
#
# Rewriting was worse. The specs in docs/api/ are not generated artifacts: they
# carry hand-written descriptions, request and response schemas, examples and
# error tables that no amount of proto parsing can produce. Running the script
# over the tree replaced about 5,700 lines of that with a skeleton, silently,
# and a --check that demanded the skeleton would have made CI enforce the loss.
#
# So the script scaffolds and checks; it does not rewrite. It writes a starting
# point for a service that has no spec, and it fails the build when a spec is
# missing, points at the wrong port, or has fallen behind its proto's RPC list.
# The prose belongs to whoever wrote it.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

exec python3 - "$REPO_ROOT" "${1:-}" <<'PY'
import re
import sys
from pathlib import Path

import yaml

root = Path(sys.argv[1])
mode = sys.argv[2] if len(sys.argv) > 2 else ""
check_only = mode == "--check"
if mode and not check_only:
    print(f"usage: generate-api-docs.sh [--check]  (got {mode!r})", file=sys.stderr)
    sys.exit(2)

OUTPUT_DIR = root / "docs" / "api"
OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

SERVICE_RE = re.compile(r"^\s*service\s+(\w+)\s*\{", re.M)
PACKAGE_RE = re.compile(r"^\s*package\s+([\w.]+)\s*;", re.M)
RPC_RE = re.compile(r"^\s*rpc\s+(\w+)\s*\(\s*(?:stream\s+)?(\w+)\s*\)\s*"
                    r"returns\s*\(\s*(?:stream\s+)?(\w+)\s*\)", re.M)


def published_ports() -> dict[str, str]:
    """The host port each compose service publishes.

    This is what a developer curls; inside the container every service listens
    on 8080. Reading it here rather than writing it down is the whole point: the
    numbers shift when a service is added, and a spec that names a stale one
    sends its reader to a different service that answers.
    """
    compose = yaml.safe_load((root / "docker-compose.yml").read_text())
    ports: dict[str, str] = {}
    for name, spec in (compose.get("services") or {}).items():
        for entry in spec.get("ports") or []:
            published = entry.split(":")[0] if isinstance(entry, str) \
                else str(entry.get("published", ""))
            if published:
                ports.setdefault(name, published)
                break
    return ports


def discover() -> dict[str, dict]:
    """Every service directory that declares an RPC service, keyed by name.

    ai-gateway is excluded deliberately: it speaks gRPC on 50051 with no JSON
    transcoding, and these specs describe ConnectRPC POSTs with JSON bodies.
    A spec for it would document a protocol it does not serve.
    """
    services: dict[str, dict] = {}
    for proto in sorted(root.glob("*/proto/*.proto")):
        svc = proto.parts[-3]
        if svc in ("packages", "ai-gateway"):
            continue
        text = proto.read_text()
        names = SERVICE_RE.findall(text)
        if not names:
            continue
        package = PACKAGE_RE.search(text)
        if not package:
            print(f"error: {proto} declares a service and no package", file=sys.stderr)
            sys.exit(1)

        entry = services.setdefault(svc, {"package": package.group(1), "rpcs": {}})
        # One spec per service directory, not per file: agronomy-service has
        # advisory.proto and inspection.proto, and its spec documents both.
        for service_name in names:
            # Slice the file at this service block so its RPCs are not credited
            # to the one before it.
            start = text.index(f"service {service_name}")
            nxt = [text.index(f"service {n}") for n in names
                   if text.index(f"service {n}") > start]
            body = text[start:min(nxt)] if nxt else text[start:]
            for method, req, resp in RPC_RE.findall(body):
                path = f"/{entry['package']}.{service_name}/{method}"
                entry["rpcs"][path] = (method, req, resp)
    return services


def spec_path(svc: str) -> Path:
    return OUTPUT_DIR / f"{svc}.yaml"


def scaffold(svc: str, port: str, entry: dict) -> str:
    title = " ".join(w.capitalize() for w in svc.split("-"))
    lines = [
        "openapi: 3.0.3",
        "info:",
        f"  title: {title} API",
        "  description: |",
        f"    Scaffolded from {svc}/proto/. Uses the ConnectRPC protocol — every",
        "    RPC is an HTTP POST with a JSON body.",
        "",
        "    This paragraph and the schemas below are a starting point, not a",
        "    generated artifact: nothing regenerates this file, so describe what",
        "    each call is for and what it can fail with.",
        "  version: 1.0.0",
        "servers:",
        f"  - url: http://localhost:{port}",
        "    description: Local development",
        "",
        "paths:",
    ]
    for path, (method, req, resp) in entry["rpcs"].items():
        lines += [
            f"  {path}:",
            "    post:",
            f'      summary: "{method}"',
            f"      operationId: {method}",
            "      requestBody:",
            "        required: true",
            "        content:",
            "          application/json:",
            "            schema:",
            "              type: object",
            f'              description: "{req}"',
            "      responses:",
            "        '200':",
            "          description: Success",
            "          content:",
            "            application/json:",
            "              schema:",
            "                type: object",
            f'                description: "{resp}"',
            "",
        ]
    return "\n".join(lines)


def spec_port(doc: dict) -> str | None:
    servers = doc.get("servers") or []
    for server in servers:
        url = str(server.get("url", ""))
        match = re.search(r"localhost:(\d+)", url)
        if match:
            return match.group(1)
    return None


services = discover()
ports = published_ports()

missing_port = sorted(s for s in services if s not in ports)
if missing_port:
    # Loudly. A service with no compose entry is one nobody can run locally,
    # which is a larger problem than its missing spec.
    print("error: no published port in docker-compose.yml for: "
          + ", ".join(missing_port), file=sys.stderr)
    sys.exit(1)

problems: list[str] = []
written: list[str] = []

for svc, entry in sorted(services.items()):
    path = spec_path(svc)
    if not path.exists():
        if check_only:
            problems.append(
                f"{svc} has {len(entry['rpcs'])} RPC(s) and no spec at "
                f"docs/api/{svc}.yaml — run scripts/generate-api-docs.sh"
            )
        else:
            path.write_text(scaffold(svc, ports[svc], entry))
            written.append(svc)
        continue

    doc = yaml.safe_load(path.read_text()) or {}

    actual_port = spec_port(doc)
    if actual_port != ports[svc]:
        problems.append(
            f"docs/api/{svc}.yaml points at localhost:{actual_port}, but compose "
            f"publishes {svc} on {ports[svc]} — that URL reaches a different service"
        )

    documented = set((doc.get("paths") or {}).keys())
    declared = set(entry["rpcs"])
    for path_name in sorted(declared - documented):
        problems.append(f"docs/api/{svc}.yaml has no entry for {path_name}")
    for path_name in sorted(documented - declared):
        problems.append(
            f"docs/api/{svc}.yaml documents {path_name}, which no proto declares"
        )

# Specs with no service behind them any more.
for existing in sorted(OUTPUT_DIR.glob("*-service*.yaml")):
    if existing.stem not in services:
        problems.append(
            f"docs/api/{existing.name} describes a service that no longer exists"
        )

if check_only:
    if problems:
        print(f"\n{len(problems)} problem(s) between the protos and docs/api/:\n",
              file=sys.stderr)
        for problem in problems:
            print(f"  - {problem}", file=sys.stderr)
        print("\nThese specs are hand-written and nothing regenerates them, so an "
              "RPC added\nwithout a matching entry stays undocumented "
              "indefinitely.", file=sys.stderr)
        sys.exit(1)
    print(f"ok: {len(services)} services, every spec present and in step")
    sys.exit(0)

for svc in written:
    print(f"Scaffolded docs/api/{svc}.yaml")
if not written:
    print("Every service already has a spec; nothing scaffolded.")
if problems:
    print("\nStill out of step (these files are hand-written — edit them):",
          file=sys.stderr)
    for problem in problems:
        print(f"  - {problem}", file=sys.stderr)
    sys.exit(1)
PY
