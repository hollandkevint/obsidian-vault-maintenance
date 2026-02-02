# Obsidian Vault Maintenance for Claude Code

Automatically process your Obsidian vault's inbox. Drop files in, run `/vault-maintenance`, get organized literature notes with proper tags and wiki-links.

**For Claude Code + Obsidian users.**

## What It Does

1. **Scans** your inbox/landing pad for new content
2. **Detects** content type (article, PDF, blog idea, meeting note)
3. **Consolidates** author series (10 articles from same author → 1 literature note)
4. **Creates** structured literature notes with frontmatter
5. **Auto-tags** based on content keywords
6. **Updates** your MOC with new links
7. **Wiki-links** to related existing notes
8. **Git commits** changes automatically

## Quick Start

### 1. Install the Skill

Copy the skill file to your Claude Code commands directory:

```bash
mkdir -p ~/.claude/commands
cp vault-maintenance.md ~/.claude/commands/
```

### 2. (Optional) Add Configuration

Copy the example config to your vault root and customize:

```bash
cp .vault-maintenance.example.yaml /path/to/your/vault/.vault-maintenance.yaml
```

### 3. Run It

```bash
cd /path/to/your/vault
claude

# Then in Claude Code:
/vault-maintenance
```

## Usage

### Interactive Mode (Default)

```bash
# Process default landing pad
/vault-maintenance

# Process specific folder
/vault-maintenance "Downloads/to-process"
```

### Headless/Automated Mode

For daily automation via launchd (macOS) or cron:

```bash
# Copy automation scripts
cp scripts/daily-vault-maintenance.sh ~/.claude/scripts/
cp prompts/daily-vault-maintenance.md ~/.claude/prompts/

# Make executable
chmod +x ~/.claude/scripts/daily-vault-maintenance.sh

# For macOS: Install launchd job (runs daily at 9 AM)
cp launchd/com.user.vault-maintenance.plist ~/Library/LaunchAgents/
launchctl load ~/Library/LaunchAgents/com.user.vault-maintenance.plist

# Manual trigger
~/.claude/scripts/daily-vault-maintenance.sh
```

## Configuration

Create `.vault-maintenance.yaml` in your vault root:

```yaml
# Where new content lands
landing_pad: "Inbox/"

# Where processed content goes
destinations:
  literature_notes: "Notes/Sources/"
  blog_ideas: "Notes/Ideas/"
  processing: "Notes/Processing/"

# MOC to auto-update (optional)
primary_moc: "Notes/Sources-MOC.md"

# Authors to consolidate (3+ articles → 1 note)
known_authors:
  - name: "Paul Graham"
    topics: ["startups", "essays"]
  - name: "Simon Willison"
    topics: ["AI", "Python"]

# Keyword → tag mapping
topic_rules:
  - keywords: ["AI", "Claude", "prompt", "LLM"]
    tags: ["topic/ai"]
  - keywords: ["product", "roadmap", "PM"]
    tags: ["topic/product"]

# Git settings
git:
  enabled: true
  message_prefix: "vault: auto-organize"
  co_author: "Claude <noreply@anthropic.com>"

# Safety limit
max_files_per_run: 15
```

### Configuration Options

| Option | Default | Description |
|--------|---------|-------------|
| `landing_pad` | `"Inbox/"` or `"📥 Landing Pad/"` | Folder to scan for new content |
| `destinations.literature_notes` | `"Sources/"` | Where literature notes go |
| `destinations.blog_ideas` | `"Content/Ideas/"` | Where blog ideas go |
| `destinations.processing` | `"Processing/"` | Where work-in-progress goes |
| `primary_moc` | `null` | MOC to auto-update with new notes |
| `known_authors` | `[]` | Authors to consolidate (3+ items → 1 note) |
| `topic_rules` | See defaults | Keyword → tag mapping |
| `git.enabled` | `true` | Auto-commit changes |
| `git.message_prefix` | `"chore: vault maintenance"` | Commit message prefix |
| `git.co_author` | `"Claude <noreply@anthropic.com>"` | Git co-author |
| `max_files_per_run` | `15` | Safety limit per execution |

