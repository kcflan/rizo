---
title: Site Migration Plan
subtitle: Prepared for the web team
slug: astro-migration
---

# Site Migration Plan: WordPress to Astro

This document outlines the plan to move the marketing site off WordPress and onto a static Astro build, what we found during the audit, and the order we'll ship it in. Estimated effort is **three weeks** with one engineer.

> **TL;DR** — The move cuts page weight by roughly 70%, removes the plugin maintenance burden, and keeps every existing URL working. The main risk is the contact form, which needs a new backend.

## Summary

- **Performance:** Median LCP drops from 3.8s to an estimated 1.1s once images move to the Astro asset pipeline.
- **Cost:** Hosting moves from a $35/mo managed plan to the free tier on Cloudflare Pages.
- **Risk:** Low overall. Two items need attention before launch — see [Findings](#findings).

| Area                | Current       | After migration   | Status         |
| ------------------- | ------------- | ----------------- | -------------- |
| Page weight (home)  | 2.4 MB        | 0.7 MB            | ✅ Verified     |
| Plugins to maintain | 23            | 0                 | ✅ Verified     |
| Contact form        | Gravity Forms | Worker + Resend   | ⚠️ Needs build  |
| Redirects           | Yoast         | `_redirects` file | 🔄 In progress |

## Findings

The audit covered 142 pages, 3 custom post types, and the full plugin list. Most content maps cleanly onto Astro content collections; the exceptions are below.

### Content model

1. Blog posts become a `posts` collection with a typed frontmatter schema.
2. Case studies need a custom field for the client logo, which WordPress stored in ACF.
   - Logos are currently inconsistent sizes — we'll normalize them to SVG where possible.
   - Four clients have no logo on file.
3. Team bios can be flattened into a single ==JSON data file== rather than a collection.

> [!NOTE]
> Shortcodes from the old page builder appear in 18 posts. They'll be converted to MDX components during import rather than cleaned by hand.

### Build configuration

The site builds with a single command. Deploy previews run on every pull request.

```ts
import { defineConfig } from 'astro/config';
import mdx from '@astrojs/mdx';

// Keep trailing slashes so existing URLs resolve unchanged
export default defineConfig({
  site: 'https://example.com',
  trailingSlash: 'always',
  integrations: [mdx()],
  image: { quality: 80 },
});
```

> [!WARNING]
> The contact form is the only dynamic feature. If the new Worker isn't live on launch day, form submissions will fail silently.

#### Commands

```bash
npm create astro@latest -- --template minimal
npm run build # outputs to ./dist
```

Press <kbd>⌘</kbd> <kbd>K</kbd> in the admin to open the new command palette. Old notes are ~~no longer relevant~~ archived.[^1]

---

## Next steps

- [x] Export all posts and media from WordPress
- [x] Set up the Astro repo and content collections
- [ ] Build the contact form Worker and test deliverability
- [ ] Write the redirect map and verify every legacy URL

> [!TIP]
> Run the redirect checker against the production sitemap, not the staging one — staging is missing 12 legacy URLs.

> [!IMPORTANT]
> Freeze WordPress content edits 48 hours before cutover.

> [!CAUTION]
> Do not delete the WordPress database until 30 days after launch.

##### Appendix

###### Revision history

Questions or changes to scope go in the project channel. The next review is scheduled for **Friday, October 2**.

[^1]: Archived in the `legacy/` folder of the content repo.
