;; -*- lexical-binding: t -*-

(defvar my/temp-dir (concat user-emacs-directory "temp"))

(defun my/join-line ()
  (interactive)
  (join-line)
  (forward-line 1)
  (back-to-indentation))

(defun my/smart-home ()
  "Jump to beginning of line or first non-whitespace."
  (interactive)
  (let ((oldpos (point)))
    (beginning-of-visual-line 1)
    (skip-syntax-forward " " (line-end-position))
    (backward-prefix-chars)
    (and (= oldpos (point)) (beginning-of-visual-line))))

(defun my/autosplit ()
  (interactive)
  (if (> 0 (- (* 8 (window-total-width)) (* 20 (window-total-height))))
    (my/split-switch-below)
    (my/split-switch-right)))

(defun my/split-switch-below ()
  "Split and switch to window below."
  (interactive)
  (split-window-below)
  (balance-windows)
  (other-window 1))

(defun my/split-switch-right ()
  "Split and switch to window on the right."
  (interactive)
  (split-window-right)
  (balance-windows)
  (other-window 1))

(defun my/haskell-reload ()
  (interactive)
  (haskell-process-file-loadish
   "reload" t
   (or haskell-interactive-previous-buffer (current-buffer))))

(defun my/notify (msg)
  "Send a graphical notification."
  (start-process "notify" nil "notify-send" "emacs" msg))

(defun my/startup-notify ()
  "Notify about startup time."
  (my/notify (format "Startup took %s!" (emacs-init-time))))

(defun my/consult-imenu-or-outline ()
  "Run consult-imenu or consult-outline depending on major-mode"
  (interactive)
  (pcase major-mode
    ('org-mode (consult-outline))
    (_ (consult-imenu))))

(defun my/align-regexp ()
  "Run align-regexp with indent-tabs disabled."
  (interactive)
  (let ((state indent-tabs-mode))
    (indent-tabs-mode -1)
    (call-interactively #'align-regexp)
    (indent-tabs-mode (if state 1 -1))))

(defvar my/splash (create-image "@splash@"))

(defun my/greeter ()
  "Switches to a simple buffer which greets the user."
  (interactive)

  (switch-to-buffer "*greeter*")
  (special-mode)
  (read-only-mode -1)
  (erase-buffer)

  (display-fill-column-indicator-mode -1) ; hide fill column
  (display-line-numbers-mode -1)          ; hide line numbers
  (call-interactively #'hl-line-mode)     ; can't be directly called for some reason
  (centaur-tabs-local-mode 1)             ; unintuitively *dis*ables tab bar
  (font-lock-mode -1)                     ; must be disabled for propertize to work
  (setq cursor-type nil)                  ; hide cursor
  (setq mode-line-format nil)             ; hide modeline

  (let* ((greeting (propertize "Welcome to Emacs!" 'face '(:height 4.0 :foreground "white")))
         (cw (frame-char-width))
         (gw (string-pixel-width greeting))
         (gs (+ (/ gw cw) (if (zerop (% gw cw)) 0 1))))

    (insert-char ?\n 8)
    (insert-image my/splash (propertize "a" 'line-prefix `(space . (:align-to (- center (0.5 . ,my/splash))))))

    (insert-char ?\n 4)
    (insert (propertize greeting 'line-prefix `(space . (:align-to (- center (0.5 . ,gs)))))))

  (read-only-mode 1)
  (message nil))
