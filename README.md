# Training log

A single-page training log. Open it on a phone, follow the session, log the working
sets, save it to a private repo.

**Live page:** https://brinkcp.github.io/training-log/

---

## What this file is for

**This README is the contract between the trainer and the app.** It says exactly how
to write `program.json` so the page renders a session correctly, and what the page
gives back afterwards.

The trainer AI reads this to publish a program. If the app changes and this file
doesn't, the trainer starts writing programs against a format that no longer exists —
and nothing will warn anyone. **Whoever changes the form updates this file in the same
commit.** That is the rule this whole setup depends on.

## Who writes what

| File | Owner | Notes |
|---|---|---|
| `program.json` | **Trainer AI** | The weekly program. Changes constantly |
| `index.html`, `sw.js` | **Claude Code** | The app. Trainer only in an emergency |
| `README.md` | **Claude Code** | This contract |
| `handoff/REQUESTS.md` | **Trainer AI** | Asks for app changes |
| `handoff/CHANGELOG.md` | **Claude Code** | Reports what was built, and asks back |

One writer per file, so two agents never clobber each other. Want the app changed?
Write it in `handoff/REQUESTS.md` rather than editing the code. If you must edit the
code in an emergency, log it there so it isn't silently undone later.

**Always pull before writing.** Both agents push to `main`, and a stale copy will
overwrite work.

---

## Writing `program.json`

A session is a list of **blocks**, each one of three types:

- **`reference`** — instructions to read. Warm-ups, skill work, mobility, core,
  cool-downs. Nothing to fill in.
- **`log`** — a table with a row per set, plus one RPE for the exercise. Use for the
  lifts you want reported back.
- **`conditioning`** — intervals. Shows the prescription and records what was actually
  done: rounds, work seconds, rest seconds, effort, notes.

Getting this split right is the main thing. A warm-up bike ride in a `log` block
produces a pointless table; a working set in a `reference` block can't be recorded at
all; and interval work in a `reference` block loses the gap between prescribed and
actual, which is usually the interesting part.

### Shape

```json
{
  "schema": 2,
  "block": "Foundation Season",
  "week": 1,
  "sessions": [
    {
      "day": "Wednesday",
      "dayLabel": "Wed · Day 1",
      "title": "Build the Foundation",
      "duration": "~60 minutes",
      "intensity": "RPE 6–8",
      "goal": "Hinge strength, upper balance, controlled work.",
      "success": "Leave better than you arrived.",
      "note": "Shown under the title — use for week-to-week adjustments.",
      "blocks": [
        {
          "type": "reference",
          "title": "Warm-up",
          "duration": "10 minutes",
          "note": "Optional line under the block title.",
          "items": [
            { "name": "Bike", "detail": "5 minutes easy" },
            { "name": "Cat-Cows", "detail": "× 10", "focus": "Optional cue." }
          ]
        },
        {
          "type": "log",
          "title": "Strength — A",
          "exercises": [
            {
              "pair": "A1",
              "name": "Trap Bar Deadlift",
              "target": "4 × 5",
              "sets": 4,
              "prescription": "60–65 kg",
              "rpe": "RPE 7",
              "rest": "90 sec",
              "focus": "Every rep identical.",
              "note": "Coach's note, shown in accent colour."
            },
            {
              "pair": "M1",
              "name": "Side Lying Hip Lift Rotations",
              "target": "2 × 8–10 each side",
              "sets": 2,
              "load": false,
              "prescription": "Bodyweight only",
              "focus": "Pelvis stacked."
            }
          ]
        },
        {
          "type": "conditioning",
          "title": "Conditioning",
          "items": [
            { "name": "Bike Intervals", "detail": "10 rounds — 20 sec hard / 40 sec easy",
              "focus": "Roughly 8/10 on the hard intervals." }
          ]
        }
      ],
      "questions": [
        "Any residual knee sensation today, even mild?"
      ]
    }
  ]
}
```

### Fields

**Top level:** `sessions` (**required**, one entry per training day); `schema`,
`block`, `week` optional.

**Session:** at least one of `day` (weekday name — if it matches today, the page opens
on it) or `title`. Optional: `dayLabel` (shown in the day picker, e.g. `"Wed · Day 1"`),
`duration`, `intensity`, `goal`, `success`, `note`, `questions`. **`blocks` required.**

**Block:** `type` (**required** — `reference`, `log` or `conditioning`), `title`
(**required**), `duration`, `note`. Then `items` for reference/conditioning, or
`exercises` for log.

**`items`:** `name` **required**; `detail`; `focus`. For conditioning, `detail` is the
prescription and is saved next to what actually happened — put the full interval spec
there.

**`exercises`:** `name` **required**; `sets` **required** (whole number 1–20);
`load` (set `false` for reps-only — no weight column, for rehab and bodyweight work);
`pair`; `target`; `prescription`; `rpe`; `rest`; `focus`; `note`.

### Rules

1. **`sets` is a whole number, not a string.** `4`, never `"4"`. It's the row count.
2. **Exercise names must be unique** across all log blocks in a session.
3. **Keep exercise names spelled identically week to week.** The page matches this
   week's sets to last week's by name. A renamed exercise silently loses its history.
4. **`target`, `prescription`, `rpe`, `rest` are free text and never parsed.** Put
   "3 × 8 each leg", "4 × 30 m", "BW / assisted" — displayed as written.
5. **Per-side and time-based work goes in `target`**, not `sets`. `sets` is only how
   many rows you get.
6. **`load: false` for anything without a weight** — mobility, rehab, bodyweight holds.
7. Fields not listed above are ignored.

### Already built into the page — don't restate these

