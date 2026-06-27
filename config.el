;; -*- lexical-binding: t; -*-
;;
;; DOOM EMACS — config.el
;; Drop this into ~/.doom.d/config.el
;;

;; ─────────────────────────────────────────
;; IDENTITY
;; ─────────────────────────────────────────
(setq user-full-name "Amit Subhash"
      user-mail-address "atsubhas@iu.edu")  ; update this


;; Outlook calendar sync -- ICS URL kept in env var for safety.
;; Set OUTLOOK_ICS_URL in your shell profile or .env.
(defun my/sync-outlook-calendar ()
  "Fetch Outlook calendar and import to org."
  (interactive)
  (let ((ics-url (getenv "OUTLOOK_ICS_URL")))
    (unless ics-url
      (user-error "Set OUTLOOK_ICS_URL in your shell profile first"))
    (with-temp-buffer
      (let ((curl-status (call-process "curl" nil t nil "-fsSL" ics-url))
            (output-file (expand-file-name "~/org/outlook-cal.org")))
        (unless (zerop curl-status)
          (error "curl failed while fetching Outlook calendar"))
        (unless (zerop
                 (call-process-region
                  (point-min) (point-max)
                  "ical2orgpy" nil nil nil "-" output-file))
          (error "ical2orgpy failed while importing Outlook calendar"))))
    (message "Outlook calendar synced!")))

