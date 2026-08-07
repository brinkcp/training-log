# Training log

A single-page training log. Open it on a phone, follow the session, log the working
sets, and save the whole thing to a private repo.

- `index.html` — the whole app. No build step, no dependencies.
- `program.json` — the current week's program. **This is the file that changes weekly.**
- `sw.js` — offline support, so the page opens at the gym without signal.
- `serve.ps1` — local preview only. Run it and open `http://localhost:8123`. Safe to delete.

The page reads `program.json` on load and renders whatever is in it. Publishing a new
week means replacing that one file — nothing else changes.

The page must be served over HTTP. Opening `index.html` from disk breaks the program
fetch and the offline cache.

---

## Writing `program.json`

**This section is the contract. If you're an AI writing this file, follow it exactly.**

A session is a list of **blocks**. Each block is one of two types:

- **`reference`** — displayed as instructions. Warm-ups, skill work, mobility, core,
  conditioning, cool-downs. Nothing to fill in.
- **`log`** — renders a table with a row per set, capturing **weight, reps and RPE**,
  plus a confidence score for the exercise. Use this only for the lifts you want
  reported back.

Getting this split right is the main thing. A warm-up bike ride in a `log` block
produces a pointless weight/reps table; a working set in a `reference` block can't be
recorded at all.

### Shape

```json
{
  "schema": 2,
  "block": "Foundation Season",
  "week": 1,
  "sessions": [
    {
      "day": "Thursday",
      "dayLabel": "Day 2",
      "title": "Upper Strength + Athletic Control",
      "duration": "~60 minutes",
      "intensity": "RPE 6–8",
      "goal": "Build strength, improve shoulder control, train single-leg stability.",
      "success": "Leave feeling better than when you arrived.",
      "blocks": [
        {
          "type": "reference",
          "title": "Warm-up",
          "duration": "10 minutes",
          "note": "Optional line shown under the block title.",
          "items": [
            { "name": "Bike", "detail": "5 minutes easy" },
            { "name": "World's Greatest Stretch", "detail": "5 each side",
              "focus": "Long spine. Rotate through upper back." }
          ]
        },
        {
          "type": "log",
          "title": "Strength Block A",
          "exercises": [
            {
              "pair": "A1",
              "name": "Incline Dumbbell Bench Press",
              "target": "4 × 8",
              "sets": 4,
              "prescription": "20 kg each hand",
              "rpe": "RPE 7",
              "rest": "90 sec",
              "focus": "Shoulder blades stable. Controlled lowering.",
              "note": "Yesterday's 17.5 kg was RPE 9. Today we build quality."
            }
          ]
        }
      ],
      "questions": [
        "Did the left shoulder still feel restricted?"
      ]
    }
  ]
}
```

### Fields

**Top level**

| Field | Required | Notes |
|---|---|---|
| `schema` | no | `2` |
| `block` | no | Training block name, e.g. "Foundation Season" |
| `week` | no | Week number. Used in the saved filename |
| `sessions` | **yes** | One entry per training day of the week |

**Session**

| Field | Required | Notes |
|---|---|---|
| `day` | yes\* | Weekday name. If it matches today, the page opens on it |
| `dayLabel` | no | e.g. "Day 2" — shown in the header and the day picker |
| `title` | yes\* | Session name |
| `duration`, `intensity` | no | Shown as metadata under the title |
| `goal`, `success` | no | Shown as a short brief |
| `blocks` | **yes** | At least one |
| `questions` | no | Session-specific follow-ups. Each becomes a text box |

\* At least one of `day` or `title`.

**Block**

| Field | Required | Notes |
|---|---|---|
| `type` | **yes** | `"reference"` or `"log"` — exactly these |
| `title` | **yes** | e.g. "Warm-up", "Strength Block A" |
| `duration` | no | Shown right-aligned next to the title |
| `note` | no | One line under the title |
| `items` | **reference only** | See below |
| `exercises` | **log only** | See below |

**`items`** (reference blocks): `name` **required**; `detail` (e.g. "3 × 8 each side",
"2 × 20–30 sec"); `focus` (coaching cue).

**`exercises`** (log blocks): `name` **required**; `sets` **required**, whole number
1–20; `pair` ("A1"); `target` ("4 × 8 each leg"); `prescription` ("20 kg each hand");
`rpe` ("RPE 7"); `rest` ("90 sec"); `focus`; `note`.

### Rules

1. **`sets` is a whole number, not a string.** `4`, never `"4"`. It's the row count.
2. **Exercise names must be unique across all log blocks in a session.**
3. **Keep exercise names spelled identically week to week.** The page matches this
   week's sets to last week's by name. A renamed exercise silently loses its history.
   Rename deliberately, never incidentally.
4. **`target`, `prescription`, `rpe` and `rest` are free text and are never parsed.**
   Put "3 × 8 each leg", "4 × 30 m", "BW / assisted", whatever suits. Displayed as
   written.
