#!/usr/bin/env uv run
# /// script
# requires-python = ">=3.11"
# dependencies = [
#   "rich>=13.0",
# ]
# ///

"""
gmail - Gmail CLI client backed by gogcli (tokens stored in macOS Keychain).

Usage:
    gmail.py --account allaria              # last 15 mails
    gmail.py --account almafintech --unread # unread only
    gmail.py --account allaria --label AWS  # filter by label
    gmail.py --account allaria --limit 50   # more results
    gmail.py --account allaria --short      # compact mode
    gmail.py --account allaria -q "from:github"  # free search
"""

from __future__ import annotations

import argparse
import json
import subprocess
import sys
from dataclasses import dataclass, field
from datetime import datetime
from typing import Any

from rich.console import Console
from rich.table import Table
from rich.text import Text

# ─── Constants ───────────────────────────────────────────────────────────────

ACCOUNT_MAP: dict[str, str] = {
    "allaria": "alejandro.schwartzmann@allaria.com.ar",
    "almafintech": "alejandro.schwartzmann@almafintech.com.ar",
}

LABEL_COLORS: dict[str, tuple[str, str]] = {
    "Label_7229473445274762100": ("AWS", "yellow"),
    "Label_4": ("GitHub", "magenta"),
    "Label_5": ("Jira", "green"),
    "Label_1270420403290694070": ("Galicia", "cyan"),
    "Label_2": ("Metabase", "blue"),
    "Label_3": ("Allaria", "green"),
    "Label_6367231469415353355": ("Google", "red"),
    "STARRED": ("*", "yellow"),
    "IMPORTANT": ("!", "yellow"),
}

# ─── Types ───────────────────────────────────────────────────────────────────


@dataclass
class Message:
    """A simplified Gmail message."""

    id: str
    thread_id: str
    internal_date: int
    from_: str
    to: str
    subject: str
    label_ids: list[str] = field(default_factory=list)


# ─── GmailClient ─────────────────────────────────────────────────────────────


class GmailClient:
    """Gmail client backed by gogcli — tokens live in macOS Keychain, never expire."""

    def __init__(self, account: str) -> None:
        self.account_key = account
        self.account = ACCOUNT_MAP.get(account, account)

    def _gog(self, *args: str, capture_json: bool = True) -> Any:
        cmd = ["gog", "--no-input", "-a", self.account]
        if capture_json:
            cmd.append("--json")
        cmd.extend(args)
        result = subprocess.run(cmd, capture_output=True, text=True, check=True)
        if capture_json:
            return json.loads(result.stdout)
        return result.stdout

    def list_messages(
        self,
        query: str | None = None,
        max_results: int = 50,
        fetch_all: bool = False,
    ) -> tuple[list[Message], int]:
        """List messages, returns (parsed_messages, total_estimate)."""
        q = query if query else "in:inbox"
        args = ["gmail", "search", q, f"--max={max_results}"]
        if fetch_all:
            args.append("--all")

        data = self._gog(*args)
        threads: list[dict[str, Any]] = data.get("threads", [])

        parsed: list[Message] = []
        for t in threads:
            try:
                dt = datetime.strptime(t["date"], "%Y-%m-%d %H:%M")
                internal_date = int(dt.timestamp() * 1000)
            except (ValueError, KeyError):
                internal_date = 0

            parsed.append(
                Message(
                    id=t["id"],
                    thread_id=t["id"],
                    internal_date=internal_date,
                    from_=t.get("from", ""),
                    to="",
                    subject=t.get("subject", "(no subject)"),
                    label_ids=t.get("labels", []),
                )
            )

        return parsed, len(parsed)

    def get_body(self, msg_id: str) -> str:
        """Get the best available body text for a message."""
        data = self._gog("gmail", "get", msg_id)
        return data.get("body", "") or "(no text content)"

    def trash_message(self, msg_id: str) -> None:
        """Move message to trash."""
        self._gog("gmail", "trash", "-y", msg_id, capture_json=False)

    def untrash_message(self, msg_id: str) -> None:
        """Remove message from trash (not supported by gogcli; no-op)."""

    def modify_message(
        self,
        msg_id: str,
        add_labels: list[str] | None = None,
        remove_labels: list[str] | None = None,
    ) -> None:
        """Modify message labels using gogcli commands."""
        add = set(add_labels or [])
        remove = set(remove_labels or [])

        if "UNREAD" in add:
            self._gog("gmail", "unread", msg_id, capture_json=False)
        if "UNREAD" in remove:
            self._gog("gmail", "mark-read", msg_id, capture_json=False)
        if "INBOX" in remove:
            self._gog("gmail", "archive", "-y", msg_id, capture_json=False)
        if "STARRED" in add:
            self._gog("gmail", "labels", "modify", msg_id, "--add=STARRED", capture_json=False)
        if "STARRED" in remove:
            self._gog("gmail", "labels", "modify", msg_id, "--remove=STARRED", capture_json=False)


# ─── Formatting helpers ──────────────────────────────────────────────────────


def format_date(ts_ms: int) -> str:
    """Format a Gmail timestamp for display."""
    dt = datetime.fromtimestamp(ts_ms / 1000)
    now = datetime.now()
    if dt.date() == now.date():
        return dt.strftime("%H:%M")
    if dt.year == now.year:
        return dt.strftime("%b %d")
    return dt.strftime("%Y-%m-%d")


