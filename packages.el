;; -*- no-byte-compile: t; -*-
;;
;; DOOM EMACS — packages.el
;; Drop this into ~/.doom.d/packages.el
;; Run `doom sync` after changes, then restart Emacs
;;

;; Outlook calendar sync (requires ical2orgpy CLI)
(package! excorporate)

;; ── PRODUCTIVITY ────────────────────────
;; macOS native notifications for org reminders
(package! alert)

;; Auto-save when you idle or switch windows
(package! super-save)

;; Distraction-free centered writing (great for papers/notes)
(package! olivetti)

;; Better looking org mode bullets and headers
(package! org-superstar)

;; Modern org rendering: TODO pills, table polish, fold markers (the biggest
;; visual upgrade. Works alongside org-superstar, doesn't replace it.)
(package! org-modern)

;; Group agenda entries by project / priority / tag instead of one flat list.
;; Single most useful package for making the agenda feel intuitive.
(package! org-super-agenda)

;; Kanban board view rendered inline in any org file from TODO states.
(package! org-kanban)

;; org-pomodoro: already provided by Doom's +pomodoro flag in init.el
;; org-noter:    already provided by Doom's +noter flag in init.el

;; ── RESEARCH / NOTES ────────────────────
;; Citation management — works with Zotero/BibTeX
(package! citar)
(package! citar-org-roam)


;; ── macOS PATH FIX ────────────────────
;; GUI Emacs doesn't inherit shell PATH
(package! exec-path-from-shell)

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

;; Solaire-mode: subtly differentiate "real" file buffers from popups/sidebars
(package! solaire-mode)

;; Themes — added to rotation (SPC t T)
(package! ef-themes)
(package! catppuccin-theme)

;; Subtle vertical indent guides in code buffers
(package! highlight-indent-guides)

;; ── AI-NATIVE EDITING ───────────────────
;; minuet-ai: Cursor-style tab completion powered by Claude (FIM)
(package! minuet
  :recipe (:host github :repo "milanglacier/minuet-ai.el"))

;; aidermacs: multi-file agent edits with ediff diff review (optional companion to claude-code-ide)
(package! aidermacs
  :recipe (:host github :repo "MatthewZMD/aidermacs"))

;; ── ORG ROAM UI ─────────────────────────
;; Visual graph of linked roam notes — opens in xwidget browser
(unpin! org-roam)
;; simple-httpd: MELPA recipe points to skeeto/emacs-web-server, but
;; eschulte/emacs-web-server (package "web-server") shares the same
;; repo dirname, causing a straight.el collision.  :local-repo avoids it.
(package! simple-httpd
  :recipe (:host github :repo "skeeto/emacs-web-server"
           :local-repo "simple-httpd"))
(package! websocket)
(package! org-roam-ui)


;; ── COLLABORATOR: AGENTIC WORKSPACE ──────
;; mcp.el: MCP client (connect Emacs TO external MCP servers)
(package! mcp
  :recipe (:host github :repo "lizqwerscott/mcp.el"
           :files ("*.el")))

;; eat: fast pure-elisp terminal emulator for agent output
(package! eat
  :recipe (:host codeberg :repo "akib/emacs-eat"
           :files ("*.el" ("term" "term/*.el") "*.texi"
                   "*.ti" ("e" "e/*")
                   ("integration" "integration/*"))))

;; agent-shell + acp.el: run CLI agents via Agent Client Protocol
(package! shell-maker)
(package! acp
  :recipe (:host github :repo "xenodium/acp.el"))
(package! agent-shell
  :recipe (:host github :repo "xenodium/agent-shell"))
