---
name: move-pasted-post-images
description: 'Move pasted images from _posts into dated images folders and rewrite markdown image URLs. Use for Jekyll post cleanup, image path normalization, and blog asset organization after pasting screenshots.'
argument-hint: 'Path to one post file or "all" to process all posts'
---

# Move Pasted Post Images

## What This Skill Produces

This skill standardizes post images by:

1. Finding locally pasted image files referenced by a post in _posts.
2. Moving those files into images/year/month/day/.
3. Renaming each image to post-slug-imgN.ext.
4. Updating image links inside the post markdown.

Target layout:

- images/{year}/{month}/{day}/{post-slug}-img{number}.{ext}

Example:

- Source post: _posts/2026-05-27-azure-monitor-suivez-la-capacite-globale-utilise-par-vos-azure-storage.md
- Source image link: ![alt](image.png)
- Destination file: images/2026/05/27/azure-monitor-suivez-la-capacite-globale-utilise-par-vos-azure-storage-img1.png
- Updated link: ![alt]({{ site.url }}/images/2026/05/27/azure-monitor-suivez-la-capacite-globale-utilise-par-vos-azure-storage-img1.png)

## When To Use

Use this skill when:

- You pasted screenshots while editing a post and files ended up in _posts.
- A post references local files like image.png, image-1.png, Screenshot 2026-05-27.png, or ./image.png.
- You want consistent image naming and URL structure for all posts.

Do not use this skill for:

- External image URLs (https://...).
- Images already stored under /images/... with a valid path.

## Inputs

- A single post path under _posts, or all posts.
- Optional dry-run mode.

## Procedure

1. Select scope.
- Single post: process one markdown file.
- Batch mode: process all markdown files in _posts.

2. Parse post metadata from filename.
- Expected filename pattern: YYYY-MM-DD-post-slug.md.
- Extract year, month, day, post-slug.
- If filename does not match, stop and report the file.

3. Detect candidate local image links in markdown.
- Markdown links: ![...](...)
- HTML links: <img src="...">
- Keep only local paths that are not absolute URLs and not already under /images/.

4. Resolve each source image file path.
- Try path relative to the post file location.
- Also support ./ prefix forms.
- If file does not exist, skip and report.

5. Build destination paths.
- Destination folder: images/year/month/day.
- Destination filename: post-slug-imgN.ext.
- Preserve original extension.
- Numbering is per post and stable by first appearance order in the markdown.

6. Move files safely.
- Create destination folder if missing.
- If destination exists and content appears identical, reuse existing file.
- If destination exists with different content, pick next available imgN.

7. Rewrite links in the post.
- Replace each migrated local link with /images/year/month/day/post-slug-imgN.ext.
- Keep original alt text and surrounding markdown unchanged.

8. Validate result.
- Every rewritten link points to an existing file.
- No remaining local image links for migrated files.
- Post markdown still parses correctly.

## Decision Rules

- If a link is external (http:// or https://): leave unchanged.
- If a link already starts with /images/: leave unchanged.
- If the source image is missing: do not rewrite the link; add to report.
- If the same source file is referenced multiple times in one post: reuse one destination file and one URL.
- If one source filename appears in multiple posts: process independently per post scope.

## Completion Checklist

- Destination folder exists for each processed post date.
- Migrated files are present under images/year/month/day/.
- Updated post file contains only normalized image paths for migrated files.
- A summary report lists: moved, skipped, missing, and rewritten counts.

## Suggested Commands

Single post workflow:

1. Open one _posts file.
2. Run the migration process in dry-run mode.
3. Apply migration.
4. Build blog and verify rendering.

Batch workflow:

1. Run dry-run across _posts.
2. Review report for ambiguous or missing files.
3. Apply migration.
4. Build blog and check changed pages.

## Verification

- Run the build task to ensure links are valid in generated site output.
- Spot-check at least one processed post page and one image URL in local serve mode.
