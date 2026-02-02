---
description: Process Obsidian vault inbox - organize content, create literature notes, update MOCs, git commit
argument-hint: "[landing-pad-path]"
allowed-tools: Bash, Read, Write, Edit, Glob, Grep
model: sonnet
---

# Obsidian Vault Maintenance for Claude Code

Automatically process new content from your vault's inbox/landing pad into organized knowledge.

**For Claude Code + Obsidian users.** Drop files in your landing pad, run `/vault-maintenance`, get organized literature notes with proper tags and wiki-links.

---

## Quick Start

```bash
# Process default landing pad (📥 Landing Pad/ or Inbox/)
/vault-maintenance

# Process specific folder
/vault-maintenance "Downloads/to-process"

# With config file for full customization
# Create .vault-maintenance.yaml in vault root (see below)
```

---

## What This Skill Does

1. **Scans** your landing pad for new content
2. **Detects** content type (article, PDF, blog idea, meeting note)
3. **Consolidates** author series (10 articles → 1 literature note)
4. **Creates** structured literature notes with frontmatter
5. **Auto-tags** based on content keywords
6. **Updates** your MOC with new links
7. **Wiki-links** to related existing notes
8. **Git commits** changes automatically

---

## Step 0: Load Configuration

Check for `.vault-maintenance.yaml` in vault root.

**If no config file found, use these defaults:**

```yaml
landing_pad: "📥 Landing Pad/"  # or "Inbox/" if that exists

destinations:
  literature_notes: "Sources/"
  blog_ideas: "Content/Ideas/"
  processing: "Processing/"

primary_moc: null  # Set to auto-update a MOC

known_authors: []  # Authors to consolidate

topic_rules:
  - keywords: ["AI", "Claude", "prompt", "LLM", "agent"]
    tags: ["topic/ai"]
  - keywords: ["product", "roadmap", "PM"]
    tags: ["topic/product"]

git:
  enabled: true
  message_prefix: "chore: vault maintenance"
  co_author: "Claude <noreply@anthropic.com>"

max_files_per_run: 15
```

---

## Step 1: Scan Landing Pad

List all items in landing pad (excluding `.DS_Store`, `.gitkeep`).

**Group by:**
- Same author (3+ items → consolidate into one note)
- File type (PDF, markdown, image)
- Content type (article, blog idea, meeting note)

---

## Step 2: Process Each Item

### PDFs
- Move to `{destinations.literature_notes}`
- Create companion: `{filename}-Literature-Note.md`
- Add to `.gitignore` if >1MB

### Article Series (same author, 3+ items)
- Create ONE consolidated literature note
- Move raw files to subfolder: `{literature_notes}/{Author-Topic}/`
- Organize by theme, not by individual article

### Single Articles
- Create literature note: `Author-Topic-Literature-Note.md`
- Move to `{destinations.literature_notes}`

### Blog Ideas (contains "idea" or `status: idea`)
- Move to `{destinations.blog_ideas}`
- Ensure frontmatter has `status: idea`

### Images/Screenshots
- If filename suggests project → move there
- Otherwise → leave in landing pad, note uncertainty

---

## Step 3: Create Literature Notes

Use this structure for each:

```markdown
---
created: {TODAY}
source: {web|newsletter|pdf|book}
author: {Author Name}
url: {if applicable}
tags:
  - type/literature-note
  - {detected topic tags}
---

# {Title} - Literature Note

## Source
- **Author**: {Name}
- **Date**: {if known}
- **Link**: {if applicable}

## Key Concepts
{3-5 main ideas extracted from content}

## Frameworks/Models
{Any structured methodologies mentioned}

## Quotable Insights
> {Direct quotes worth saving}

## Application Notes
{How to apply this - connect to existing projects if known}

## Related
- [[related-note]]
```

---

## Step 4: Topic Detection

Scan content for keywords, apply matching tags:

**Default rules:**
| Keywords | Tags |
|----------|------|
| AI, Claude, prompt, LLM, agent | `topic/ai` |
| product, roadmap, PM | `topic/product` |
| data, analytics, pipeline | `topic/data` |
| healthcare, clinical, FHIR | `topic/healthcare` |
| consulting, freelance, pricing | `topic/consulting` |

**Custom rules** via config file `topic_rules`.

---

## Step 5: Update MOC (if configured)

If `primary_moc` set and literature notes created:

1. Read MOC file
2. Find appropriate section
3. Add: `- [[Note-Name]] - Brief description`
4. Update timestamp

---

## Step 6: Wiki-Link Related Content

For each new note:
1. Search vault for related content (topic, author, theme)
2. Add `## Related` section with wiki-links
3. Consider backlinks to highly relevant existing notes

---

## Step 7: Git Commit

If `git.enabled` and files changed:

```bash
git add .
git commit -m "{message_prefix}

- Processed {N} items
- Created {N} literature notes

Co-Authored-By: {co_author}"
```

---

## Configuration File

Create `.vault-maintenance.yaml` in your vault root:

```yaml
# .vault-maintenance.yaml

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
  - keywords: ["startup", "founder", "VC"]
    tags: ["topic/startups"]
  - keywords: ["Python", "JavaScript", "code"]
    tags: ["topic/programming"]

# Git settings
git:
  enabled: true
  message_prefix: "vault: auto-organize"
  co_author: "Claude <noreply@anthropic.com>"

# Safety limit
max_files_per_run: 15
```

---

## Output Format

```markdown
## Vault Maintenance Complete

### Configuration
- **Landing Pad**: {path}
- **Config**: {.vault-maintenance.yaml or defaults}

### Processing Summary
Processed **{N} items**:

| Source | Destination | Action |
|--------|-------------|--------|
| article.md | Sources/ | Created literature note |
| paper.pdf | Sources/ | Moved + created note |

**Literature Notes Created:**
- `Author-Topic-Literature-Note.md` - Description

**Consolidated:**
- {Author} ({N} articles) → single note

### MOC Updated
- `Sources-MOC.md` - Added {N} links

### Remaining
- {items and why, or "Empty"}

### Git
{commit hash or "disabled"}
```

---

## Constraints

- Never delete files
- Never modify outside vault
- If uncertain → leave in landing pad with note
- Max `{max_files_per_run}` files per run
- Consolidate related content
- Prefer editing existing MOCs

---

## Headless/Automated Mode

For daily automation via launchd/cron, use the companion script:

```bash
# Setup (one-time)
~/.claude/scripts/daily-vault-maintenance.sh

# Manual trigger
~/.claude/scripts/daily-vault-maintenance.sh --oauth
```

See `~/.claude/prompts/daily-vault-maintenance.md` for the headless prompt.
