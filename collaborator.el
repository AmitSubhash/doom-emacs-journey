;; -*- lexical-binding: t; -*-
;;
;; COLLABORATOR -- Unified Agentic Workspace for Emacs
;;
;; Primary AI: Claude Code CLI (claude-code-ide + claude-code.el)
;; No API key required -- uses Claude subscription auth.
;;
;; Architecture:
;;   claude-code-ide (config.el)  -> MCP bridge, diff review, session mgmt
;;   claude-code.el  (config.el)  -> multi-instance CLI runner
;;   agent-shell     (this file)  -> ACP-based Claude shell (needs claude-agent-acp)
;;   mcp.el          (this file)  -> connect Emacs TO external MCP servers
;;   eat / vterm     (this file)  -> terminal tiles for agent output
;;
;; Keybindings: SPC A = agent prefix (SPC a is Doom's org-agenda)
;;

;; -----------------------------------------
;; MCP.EL -- MCP Client
;; M-x mcp-hub  to start/stop/restart servers
;; Keys in hub: s=start, k=stop, r=restart
;; -----------------------------------------
(use-package! mcp
  :defer t
  :commands (mcp-hub)
  :init
  (setq mcp-hub-servers
        '(("filesystem"
           :command "npx"
           :args ("-y" "@modelcontextprotocol/server-filesystem"
                  "/Users/amit/"))
          ("fetch"
           :command "uvx"
           :args ("mcp-server-fetch")))))


;; -----------------------------------------
;; EAT -- Fast Terminal Emulator
;; SPC A e  open eat (local)
;; SPC A s  open eat SSH'd to BigRed200
;; SPC A r  open eat SSH'd to br200 + start Claude Code
;; Pure elisp, 3x faster than term-mode
;; -----------------------------------------
(use-package! eat
  :defer t
  :commands (eat eat-other-window)
  :config
  (setq eat-kill-buffer-on-exit t
        eat-enable-mouse t))

(defvar br200-ssh-command "ssh br200"
  "SSH command to connect to BigRed200.")

(defvar br200-claude-init-commands
  (concat "export NVM_DIR=/N/slate/atsubhas/claude-code/nvm && "
          "source $NVM_DIR/nvm.sh && "
          "claude")
  "Commands to initialize Claude Code on br200 after SSH.")

(defun br200--send-init-commands (buffer)
  "Send BR200 Claude initialization commands to terminal BUFFER."
  (run-at-time 3 nil
               (lambda ()
                 (when (buffer-live-p buffer)
                   (when-let ((proc (get-buffer-process buffer)))
                     (process-send-string
                      proc
                      (concat br200-claude-init-commands "\n")))))))

