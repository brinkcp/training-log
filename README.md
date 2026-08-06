# Training log

A single-page training log. Open it on a phone, log sets as you train, download the
session as a file when you finish.

- `index.html` — the whole app. No build step, no dependencies.
- `program.json` — the current week's program. **This is the file that changes weekly.**
- `sw.js` — offline support, so the page opens at the gym without signal.
- `serve.ps1` — local preview only. Run it and open `http://localhost:8123` to test
  changes before publishing. Not used by the live page; safe to delete.

The page must be served over HTTP, not opened as a file. Opening `index.html`
directly from disk breaks the program fetch and the offline cache.

The page reads `program.json` on load and renders whatever is in it. Publishing a new
week means replacing that one file — nothing else changes.

---

## Writing `program.json`

This section is the contract. If you're an AI writing this file, follow it exactly.

### Shape

```json
{
  "schema": 1,
  "block": "Foundation Season",
  "week": 1,
  "sessions": [
    {
      "day": "Saturday",
      "title": "Calibration",
      "notes": "Optional brief shown at the top of the session.",
      "exercises": [
        {
          "name": "Trap Bar Deadlift",
          "target": "4 × 5 @ RPE 7",
          "sets": 4,
          "notes": "Optional cue shown under the exercise name."
        }
      ]
    }
  ]
}
```

### Fields

| Field | Required | Type | Notes |
|---|---|---|---|
| `schema` | no | number | Currently `1`. Reserved for future format changes. |
| `block` | no | string | Training block name. Shown as the eyebrow above the title. |
| `week` | no | number | Week within the block. Shown next to the block, and used in the exported filename. |
| `sessions` | **yes** | array | At least one session. One entry per training day in the week. |
| `sessions[].day` | yes\* | string | A weekday name — `"Monday"`, `"Saturday"`. See *Day matching* below. |
| `sessions[].title` | yes\* | string | Session name, e.g. `"Calibration"`, `"Lower Power"`. |
| `sessions[].notes` | no | string | Session brief. Shown in its own card above the exercises. |
| `sessions[].exercises` | **yes** | array | At least one exercise. |
| `exercises[].name` | **yes** | string | Non-empty. **Must be unique within the session** — see *Why names matter*. |
| `exercises[].sets` | **yes** | integer | Whole number, 1–20. Controls how many rows to log. |
| `exercises[].target` | no | string | Free text, e.g. `"4 × 5 @ RPE 7"`, `"3 × 8"`, `"4 × 30 m"`. Displayed, never parsed. |
| `exercises[].notes` | no | string | A coaching cue for that exercise. |

\* Each session needs at least one of `day` or `title`.

### Rules

1. **`sets` is a whole number, not a string.** `4`, not `"4"`. It's the row count.
2. **`target` is free text and is never parsed.** Put whatever notation you like in
   it — reps, RPE, distance, tempo, time. It's displayed as written.
3. **Exercise names must be unique within a session.** If a session genuinely repeats
   a movement, distinguish them: `"Back Squat (heavy)"` and `"Back Squat (backoff)"`.
4. **Keep exercise names stable week to week.** `"Trap Bar Deadlift"` should stay
   spelled that way. Names are how the page matches this week's sets to last week's.
5. **Don't add fields hoping they'll render.** Anything not in the table above is
   ignored. Extra fields are harmless but do nothing.

### Why names matter

The page matches sets by **exercise name and set number**, not by position. That means
you can reorder exercises, add one, or drop one, and the sets you've already logged
stay attached to the right movement.

The cost is that a renamed exercise is treated as a new one — its "last time" numbers
won't carry over. Rename deliberately, not incidentally.

### Day matching

On load the page looks for a session whose `day` matches today's weekday name. If one
matches, it opens on that session. If none does, it opens the first session in the
array. When there's more than one session, a row of buttons at the top switches
between them.

### If the file is wrong

The page validates `program.json` before rendering and refuses to guess. A malformed
file produces a list of specific problems — which session, which exercise, what was
expected — instead of a broken or half-rendered page. Fix the file and reload.

---

## How data comes back out

While you train, everything is saved to the browser's local storage on that device,
continuously and with no connection required.

**Finish session** downloads the session as a JSON file named
`YYYY-MM-DD-w<week>-<day>.json`, records it as the "last time" reference you'll see
next week, and clears the form.

**Download a copy** saves the same file without clearing anything.

Sessions are per-device, because local storage is. Log on the phone and the numbers
live on the phone until you move the file somewhere shared.

### Session file shape

```json
{
  "block": "Foundation Season",
  "week": 1,
  "day": "Saturday",
  "title": "Calibration",
  "completedAt": "2026-08-08T06:41:00.000Z",
  "readiness": { "sleep": 4, "energy": 3, "back": 4 },
  "exercises": {
    "Trap Bar Deadlift": {
      "target": "4 × 5 @ RPE 7",
      "sets": {
        "1": { "weight": "80", "reps": "5" },
        "2": { "weight": "90", "reps": "5" }
      },
      "notes": ""
    }
  },
  "session": { "strongest": "", "weakest": "", "notes": "" }
}
```

Weights and reps are stored as strings exactly as typed — `"82.5"`, `"5"` — so half
kilos and odd notation survive. Anything reading these files should parse them as
numbers itself.

---

## Not built yet

- **Pushing sessions to a repo automatically.** Right now finishing a session
  downloads a file and you file it yourself. A one-tap push to a private repo is a
  contained change to one function when you want it.
- **Trends.** Sessions are archived with enough structure to chart later, but there's
  no history view yet.
