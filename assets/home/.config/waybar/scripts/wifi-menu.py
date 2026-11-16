#!/usr/bin/env python3

from __future__ import annotations

import os
import subprocess
import sys

ROFI = ["rofi", "-dmenu", "-i", "-p", "Wi-Fi"]
EDITOR = "nm-connection-editor"
APP = "Wi-Fi"


def which(cmd: str) -> str | None:
    if os.path.dirname(cmd):
        return cmd if os.access(cmd, os.X_OK) else None
    for directory in os.environ.get("PATH", "").split(os.pathsep):
        path = os.path.join(directory, cmd)
        if os.access(path, os.X_OK) and not os.path.isdir(path):
            return path
    return None


def run(
    cmd: list[str], *, input_text: str | None = None
) -> subprocess.CompletedProcess:
    try:
        return subprocess.run(
            cmd, input=input_text, text=True, capture_output=True, check=False
        )
    except FileNotFoundError:
        return subprocess.CompletedProcess(cmd, 127, "", f"Command not found: {cmd[0]}")


def launch(cmd: list[str]) -> None:
    try:
        subprocess.Popen(cmd, start_new_session=True)
    except FileNotFoundError:
        notify("Wi-Fi", f"Command not found: {cmd[0]}")


def notify(title: str, body: str = "") -> None:
    if which("notify-send"):
        subprocess.run(["notify-send", "-a", APP, title, body], check=False)


def split_nmcli(line: str) -> list[str]:
    parts: list[str] = []
    cur: list[str] = []
    escaped = False
    for ch in line:
        if escaped:
            cur.append(ch)
            escaped = False
        elif ch == "\\":
            escaped = True
        elif ch == ":":
            parts.append("".join(cur))
            cur = []
        else:
            cur.append(ch)
    parts.append("".join(cur))
    return parts


def nmcli(*args: str) -> subprocess.CompletedProcess:
    return run(["nmcli", *args])


def nmcli_parallel(*calls: tuple[str, ...]) -> list[subprocess.CompletedProcess]:
    procs = [
        subprocess.Popen(
            ["nmcli", *args],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
        )
        for args in calls
    ]
    results: list[subprocess.CompletedProcess] = []
    for proc in procs:
        out, err = proc.communicate()
        results.append(subprocess.CompletedProcess(proc.args, proc.returncode, out, err))
    return results


def parse_active(out: str) -> tuple[str | None, str | None]:
    for line in out.splitlines():
        parts = split_nmcli(line)
        if len(parts) < 3 or parts[1] != "802-11-wireless":
            continue
        if parts[2] in ("", "--"):
            continue
        return parts[0], parts[2]
    return None, None


def find_profile(ssid: str) -> str | None:
    out = nmcli("-t", "-f", "NAME,TYPE", "connection", "show").stdout
    names: list[str] = []
    for line in out.splitlines():
        parts = split_nmcli(line)
        if len(parts) >= 2 and parts[1] == "802-11-wireless":
            names.append(parts[0])
    if ssid in names:
        return ssid
    for name in names:
        current = nmcli(
            "-g", "802-11-wireless.ssid", "connection", "show", name
        ).stdout.strip()
        if current == ssid:
            return name
    return None


def parse_networks(out: str) -> list[dict[str, object]]:
    nets: dict[str, dict[str, object]] = {}
    for line in out.splitlines():
        parts = split_nmcli(line)
        if len(parts) < 4:
            continue
        in_use, ssid, signal, security = parts[0], parts[1], parts[2], parts[3]
        if not ssid:
            continue
        try:
            sig = int(signal)
        except ValueError:
            sig = 0
        prev = nets.get(ssid)
        if prev is None or sig > int(prev["signal"]):
            nets[ssid] = {
                "ssid": ssid,
                "signal": sig,
                "security": security,
                "in_use": in_use == "*",
            }
    return sorted(
        nets.values(),
        key=lambda n: (
            0 if n["in_use"] else 1,
            -int(n["signal"]),
            str(n["ssid"]).lower(),
        ),
    )


def scan_networks(*, rescan: bool = False) -> list[dict[str, object]]:
    return parse_networks(
        nmcli(
            "-t",
            "-f",
            "IN-USE,SSID,SIGNAL,SECURITY",
            "device",
            "wifi",
            "list",
            "--rescan",
            "yes" if rescan else "no",
        ).stdout
    )


def signal_bar(signal: int) -> str:
    if signal >= 75:
        return "▂▄▆█"
    if signal >= 50:
        return "▂▄▆_"
    if signal >= 25:
        return "▂▄__"
    return "▂___"


