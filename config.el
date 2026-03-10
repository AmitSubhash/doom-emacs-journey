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
          ("j" "Journal" entry (function org-journal-new-entry)
           "* %?\n  %U")))

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
;; ORG AGENDA KEYBINDINGS
;; ─────────────────────────────────────────
;; Use Emacs state in org-agenda so native keybindings (f, b, d, w, etc.) work.
;; evil-set-initial-state is the reliable way — it runs BEFORE evil-org-agenda
;; can override the state, unlike add-hook which gets clobbered.
(after! evil
  (evil-set-initial-state 'org-agenda-mode 'emacs))


;; ─────────────────────────────────────────
;; ORG JOURNAL — use .org extension so agenda can find TODOs
;; ─────────────────────────────────────────
(after! org-journal
  (setq org-journal-file-format "%Y%m%d.org"
        org-journal-dir "~/org/journal/"))


;; ─────────────────────────────────────────
;; ORG ROAM — linked research notes (like Obsidian but in Emacs)
;; SPC n r to access all roam commands
;; ─────────────────────────────────────────
(use-package! org-roam
  :after org
  :config
  (setq org-roam-directory "~/org/roam/"
        org-roam-dailies-directory "daily/"))

(use-package! org-roam-ui
  :after org-roam
  :config
  (setq org-roam-ui-sync-theme t
        org-roam-ui-follow t
        org-roam-ui-update-on-save t
        org-roam-ui-open-on-start nil))

;; Bind SPC n g -> org-roam-ui-open.
;; Must be outside use-package! :config because that block is deferred
;; until org-roam loads (lazy). The flat "n g" path adds to Doom's
;; existing SPC n prefix instead of redefining it.
(after! org-roam-ui
  (map! :leader
        :desc "Roam UI graph" "n g" #'org-roam-ui-open))


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
(use-package! claude-code-ide
  :bind ("C-c C-'" . claude-code-ide-menu)
  :config
  (claude-code-ide-emacs-tools-setup))

;; Confirm quit — prevents accidental closes
(setq confirm-kill-emacs 'y-or-n-p)

;; Scroll more like a normal editor
(setq scroll-margin 5
      scroll-conservatively 101)
