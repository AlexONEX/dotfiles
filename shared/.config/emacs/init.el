;;; init.el --- -*- lexical-binding: t; no-byte-compile: t; -*-

(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)

;; Keep Custom's writes (package-selected-packages, etc.) out of this
;; git-tracked symlink. custom.el lives in the real ~/.config/emacs, not the repo.
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(load custom-file t)

(require 'use-package)
(setq use-package-always-ensure t)
;; Per-package load timings -> `M-x use-package-report'. Built-in, no cost at runtime.
(setq use-package-compute-statistics t)

;; No GC during startup (avoids pauses mid-init); restore a sane 64MB afterwards.
;; A small read-process-output-max throttles rg/eglot output.
(setq gc-cons-threshold most-positive-fixnum
      read-process-output-max (* 4 1024 1024))    ; 4MB
(add-hook 'emacs-startup-hook
          (lambda () (setq gc-cons-threshold (* 64 1024 1024))))  ; 64MB steady-state

;; Silence native-comp first-compile warning noise.
(setq native-comp-async-report-warnings-errors 'silent)

;; A GUI launched from the .app/dock starts with a bare PATH and can't find
;; rg/fd/git/etc. exec-path-from-shell imports the real zsh PATH into Emacs.
(use-package exec-path-from-shell
  :init (setq exec-path-from-shell-arguments nil)   ; no -i: faster, reads .zshenv
  :config (exec-path-from-shell-initialize))

;; The GUI instance (Emacs.app) runs the server; `ec` (emacsclient -t) attaches
;; terminal frames -> shared buffers. On macOS the headless daemon can't reach
;; the WindowServer, so the GUI is the server.
(require 'server)
(unless (server-running-p) (server-start))

;; GUI font: without this the frame uses the default (Menlo) and nerd icons
;; render broken. Set via default-frame-alist so frames created by the .app /
;; emacsclient -c pick it up.
(add-to-list 'default-frame-alist '(font . "CaskaydiaCove Nerd Font Mono-14"))
;; Maximized (fills the screen, not native fullscreen which hides the bar).
(add-to-list 'default-frame-alist '(fullscreen . maximized))

(setq inhibit-startup-screen t)
(when (fboundp 'menu-bar-mode) (menu-bar-mode -1))
(when (fboundp 'tool-bar-mode) (tool-bar-mode -1))
(when (fboundp 'scroll-bar-mode) (scroll-bar-mode -1))

;; Scroll one line at a time instead of the default half-page recenter jump
(setq scroll-conservatively 101
      scroll-margin 3
      scroll-step 1)
(pixel-scroll-precision-mode 1)  ; smooth pixel scrolling (mouse/trackpad)

(global-display-line-numbers-mode 1)
(setq display-line-numbers-type 'relative)
(column-number-mode 1)

(setq backup-directory-alist `(("." . ,(expand-file-name "backups" user-emacs-directory))))
(setq create-lockfiles nil)
(let ((dir (expand-file-name "auto-save/" user-emacs-directory)))
  (make-directory dir t)
  (setq auto-save-file-name-transforms `((".*" ,dir t))))
(setq help-window-select t)
(setq python-indent-guess-indent-offset-verbose nil)
(setq-default indent-tabs-mode nil)
(setq-default tab-width 4)

(use-package xclip
  :config
  (xclip-mode 1))

(use-package evil
  :init
  (setq evil-want-keybinding nil)
  :config
  (evil-mode 1))

(use-package evil-collection
  :after evil
  :config
  (evil-collection-init))

(defun al-hover-at-point ()
  (interactive)
  (cond
   ((or (bound-and-true-p eglot--managed-mode) (bound-and-true-p lsp-mode))
    (let ((buf (ignore-errors (eldoc-doc-buffer))))
      (if (buffer-live-p buf)
          (select-window (display-buffer buf))
        (message "No hover info here"))))
   ((symbol-at-point) (describe-symbol (symbol-at-point)))
   (t (call-interactively #'describe-symbol))))

(with-eval-after-load 'evil
  (evil-define-key 'normal 'global (kbd "K") #'al-hover-at-point))

(defun al-reload-config ()
  (interactive)
  (load-file user-init-file))

(defun al-quit ()
  "Close the current window; if it is the last one, close the client frame
\(keeping the daemon alive) or kill a standalone Emacs."
  (interactive)
  (if (one-window-p)
      (save-buffers-kill-terminal)
    (delete-window)))

(use-package general
  :config
  (general-create-definer al-define-leader-key
    :states '(normal visual)
    :keymaps 'override
    :prefix ",")
  (general-create-definer al-define-localleader-key
    :states '(normal visual)
    :keymaps 'override
    :prefix "SPC")
  (al-define-leader-key
    "w" '(save-buffer :which-key "save")
    "q" '(al-quit :which-key "close window/frame")
    "rr" '(al-reload-config :which-key "reload init"))
  (al-define-localleader-key
    "e" '(dired-jump :which-key "explorer")))

;; Dired lists with eza (like the `ls` alias in ~/.zsh/aliases.zsh): eza -al, dirs first.
;; -H adds the link-count column, long-iso/no color keep dired's parser happy;
;; eza-dired reorders/cleans eza columns so dired can parse them.
;; ponytail: eza ignores ls's -t/-S sort flags, so dired's `s` sort toggle is a no-op.
(setq insert-directory-program (expand-file-name "eza-dired" (file-name-directory (file-truename user-init-file)))
      dired-use-ls-dired nil
      dired-listing-switches "-alH --group-directories-first --time-style=long-iso --color=never")

(use-package which-key
  :ensure nil
  :config
  (which-key-mode 1))

(evil-define-command al-mkdir (dir)
  (interactive "<a>")
  (make-directory dir t)
  (when (derived-mode-p 'dired-mode) (revert-buffer)))

(defun al-save-and-quit ()
  (interactive)
  (when (buffer-file-name) (save-buffer))
  (al-quit))

(with-eval-after-load 'evil
  (evil-ex-define-cmd "mkdir" #'al-mkdir)
  (evil-ex-define-cmd "q[uit]" #'al-quit)
  (evil-ex-define-cmd "wq" #'al-save-and-quit))

(use-package vertico
  :init
  (vertico-mode 1))

(use-package orderless
  :init
  (setq completion-styles '(orderless basic)
        completion-category-overrides '((file (styles partial-completion)))))

(use-package marginalia
  :init
  (marginalia-mode 1))

(defun al-find-file ()
  (interactive)
  (if (project-current)
      (project-find-file)
    (consult-fd default-directory)))

(defun al-grep-github ()
  "Ripgrep across all of ~/Github (search content in every project)."
  (interactive)
  (consult-ripgrep (expand-file-name "~/Github/")))

(defun al-find-file-github ()
  "Fuzzy file finder across all of ~/Github (recursive, every project)."
  (interactive)
  (consult-fd (expand-file-name "~/Github/")))

(use-package consult
  :defer t
  :init
  ;; Snappier: defaults are throttle 0.4 / debounce 0.2 / min-input 3 -> feels slow vs fzf.
  (setq consult-async-min-input 2
        consult-async-input-throttle 0.1
        consult-async-input-debounce 0.05
        consult-async-refresh-delay 0.05))
;; Binds top-level (commands autoload consult) so they exist before it loads.
(al-define-leader-key
  "f" '(:ignore t :which-key "find")
  "ff" '(al-find-file :which-key "file (recursive)")
  "fF" '(find-file :which-key "file (browse path)")
  "fg" '(consult-ripgrep :which-key "grep project")
  "fG" '(al-grep-github :which-key "grep all ~/Github")
  "fp" '(project-switch-project :which-key "pick project")
  "fP" '(al-find-file-github :which-key "file across ~/Github")
  "fn" '(dired-create-empty-file :which-key "new empty file (here)")
  "fb" '(consult-buffer :which-key "buffer")
  "fl" '(consult-line :which-key "line in buffer")
  "fs" '(consult-imenu :which-key "file symbols")
  "fS" '(consult-imenu-multi :which-key "project symbols"))
(al-define-localleader-key
  "SPC" '(execute-extended-command :which-key "M-x"))

(use-package corfu
  :init
  (global-corfu-mode 1)
  :config
  (setq corfu-auto t
        corfu-auto-delay 0.1
        corfu-auto-prefix 2
        corfu-cycle t
        corfu-preselect 'first)
  (define-key corfu-map (kbd "RET") nil)
  (define-key corfu-map (kbd "TAB") #'corfu-insert)
  (define-key corfu-map (kbd "C-n") #'corfu-next)
  (define-key corfu-map (kbd "C-b") #'corfu-previous))

(use-package cape
  :init
  (add-to-list 'completion-at-point-functions #'cape-dabbrev)
  (add-to-list 'completion-at-point-functions #'cape-file))

(use-package yasnippet
  :hook (prog-mode . yas-minor-mode))   ; lazy: starts on the first code buffer, not at init
(use-package yasnippet-snippets :after yasnippet)

(use-package yasnippet-capf
  :after (cape yasnippet)
  :init
  (add-to-list 'completion-at-point-functions #'yasnippet-capf))

(use-package evil-commentary
  :after evil
  :config
  (evil-commentary-mode 1))

(use-package evil-mc
  :after evil
  :config
  (global-evil-mc-mode 1)
  (evil-define-key '(normal visual) 'global (kbd "C-n") #'evil-mc-make-and-goto-next-match)
  (evil-define-key '(normal visual) 'global (kbd "C-p") #'evil-mc-make-and-goto-prev-match)
  (al-define-leader-key
    "m" '(:ignore t :which-key "multi-cursor")
    "ma" '(evil-mc-make-all-cursors :which-key "all matches")
    "mq" '(evil-mc-undo-all-cursors :which-key "quit")))

(use-package avy :defer t)
(al-define-localleader-key
  "j" '(avy-goto-char-timer :which-key "jump"))

(use-package diff-hl
  :defer 1
  :config
  (global-diff-hl-mode 1)
  (diff-hl-margin-mode 1)
  (add-hook 'magit-post-refresh-hook #'diff-hl-magit-post-refresh))

(electric-pair-mode 1)

;; copilot-mode turns on via the hook, but the language server starts lazily and
;; loses the race on the first buffer at startup (fails silently -> dead until
;; `copilot-diagnose'). Restart it on mode activation if the connection is down.
(defun al-copilot-ensure-server ()
  "Start the Copilot server when `copilot-mode' turns on and it's not alive."
  (when (and copilot-mode (not (copilot--connection-alivep)))
    (copilot--start-server)))

(use-package copilot
  :hook ((prog-mode . copilot-mode)
         (copilot-mode . al-copilot-ensure-server))
  :init
  (setq copilot-node-executable "/opt/homebrew/bin/node"
        copilot-indent-offset-warning-disable t)   ; silence "no mode-specific indent offset"
  :config
  (define-key copilot-completion-map (kbd "M-l") #'copilot-accept-completion-by-line)
  (define-key copilot-completion-map (kbd "M-L") #'copilot-accept-completion)
  (define-key copilot-completion-map (kbd "M-]") #'copilot-next-completion)
  (define-key copilot-completion-map (kbd "M-[") #'copilot-previous-completion))

(use-package evil-surround
  :after evil
  :config
  (global-evil-surround-mode 1)
  (evil-define-key 'normal evil-surround-mode-map
    "sa" #'evil-surround-region
    "sd" #'evil-surround-delete
    "sr" #'evil-surround-change)
  (which-key-add-key-based-replacements
    "s"  "surround"
    "sa" "add (sa <motion> <char>)"
    "sd" "delete (sd <char>)"
    "sr" "replace (sr <old> <new>)"))

(use-package evil-textobj-tree-sitter
  :after evil
  :config
  (define-key evil-outer-text-objects-map "f" (evil-textobj-tree-sitter-get-textobj "function.outer"))
  (define-key evil-inner-text-objects-map "f" (evil-textobj-tree-sitter-get-textobj "function.inner"))
  (define-key evil-outer-text-objects-map "c" (evil-textobj-tree-sitter-get-textobj "class.outer"))
  (define-key evil-inner-text-objects-map "c" (evil-textobj-tree-sitter-get-textobj "class.inner"))
  (define-key evil-outer-text-objects-map "a" (evil-textobj-tree-sitter-get-textobj "parameter.outer"))
  (define-key evil-inner-text-objects-map "a" (evil-textobj-tree-sitter-get-textobj "parameter.inner"))
  ;; Movement (nvim ]f/[f/]c/[c): jump to next/prev function/class.
  ;; goto-textobj is a command to CALL (unlike get-textobj), so wrap in lambdas.
  (evil-define-key 'normal 'global (kbd "]f")
    (lambda () (interactive) (evil-textobj-tree-sitter-goto-textobj "function.outer")))
  (evil-define-key 'normal 'global (kbd "[f")
    (lambda () (interactive) (evil-textobj-tree-sitter-goto-textobj "function.outer" t)))
  (evil-define-key 'normal 'global (kbd "]c")
    (lambda () (interactive) (evil-textobj-tree-sitter-goto-textobj "class.outer")))
  (evil-define-key 'normal 'global (kbd "[c")
    (lambda () (interactive) (evil-textobj-tree-sitter-goto-textobj "class.outer" t))))

(use-package magit :defer t)
(use-package forge
  :after magit
  :init (setq forge-add-default-bindings nil))
;; Binds top-level (commands autoload magit/forge) so ,g* exist before they load.
(al-define-leader-key
  "g" '(:ignore t :which-key "git")
  "gg" '(magit-status :which-key "status")
  "gb" '(magit-blame :which-key "blame")
  "gl" '(magit-log-current :which-key "log")
  "gp" '(forge-list-pulls :which-key "PRs")
  "gi" '(forge-list-issues :which-key "issues"))

(use-package terraform-mode)

;; SSH via TRAMP. Hosts autocomplete natively with `C-x C-f /ssh:host:`.
;; ControlMaster (connection reuse) is on by default in modern TRAMP, so no config.
;; `,ss` just picks a ~/.ssh/config host with vertico and opens dired there.
;; debian-server's gitstatus prompt ends with an xterm title (ESC ] 0 ; ... BEL) after
;; the `$ `; the stock pattern never matches it and TRAMP spins at 100% CPU forever.
(with-eval-after-load 'tramp
  (setq tramp-shell-prompt-pattern
        "\\(?:^\\|\r\\)[^]#$%>\n]*#?[]#$%>] *\\(\e\\[[0-9;]*[a-zA-Z] *\\|\e\\][0-9];[^\a]*\a\\)*"))
(defun al-ssh-dired ()
  "Open dired on a host from ~/.ssh/config over TRAMP."
  (interactive)
  (require 'tramp)
  (let* ((hosts (seq-uniq (delq nil (mapcar #'cadr (tramp-parse-sconfig "~/.ssh/config")))))
         (host (completing-read "SSH host: " hosts nil t)))
    (dired (format "/ssh:%s:" host))))

(al-define-leader-key
  "s" '(:ignore t :which-key "ssh")
  "ss" '(al-ssh-dired :which-key "host -> dired"))

(defun al-open-init ()
  "Open the Emacs init file."
  (interactive)
  (find-file user-init-file))

(al-define-leader-key
  "o" '(:ignore t :which-key "open / obsidian")
  "oc" '(al-open-init :which-key "init.el"))

;; Java uses lsp-mode + lsp-java (a full jdtls client like VS Code): supports the
;; refactorings jdtls delegates to the client (Change Signature, Extract Interface,
;; ...) that eglot can't do. eglot still owns every other language.
(use-package lsp-mode
  :init (setq lsp-keymap-prefix nil)          ; no default prefix; use our leader
  :hook ((java-ts-mode java-mode) . lsp-deferred)
  :config
  (setq lsp-completion-provider :none          ; use corfu/capf, not company
        lsp-diagnostics-provider :flymake      ; keep flymake, like the rest
        lsp-headerline-breadcrumb-enable nil
        lsp-signature-auto-activate nil
        lsp-enable-symbol-highlighting nil
        ;; anti-freeze: file watchers are the #1 hang on big projects
        lsp-enable-file-watchers nil
        lsp-idle-delay 0.5
        lsp-log-io nil                         ; io logging is very slow
        lsp-lens-enable nil
        lsp-enable-on-type-formatting nil
        lsp-enable-indentation nil))

(use-package lsp-java
  :after lsp-mode
  :init
  ;; lsp-java's own snapshot download (jdt.ls 1.57.0) ships a broken m2e bundle
  ;; (NoClassDefFoundError -> jdtls exits 13, restart loop). Reuse the working
  ;; jdtls (1.61.0) that eglot-java fetched under share/.
  (setq lsp-java-server-install-dir (expand-file-name "share/eclipse.jdt.ls/" user-emacs-directory)))

;; Dispatch the ,c* code bindings to lsp-mode or eglot depending on the buffer,
;; so the same keys work in Java (lsp) and everywhere else (eglot).
(defun al-code-rename ()
  (interactive)
  (call-interactively (if (bound-and-true-p lsp-mode) #'lsp-rename #'eglot-rename)))
(defun al-code-action ()
  (interactive)
  (call-interactively (if (bound-and-true-p lsp-mode) #'lsp-execute-code-action #'eglot-code-actions)))
(defun al-code-format ()
  "Format the buffer. Java/LSP -> lsp-format-buffer; elsewhere try the LSP and
fall back to apheleia (black/ruff/prettier/…) when the server can't format,
e.g. pyright (no documentFormattingProvider)."
  (interactive)
  (cond
   ((bound-and-true-p lsp-mode) (lsp-format-buffer))
   ((ignore-errors (call-interactively #'eglot-format) t))   ; nil if unsupported/no server
   (t (call-interactively #'apheleia-format-buffer))))
(defun al-code-type-def ()
  (interactive)
  (call-interactively (if (bound-and-true-p lsp-mode) #'lsp-find-type-definition #'eglot-find-typeDefinition)))

;; ---- Change Signature for Java (ported from nvim-jdtls) ----
;; lsp-java has no `changeSignature' branch (confirmed upstream), so this refactor
;; is silently dropped. jdtls implements it via java/getChangeSignatureInfo +
;; java/getRefactorEdit; we add the missing client side: fetch the signature,
;; edit it in a buffer, send it back, apply the returned WorkspaceEdit.
(defvar-local al-jcs--target nil "Source buffer to apply the edit to.")
(defvar-local al-jcs--context nil "Code-action params for the pending change.")
(defvar-local al-jcs--info nil "Signature info returned by jdtls.")

(defvar al-jcs-mode-map (make-sparse-keymap)
  "Keymap for the change-signature editor.")

(define-derived-mode al-jcs-mode fundamental-mode "ChangeSig"
  "Edit a Java method signature; \\[al-jcs-apply] applies, \\[al-jcs-cancel] cancels.")

;; Leader keys, mode-scoped: ,s applies, ,c cancels. :major-modes t makes them
;; shadow the global ,c code prefix ONLY inside this buffer (verified: general
;; resolves the mode-scoped override before the global leader).
(with-eval-after-load 'general
  (al-define-leader-key
    :keymaps 'al-jcs-mode-map
    :major-modes t
    "s" '(al-jcs-apply :which-key "apply change signature")
    "c" '(al-jcs-cancel :which-key "cancel")))

(defun al-java-change-signature (action)
  "Entry point: fetch the current signature from jdtls, then open the editor."
  (let ((context (nth 1 (append (lsp:command-arguments? action) nil)))
        (src (current-buffer)))
    (lsp-request-async
     "java/getChangeSignatureInfo" context
     (lambda (info) (al-jcs--open src context info))
     :mode 'detached)))

(defun al-jcs--open (src context info)
  "Open the signature editor for INFO tied to SRC buffer and CONTEXT."
  (let ((buf (get-buffer-create "*java-change-signature*")))
    (with-current-buffer buf
      (al-jcs-mode)
      (setq al-jcs--target src al-jcs--context context al-jcs--info info)
      (erase-buffer)
      (insert "# Change signature.  ,s apply,  ,c cancel  (ESC to normal state first).\n"
              "# One param per line: `[idx] <type> <name>'.  Reorder/rename/retype freely.\n"
              "# Delete a line to drop a param; add a line WITHOUT [idx] for a new one.\n\n"
              (format "method: %s\n" (gethash "methodName" info))
              (format "return: %s\n" (gethash "returnType" info))
              "params:\n")
      (dolist (p (append (gethash "parameters" info) nil))
        (insert (format "  [%d] %s %s\n"
                        (gethash "originalIndex" p)
                        (gethash "type" p) (gethash "name" p))))
      (goto-char (point-min)) (forward-line 4))
    (pop-to-buffer buf)))

(defun al-jcs-cancel ()
  "Abandon the change-signature edit; kill the editor and return to the source."
  (interactive)
  (quit-window t))   ; t = kill buffer, delete its window, refocus the source

(defun al-jcs--collect ()
  "Parse the editor buffer into (METHOD-NAME RETURN-TYPE PARAMS-VECTOR)."
  (let (method ret params)
    (save-excursion
      (goto-char (point-min))
      (while (not (eobp))
        (let ((l (string-trim (buffer-substring-no-properties
                               (line-beginning-position) (line-end-position)))))
          (cond
           ((string-prefix-p "#" l))
           ((string-prefix-p "method:" l) (setq method (string-trim (substring l 7))))
           ((string-prefix-p "return:" l) (setq ret (string-trim (substring l 7))))
           ((string= l "params:"))
           ((string= l ""))
           ((string-match "\\`\\(?:\\[\\([0-9-]+\\)\\]\\)?[ \t]*\\(.+?\\)[ \t]+\\([A-Za-z_][A-Za-z0-9_]*\\)\\'" l)
            (let* ((idx (match-string 1 l))
                   (orig (if idx (string-to-number idx) -1))
                   (name (match-string 3 l))
                   (h (make-hash-table :test 'equal)))
              (puthash "type" (string-trim (match-string 2 l)) h)
              (puthash "name" name h)
              (puthash "originalIndex" orig h)
              (puthash "defaultValue"
                       (if (>= orig 0) ""
                         (read-string (format "Default value for new param `%s': " name) "null"))
                       h)
              (push h params)))))
        (forward-line 1)))
    (list method ret (vconcat (nreverse params)))))

(defun al-jcs-apply ()
  "Send the edited signature to jdtls and apply the resulting edit."
  (interactive)
  (let* ((info al-jcs--info) (context al-jcs--context) (target al-jcs--target)
         (parsed (al-jcs--collect)))
    (quit-window t)   ; kill editor + its window, refocus the source (like C-SPC x)
    ;; Build + send in the Java buffer: the editor buffer has no file, so
    ;; lsp--make-document-formatting-params (needs the document URI) errors there.
    (with-current-buffer target
      (let ((req (list :command "changeSignature"
                       :context context
                       :options (plist-get (lsp--make-document-formatting-params) :options)
                       :commandArguments
                       (vector (gethash "methodIdentifier" info)
                               (lsp-json-bool nil)                        ; is_delegate
                               (or (nth 0 parsed) (gethash "methodName" info))
                               (gethash "modifier" info)                  ; access type
                               (or (nth 1 parsed) (gethash "returnType" info))
                               (nth 2 parsed)                             ; parameters
                               (gethash "exceptions" info)
                               (lsp-json-bool nil)))))                    ; preview
        (lsp-java--apply-edit (lsp-request "java/getRefactorEdit" req))))
    (message "Change signature applied.")))

(with-eval-after-load 'lsp-java
  ;; lsp-java drops changeSignature; intercept it and run our implementation.
  (advice-add
   'lsp-java--apply-refactoring-command :around
   (lambda (orig action)
     (if (string= (car (append (lsp:command-arguments? action) nil)) "changeSignature")
         (al-java-change-signature action)
       (funcall orig action)))))

(defun al-eglot-ensure-deferred ()
  ;; Java is owned by lsp-java, never eglot -> skip it here so the two clients
  ;; don't both manage the buffer.
  (unless (derived-mode-p 'java-mode 'java-ts-mode)
    (let ((buf (current-buffer)))
      (run-with-idle-timer
       0.3 nil
       (lambda ()
         (when (buffer-live-p buf)
           (with-current-buffer buf (eglot-ensure))))))))

(use-package eglot
  :ensure nil
  :hook (prog-mode . al-eglot-ensure-deferred)
  :config
  (setq eglot-sync-connect nil
        eglot-events-buffer-size 0)
  ;; pylsp (not pyright): pyright is type-check only, no refactors. pylsp bundles
  ;; rope (extract method/variable, inline, introduce parameter) + ruff/mypy/black
  ;; plugins -> those show up as ,ca code actions.
  (add-to-list 'eglot-server-programs
               '((python-mode python-ts-mode) . ("pylsp")))
  (add-to-list 'eglot-server-programs
               '((terraform-mode) . ("terraform-ls" "serve")))
  (cl-defmethod eglot-register-capability
    (server (method (eql workspace/didChangeWatchedFiles)) id &key watchers)
    (ignore server method id watchers)))

;; ponytail: alist, add a language when you hit one. Native `compile' gives the
;; output buffer + errant-line navigation for free.
(defvar al-run-commands
  '((python-mode        . "python3")
    (python-ts-mode     . "python3")
    (js-mode            . "node")
    (js-ts-mode         . "node")
    (typescript-ts-mode . "npx tsx")
    (sh-mode            . "bash")
    (bash-ts-mode       . "bash")
    (go-mode            . "go run")
    (go-ts-mode         . "go run"))
  "Major-mode -> interpreter for `al-run-file'.")

(defun al-run-file ()
  "Save and run the current file via `compile'; output in *compilation*."
  (interactive)
  (let ((cmd  (cdr (assq major-mode al-run-commands)))
        (file (buffer-file-name)))
    (unless file (user-error "Buffer is not visiting a file"))
    (unless cmd  (user-error "No run command for %s" major-mode))
    (save-buffer)
    (compile (format "%s %s" cmd (shell-quote-argument file)))))

;; Code binds top-level so ,c* work regardless of eglot/lsp load order.
(al-define-leader-key
  "c" '(:ignore t :which-key "code")
  "cc" '(al-run-file :which-key "run this file")
  "cr" '(al-code-rename :which-key "rename")
  "ca" '(al-code-action :which-key "code action")
  "cd" '(consult-flymake :which-key "list diagnostics (C-u = project)")
  "cf" '(al-code-format :which-key "format")
  "cR" '(xref-find-references :which-key "references")
  "cD" '(al-code-type-def :which-key "type def")
  "ci" '(eglot-inlay-hints-mode :which-key "toggle inlay hints")
  "cl" '(eglot :which-key "start LSP"))

(with-eval-after-load 'evil
  (evil-define-key 'normal 'global (kbd "]d") #'flymake-goto-next-error)
  (evil-define-key 'normal 'global (kbd "[d") #'flymake-goto-prev-error))

(use-package flymake-collection
  :hook (after-init . flymake-collection-hook-setup))

(add-hook 'prog-mode-hook #'flymake-mode)
(add-hook 'yaml-ts-mode-hook #'flymake-mode)

(use-package apheleia
  :defer 1
  :config
  (apheleia-global-mode 1))

(setq treesit-font-lock-level 3)   ; 4 = max, expensive on big TS/TSX; 3 is rich and fast

(use-package treesit-auto
  :config
  (setq treesit-auto-install t)   ; install grammars automatically, no prompt
  (treesit-auto-add-to-auto-mode-alist 'all))

;; Folding: treesit-fold (correct for tree-sitter modes; hideshow breaks
;; because ts modes override forward-sexp). za toggles a single block.
(defun al-fold-java-imports (node _offset)
  "Fold the whole run of consecutive Java import declarations."
  (let* ((parent (treesit-node-parent node))
         (imports (seq-filter (lambda (n) (equal (treesit-node-type n) "import_declaration"))
                              (treesit-node-children parent))))
    (when (cdr imports)
      (cons (treesit-node-end (car imports))
            (treesit-node-end (car (last imports)))))))

(use-package treesit-fold
  :config
  (global-treesit-fold-mode 1)
  (push '(import_declaration . al-fold-java-imports)
        (alist-get 'java-ts-mode treesit-fold-range-alist))
  (with-eval-after-load 'evil
    (evil-define-key 'normal 'global
      "za" #'treesit-fold-toggle
      "zc" #'treesit-fold-close
      "zo" #'treesit-fold-open
      "zR" #'treesit-fold-open-all
      "zM" #'treesit-fold-close-all)))

(defun al-fold-imports-on-open ()
  "Auto-fold the import block when a Java buffer opens."
  (let ((buf (current-buffer)))
    (run-with-idle-timer
     0.2 nil
     (lambda ()
       (when (buffer-live-p buf)
         (with-current-buffer buf
           (when (bound-and-true-p treesit-fold-mode)
             (save-excursion
               (goto-char (point-min))
               (when (re-search-forward "^import " nil t)
                 (ignore-errors (treesit-fold-close)))))))))))

(add-hook 'java-ts-mode-hook #'al-fold-imports-on-open)

(defvar al-dark-theme 'doom-nord)
(defvar al-light-theme 'modus-operandi-tritanopia)
(defvar al-current-theme al-dark-theme)

(defun al-toggle-theme ()
  (interactive)
  (setq al-current-theme
        (if (eq al-current-theme al-dark-theme) al-light-theme al-dark-theme))
  (mapc #'disable-theme custom-enabled-themes)
  (load-theme al-current-theme t)
  (message "Theme: %s" al-current-theme))

(use-package doom-themes)                   ; eager: load-theme needs it at startup
(use-package ef-themes :defer t)            ; only via consult-theme / ,T -> autoloaded
(use-package catppuccin-theme :defer t)

(with-eval-after-load 'doom-themes
  (load-theme al-dark-theme t))

(al-define-leader-key
  "t" '(al-toggle-theme :which-key "toggle dark/light")
  "T" '(consult-theme :which-key "pick theme (preview)"))

(use-package nerd-icons
  ;; Default is "Symbols Nerd Font Mono" (not installed); use the CaskaydiaCove I have.
  :init (setq nerd-icons-font-family "CaskaydiaCove Nerd Font Mono"))

(use-package doom-modeline
  :init
  (doom-modeline-mode 1))

;; Start in ~/Github (scratch, dashboard, find-file, dired begin there).
;; default-directory is buffer-local -> setq-default for new buffers.
(setq-default default-directory (expand-file-name "~/Github/"))
(setq command-line-default-directory (expand-file-name "~/Github/"))

;; Dashboard: repos from the three roots below + commit stats.
(defconst al-repo-roots
  (mapcar #'expand-file-name '("~/Github/Allaria" "~/Github/Gitlab" "~/Github/me")))
(defconst al-repos-per-root 14)
(defconst al-col-width 38)
(defvar-local al-dashboard-col-pos nil
  "Buffer position of the first repo in each column of `al-repo-roots'.")
(defconst al-activity-days 14)

(defun al-root-repos (root)
  "Git repos directly under ROOT, most recently active first."
  (let* ((act (lambda (d) (float-time (or (file-attribute-modification-time
                                           (file-attributes (expand-file-name ".git/logs/HEAD" d)))
                                          0))))
         (repos (seq-filter (lambda (d) (file-exists-p (expand-file-name ".git" d)))
                            (directory-files root t directory-files-no-dot-files-regexp))))
    (sort repos (lambda (a b) (> (funcall act a) (funcall act b))))))

(defun al-commit-counts (repos)
  "Alist (DAY . N) of my commits over the last `al-activity-days' days in REPOS."
  (let ((counts (make-hash-table :test #'equal)))
    (dolist (r repos)
      (with-temp-buffer
        (when (zerop (call-process "git" nil t nil "-C" r "log" "--no-merges"
                                   (format "--since=%d.days" al-activity-days)
                                   "--author=Alex\\|alejandro" "--format=%ad" "--date=short"))
          (dolist (day (split-string (buffer-string) "\n" t))
            (puthash day (1+ (gethash day counts 0)) counts)))))
    (mapcar (lambda (i)
              (let ((day (format-time-string "%F" (time-subtract (current-time) (days-to-time (- al-activity-days 1 i))))))
                (cons day (gethash day counts 0))))
            (number-sequence 0 (1- al-activity-days)))))

(defun al-bar (n biggest)
  (make-string (if (zerop biggest) 0 (max (min 1 n) (round (* 20 (/ (float n) biggest))))) ?█))

(defun al-sparkline (nums)
  (let ((top (max 1 (apply #'max nums))))
    (mapconcat (lambda (n) (string (aref "▁▂▃▄▅▆▇█" (min 7 (floor (* 7 (/ (float n) top))))))) nums "")))

(defun al-dashboard-repos (_list-size)
  "Dashboard item: stats, then one repo column per root in `al-repo-roots'."
  (let* ((all (mapcar (lambda (r) (cons r (al-root-repos r))) al-repo-roots))
         (sizes (mapcar (lambda (x) (length (cdr x))) all))
         (counts (mapcar #'cdr (al-commit-counts (apply #'append (mapcar #'cdr all)))))
         (biggest (apply #'max sizes))
         (shown (mapcar (lambda (x) (seq-take (cdr x) al-repos-per-root)) all))
         (pos (make-list (length all) nil)))
    (insert (format "  %d repos · commits (%dd) %s  %d total\n\n"
                    (apply #'+ sizes) al-activity-days (al-sparkline counts) (apply #'+ counts)))
    (insert "  ")
    (cl-loop for root in all for n in sizes
             do (insert (propertize (format (format "%%-%ds" al-col-width)
                                            (format "%s %s %d" (file-name-nondirectory (car root))
                                                    (al-bar n biggest) n))
                                    'face 'dashboard-heading)))
    (insert "\n")
    (dotimes (row al-repos-per-root)
      (insert "  ")
      (cl-loop for col in shown for i from 0
               do (let ((repo (nth row col)))
                    (when (and repo (zerop row)) (setf (nth i pos) (point)))
                    (if repo
                        (let ((name (truncate-string-to-width (file-name-nondirectory repo) (- al-col-width 2))))
                          (insert-text-button name 'action (lambda (_) (dired repo))
                                              'follow-link t)
                          (insert (make-string (- al-col-width (string-width name)) ?\s)))
                      (insert (make-string al-col-width ?\s)))))
      (insert "\n"))
    (setq al-dashboard-col-pos pos)
    (run-with-idle-timer 0 nil (lambda () (al-dashboard-goto-col 0)))))

(defun al-dashboard-goto-col (i)
  "Jump to the first repo of column I (0 = Allaria, 1 = Gitlab, 2 = me)."
  (when-let* ((p (nth i al-dashboard-col-pos))) (goto-char p)))

(defun al-dashboard-cell (line col)
  "Position of the repo button at LINE / column COL of the grid, or nil."
  (save-excursion
    (goto-char (point-min))
    (and (zerop (forward-line (1- line)))
         (progn (move-to-column col) (button-at (point)))
         (point))))

(defun al-dashboard-step (drow dcol)
  "Move DROW rows / DCOL columns over the repo grid.
Off the grid (e.g. at startup) it lands on the first Allaria repo.
Moving sideways into a shorter column lands on its last repo."
  (let* ((idx (max 0 (floor (- (current-column) 2) al-col-width)))
         (target (+ idx dcol))
         (col (+ 2 (* target al-col-width)))
         (line (line-number-at-pos))
         (dest (and (<= 0 target (1- (length al-repo-roots)))
                    (if (zerop dcol)
                        (al-dashboard-cell (+ line drow) col)
                      (cl-loop for l downfrom line to 1
                               thereis (al-dashboard-cell l col))))))
    (cond ((not (button-at (point))) (al-dashboard-goto-col 0))
          (dest (goto-char dest)))))

(use-package dashboard
  :init
  (setq dashboard-items '((repos . 1))
        dashboard-item-generators '((repos . al-dashboard-repos))
        dashboard-item-names '(("Repos:" . repos))
        dashboard-set-file-icons nil
        dashboard-startup-banner nil)          ; no logo: the space goes to the repo grid
  :config
  ;; dashboard rejects a nil banner; its only caller already skips a nil result.
  (advice-add 'dashboard-choose-banner :around (lambda (f b) (and b (funcall f b))))
  ;; Buffer-local so they beat evil-collection's dashboard-next-line/previous-line,
  ;; which only know dashboard's own widgets, not this grid.
  (add-hook 'dashboard-mode-hook
            (lambda ()
              (dolist (k `(("h" ,(lambda () (interactive) (al-dashboard-step 0 -1)))
                           ("l" ,(lambda () (interactive) (al-dashboard-step 0 1)))
                           ("j" ,(lambda () (interactive) (al-dashboard-step 1 0)))
                           ("k" ,(lambda () (interactive) (al-dashboard-step -1 0)))
                           ("r" ,(lambda () (interactive) (al-dashboard-goto-col 0)))   ; Allaria
                           ("t" ,(lambda () (interactive) (al-dashboard-goto-col 1)))   ; Gitlab
                           ("p" ,(lambda () (interactive) (al-dashboard-goto-col 2))))) ; me
                (evil-local-set-key 'normal (kbd (car k)) (cadr k)))))
  ;; Keep the dashboard (and what you open from it) rooted at ~/Github.
  (add-hook 'dashboard-mode-hook
            (lambda () (setq default-directory (expand-file-name "~/Github/"))))
  (dashboard-setup-startup-hook))

;; Obsidian: one vault, versioned in git, with work/ and personal/ folders.
;; obsidian.el works on the .md files directly (wikilinks, backlinks, tags,
;; daily notes) -> the Obsidian app doesn't need to be running.
(defconst al-vault (expand-file-name "~/Github/me/obsidian/"))

(use-package obsidian
  :init
  (setq elgrep-data-file nil                ; elgrep's saved-search history; unused, and its file triggers a lexical-binding warning
        obsidian-directory al-vault
        obsidian-inbox-directory "inbox"
        obsidian-daily-notes-directory "daily")
  :config
  (global-obsidian-mode 1))

(defun al-note-recent ()
  "Pick among the 30 most recently modified notes."
  (interactive)
  (let* ((files (sort (obsidian-files)
                      (lambda (a b) (time-less-p (file-attribute-modification-time (file-attributes b))
                                                 (file-attribute-modification-time (file-attributes a))))))
         (names (mapcar (lambda (f) (file-relative-name f al-vault)) (seq-take files 30))))
    (find-file (expand-file-name
                (completing-read "Recent note: "
                                 (lambda (str pred action)  ; keep mtime order
                                   (if (eq action 'metadata)
                                       '(metadata (display-sort-function . identity))
                                     (complete-with-action action names str pred)))
                                 nil t)
                al-vault))))

(defun al-vault-dired ()
  (interactive)
  (dired al-vault))

(defun al-note-open-app ()
  "Open the vault in the Obsidian app."
  (interactive)
  (browse-url (concat "obsidian://open?path=" (url-hexify-string (directory-file-name al-vault)))))

(use-package markdown-mode
  :mode ("\\.md\\'" . markdown-mode)
  :init
  (setq markdown-header-scaling t                 ; bigger headings
        markdown-fontify-code-blocks-natively t   ; highlight ```lang blocks
        markdown-enable-wiki-links t
        markdown-list-item-bullets '("●" "○" "◆" "◇"))
  :config
  ;; defcustom resets it on load, so set after (hides ** _ # [[ ]] until the cursor is on them).
  (setq-default markdown-hide-markup t)
  :hook ((markdown-mode . visual-line-mode)
         (markdown-mode . visual-wrap-prefix-mode)
         ;; LSP (marksman: [[link]] / heading completion, go-to-definition,
         ;; diagnostics for broken links) only for notes in the vault.
         (markdown-mode . (lambda ()
                            (when (and buffer-file-name
                                       (string-prefix-p al-vault buffer-file-name))
                              (eglot-ensure))))))

(with-eval-after-load 'eglot
  (add-to-list 'eglot-server-programs '(markdown-mode . ("marksman" "server"))))

(al-define-leader-key
  "od" '(obsidian-daily-note :which-key "obsidian: daily note")
  "on" '(obsidian-capture :which-key "obsidian: new note (inbox)")
  "of" '(obsidian-jump :which-key "obsidian: find note")
  "or" '(al-note-recent :which-key "obsidian: recent notes")
  "os" '(obsidian-search :which-key "obsidian: search text")
  "ot" '(obsidian-find-tag :which-key "obsidian: find by tag")
  "ob" '(obsidian-toggle-backlinks-panel :which-key "obsidian: backlinks")
  "ol" '(obsidian-follow-link-at-point :which-key "obsidian: follow [[link]]")
  "ov" '(al-vault-dired :which-key "obsidian: vault folder (dired)")
  "oa" '(al-note-open-app :which-key "obsidian: open in app"))

;; Tabs = buffers, bufferline.nvim style: a flat global list of all file
;; buffers (not per-window like tab-line's default).
(defun al-tab-line-buffers ()
  (seq-filter (lambda (b)
                (let ((f (buffer-file-name b)))
                  (and f
                       (not (string-prefix-p " " (buffer-name b)))
                       ;; skip emacs-internal files (projects.eld, recentf.eld, autosaves)
                       (not (string-match-p "/\\.\\(emacs\\.d\\|config/emacs\\)/" f))
                       (not (string-suffix-p ".eld" f)))))
              (buffer-list)))
(setq tab-line-tabs-function #'al-tab-line-buffers)
(global-tab-line-mode 1)

;; Tabs are never auto-pruned: they persist until you close them (SPC w u /
;; al-tab-close), and desktop-save restores them across restarts. (Removed the
;; midnight/clean-buffer-list idle sweep that was killing tabs out from under you.)

(defun al-tab-next ()
  "Save (like nvim's save_and_switch) and jump to the next tab."
  (interactive)
  (when (and (buffer-file-name) (buffer-modified-p)) (save-buffer))
  (tab-line-switch-to-next-tab))

(defun al-tab-prev ()
  (interactive)
  (when (and (buffer-file-name) (buffer-modified-p)) (save-buffer))
  (tab-line-switch-to-prev-tab))

(defun al-tab-close ()
  "Kill the current buffer (the tab) and land on the previous one, leaving the rest."
  (interactive)
  (let ((b (current-buffer)))
    (tab-line-switch-to-prev-tab)
    (kill-buffer b)))

(use-package indent-bars
  :init
  (setq indent-bars-prefer-character t)
  :hook
  (prog-mode . indent-bars-mode))

(use-package move-text :defer t)   ; M-k/M-j binds (below) autoload it

(defun al-join-keep-cursor ()
  (interactive)
  (save-excursion (delete-indentation 1)))

(defun al-q-remapped ()
  (interactive)
  (message "q is remapped to Q (record macro)"))

(defun al-yank-buffer ()
  (interactive)
  (kill-ring-save (point-min) (point-max))
  (message "Buffer copied to the kill-ring"))

(defun al-yank-file-path ()
  "Copy the visited file's absolute path to the kill-ring / clipboard."
  (interactive)
  (let ((path (buffer-file-name)))
    (if path (progn (kill-new path) (message "Copied: %s" path))
      (message "Buffer is not visiting a file"))))

(defun al-insert-line-below ()
  (interactive)
  (save-excursion (end-of-line) (newline)))

(defun al-insert-line-above ()
  (interactive)
  (save-excursion (beginning-of-line) (newline)))

(with-eval-after-load 'evil
  (evil-define-key '(normal visual) 'global ";" #'evil-ex)
  (evil-define-key '(normal visual) 'global "H" "^")
  (evil-define-key '(normal visual) 'global "L" "g_")
  (evil-define-key 'normal 'global "J" #'al-join-keep-cursor)
  (evil-define-key 'normal 'global "q" #'al-q-remapped)
  (evil-define-key 'normal 'global "Q" #'evil-record-macro)
  (evil-define-key '(normal visual) 'global (kbd "M-k") #'move-text-up)
  (evil-define-key '(normal visual) 'global (kbd "M-j") #'move-text-down)
  (evil-define-key 'normal 'global "gt" #'tab-line-switch-to-next-tab)
  (evil-define-key 'normal 'global "gT" #'tab-line-switch-to-prev-tab)
  (evil-define-key 'normal 'global (kbd "TAB") #'al-tab-next)     ; terminal
  (evil-define-key 'normal 'global (kbd "<tab>") #'al-tab-next)   ; GUI
  (evil-define-key 'normal 'global (kbd "<backtab>") #'al-tab-prev)
  ;; C-w closes the current mini-tab (browser-style). Drops evil's C-w window
  ;; prefix in normal/motion -- we use C-SPC for splits/panes anyway. Insert-state
  ;; C-w (delete word back) is a different state, so it stays intact.
  (evil-define-key '(normal motion) 'global (kbd "C-w") #'al-tab-close))

(al-define-leader-key
  "y" '(al-yank-buffer :which-key "yank buffer"))
(al-define-localleader-key
  "o" '(al-insert-line-below :which-key "line below")
  "O" '(al-insert-line-above :which-key "line above")
  "y" '(:ignore t :which-key "yank")
  "yp" '(al-yank-file-path :which-key "file path"))

;; Real terminal (libvterm) to live in zsh inside Emacs. Compiles a native
;; module the first time (needs cmake + glibtool, already present).
(defun al-vterm-setup ()
  "Per-buffer vterm tweaks: no line numbers, Nord background like Ghostty."
  (display-line-numbers-mode -1)
  (face-remap-add-relative 'default :background "#2e3440" :foreground "#d8dee9"))

(use-package vterm
  :init (setq vterm-shell "/bin/zsh"
              vterm-max-scrollback 10000
              vterm-timer-delay 0.01)        ; smoother render
  :hook (vterm-mode . al-vterm-setup)
  :config
  ;; ANSI palette = Nord (same as Ghostty) so the colors match.
  (let ((nord '((vterm-color-black         . "#3b4252") (vterm-color-red     . "#bf616a")
                (vterm-color-green         . "#a3be8c") (vterm-color-yellow  . "#ebcb8b")
                (vterm-color-blue          . "#81a1c1") (vterm-color-magenta . "#b48ead")
                (vterm-color-cyan          . "#88c0d0") (vterm-color-white   . "#e5e9f0")
                (vterm-color-bright-black  . "#4c566a") (vterm-color-bright-red     . "#bf616a")
                (vterm-color-bright-green  . "#a3be8c") (vterm-color-bright-yellow  . "#ebcb8b")
                (vterm-color-bright-blue   . "#81a1c1") (vterm-color-bright-magenta . "#b48ead")
                (vterm-color-bright-cyan   . "#8fbcbb") (vterm-color-bright-white   . "#eceff4"))))
    (dolist (c nord)
      (set-face-attribute (car c) nil :foreground (cdr c) :background (cdr c)))))

;; Bottom panel, 30% tall -- only for the dropdown (not for C-Space t/V/s).
(defvar al-vterm-side-action
  '(display-buffer-in-side-window (side . bottom) (window-height . 0.3)))
(defun al-vterm-toggle ()
  "Show/hide a zsh vterm in a bottom panel (dropdown terminal)."
  (interactive)
  (let* ((buf (get-buffer "*vterm*"))
         (win (and buf (get-buffer-window buf))))
    (cond (win (delete-window win))                                   ; visible -> hide
          (buf (select-window (display-buffer buf al-vterm-side-action))) ; exists -> show
          (t (let ((display-buffer-overriding-action (list al-vterm-side-action)))
               (vterm))))))                                            ; missing -> create at bottom

;; ===== tmux parity: panes (Emacs windows), workspaces (tab-bar), zsh in split =====
;; Mapping: tmux pane = Emacs window - tmux window = tab-bar tab - tmux session ~= tab/frame
(tab-bar-mode 1)
;; tmux status-line style bar: always visible, numbered windows (1 2 3),
;; session (frame) name on the left as [main], clock on the right.
(defun al-tab-bar-session (&rest _)
  "Session label on the left, tmux [main] style."
  `((al-session menu-item
                ,(format " [%s] " (or (frame-parameter nil 'session-name) "main"))
                ignore)))
(setq tab-bar-show t                          ; always visible (like the tmux status bar)
      tab-bar-tab-hints t                     ; number the windows: 1 2 3
      tab-bar-close-button-show nil
      tab-bar-new-button-show nil
      tab-bar-new-tab-choice "*scratch*"
      tab-bar-format '(al-tab-bar-session
                       tab-bar-format-tabs
                       tab-bar-format-align-right
                       tab-bar-format-global))
(setq tab-bar-tab-name-format-function
      (lambda (tab i)
        (propertize (format " %d:%s " i (alist-get 'name tab))
                    'face (funcall tab-bar-tab-face-function tab))))
;; Show the clock on the bar (right side), like tmux status-right.
(setq display-time-format "%H:%M" display-time-default-load-average nil)
(display-time-mode 1)

;; No desktop-save: file tabs are not restored across restarts.
;; (windmove: pane nav is C-hjkl and C-SPC arrows; dropped the redundant M-<arrows>.)

(defun al-vterm-new ()
  "Open a NEW independent vterm (unique name), not reusing the existing one."
  (interactive)
  (vterm (generate-new-buffer-name "*vterm*")))

(defun al-term-zsh (split-fn)
  "Split with SPLIT-FN and open a NEW zsh shell there (each pane its own shell)."
  (funcall split-fn) (other-window 1) (al-vterm-new))

(defun al-split (split-fn)
  "Split with SPLIT-FN and move focus. In vterm open a NEW shell (like tmux,
not the same buffer duplicated); in any other buffer, a normal split."
  (if (derived-mode-p 'vterm-mode)
      (al-term-zsh split-fn)                 ; new pane with its own zsh
    (funcall split-fn) (other-window 1)))
(defun al-split-below () (interactive) (al-split #'split-window-below))
(defun al-split-right () (interactive) (al-split #'split-window-right))

;; Pane zoom like tmux prefix+z: maximize and restore. Stores a single
;; window-configuration, enough for a simple toggle.
(defvar al-window-zoomed nil)
(defun al-toggle-zoom ()
  "Maximize the current pane; toggle again to restore the layout (like tmux prefix z)."
  (interactive)
  (if (window-configuration-p al-window-zoomed)
      (progn (set-window-configuration al-window-zoomed) (setq al-window-zoomed nil))
    (setq al-window-zoomed (current-window-configuration))
    (delete-other-windows)))

(defun al-vterm-copy ()
  "Enter copy-mode in vterm (scrollback + vi selection), like tmux prefix [.
Exit with `q'. Outside vterm does nothing."
  (interactive)
  (when (derived-mode-p 'vterm-mode) (vterm-copy-mode 1)))

(defun al-kill-pane ()
  "Close the pane (tmux x). Kill a vterm's live process first; then close the
pane, or if it's the last pane in the workspace, close the whole workspace
\(tab) and jump to another."
  (interactive)
  (when (derived-mode-p 'vterm-mode)
    (let ((kill-buffer-query-functions nil))   ; don't ask about the live process
      (kill-buffer (current-buffer))))
  ;; Try to close the pane; delete-window refuses on the sole ordinary window
  ;; (count-windows lies: it counts the minibuffer and side windows). On that
  ;; refusal we're the last pane -> close the workspace, or land on dashboard.
  (condition-case nil
      (delete-window)                                     ; other panes -> just this pane
    (error
     (if (> (length (tab-bar-tabs)) 1)
         (tab-bar-close-tab)                              ; last pane -> kill workspace, go to another
       (dashboard-open)))))                               ; nothing left -> land on the dashboard

(defun al-choose-tab ()
  "List workspaces (tab-bar tabs) and jump to the chosen one (tmux choose-window)."
  (interactive)
  (let ((cands (seq-map-indexed
                (lambda (tab i) (cons (format "%d: %s" (1+ i) (alist-get 'name tab)) (1+ i)))
                (tab-bar-tabs))))
    (tab-bar-select-tab (cdr (assoc (completing-read "Window: " cands nil t) cands)))))

(defun al-choose-frame ()
  "List sessions (frames) and switch to the chosen one (tmux choose-session).
Labels by session-name (or frame name) + the frame's current buffer, so frames
with identical names are still distinguishable."
  (interactive)
  (let ((cands (mapcar (lambda (f)
                         (cons (format "%s — %s"
                                       (or (frame-parameter f 'session-name)
                                           (frame-parameter f 'name))
                                       (buffer-name (window-buffer (frame-selected-window f))))
                               f))
                       (frame-list))))
    (select-frame-set-input-focus
     (cdr (assoc (completing-read "Session: " cands nil t) cands)))))

(with-eval-after-load 'evil
  ;; Navigate panes without prefix, vim-tmux-navigator style (= tmux bind -n C-hjkl).
  (evil-define-key '(normal motion) 'global (kbd "C-h") #'windmove-left)
  (evil-define-key '(normal motion) 'global (kbd "C-j") #'windmove-down)
  (evil-define-key '(normal motion) 'global (kbd "C-k") #'windmove-up)
  (evil-define-key '(normal motion) 'global (kbd "C-l") #'windmove-right)
  ;; Navigate workspaces without prefix (= tmux bind -n C-S-h/l).
  (evil-define-key '(normal motion) 'global (kbd "C-S-h") #'tab-bar-switch-to-prev-tab)
  (evil-define-key '(normal motion) 'global (kbd "C-S-l") #'tab-bar-switch-to-next-tab)
  ;; tmux-style prefix (C-Space) in normal/visual/motion states.
  (define-prefix-command 'al-tmux-map)
  (evil-define-key '(normal visual motion) 'global (kbd "C-SPC") 'al-tmux-map)
  (define-key al-tmux-map "v" #'al-split-below)         ; split below; in vterm = new shell (tmux v)
  (define-key al-tmux-map "h" #'al-split-right)         ; split right; in vterm = new shell (tmux h)
  (define-key al-tmux-map "x" #'al-kill-pane)           ; close pane; kills vterm (tmux x)
  (define-key al-tmux-map "z" #'al-toggle-zoom)         ; zoom pane (tmux z)
  (define-key al-tmux-map "V" (lambda () (interactive) (al-term-zsh #'split-window-below))) ; split+zsh
  (define-key al-tmux-map "s" #'al-choose-frame)        ; list sessions (frames), pick (tmux s)
  (define-key al-tmux-map "p" #'project-switch-project) ; open/switch project
  (define-key al-tmux-map "t" #'al-vterm-new)          ; new zsh in the current pane
  (define-key al-tmux-map "c" #'tab-bar-new-tab)        ; new window/session (tmux c/n)
  (define-key al-tmux-map "n" #'tab-bar-new-tab)
  (define-key al-tmux-map "&" #'tab-bar-close-tab)      ; close window
  (define-key al-tmux-map "w" #'al-choose-tab)          ; list windows (tabs), pick (tmux w)
  ;; Navigate panes with prefix + arrows (works inside vterm too).
  (define-key al-tmux-map (kbd "<left>")  #'windmove-left)
  (define-key al-tmux-map (kbd "<down>")  #'windmove-down)
  (define-key al-tmux-map (kbd "<up>")    #'windmove-up)
  (define-key al-tmux-map (kbd "<right>") #'windmove-right)
  ;; --- extra combo (tmux parity) ---
  (define-key al-tmux-map "[" #'al-vterm-copy)          ; copy-mode/scrollback (tmux [)
  (define-key al-tmux-map "," #'tab-bar-rename-tab)     ; rename window (tmux ,)
  (define-key al-tmux-map "l" #'tab-bar-switch-to-recent-tab) ; last window (tmux l)
  ;; Jump to workspace N by number, matching the 1: 2: 3: hints in the bar.
  ;; C-SPC 1..9 -> tabs 1..9 ; C-SPC 0 -> tab 10 (tmux/browser convention).
  (dotimes (n 10)
    (let ((tab (if (= n 0) 10 n)))
      (define-key al-tmux-map (number-to-string n)
        (lambda () (interactive) (tab-bar-select-tab tab)))))
  ;; Resize panes: H/L width, J/K height (step of 5).
  (define-key al-tmux-map "H" (lambda () (interactive) (shrink-window-horizontally 5)))
  (define-key al-tmux-map "L" (lambda () (interactive) (enlarge-window-horizontally 5)))
  (define-key al-tmux-map "J" (lambda () (interactive) (enlarge-window 5)))
  (define-key al-tmux-map "K" (lambda () (interactive) (shrink-window 5))))

;; In vterm (char mode) keys go to the shell -> the C-Space prefix never reaches
;; Emacs. Let it through so splits/workspaces/nav work like in a normal buffer.
(with-eval-after-load 'vterm
  (add-to-list 'vterm-keymap-exceptions "C-SPC")
  (define-key vterm-mode-map (kbd "C-SPC") 'al-tmux-map))

;; Toggle the zsh dropdown from anywhere.
(global-set-key (kbd "C-`") #'al-vterm-toggle)
