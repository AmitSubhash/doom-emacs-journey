# My Doom Emacs Journey

This is where it starts.

On the night of March 8-9, 2026, I went from zero Emacs knowledge to a fully working
personal productivity and research environment in a single evening. This repo is the
config that came out of that night -- annotated, explained, and honest about why I
made every choice I made.

I'm a neuroengineering PhD student (IU) who spends most of my time in Python doing
research on diffuse optical tomography and neonatal brain imaging. I'd been a VS Code
person. I'd heard about Emacs for years. I finally jumped.

---

## Why Doom Emacs

Vanilla Emacs in 2026 is like buying a plot of land and being handed a shovel. Doom
Emacs is like getting the shovel, a blueprint, and a team of people who've already
built sensible defaults so you don't have to discover over 10 years that `(setq
gc-cons-threshold 100000000)` exists.

Doom gives you:
- Evil mode (Vim keybindings) out of the box -- I wasn't giving those up
- A sane module system so you enable features rather than copy-pasting init snippets
- A community that has solved most of the painful bootstrapping problems
- Fast startup and a well-maintained core

The three files that control everything:

| File | Purpose |
|------|---------|
| `init.el` | Which Doom modules are active (features you want) |
| `packages.el` | Extra packages not in the Doom module system |
| `config.el` | Your personal configuration of everything above |

---

## `init.el` -- The Module Map

Doom organizes features into modules. Here's every module I enabled and why.

### `:completion`

```elisp
(corfu +orderless)
```
**Corfu** is in-buffer completion (what pops up as you type code). I picked it over
the older Company mode because it's lighter and faster. The `+orderless` flag lets
you type parts of a completion candidate in any order -- type `py im` and it matches
`python-import`. For research code where function names are long and varied, this is
a genuine time saver.

```elisp
(vertico +icons)
```
**Vertico** handles the minibuffer -- the search bar that appears at the bottom when
you open files, switch buffers, run commands. It replaces the default Emacs experience
with a vertical, incremental search that shows matches as you type. `+icons` adds
file-type icons so you can visually scan results. Think of it as a much better version
of VS Code's Command Palette.

---

### `:ui`

```elisp
doom
doom-dashboard
```
The Doom UI defaults and the splash screen on startup. Keeps things looking clean
rather than the default Emacs aesthetic from 1995.

```elisp
hl-todo
```
Highlights `TODO`, `FIXME`, `NOTE`, `HACK`, `DEPRECATED` in code with distinct colors.
In research code especially, I leave a lot of `# TODO: verify this against the paper`
comments. This makes them impossible to miss.

```elisp
modeline
```
The status bar at the bottom showing current file, git branch, LSP status, etc.
Doom's modeline is significantly more informative than the default.

```elisp
(popup +defaults)
```
Manages where popup windows appear (documentation, terminals, error messages). Without
this, popups can take over your whole screen in disorienting ways. `+defaults` sets
sensible rules so most popups appear at the bottom in a controlled way.

```elisp
(treemacs +lsp)
```
File tree sidebar, like VS Code's explorer panel. `SPC o p` to toggle it. `+lsp`
integrates it with the language server so it can show diagnostics per file. I use
this when navigating unfamiliar codebases more than my own research repos.

```elisp
(vc-gutter +pretty)
```
Shows git diff indicators in the left margin -- green for new lines, orange for
modified, red for deleted. Lets me see at a glance what I've changed in the current
file without opening Magit.

```elisp
workspaces
```
Tab-based workspaces via `SPC TAB`. Each tab is an isolated set of open buffers.
I use this to separate my research project from my notes from my config editing --
switching contexts without closing files.

```elisp
zen
```
Distraction-free writing mode. Hides everything except the current buffer, centers
the text, widens the margins. I use this for writing notes, reflections, and paper
drafts where I don't want to see code or file trees.

---

### `:editor`

```elisp
(evil +everywhere)
```
Vim keybindings, everywhere. This was non-negotiable. I've been using Vim motions
for years. `+everywhere` extends them into buffers that would otherwise be Emacs-only
(help pages, dired, magit, etc.). Without this I wouldn't have switched.

