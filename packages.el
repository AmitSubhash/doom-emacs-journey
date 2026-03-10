;; -*- no-byte-compile: t; -*-
;;
;; DOOM EMACS — packages.el
;; Drop this into ~/.doom.d/packages.el
;; Run `doom sync` after changes, then restart Emacs
;;

;; Amit Subahsh added this, I'm doing this to add outlook to this
;; SO I can directly add tot his
(package! excorporate)

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
;; claude-code-ide: Full MCP bridge with diff panel
(package! claude-code-ide
  :recipe (:host github :repo "manzaltu/claude-code-ide.el"))

;; claude-code: Simpler Claude Code runner
(package! claude-code
  :recipe (:host github :repo "stevemolitor/claude-code.el"
                 :files ("*.el" "grpc")))


;; ── ORG ROAM UI ─────────────────────────
;; Visual graph of your linked roam notes in the browser
;; Launch with: M-x org-roam-ui-mode  (or SPC n g after config below)
(unpin! org-roam)       ; REQUIRED: org-roam-ui needs bleeding-edge org-roam
(package! org-roam-ui)
(package! websocket)    ; WebSocket server that powers the live graph


;; ── AESTHETICS ──────────────────────────
;; Nerd icons for file tree and modeline
(package! nerd-icons)
(package! nerd-icons-dired)

;; Smooth scrolling
(package! good-scroll)
