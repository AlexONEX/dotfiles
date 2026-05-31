#!/usr/bin/env uv run
# /// script
# requires-python = ">=3.11"
# dependencies = [
#   "google-auth>=2.1",
#   "google-auth-oauthlib>=1.0",
# ]
# ///
"""
gmail-reauth — Re-autenticación OAuth para cuentas Gmail.

Re-ejecuta el flujo OAuth (abre browser, pegás el código) y guarda
el token fresco en ~/.gmail-mcp/credentials-{account}.json.

Uso:
    gmail-reauth.py almafintech
    gmail-reauth.py allaria         # si alguna vez expira
"""

from __future__ import annotations

import json
import os
import sys
import webbrowser

SCOPES = [
    "https://www.googleapis.com/auth/gmail.settings.sharing",
    "https://www.googleapis.com/auth/gmail.compose",
    "https://www.googleapis.com/auth/gmail.modify",
    "https://www.googleapis.com/auth/gmail.settings.basic",
    "https://www.googleapis.com/auth/gmail.send",
]

CREDS_DIR = os.path.expanduser("~/.gmail-mcp")
OAUTH_KEYS = os.path.join(CREDS_DIR, "gcp-oauth.keys.json")
REDIRECT_PORT = 8080
REDIRECT_URI = f"http://localhost:{REDIRECT_PORT}/"


def load_client_config() -> dict:
    if not os.path.exists(OAUTH_KEYS):
        print(f"✗ No se encuentra: {OAUTH_KEYS}")
        print("  Este archivo tiene el client_id / client_secret de Google Cloud.")
        sys.exit(1)
    with open(OAUTH_KEYS) as f:
        raw = json.load(f)
    # Normalizar al formato que espera google_auth_oauthlib
    installed = raw.get("installed", raw)
    return {
        "installed": {
            "client_id": installed["client_id"],
            "client_secret": installed["client_secret"],
            "auth_uri": installed.get("auth_uri", "https://accounts.google.com/o/oauth2/auth"),
            "token_uri": installed.get("token_uri", "https://oauth2.googleapis.com/token"),
            "redirect_uris": [REDIRECT_URI],
        }
    }


def main():
    if len(sys.argv) < 2:
        print(f"Uso: {sys.argv[0]} <account>")
        print(f"Ej:  {sys.argv[0]} almafintech")
        sys.exit(1)

    account = sys.argv[1]
    token_path = os.path.join(CREDS_DIR, f"credentials-{account}.json")

    print(f"🔑 Re-autenticando cuenta: {account}")
    print(f"   Token: {token_path}")
    print()

    from google_auth_oauthlib.flow import InstalledAppFlow

    client_config = load_client_config()
    flow = InstalledAppFlow.from_client_config(
        client_config,
        scopes=SCOPES,
        redirect_uri=REDIRECT_URI,
    )

    # Abrir browser automáticamente
    auth_url, _ = flow.authorization_url(
        access_type="offline",
        include_granted_scopes="true",
        prompt="consent",  # fuerza refresh_token aunque ya exista
    )

    print(f"→ Abriendo browser para autorizar...")
    webbrowser.open(auth_url)

    # Usa el loopback server integrado (puerto aleatorio, automanejado)
    print("   Esperando autorización en el browser...")
    creds = flow.run_local_server(
        port=0,                 # puerto aleatorio
        open_browser=True,
        success_message="✅ Autorizado. Ya podes cerrar esta ventana.",
    )

    creds = flow.credentials
    token_data = {
        "access_token": creds.token,
        "refresh_token": creds.refresh_token,
        "scope": " ".join(creds.scopes),
        "token_type": "Bearer",
        "expiry_date": int(creds.expiry.timestamp() * 1000),
    }

    with open(token_path, "w") as f:
        json.dump(token_data, f, indent=2)

    print(f"\n✅ Token guardado en: {token_path}")
    print(f"   Access token:  {creds.token[:40]}...")
    print(f"   Refresh token: {creds.refresh_token[:40]}...")
    print(f"   Expira:        {creds.expiry}")
    print()
    print("ℹ️  Ahora reiniciá la sesión de opencode o el MCP para que tome el nuevo token.")
    print("   O simplemente cerra y abrí de nuevo opencode.")


if __name__ == "__main__":
    main()