def security_label(security: str) -> str:
    if not security or security == "--":
        return "open"
    if "802.1X" in security or "Enterprise" in security.upper():
        return "802.1X"
    return security


def build_entries() -> tuple[str, list[tuple[str, str, object | None]]]:
    general, active, scan = nmcli_parallel(
        ("-t", "-f", "WIFI", "general"),
        ("-t", "-f", "NAME,TYPE,DEVICE", "connection", "show", "--active"),
        (
            "-t",
            "-f",
            "IN-USE,SSID,SIGNAL,SECURITY",
            "device",
            "wifi",
            "list",
            "--rescan",
            "no",
        ),
    )
    enabled = general.stdout.strip() == "enabled"
    active_name, _ = parse_active(active.stdout)
    networks = parse_networks(scan.stdout) if enabled else []
    if enabled and not networks:
        notify("Scanning Wi-Fi", "No cached networks. This may take a few seconds.")
        networks = scan_networks(rescan=True)

    if enabled:
        status = "Wi-Fi on"
        if active_name:
            status += f" · connected to {active_name}"
    else:
        status = "Wi-Fi off"

    entries: list[tuple[str, str, object | None]] = []
    entries.append(
        ("  Turn off Wi-Fi", "wifi_off", None)
        if enabled
        else ("  Turn on Wi-Fi", "wifi_on", None)
    )

    if enabled and active_name:
        entries.append((f"  Disconnect from {active_name}", "disconnect", active_name))

    entries += [
        ("━" * 24, "separator", None),
        ("  Open connections list", "editor", None),
        ("  Refresh list", "refresh", None),
    ]

    if enabled:
        for idx, net in enumerate(networks, 1):
            mark = "●" if net["in_use"] else " "
            label = (
                f"{idx:>2}. {mark} {security_label(str(net['security'])):<9} "
                f"{signal_bar(int(net['signal']))} {int(net['signal']):>3}%  {net['ssid']}"
            )
            entries.append((label, "connect", net))

    return status, entries


def activate_profile(name: str) -> bool:
    return nmcli("connection", "up", "id", name).returncode == 0


def ask_password(ssid: str) -> str | None:
    proc = run(["zenity", "--password", "--title=Wi-Fi", f"--text=Password for {ssid}"])
    if proc.returncode != 0:
        return None
    return proc.stdout.rstrip("\n")


def connect_network(net: dict[str, object]) -> None:
    ssid = str(net["ssid"])
    security = str(net["security"])

    if "802.1X" in security or "Enterprise" in security.upper():
        notify(
            "Enterprise network",
            f"{ssid} must be configured in the connection editor.",
        )
        launch([EDITOR])
        return

    profile = find_profile(ssid)
    if profile and activate_profile(profile):
        notify("Connected", ssid)
        return

    password = None
    if security and security != "--":
        password = ask_password(ssid)
        if password is None:
            return

    cmd = ["nmcli", "device", "wifi", "connect", ssid]
    if password:
        cmd += ["password", password]
    res = run(cmd)
    if res.returncode == 0:
        notify("Connected", ssid)
    else:
        notify("Failed to connect", ssid)


def main() -> int:
    if not which("nmcli"):
        notify("Wi-Fi", "nmcli is not installed.")
        return 1

    status, entries = build_entries()
    proc = run(
        [*ROFI, "-mesg", status],
        input_text="\n".join(label for label, _, _ in entries) + "\n",
    )
    if proc.returncode == 127:
        notify("Wi-Fi", "rofi is not installed.")
        return 1
    if proc.returncode != 0:
        return 0

    chosen = proc.stdout.rstrip("\n")
    if not chosen:
        return 0

    for label, action, data in entries:
        if label != chosen:
            continue
        if action == "wifi_off":
            if nmcli("radio", "wifi", "off").returncode == 0:
                notify("Wi-Fi off")
            else:
                notify("Failed to turn Wi-Fi off")
        elif action == "wifi_on":
            if nmcli("radio", "wifi", "on").returncode == 0:
                notify("Wi-Fi on")
            else:
                notify("Failed to turn Wi-Fi on")
        elif action == "disconnect":
            if nmcli("connection", "down", "id", str(data)).returncode == 0:
                notify("Disconnected", str(data))
            else:
                notify("Failed to disconnect", str(data))
        elif action == "editor":
            launch([EDITOR])
        elif action == "refresh":
            nmcli("device", "wifi", "rescan")
            notify("Scanning Wi-Fi", "The list will update in a few seconds.")
            os.execv(sys.executable, [sys.executable, os.path.realpath(__file__)])
        elif action == "connect":
            connect_network(data)  # type: ignore[arg-type]
        break
    return 0


if __name__ == "__main__":
    sys.exit(main())