5. **Per-side and time-based work belongs in `target`**, not in `sets`. `sets` is only
   how many rows you get.
6. **Don't put warm-ups, mobility or conditioning in `log` blocks.**
7. Fields not listed above are ignored.

### Already built in — don't restate these

The page always includes them, so leave them out of `program.json`:

- **Readiness**: sleep, energy, back confidence, each **out of 10**
- **Back check**: before training, after warm-up, during lifting, immediately after,
  and **2–3 hours later**, each out of 10, plus a notes field
- **Session report**: strongest exercise, weakest exercise, anything awkward
- **Confidence (1–5)** per logged exercise

Use `questions` only for what's *specific to that session* — "did the left shoulder
still feel restricted", "did hamstring cramping appear".

### If the file is wrong

The page validates before rendering and refuses to guess. A malformed file lists
specific problems — which session, which block, which exercise — instead of rendering
something broken. Fix and reload.

---

## Logging and saving

Everything is saved to the browser's local storage as you go, continuously, with no
connection required.

**Save session** writes the session to `sessions/YYYY-MM-DD-w<week>-<day>.json` in your
private repo. **The form is not cleared.** Saving again overwrites the same file, which
is what makes the "2–3 hours later" back check possible — log it, train, save, then add
the delayed reading from the couch and save again.

Next week is a separate file automatically, because saved state is keyed by block,
week and day.

### Session file shape

```json
{
  "block": "Foundation Season",
  "week": 1,
  "day": "Thursday",
  "title": "Upper Strength + Athletic Control",
  "completedAt": "2026-08-07T06:41:00.000Z",
  "readiness": { "sleep": 7, "energy": 6, "back": 7 },
  "exercises": {
    "Incline Dumbbell Bench Press": {
      "block": "Strength Block A",
      "pair": "A1",
      "target": "4 × 8",
      "prescribed": "20 kg each hand",
      "sets": {
        "1": { "weight": "20", "reps": "8", "rpe": "7" },
        "2": { "weight": "20", "reps": "8", "rpe": "7.5" }
      },
      "confidence": 4,
      "notes": ""
    }
  },
  "backCheck": { "before": 6, "warmup": 7, "lifting": 7, "after": 6, "laterHours": 8, "note": "" },
  "reflection": { "strongest": "", "weakest": "", "awkward": "" },
  "answers": { "Did the left shoulder still feel restricted?": "" }
}
```

Weights, reps and RPE are stored as strings exactly as typed — `"82.5"`, `"7.5"` — so
half kilos and half-point RPE survive. Anything reading these should parse them itself.

---

## Saving straight to GitHub

**Do these in order — it matters.**

1. **Create the private repo first**, e.g. `training-data`. Not this repo; this one is
   public. **Tick "Add a README"** so it has a default branch to commit against.

2. **Then create a fine-grained token**
   ([github.com/settings/personal-access-tokens](https://github.com/settings/personal-access-tokens)):
   - *Repository access* → **Only select repositories** → your sessions repo
   - *Permissions* → *Repository permissions* → **Contents: Read and write**
     (separate from repository access — granting one doesn't grant the other)
   - Set an expiry you're happy to renew

**Why the order matters:** a fine-grained token only reaches repositories chosen when
it was created. Make the token first and the repo won't be in its list, and GitHub
answers with a **404, not a permission error** — it won't confirm a repo exists to a
token that can't see it. It looks exactly like a typo in the repo name.

If you hit that, you don't need a new token: edit the existing one's *Repository
access* to add the repo. The token value doesn't change, so nothing needs re-pasting.

Then open **Set up saving to GitHub** at the bottom of the page and fill in the three
fields. **Save and test** writes a real file to prove write access, and only stores the
token if that succeeds.

### About the token

It lives in this browser's local storage on that device only. It's never written into
this repo and never sent anywhere but GitHub. It reaches the one repo you scope it to
and nothing else — revoke it from GitHub settings any time. Anyone with your unlocked
phone could extract it, which is why it's scoped narrowly.

`brinkcp.github.io` is a single origin for the whole account, and browser storage is
per-origin rather than per-path. Any other page published under that account could read
this token, so don't host third-party code there.

**Forget token** removes it from the device; saving then downloads a file instead.

### When an upload fails

The session is recorded locally *first*, then uploaded. A failed upload queues it
rather than losing it, and your "last time" reference updates either way. Queued
sessions upload **automatically** next time you open the page with a connection.

The message distinguishes the two cases, because the fix differs:

- **No connection** — nothing to do.
- **Token expired or wrong** — retrying won't help. Fix the token in the settings and
  the backlog uploads the moment it works.

---

## Not built yet

- **Trends.** Sessions archive with enough structure to chart later, but there's no
  history view.
- **Reading history back from the repo.** "Last time" comes from this device's local
  storage, so it only carries over if you log on the same device each week.