;; ─────────────────────────────────────────
;; APPEARANCE
;; ─────────────────────────────────────────
;; Theme: modus-vivendi-tinted with a softer, lifted background.
;; Cycle themes anytime with SPC t T (defined below).
(setq doom-theme 'doom-tokyo-night)

;; Lifted, less-pitch-black palette tuned for Retina XDR.
;; Background ~#1a1d24 reads as deep charcoal without crushing your eyes.
;; Charcoal background pin DISABLED so each theme shows its own full palette
;; (background, modeline, everything), Typora-style. To bring the
;; charcoal-on-every-theme look back, change `(when nil` to `(progn`.
(when nil (custom-set-faces!
  '(default                  :background "#1a1d24" :foreground "#e6e6e6")
  '(fringe                   :background "#1a1d24")
  '(hl-line                  :background "#262a33")
  '(region                   :background "#3a3f4b")
  '(line-number              :foreground "#4c5260" :background "#1a1d24")
  '(line-number-current-line :foreground "#c4a7e7" :background "#262a33" :weight bold)
  '(cursor                   :background "#ffd866")
  '(font-lock-comment-face   :foreground "#8a93a6" :slant italic)
  '(font-lock-doc-face       :foreground "#a0a8bd" :slant italic)
  '(font-lock-string-face    :foreground "#a6e3a1")
  '(font-lock-keyword-face   :weight medium)
  ;; Modeline gets a subtle lift so it pops against the buffer
  '(mode-line                :background "#22262f" :box (:line-width 6 :color "#22262f"))
  '(mode-line-inactive       :background "#1d2027" :box (:line-width 6 :color "#1d2027"))
  ;; Vertical window divider — invisible thin line
  '(vertical-border          :foreground "#262a33" :background "#262a33")
  ;; Diff/magit faces with more saturation
  '(magit-diff-added         :background "#1d3325" :foreground "#a6e3a1")
  '(magit-diff-added-highlight :background "#234029" :foreground "#b6f3b1")
  '(magit-diff-removed       :background "#3a1f23" :foreground "#f38ba8")
  '(magit-diff-removed-highlight :background "#4a2429" :foreground "#ff9bbb")))

;; Solaire: subtly darken popups/sidebars so real file buffers feel "primary".
(use-package! solaire-mode
  :hook (after-init . solaire-global-mode))

;; Pick installed fonts defensively so one bad family name does not break startup.
(defun my/first-available-font (candidates)
  "Return the first installed font from CANDIDATES."
  (catch 'font
    (dolist (font candidates)
      (when (member font (font-family-list))
        (throw 'font font)))
    nil))

(let ((fixed-font (or (my/first-available-font '("JetBrainsMono Nerd Font" "JetBrains Mono"
                                                 "Iosevka Term"
                                                 "Cascadia Code NF"
                                                 "Menlo"))
                      "Menlo"))
      ;; Keep org prose neat and terminal-like by using the same mono stack.
      (variable-font nil)
      (unicode-font (or (my/first-available-font '("Symbols Nerd Font Mono"
                                                   "Symbola"
                                                   "Apple Symbols"))
                        "Apple Symbols")))
  (setq variable-font (or (my/first-available-font (list fixed-font
                                                         "JetBrains Mono"
                                                         "Menlo"
                                                         "Cascadia Code NF"))
                          fixed-font
                          "Menlo"))
  (setq doom-font (font-spec :family fixed-font :size 16 :weight 'medium)
        doom-variable-pitch-font (font-spec :family variable-font :size 16)
        doom-unicode-font (font-spec :family unicode-font :size 15)
        doom-big-font (font-spec :family fixed-font :size 24 :weight 'medium)))

;; Tighter, more readable line spacing on Retina
(setq-default line-spacing 0.18)

(after! mixed-pitch
  (setq mixed-pitch-set-height t))

(after! org
  ;; Keep org readable while staying close to the terminal/editor look.
  (add-hook 'org-mode-hook #'mixed-pitch-mode)
  (set-face-attribute 'org-document-title nil
                      :family (face-attribute 'variable-pitch :family nil t)
                      :height 1.2
                      :weight 'semi-bold)
  (dolist (face '(org-code
                  org-block
                  org-block-begin-line
                  org-block-end-line
                  org-table
                  org-formula
                  org-verbatim
                  org-meta-line
                  org-checkbox
                  line-number
                  line-number-current-line))
    (set-face-attribute face nil :inherit '(fixed-pitch))))

;; Show line numbers
(setq display-line-numbers-type 'relative)  ; relative = easier vim jumping

;; Maximize on startup
(add-to-list 'initial-frame-alist '(fullscreen . maximized))

;; ─────────────────────────────────────────
;; UI POLISH — frame padding, transparency, smooth scroll
;; ─────────────────────────────────────────
;; Internal padding so code doesn't kiss the window edge (modern editor feel)
(add-to-list 'default-frame-alist '(internal-border-width . 14))
(add-to-list 'initial-frame-alist '(internal-border-width . 14))

;; Subtle background transparency (active 95%, inactive 88%)
(add-to-list 'default-frame-alist '(alpha-background . 96))
(add-to-list 'initial-frame-alist '(alpha-background . 96))

;; Hide title bar text but keep traffic lights — cleaner look
(add-to-list 'default-frame-alist '(ns-transparent-titlebar . t))
(add-to-list 'default-frame-alist '(ns-appearance . dark))

;; Pixel-precise smooth scrolling (Emacs 29+)
(when (fboundp 'pixel-scroll-precision-mode)
  (pixel-scroll-precision-mode 1)
  (setq pixel-scroll-precision-interpolate-page t
        pixel-scroll-precision-use-momentum t
        pixel-scroll-precision-momentum-seconds 1.2))

;; Disable cursor blinking (less distracting)
(blink-cursor-mode -1)

;; Compact, icon-rich modeline
(after! doom-modeline
  (setq doom-modeline-height 32
        doom-modeline-bar-width 4
        doom-modeline-icon t
        doom-modeline-major-mode-icon t
        doom-modeline-major-mode-color-icon t
        doom-modeline-buffer-state-icon t
        doom-modeline-buffer-modification-icon t
        doom-modeline-buffer-encoding nil
        doom-modeline-vcs-max-length 24
        doom-modeline-modal-icon nil))

;; Keep Cmd-click/drag behaving like normal text selection on macOS.
(when IS-MAC
  (global-set-key (kbd "s-<down-mouse-1>") #'mouse-drag-region)
  (global-set-key (kbd "s-<drag-mouse-1>") #'mouse-set-region)
  (global-set-key (kbd "s-<mouse-1>") #'mouse-set-point))

;; Doom's benchmark hook can run before `doom-modules' is populated on some
;; startup paths. Guard it so startup doesn't error on the benchmark message.
(with-eval-after-load 'doom-start
  (defun my/doom-display-benchmark-safe-h (&optional return-p)
    "Display Doom's benchmark without assuming `doom-modules' is bound."
    (funcall (if return-p #'format #'message)
             "Doom loaded %d packages across %d modules in %.03fs"
             (- (length load-path) (length (get 'load-path 'initial-value)))
             (if (and (boundp 'doom-modules) (hash-table-p doom-modules))
                 (hash-table-count doom-modules)
               -1)
             doom-init-time))
  (advice-add #'doom-display-benchmark-h :override #'my/doom-display-benchmark-safe-h))


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
           "* %U %?\n  %i")
          ("p" "Project task" entry (file+headline "~/org/projects.org" "Inbox")
           "* TODO %?\n  :PROPERTIES:\n  :CREATED: %U\n  :END:\n  %a")
          ("P" "New project (full template)" entry
           (file+headline "~/org/projects.org" "Active projects")
           "* %^{Project name} :project:\n  :PROPERTIES:\n  :CATEGORY: %^{Short tag}\n  :CREATED: %U\n  :END:\n\n  Goal: %^{One-sentence goal, what does done look like}\n\n** NEXT %^{First action}\n** TODO \n** Notes\n** References\n")))

  ;; Agenda — your daily command center
  ;; SPC o a a to open
  (setq org-agenda-files '("~/org/" "~/org/journal/"))
  (setq org-agenda-span 'week)

  ;; Log timestamp when tasks are marked DONE
  (setq org-log-done 'time)

  ;; Better looking org
  (setq org-hide-emphasis-markers t      ; hide *bold* markers, show result
        org-pretty-entities t
        org-ellipsis " ▾ "
        org-startup-indented t)

  ;; Refile: move a captured task into the right project.
  ;; Targets = any heading up to depth 3 in agenda files (projects.org, etc).
  ;; Shows full path like "projects.org/Active projects/Piglet 26 cortical rendering".
  (setq org-refile-targets '((nil :maxlevel . 3)
                             (org-agenda-files :maxlevel . 3))
        org-refile-use-outline-path 'file
        org-outline-path-complete-in-steps nil
        org-refile-allow-creating-parent-nodes 'confirm))


;; ─────────────────────────────────────────
;; ORG-MODERN — modern rendering for org-mode
;; TODO pills, table polish, fold markers, timestamp chips
;; ─────────────────────────────────────────
(use-package! org-modern
  :hook ((org-mode . org-modern-mode)
         (org-agenda-finalize . org-modern-agenda))
  :config
  (setq org-modern-star 'replace
        org-modern-hide-stars nil
        org-modern-table t
        org-modern-block-fringe nil
        org-modern-keyword nil
        org-modern-checkbox nil
        org-modern-todo-faces
        '(("TODO"        :background "#ff6c6b" :foreground "#1c1f24" :weight bold)
          ("NEXT"        :background "#da8548" :foreground "#1c1f24" :weight bold)
          ("IN-PROGRESS" :background "#ecbe7b" :foreground "#1c1f24" :weight bold)
          ("WAITING"     :background "#a9a1e1" :foreground "#1c1f24" :weight bold)
          ("DONE"        :background "#98be65" :foreground "#1c1f24")
          ("CANCELLED"   :background "#5b6268" :foreground "#dfdfdf"))))


;; ─────────────────────────────────────────
;; ORG-SUPER-AGENDA — grouped agenda views (THE intuitiveness fix)
;; Groups by project / priority / tag instead of one flat wall of text.
;; ─────────────────────────────────────────
(use-package! org-super-agenda
  :after org-agenda
  :config
  (setq org-super-agenda-header-map (make-sparse-keymap))
  (org-super-agenda-mode 1))

;; A real dashboard. Open with SPC o a d (or M-x org-agenda d).
(after! org-agenda
  (setq org-agenda-custom-commands
        '(("d" "Dashboard"
           ((agenda "" ((org-agenda-span 3)
                        (org-deadline-warning-days 14)
                        (org-super-agenda-groups
                         '((:name "Overdue"    :deadline past :order 1)
                           (:name "Today"      :time-grid t :date today :order 2)
                           (:name "Due soon"   :deadline future :order 3)
                           (:name "Scheduled"  :scheduled today :order 4)))))
            (alltodo "" ((org-agenda-overriding-header "All open tasks")
                         (org-super-agenda-groups
                          '((:name "In Progress" :todo "IN-PROGRESS" :order 1)
                            (:name "Next"        :todo "NEXT"        :order 2)
                            (:name "Waiting on"  :todo "WAITING"     :order 3)
                            (:name "Research"    :tag "research"     :order 4)
                            (:name "Projects"    :tag "project"      :order 5)
                            (:name "Inbox"       :tag "inbox"        :order 6)
                            (:name "Someday"     :todo "TODO"        :order 9)))))))
          ("r" "Research view"
           ((tags-todo "+research" ((org-agenda-overriding-header "Research tasks")))
            (tags "+ideas" ((org-agenda-overriding-header "Ideas to explore")))))
          ("p" "Projects only"
           ((tags-todo "+project" ((org-agenda-overriding-header "All project tasks")
                                   (org-super-agenda-groups
                                    '((:auto-parent t))))))))))


;; ─────────────────────────────────────────
;; ORG-KANBAN — kanban board rendered inline in any org file
;; Add this dynamic block at the top of projects.org:
;;   #+BEGIN: kanban :mirrored t :match "project"
;;   #+END:
;; Then C-c C-c on the BEGIN line to render.
;; ─────────────────────────────────────────
(use-package! org-kanban
  :after org)


;; Quick keys for the new agenda views.
;; Doom already binds SPC o a to org-agenda. From the agenda dispatcher
;; that opens, press: d = Dashboard, r = Research, p = Projects.
;; We add convenience top-level commands so you can also do M-x amit/agenda-dashboard.
(defun amit/agenda-dashboard () (interactive) (org-agenda nil "d"))
(defun amit/agenda-research  () (interactive) (org-agenda nil "r"))
(defun amit/agenda-projects  () (interactive) (org-agenda nil "p"))


;; ─────────────────────────────────────────
;; APPOINTMENT REMINDERS + macOS NOTIFICATIONS
;; Org agenda items with timestamps trigger desktop alerts.
;; ─────────────────────────────────────────
;; Calendar notifications are DISABLED.
;; If you want desktop notifications for agenda items later, see
;; ~/.config/doom/disabled-calendar.el.bak for the original setup.
(after! org
  (when (fboundp 'appt-activate) (appt-activate -1))
  (remove-hook 'org-agenda-finalize-hook 'org-agenda-to-appt))


;; ─────────────────────────────────────────
;; SCHEDULED NOTIFICATIONS (no email needed)
;; M-x my/remind-me  -- schedule a macOS notification
;; Works while Emacs is running; use cron for persistent.
;; ─────────────────────────────────────────
(defun my/send-notification (title body)
  "Fire a macOS notification with sound. Safely escapes BODY/TITLE."
  (let* ((sanitize (lambda (s)
                     (replace-regexp-in-string
                      "[\"\n\r]" " " (format "%s" s))))
         (clean-title (funcall sanitize title))
         (clean-body  (funcall sanitize body))
         (script (format "display notification \"%s\" with title \"%s\" sound name \"Glass\""
                         clean-body clean-title)))
    (ignore-errors
      (call-process "osascript" nil 0 nil "-e" script))))

(defun my/schedule-reminder (datetime title body)
  "Schedule a macOS notification at DATETIME (e.g. \"March 12, 2026 6:00pm\").
Only fires while Emacs is running."
  (let* ((target-time (date-to-time datetime))
         (delay-seconds (float-time (time-subtract target-time (current-time)))))
    (if (> delay-seconds 0)
        (progn
          (run-at-time delay-seconds nil #'my/send-notification title body)
          (message "Reminder scheduled for %s (in %.0f minutes)"
                   datetime (/ delay-seconds 60.0)))
      (message "Error: That time is in the past!"))))

(defun my/remind-me (datetime title body)
  "Quick self-reminder via macOS notification.  M-x my/remind-me"
  (interactive
   (list
    (read-string "When? (e.g. March 15, 2026 9:00am): ")
    (read-string "Title: ")
    (read-string "Body: ")))
  (my/schedule-reminder datetime title body))


;; ─────────────────────────────────────────
;; ORG ROAM — linked research notes (like Obsidian but in Emacs)
;; SPC n r to access all roam commands
;; ─────────────────────────────────────────
(use-package! org-roam
  :after org
  :config
  (setq org-roam-directory "~/org/roam/"
        org-roam-dailies-directory "daily/")
  (org-roam-db-autosync-mode))


;; ─────────────────────────────────────────
;; ORG ROAM UI — interactive graph of linked notes
;; SPC n g  to open/toggle the graph in xwidget browser (embedded, no external app)
;; Double-click a node in the graph to jump to that note.
;; ─────────────────────────────────────────
(use-package! websocket
  :after org-roam)

(use-package! org-roam-ui
  :after org-roam
  :config
  (setq org-roam-ui-sync-theme       t
        org-roam-ui-follow           t
        org-roam-ui-update-on-save   t
        org-roam-ui-open-on-start    nil
        org-roam-ui-browser-function #'xwidget-webkit-browse-url))

;; Keybinding registered at startup, not lazily with the package.
;; org-roam-ui-open is autoloaded so it triggers package loading on first use.
(map! :leader
      (:prefix ("n" . "notes")
               :desc "Roam graph" "g" #'org-roam-ui-open))


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
;; GUI Emacs doesn't inherit shell PATH. exec-path-from-shell syncs it.
;; ─────────────────────────────────────────
(when IS-MAC
  (use-package! exec-path-from-shell
    :config
    (setq exec-path-from-shell-variables
          '("PATH" "MANPATH" "NVM_DIR" "PYENV_ROOT" "CONDA_PREFIX"))
    (exec-path-from-shell-initialize))
  ;; Belt-and-suspenders: hard-code Homebrew paths for early LSP startup
  (dolist (path '("/opt/homebrew/bin" "/opt/homebrew/sbin" "/usr/local/bin"))
    (add-to-list 'exec-path path t)))

;; ─────────────────────────────────────────
;; COMPLETION / NAVIGATION
;; Consult + Embark + Marginalia sharpen the minibuffer workflow.
;; Cape extends CAPF completion without adding constant motion.
;; ─────────────────────────────────────────
(global-set-key (kbd "C-c s l") #'consult-line)
(global-set-key (kbd "C-c s L") #'consult-line-multi)
(global-set-key (kbd "C-c s p") #'consult-ripgrep)
(global-set-key (kbd "C-c s b") #'consult-buffer)
(global-set-key (kbd "C-c .") #'embark-act)
(global-set-key (kbd "C-c ;") #'embark-dwim)
(global-set-key (kbd "C-h B") #'embark-bindings)

(after! consult
  ;; Keep previews on demand instead of constantly repainting windows.
  (consult-customize
   consult-buffer
   consult-line
   consult-line-multi
   consult-ripgrep
   consult-git-grep
   consult-grep
   :preview-key "M-.")
  (setq consult-line-start-from-top t))

(after! marginalia
  (marginalia-mode 1))

(after! embark
  (setq prefix-help-command #'embark-prefix-help-command))

(after! cape
  ;; Delay dabbrev until a real prefix exists so completion stays responsive.
  (defalias 'my/cape-dabbrev-min-3
    (cape-capf-prefix-length #'cape-dabbrev 3))

  (defun my/enable-cape-history ()
    "Enable history completion in the current shell-like buffer."
    (add-hook 'completion-at-point-functions #'cape-history nil t))

  (add-hook 'completion-at-point-functions #'cape-file)
  (add-hook 'completion-at-point-functions #'my/cape-dabbrev-min-3)
  (add-hook 'eshell-mode-hook #'my/enable-cape-history)
  (add-hook 'comint-mode-hook #'my/enable-cape-history))


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
;; DAP — Python debugger (debugpy)
;; SPC d d  start debugging current file
;; SPC d b  toggle breakpoint on current line
;; SPC d n  step over (next line)
;; SPC d i  step into function
;; SPC d o  step out of function
;; SPC d c  continue to next breakpoint
;; SPC d e  evaluate expression at point
;; SPC d r  restart debug session
;; SPC d x  disconnect/stop debugging
;; SPC d u  open UI panels (locals, watches, breakpoints)
;; ─────────────────────────────────────────
(after! dap-mode
  (setq dap-python-debugger 'debugpy
        dap-auto-configure-mode t)

  ;; Show local variables and breakpoints panels automatically
  (setq dap-auto-configure-features
        '(sessions locals breakpoints expressions repl))

  ;; Template: debug the current file
  (dap-register-debug-template
   "Python :: Current File"
   (list :type "python"
         :request "launch"
         :name "Python :: Current File"
         :program nil              ; filled dynamically below
         :justMyCode :json-false)) ; step into libraries too

  ;; Template: run pytest on current file
  (dap-register-debug-template
   "Python :: Pytest Current"
   (list :type "python"
         :request "launch"
         :module "pytest"
         :args "-xvs"
         :name "Python :: Pytest Current"
         :justMyCode :json-false)))

;; Auto-enable dap in Python buffers
(add-hook! python-base-mode-hook
  (dap-mode 1)
  (dap-ui-mode 1)
  (dap-tooltip-mode 1))    ; hover over vars to see values

;; Quick-debug current file without picking a template
(defun my/dap-debug-current-file ()
  "Debug the currently visited Python file with debugpy."
  (interactive)
  (dap-debug (list :type "python"
                   :request "launch"
                   :name (format "Debug: %s" (buffer-name))
                   :program (buffer-file-name)
                   :justMyCode :json-false)))

;; Keybindings under SPC d
(map! :leader
      (:prefix ("d" . "debug")
               ;; Core workflow
               :desc "Debug this file"      "d" #'my/dap-debug-current-file
               :desc "Debug (pick template)" "D" #'dap-debug
               :desc "Debug last config"    "l" #'dap-debug-last
               :desc "Restart"              "r" #'dap-debug-restart
               :desc "Disconnect"           "x" #'dap-disconnect

               ;; Stepping
               :desc "Breakpoint toggle"    "b" #'dap-breakpoint-toggle
               :desc "Breakpoint condition" "B" #'dap-breakpoint-condition
               :desc "Step over (next)"     "n" #'dap-next
               :desc "Step into"            "i" #'dap-step-in
               :desc "Step out"             "o" #'dap-step-out
               :desc "Continue"             "c" #'dap-continue

               ;; Inspection
               :desc "Eval at point"        "e" #'dap-eval-thing-at-point
               :desc "Eval expression"      "E" #'dap-eval
               :desc "Eval region"          "v" #'dap-eval-region
               :desc "Add watch"            "w" #'dap-ui-expressions-add

               ;; UI panels
               (:prefix ("u" . "ui")
                        :desc "Locals"              "l" #'dap-ui-locals
                        :desc "Expressions/watch"   "e" #'dap-ui-expressions
                        :desc "Breakpoints list"    "b" #'dap-ui-breakpoints
                        :desc "Sessions"            "s" #'dap-ui-sessions
                        :desc "REPL"                "r" #'dap-ui-repl)))


;; ─────────────────────────────────────────
;; CODE INVESTIGATION — unique tools not covered by Magit or default Doom
;; SPC c I  opens the investigate prefix
;; ─────────────────────────────────────────
(defun my/investigate-call-hierarchy-incoming ()
  "Show incoming call hierarchy (who calls this?)."
  (interactive)
  (lsp-treemacs-call-hierarchy t))

(defun my/investigate-call-hierarchy-outgoing ()
  "Show outgoing call hierarchy (what does this call?)."
  (interactive)
  (lsp-treemacs-call-hierarchy nil))

(defun my/investigate-errors ()
  "List all diagnostics/errors in the project."
  (interactive)
  (if (bound-and-true-p lsp-mode)
      (lsp-treemacs-errors-list)
    (flycheck-list-errors)))

(map! :leader
      (:prefix ("c" . "code")
               (:prefix ("I" . "investigate")
                        :desc "Call hierarchy (in)"  "h" #'my/investigate-call-hierarchy-incoming
                        :desc "Call hierarchy (out)" "H" #'my/investigate-call-hierarchy-outgoing
                        :desc "Symbols in file"      "s" #'consult-imenu
                        :desc "Symbols in project"   "S" #'consult-imenu-multi
                        :desc "All errors/warnings"  "e" #'my/investigate-errors
                        :desc "Type definition"      "t" #'lsp-find-type-definition
                        :desc "Git time machine"     "T" #'git-timemachine)))


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
  (setq persp-autokill-buffer-on-remove 'kill-weak)

  ;; Protect Claude Code buffers from workspace autokill.
  ;; Without this, switching workspaces sends SIGHUP to the Claude process
  ;; (exit code 129) because persp-mode classifies terminal buffers as "weak".
  (defun my/persp-protect-claude-buffers (buffer)
    "Return non-nil for Claude buffers to filter them OUT of workspaces.
persp-mode treats non-nil as 'filtered out' -- buffer stays global and
is never auto-killed on workspace switch.
Covers: claude-code-ide (*claude-code*), claude-code.el (*claude:<dir>*),
agent-shell (*Claude Code*), and BR200 remote terminals (*br200*)."
    (string-match-p "\\*claude-code\\|\\*claude:\\|\\*Claude Code\\|\\*br200"
                    (buffer-name buffer)))
  (add-hook 'persp-common-buffer-filter-functions
            #'my/persp-protect-claude-buffers))


;; ─────────────────────────────────────────
;; PERFORMANCE
;; ─────────────────────────────────────────
(setq gc-cons-threshold 100000000          ; reduce GC pauses
      read-process-output-max (* 1024 1024) ; faster LSP
      lsp-idle-delay 0.5)



;; ─────────────────────────────────────────
;; GUIDE / CHEATSHEET — quick help in a bottom side window
;; ─────────────────────────────────────────
(defun my/open-guide ()
  "Open the local Doom guide in a single bottom side window."
  (interactive)
  (let* ((file   (expand-file-name "README.org" doom-user-dir))
         (existing (get-buffer "*doom-guide*"))
         (buffer (or existing
                     (find-file-noselect file))))
    (dolist (win (get-buffer-window-list buffer nil t))
      (delete-window win))
    (dolist (win (get-buffer-window-list (find-file-noselect file) nil t))
      (unless (eq (window-buffer win) buffer)
        (delete-window win)))
    (let ((window (display-buffer-in-side-window
                   buffer
                   '((side          . bottom)
                     (slot          . 5)
                     (window-height . 0.42)
                     (preserve-size . (nil . t))
                     (no-delete-other-windows . t)))))
      (with-current-buffer buffer
        (rename-buffer "*doom-guide*" t)
        (goto-char (point-min))
        (view-mode 1))
      (select-window window))))

(defun my/open-cheatsheet ()
  "Toggle the Emacs cheatsheet in a bottom window (like vterm)."
  (interactive)
  (let* ((buf-name "*cheatsheet*")
         (file     (expand-file-name "cheatsheet.html" doom-user-dir))
         (url      (concat "file://" file))
         (win      (get-buffer-window buf-name)))
    (cond
     ;; Visible -- hide it
     (win
      (delete-window win))
     ;; Buffer exists but hidden -- just show it
     ((get-buffer buf-name)
      (display-buffer-in-side-window
       (get-buffer buf-name)
       '((side          . bottom)
         (slot          . 5)
         (window-height . 0.42)
         (preserve-size . (nil . t))
         (no-delete-other-windows . t))))
     ;; First open -- create xwidget buffer
     (t
      (save-selected-window
        (xwidget-webkit-browse-url url)
        (rename-buffer buf-name t))
      (display-buffer-in-side-window
       (get-buffer buf-name)
       '((side          . bottom)
         (slot          . 5)
         (window-height . 0.42)
         (preserve-size . (nil . t))
         (no-delete-other-windows . t)))))))

(map! "C-c h" #'my/open-guide
      "C-c H" #'my/open-cheatsheet)

;; ─────────────────────────────────────────
;; LLM — Doom's :tools llm module (gptel + magit AI + ob-gptel)
;; ─────────────────────────────────────────
(after! gptel
  ;; Claude only -- Sonnet 4.6 default, Opus 4.6 for heavy tasks
  (setq gptel-backend
        (gptel-make-anthropic "Claude"
          :stream t
          :key (lambda () (getenv "ANTHROPIC_API_KEY"))
          :models '(claude-sonnet-4-6 claude-opus-4-6 claude-haiku-4-5))
        gptel-model 'claude-sonnet-4-6))

;; ─────────────────────────────────────────
;; QUALITY OF LIFE
;; ─────────────────────────────────────────
;; Auto-save when you switch buffers/windows
(use-package! super-save
  :config
  (super-save-mode +1)
  (setq super-save-auto-save-when-idle t))

;; Faster which-key popup (default 1s is sluggish)
(after! which-key
  (setq which-key-idle-delay 0.3))

;; Winner mode: undo/redo window layouts with C-c left / C-c right
(winner-mode +1)

;; Remember more recent files (SPC f r)
(after! recentf
  (setq recentf-max-saved-items 200))

;; Start Emacs server so `emacsclient` opens files instantly from terminal
(unless (or noninteractive (daemonp))
  (require 'server)
  (unless (server-running-p)
    (server-start)))

;; ─────────────────────────────────────────
;; CLAUDE CODE IDE — bidirectional MCP bridge
;; C-c C-' to open menu
;; ─────────────────────────────────────────
;; Prevent Claude/Codex session vars from leaking into doom's env cache.
;; Layer 1: deny patterns for `doom env` generation (affects next `doom sync`)
(after! doom-cli-env
  (dolist (pattern '("^CLAUDECODE"
                     "^CLAUDE_CODE_"
                     "^CLAUDE_PLUGIN_"
                     "^CODEX_"
                     "^ENABLE_IDE_INTEGRATION$"
                     "^FORCE_CODE_TERMINAL$"
                     "^NO_COLOR$"
                     "^GIT_EDITOR$"))
    (add-to-list 'doom-env-deny pattern)))

;; Layer 2: unset vars that actively BLOCK new Claude sessions.
;; CLAUDECODE=1 tells the CLI "you're already inside an IDE" and causes it
;; to refuse startup or die immediately.  The remaining session-specific vars
;; (tokens, ports, plugin paths) are harmless stale noise that each fresh CLI
;; process overwrites on its own -- so we leave them alone to avoid breaking
;; other launch paths (claude-code.el, agent-shell, vterm).
(setenv "CLAUDECODE" nil)
;; NO_COLOR suppresses ANSI escapes in all subprocesses -- undesirable in Emacs.
(setenv "NO_COLOR" nil)

(use-package! claude-code-ide
  :bind (("C-c C-'" . claude-code-ide-menu)        ; transient menu
         ("C-c c c" . claude-code-ide)              ; start/toggle session
         ("C-c c r" . claude-code-ide-resume)       ; resume previous conversation
         ("C-c c k" . claude-code-ide-continue)     ; continue most recent
         ("C-c c p" . claude-code-ide-send-prompt)  ; send prompt from minibuffer
         ("C-c c s" . claude-code-ide-list-sessions) ; switch sessions
         ("C-c c t" . claude-code-ide-toggle)       ; toggle window visibility
         ("C-c c @" . claude-code-ide-insert-at-mentioned))
  :config
  ;; Claude window on the right, narrow enough to preserve code width.
  (setq claude-code-ide-window-side 'right
        claude-code-ide-window-width 88)
  ;; Enable Emacs MCP tools (xref, treesitter, imenu, project info)
  (claude-code-ide-emacs-tools-setup)
  ;; Enable live status in modeline (token count, stream timer, rate limits)
  (claude-code-ide-status-mode 1)
  ;; Status keybindings (must be in :config, not :bind, for sub-module commands)
  (map! "C-c c a" #'claude-code-ide-status-show-analytics
        "C-c c u" #'claude-code-ide-status-refresh-usage))

;; claude-code.el: multiple named instances per project
(use-package! claude-code
  :bind (("C-c c n" . claude-code-new-instance)   ; create named instance
         ("C-c c b" . claude-code-switch-to-buffer) ; switch instance (current project)
         ("C-c c B" . claude-code-select-buffer)    ; switch instance (all projects)
         ("C-c c K" . claude-code-kill-all))        ; kill all instances
  :config
  (setq claude-code-window-side 'right
        claude-code-window-width 88))

;; Confirm quit — prevents accidental closes
(setq confirm-kill-emacs 'y-or-n-p)

;; Scroll more like a normal editor
(setq scroll-margin 5
      scroll-conservatively 101)


;; ─────────────────────────────────────────
;; ORG-SUPERSTAR — prettier org bullets and list markers
;; Replaces the default * heading stars with unicode symbols
;; ─────────────────────────────────────────
(use-package! org-superstar
  :after org
  :hook (org-mode . org-superstar-mode)
  :config
  (setq org-superstar-headline-bullets-list '("◉" "○" "✸" "✿" "✤")
        org-superstar-item-bullet-alist    '((?* . ?•) (?+ . ?➤) (?- . ?–))
        org-superstar-special-todo-items  t))


;; ─────────────────────────────────────────
;; OLIVETTI — distraction-free centered writing
;; SPC t o to toggle; pairs well with zen mode (SPC t z)
;; ─────────────────────────────────────────
(use-package! olivetti
  :config
  (setq olivetti-body-width 90
        olivetti-minimum-body-width 72
        olivetti-recall-visual-line-mode-entry-state t)
  (map! :leader
        (:prefix ("t" . "toggle")
                 :desc "Olivetti (centered)" "o" #'olivetti-mode)))


;; ─────────────────────────────────────────
;; NERD-ICONS — icons in dired, modeline, etc.
;; First time: run M-x nerd-icons-install-fonts
;; ─────────────────────────────────────────
;; Doom's `(dired +icons)` module already adds file icons in Dired.
;; Enabling `nerd-icons-dired-mode` on top of that duplicates every icon.
(use-package! nerd-icons
  :when (display-graphic-p))


;; ─────────────────────────────────────────
;; CITAR — citation management (Zotero / BibTeX)
;; SPC n b b  insert citation in org
;; SPC n b o  open paper PDF/URL
;; SPC n b n  open/create notes for entry
;; Keep your .bib at ~/org/references.bib (Zotero Better BibTeX export target)
;; ─────────────────────────────────────────
(use-package! citar
  :after org
  :custom
  (citar-bibliography  '("~/org/references.bib"))
  (citar-notes-paths   '("~/org/roam/"))
  (citar-library-paths '("~/Documents/papers/"))
  :config
  (map! :leader
        (:prefix ("n" . "notes")
                 :desc "Insert citation"   "b b" #'citar-insert-citation
                 :desc "Open reference"    "b o" #'citar-open
                 :desc "Open notes"        "b n" #'citar-open-notes
                 :desc "Open bibliography" "b B" #'citar-open-entry)))

(use-package! citar-org-roam
  :after (citar org-roam)
  :config
  (citar-org-roam-mode 1)
  (setq citar-org-roam-note-title-template "${author} (${year}) - ${title}"))


;; -----------------------------------------
;; COLLABORATOR -- Agentic Workspace Module
;; -----------------------------------------
(load! "collaborator")


;; ─────────────────────────────────────────
;; DOOM DASHBOARD EXTRAS
;; ─────────────────────────────────────────
(setq +doom-dashboard-menu-sections
      (append
       `(("Org capture"
          :icon ,(nerd-icons-octicon "nf-oct-diff_added" :face 'doom-dashboard-menu-title)
          :key "SPC X"
          :when (fboundp 'org-capture)
          :action org-capture)
         ("Open local guide"
          :icon ,(nerd-icons-octicon "nf-oct-book" :face 'doom-dashboard-menu-title)
          :key "C-c h"
          :action my/open-guide))
       +doom-dashboard-menu-sections))


;; ─────────────────────────────────────────
;; TYPORA WRITING THEMES — prose fonts + per-theme backgrounds
;; SPC t y  pick a Typora theme (github/newsprint/night/pixyll/gothic/whitey)
;; Each carries its own background + prose font + per-level heading fonts.
;; Markdown buffers get the Typora reading layout (mixed-pitch + olivetti).
;; ─────────────────────────────────────────
(load! "typora-themes")

(after! markdown-mode
  (add-hook 'markdown-mode-hook #'mixed-pitch-mode)
  (add-hook 'markdown-mode-hook #'visual-line-mode)
  (add-hook 'markdown-mode-hook #'olivetti-mode))

;; Hang-indent soft-wrapped prose lines so a wrapped line aligns under the first
;; line instead of jutting to the left margin under org-indent. Uses Doom's
;; word-wrap module (adaptive-wrap). Affects journal/org and markdown buffers.
(add-hook 'org-mode-hook #'+word-wrap-mode)
(add-hook 'markdown-mode-hook #'+word-wrap-mode)


;; ─────────────────────────────────────────
;; THEME CYCLER — try a theme without editing config
;; SPC t T  pick from a curated list (live preview via consult)
;; SPC t L  toggle light/dark pair
;; ─────────────────────────────────────────
(defvar my/theme-rotation
  '(modus-vivendi-tinted
    ef-elea-dark
    ef-bio
    doom-tokyo-night
    doom-gruvbox
    doom-one
    doom-dracula
    doom-monokai-pro
    doom-nord
    catppuccin
    ;; Typora writing themes (typora-themes.el)
    typora-github
    typora-newsprint
    typora-night
    typora-pixyll
    typora-gothic
    typora-whitey)
  "Themes to cycle through with `my/cycle-theme'.")

(defvar my/chrome-faces
  '(default fringe hl-line region line-number line-number-current-line
    cursor mode-line mode-line-inactive vertical-border
    solaire-default-face solaire-fringe-face)
  "Frame chrome faces a Typora theme overrides; recalculated on the way back.")

(defun my/load-or-enable-theme (theme)
  "Activate THEME. Typora themes live in memory, so route them through
`my/typora-theme' (which `enable-theme's them); load others from file.
When returning to a dev theme, recalc the chrome faces so the charcoal
palette pinned in the `user' theme reasserts over any Typora override."
  (if (string-prefix-p "typora-" (symbol-name theme))
      (my/typora-theme theme)
    (mapc #'disable-theme custom-enabled-themes)
    (load-theme theme t)
    (dolist (f my/chrome-faces)
      (when (facep f) (custom-theme-recalc-face f)))))

(defun my/cycle-theme ()
  "Pick a theme from `my/theme-rotation' with live preview."
  (interactive)
  (let* ((choice (intern (completing-read
                          "Theme: "
                          (mapcar #'symbol-name my/theme-rotation)
                          nil t))))
    (my/load-or-enable-theme choice)
    (message "Loaded %s" choice)))

(defvar my/light-theme 'modus-operandi-tinted)
(defvar my/dark-theme  'doom-tokyo-night)

(defun my/toggle-light-dark ()
  "Swap between configured light and dark themes."
  (interactive)
  (let ((next (if (memq my/dark-theme custom-enabled-themes)
                  my/light-theme
                my/dark-theme)))
    (my/load-or-enable-theme next)
    (message "Loaded %s" next)))

(map! :leader
      (:prefix ("t" . "toggle")
               :desc "Cycle theme"      "T" #'my/cycle-theme
               :desc "Light/dark toggle" "L" #'my/toggle-light-dark
               :desc "Typora theme"     "y" #'my/typora-theme))


;; ─────────────────────────────────────────
;; THEME POLISH — titlebar follows theme + remember last pick across restarts
;; ─────────────────────────────────────────
;; macOS titlebar tracks the theme's light/dark nature, so a light theme no
;; longer keeps a dark title bar. Completes the "whole window transforms" feel.
(defun my/update-ns-appearance (&rest _)
  "Match the macOS titlebar to the current theme's background mode."
  (when (and (boundp 'IS-MAC) IS-MAC (display-graphic-p))
    (let ((appearance (if (eq (frame-parameter nil 'background-mode) 'dark)
                          'dark 'light)))
      (dolist (frame (frame-list))
        (set-frame-parameter frame 'ns-appearance appearance)))))
(advice-add 'load-theme   :after #'my/update-ns-appearance)
(advice-add 'enable-theme :after #'my/update-ns-appearance)

;; Remember the theme you pick with SPC t T and restore it next launch,
;; the way Typora keeps your last theme. Stored in ~/.config/doom/.last-theme.
(defvar my/last-theme-file (expand-file-name ".last-theme" doom-user-dir))
(defun my/save-last-theme (theme &rest _)
  "Persist THEME for restoration on next startup."
  (ignore-errors
    (with-temp-file my/last-theme-file (insert (symbol-name theme)))))
(advice-add 'my/load-or-enable-theme :after #'my/save-last-theme)
(defun my/restore-last-theme ()
  "Re-apply the last theme chosen through the cycler, if one was saved."
  (when (file-exists-p my/last-theme-file)
    (ignore-errors
      (let ((theme (intern (string-trim
                            (with-temp-buffer
                              (insert-file-contents my/last-theme-file)
                              (buffer-string))))))
        (when (and theme (not (memq theme custom-enabled-themes)))
          (my/load-or-enable-theme theme))))))
(add-hook 'emacs-startup-hook #'my/restore-last-theme)


;; ─────────────────────────────────────────
;; INDENT GUIDES — subtle vertical lines for code blocks
;; ─────────────────────────────────────────
(use-package! highlight-indent-guides
  :hook ((prog-mode . highlight-indent-guides-mode))
  :config
  (setq highlight-indent-guides-method 'character
        highlight-indent-guides-character ?\│
        highlight-indent-guides-responsive 'top
        highlight-indent-guides-auto-character-face-perc 12
        highlight-indent-guides-auto-top-character-face-perc 28))


;; ─────────────────────────────────────────
;; SAVE PLACE + RECENTF + AUTO-REVERT polish
;; ─────────────────────────────────────────
(save-place-mode 1)
(global-auto-revert-mode 1)
(setq global-auto-revert-non-file-buffers t
      auto-revert-verbose nil)


;; ─────────────────────────────────────────
;; DASHBOARD POLISH
;; ─────────────────────────────────────────
(after! doom-dashboard
  (setq fancy-splash-image nil
        +doom-dashboard-banner-padding '(0 . 2)))


;; ─────────────────────────────────────────
;; VC-GUTTER (git diff in fringe) — sharper symbols
;; ─────────────────────────────────────────
(after! git-gutter-fringe
  (custom-set-faces!
    '(git-gutter-fr:added    :foreground "#a6e3a1")
    '(git-gutter-fr:modified :foreground "#f9e2af")
    '(git-gutter-fr:deleted  :foreground "#f38ba8")))


;; ═════════════════════════════════════════
;; AI-NATIVE EDITING — Cursor/Zed-grade workflow
;; ═════════════════════════════════════════
;; Three layers, all powered by Claude:
;;   1. Tab autocomplete (minuet)         — predictions while typing
;;   2. Inline rewrite (gptel-rewrite)    — Cmd+K equivalent
;;   3. Agent mode (claude-code-ide)      — multi-file changes with diff
;;
;; Unified menu:  SPC a   (everything you'd ever want)
;; ═════════════════════════════════════════

;; ─── 1. TAB COMPLETION (minuet-ai) ───────
;; Inline ghost-text predictions as you type. Tab to accept, M-n/M-p to cycle.
(use-package! minuet
  :defer t
  :init
  ;; Show suggestions automatically in code buffers
  (add-hook 'prog-mode-hook #'minuet-auto-suggestion-mode)
  :config
  (setq minuet-provider 'claude
        minuet-n-completions 1
        minuet-context-window 16000
        minuet-request-timeout 4
        minuet-auto-suggestion-debounce-delay 0.4
        minuet-auto-suggestion-throttle-delay 1.0)

  ;; Use Claude Haiku for speed (Sonnet is overkill for FIM)
  (plist-put minuet-claude-options :model "claude-haiku-4-5")
  (plist-put minuet-claude-options :max_tokens 256)

  ;; Pull API key from env (same one gptel uses)
  (defun my/minuet-anthropic-key ()
    (or (getenv "ANTHROPIC_API_KEY")
        (user-error "ANTHROPIC_API_KEY not set in shell env")))
  (plist-put minuet-claude-options :api-key #'my/minuet-anthropic-key)

  ;; Keybindings while a suggestion is showing
  (define-key minuet-active-mode-map (kbd "TAB")    #'minuet-accept-suggestion)
  (define-key minuet-active-mode-map (kbd "C-<tab>") #'minuet-accept-suggestion-line)
  (define-key minuet-active-mode-map (kbd "M-n")    #'minuet-next-suggestion)
  (define-key minuet-active-mode-map (kbd "M-p")    #'minuet-previous-suggestion)
  (define-key minuet-active-mode-map (kbd "C-g")    #'minuet-dismiss-suggestion))


;; ─── 2. INLINE REWRITE (gptel-rewrite) ───
;; Cursor's Cmd+K: select code, describe change, ediff diff, accept/reject.
(after! gptel
  ;; Better diff UI for rewrites
  (setq gptel-rewrite-default-action 'ediff)

  ;; Curated system prompts for one-shot tasks
  (setq gptel-directives
        '((default     . "You are a precise coding assistant. Be concise. Output code only when asked.")
          (programmer  . "You are an expert programmer. Output ONLY code, no prose, no fences. Match the surrounding style. Preserve indentation exactly.")
          (refactor    . "Refactor for clarity and idiom. Preserve behavior. Output ONLY the rewritten code, no fences, no commentary.")
          (explain     . "Explain this code clearly and briefly. Cover what it does, why, and any subtle behavior. Use bullets where helpful.")
          (fix         . "Fix bugs in this code. Output ONLY the fixed code, no fences, no commentary. Preserve style and indentation.")
          (optimize    . "Optimize this code for performance and readability without changing behavior. Output ONLY the rewritten code, no commentary.")
          (document    . "Add concise docstrings/comments where they add value. Do not change code logic. Output ONLY the annotated code.")
          (test        . "Write thorough pytest tests for this code. Cover happy path, edge cases, error cases. Output ONLY the test file content.")
          (typehint    . "Add Python type hints to this code. Use modern syntax (Python 3.11+, X | None, list[T], etc.). Output ONLY the typed code.")
          (researcher  . "You help with neuroengineering research: DOT, MCX, NIRFASTerFF, NeuroDOT, PyTorch. Be precise about scientific correctness."))))

;; Quick-action helpers — one-shot rewrites without typing the prompt
(defun my/ai-rewrite-with (directive-key)
  "Run gptel-rewrite on the active region using a preset DIRECTIVE-KEY.
DIRECTIVE-KEY is a symbol from `gptel-directives'."
  (unless (use-region-p)
    (user-error "Select a region first"))
  (let ((gptel--system-message (alist-get directive-key gptel-directives)))
    (gptel-rewrite)))

(defun my/ai-refactor   () (interactive) (my/ai-rewrite-with 'refactor))
(defun my/ai-fix        () (interactive) (my/ai-rewrite-with 'fix))
(defun my/ai-optimize   () (interactive) (my/ai-rewrite-with 'optimize))
(defun my/ai-document   () (interactive) (my/ai-rewrite-with 'document))
(defun my/ai-typehint   () (interactive) (my/ai-rewrite-with 'typehint))

(defun my/ai-explain ()
  "Explain the region in a side buffer (no rewrite)."
  (interactive)
  (unless (use-region-p) (user-error "Select a region first"))
  (let ((text (buffer-substring-no-properties (region-beginning) (region-end)))
        (mode major-mode))
    (with-current-buffer (get-buffer-create "*AI Explain*")
      (let ((inhibit-read-only t))
        (erase-buffer)
        (markdown-mode)
        (insert "# Explanation\n\nAsking Claude...\n\n## Code\n\n```\n" text "\n```\n\n## Result\n\n"))
      (display-buffer (current-buffer) '(display-buffer-in-side-window
                                         (side . right) (window-width . 0.4)))
      (gptel-request
       text
       :system (alist-get 'explain gptel-directives)
       :buffer (current-buffer)
       :position (point-max)
       :context (format "language: %s" mode)))))

(defun my/ai-write-tests ()
  "Generate pytest tests for the region in a new buffer."
  (interactive)
  (unless (use-region-p) (user-error "Select a region first"))
  (let ((text (buffer-substring-no-properties (region-beginning) (region-end))))
    (with-current-buffer (get-buffer-create "*AI Tests*")
      (let ((inhibit-read-only t))
        (erase-buffer)
        (python-mode)
        (insert "# Generated tests — review before running\n\n"))
      (display-buffer (current-buffer) '(display-buffer-in-side-window
                                         (side . right) (window-width . 0.45)))
      (gptel-request
       text
       :system (alist-get 'test gptel-directives)
       :buffer (current-buffer)
       :position (point-max)))))

(defun my/ai-commit-message ()
  "Generate a conventional-commit message from staged diff and insert it."
  (interactive)
  (let* ((default-directory (or (vc-root-dir) default-directory))
         (diff (shell-command-to-string "git diff --cached")))
    (when (string-empty-p diff)
      (user-error "Nothing staged. Stage hunks in magit first"))
    (gptel-request
     (format "Generate a conventional commit message (feat/fix/refactor/docs/test/chore/perf/ci) for this diff. Output: one-line subject under 72 chars, blank line, optional body. NO co-author lines, NO 'hermes' or AI mentions, NO emojis. Just the commit message text.\n\nDIFF:\n%s" diff)
     :system "You write tight, conventional-format git commit messages. Imperative mood. No fluff."
     :callback
     (lambda (response _info)
       (when response
         (let ((msg (string-trim response)))
           (if (derived-mode-p 'git-commit-mode 'text-mode)
               (progn (goto-char (point-min)) (insert msg "\n"))
             (kill-new msg)
             (message "Commit message copied: %s"
                      (car (split-string msg "\n"))))))))))


;; ─── 3. AGENT MODE ─────────────────────
;; claude-code-ide is already configured (C-c C-' menu).
;; Aidermacs gives a parallel multi-file edit flow with ediff review.
(use-package! aidermacs
  :defer t
  :init
  (setq aidermacs-default-model "anthropic/claude-sonnet-4-6"
        aidermacs-use-architect-mode nil
        aidermacs-show-diff-after-change t
        aidermacs-auto-commits nil)) ; you commit yourself via magit


;; ─── 4. UNIFIED AI MENU (SPC l for LLM) ──────────
;; All AI actions live under one prefix so you never hunt.
;; Was SPC a, moved because Doom binds SPC a to a single command (not prefix),
;; which caused: "Key sequence a k starts with non-prefix key a".
(map! :leader
      (:prefix ("l" . "LLM/AI")
       ;; Inline edits (work on selected region)
       :desc "Rewrite (custom prompt)" "k" #'gptel-rewrite          ; Cmd+K equivalent
       :desc "Refactor"                "r" #'my/ai-refactor
       :desc "Fix bugs"                "f" #'my/ai-fix
       :desc "Optimize"                "o" #'my/ai-optimize
       :desc "Add docstrings"          "d" #'my/ai-document
       :desc "Add type hints"          "y" #'my/ai-typehint
       :desc "Explain (side buffer)"   "e" #'my/ai-explain
       :desc "Write tests"             "t" #'my/ai-write-tests

       ;; Chat
       :desc "Chat (gptel)"            "c" #'gptel
       :desc "Send region to chat"     "s" #'gptel-send
       :desc "Add as context"          "x" #'gptel-add
       :desc "Pick directive/system"   "S" #'gptel-system-prompt

       ;; Tab completion control
       (:prefix ("g" . "ghost-text")
        :desc "Toggle auto suggest"    "t" #'minuet-auto-suggestion-mode
        :desc "Suggest now"            "s" #'minuet-show-suggestion
        :desc "Complete with prompt"   "p" #'minuet-complete-with-minibuffer)

       ;; Agent mode
       (:prefix ("A" . "agent")
        :desc "Claude Code IDE menu"   "c" #'claude-code-ide-menu
        :desc "Start Claude session"   "s" #'claude-code-ide
        :desc "Resume Claude"          "r" #'claude-code-ide-resume
        :desc "Send prompt"            "p" #'claude-code-ide-send-prompt
        :desc "Aider session"          "a" #'aidermacs-transient-menu)

       ;; Git
       (:prefix ("v" . "vcs")
        :desc "AI commit message"      "c" #'my/ai-commit-message)))

;; Magit integration: in commit buffer, `C-c i` writes the message for you.
(after! magit
  (define-key git-commit-mode-map (kbd "C-c i") #'my/ai-commit-message))