## Authentication (for Headless Mode)

The automation script supports two authentication methods:

### Option 1: OAuth Token (Recommended - No Extra Cost)

If you have a Claude Max subscription:

```bash
# Generate OAuth token (valid 1 year)
claude setup-token

# Store in macOS Keychain
security add-generic-password -a "$USER" -s "claude-code-oauth" -w "YOUR_TOKEN"

# Or add to .env in vault root
echo 'CLAUDE_CODE_OAUTH_TOKEN=YOUR_TOKEN' >> /path/to/vault/.env
```

### Option 2: API Key (Pay-per-use)

```bash
export ANTHROPIC_API_KEY=your_key

# Or force API mode
~/.claude/scripts/daily-vault-maintenance.sh --api
```

### Auth Priority

The script checks in order:
1. OAuth token from macOS Keychain
2. OAuth token from vault `.env`
3. API key from environment

## File Structure

```
obsidian-vault-maintenance/
├── README.md                           # This file
├── LICENSE                             # MIT License
├── vault-maintenance.md                # The skill (copy to ~/.claude/commands/)
├── .vault-maintenance.example.yaml     # Example config
├── prompts/
│   └── daily-vault-maintenance.md      # Headless prompt
├── scripts/
│   └── daily-vault-maintenance.sh      # Automation wrapper
└── launchd/
    └── com.user.vault-maintenance.plist # macOS scheduler
```

## Literature Note Format

Created notes follow this structure:

```markdown
---
created: 2026-02-02
source: web
author: Author Name
url: https://example.com/article
tags:
  - type/literature-note
  - topic/ai
---

# Article Title - Literature Note

## Source
- **Author**: Author Name
- **Date**: 2026-02-02
- **Link**: https://example.com/article

## Key Concepts
- Main idea 1
- Main idea 2
- Main idea 3

## Frameworks/Models
Any structured methodologies mentioned

## Quotable Insights
> Direct quotes worth saving

## Application Notes
How to apply this knowledge

## Related
- [[related-note-1]]
- [[related-note-2]]
```

## Content Type Detection

| Content | Action |
|---------|--------|
| PDF | Move to sources, create companion literature note |
| Article series (3+ from same author) | Consolidate into single literature note |
| Single article | Create individual literature note |
| Blog idea (contains "idea" or `status: idea`) | Move to blog ideas folder |
| Screenshot/image | Move to related project or leave with note |

## Constraints

- Never deletes files
- Never modifies files outside vault
- Leaves uncertain items in landing pad with explanation
- Max 15 files per run (configurable)
- Consolidates related content automatically
- Prefers editing existing MOCs over creating new ones

## Requirements

- [Claude Code](https://claude.ai/code) CLI installed
- Obsidian vault with git initialized (optional but recommended)
- macOS for launchd automation (or adapt for cron on Linux)

## Troubleshooting

### "Credit balance too low" error

You're using API key mode without credits. Either:
- Add credits at console.anthropic.com
- Switch to OAuth mode with Max subscription

### Skill not found

Ensure the skill is in the right location:
```bash
ls ~/.claude/commands/vault-maintenance.md
```

### Headless mode hangs

Check authentication:
```bash
# Test OAuth token
security find-generic-password -a "$USER" -s "claude-code-oauth" -w

# Test with explicit mode
~/.claude/scripts/daily-vault-maintenance.sh --oauth
```

## Contributing

Issues and PRs welcome. Please include:
- Your vault structure (anonymized)
- Config file (if custom)
- Expected vs actual behavior

## License

MIT

## Author

Kevin Holland ([@kevintholland](https://linkedin.com/in/kevintholland))

Built with Claude Code.
