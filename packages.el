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
;; macOS native notifications for org reminders
(package! alert)

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




;; ── AESTHETICS ──────────────────────────
;; Nerd icons for file tree and modeline
(package! nerd-icons)
(package! nerd-icons-dired)

;; Smooth scrolling
(package! good-scroll)


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
