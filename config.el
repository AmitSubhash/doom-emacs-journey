;; -*- lexical-binding: t; -*-
;;
;; DOOM EMACS — config.el
;; Drop this into ~/.doom.d/config.el
;;

;; ─────────────────────────────────────────
;; IDENTITY
;; ─────────────────────────────────────────
(setq user-full-name "Amit Subhash"
      user-mail-address "your@email.com")  ; update this


;; Adding my own things gang, unbeatable subhash
(defun my/sync-outlook-calendar ()
  "Fetch Outlook calendar and import to org."
  (interactive)
  (let ((ics-url (getenv "OUTLOOK_CALENDAR_ICS_URL"))  ; export this in ~/.zshrc, never hardcode
    (shell-command
     (format "curl -s '%s'  | ical2orgpy - ~/org/outlook-cal.org" ics-url))
    (message "Outlook calendar synced!")))

;; ─────────────────────────────────────────
;; APPEARANCE
;; ─────────────────────────────────────────
(setq doom-theme 'doom-one)  ; clean dark theme, easy on eyes for long sessions

;; Font — JetBrains Mono is excellent for code + research
;; Install it first: brew install --cask font-jetbrains-mono
(setq doom-font (font-spec :family "JetBrains Mono" :size 14 :weight 'regular)
      doom-variable-pitch-font (font-spec :family "Inter" :size 14)
      doom-big-font (font-spec :family "JetBrains Mono" :size 22))  ; SPC t b for big font mode

;; Show line numbers
(setq display-line-numbers-type 'relative)  ; relative = easier vim jumping

;; Maximize on startup
(add-to-list 'initial-frame-alist '(fullscreen . maximized))


;; ─────────────────────────────────────────
;; ORG MODE — your productivity backbone
;; ─────────────────────────────────────────
(setq org-directory "~/org/")  ; all your org files live here, keep it simple

(after! org
  ;; Task states — covers your research + life workflow
  (setq org-todo-keywords
        '((sequence "TODO(t)" "NEXT(n)" "IN-PROGRESS(i)" "WAITING(w@/!)"
                    "|" "DONE(d)" "CANCELLED(c@)")))

  ;; Color-code task states
  (setq org-todo-keyword-faces
        '(("TODO"        . (:foreground "#ff6c6b" :weight bold))
          ("NEXT"        . (:foreground "#da8548" :weight bold))
          ("IN-PROGRESS" . (:foreground "#ecbe7b" :weight bold))
          ("WAITING"     . (:foreground "#a9a1e1" :weight bold))
          ("DONE"        . (:foreground "#98be65" :weight bold))
          ("CANCELLED"   . (:foreground "#5b6268" :weight bold :strike-through t))))

  ;; Capture templates — quick entry points for new tasks/notes
  ;; SPC X to trigger capture from anywhere
  (setq org-capture-templates
        '(("t" "Task" entry (file+headline "~/org/inbox.org" "Tasks")
           "* TODO %?\n  %U\n  %a")
          ("n" "Note" entry (file+headline "~/org/inbox.org" "Notes")
           "* %? :note:\n  %U")
          ("r" "Research idea" entry (file+headline "~/org/research.org" "Ideas")
           "* %? :research:\n  %U\n  Source: %a")
          ("j" "Journal" entry (file+datetree "~/org/journal.org")
           "* %U %?\n  %i")))

  ;; Agenda — your daily command center
  ;; SPC o a a to open
  (setq org-agenda-files '("~/org/" "~/org/journal/"))
  (setq org-agenda-span 'week)

  ;; Better looking org
  (setq org-hide-emphasis-markers t      ; hide *bold* markers, show result
        org-pretty-entities t
        org-ellipsis " ▾ "
        org-startup-indented t))


;; ─────────────────────────────────────────
;; ORG ROAM — linked research notes (like Obsidian but in Emacs)
;; SPC n r to access all roam commands
;; ─────────────────────────────────────────
(use-package! org-roam
  :after org
  :config
  (setq org-roam-directory "~/org/roam/"
        org-roam-dailies-directory "daily/"))


;; ─────────────────────────────────────────
;; ORG ROAM UI — visual graph of your notes
;; Opens in browser at http://127.0.0.1:35901/
;; SPC n g to toggle. Double-click a node to jump to that note in Emacs.
;; Graph updates live as you save notes.
;; ─────────────────────────────────────────
(use-package! websocket
  :after org-roam)

(use-package! org-roam-ui
  :after org-roam
  :config
  (setq org-roam-ui-sync-theme t           ; mirrors doom-one colors in graph
        org-roam-ui-follow t               ; graph pans to current note
        org-roam-ui-update-on-save t       ; live refresh on save
        org-roam-ui-open-on-start nil      ; don't auto-open browser every launch
        ;; open graph in Chrome for better WebGL perf than xwidget
        org-roam-ui-browser-function #'browse-url-default-macosx-browser)

  (map! :leader
        (:prefix ("n" . "notes")
         :desc "Roam graph (UI)" "g" #'org-roam-ui-mode)))


;; ─────────────────────────────────────────
;; ORG TREE SLIDE — presentations from org files
;; Already installed via +present in init.el, just needs configuration.
;; F8 to start/stop. F9/F10 to navigate slides.
;; Each top-level * heading = one slide.
;; ─────────────────────────────────────────
(after! org-tree-slide
  (org-tree-slide-presentation-profile)

  (map! :map org-tree-slide-mode-map
        "<f8>"  #'org-tree-slide-mode
        "<f9>"  #'org-tree-slide-move-previous-tree
        "<f10>" #'org-tree-slide-move-next-tree)

  (setq org-tree-slide-header t            ; show #+title and #+author at top
        org-tree-slide-breadcrumbs " > "   ; section breadcrumb separator
        org-tree-slide-activate-message   "Presentation mode ON"
        org-tree-slide-deactivate-message "Presentation mode OFF")

  ;; Entering presentation: enlarge text, show images, lock editing
  (add-hook 'org-tree-slide-play-hook
            (lambda ()
              (text-scale-increase 2)
              (org-display-inline-images)
              (read-only-mode +1)))

  ;; Leaving presentation: restore everything
  (add-hook 'org-tree-slide-stop-hook
            (lambda ()
              (text-scale-increase 0)
              (org-remove-inline-images)
              (read-only-mode -1))))


;; ─────────────────────────────────────────
;; PATH / EXEC-PATH FIX (macOS GUI Emacs)
;; EMACS_PLUS_NO_PATH_INJECTION=1 is baked into the doom binary and
;; .local/env, preventing the shell PATH from reaching exec-path.
;; This means lsp-mode cannot find npm/node to install pyright.
;; Fix: sync PATH explicitly at startup via exec-path-from-shell.
;; ─────────────────────────────────────────
(when IS-MAC
  (after! exec-path-from-shell
    (dolist (var '("PATH" "MANPATH" "NVM_DIR" "PYENV_ROOT" "CONDA_PREFIX"))
      (exec-path-from-shell-copy-env var))
    (exec-path-from-shell-initialize))
  ;; Belt-and-suspenders: hard-code Homebrew paths in case the above
  ;; runs after lsp-mode first tries to find npm.
  (dolist (path '("/opt/homebrew/bin" "/opt/homebrew/sbin" "/usr/local/bin"))
    (add-to-list 'exec-path path t)))


;; ─────────────────────────────────────────
;; LSP / PYRIGHT
;; ─────────────────────────────────────────
(after! lsp-mode
  (setq lsp-log-io nil
        lsp-enable-symbol-highlighting t))

(after! lsp-ui
  (setq lsp-ui-doc-enable t          ; K shows inline doc popup
        lsp-ui-doc-show-with-cursor t
        lsp-ui-doc-position 'at-point
        lsp-ui-doc-delay 0.2
        lsp-ui-sideline-enable nil)) ; sideline is noisy, disable it


;; ─────────────────────────────────────────
;; BROWSER — xwidget-webkit
;; Full Chromium-based renderer, compiled into this Emacs build.
;; Replaces opening external browser for K docs, org links, etc.
;; Keybindings (inside xwidget buffer):
;;   g = go to URL   r = reload   b = back   f = forward   q = quit
;; SPC o w  = open URL in embedded browser
;; SPC o W  = open URL in Safari/external (fallback)
;; ─────────────────────────────────────────
(when (featurep 'xwidget-internal)
  (setq browse-url-browser-function #'xwidget-webkit-browse-url
        browse-url-secondary-browser-function #'browse-url-default-macosx-browser)

  (map! :leader
        (:prefix ("o" . "open")
         :desc "Browser (xwidget)" "w" #'xwidget-webkit-browse-url
         :desc "Browser (Safari)"  "W" #'browse-url-default-macosx-browser))

  (after! xwidget
    (setq xwidget-webkit-enable-plugins nil))) ; keep it stable, no plugins


;; ─────────────────────────────────────────
;; PYTHON
;; ─────────────────────────────────────────
(after! python
  (setq python-shell-interpreter "python3"))

;; Use virtual envs automatically when present
(use-package! pet
  :config
  (add-hook 'python-base-mode-hook 'pet-mode -10))


;; ─────────────────────────────────────────
;; MAGIT — git interface
;; SPC g g to open in current project
;; ─────────────────────────────────────────
(after! magit
  (setq magit-display-buffer-function #'magit-display-buffer-fullframe-status-v1))


;; ─────────────────────────────────────────
;; VTERM — terminal inside Emacs
;; SPC o t to toggle
;; ─────────────────────────────────────────
(after! vterm
  (setq vterm-max-scrollback 10000))


;; ─────────────────────────────────────────
;; WORKSPACES — tab-based project separation
;; SPC TAB to manage
;; ─────────────────────────────────────────
(after! persp-mode
  (setq persp-autokill-buffer-on-remove 'kill-weak))


;; ─────────────────────────────────────────
;; PERFORMANCE
;; ─────────────────────────────────────────
(setq gc-cons-threshold 100000000          ; reduce GC pauses
      read-process-output-max (* 1024 1024) ; faster LSP
      lsp-idle-delay 0.5)


;; ─────────────────────────────────────────
;; QUALITY OF LIFE
;; ─────────────────────────────────────────
;; Auto-save when you switch buffers/windows
(after! super-save
  (super-save-mode +1)
  (setq super-save-auto-save-when-idle t))

;; ─────────────────────────────────────────
;; CLAUDE CODE IDE — bidirectional MCP bridge
;; C-c C-' to open menu
;; ─────────────────────────────────────────
;; Prevent CLAUDECODE env var from blocking Claude Code in Emacs
;; Layer 1: never capture it in doom's env file
(after! doom-cli-env
  (add-to-list 'doom-env-deny "^CLAUDECODE$"))
;; Layer 2: always unset it at runtime (belt + suspenders)
(setenv "CLAUDECODE" nil)

(use-package! claude-code-ide
  :bind (("C-c C-'" . claude-code-ide-menu)        ; transient menu
         ("C-c c c" . claude-code-ide)              ; start/toggle session
         ("C-c c r" . claude-code-ide-resume)       ; resume previous conversation
         ("C-c c k" . claude-code-ide-continue)     ; continue most recent
         ("C-c c p" . claude-code-ide-send-prompt)  ; send prompt from minibuffer
         ("C-c c s" . claude-code-ide-list-sessions) ; switch sessions
         ("C-c c t" . claude-code-ide-toggle)       ; toggle window visibility
         ("C-c c @" . claude-code-ide-insert-at-mentioned)) ; send selection
  :config
  ;; Claude window on the right, 100 columns wide
  (setq claude-code-ide-window-side 'right
        claude-code-ide-window-width 100)
  ;; Enable Emacs MCP tools (xref, treesitter, imenu, project info)
  (claude-code-ide-emacs-tools-setup))

;; Confirm quit — prevents accidental closes
(setq confirm-kill-emacs 'y-or-n-p)

;; Scroll more like a normal editor
(setq scroll-margin 5
      scroll-conservatively 101)
