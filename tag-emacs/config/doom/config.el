;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;;; VARIABLES

;; basics
(setq user-full-name "Leon Schumacher" user-mail-address "leonsch@protonmail.com")
(setq org-directory "~/org/")
(setq display-line-numbers-type 'relative)
(setq doom-font "Iosevka-10")
(setq doom-theme 'doom-gruvbox)
(setq fancy-splash-image "~/.config/doom/splash.png")

;; don't ask when quitting
(setq confirm-kill-emacs nil)

;; kill whole line
(setq kill-whole-line t)

;; whitespace and tabs
(setq electric-indent-inhibit t)
(setq whitespace-style '(face tabs tab-mark trailing))
(setq whitespace-display-mappings
      '((tab-mark 9 [124 9])))
(setq backward-delete-char-untabify-method nil)

;; paren style
(setq show-paren-style 'expression)
(setq show-paren-delay 0)
(custom-set-faces!
  '(show-paren-match :bold t :background "#303030"))
(setq rainbow-delimiters-max-face-count 10)

;; switch-window
(setq switch-window-input-style 'minibuffer)
(setq switch-window-increase 4)
(setq switch-window-threshold 2)
(setq switch-window-shortcut-style 'qwerty)
(setq switch-window-qwerty-shortcuts
      '("a" "s" "d" "f" "j" "k" "l"))

;; company
(setq company-minimum-prefix-length 1)
(setq company-dabbrev-ignore-case t)
(setq company-dabbrev-downcase nil)
(setq company-idle-delay 0)
(setq company-show-numbers t)
(add-to-list 'company-backends #'company-tabnine)

;; elcord
(setq elcord-use-major-mode-as-main-icon t)
(setq elcord-editor-icon "emacs_icon")
(setq elcord-buffer-details-format-function #'my/elcord-buffer-details-format)
(setq elcord-client-id "856822158574878751")
(setq elcord-mode-icon-alist '((Man-mode . "man-mode_icon")
                               (c++-mode . "cpp-mode_icon")
                               (c-mode . "c-mode_icon")
                               (comint-mode . "comint-mode_icon")
                               (compilation-mode . "compilation-mode_icon")
                               (emacs-lisp-mode . "emacs_icon")
                               (gdb-breakpoints-mode . "comint-mode_icon")
                               (gdb-frames-mode . "comint-mode_icon")
                               (gdb-locals-mode . "comint-mode_icon")
                               (haskell-interactive-mode . "haskell-mode_icon")
                               (haskell-mode . "haskell-mode_icon")
                               (lisp-mode . "lisp-mode_icon")
                               (magit-mode . "git-mode_icon")
                               (makefile-mode . "compilation-mode_icon")
                               (nim-mode . "nim-mode_icon")
                               (opencl-mode . "opencl-mode_icon")
                               (org-mode . "org-mode_icon")
                               (pdf-view-mode . "pdf-view-mode_icon")
                               (python-mode . "python-mode_icon")
                               (sh-mode . "vterm-mode_icon")
                               (tcl-mode . "tcl-mode_icon")
                               (v-mode . "v-mode_icon")
                               (vterm-mode . "vterm-mode_icon")
                               (zig-mode . "zig-mode_icon")))

;; centaur-tabs
(setq centaur-tabs-gray-out-icons nil)
(setq centaur-tabs-set-close-button nil)

;; filetypes
(add-to-list 'auto-mode-alist '("\\.cl\\'"  . opencl-mode))
(add-to-list 'auto-mode-alist '("\\.v\\'"   . v-mode))
(add-to-list 'auto-mode-alist '("\\.vsh\\'" . v-mode))

;;; FUNCTIONS

(defun my/indentall ()
  "Clean indentation in the whole buffer"
  (interactive)
  (delete-trailing-whitespace)
  (indent-region (point-min) (point-max) nil))

(defun my/split-and-switch-below ()
  "Split window below and switch to it."
  (interactive)
  (split-window-below)
  (balance-windows)
  (other-window 1))

(defun my/split-and-switch-right ()
  "Split window right and switch to it."
  (interactive)
  (split-window-right)
  (balance-windows)
  (other-window 1))

(defun my/compile ()
  "Save & compile buffer"
  (interactive)
  (save-buffer)
  (setq-local compilation-read-command nil)
  (cd (substitute-env-in-file-name "$PROOT"))
  (call-interactively #'compile))

(defun my/run-special-compiler ()
  "Runs the special compiler on this file"
  (interactive)
  (shell-command (concat "compiler " buffer-file-name)))

(defun my/switch-to-scratch-buffer ()
  "Switch to the scratch buffer"
  (interactive)
  (switch-to-buffer "*scratch*")
  (emacs-lisp-mode))

(defun my/open-zathura ()
  "Opens zathura on the generated output file"
  (interactive)
  (call-process-shell-command
   (concat
    "zathura "
    (file-name-sans-extension buffer-file-name)
    ".ps") nil 0))

(defun my/ps2pdf ()
  "Run the ps2pdf shell command"
  (interactive)
  (call-process-shell-command
   (concat
    "ps2pdf "
    (file-name-sans-extension buffer-file-name)
    ".ps") nil 0))

(defun my/disable-tabs (&optional width)
  "Disable tabs, optionally specify indent width"
  (unless width (setq width 4))
  (setq indent-tabs-mode nil)
  (setq tab-width width))

(defun my/enable-tabs (&optional width)
  "Enable tabs, optionally specify tab width"
  (unless width (setq width 4))
  (local-set-key (kbd "TAB") #'tab-to-tab-stop)
  (setq indent-tabs-mode t)
  (setq tab-width width))

(defun my/elcord-buffer-details-format ()
  (let ((pname (doom-project-name)))
    (pcase pname
      ("-" (buffer-name))
      (_ (format "%s - %s" pname (buffer-name))))))

(defun my/text-scale-reset ()
  "Set text scale to 0"
  (interactive)
  (text-scale-set 0))

(defun my/dwim-backward-kill-word ()
  "DWIM kill characters backward until encountering the beginning of a word or non-word."
  (interactive)
  (if (thing-at-point 'word) (backward-kill-word 1)
    (let* ((orig-point              (point))
           (orig-line               (line-number-at-pos))
           (backward-word-point     (progn (backward-word) (point)))
           (backward-non-word-point (progn (goto-char orig-point) (my/backward-non-word) (point)))
           (min-point               (max backward-word-point backward-non-word-point)))

      (if (< (line-number-at-pos min-point) orig-line) (progn (goto-char min-point) (end-of-line) (delete-horizontal-space))
        (delete-region min-point orig-point)
        (goto-char min-point)))))

(defun my/backward-non-word ()
  "Move backward until encountering the beginning of a non-word."
  (interactive)
  (search-backward-regexp "[^a-zA-Z0-9\s\n]")
  (while (looking-at "[^a-zA-Z0-9\s\n]")
    (backward-char))
  (forward-char))

;;; HOOKS

;; enable tabs everywhere
(add-hook 'prog-mode-hook #'my/enable-tabs)
(add-hook 'sh-mode-hook   #'my/enable-tabs)

;; disable tabs in some modes
(add-hook 'haskell-mode-hook    (lambda () (interactive) (my/disable-tabs 2)))
(add-hook 'nim-mode-hook        (lambda () (interactive) (my/disable-tabs 2)))
(add-hook 'lisp-mode-hook       #'my/disable-tabs)
(add-hook 'emacs-lisp-mode-hook #'my/disable-tabs)
(add-hook 'python-mode-hook     #'my/disable-tabs)
(add-hook 'zig-mode-hook        #'my/disable-tabs)

;; nroff uses some functions
(add-hook
 'nroff-mode-hook
 (lambda ()
   (add-hook 'after-save-hook #'my/run-special-compiler)))

(add-hook 'sly-mode-hook (lambda () (map!)
                           "M-n" #'sly-mrepl-next-input-or-button
                           "M-p" #'sly-mrepl-previous-input-or-button))

;; zig-mode
(use-package! zig-mode
  :hook ((zig-mode . lsp-deferred))
  :custom (zig-format-on-save nil)
  :config
  (after! lsp-mode
    (add-to-list 'lsp-language-id-configuration '(zig-mode . "zig"))
    (lsp-register-client
     (make-lsp-client
      :new-connection (lsp-stdio-connection "zls")
      :major-modes '(zig-mode)
      :server-id 'zls))))

;; v-mode
(advice-add #'v-project-root :around (lambda (&optional _) (file-name-directory buffer-file-name)))
(advice-add #'v-load-tags    :around (lambda (&optional _) ()))
(advice-add #'v-build-tags   :around (lambda (&optional _) ()))

(use-package! v-mode
  :config
  (flycheck-define-checker v-checker
    "A v syntax checker using v -check"
    :command ("v" "-check" (eval (buffer-file-name)))
    :error-patterns
    ((error line-start (file-name) ":" line ":" column ": error: " (message) line-end)
     (error line-start (file-name) ":" line ":" column ": warning: " (message) line-end))
    :modes v-mode)
  (add-to-list 'flycheck-checkers 'v-checker))

;; nim-mode
(use-package! nim-mode
  :hook (nim-mode . lsp))

;;; MODES
(global-whitespace-mode)
(when (zerop (shell-command "pgrep -i discord")) (elcord-mode))

;;; BINDINGS
(defmacro my/bind-keys* (&rest body)
  `(progn
     ,@(cl-loop
        while body collecting
        `(bind-key* ,(pop body) ,(pop body)))))

(my/bind-keys*
 ;; Editing
 "<C-tab>"       #'my/indentall
 "C-v"           #'yank
 "C-y"           #'undo-fu-only-redo
 "C-z"           #'undo-fu-only-undo
 "M-<backspace>" #'my/dwim-backward-kill-word
 "M-v"           #'counsel-yank-pop

 ;; Movement
 "C-,"         #'mc/mark-previous-like-this
 "C-."         #'mc/mark-next-like-this
 "C-s"         #'counsel-grep-or-swiper
 "M-l"         #'avy-goto-line
 "M-n"         #'scroll-up-command
 "M-p"         #'scroll-down-command
 "M-s"         #'ace-jump-char-mode

 ;; Window controls
 "C-#"         #'next-window-any-frame
 "C-<next>"    #'centaur-tabs-forward
 "C-<prior>"   #'centaur-tabs-backward
 "C-M-#"       #'previous-window-any-frame
 "C-M-<end>"   #'+workspace/delete
 "C-M-<home>"  #'+workspace/new
 "C-M-<next>"  #'+workspace/switch-right
 "C-M-<prior>" #'+workspace/switch-left
 "C-x 2"       #'my/split-and-switch-below
 "C-x 3"       #'my/split-and-switch-right
 "C-x b"       #'counsel-switch-buffer

 ;; Tools
 "<f5>"        #'my/compile
 "C-,"         #'mc/mark-previous-like-this
 "C-."         #'mc/mark-next-like-this
 "C-c C-o"     #'my/open-zathura
 "C-c C-p"     #'my/ps2pdf
 "C-c x"       #'my/switch-to-scratch-buffer
 "C-x C-z"     #'+nav-flash/blink-cursor
 "M-+"         #'text-scale-increase
 "M--"         #'text-scale-decrease
 "M-="         #'my/text-scale-reset)

(add-hook
 'sly-mrepl-mode-hook
 (lambda ()
   (bind-key "C-n" #'sly-mrepl-next-input-or-button 'sly-mrepl-mode-map)
   (bind-key "C-p" #'sly-mrepl-previous-input-or-button 'sly-mrepl-mode-map)))