```elisp
(format +onsave)
```
Auto-formats code on save using whatever formatter is configured for the language.
For Python this triggers `ruff format`. I never want to think about formatting --
it should just happen.

```elisp
fold
```
Code folding -- collapse a function or class to a single line with `za`. Essential
for navigating large files.

```elisp
snippets
```
Text expansion via Yasnippet. Type a short trigger, hit Tab, get a full code template.
Doom ships with snippets for most languages. I plan to add research-specific ones
(SLURM job headers, numpy docstring templates, etc.).

---

### `:emacs`

```elisp
(dired +icons)
```
Dired is Emacs's built-in file manager. `+icons` adds visual icons. I use this less
than treemacs but it's powerful for batch file operations.

```elisp
(undo +tree)
```
Visual undo history. Instead of linear undo, you get a tree of every edit state you've
been in, and you can navigate it. This has saved me more than once when I've undone
something and then done other things before realizing I needed the undone content back.

---

### `:term`

```elisp
vterm
```
A proper terminal emulator inside Emacs. Not a fake shell -- a real PTY-based terminal
that handles things like `htop`, `ssh`, and interactive Python. I use this constantly:
running SLURM jobs, SSHing into BigRed200, running test suites. `SPC o t` to toggle.

---

### `:checkers`

```elisp
syntax
```
Live syntax checking (via Flycheck). Red/yellow underlines appear as you type for
errors and warnings, sourced from the LSP or standalone linters.

```elisp
(spell +aspell)
```
Spell checking, backed by Aspell. Useful in org-mode for writing notes and paper drafts.
Off by default in code buffers, on in prose buffers.

---

### `:tools`

```elisp
(eval +overlay)
```
Run code inline and see the result overlaid in the buffer. For Python exploration
this is excellent -- highlight an expression, run it, see the output without leaving
the file.

```elisp
(lookup +dictionary +docsets)
```
`K` to look up documentation for the symbol under the cursor. `+dictionary` adds
English dictionary lookup for prose writing. `+docsets` enables Dash/Zeal integration
for offline documentation.

```elisp
lsp
```
Language Server Protocol integration. The backbone of code intelligence: go-to-definition,
find-references, rename, hover docs, diagnostics. Without this Emacs is a text editor.
With this it's a proper IDE.

```elisp
magit
```
The best Git interface that exists, on any editor, anywhere. Period. `SPC g g` to open
it. Stage hunks (not just files), write commits, browse history, manage branches,
handle merge conflicts -- all in a structured, keyboard-driven interface that makes
the Git CLI feel primitive. This alone is worth switching to Emacs for.

```elisp
pdf
```
Read PDFs inside Emacs. Combined with `org-noter` (see packages.el), you can annotate
PDFs and have those annotations live as linked org-roam notes. The workflow for reading
research papers becomes: open PDF, take notes in the sidebar, notes auto-link back to
the page and position in the PDF.

---

### `:lang`

```elisp
(org
 +roam2
 +pretty
 +journal
 +dragndrop
 +hugo
 +noter
 +pomodoro
 +present)
```
Org-mode is the reason people stay in Emacs for 20 years. It is simultaneously:
a todo/task manager, a note-taking system, a calendar, a spreadsheet, a literate
programming environment, a presentation tool, and a document format that exports to
LaTeX, HTML, PDF, and more.

- `+roam2` -- Zettelkasten-style linked notes (think Obsidian, but text files, in Emacs)
- `+pretty` -- icons, better fonts, visual improvements in org buffers
- `+journal` -- daily journal files, `SPC n j j` to open today's
- `+dragndrop` -- drag images directly into org files
- `+hugo` -- export org files as Hugo blog posts if I ever publish a digital garden
- `+noter` -- annotate PDFs with notes that link back to exact page positions
- `+pomodoro` -- 25-minute focus timers on individual TODO items
- `+present` -- give presentations directly from org files

