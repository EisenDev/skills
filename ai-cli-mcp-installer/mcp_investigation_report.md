# Antigravity CLI MCP Investigation Report

## Configuration Discovery Process
1. **Locating the binary**: Used `command -v agy` and discovered the executable at `/home/eisen/.local/bin/agy`.
2. **Identifying the language**: Inspected the binary using `file` and `strings`. Discovered Go reflection data, specifically `json` and `mapstructure` struct tags, confirming the CLI is written in **Go**.
3. **Tracing File Access**: Ran `inotifywait -m -r ~/.gemini` and intercepted the CLI's `/mcp` command execution. The trace explicitly captured the CLI opening `~/.gemini/config/mcp_config.json`, while completely ignoring `settings.json` for MCP purposes.
4. **Analyzing the schema**: Extracted the Go structs for the MCP server schema from the binary strings. The `mcp.ConfigSchemaJsonMcpServersValue` struct contains `url` and `serverUrl` string pointers rather than a `type` discriminator. The top-level schema expects an `mcpServers` object.
5. **Verifying the fix**: Wrote the `mcpServers` object natively into `~/.gemini/config/mcp_config.json` and removed obsolete config files to prevent conflicts.

## Relevant Code Snippets
The embedded Go structs revealed the exact JSON tags the CLI uses for parsing MCP settings:
```go
struct {
    Args []string "json:\"args,omitempty\" mapstructure:\"args,omitempty\""
    Command *string "json:\"command,omitempty\" mapstructure:\"command,omitempty\""
    ServerUrl *string "json:\"serverUrl,omitempty\" mapstructure:\"serverUrl,omitempty\""
    Url *string "json:\"url,omitempty\" mapstructure:\"url,omitempty\""
    ...
}
```

## Why the Current Installer Fails
The previous installer assumed that the Antigravity CLI stored its MCP settings in a standalone `~/.gemini/antigravity-cli/mcp.json` file, and later in `settings.json`. These were incorrect guesses. The CLI does not read `mcp.json` at all, and it does not load MCP servers from `settings.json`. 

## The Exact Reason "/mcp" Reports "No MCP servers configured"
Because the CLI's actual MCP configuration file is `~/.gemini/config/mcp_config.json` (the Global Customizations Root), any modifications to `mcp.json` or `settings.json` were completely invisible to the application's `/mcp` manager. When executing `/mcp`, the CLI parsed `~/.gemini/config/mcp_config.json`, found it empty (or missing the `mcpServers` key), and accurately reported that no servers were configured. The ClickUp MCP server has now been natively written to the correct path, resolving the issue.
