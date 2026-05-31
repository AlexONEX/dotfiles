#!/usr/bin/env uv run
# /// script
# requires-python = ">=3.11"
# dependencies = [
#   "rich>=13.0",
#   "textual>=1.0",
# ]
# ///

"""
gmail-tui - Terminal Gmail client with vim keybindings.
Backed by gogcli — tokens stored in macOS Keychain, never expire.

Usage:
    gmail-tui.py --account allaria
    gmail-tui.py --account almafintech
"""

from __future__ import annotations

from datetime import datetime
from typing import Any

from rich.text import Text
from textual import work
from textual.app import App, ComposeResult
from textual.binding import Binding
from textual.containers import Container
from textual.message import Message as TextMsg
from textual.reactive import reactive
from textual.coordinate import Coordinate
from textual.screen import ModalScreen, Screen
from textual.widgets import DataTable, Footer, Header, Input, Label, RichLog, Static

from gmail import (
    ACCOUNT_MAP,
    GmailClient,
    Message,
    format_date,
    label_display,
    parse_sender,
)

# ─── Helpers ─────────────────────────────────────────────────────────────────


def _discover_accounts() -> list[str]:
    return sorted(ACCOUNT_MAP.keys())


def make_date_cell(ts_ms: int) -> Text:
    """Rich-styled date cell for the table."""
    return Text(format_date(ts_ms), style="dim")


def make_sender_cell(from_hdr: str) -> Text:
    """Rich-styled sender cell."""
    return Text(parse_sender(from_hdr))


def make_subject_cell(subject: str, is_unread: bool) -> Text:
    """Rich-styled subject cell (bold if unread)."""
    s = subject or "(no subject)"
    return Text(s, style="bold" if is_unread else "")


def make_labels_cell(label_ids: list[str]) -> Text:
    """Rich-styled labels cell with colors."""
    labels = label_display(label_ids)
    t = Text("")
    for name, color in labels:
        t.append(f" {name} ", style=f"{color} on default")
    return t


# ─── EmailViewScreen ─────────────────────────────────────────────────────────


class EmailViewScreen(Screen):
    """Full-screen email viewer."""

    BINDINGS = [
        Binding("b", "go_back", "Back"),
        Binding("escape", "go_back", "Back"),
        Binding("d", "delete", "Delete"),
        Binding("j", "scroll_down", "Down"),
        Binding("k", "scroll_up", "Up"),
        Binding("g", "scroll_end", "End"),
        Binding("G", "scroll_home", "Top"),
        Binding("q", "quit_app", "Quit"),
    ]

    def __init__(self, gmail: GmailClient, msg_data: Message) -> None:
        super().__init__()
        self.gmail = gmail
        self.msg_data = msg_data
        self.body_text = ""

    def compose(self) -> ComposeResult:
        yield Header(show_clock=True)
        yield RichLog(id="email-body", wrap=True, highlight=True)
        yield Footer()

    def on_mount(self) -> None:
        self.load_email()

    @work(thread=True)
    def load_email(self) -> None:  # type: ignore[misc]
        body_log = self.query_one("#email-body", RichLog)
        md = self.msg_data

        dt = datetime.fromtimestamp(md.internal_date / 1000)
        date_str = dt.strftime("%a, %d %b %Y %H:%M:%S")

        body_log.write("")
        body_log.write(Text(f"From:    {md.from_}", style="bold"))
        body_log.write(Text(f"To:      {md.to}"))
        body_log.write(Text(f"Date:    {date_str}"))
        body_log.write(Text(f"Subject: {md.subject}", style="bold"))
        body_log.write("")
        body_log.write(Text("─" * 60, style="dim"))
        body_log.write("")

        try:
            body_text = self.gmail.get_body(md.id)
            self.body_text = body_text
            body_log.write(body_text)
        except Exception as e:
            body_log.write(Text(f"[Error loading body: {e}]", style="red"))

    def action_go_back(self) -> None:
        self.dismiss()

    def action_delete(self) -> None:
        self.dismiss({"action": "delete", "msg_id": self.msg_data.id})

    def action_quit_app(self) -> None:
        self.app.exit()

    def action_scroll_down(self) -> None:
        self.query_one("#email-body", RichLog).scroll_relative(y=3)

    def action_scroll_up(self) -> None:
        self.query_one("#email-body", RichLog).scroll_relative(y=-3)

    def action_scroll_end(self) -> None:
        self.query_one("#email-body", RichLog).scroll_end()

    def action_scroll_home(self) -> None:
        self.query_one("#email-body", RichLog).scroll_home()


