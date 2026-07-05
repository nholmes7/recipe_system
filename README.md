# recipe_system

A personal recipe collection stored as YAML files, served as a simple static site via GitHub Pages.

## How it works

- **`recipes/*.yaml`** — one file per recipe, in a consistent format (see below).
- **`recipes/index.json`** — a generated manifest listing every recipe's display name and filename. Regenerate it with `./generate_index.sh` after adding, renaming, or removing a recipe.
- **`index.html`** — fetches `recipes/index.json` and renders a clickable list of recipes.
- **`recipe.html`** — fetches a single recipe YAML (via the `?file=` query param), parses it client-side with [js-yaml](https://github.com/nodeca/js-yaml), and renders the title, metadata, ingredients, and instructions.

Both pages fetch directly from `raw.githubusercontent.com` on the `main` branch, so changes pushed to `main` are reflected immediately without a build step.

## Adding a recipe

1. Add a new `recipes/<name>.yaml` file following the format below.
2. Run `./generate_index.sh` to regenerate `recipes/index.json`.
3. Commit and push to `main`.

If you're using Claude Code, the `recipe-from-url` skill (`.claude/skills/recipe-from-url/`) automates this: give it a recipe URL and it will fetch the page, transcribe it into the format below, write the file, and regenerate the index for you.

## Recipe YAML format

```yaml
---
title: Chicken Pot Pie With Biscuits
category: Main
prep time: 30 mins
cook time: 30 mins
servings: 6
source: https://example.com/original-recipe
ingredients:
  - Flour 2 cups
  - Salt 0.5 tsp
instructions:
  - Preheat the oven to 425 degrees.
  - Mix the dry ingredients together.
```

Fields:

- `title` (required) — recipe name.
- `category` — free-text, e.g. `Main`, `Dessert`, `dinner`.
- `prep time`, `cook time`, `servings`, `source` — optional metadata.
- `ingredients` (required) — each entry is a string formatted `<ingredient name> <quantity> <unit>[, prep note]`, e.g. `Flour 2 cups` or `Apples 3 lb, peeled, cored and sliced`. The ingredient name always comes first, before the quantity — never lead with the number (not `2 cups Flour`). This is deliberate: when scanning down an ingredient list, the ingredient name is the thing you're looking for, and it should be the first word on the line rather than buried after the quantity and unit. Quantities are always decimals, never fractions (`0.5 cup`, not `1/2 cup`), for consistent alignment and easier scanning.

  Ingredients can be either a flat list of strings, or a map of group name to list of strings for recipes with sub-components (e.g. `Biscuits:` / `Filling:`):

  ```yaml
  ingredients:
    Biscuits:
      - Flour 2 cups
    Filling:
      - Shallots 4 units
  ```

- `instructions` (required) — a list of steps, in order.
