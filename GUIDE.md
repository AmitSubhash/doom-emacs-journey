# Amit's Doom Emacs Setup Guide & Learning Plan

## What You Built (March 8-9, 2026)

In a single evening, you went from zero Emacs knowledge to a fully integrated productivity system. Here's everything that's in your setup and how to use it.
 of file
- `w` = forward one word, `b` = back one word
- `/` = search, `n` = next match
- `u` = undo, `C-r` = redo
- `dd` = delete line, `o` = new line below, `O` = new line above
- `0` = jump to start of line, `$` = jump to end
- `<<` = de-indent line, `>>` = indent line
- `V` = select lines visually, then `<` or `>` to shift

**Insert Mode** (for typing text):
- `i` = enter insert mode
- `ESC` = back to normal mode
- `C-d` = de-indent while typing

**The SPC Menu** (press SPC and wait for the menu):
- `SPC f f` = find/open file
- `SPC f s` = save current file
- `SPC f P` = open your config files
- `SPC b b` = switch between open buffers
- `SPC b d` = close current buffer
- `SPC w v` = split window vertically
- `SPC w s` = split horizontally
- `SPC w w` = jump between splits
- `SPC w q` = close a split
- `SPC q q` = quit Emacs
- `SPC q r` = restart Emacs
- `SPC :` = run any command by name
- `SPC h` = help menu
- `SPC s p` = search text across entire project

**When you're stuck:**
- `ESC ESC ESC` clears most things
- `SPC b b` to find your way to any buffer
- `SPC b d` to kill whatever buffer you're trapped in
- `C-g` to cancel any active prompt or operation

---

## 1. Journal (Daily Brain Dump)

**Open today's journal:** `SPC n j j`

This creates a file in `~/org/journal/` with today's date. Just write freely. Thoughts, reflections, what happened, random ideas.

**Org-mode formatting while writing:**
- `* Heading` with stars for hierarchy (`*`, `**`, `***`)
- `TAB` on a heading to fold/unfold it
- `Shift-TAB` to fold/unfold everything globally
- `*bold*`, `/italic/`, `=code=`, `~verbatim~`
- `M-k` / `M-j` to move headings up/down
- `M-h` / `M-l` to promote/demote headings

**Adding TODOs in your journal:**
```org
* TODO Task description here
DEADLINE: <2026-03-15>
```
- Write `* TODO` at the start of a heading
- `SPC m d d` to add a deadline
- `SPC m d s` to schedule it
- `SPC m t` to cycle TODO states (TODO, IN-PROGRESS, DONE, CANCELLED)
- `SPC m p` to set priority (A = highest, B, C)

**Code blocks in notes:**
Use `SPC :` then `org-insert-structure-template`, type `s`, add `python :results output` after `src`:
```org
#+begin_src python :results output
print("Hello from inside your journal!")
#+end_src
```
Then `C-c C-c` inside the block to execute it.

---

## 2. Roam Notes (Knowledge Brain)

Your personal wiki. One idea per note, link them as connections form.

**Create or find a note:** `SPC n r f`, type a title, enter

**Link to another note:** While writing, `SPC n r i`, search for the target note, select it

**See what links to current note:** `SPC n r b` opens backlinks panel

**Daily roam note:** `SPC n r d d` (fleeting thoughts, separate from journal)

**Tag a note:** Add at the top of any note:
```org
#+filetags: :neuroengineering:dot:mcx:
```

**Recommended note structure:**
```org
Brief 2-3 sentence explanation of the concept.

* Key Ideas
The main points...

* Relation to My Work
How this connects to DOT, piglet models, etc.

* References
- Paper by Author (Year)
- URL or resource

* Questions
- Things I still need to figure out
```

**The workflow for reading articles:**
1. Read the article
2. `SPC n r f`, title it (e.g., "Monte Carlo Photon Transport in Tissue")
3. Summarize in your own words
4. `SPC n r i` to link to related notes
5. `SPC f s` to save

**Renaming a note:** Open it, `SPC :` then `org-roam-rename-file`

---

## 3. Agenda (Command Center)

**Open weekly agenda:** `SPC o a a` then press `a`

