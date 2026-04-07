# HTTP Mode Lifecycle

Container runs in tmux. Port from `.knowledge/config.json`.

## Start
```bash
tmux new-session -d -s <session_id> \
  "podman run --rm -p <port>:3000 -v <db>:/data/wiki.db localhost/kb-mcp-server --transport http --port 3000 /data/wiki.db"
```

## Stop
```bash
tmux kill-session -t <session_id>
```

## Check
```bash
tmux has-session -t <session_id> 2>/dev/null && echo "running" || echo "stopped"
```

## Logs
```bash
tmux capture-pane -t <session_id> -p -S -50
```
