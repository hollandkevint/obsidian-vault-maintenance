---
name: vault-maintenance
description: Process Obsidian vault inbox - organize content, create literature notes, update MOCs, git commit
---

# Obsidian Vault Maintenance

Automatically process new content from your vault's inbox/landing pad into organized knowledge.

**For Claude Code + Obsidian users.** Drop files in your landing pad, run `/vault-maintenance`, get organized literature notes with proper tags and wiki-links.

## Quick Start

```bash
# Process default landing pad (Inbox/ or 📥 Landing Pad/)
/vault-maintenance

# Process specific folder
/vault-maintenance "Downloads/to-process"
```

## What This Skill Does

1. **Scans** your landing pad for new content
2. **Detects** content type (article, PDF, blog idea, meeting note)
3. **Consolidates** author series (10 articles → 1 literature note)
4. **Creates** structured literature notes with frontmatter
5. **Auto-tags** based on content keywords
6. **Updates** your MOC with new links
7. **Wiki-links** to related existing notes
8. **Git commits** changes automatically

## Installation

### 1. Download the skill

```bash
# Clone the repo
git clone https://github.com/hollandkevint/obsidian-vault-maintenance.git

# Or just download the skill file
curl -o ~/.claude/commands/vault-maintenance.md \
  https://raw.githubusercontent.com/hollandkevint/obsidian-vault-maintenance/main/vault-maintenance.md
```

### 2. (Optional) Add configuration

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

max_files_per_run: 15
```

### 3. Run it

```bash
cd /path/to/your/vault
claude
# Then type: /vault-maintenance
```

## Workflow

### Step 1: Load Configuration

Checks for `.vault-maintenance.yaml` in vault root. Uses sensible defaults if not found.

### Step 2: Scan Landing Pad

Lists all items, groups by:
- Same author (3+ items → consolidate)
- File type (PDF, markdown, image)
- Content type (article, blog idea, meeting note)

### Step 3: Process Each Item

| Content Type | Action |
|--------------|--------|
| PDF | Move to sources, create companion literature note |
| Article series (3+ same author) | Consolidate into single literature note |
| Single article | Create individual literature note |
| Blog idea | Move to ideas folder with `status: idea` |
| Screenshot | Move to related project or leave with note |

### Step 4: Create Literature Notes

```markdown
---
created: 2026-02-02
source: web
author: Author Name
url: https://example.com
tags:
  - type/literature-note
  - topic/ai
---

# Article Title - Literature Note

## Source
- **Author**: Author Name
- **Date**: 2026-02-02
- **Link**: https://example.com

## Key Concepts
- Main idea 1
- Main idea 2

## Frameworks/Models
Any methodologies mentioned

## Quotable Insights
> Direct quotes worth saving

## Application Notes
How to apply this knowledge

## Related
- [[related-note]]
```

### Step 5: Topic Detection

Scans content for keywords, applies matching tags:

| Keywords | Tags |
|----------|------|
| AI, Claude, prompt, LLM, agent | `topic/ai` |
| product, roadmap, PM | `topic/product` |
| data, analytics, pipeline | `topic/data` |
| healthcare, clinical, FHIR | `topic/healthcare` |

### Step 6: Update MOC

If `primary_moc` configured, adds new notes:
```markdown
- [[Note-Name]] - Brief description
```

### Step 7: Git Commit

If `git.enabled`:
```bash
git add .
git commit -m "vault: auto-organize - processed N items"
```

## Headless/Automated Mode

For daily automation via launchd (macOS) or cron:

### Setup

```bash
# Copy scripts
mkdir -p ~/.claude/scripts ~/.claude/prompts
cp scripts/daily-vault-maintenance.sh ~/.claude/scripts/
cp prompts/daily-vault-maintenance.md ~/.claude/prompts/
chmod +x ~/.claude/scripts/daily-vault-maintenance.sh
```

### Authentication

**Option 1: OAuth Token (Max plan - no extra cost)**

```bash
# Generate token (valid 1 year)
claude setup-token

# Store in macOS Keychain
security add-generic-password -a "$USER" -s "claude-code-oauth" -w "YOUR_TOKEN"
```

**Option 2: API Key (pay-per-use)**

```bash
export ANTHROPIC_API_KEY=your_key
```

### Schedule (macOS)

```bash
# Copy and edit the plist (update paths for your username)
cp launchd/com.user.vault-maintenance.plist ~/Library/LaunchAgents/

# Load (runs daily at 9 AM)
launchctl load ~/Library/LaunchAgents/com.user.vault-maintenance.plist

# Manual trigger
launchctl start com.user.vault-maintenance
```

### Manual Run

```bash
~/.claude/scripts/daily-vault-maintenance.sh
~/.claude/scripts/daily-vault-maintenance.sh --oauth  # Force OAuth
~/.claude/scripts/daily-vault-maintenance.sh --api    # Force API key
```

## Constraints

- Never deletes files
- Never modifies outside vault
- If uncertain → leaves in landing pad with note
- Max 15 files per run (configurable)
- Consolidates related content
- Prefers editing existing MOCs

## Troubleshooting

### "No config file found"
That's fine - defaults will be used. Create `.vault-maintenance.yaml` for customization.

### "Landing pad empty"
Nothing to process. Drop some files in your inbox folder first.

### "Credit balance too low" (headless mode)
You're using API key mode. Either add credits or switch to OAuth with Max subscription.

### Skill not found
Ensure file is at `~/.claude/commands/vault-maintenance.md`

## Requirements

- [Claude Code](https://claude.ai/code) CLI
- Obsidian vault (git-tracked recommended)
- macOS for launchd automation (or adapt for cron)

## License

MIT - See [LICENSE](LICENSE)

## Author

Kevin Holland ([@kevintholland](https://linkedin.com/in/kevintholland))