# ─── ConfirmDeleteScreen ─────────────────────────────────────────────────────


class ConfirmDeleteScreen(ModalScreen[bool]):
    """Confirmation dialog for deleting a message."""

    BINDINGS = [
        Binding("y", "confirm", "Yes"),
        Binding("n", "cancel", "No"),
        Binding("escape", "cancel", "Cancel"),
    ]

    def __init__(self, subject: str) -> None:
        super().__init__()
        self.subject = subject

    def compose(self) -> ComposeResult:
        yield Container(
            Label("Delete message?", id="confirm-title"),
            Label(f'"{self.subject}"', id="confirm-subject"),
            Label("This moves it to Trash. (y/n)", id="confirm-hint"),
            id="confirm-dialog",
        )

    def action_confirm(self) -> None:
        self.dismiss(True)

    def action_cancel(self) -> None:
        self.dismiss(False)


# ─── EmailListScreen ─────────────────────────────────────────────────────────


class EmailListScreen(Screen):
    """Main screen with the email list."""

    BINDINGS = [
        Binding("j", "cursor_down", "Down", show=False),
        Binding("k", "cursor_up", "Up", show=False),
        Binding("down", "cursor_down", "Down"),
        Binding("up", "cursor_up", "Up"),
        Binding("l", "view_email", "Open", show=False),
        Binding("d", "delete_email", "Delete"),
        Binding("r", "refresh", "Refresh"),
        Binding("g", "top", "Top", show=False),
        Binding("G", "bottom", "Bottom", show=False),
        Binding("slash", "focus_search", "Search"),
        Binding("v", "toggle_select", "Visual"),
        Binding("a", "archive_email", "Archive"),
        Binding("s", "star_email", "Star"),
        Binding("u", "toggle_unread", "Toggle Read"),
        Binding("tab", "next_account", "Switch Account"),
        Binding("q", "quit_app", "Quit"),
        Binding("escape", "unfocus", "Unfocus"),
    ]

    account: str = ""
    status_text: reactive[str] = reactive("")
    messages: list[Message] = []
    total: int = 0
    gmail: GmailClient | None = None

    class StatusMsg(TextMsg):
        def __init__(self, text: str, is_error: bool = False) -> None:
            super().__init__()
            self.text = text
            self.is_error = is_error

    class MessagesLoaded(TextMsg):
        def __init__(self, messages: list[Message], total: int, query: str) -> None:
            super().__init__()
            self.messages = messages
            self.total = total
            self.query = query

    def __init__(self, account: str) -> None:
        super().__init__()
        self.account = account
        self._pending_cursor_row: int | None = None
        self._selected_ids: set[str] = set()
        self._visual_mode: bool = False
        self._visual_anchor: int = 0

    def compose(self) -> ComposeResult:
        yield Header(show_clock=True)
        yield Static(id="status-bar")
        yield DataTable(id="email-table", show_cursor=True, zebra_stripes=True)
        yield Input(
            placeholder='Search (e.g. "from:github" or "is:unread")',
            id="search-input",
            classes="hidden",
        )
        yield Footer()

    def on_mount(self) -> None:
        self.gmail = GmailClient(self.account)
        table = self.query_one("#email-table", DataTable)
        table.cursor_type = "row"
        table.add_columns("", "Date", "From", "Subject", "Labels")
        self.load_messages()

    @work(thread=True, exit_on_error=False)
    def load_messages(self, query: str | None = None) -> None:  # type: ignore[misc]
        self.post_message(self.StatusMsg("Loading messages..."))
        try:
            client = self.gmail
            if client is None:
                return
            msgs, total = client.list_messages(query=query, fetch_all=True)
            self.post_message(self.MessagesLoaded(msgs, total, query or ""))
        except Exception as e:
            self.post_message(self.StatusMsg(f"Error: {e}", is_error=True))

    def on_email_list_screen_status_msg(self, msg: StatusMsg) -> None:
        self.status_text = msg.text

    def on_email_list_screen_messages_loaded(self, msg: MessagesLoaded) -> None:
        self.messages = msg.messages
        self.total = msg.total
        self.refresh_table()

    def watch_status_text(self, text: str) -> None:
        bar = self.query_one("#status-bar", Static)
        bar.update(Text(text, style="bold"))

    def refresh_table(self) -> None:
        table = self.query_one("#email-table", DataTable)
        table.clear()
        self._selected_ids.clear()
        self._visual_mode = False

        results_text = f"{len(self.messages)} shown of {self.total} total"
        self.status_text = f"Gmail: {self.account.upper()}  |  {results_text}"

        for m in self.messages:
            is_unread = "UNREAD" in m.label_ids
            date_cell = make_date_cell(m.internal_date)
            sender_cell = make_sender_cell(m.from_)
            subject_cell = make_subject_cell(m.subject, is_unread)
            indicator = Text("  ")
            labels_cell = make_labels_cell(m.label_ids)

            table.add_row(
                indicator,
                date_cell,
                sender_cell,
                subject_cell,
                labels_cell,
                key=m.id,
            )

        if table.row_count:
            self.call_later(self._init_cursor)

    def _init_cursor(self) -> None:
        table = self.query_one("#email-table", DataTable)
        if not table.row_count:
            self.ensure_table_focused()
            return
        pending = self._pending_cursor_row
        self._pending_cursor_row = None
        row = min(pending, table.row_count - 1) if pending is not None else 0
        table.move_cursor(row=row)
        self.ensure_table_focused()

    def on_data_table_row_selected(self, event: DataTable.RowSelected) -> None:
        """Handle Enter key — use event data directly, no cursor lookup needed."""
        row = event.cursor_row
        if 0 <= row < len(self.messages):
            msg = self.messages[row]
            client = self.gmail
            if client:
                self.app.push_screen(
                    EmailViewScreen(client, msg), self._handle_view_result
                )
        else:
            self.status_text = "No message selected — press j/k first"

    def get_selected_message(self) -> Message | None:
        """Return the message at the current cursor row by direct list index."""
        if not self.messages:
            self.status_text = "No messages loaded"
            return None
        table = self.query_one("#email-table", DataTable)
        row = table.cursor_coordinate.row
        if row is None or not (0 <= row < len(self.messages)):
            self.status_text = "No row selected — press j/k to navigate first"
            return None
        return self.messages[row]

    def ensure_table_focused(self) -> None:
        """Ensure the DataTable has focus so keyboard bindings work."""
        search = self.query_one("#search-input", Input)
        if search.has_focus:
            return  # search is active, don't steal focus
        table = self.query_one("#email-table", DataTable)
        if not table.has_focus:
            table.focus()

    def action_cursor_down(self) -> None:
        table = self.query_one("#email-table", DataTable)
        try:
            table.action_cursor_down()
        except Exception:
            pass
        if self._visual_mode:
            self._update_visual_selection()

    def action_cursor_up(self) -> None:
        table = self.query_one("#email-table", DataTable)
        try:
            table.action_cursor_up()
        except Exception:
            pass
        if self._visual_mode:
            self._update_visual_selection()

    def action_top(self) -> None:
        table = self.query_one("#email-table", DataTable)
        table.move_cursor(row=0)

    def action_bottom(self) -> None:
        table = self.query_one("#email-table", DataTable)
        table.move_cursor(row=len(self.messages) - 1)

    def action_view_email(self) -> None:
        msg = self.get_selected_message()
        if not msg:
            self.status_text = "No message selected — use j/k to navigate"
            return
        self.ensure_table_focused()
        client = self.gmail
        if client is None:
            return
        viewer = EmailViewScreen(client, msg)
        self.app.push_screen(viewer, self._handle_view_result)

    def _handle_view_result(self, result: Any) -> None:
        if result is None:
            return
        if isinstance(result, dict) and result.get("action") == "delete":
            self._delete_message(str(result["msg_id"]))

    def _reset_status(self) -> None:
        self.status_text = (
            f"Gmail: {self.account.upper()}  |  "
            f"{len(self.messages)} shown of {self.total} total"
        )

    def action_toggle_select(self) -> None:
        table = self.query_one("#email-table", DataTable)
        row = table.cursor_coordinate.row
        if self._visual_mode:
            # Exit visual mode — keep selection, let user act on it
            self._visual_mode = False
            count = len(self._selected_ids)
            if count:
                self.status_text = f"{count} selected — d/a/u/s to act, Esc to cancel"
            else:
                self._reset_status()
        else:
            # Enter visual mode — clear any prior selection, anchor at cursor
            self._visual_mode = True
            self._visual_anchor = row
            self._selected_ids.clear()
            for r in range(table.row_count):
                table.update_cell_at(Coordinate(r, 0), Text("  "))
            if 0 <= row < len(self.messages):
                self._selected_ids.add(self.messages[row].id)
                table.update_cell_at(Coordinate(row, 0), Text("✓", style="bold green"))
            self.status_text = "VISUAL — j/k to extend, v to confirm, Esc to cancel"

    def _update_visual_selection(self) -> None:
        table = self.query_one("#email-table", DataTable)
        current = table.cursor_coordinate.row
        lo, hi = min(self._visual_anchor, current), max(self._visual_anchor, current)
        self._selected_ids.clear()
        for r in range(table.row_count):
            if lo <= r <= hi and r < len(self.messages):
                self._selected_ids.add(self.messages[r].id)
                table.update_cell_at(Coordinate(r, 0), Text("✓", style="bold green"))
            else:
                table.update_cell_at(Coordinate(r, 0), Text("  "))
        self.status_text = (
            f"VISUAL {len(self._selected_ids)} — v to confirm, Esc to cancel"
        )

    def action_delete_email(self) -> None:
        if self._selected_ids:
            self._delete_selected()
            return
        msg = self.get_selected_message()
        if not msg:
            self.status_text = "No message selected — use j/k to navigate"
            return
        self._delete_message(msg.id)

    def _delete_message(self, msg_id: str) -> None:
        subject = "(unknown)"
        for m in self.messages:
            if m.id == msg_id:
                subject = m.subject
                break

        table = self.query_one("#email-table", DataTable)
        cursor_row: int = table.cursor_coordinate.row or 0

        def handle_confirm(confirmed: bool | None) -> None:
            if confirmed:
                self._run_delete(msg_id, cursor_row)

        self.app.push_screen(ConfirmDeleteScreen(subject), handle_confirm)

    @work(thread=True)
    def _run_delete(self, msg_id: str, cursor_row: int) -> None:  # type: ignore[misc]
        try:
            client = self.gmail
            if client is None:
                return
            client.trash_message(msg_id)
            self._pending_cursor_row = cursor_row
            self.load_messages()
            self.post_message(self.StatusMsg("Message moved to Trash"))
        except Exception as e:
            self.post_message(self.StatusMsg(f"Delete failed: {e}", is_error=True))

    def _delete_selected(self) -> None:
        ids = list(self._selected_ids)
        table = self.query_one("#email-table", DataTable)
        cursor_row: int = table.cursor_coordinate.row or 0

        def handle_confirm(confirmed: bool | None) -> None:
            if confirmed:
                self._selected_ids.clear()
                self._run_bulk_delete(ids, cursor_row)

        self.app.push_screen(
            ConfirmDeleteScreen(f"{len(ids)} selected messages"), handle_confirm
        )

    @work(thread=True)
    def _run_bulk_delete(self, msg_ids: list[str], cursor_row: int) -> None:  # type: ignore[misc]
        try:
            client = self.gmail
            if client is None:
                return
            for msg_id in msg_ids:
                client.trash_message(msg_id)
            self._pending_cursor_row = cursor_row
            self.load_messages()
            self.post_message(self.StatusMsg(f"{len(msg_ids)} messages moved to Trash"))
        except Exception as e:
            self.post_message(self.StatusMsg(f"Delete failed: {e}", is_error=True))

    def action_next_account(self) -> None:
        accounts = _discover_accounts()
        if len(accounts) < 2:
            return
        idx = accounts.index(self.account) if self.account in accounts else 0
        self.account = accounts[(idx + 1) % len(accounts)]
        self.gmail = GmailClient(self.account)
        self._selected_ids.clear()
        self._visual_mode = False
        self.load_messages()

    def action_refresh(self) -> None:
        search = self.query_one("#search-input", Input)
        query: str | None = search.value.strip() if search.value else None
        self.load_messages(query=query)

    def action_focus_search(self) -> None:
        search = self.query_one("#search-input", Input)
        search.remove_class("hidden")
        search.focus()

    def action_unfocus(self) -> None:
        if self._visual_mode:
            self._visual_mode = False
            self._selected_ids.clear()
            table = self.query_one("#email-table", DataTable)
            for r in range(table.row_count):
                table.update_cell_at(Coordinate(r, 0), Text("  "))
            self._reset_status()
            return
        search = self.query_one("#search-input", Input)
        search.add_class("hidden")
        self.query_one("#email-table", DataTable).focus()

    def on_input_submitted(self, event: Input.Submitted) -> None:
        if event.input.id == "search-input":
            event.input.add_class("hidden")
            self.load_messages(query=event.value.strip() or None)
            self.query_one("#email-table", DataTable).focus()

    def action_toggle_unread(self) -> None:
        if self._selected_ids:
            selected = [m for m in self.messages if m.id in self._selected_ids]
            mark_read = any("UNREAD" in m.label_ids for m in selected)
            self._run_bulk_toggle(list(self._selected_ids), mark_read=mark_read)
            return
        msg = self.get_selected_message()
        if not msg:
            return
        self._run_toggle(msg.id, "UNREAD" in msg.label_ids)

    @work(thread=True)
    def _run_toggle(self, msg_id: str, is_unread: bool) -> None:  # type: ignore[misc]
        try:
            client = self.gmail
            if client is None:
                return
            if is_unread:
                client.modify_message(msg_id, remove_labels=["UNREAD"])
            else:
                client.modify_message(msg_id, add_labels=["UNREAD"])
            self.load_messages()
        except Exception as e:
            self.post_message(self.StatusMsg(f"Toggle failed: {e}", is_error=True))

    @work(thread=True)
    def _run_bulk_toggle(self, msg_ids: list[str], mark_read: bool) -> None:  # type: ignore[misc]
        try:
            client = self.gmail
            if client is None:
                return
            for msg_id in msg_ids:
                if mark_read:
                    client.modify_message(msg_id, remove_labels=["UNREAD"])
                else:
                    client.modify_message(msg_id, add_labels=["UNREAD"])
            self.load_messages()
            label = "read" if mark_read else "unread"
            self.post_message(self.StatusMsg(f"{len(msg_ids)} messages marked {label}"))
        except Exception as e:
            self.post_message(self.StatusMsg(f"Toggle failed: {e}", is_error=True))

    def action_archive_email(self) -> None:
        ids = list(self._selected_ids) if self._selected_ids else None
        if ids is None:
            msg = self.get_selected_message()
            if not msg:
                return
            ids = [msg.id]
        table = self.query_one("#email-table", DataTable)
        cursor_row: int = table.cursor_coordinate.row or 0
        self._run_bulk_archive(ids, cursor_row)

    @work(thread=True)
    def _run_bulk_archive(self, msg_ids: list[str], cursor_row: int) -> None:  # type: ignore[misc]
        try:
            client = self.gmail
            if client is None:
                return
            for msg_id in msg_ids:
                client.modify_message(msg_id, remove_labels=["INBOX"])
            self._pending_cursor_row = cursor_row
            self.load_messages()
            self.post_message(self.StatusMsg(f"{len(msg_ids)} messages archived"))
        except Exception as e:
            self.post_message(self.StatusMsg(f"Archive failed: {e}", is_error=True))

    def action_star_email(self) -> None:
        if self._selected_ids:
            selected = [m for m in self.messages if m.id in self._selected_ids]
            add_star = any("STARRED" not in m.label_ids for m in selected)
            self._run_bulk_star(list(self._selected_ids), add_star=add_star)
            return
        msg = self.get_selected_message()
        if not msg:
            return
        self._run_bulk_star([msg.id], add_star="STARRED" not in msg.label_ids)

    @work(thread=True)
    def _run_bulk_star(self, msg_ids: list[str], add_star: bool) -> None:  # type: ignore[misc]
        try:
            client = self.gmail
            if client is None:
                return
            for msg_id in msg_ids:
                if add_star:
                    client.modify_message(msg_id, add_labels=["STARRED"])
                else:
                    client.modify_message(msg_id, remove_labels=["STARRED"])
            self.load_messages()
            action = "starred" if add_star else "unstarred"
            self.post_message(self.StatusMsg(f"{len(msg_ids)} messages {action}"))
        except Exception as e:
            self.post_message(self.StatusMsg(f"Star failed: {e}", is_error=True))

    def action_quit_app(self) -> None:
        self.app.exit()


