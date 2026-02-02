You are maintaining an Obsidian vault. Execute the daily maintenance routine below.

## Step 0: Load Configuration

Check for `.vault-maintenance.yaml` in vault root. If not found, use defaults:
- Landing pad: `Inbox/` or `📥 Landing Pad/`
- Literature notes: `Sources/`
- Blog ideas: `Content/Ideas/`

## Step 1: Scan Landing Pad

List all items (excluding `.DS_Store`, `.gitkeep`).

Group by:
- Same author (3+ items → consolidate)
- File type (PDF, markdown, image)
- Content type (article, blog idea, meeting note)

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

### Blog Ideas
- Move to `{destinations.blog_ideas}`
- Ensure frontmatter has `status: idea`

### Images/Screenshots
- If filename suggests project → move there
- Otherwise → leave in landing pad, note uncertainty

## Step 3: Create Literature Notes

Use this structure:

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
{3-5 main ideas}

## Frameworks/Models
{Any methodologies mentioned}

## Quotable Insights
> {Direct quotes}

## Application Notes
{How to apply this}

## Related
- [[related-note]]
```

## Step 4: Topic Detection

Apply tags based on `topic_rules` config or defaults:
- AI, Claude, prompt, LLM → `topic/ai`
- product, roadmap, PM → `topic/product`
- data, analytics → `topic/data`

## Step 5: Update MOC (if configured)

If `primary_moc` set:
1. Read MOC file
2. Add: `- [[Note-Name]] - Brief description`
3. Update timestamp

## Step 6: Wiki-Link Related Content

For each new note:
1. Search vault for related content
2. Add `## Related` section with wiki-links

## Step 7: Git Commit

If `git.enabled` and files changed:

```bash
git add .
git commit -m "{message_prefix}

- Processed {N} items
- Created {N} literature notes

Co-Authored-By: {co_author}"
```

## Constraints

- Never delete files
- Never modify outside vault
- If uncertain → leave in landing pad with note
- Max `{max_files_per_run}` files per run
- Consolidate related content
- Prefer editing existing MOCs

## Output Format

```markdown
## Vault Maintenance Complete

### Configuration
- **Landing Pad**: {path}
- **Config**: {file or defaults}

### Processing Summary
Processed **{N} items**:

| Source | Destination | Action |
|--------|-------------|--------|
| file.md | Sources/ | Created note |

**Literature Notes Created:**
- `Note-Name.md` - Description

### MOC Updated
- `MOC.md` - Added {N} links

### Remaining
- {items and why, or "Empty"}

### Git
{commit hash or "disabled"}
```
