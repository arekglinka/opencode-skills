# OAuth Flow Reference

## When to Trigger
- Only when `include_google_workspace == "y"` was selected
- After cookiecutter project generation is complete
- After optional GitHub push is done

## Prerequisites
User needs `credentials.json` from Google Cloud Console:
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create or select a project
3. Enable APIs: Google Drive, Google Sheets, Google Tasks
4. Navigate to APIs & Services > Credentials
5. Create OAuth 2.0 Client ID (type: **Desktop app**, NOT web app)
6. Download the JSON credentials file
7. Place as `credentials.json` in the generated project root

## How It Works
The generated `google_workspace` component uses `google-auth-oauthlib`:

```python
from google_auth_oauthlib.flow import InstalledAppFlow
flow = InstalledAppFlow.from_client_secrets_file(
    "credentials.json",
    scopes=[
        "https://www.googleapis.com/auth/drive",
        "https://www.googleapis.com/auth/spreadsheets",
        "https://www.googleapis.com/auth/tasks",
    ],
)
credentials = flow.run_local_server(port=0)
```

`run_local_server(port=0)` opens a random local port and launches the system browser. On first run the user sees:
1. Google login page
2. OAuth consent screen listing requested permissions
3. "This app wants to access your Google Account"
4. User clicks "Allow"
5. Browser shows "Authentication successful"
6. Token is saved locally for future use

Credential lookup also respects the `GOOGLE_OAUTH_CREDENTIALS` env var as an override path.

## Token Persistence
- Token saved to: `.cache/google_workspace/token.json`
- Subsequent runs load the saved token (no browser needed)
- If the token is expired but has a refresh token, it auto-refreshes
- If the saved token is corrupted, a fresh OAuth flow starts
- `.cache/` is already in the template `.gitignore`

## Agent Instructions
1. After project generation, if google_workspace was selected:
   - Tell the user: "Google Workspace integration was included. To use it:"
   - List the steps to get `credentials.json` (see Prerequisites above)
   - Tell the user: "On first run, a browser window will open for OAuth consent"
   - Tell the user: "After first consent, the token is cached and no browser is needed later"
2. Do NOT automate the OAuth flow. Guide the user through it manually.
3. Do NOT ask for `credentials.json` contents. It contains secrets.
4. Do NOT run the OAuth flow as part of project generation.

## Troubleshooting
| Issue | Solution |
|-------|----------|
| `credentials.json not found` | Place file in project root, or set `GOOGLE_OAUTH_CREDENTIALS` env var |
| `Invalid client` or redirect_uri mismatch | Verify OAuth client type is "Desktop app" (not "Web application") |
| `Access blocked: OAuth 2.0` | Enable Drive, Sheets, and Tasks APIs in Google Cloud Console |
| Token expired, refresh failed | Delete `.cache/google_workspace/token.json` and re-authenticate |
| `Failed to load saved token` | Corrupted token file. Delete it and re-run (browser opens again) |
| Port in use | `run_local_server(port=0)` picks a random port. Shouldn't conflict. |
