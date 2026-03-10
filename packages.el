;; -*- no-byte-compile: t; -*-
;;
;; DOOM EMACS — packages.el
;; Drop this into ~/.doom.d/packages.el
;; Run `doom sync` after changes, then restart Emacs
;;

;; ── PRODUCTIVITY ────────────────────────
;; Auto-save when you idle or switch windows
(package! super-save)

;; Distraction-free centered writing (great for papers/notes)
(package! olivetti)

;; org-superstar, org-pomodoro, org-noter are provided by Doom's
;; +pretty, +pomodoro, +noter flags in init.el — no need to declare here

;; ── RESEARCH / NOTES ────────────────────
;; Citation management — works with Zotero/BibTeX
(package! citar)
(package! citar-org-roam)

;; Roam UI — interactive graph visualization in browser
(package! simple-httpd)   ; required dependency of org-roam-ui
(package! org-roam-ui)


;; ── PYTHON ──────────────────────────────
;; Auto-detect and activate virtualenvs
(package! pet)


;; ── CLAUDE CODE INTEGRATION ─────────────
;; claude-code-ide: Full MCP bridge with diff panel
(package! claude-code-ide
  :recipe (:host github :repo "manzaltu/claude-code-ide.el"))

;; claude-code: Simpler Claude Code runner
(package! claude-code
  :recipe (:host github :repo "stevemolitor/claude-code.el"
           :files ("*.el" "grpc")))


;; ── AESTHETICS ──────────────────────────
;; Nerd icons for file tree and modeline
(package! nerd-icons)
(package! nerd-icons-dired)

;; Smooth scrolling
(package! good-scroll)
