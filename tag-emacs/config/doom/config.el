;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets.
(setq user-full-name "Leon Schumacher"
      user-mail-address "leonsch@protonmail.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom. Here
;; are the three important ones:
;;
;; + `doom-font'
;; + `doom-variable-pitch-font'
;; + `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;;
;; They all accept either a font-spec, font string ("Input Mono-12"), or xlfd
;; font string. You generally only need these two:
;; (setq doom-font (font-spec :family "monospace" :size 12 :weight 'semi-light)
;;       doom-variable-pitch-font (font-spec :family "sans" :size 13))

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-one)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type 'relative)


;; Here are some additional functions/macros that could help you configure Doom:
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
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.

(setq doom-font "PragmataPro-10")

(defun my/split-and-switch-below ()
  "Split window below and switch to it."
  (interactive)
  (split-window-below)
  (balance-windows)
  (other-window 1))

(map! "C-x 2" #'my/split-and-switch-below)

(defun my/split-and-switch-right ()
  "Split window right and switch to it."
  (interactive)
  (split-window-right)
  (balance-windows)
  (other-window 1))

(map! "C-x 3" #'my/split-and-switch-right)

(setq switch-window-input-style 'minibuffer)
(setq switch-window-increase 4)
(setq switch-window-threshold 2)
(setq switch-window-shortcut-style 'qwerty)
(setq switch-window-qwerty-shortcuts
      '("a" "s" "d" "f" "j" "k" "l"))
(map! "C-x o" #'switch-window)

(map! "M-s" #'avy-goto-char)
(map! "M-l" #'avy-goto-line)

(map! "<f5>" (lambda ()
               (interactive)
               (save-buffer)
               (setq-local compilation-read-command nil)
               (call-interactively #'compile)))

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

(setq company-minimum-prefix-length 1)
(setq company-dabbrev-ignore-case t)
(setq company-dabbrev-downcase nil)
(setq company-idle-delay 0)

(setq elcord-use-major-mode-as-main-icon t)
(setq elcord-editor-icon "emacs_icon")

(defun my/elcord-buffer-details-format ()
  (let ((pname (doom-project-name)))
    (pcase pname
      ("-" (buffer-name))
      (_ (format "%s - %s" pname (buffer-name))))))
(setq elcord-buffer-details-format-function #'my/elcord-buffer-details-format)

(setq elcord-client-id "856822158574878751")
(setq elcord-mode-icon-alist '((c++-mode . "cpp-mode_icon")
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
                               (org-mode . "org-mode_icon")
                               (pdf-view-mode . "pdf-view-mode_icon")
                               (python-mode . "python-mode_icon")
                               (vterm-mode . "vterm-mode_icon")
                               (zig-mode . "zig-mode_icon")))
(elcord-mode)

(map! "M-+" #'doom/increase-font-size)
(map! "M-=" #'doom/reset-font-size)

(defun disable-tabs (&optional width)
  "Disable tabs, optionally specify indent width"
  (unless width (setq width 4))
  (setq indent-tabs-mode nil)
  (setq tab-width width))

(defun enable-tabs (&optional width)
  "Enable tabs, optionally specify tab width"
  (unless width (setq width 4))
  (local-set-key (kbd "TAB") #'tab-to-tab-stop)
  (setq indent-tabs-mode t)
  (setq tab-width width))

(add-hook 'prog-mode-hook 'enable-tabs)
(add-hook 'sh-mode-hook 'enable-tabs)

(add-hook 'sh-mode-hook (lambda () (enable-tabs 2)))

(add-hook 'haskell-mode-hook (lambda () (disable-tabs 2)))

(add-hook 'lisp-mode-hook 'disable-tabs)
(add-hook 'emacs-lisp-mode-hook 'disable-tabs)
(add-hook 'python-mode-hook 'disable-tabs)
(add-hook 'zig-mode-hook 'disable-tabs)

(setq-default electric-indent-inhibit t)
(setq whitespace-style '(face tabs tab-mark trailing))
(setq whitespace-display-mappings
      '((tab-mark 9 [124 9])))
(global-whitespace-mode)

(defun switch-to-scratch-buffer ()
  "Switch to the scratch buffer"
  (interactive)
  (switch-to-buffer "*scratch*"))
(map! "C-c x" #'switch-to-scratch-buffer)

(setq backward-delete-char-untabify-method nil)

(map! "<C-tab>" (lambda ()
                  (interactive)
                  (delete-trailing-whitespace)
                  (indent-region (point-min) (point-max) nil)))

(map! "C-v" #'yank)
(map! "M-v" #'counsel-yank-pop)
(map! "C-z" #'undo-fu-only-undo)
(map! "C-y" #'undo-fu-only-redo)
(map! "M-n" #'scroll-up-command)
(map! "M-p" #'scroll-down-command)
(map! "C-w" #'kill-ring-save)
(map! "M-w" #'kill-region)

(setq show-paren-style 'expression)
(setq show-paren-delay 0)
(custom-set-faces!
  '(show-paren-match :bold nil :foreground nil))