**Agenda navigation (emacs state):**
- `f` = forward a week
- `b` = back a week
- `d` = day view
- `w` = week view
- `j`/`k` or arrow keys to move between items
- `.` = jump to today
- `Enter` = open the item in its file
- `t` = toggle TODO state
- `q` = quit agenda

**Agenda dispatcher options** (the menu before the agenda opens):
- `a` = weekly calendar view
- `t` = list of ALL TODOs
- `n` = agenda + all TODOs combined (best daily view)
- `s` = search by keyword
- `m` = search by tags

**Your agenda pulls from two sources:**
1. Your org files in `~/org/` and `~/org/journal/` (your TODOs)
2. `~/org/outlook-cal.org` (your Outlook calendar, auto-synced)

**Calendar sync:** Happens automatically on Emacs startup and every 30 minutes. To manually sync: `SPC :` then `my/sync-outlook-calendar`

---

## 4. VS Code Features (Already in Your Setup)

**File tree:** `SPC o p` opens treemacs sidebar

**Project management:**
- `SPC p p` = open/switch project
- `SPC s p` = search text across project (like Ctrl+Shift+F)

**Code intelligence (LSP):**
- `gd` = go to definition
- `K` = show documentation for symbol under cursor
- `SPC c r` = rename variable across files
- `SPC c a` = code actions
- Autocomplete appears automatically as you type

**Git (Magit):**
- `SPC g g` = open Magit status
- Inside Magit: `s` to stage, `c c` to commit, `P p` to push
- `SPC g b` = git blame

**Terminal:** `SPC o t` toggles vterm

---

## 5. Quick Capture

Press `SPC X` from anywhere. A capture menu appears:
- `j` = new journal entry
- `t` = new TODO (goes to inbox)
- `r` = research idea
- `n` = quick note

Write your thought, `C-c C-c` to save it, you're back where you were. It's like an inbox that catches thoughts without interrupting your flow.

---

## Your File Structure

```
~/org/
  inbox.org          (capture inbox)
  research.org       (research ideas)
  outlook-cal.org    (synced Outlook calendar)
  journal/
    20260308.org     (daily journal files)
    20260309.org
  roam/
    daily/           (daily roam notes)
    (your roam notes appear here)
```

---

## Config Files

Your Doom config lives in `~/.doom.d/`:
- `init.el` = modules (what features are enabled)
- `config.el` = your personal settings
- `packages.el` = extra packages

Open any of them with `SPC f P`.

After changing `init.el` or `packages.el`: run `doom sync` in terminal, restart Emacs.
After changing `config.el`: `SPC :` then `eval-buffer`, or restart Emacs.

---

## Learning Plan: Days 1-7

### Day 1 (Today - Done!)
- [x] Set up journal, agenda, roam, calendar sync, Claude Code, vterm
- [x] Learned basic navigation, modes, SPC menu
- [x] First journal entry with formatting experiments
- [x] First roam note

### Day 2: Journal + Agenda Comfort
- Morning: `SPC o a a` to check your week. Review meetings and TODOs.
- Write morning journal entry with `SPC n j j`. Plan your day with TODOs.
- Throughout the day: add TODOs with deadlines as things come up.
- End of day: journal reflection. Mark completed TODOs with `SPC m t`.
- Practice: `f`, `b`, `d`, `w` in agenda. Fold/unfold with TAB in journal.

### Day 3: Roam Notes Begin
- Read one article or paper related to your research.
- Create 2-3 roam notes on key concepts from the reading.
- Practice linking notes with `SPC n r i`.
- Check backlinks with `SPC n r b`.
- Add `#+filetags:` to categorize your notes.

### Day 4: Roam Notes + Capture Flow
- Use `SPC X` (quick capture) throughout the day for fleeting thoughts.
- Create 3-5 more roam notes.
- Start building connections: when you create a new note, link it to at least one existing note.
- Try daily roam note: `SPC n r d d`.

### Day 5: VS Code Mode
- Open a coding project with `SPC p p`.
- Use treemacs (`SPC o p`) for file navigation.
- Try LSP features: `gd` for go-to-definition, `K` for docs.
- Use `SPC s p` to search across files.
- Try Magit: `SPC g g`, stage and commit something.

### Day 6: Advanced Org
- Experiment with code blocks in notes (Python, shell).
- Try the pomodoro timer: `SPC m P` on a TODO heading.
- Explore org-noter: open a PDF and annotate it with linked notes.
- Try different agenda views: `SPC o a a` then `n` for combined view.

