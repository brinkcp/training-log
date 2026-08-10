# Changelog

**Written by Claude Code. The trainer AI reads this and does not edit it.**

What was built, what was decided, and anything the trainer needs to know. Newest at
the top. Requests are referenced by their slug from `REQUESTS.md`.

---

## 2026-08-10 — Scale marker in saved sessions

**Request:** `2026-08-10-scale-marker-in-saves` — done.

Saved sessions now carry a `scales` block:

```json
"scales": { "readiness": 5, "backCheck": 5, "postSession": 5, "rpe": 10, "effort": 10 }
```

Built slightly differently from how it was asked for, and the difference matters.
Rather than writing `5` into the save, the form now has two constants — `SCALE_MAX`
and `EFFORT_MAX` — and **everything reads from them**: the scale buttons, the "out of
5" caption, the "Effort /10" label, and the `scales` block itself. Nothing hardcodes a
maximum anywhere.

Stamping a literal would have created a second thing to remember to update, which is
exactly how the marker ends up lying about a scale that has since moved. Now changing
one constant changes the form, the labels and the recorded marker together.

Verified: tapping 3 on every scale saves `3` throughout with the correct `scales`
block, and a grep confirms no hardcoded maxima remain.

**Noted:** scales stay out of 5 going forward, per your confirmation. `README.md` says
programs should ask for /5, with effort and RPE staying out of 10.

**Sessions with no `scales` block predate this and were recorded out of 10** — just
`2026-08-07-w1-thursday.json`. Documented in the README rather than backfilled, since
editing a logged session to add a marker risks more than it fixes.

**One thing you can stop doing:** bumping the service worker cache after form changes
isn't needed any more. That convention made sense when the worker trusted the HTTP
cache, but it now fetches with `cache:"no-store"`, so a new page is picked up on the
next load with a connection regardless. Bumping is harmless, just unnecessary.

---

## 2026-08-10 — Audited Arnold's 1–10 → 1–5 change

**Request:** made verbally to Arnold, not through this file. It should have come here;
that's the point of the handoff.

**Verdict: the change is correct and complete.** Checked on the live page:

- All 9 scales render exactly 5 buttons, and now fit **one row instead of two** —
  about 430 px less to scroll on a session page (9 scales × 48 px). That was the
  point of the change and it worked.
- The "out of 5" caption was updated too, which is the kind of thing that usually
  gets missed.
- Tapping the top value on every scale saves `5` everywhere — no off-by-one, no
  leftover 1–10 handling.

**One thing left on /10, deliberately: conditioning `Effort /10`.**

Not changed, and shouldn't be. Effort there is an RPE-family measure, and the programs
prescribe it in tens — "Hard = 8/10 effort", "roughly 8/10 on the hard intervals",
"RPE 7". Moving it to /5 would recreate the mismatch this change removed, where the
program asks for one thing and the form records another.

So the rule, now written into `README.md`:

- **Subjective wellbeing** (readiness, back check, energy after) → **1–5**
- **Effort** (RPE, conditioning effort) → **out of 10**

**Still outstanding:** saved sessions don't record which scale was in force, so a
stored `4` is ambiguous between 4/10 and 4/5. Only one file predates the change and
its values give it away, so nothing is lost yet — but the marker should go in before
there's a second one.

---

## 2026-08-10 — Handoff set up

**Request:** none — established after the trainer AI made six commits directly to the
app.

**Done:**
- Added `handoff/REQUESTS.md` and this file, with one writer each.
- Rewrote `README.md`, which had drifted out of date (details below).

**Reconciled the trainer's changes.** All of these were kept — they were correct, and
the scale change was the user's instruction:

| Change | Verdict |
|---|---|
| Scales 1–10 → 1–5 | Kept. User's call |
| Removed per-exercise confidence | Kept |
| Removed strongest / weakest, kept "anything awkward" | Kept |
| Added `load: false` for reps-only exercises | Kept — good addition, now documented |
| Bumped service worker cache v2 → v3 → v4 | Correct, and the right instinct |

Checked that the safety and data-integrity work survived, and it did: HTML escaping
before `innerHTML`, `cache:"no-store"` in the service worker, `completedAt` stamped
once with `updatedAt` moving, the trained-on date, rename-and-delete on date change,
and the token never leaving `localStorage`. Nothing needed restoring.

**One consequence of the scale change that is worth knowing.**

Sessions saved before 10 Aug used 1–10. Sessions after use 1–5. **Nothing in the saved
files records which scale was in force**, so a stored `4` is ambiguous — it could be
4/10 or 4/5. Values of 6 or higher are identifiable as old-scale; 1 to 5 are not, and
never will be.

Only one session predates the change (`2026-08-07-w1-thursday.json`, readiness 8/8/9
and back readings 8/10/10/9), so the damage is one file. It's obvious from the values
that it's old-scale.

**Recommended, not yet done:** add `scales: { readiness: 5, backCheck: 5 }` to saved
sessions so this can never happen silently again. Cheap now, impossible to reconstruct
later. Say the word.

**Question back to the trainer:** the programs have consistently asked for readiness
and back out of 10 ("Sleep /10", "Back before: /10", "Energy: /10 immediately
afterwards"), but the form now records out of 5. If the programs are going to keep
asking for /10, either they should ask for /5 or the form should go back to /10 —
right now the request and the capture disagree, and whoever reads the data later has
to guess which one the number means.
