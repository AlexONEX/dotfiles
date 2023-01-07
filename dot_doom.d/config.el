;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
(setq user-full-name "Alex"
      user-mail-address "a.schwartzmann@hotmail.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom:
;;
;; - `doom-font' -- the primary font to use
;; - `doom-variable-pitch-font' -- a non-monospace font (where applicable)
;; - `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;; - `doom-unicode-font' -- for unicode glyphs
;; - `doom-serif-font' -- for the `fixed-pitch-serif' face
;;
;; See 'C-h v doom-font' for documentation and more examples of what they
;; accept. For example:
;;
;;(setq doom-font (font-spec :family "Fira Code" :size 12 :weight 'semi-light)
;;      doom-variable-pitch-font (font-spec :family "Fira Sans" :size 13))
;;
;; If you or Emacs can't find your font, use 'M-x describe-font' to look them
;; up, `M-x eval-region' to execute elisp code, and 'M-x doom/reload-font' to
;; refresh your font settings. If Emacs still can't find your font, it likely
;; wasn't installed correctly. Font issues are rarely Doom issues!

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doo-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
;;(setq doom-theme 'dracula)
(setq doom-theme 'doom-nord)

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
;; (setq display-line-numbers-type t)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/Documents/")


;; Whenever you reconfigure a package, make sure to wrap your config in an
;; `after!' block, otherwise Doom's defaults may override your settings. E.g.
;;
;;   (after! PACKAGE
;;     (setq x y))
;;
;; The exceptions to this rule:
;;
;;   - Setting file/directory variables (like `org-directory')
;;   - Setting variables which explicitly tell you to set them before their
;;     package is loaded (see 'C-h v VARIABLE' to look up their documentation).
;;   - Setting doom variables (which start with 'doom-' or '+').
;;
;; Here are some additional functions/macros that will help you configure Doom.
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;; Alternatively, use `C-h o' to look up a symbol (functions, variables, faces,
;; etc).
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they a
(setq! doom-unicode-font (font-spec :family "JetBrainsMono Nerd Font" :size 12))
(setq gc-cons-threshold 20000000)

(setq make-backup-files nil)
(setq large-file-warning-threshold 20000000)

(setq sentence-end-double-space nil)
(fset 'yes-or-no-p 'y-or-n-p)

(display-time-mode t)


(setq backup-directory-alist
      `((".*" . ,temporary-file-directory)))
(setq auto-save-file-name-transforms
      `((".*" ,temporary-file-directory t)))

(use-package! copilot
  :hook (prog-mode . copilot-mode)
  :bind (("C-TAB" . 'copilot-accept-completion-by-word)
         ("C-<tab>" . 'copilot-accept-completion-by-word)
         :map copilot-completion-map
         ("<tab>" . 'copilot-accept-completion)
         ("TAB" . 'copilot-accept-completion)))

(use-package org
  :requires (ob-core org-agenda org-capture ox ox-md)
  :mode ("\\.org\\'" . org-mode)
  :commands (org-babel-do-load-languages org-demote-subtree org-promote-subtree)
  :bind (:map org-mode-map
         ("<M-right>" . org-demote-subtree)
         ("<M-left>" . org-promote-subtree))
  :config
  (setq org-export-backends '(ascii html icalendar latex odt md))
  (setq org-src-fontify-natively t)
  (setq org-log-done 'time)
  (setq org-html-doctype "html5")
  (setq org-export-headline-levels 6)
  (setq org-export-with-smart-quotes t)
  (setq org-adapt-indentation nil)
  (setq org-edit-src-content-indentation 0)

  ;; Custom TODO keywords
  (setq org-todo-keywords
        '((sequence "TODO(t)" "NEXT(n)" "|" "DONE(d!)" "CANCELED(c@)")))
  (setq org-todo-keyword-faces
        '(("TODO" :foreground "red" :weight bold)
          ("NEXT :foreground "blue :weight bold)
          ("DONE :foreground "forest green :weight bold)
          ("CANCELED" :foreground "forest green" :weight bold)))

  ;; setup org-capture
  ;; `M-x org-capture' to add notes. `C-u M-x org-capture' to visit file
  (setq org-capture-templates
        `(("t" "Tasks" entry (file ,(concat org-directory "/todo.org"))
           "* TODO %?\n %U\n  %i\n  %a")
          ("n" "Notes" entry (file ,(concat org-directory "/notes.org"))
           "* %?\n %U\n %i\n")))

  ;; setup org-agenda
  (setq org-agenda-files (list org-directory))
  (setq org-agenda-window-setup 'current-window)

  ;; Set up babel source-block execution
  (org-babel-do-load-languages
   'org-babel-load-languages
   '((emacs-lisp . t)
     (python . t)
     (haskell . t)
     (C . t)
     (shell . t)))

  ;; Set up latex
  (setq org-export-with-LaTeX-fragments t)
  (setq org-preview-latex-default-process 'imagemagick)

  ;; local variable for keeping track of pdf-process options
  (setq pdf-processp nil)

  ;; Prevent Weird LaTeX class issue
  (unless (boundp 'org-latex-classes)
    (setq org-latex-classes nil))
  (add-to-list 'org-latex-classes
               '("per-file-class"
                 "\\documentclass{article}
                      [NO-DEFAULT-PACKAGES]
                      [EXTRA]")))

;; Other config
(defun toggle-org-latex-pdf-process ()
  "Change org-latex-pdf-process variable.

    Toggle from using latexmk or pdflatex. LaTeX-Mk handles BibTeX,
    but opens a new PDF every-time."
  (interactive)
  (if pdf-processp
      ;; LaTeX-Mk for BibTex
      (progn
        (setq pdf-processp nil)
        (setq org-latex-pdf-process
              '("latexmk -pdflatex='pdflatex -shell-escape -interaction nonstopmode -output-directory %o %f' -gg -pdf -bibtex-cond -f %f"))
        (message "org-latex-pdf-process: latexmk"))

    ;; Plain LaTeX export
    (progn
      (setq pdf-processp t)
      (setq org-latex-pdf-process
            '("xelatex -shell-escape -interaction nonstopmode -output-directory %o %f"))
      (message "org-latex-pdf-process: xelatex"))))

;; Turn off mouse interface early in startup to avoid momentary display.
(if (fboundp 'tool-bar-mode) (tool-bar-mode -1))
(if (fboundp 'menu-bar-mode) (menu-bar-mode -1))
(if (fboundp 'scroll-bar-mode) (scroll-bar-mode -1))

;; No splash screen.
(setq inhibit-startup-message t)

;; No fascists.
(setq initial-scratch-message nil)

;; Productive default mode.
(setq initial-major-mode 'org-mode)

;; No alarms.
(setq ring-bell-function 'ignore)

;; Change cursor.
(setq-default cursor-type 'box)
(blink-cursor-mode -1)

;; When on a tab, make the cursor the tab length…
(setq-default x-stretch-cursor t)

;; But never insert tabs…
(set-default 'indent-tabs-mode nil)

;; Except in Makefiles.
(add-hook 'makefile-mode-hook 'indent-tabs-mode)

;; Keep files clean.
(setq-default show-trailing-whitespace t)
(add-hook 'before-save-hook 'whitespace-cleanup)

;; Write backup files to their own directory
(setq backup-by-copying t)
(setq backup-directory-alist
      `(("." . ,(expand-file-name
                 (concat user-emacs-directory "backups")))))

;; Don't write lock-files, I'm the only one here
(setq create-lockfiles nil)

;; Keep emacs Custom-settings in separate file.
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(when (not (file-exists-p custom-file))
  (write-region "" nil custom-file))
(load custom-file)

;; Line Numbers
(global-display-line-numbers-mode t)

;; Fix empty clipboard error.
(setq save-interprogram-paste-before-kill nil)

;; Remove text in active region if inserting text
(delete-selection-mode 1)

;; Don't automatically copy selected text
(setq select-enable-primary nil)

;; Full path in frame title
(setq frame-title-format '(buffer-file-name "%f" ("%b")))

;; Auto refresh buffers when edits occur outside emacs
(global-auto-revert-mode 1)

;; Also auto refresh Dired, but be quiet about it
(setq global-auto-revert-non-file-buffers t)
(setq auto-revert-verbose nil)

;; Quickly copy/move file in Dired
(setq dired-dwim-target t)

;; Show keystrokes in progress
(setq echo-keystrokes 0.1)

;; Move files to trash when deleting
(setq delete-by-moving-to-trash t)

;; Transparently open compressed files
(auto-compression-mode t)

;; Show matching parens
(setq show-paren-delay 0)
(show-paren-mode 1)

;; Auto-close brackets and double quotes
(electric-pair-mode 1)

;; Don't automatically indent lines
(electric-indent-mode -1)

;; Answering just 'y' or 'n' will do
(defalias 'yes-or-no-p 'y-or-n-p)

;; UTF-8 please
(setq locale-coding-system 'utf-8)
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)
(set-selection-coding-system 'utf-8)
(prefer-coding-system 'utf-8)

;; Always display line and column numbers
(setq line-number-mode t)
(setq column-number-mode t)

;; Wrap lines at 80 characters wide, not 72
(setq fill-column 80)

;; Smooth Scroll
(setq mouse-wheel-scroll-amount '(1 ((shift) .1))) ; one line at a time

;; Scroll one line when hitting bottom of window
(setq scroll-conservatively 10000)

;; Navigate sillycased words
(global-subword-mode 1)

;; Word wrap (t is no wrap, nil is wrap)
(setq-default truncate-lines nil)

;; Sentences do not need double spaces to end. Period.
(set-default 'sentence-end-double-space nil)

;; Don't use shift to mark things
(setq shift-select-mode nil)

;; eval-expression-print-level needs to be set to nil (turned off) so
;; that you can always see what's happening.
(setq eval-expression-print-level nil)

;; Allow clipboard from outside emacs
(setq select-enable-clipboard t
      save-interprogram-paste-before-kill t
      apropos-do-all t
      mouse-yank-at-point t)

;; Improve performance of very long lines
(setq-default bidi-display-reordering 'left-to-right)

;; Automatically load latex-preview-pane
(latex-preview-pane-enable)