### Day 7: Review + Customize
- Review your roam graph: how are your notes connected?
- Customize anything that bugs you (fonts, themes, keybindings).
- Ask Claude Code to audit your config for improvements.
- Consider setting up org-roam-ui for visual graph (browser-based, like Obsidian's graph view).

---

## Things to Set Up Later

1. **org-roam-ui** (visual graph in browser, like Obsidian's graph view)
2. **org-gcal or caldav** (two-way calendar sync, not just read-only)
3. **mu4e** (email inside Emacs, your init.el has it commented out)
4. **gptel** (talk to Claude directly in any buffer, needs API key)
5. **org-present** (give presentations from org files, already enabled in init.el)
6. **Publishing** (ox-hugo to publish notes as a website/digital garden)

---

## Troubleshooting Quick Reference

| Problem | Solution |
|---|---|
| Stuck in a weird state | `ESC ESC ESC` then `SPC b b` |
| Can't exit a buffer | `SPC b d` or `q` |
| Autocomplete error (Corfu) | `C-g` to dismiss |
| Need to restart | `SPC q r` or quit and reopen |
| Config change not working | `SPC :` then `eval-buffer`, or restart |
| Package issue | `doom sync` in terminal, restart |
| Lost in agenda | `q` to quit, `.` to jump to today |
| Claude Code won't start | `unset CLAUDECODE && claude` in vterm |
| Calendar not updating | `SPC :` then `my/sync-outlook-calendar` |

---

## Key Philosophy

- Journal daily. Don't overthink structure.
- One idea per roam note. Link generously.
- TODOs go in your journal. Agenda reads them automatically.
- Save often: `SPC f s`
- When in doubt, press `SPC` and explore the menu.
- Use Claude Code (`SPC o t` then `claude`) when you're stuck on config issues.
- Don't try to learn everything at once. The muscle memory builds naturally.

---

## 6. Jupyter Notebooks (EIN)

Run and edit `.ipynb` files directly inside Emacs using EIN (Emacs IPython Notebook).

### Prerequisites

Jupyter must be installed (`pip3 install jupyter ipympl`). Already done.

### Starting a Notebook Server

**Option A -- from vterm:**
```
SPC o t
jupyter notebook --no-browser
```
Then in Emacs: `SPC :` then `ein:notebooklist-login`, enter `http://localhost:8888`, paste the token from the terminal.

**Option B -- let EIN start it:**
`SPC :` then `ein:run`, select your Python. EIN launches Jupyter and connects automatically.

### Opening a Notebook

Once connected:
- `SPC :` then `ein:notebooklist-open` to browse notebooks
- Or `SPC f f`, navigate to a `.ipynb` file, EIN opens it automatically

### Cell Keybindings (in the notebook buffer)

| Key | Action |
|---|---|
| `C-c C-c` | Execute current cell |
| `C-c C-a` | Insert cell above |
| `C-c C-b` | Insert cell below |
| `C-c C-t` | Toggle cell type (code/markdown) |
| `C-c C-d` | Delete cell |
| `C-c C-n` | Move to next cell |
| `C-c C-p` | Move to previous cell |
| `C-c C-k` | Interrupt kernel |
| `C-c C-r` | Restart kernel |
| `C-c C-l` | Clear cell output |
| `C-c C-s` | Save notebook |
| `C-c C-#` | Split cell at point |

### Inline Plots

Plots render inline automatically (configured with `ein:output-area-inlined-images t` in config.el). For interactive 3D plots in the browser, use `%matplotlib widget` at the top of the notebook.

### Workflow

1. `SPC :` -> `ein:run` (starts Jupyter server)
2. `SPC :` -> `ein:notebooklist-open` (browse notebooks)
3. Navigate to cell, edit, `C-c C-c` to run
4. `C-c C-s` to save
5. `SPC :` -> `ein:stop` to shut down the server when done

### Troubleshooting

| Problem | Solution |
|---|---|
| Can't connect | Check Jupyter is running: `jupyter notebook list` in vterm |
| No plots | Make sure `%matplotlib inline` is in first cell |
| Wrong Python | `SPC :` then `ein:run` and select correct interpreter |
| Kernel died | `C-c C-r` to restart kernel |
