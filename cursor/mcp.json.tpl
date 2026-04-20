{
  "mcpServers": {
    "github": {
      "url": "https://api.githubcopilot.com/mcp/",
      "headers": {
        "Authorization": "Bearer op://clawd/cbndd6i4kc4wqmlg22fc3p6nkm/credential"
      }
    },
    "context7": {
      "url": "https://mcp.context7.com/mcp",
      "headers": {
        "CONTEXT7_API_KEY": "op://clawd/qivvl2atclndugp4cecg3oxqey/API Key"
      }
    },
    "Sentry": {
      "url": "https://mcp.sentry.dev/mcp"
    },
    "chrome-devtools": {
      "command": "npx",
      "args": ["-y", "chrome-devtools-mcp@latest"]
    },
    "playwriter": {
      "command": "npx",
      "args": ["playwriter@latest"]
    },
    "shadcn": {
      "command": "npx",
      "args": ["shadcn@latest", "mcp"]
    }
  }
}
