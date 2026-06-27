;;; typora-themes.el -*- lexical-binding: t; -*-
;;
;; Faithful Emacs ports of the Typora writing themes Amit uses, generated from
;; their own CSS (~/Library/Application Support/abnerworks.Typora/themes/).
;; Each theme changes the frame background, the proportional prose font
;; (rendered through `variable-pitch' + mixed-pitch), and the heading fonts,
;; sizes and colours per level -- mirroring how each Typora theme styles a
;; document. Works in both `markdown-mode' and `org-mode'.
;;
;; Switch with `my/typora-theme' (SPC t y). These coexist with the Doom themes;
;; switching back to a dev theme via SPC t T / SPC t L cleanly reverts.
;;
;; Spec source (verified against the CSS):
;;   github    white  #fff  / Open Sans         (sans, his active light)
;;   newsprint cream  #f3f2ee / PT Serif         (newspaper serif)
;;   night     dark   #363b40 / Helvetica Neue   (his active dark)
;;   pixyll    white  #fff  / Merriweather body + Lato headings
;;   gothic    paper  #fcfcfc / Didact Gothic + TeX Gyre Adventor (geometric)
;;   whitey    white  #fefefe / Vollkorn         (serif, dramatic h1)

(require 'cl-lib)

(defun my/typora--font (candidates)
  "Return the first installed family from CANDIDATES, else the last one."
  (or (cl-some (lambda (f) (when (member f (font-family-list)) f)) candidates)
      (car (last candidates))))

(defvar my/typora-theme-specs
  '((typora-github
     :desc "GitHub - Open Sans on white (light)"
     :bg "#ffffff" :fg "#24292e" :region "#c8e1ff" :hl "#f6f8fa"
     :prose ("Open Sans" "Helvetica Neue" "Sans Serif")
     :head  ("Open Sans" "Helvetica Neue" "Sans Serif") :head-weight bold
     :head-fg "#24292e" :h6-fg "#777777"
     :heights (2.25 1.75 1.5 1.25 1.0 1.0)
     :link "#4183c4" :quote "#777777" :quote-bd "#dfe2e5"
     :code-bg "#f3f4f4" :block-bg "#f8f8f8")
    (typora-newsprint
     :desc "Newsprint - PT Serif on cream (newspaper)"
     :bg "#f3f2ee" :fg "#1f0909" :region "#d8d6cf" :hl "#eae8e1"
     :prose ("PT Serif" "Georgia" "Times New Roman") :prose-slant-quote t
     :head  ("PT Serif" "Georgia" "Times New Roman") :head-weight normal
     :head-fg "#1f0909"
     :heights (1.875 1.3125 1.3125 1.125 1.0 1.0)
     :link "#065588" :quote "#656565" :quote-bd "#bababa" :quote-italic t
     :code-bg "#dadada" :block-bg "#dadada")
    (typora-night
     :desc "Night - Helvetica Neue on slate (dark)"
     :bg "#363b40" :fg "#b8bfc6" :region "#4a5159" :hl "#3c4248"
     :prose ("Helvetica Neue" "Open Sans" "Sans Serif")
     :head  ("Lucida Grande" "Helvetica Neue" "Sans Serif") :head-weight normal
     :head-fg "#dedede" :h6-fg "#ffffff"
     :heights (2.5 1.63 1.17 1.12 0.97 0.93)
     :link "#6cb6ff" :quote "#8b9197" :quote-bd "#474d54"
     :code-bg "#2b2f33" :block-bg "#2b2f33")
    (typora-pixyll
     :desc "Pixyll - Merriweather body, Lato headings (light)"
     :bg "#ffffff" :fg "#333333" :region "#d6d2e6" :hl "#f7f7f7"
     :prose ("Merriweather" "Georgia" "Serif")
     :head  ("Lato" "Helvetica Neue" "Sans Serif") :head-weight bold
     :head-fg "#333333"
     :heights (2.0 1.5 1.25 1.13 1.1 1.1)
     :link "#463f5c" :quote "#7a7a7a" :quote-bd "#efefef"
     :code-bg "#f4f4f4" :block-bg "#fafafa")
    (typora-gothic
     :desc "Gothic - Didact Gothic / TeX Gyre Adventor (light)"
     :bg "#fcfcfc" :fg "#2b2b2b" :region "#e6cccc" :hl "#f4f4f4"
     :prose ("Didact Gothic" "Futura" "Avenir Next" "Sans Serif")
     :head  ("TeX Gyre Adventor" "Futura" "Avenir Next" "Sans Serif")
     :head-weight normal :head-fg "#111111"
     :heights (2.2 1.7 1.4 1.2 1.125 1.0)
     :link "#990000" :quote "#6f6f6f" :quote-bd "#9f9f9f"
     :code-bg "#f3f3f3" :block-bg "#fdfdfd")
    (typora-whitey
     :desc "Whitey - Vollkorn serif, dramatic h1 (light)"
     :bg "#fefefe" :fg "#333333" :region "#cfe5f3" :hl "#f5f5f5"
     :prose ("Vollkorn" "Palatino" "Georgia" "Serif")
     :head  ("Vollkorn" "Palatino" "Georgia" "Serif") :head-weight normal
     :head-fg "#2f2f2f"
     :heights (3.0 1.8 1.4 1.2 1.0 1.0)
     :link "#2484c1" :quote "#555555" :quote-bd "#dddddd"
     :code-bg "#f0f0f0" :block-bg "#fafafa"))
  "Specs for the Typora writing themes; see `my/typora--define'.")

(defun my/typora--faces (pl prose head)
  "Build a `custom-theme-set-faces' face list from spec plist PL.
PROSE and HEAD are the resolved (installed) prose and heading families."
  (let* ((bg   (plist-get pl :bg))
         (fg   (plist-get pl :fg))
         (reg  (plist-get pl :region))
         (hl   (plist-get pl :hl))
         (hw   (or (plist-get pl :head-weight) 'bold))
         (hfg  (or (plist-get pl :head-fg) fg))
         (h6fg (or (plist-get pl :h6-fg) hfg))
         (hs   (plist-get pl :heights))
         (link (plist-get pl :link))
         (qt   (plist-get pl :quote))
         (qbd  (plist-get pl :quote-bd))
         (qsl  (if (plist-get pl :quote-italic) 'italic 'normal))
         (cbg  (plist-get pl :code-bg))
         (bbg  (or (plist-get pl :block-bg) cbg))
         ;; heading face spec for level N (0-based); h6 may take its own colour
         (hdr (lambda (n)
                `((t (:family ,head :weight ,hw :height ,(nth n hs)
                      :foreground ,(if (= n 5) h6fg hfg) :slant normal
                      :underline nil :overline nil :box nil))))))
    `((default          ((t (:background ,bg :foreground ,fg))))
      (cursor           ((t (:background ,fg))))
      (region           ((t (:background ,reg :extend t))))
      (hl-line          ((t (:background ,hl :extend t))))
      (fringe           ((t (:background ,bg :foreground ,bg))))
      (vertical-border  ((t (:foreground ,hl :background ,hl))))
      (variable-pitch   ((t (:family ,prose :height 1.0))))
      ;; ---- markdown ----
      (markdown-header-face-1 (,@(funcall hdr 0)))
      (markdown-header-face-2 (,@(funcall hdr 1)))
      (markdown-header-face-3 (,@(funcall hdr 2)))
      (markdown-header-face-4 (,@(funcall hdr 3)))
      (markdown-header-face-5 (,@(funcall hdr 4)))
      (markdown-header-face-6 (,@(funcall hdr 5)))
      (markdown-header-delimiter-face ((t (:family ,head :foreground ,qbd :height 0.9 :weight ,hw))))
      (markdown-header-rule-face      ((t (:foreground ,qbd))))
      (markdown-blockquote-face ((t (:foreground ,qt :slant ,qsl))))
      (markdown-pre-face        ((t (:background ,bbg :foreground ,fg))))
      (markdown-code-face       ((t (:background ,cbg :foreground ,fg :extend t))))
      (markdown-inline-code-face ((t (:background ,cbg :foreground ,fg))))
      (markdown-link-face       ((t (:foreground ,link))))
      (markdown-url-face        ((t (:foreground ,link))))
      (markdown-list-face       ((t (:foreground ,fg :weight bold))))
      (markdown-bold-face       ((t (:foreground ,fg :weight bold))))
      (markdown-italic-face     ((t (:foreground ,fg :slant italic))))
      (markdown-markup-face     ((t (:foreground ,qbd))))
      ;; ---- org ----
      (org-document-title ((t (:family ,head :weight ,hw :height 1.8 :foreground ,hfg))))
      (org-document-info  ((t (:foreground ,qt))))
      (org-level-1 (,@(funcall hdr 0)))
      (org-level-2 (,@(funcall hdr 1)))
      (org-level-3 (,@(funcall hdr 2)))
      (org-level-4 (,@(funcall hdr 3)))
      (org-level-5 (,@(funcall hdr 4)))
      (org-level-6 (,@(funcall hdr 5)))
      (org-quote   ((t (:foreground ,qt :slant ,qsl :extend t))))
      (org-block   ((t (:background ,bbg :extend t))))
      (org-block-begin-line ((t (:background ,bbg :foreground ,qbd :extend t))))
      (org-block-end-line   ((t (:background ,bbg :foreground ,qbd :extend t))))
      (org-code    ((t (:background ,cbg :foreground ,fg))))
      (org-verbatim ((t (:background ,cbg :foreground ,fg))))
      (org-link    ((t (:foreground ,link :underline t))))
      (org-table   ((t (:foreground ,fg)))))))

(defun my/typora--define (spec)
  "Declare one Typora theme from SPEC (an entry of `my/typora-theme-specs')."
  (let* ((name  (car spec))
         (pl    (cdr spec))
         (prose (my/typora--font (plist-get pl :prose)))
         (head  (my/typora--font (plist-get pl :head)))
         (feat  (intern (concat (symbol-name name) "-theme"))))
    (custom-declare-theme name feat (plist-get pl :desc))
    (put name 'theme-settings nil)
    (apply #'custom-theme-set-faces name (my/typora--faces pl prose head))
    (provide-theme name)
    name))

(defun my/typora--define-all ()
  "Declare every Typora theme. Safe to call after fonts are available."
  (mapc #'my/typora--define my/typora-theme-specs))

(defun my/typora--apply-chrome (pl)
  "Force the frame chrome to Typora spec PL via `set-face-attribute'.
This overrides the charcoal palette pinned in the `user' theme (which
otherwise outranks any theme), so the window background actually becomes
the Typora colour. Applies to all frames. Dev themes restore the charcoal
palette by recalculating these faces (see `my/load-or-enable-theme')."
  (let* ((bg  (plist-get pl :bg))
         (fg  (plist-get pl :fg))
         (hl  (plist-get pl :hl))
         (reg (plist-get pl :region))
         (qbd (plist-get pl :quote-bd))
         (mbg (or (plist-get pl :block-bg) (plist-get pl :code-bg) bg)))
    (set-face-attribute 'default nil :background bg :foreground fg)
    (set-face-attribute 'fringe nil :background bg :foreground bg)
    (when (facep 'hl-line)
      (set-face-attribute 'hl-line nil :background hl))
    (set-face-attribute 'region nil :background reg)
    (set-face-attribute 'cursor nil :background fg)
    (set-face-attribute 'vertical-border nil :foreground hl :background hl)
    (when (facep 'solaire-default-face)
      (set-face-attribute 'solaire-default-face nil :background bg :foreground fg))
    (when (facep 'solaire-fringe-face)
      (set-face-attribute 'solaire-fringe-face nil :background bg :foreground bg))
    (when (facep 'line-number)
      (set-face-attribute 'line-number nil :background bg :foreground qbd))
    (when (facep 'line-number-current-line)
      (set-face-attribute 'line-number-current-line nil
                          :background hl :foreground fg :weight 'bold))
    (set-face-attribute 'mode-line nil :background mbg :foreground fg
                        :box `(:line-width 6 :color ,mbg))
    (when (facep 'mode-line-inactive)
      (set-face-attribute 'mode-line-inactive nil :background bg :foreground qbd
                          :box `(:line-width 6 :color ,bg)))))

(defvar my/typora-current nil "Currently active Typora theme symbol, if any.")

;;;###autoload
(defun my/typora-theme (&optional name)
  "Switch to a Typora writing theme NAME and turn on the writing layout.
Disables other themes first so the background/fonts swap cleanly."
  (interactive)
  (unless (get (caar my/typora-theme-specs) 'theme-feature)
    (my/typora--define-all))
  (let ((name (or name
                  (intern (completing-read
                           "Typora theme: "
                           (mapcar (lambda (s)
                                     (cons (symbol-name (car s)) (car s)))
                                   my/typora-theme-specs)
                           nil t nil nil
                           (when my/typora-current
                             (symbol-name my/typora-current)))))))
    (mapc #'disable-theme custom-enabled-themes)
    (enable-theme name)
    (my/typora--apply-chrome (cdr (assq name my/typora-theme-specs)))
    (setq my/typora-current name)
    ;; turn on the Typora reading layout in this buffer if it is prose
    (when (derived-mode-p 'markdown-mode 'org-mode 'text-mode)
      (when (fboundp 'mixed-pitch-mode) (mixed-pitch-mode 1))
      (when (fboundp 'olivetti-mode) (olivetti-mode 1))
      (visual-line-mode 1))
    (message "Typora: %s" name)))

;; Declare them now so `enable-theme'/cycling find them. font-family-list is
;; only populated under a GUI frame, so resolve lazily on first graphical frame.
(if (and (display-graphic-p) (font-family-list))
    (my/typora--define-all)
  (add-hook 'server-after-make-frame-hook #'my/typora--define-all)
  (add-hook 'window-setup-hook #'my/typora--define-all))

(provide 'typora-themes)
;;; typora-themes.el ends here