def parse_sender(from_header: str) -> str:
    """Extract display name from a From header."""
    if not from_header:
        return "unknown"
    if "<" in from_header:
        name = from_header.split("<")[0].strip()
        email = from_header.split("<")[1].rstrip(">").strip()
        return name or email
    return from_header


def label_display(label_ids: list[str]) -> list[tuple[str, str]]:
    """Return list of (name, color) for known labels."""
    return [LABEL_COLORS[lid] for lid in label_ids if lid in LABEL_COLORS]


def truncate(text: str, width: int) -> str:
    """Truncate text with ellipsis."""
    if not text or len(text) <= width:
        return text
    return text[: width - 3] + "..."


# ─── CLI rendering ───────────────────────────────────────────────────────────


def render_table(
    messages: list[Message],
    total: int,
    account: str,
    query: str | None,
) -> None:
    """Render messages as a rich table."""
    console = Console()

    console.print(
        f"\n[bold]gmail: {account} -- {total} encontrados (mostrando {len(messages)})[/]"
    )
    if query:
        console.print(f"   [dim]Filtro: {query}[/]")

    table = Table(show_header=True, header_style="bold", box=None)
    table.add_column("", width=2)
    table.add_column("Date", style="dim", no_wrap=True)
    table.add_column("From")
    table.add_column("Subject")
    table.add_column("Labels")

    for msg in messages:
        is_unread = "UNREAD" in msg.label_ids
        indicator = "[bold cyan]>[/]" if is_unread else "  "
        date_text = format_date(msg.internal_date)
        sender = truncate(parse_sender(msg.from_), 28)
        subject_style = "bold" if is_unread else ""
        subject = Text(truncate(msg.subject, 40), style=subject_style)

        labels = label_display(msg.label_ids)
        label_parts = [f"[{color}]{name}[/]" for name, color in labels]

        table.add_row(
            indicator,
            date_text,
            sender,
            subject,
            " ".join(label_parts),
        )

    console.print(table)
    console.print()


def render_compact(
    messages: list[Message], total: int, account: str, query: str | None
) -> None:
    """Compact single-line rendering."""
    console = Console()
    console.print(
        f"\n[bold]gmail: {account} -- {total} encontrados (mostrando {len(messages)})[/]"
    )
    if query:
        console.print(f"   [dim]Filtro: {query}[/]")
    console.print()

    for msg in messages:
        is_unread = "UNREAD" in msg.label_ids
        indicator = "[bold cyan]>[/]" if is_unread else " "
        date_text = format_date(msg.internal_date)
        sender = truncate(parse_sender(msg.from_), 20)
        subject = truncate(msg.subject or "(sin asunto)", 36)

        labels = label_display(msg.label_ids)
        label_str = " ".join(f"[{color}]{name}[/]" for name, color in labels)

        line = f"{indicator} [dim]{date_text:<7}[/] {sender:<22} {subject:<38}"
        if label_str:
            line += f" {label_str}"
        console.print(line)

    console.print()


# ─── CLI main ────────────────────────────────────────────────────────────────


def cli_main() -> None:
    """Entry point for CLI mode."""
    parser = argparse.ArgumentParser(
        description="Gmail CLI client (backed by gogcli, tokens in macOS Keychain)",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""\
Examples:
  %(prog)s                          # allaria, ultimos 15
  %(prog)s -a almafintech -u        # almafintech, solo no leidos
  %(prog)s -a allaria -l AWS -s     # label AWS, modo compacto
  %(prog)s -a allaria -n 50         # 50 resultados
  %(prog)s -a allaria -q "from:github.com"  # busqueda libre
        """,
    )
    parser.add_argument(
        "--account",
        "-a",
        default="allaria",
        choices=list(ACCOUNT_MAP.keys()),
        help="Cuenta de Gmail (default: allaria)",
    )
    parser.add_argument(
        "--label",
        "-l",
        default=None,
        help="Filtrar por label (ej: AWS, GitHub, Jira)",
    )
    parser.add_argument(
        "--limit",
        "-n",
        type=int,
        default=15,
        help="Cantidad de mails (default: 15)",
    )
    parser.add_argument(
        "--unread",
        "-u",
        action="store_true",
        help="Solo mostrar no leidos",
    )
    parser.add_argument(
        "--query",
        "-q",
        default=None,
        help="Query de busqueda libre (sintaxis Gmail)",
    )
    parser.add_argument(
        "--short",
        "-s",
        action="store_true",
        help="Modo compacto (una linea por mail)",
    )

    args = parser.parse_args()

    q_parts: list[str] = ["in:inbox"]
    if args.query:
        q_parts = [args.query]
    else:
        if args.unread:
            q_parts.append("is:unread")
        if args.label:
            q_parts.append(f"label:{args.label}")

    query = " ".join(q_parts)

    try:
        client = GmailClient(args.account)
        messages, total = client.list_messages(query=query, max_results=args.limit)

        if not messages:
            Console().print("[dim]No hay mensajes.[/]")
            return

        if args.short:
            render_compact(messages, total, args.account, query)
        else:
            render_table(messages, total, args.account, query)

    except subprocess.CalledProcessError as e:
        Console().print(f"[red]Error de gogcli: {e.stderr or e}[/]")
        sys.exit(1)
    except KeyboardInterrupt:
        Console().print("\n[yellow]Cancelado.[/]")
        sys.exit(0)


# ─── Entry point ─────────────────────────────────────────────────────────────


def main() -> None:
    cli_main()


if __name__ == "__main__":
    main()