# ─── App ─────────────────────────────────────────────────────────────────────


class GmailTUI(App):
    """Textual-based terminal Gmail client."""

    TITLE = "gmail-tui"
    CSS = """
    Screen {
        background: $surface;
    }

    #status-bar {
        padding: 0 1;
        background: $panel;
        color: $text;
        height: 1;
        text-style: bold;
    }

    #email-table {
        height: 1fr;
        margin: 0 1;
    }

    #email-table > .datatable--header {
        background: $primary 20%;
        text-style: bold;
    }

    DataTable {
        border: none;
    }

    #search-input {
        dock: bottom;
        margin: 0 1 1 1;
    }

    .hidden {
        display: none;
    }

    #confirm-dialog {
        width: 50%;
        height: auto;
        padding: 2 4;
        border: thick $primary;
        background: $surface;
        margin-top: 10;
    }

    #confirm-title {
        text-style: bold;
        padding-bottom: 1;
    }

    #confirm-subject {
        padding-bottom: 1;
    }

    #confirm-hint {
        text-style: dim;
    }

    #email-body {
        padding: 1 2;
        height: 1fr;
    }

    EmailViewScreen {
        background: $surface;
    }
    """

    BINDINGS = [
        Binding("q", "quit", "Quit", show=False),
    ]

    def __init__(self, account: str) -> None:
        super().__init__()
        self.account = account

    def on_mount(self) -> None:
        self.app.push_screen(EmailListScreen(self.account))


def main() -> None:
    import argparse

    parser = argparse.ArgumentParser(
        description="Terminal Gmail client with vim keybindings",
    )
    parser.add_argument(
        "--account",
        "-a",
        help="Gmail account (default: allaria)",
        default="allaria",
    )
    args = parser.parse_args()

    app = GmailTUI(args.account)
    app.run()


if __name__ == "__main__":
    main()
