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

;; Better looking org mode bullets and headers
(package! org-superstar)

;; Pomodoro timer integrated with org
(package! org-pomodoro)


;; ── RESEARCH / NOTES ────────────────────
;; Citation management — works with Zotero/BibTeX
(package! citar)
(package! citar-org-roam)

;; PDF annotation that links back to org notes
(package! org-noter)


;; ── PYTHON ──────────────────────────────
;; Auto-detect and activate virtualenvs
(package! pet)


;; ── CLAUDE CODE INTEGRATION ─────────────
;; Option A: Full MCP bridge (more powerful)
;; Uncomment when ready:
;; (package! claude-code-ide
;;   :recipe (:host github :repo "manzaltu/claude-code-ide.el"))

;; Option B: Simpler Claude Code runner (recommended to start)
(package! claude-code
  :recipe (:host github :repo "stevemolitor/claude-code.el"
           :files ("*.el" "grpc")))


;; ── AESTHETICS ──────────────────────────
;; Nerd icons for file tree and modeline
(package! nerd-icons)
(package! nerd-icons-dired)

;; Smooth scrolling
(package! good-scroll)
