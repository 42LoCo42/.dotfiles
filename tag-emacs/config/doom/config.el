;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;;; VARIABLES

;; basics
(setq user-full-name "Leon Schumacher" user-mail-address "leonsch@protonmail.com")
(setq org-directory "~/org/")
(setq display-line-numbers-type 'relative)
(setq doom-font "Iosevka-10")
(setq doom-theme 'doom-gruvbox)
(setq fancy-splash-image "~/.config/doom/splash.png")

;; whitespace and tabs
(setq-default electric-indent-inhibit t)
(setq whitespace-style '(face tabs tab-mark trailing))
(setq whitespace-display-mappings
      '((tab-mark 9 [124 9])))
(global-whitespace-mode)
(setq backward-delete-char-untabify-method nil)

;; paren style
(setq show-paren-style 'expression)
(setq show-paren-delay 0)
(custom-set-faces!
  '(show-paren-match :bold nil :foreground nil))

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
                               (opencl-mode . "opencl-mode_icon")
                               (org-mode . "org-mode_icon")
                               (pdf-view-mode . "pdf-view-mode_icon")
                               (python-mode . "python-mode_icon")
                               (sh-mode . "vterm-mode_icon")
                               (v-mode . "v-mode_icon")
                               (vterm-mode . "vterm-mode_icon")
                               (zig-mode . "zig-mode_icon")))
(when (eq (shell-command "pgrep -i discord") 0) (elcord-mode))

;; centaur-tabs
(setq centaur-tabs-gray-out-icons nil)
(setq centaur-tabs-set-close-button nil)

;; filetypes
(add-to-list 'auto-mode-alist '("\\.cl\\'" . opencl-mode))

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
  (call-interactively #'compile))

(defun my/run-special-compiler ()
  "Runs the special compiler on this file"
  (interactive)
  (shell-command (concat "compiler " buffer-file-name)))

(defun my/switch-to-scratch-buffer ()
  "Switch to the scratch buffer"
  (interactive)
  (switch-to-buffer "*scratch*")
  (lisp-interaction-mode))

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

;;; HOOKS

;; enable tabs everywhere
(add-hook 'prog-mode-hook #'my/enable-tabs)
(add-hook 'sh-mode-hook   #'my/enable-tabs)

;; disable tabs in some modes
(add-hook 'haskell-mode-hook    (lambda () (interactive) (my/disable-tabs 2)))
(add-hook 'lisp-mode-hook       #'my/disable-tabs)
(add-hook 'emacs-lisp-mode-hook #'my/disable-tabs)
(add-hook 'python-mode-hook     #'my/disable-tabs)
(add-hook 'zig-mode-hook        #'my/disable-tabs)

;; nroff uses some functions
(add-hook
 'nroff-mode-hook
 (lambda ()
   (add-hook 'after-save-hook #'my/run-special-compiler)))

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
(add-to-list 'auto-mode-alist '("\\.v\\'" . v-mode))
(add-to-list 'auto-mode-alist '("\\.vsh\\'" . v-mode))

(advice-add #'v-project-root :around (lambda (&optional _) (file-name-directory buffer-file-name)))
(advice-add #'v-load-tags    :around (lambda (&optional _) ()))
(advice-add #'v-build-tags   :around (lambda (&optional _) ()))

;; (use-package! v-mode
;;   :hook ((v-mode . lsp-deferred))
;;   :config
;;   (after! lsp-mode
;;     (add-to-list 'lsp-language-id-configuration '(v-mode . "v"))
;;     (lsp-register-client
;;      (make-lsp-client
;;       :new-connection (lsp-stdio-connection "vls")
;;       :major-modes '(v-mode)
;;       :server-id 'v))))

(use-package! v-mode
  :config
  (flycheck-define-checker v-checker
    "A v syntax checker using the v fmt."
    :command ("v" "-check" (eval (buffer-file-name)))
    :error-patterns
    ((error line-start (file-name) ":" line ":" column ": error: " (message) line-end)
     (error line-start (file-name) ":" line ":" column ": warning: " (message) line-end))
    :modes v-mode)
  (add-to-list 'flycheck-checkers 'v-checker))

;;; BINDINGS

(defvar my-keys-minor-mode-map
  (let ((map (make-sparse-keymap)))
    (map! :map my-keys-minor-mode-map
          ;; Editing
          "<C-tab>"     #'my/indentall
          "C-/"         #'isearch-forward
          "C-s"         #'save-buffer
          "C-v"         #'yank
          "C-w"         #'kill-ring-save
          "C-y"         #'undo-fu-only-redo
          "C-z"         #'undo-fu-only-undo
          "M-v"         #'counsel-yank-pop
          "M-w"         #'kill-region

          ;; Movement
          "C-,"         #'mc/mark-previous-like-this
          "C-."         #'mc/mark-next-like-this
          "M-l"         #'avy-goto-line
          "M-n"         #'scroll-up-command
          "M-p"         #'scroll-down-command
          "M-s"         #'avy-goto-char

          ;; Window controls
          "C-#"         #'next-window-any-frame
          "C-<next>"    #'centaur-tabs-forward
          "C-<prior>"   #'centaur-tabs-backward
          "C-M-#"       #'previous-window-any-frame
          "C-M-<end>"   #'tab-bar-close-tab
          "C-M-<home>"  #'tab-bar-new-tab
          "C-M-<next>"  #'tab-bar-switch-to-next-tab
          "C-M-<prior>" #'tab-bar-switch-to-prev-tab
          "C-x 2"       #'my/split-and-switch-below
          "C-x 3"       #'my/split-and-switch-right
          "C-x o"       #'switch-window

          ;; Tools
          "<f5>"        #'my/compile
          "C-,"         #'mc/mark-previous-like-this
          "C-."         #'mc/mark-next-like-this
          "C-c C-o"     #'my/open-zathura
          "C-c C-p"     #'my/ps2pdf
          "C-c x"       #'my/switch-to-scratch-buffer
          "M-+"         #'text-scale-increase
          "M--"         #'text-scale-decrease
          "M-="         #'my/text-scale-reset
          )
    map)
  "my-keys-minor-mode keymap.")

(define-minor-mode my-keys-minor-mode
  "A minor mode for my keybindings"
  :init-value t)

;; (tab-bar-mode)
(my-keys-minor-mode)
