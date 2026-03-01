# ai-dev-exp-template

Vite-based single-page template for `ai-dev-day-XXX` repositories.

## Required meta.json fields

- `day` (e.g. `Day001`)
- `title`
- `description`
- `genre`
- `theme`
- `story_summary`

## Theme behavior

- `src/themes.js` defines 8 visual themes.
- Runtime applies `meta.json.theme` using CSS variables.
- Day repos should set `theme` with a day-seeded deterministic selector.
