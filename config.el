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
          ("j" "Journal" entry (file+datetree "~/org/journal.org")
           "* %U %?\n  %i")))

  ;; Agenda — your daily command center
  ;; SPC o a a to open
  (setq org-agenda-files '("~/org/"))
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
;; PATH / EXEC-PATH FIX (macOS GUI Emacs)
;; emacs-plus sets EMACS_PLUS_NO_PATH_INJECTION=1, which prevents
;; the shell PATH from reaching exec-path. Fix it explicitly so
;; lsp-mode can find npm/node/pyright.
;; ─────────────────────────────────────────
(when IS-MAC
  (after! exec-path-from-shell
    (dolist (var '("PATH" "MANPATH" "NVM_DIR" "PYENV_ROOT" "CONDA_PREFIX"))
      (exec-path-from-shell-copy-env var))
    (exec-path-from-shell-initialize))
  ;; Belt-and-suspenders: ensure Homebrew bin is always in exec-path
  (dolist (path '("/opt/homebrew/bin" "/opt/homebrew/sbin" "/usr/local/bin"))
    (add-to-list 'exec-path path t)))


;; ─────────────────────────────────────────
;; LSP / PYRIGHT
;; ─────────────────────────────────────────
(after! lsp-mode
  (setq lsp-log-io nil                    ; reduce noise
        lsp-enable-symbol-highlighting t))

(after! lsp-ui
  (setq lsp-ui-doc-enable t              ; K shows inline doc popup
        lsp-ui-doc-show-with-cursor t
        lsp-ui-doc-position 'at-point
        lsp-ui-doc-delay 0.2
        lsp-ui-sideline-enable nil))     ; sideline is noisy, keep it off


;; ─────────────────────────────────────────
;; BROWSER — xwidget-webkit (full renderer, built into this Emacs build)
;; Keybindings:
;;   SPC o w   open URL in xwidget browser
;;   SPC o W   open URL in external browser (fallback)
;; Inside xwidget buffer: g=go, r=reload, b=back, f=forward, q=quit
;; ─────────────────────────────────────────
(when (featurep 'xwidget-internal)
  (setq browse-url-browser-function #'xwidget-webkit-browse-url
        browse-url-secondary-browser-function #'browse-url-default-macosx-browser)

  (map! :leader
        (:prefix ("o" . "open")
         :desc "Browser (xwidget)"  "w" #'xwidget-webkit-browse-url
         :desc "Browser (external)" "W" #'browse-url-default-macosx-browser))

  (after! xwidget
    (setq xwidget-webkit-enable-plugins nil))) ; no Flash etc., keeps it stable


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
(super-save-mode +1)
(setq super-save-auto-save-when-idle t)

;; Confirm quit — prevents accidental closes
(setq confirm-kill-emacs 'y-or-n-p)

;; Scroll more like a normal editor
(setq scroll-margin 5
      scroll-conservatively 101)