```elisp
(python +lsp +pyright)
```
Python support. `+lsp` enables code intelligence via LSP. `+pyright` specifically uses
Microsoft's Pyright type checker, which is significantly faster and more accurate than
alternatives for the type of scientific Python I write (numpy, torch, scipy).

```elisp
(latex +latexmk +cdlatex +lsp)
```
LaTeX support for papers. `+cdlatex` enables fast math entry -- in a LaTeX buffer,
type `\` and get a smart autocomplete for math symbols. `+latexmk` handles compilation.
This is how I'll write my PhD dissertation.

```elisp
(markdown +grip)
```
Markdown editing. `+grip` previews the rendered markdown in a browser using GitHub's
renderer, so what you see is what GitHub will show.

---

### `:app`

```elisp
(rss +org)
```
RSS feed reader inside Emacs, integrated with org-mode. I subscribe to arxiv feeds
for DOT/fNIRS/neonatal imaging papers. New papers show up in my Emacs as org entries
I can read, tag, and capture into my research notes.

---

## `packages.el` -- Extra Packages

These are packages I added beyond what the Doom module system provides.

### Productivity

**`super-save`** -- Auto-saves your buffers when you idle, switch windows, or switch
buffers. I never want to lose work because I forgot `SPC f s`. With this, I effectively
never lose anything. It runs silently in the background.

**`olivetti`** -- A distraction-free centered writing mode. Similar to the built-in
`zen` module but gives more control over the text width and margins. I use this for
writing that requires sustained focus -- paper drafts, long journal entries, notes
that need thinking.

**`org-superstar`** -- Replaces the `*` heading markers in org files with proper
typographic bullets and symbols. Makes org files feel less like plain text and more
like a document.

**`org-pomodoro`** -- Pomodoro timers (25-minute work intervals) tied directly to
org TODO items. `SPC m P` on any heading starts a timer. When the timer ends, Emacs
notifies you and logs the time spent on that task. This gives you an automatic record
of where your time went.

### Research and Notes

**`citar`** and **`citar-org-roam`** -- Citation management that integrates with
Zotero and BibTeX. When reading a paper and want to cite it in a note, `citar` lets
me search my Zotero library by title, author, or keyword and insert a proper citation.
`citar-org-roam` connects citations to roam notes -- each paper I read can have a
dedicated roam note linked to its citation.

**`org-noter`** -- The PDF annotation workflow. Open a PDF, open a paired org file,
and every note you take is anchored to the exact page and position in the PDF. When
you click the note later, it jumps to that exact spot in the PDF. Essential for
reading research papers with intent.

### Python

**`pet`** (Python Environment Tool) -- Automatically detects and activates virtual
environments. When I open a Python file inside a project that has a `.venv` or `conda`
environment, `pet` finds it and configures Emacs to use it for the LSP, the REPL, and
code execution. No more manually pointing Emacs at the right Python.

### Claude Code Integration

**`claude-code`** -- Runs Claude Code (`claude`) in a vterm buffer managed by Emacs.
This is how I use Claude Code from inside Emacs rather than switching to a separate
terminal tab. I can be editing a file and launch Claude Code in a split without
leaving my editor.

The commented-out `claude-code-ide` option is a more powerful MCP bridge that gives
Claude Code actual awareness of my Emacs state (open buffers, cursor position, LSP
diagnostics). I'll set that up once I'm more comfortable with the basics.

### Aesthetics

**`nerd-icons`** and **`nerd-icons-dired`** -- Icon fonts used throughout: in the
file tree, modeline, dired, completion results. Install the fonts once with
`M-x nerd-icons-install-fonts` and then everything has visual file-type indicators.

**`good-scroll`** -- Smooth pixel-level scrolling. Default Emacs scrolling jumps
by lines, which is jarring coming from any modern editor. This makes scrolling feel
continuous.

---

## `config.el` -- Key Decisions Explained

### Theme and Font

```elisp
(setq doom-theme 'doom-one)
```
`doom-one` is a dark theme that's easy on the eyes during long sessions. High contrast
between syntax categories without being garish.

```elisp
(setq doom-font (font-spec :family "JetBrains Mono" :size 14 :weight 'regular))
```
JetBrains Mono for code. It has excellent ligature support and is designed for long
reading sessions. Install with `brew install --cask font-jetbrains-mono`.

```elisp
(setq display-line-numbers-type 'relative)
```
Relative line numbers -- the current line shows its absolute number, all other lines
show their distance from the cursor. This is how you use Vim motions efficiently:
`12j` to jump 12 lines down, `5k` to go 5 lines up. With absolute line numbers you'd
have to do mental math every time.

### Org and Task Management

The TODO states are:
```
TODO -> NEXT -> IN-PROGRESS -> WAITING -> DONE / CANCELLED
```

This covers the full lifecycle of a research task:
- `TODO` -- captured, not yet prioritized
- `NEXT` -- the next thing to do on this project
- `IN-PROGRESS` -- actively working on it now
- `WAITING` -- blocked on someone else or an external event
- `DONE` / `CANCELLED` -- finished or dropped

The capture templates (`SPC X`) give me one-keystroke entry for tasks, notes, research
ideas, and journal entries without losing my current context.

### macOS PATH Fix

```elisp
(when IS-MAC
  (after! exec-path-from-shell
    (dolist (var '("PATH" "MANPATH" "NVM_DIR" "PYENV_ROOT" "CONDA_PREFIX"))
      (exec-path-from-shell-copy-env var))))
```

This is one of the most annoying macOS-specific problems: GUI Emacs doesn't inherit
your shell's `PATH`, so LSP servers (pyright, node) can't be found. This block copies
the necessary environment variables from your login shell into Emacs's process
environment. Without this, you'd see errors like `pyright not found` even though
`which pyright` works fine in your terminal.

### Performance

```elisp
(setq gc-cons-threshold 100000000          ; ~100MB before GC
      read-process-output-max (* 1024 1024) ; 1MB chunks for LSP
      lsp-idle-delay 0.5)
```

LSP servers send a lot of data. The defaults are tuned for a 1990s machine. Raising
these reduces the stuttering that happens when the LSP is streaming large responses.

### Magit Full-Frame

```elisp
(setq magit-display-buffer-function #'magit-display-buffer-fullframe-status-v1)
```

Opens Magit's status buffer in a full frame rather than a split. I prefer the full
view -- more space to see diffs, staged/unstaged changes, and the commit history
simultaneously.

---

## Getting Started

1. Install [Doom Emacs](https://github.com/doomemacs/doomemacs):
   ```bash
   git clone --depth 1 https://github.com/doomemacs/doomemacs ~/.config/emacs
   ~/.config/emacs/bin/doom install
   ```

2. Clone this repo into `~/.doom.d/`:
   ```bash
   git clone https://github.com/AmitSubhash/doom-emacs-journey ~/.doom.d
   ```

3. Update your identity in `config.el`:
   ```elisp
   (setq user-full-name "Your Name"
         user-mail-address "you@email.com")
   ```

4. Install fonts:
   ```bash
   brew install --cask font-jetbrains-mono
   # then inside Emacs:
   # M-x nerd-icons-install-fonts
   ```

5. Sync and launch:
   ```bash
   doom sync
   emacs
   ```

---

## The `GUIDE.md`

`GUIDE.md` is my personal cheatsheet from day one -- every keybinding, workflow, and
note-taking pattern that I needed to actually use this setup. It's written for me but
it might be useful to you too.

---

## What's Next

Things I know I want to add but haven't set up yet:

- `org-roam-ui` -- visual graph of linked notes in the browser
- `mu4e` -- email inside Emacs (already commented out in init.el, waiting until I'm ready)
- `gptel` -- talk to Claude in any buffer using my API key
- `org-present` -- give conference presentations from org files
- SLURM snippet templates for BigRed200 job scripts
- Research-specific yasnippets (numpy docstrings, MCX config blocks)

---

*Started: March 9, 2026. Zero Emacs knowledge on March 8.*