(defun br200/eat (&optional start-claude)
  "Open an eat terminal SSH'd into BigRed200.
With prefix arg (C-u) or START-CLAUDE non-nil, also launch Claude Code.
Falls back to vterm if eat is unavailable."
  (interactive "P")
  (let* ((buf-name (if start-claude "*br200:claude*" "*br200*"))
         (existing (get-buffer buf-name))
         (ssh-args (split-string-and-unquote br200-ssh-command)))
    (if (and existing (buffer-live-p existing))
        (pop-to-buffer existing)
      (cond
       ((progn (require 'eat nil t) (fboundp 'eat-make))
        (let ((buf (apply #'eat-make buf-name (car ssh-args) nil (cdr ssh-args))))
          (with-current-buffer buf
            (rename-buffer buf-name t))
          (when start-claude
            (br200--send-init-commands buf))
          (pop-to-buffer buf)))
       ((fboundp '+vterm/here)
        (let ((default-directory "~"))
          (+vterm/here nil)
          (rename-buffer buf-name t)
          (vterm-send-string br200-ssh-command)
          (vterm-send-return)
          (when start-claude
            (br200--send-init-commands (current-buffer)))))
       (t
        (user-error "Neither eat nor vterm is available"))))))

(defun br200/eat-claude ()
  "Open an eat terminal SSH'd into br200 and start Claude Code."
  (interactive)
  (br200/eat t))

(defun br200/dired ()
  "Open a TRAMP dired buffer for BigRed200 home directory."
  (interactive)
  (dired "/ssh:br200:/N/u/atsubhas/BigRed200/"))

(defun br200/dired-slate ()
  "Open a TRAMP dired buffer for BigRed200 slate storage."
  (interactive)
  (dired "/ssh:br200:/N/slate/atsubhas/"))


;; -----------------------------------------
;; AGENT-SHELL -- Run CLI Agents via ACP
;; SPC A a  open agent shell
;;
;; Requires: npm install -g @zed-industries/claude-agent-acp
;; Uses login-based auth (same as Claude Code subscription).
;; -----------------------------------------
(use-package! acp
  :defer t)

(use-package! agent-shell
  :defer t
  :commands (agent-shell agent-shell-anthropic-start-claude-code)
  :config
  ;; Use login auth (no API key needed, uses Claude subscription).
  ;; Inherit the Emacs environment so ACP helpers can see PATH/HOME.
  (require 'agent-shell-anthropic nil t)
  (setq agent-shell-display-function #'pop-to-buffer
        agent-shell-anthropic-claude-environment
        (agent-shell-make-environment-variables :inherit-env t)
        agent-shell-preferred-agent-config
        (agent-shell-anthropic-make-claude-code-config)))


;; -----------------------------------------
;; COLLABORATOR WORKSPACE LAYOUT
;;
;;  +----------+----------+----------+
;;  |          |          |          |
;;  |  Code    |  Claude  |  Notes   |
;;  |  Editor  |  Code    |  (org)   |
;;  |          |          |          |
;;  |          |          |          |
;;  +----------+----------+----------+
;;
;; SPC A w  to activate
;; -----------------------------------------
(defun collaborator--notes-file ()
  "Return path to Collaborator scratch notes file."
  (expand-file-name "collaborator.org" org-directory))

(defun collaborator--find-agent-buffer ()
  "Find the best available agent buffer to display.
Priority: claude-code-ide > claude-code > agent-shell."
  (or
   ;; claude-code-ide buffers (pattern: *claude-code-ide*)
   (cl-find-if (lambda (b)
                 (string-match-p "\\*claude-code" (buffer-name b)))
               (buffer-list))
   ;; agent-shell Claude Code buffer
   (get-buffer "*Claude Code*")
   ;; any agent-shell buffer
   (get-buffer "*agent-shell*")))

(defun collaborator/workspace ()
  "Set up the Collaborator agentic workspace layout.
Three columns: code editor | claude | notes.
If no Claude session exists, starts one via claude-code-ide."
  (interactive)
  (delete-other-windows)
  (let* ((code-win (selected-window))
         (notes-width (max 28 (min 42 (floor (* (frame-width) 0.18)))))
         (agent-width (max 72
                           (min (if (boundp 'claude-code-ide-window-width)
                                    claude-code-ide-window-width
                                  88)
                                (floor (* (frame-width) 0.28)))))
         (agent-win (split-window-right (+ agent-width notes-width)))
         (notes-win (split-window agent-win notes-width 'right)))

    ;; Middle: Claude agent panel
    (select-window agent-win)
    (let ((agent-buf (collaborator--find-agent-buffer)))
      (if agent-buf
          (switch-to-buffer agent-buf)
        (when (fboundp 'claude-code-ide)
          (claude-code-ide))))

    ;; Notes panel (right column)
    (select-window notes-win)
    (find-file (collaborator--notes-file))

    ;; Return focus to code editor
    (select-window code-win)
    (message "Collaborator workspace active  [SPC A q] to close")))

(defun collaborator/project-workspace ()
  "Create or switch to a project workspace, then open the collaborator layout."
  (interactive)
  (let* ((project (ignore-errors (project-current)))
         (name (if project
                   (file-name-nondirectory
                    (directory-file-name (project-root project)))
                 "agent")))
    (when (fboundp '+workspace-switch)
      (+workspace-switch name t))
    (collaborator/workspace)))


(defun collaborator/toggle-agent-panel ()
  "Toggle the Claude Code agent panel on the right side."
  (interactive)
  (let ((agent-buf (collaborator--find-agent-buffer)))
    (if (and agent-buf (get-buffer-window agent-buf))
        (delete-window (get-buffer-window agent-buf))
      (let ((win (split-window-right)))
        (if agent-buf
            (set-window-buffer win agent-buf)
          (select-window win)
          (when (fboundp 'claude-code-ide)
            (claude-code-ide)))))))


(defun collaborator/close-panels ()
  "Close all Collaborator panels, keep only the code buffer."
  (interactive)
  (delete-other-windows)
  (message "Collaborator panels closed."))


;; -----------------------------------------
;; COLLABORATOR KEYBINDINGS
;; SPC A = agent commands (SPC a is Doom's org-agenda under notes)
;;
;; Existing claude-code bindings (C-c c *) are unchanged:
;;   C-c C-'  transient menu (claude-code-ide)
;;   C-c c c  start/toggle session
;;   C-c c n  new named instance
;;   C-c c p  send prompt
;;   C-c c s  list sessions
;;   C-c c t  toggle window
;;   C-c c @  send selection
;; -----------------------------------------
(map! :leader
      (:prefix ("A" . "agent")
       ;; workspace (the main draw)
       :desc "Collaborator layout"   "w" #'collaborator/workspace
       :desc "Project cockpit"       "W" #'collaborator/project-workspace
       :desc "Toggle agent panel"    "t" #'collaborator/toggle-agent-panel
       :desc "Close all panels"      "q" #'collaborator/close-panels
       :desc "Claude Code IDE"       "c" #'claude-code-ide
       :desc "gptel chat"            "g" #'my/gptel-open
       :desc "gptel menu"            "m" #'my/gptel-open-menu
       :desc "Rewrite region"        "R" #'my/gptel-rewrite-region
       :desc "gptel MCP tools"       "M" #'gptel-mcp-connect

       ;; agent-shell (ACP -- needs claude-agent-acp)
       :desc "Agent shell (ACP)"     "a" #'agent-shell

       ;; mcp
       :desc "MCP hub"               "h" #'mcp-hub

       ;; terminals (local)
       :desc "Eat terminal"          "e" #'eat
       :desc "Vterm"                 "v" #'+vterm/toggle

       ;; BigRed200 remote
       :desc "BR200 shell"           "s" #'br200/eat
       :desc "BR200 + Claude"        "r" #'br200/eat-claude
       :desc "BR200 dired (home)"    "d" #'br200/dired
       :desc "BR200 dired (slate)"   "D" #'br200/dired-slate))


;; -----------------------------------------
;; AUTO-CREATE COLLABORATOR NOTES FILE
;; -----------------------------------------
(defun collaborator/ensure-notes-file ()
  "Create the collaborator notes file if it doesn't exist."
  (let ((f (collaborator--notes-file)))
    (unless (file-exists-p f)
      (with-temp-file f
        (insert "#+title: Collaborator Notes\n"
                "#+startup: overview\n\n"
                "* Scratch\n\n"
                "* Agent Logs\n\n"
                "* References\n\n")))))

(add-hook 'doom-after-init-hook #'collaborator/ensure-notes-file)
