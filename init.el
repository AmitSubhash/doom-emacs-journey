;; -*- lexical-binding: t; -*-
;;
;; DOOM EMACS — init.el
;; Drop this into ~/.doom.d/init.el
;; Run `doom sync` after any changes here
;;

(doom! :input

       :completion
       (corfu +orderless)       ; lightweight, fast autocomplete
       (vertico +icons)         ; better minibuffer search

       :ui
       doom                     ; doom UI defaults
       doom-dashboard           ; splash screen
       (emoji +unicode)
       hl-todo                  ; highlight TODO/FIXME/NOTE
       modeline                 ; status bar
       ophints                  ; visual hints for operations
       (popup +defaults)        ; smart popup management
       (treemacs +lsp)          ; file tree sidebar
       unicode
       (vc-gutter +pretty)      ; git gutter in margin
       vi-tilde-fringe          ; tilde on empty lines
       (window-select +numbers)
       workspaces               ; tab-based workspaces (SPC TAB)
       zen                      ; distraction-free writing mode

       :editor
       (evil +everywhere)       ; vim keybindings throughout
       file-templates
       fold
       (format +onsave)         ; auto-format on save
       snippets
       word-wrap

       :emacs
       (dired +icons)           ; file manager
       electric
       (ibuffer +icons)
       (undo +tree)             ; visual undo history
       vc                       ; version control integration

       :term
       vterm                    ; proper terminal inside Emacs

       :checkers
       syntax                   ; live syntax checking
       (spell +aspell)          ; spell check

       :tools
       (debugger +lsp)
       (eval +overlay)          ; run code inline
       (lookup +dictionary +docsets)
       lsp                      ; language server protocol
       magit                    ; git interface (the best git UI anywhere)
       pdf                      ; read PDFs inside Emacs
       rgb                      ; color previews

       :os
       (:if IS-MAC macos)       ; mac-specific fixes
       tty

       :lang
       (org                     ; THE killer feature
        +roam2                  ; zettelkasten-style linked notes
        +pretty                 ; prettier org with icons
        +journal                ; daily journal entries
        +dragndrop              ; drag images into org files
        +hugo                   ; export to Hugo blog if you want
        +noter                  ; annotate PDFs with org notes
        +pomodoro               ; focus timer built in
        +present)               ; presentations from org files
       (python                  ; Python — your main research language
        +lsp
        +pyright)               ; fast type checking
       (javascript +lsp)
       (markdown +grip)         ; preview markdown in browser
       (sh +lsp)                ; shell scripts
       (json +lsp)
       (yaml +lsp)
       (latex                   ; for papers
        +latexmk
        +cdlatex
        +lsp)

       :email
       ;; Uncomment when ready to set up email:
       ;; (mu4e +org +gmail)

       :app
       calendar
       (rss +org)               ; RSS feeds in Emacs/org

       :config
       (default +bindings +smartparens))
