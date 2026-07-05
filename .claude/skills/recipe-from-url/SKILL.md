---
name: recipe-from-url
description: Transcribes a recipe from a webpage URL into this repo's recipes/*.yaml format and regenerates the index. Use whenever the user pastes a recipe URL and asks to add, import, transcribe, or convert it — even if they just say "add this" with a link.
---

# Recipe from URL

Turns a recipe webpage into a correctly formatted YAML file in `recipes/`, following the conventions documented in `README.md`. This exists because manually retyping recipes into YAML is the most tedious part of maintaining this collection.

## Workflow

1. **Fetch the page** with WebFetch. Write a detailed prompt, not a generic one — ask explicitly for:
   - Title, stated category, prep time, cook time, and servings (leave out any that aren't stated rather than guessing).
   - The **complete** ingredient list, verbatim, with quantities and units exactly as written — instruct the fetch not to summarize or drop any ingredients.
   - The **complete** instructions, preserving every technique and timing detail — instruct the fetch not to condense steps into vague summaries.
   - Whether the page has grouped ingredients/sub-recipes (e.g. "For the crust" / "For the filling") — if so, preserve the groupings.
   - Whether the page embeds a `schema.org/Recipe` JSON-LD block. If so, treat that as the authoritative source over the visible page text (it's structured and far less noisy than SEO blog prose).

   Recipe blog posts are often padded with life-story preamble — the fetch prompt should tell the model to ignore that and focus only on recipe data.

2. **Normalize into this repo's format** (see README.md for the full spec):
   - `title` — title case.
   - `category` — short freeform label (`Dessert`, `Main`, `Breakfast`, etc.); infer one if the site doesn't state it.
   - `prep time` / `cook time` — copy as given (e.g. `20 mins`); omit if not stated.
   - `servings` — plain number if stated.
   - `source` — the URL that was fetched, so the recipe can always be traced back to its origin.
   - `ingredients` — a flat list of strings shaped `<Ingredient> <quantity> <unit>[, prep note]`, e.g. `Apples 3 lb, peeled, cored and sliced`. **The ingredient name always comes first** — never lead with the quantity (not `3 lb Apples`). This is a deliberate, non-negotiable ordering: when scanning down a list of a dozen ingredients, the name is what you're looking for, and it must be the first word on the line, not buried after a number and unit. Source pages almost always write quantity-first ("2 cups flour", "1 tsp salt") — you must invert that order for every ingredient, not just copy the source's phrasing. Convert fractions to decimals (`0.5 cup`, not `1/2 cup`) to match the rest of the collection. For recipes with distinct components, use a mapping of group name to ingredient list instead of a flat list — see `chicken_pot_pie_with_biscuits.yaml` or `giant_banana_cinnamon_roll__dough.yaml` for the shape.
   - `instructions` — an ordered list of full imperative-sentence steps. Condense marketing filler, but never drop actual technique, timing, or temperature details.

3. **Pick a filename**: lowercase the title, replace spaces/punctuation with underscores, strip stray characters (apostrophes, etc.) — e.g. "Chicken Pot Pie With Biscuits" → `chicken_pot_pie_with_biscuits.yaml`. Check `recipes/` first; if a file with that name already exists, ask the user whether to overwrite it or pick a different name rather than clobbering it silently.

4. **Write the file** to `recipes/<slug>.yaml`, matching the key order and style of existing recipes.

5. **Regenerate the index** by running `./generate_index.sh` from the repo root, so `recipes/index.json` picks up the new entry.

6. **Show the user the final YAML** and flag anything you weren't fully confident about (an ambiguous quantity, a step you had to condense, a category you had to guess). Transcription from an arbitrary web page isn't perfectly reliable — a quick sanity check against the original is worth the ask.

## Edge cases

- If the URL doesn't resolve or clearly isn't a recipe page, say so — don't invent ingredients or steps to fill the format.
- If the source uses vague quantities ("a splash", "to taste"), keep that wording rather than forcing a fake number.
- The double-underscore filename convention (`nachos__beans.yaml`, `nachos__cheese.yaml`) is for genuinely separate recipes that form one meal, added across multiple invocations — not for a single recipe's internal sub-sections, which belong in the grouped `ingredients` mapping instead.