- **Readiness:** sleep, energy, back confidence — **each 1–5**
- **Back & recovery check:** before training, after warm-up, during lifting,
  immediately after, **2–3 hours later** — **each 1–5**, plus a notes field
- **Energy immediately after** — **1–5**
- **Anything awkward or technically difficult** — free text
- **Trained on** date, defaulting to today
- One **RPE** and a **notes** box per logged exercise

Use `questions` only for what's specific to that session — "any residual knee
sensation", "left shoulder still restricted during hangs".

### Which scale to ask for

Two scales are in use, deliberately:

| Measure | Scale |
|---|---|
| Readiness (sleep, energy, back), back check, energy after | **1–5** |
| RPE per exercise, conditioning effort | **out of 10** |

Subjective wellbeing is 1–5 — it's a quick tap and ten options is more deliberation
than the answer deserves. Effort stays out of 10 because RPE is conventionally a
ten-point scale and the programs already prescribe it that way ("RPE 7", "8/10
effort").

**Write programs to match.** Asking for "Sleep /10" gets recorded out of 5, and the
number then means something other than what it says. Readiness moved from 1–10 to 1–5
on 10 Aug 2026.

### If the file is wrong

The page validates before rendering and refuses to guess. A malformed file lists
specific problems — which session, which block, which exercise — instead of rendering
something broken. Fix and reload.

---

## What comes back

Everything saves to the browser's local storage as you go, with no connection needed.

**Trained on** drives the filename, so a session logged the next morning is still
filed under the day it happened.

**Save session** writes to `sessions/<trained-on>-w<week>-<day>.json` in the private
repo. **The form is not cleared** — saving again overwrites the same file, which is
what makes the "2–3 hours later" reading possible. Change the date after saving and
the next save renames the file, deleting the old one so a session is never stored
twice.

```json
{
  "block": "Foundation Season", "week": 1,
  "day": "Wednesday", "dayLabel": "Wed · Day 1", "title": "Build the Foundation",
  "date": "2026-08-12",
  "completedAt": "2026-08-12T06:41:00.000Z",
  "updatedAt": "2026-08-12T09:12:44.000Z",
  "scales": { "readiness": 5, "backCheck": 5, "postSession": 5, "rpe": 10, "effort": 10 },
  "readiness": { "sleep": 4, "energy": 4, "back": 5 },
  "exercises": {
    "Trap Bar Deadlift": {
      "block": "Strength — A", "pair": "A1", "target": "4 × 5", "prescribed": "60–65 kg",
      "sets": { "1": { "weight": "60", "reps": "5" }, "2": { "weight": "65", "reps": "5" } },
      "rpe": "7",
      "notes": ""
    }
  },
  "conditioning": {
    "Bike Intervals": {
      "block": "Conditioning", "prescribed": "10 rounds — 20 sec hard / 40 sec easy",
      "rounds": "8", "work": "15", "rest": "45", "effort": "8", "notes": ""
    }
  },
  "backCheck": { "before": 4, "warmup": 4, "lifting": 5, "after": 4, "laterHours": 3, "note": "" },
  "postSession": { "energy": 4 },
  "reflection": { "awkward": "" },
  "answers": { "Any residual knee sensation today, even mild?": "" }
}
```

- **`date`** is the day trained, and the one to sort and chart by. **`day`** is the
  program's label and may not be the real weekday — sessions get trained late.
- **`completedAt`** is stamped once; **`updatedAt`** moves on every save.
- Weights, reps and RPE are strings exactly as typed — `"82.5"`, `"7.5"` — so half
  kilos and half-point RPE survive. Parse them yourself.
- **`scales` records what each number was measured against**, stamped at save time
  from the form itself, so a stored `4` is never ambiguous. **Sessions with no
  `scales` block predate 10 Aug 2026 and were recorded out of 10** — only
  `2026-08-07-w1-thursday.json`.

---

## Saving to GitHub

**Do these in order — it matters.**

1. **Create the private repo first**, e.g. `training-data`. Not this repo; this one is
   public. **Tick "Add a README"** so it has a default branch.
2. **Then create a fine-grained token**
   ([github.com/settings/personal-access-tokens](https://github.com/settings/personal-access-tokens)):
   - *Repository access* → **Only select repositories** → the sessions repo
   - *Permissions* → *Repository permissions* → **Contents: Read and write**
     (separate from repository access — one doesn't grant the other)

**Why the order matters:** a fine-grained token only reaches repositories chosen when
it was created. Make the token first and GitHub answers with a **404, not a permission
error** — it won't confirm a repo exists to a token that can't see it. It looks exactly
like a typo in the repo name. Fix by editing the token's repository access; the token
value doesn't change, so nothing needs re-pasting.

Then open **Set up saving to GitHub** at the bottom of the page. **Save and test**
writes a real file to prove write access, and only stores the token if that succeeds.

### About the token

It lives in that browser's local storage on that device only. Never written into this
repo, never sent anywhere but GitHub, reaches only the repo you scope it to. Revoke it
any time.

`brinkcp.github.io` is one origin for the whole account and storage is per-origin, not
per-path — so any other page published under that account could read this token. Don't
host third-party code there.

### When an upload fails

The session is recorded locally *first*, then uploaded. A failed upload queues it
rather than losing it, and uploads automatically next time the page is opened with a
connection. The message distinguishes **no connection** (nothing to do) from **token
expired or wrong** (fix it in the settings; the backlog goes up as soon as it works).

---

## Not built yet

- **Trends.** Sessions archive with enough structure to chart later; no history view.
- **Reading history back from the repo.** "Last time" comes from the device's local
  storage, so it only carries over when logging on the same device.
- **A scale marker in saved sessions.** See `handoff/CHANGELOG.md`.
