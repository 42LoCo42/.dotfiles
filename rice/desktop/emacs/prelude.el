;; -*- lexical-binding: t -*-

(defvar my/home-dir (expand-file-name "~/"))
(defvar my/temp-dir (concat user-emacs-directory "temp/"))
(mkdir my/temp-dir t)

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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defvar my/splash (create-image "@splash@"))

(defun my/center-content (content)
  "Inserts CONTENT centered between left and right window edge"
  (if (imagep content)
    (insert-image content (propertize "a" 'line-prefix `(space . (:align-to (- center (0.5 . ,content))))))
    (let* ((cw (frame-char-width))                        ; char width
           (tw (string-pixel-width content))              ; text width
           (sp (+ (/ tw cw) (if (zerop (% tw cw)) 0 1)))) ; spacing
      (insert (propertize content 'line-prefix `(space . (:align-to (- center (0.5 . ,sp)))))))))

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

  (insert-char ?\n 8)
  (my/center-content my/splash)

  (insert-char ?\n 4)
  (my/center-content (propertize "Welcome to Emacs!" 'face '(:height 4.0 :foreground "white")))

  (insert-char ?\n 2)
  (my/center-content (propertize (format "<< Loaded %d/%d packages in %s >>"
                                         (cl-loop
                                          for p hash-values of use-package-statistics
                                          if (gethash :config p)
                                          count p)
                                         (hash-table-count use-package-statistics)
                                         (emacs-init-time))
                                 'face '(:height 1.25 :foreground "gray" :slant italic)))

  (read-only-mode 1)
  (message nil))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(require 'telephone-line)
(require 'project)

(defvar my/telephone-line-space
  (make-instance 'telephone-line-unicode-separator :char 32))

(telephone-line-defsegment my/telephone-line-project-cached-segment ()
  (if (boundp 'my/project-cached) my/project-cached
    (let ((result (funcall (funcall #'telephone-line-project-segment) face)))
      (setq-local my/project-cached result))))

(telephone-line-defsegment my/telephone-line-buffer-segment ()
  (if (boundp 'my/buffer-segment-cached) my/buffer-segment-cached
    (let ((name (buffer-file-name))
          (proj (project-current))
          (prop (lambda (path)
                  (concat (propertize (or (file-name-directory path) "") 'face 'bold)
                          (propertize (file-name-nondirectory path)      'face '(bold :foreground "light green"))))))
      (setq-local
       my/buffer-segment-cached
       `(""
         mode-line-mule-info
         mode-line-modified
         mode-line-client
         mode-line-remote
         " "
         ,(cond
           ((not name) (propertize (buffer-name) 'face 'bold))
           (proj (funcall prop (string-remove-prefix
                                (expand-file-name (project-root proj)) name)))
           (t (funcall prop (if (string-prefix-p my/home-dir name)
                              (concat "~/" (string-remove-prefix my/home-dir name))
                              name)))))))))

(telephone-line-defsegment my/telephone-line-symbol-segment ()
  (string-trim (lsp-headerline--build-symbol-string)))

(telephone-line-defsegment my/telephone-line-crdt-segment ()
  (if-let* ((_ (boundp 'crdt-mode))
            (_ crdt-mode)
            (session (crdt--read-session-maybe))
            (contacts (crdt--session-contact-table session))
            (follow-id (crdt--session-follow-user-id session))
            (follow-name (crdt--contact-metadata-name (gethash follow-id contacts))))
      `("" ,(propertize (format "Following: %s" follow-name) 'face '(bold :foreground "red")))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; https://github.com/blahgeek/emacs-lsp-booster

(defun lsp-booster--advice-json-parse (old-fn &rest args)
  "Try to parse bytecode instead of json."
  (or
   (when (equal (following-char) ?#)
     (let ((bytecode (read (current-buffer))))
       (when (byte-code-function-p bytecode)
         (funcall bytecode))))
   (apply old-fn args)))

(defun lsp-booster--advice-final-command (old-fn cmd &optional test?)
  "Prepend emacs-lsp-booster command to lsp CMD."
  (let ((orig-result (funcall old-fn cmd test?)))
    (if (and (not test?)                             ;; for check lsp-server-present?
             (not (file-remote-p default-directory)) ;; see lsp-resolve-final-command, it would add extra shell wrapper
             lsp-use-plists
             (not (functionp 'json-rpc-connection))  ;; native json-rpc
             (executable-find "emacs-lsp-booster"))
      (progn
        (when-let ((command-from-exec-path (executable-find (car orig-result))))  ;; resolve command from exec-path (in case not found in $PATH)
          (setcar orig-result command-from-exec-path))
        (message "Using emacs-lsp-booster for %s!" orig-result)
        (cons "emacs-lsp-booster" orig-result))
      orig-result)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; https://www.masteringemacs.org/article/seamlessly-merge-multiple-documentation-sources-eldoc
(defun my/flycheck-eldoc (callback &rest _ignored)
  "Print flycheck messages at point by calling CALLBACK."
  (when-let ((flycheck-errors (and flycheck-mode (flycheck-overlay-errors-at (point)))))
    (mapc
     (lambda (err)
       (funcall callback
                (format "%s: %s"
                        (let ((level (flycheck-error-level err)))
                          (pcase level
                            ('info (propertize "I" 'face 'flycheck-error-list-info))
                            ('error (propertize "E" 'face 'flycheck-error-list-error))
                            ('warning (propertize "W" 'face 'flycheck-error-list-warning))
                            (_ level)))
                        (flycheck-error-message err))
                :thing (or (flycheck-error-id err)
                           (flycheck-error-group err))
                :face 'font-lock-doc-face))
     flycheck-errors)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(require 'dash)

(defun my/flycheck-deadnix (output checker _)
  (->> output
       (flycheck-parse-json)
       (car)
       (alist-get 'results)
       (mapcar (lambda (item)
                 (let-alist item
                   (flycheck-error-new-at
                    .line
                    .column
                    'warning
                    .message
                    :end-column .endColumn
                    :checker checker))))))

(defun my/flycheck-zlint (output checker _)
  (->> output
       (string-trim)
       (string-replace "\n" ",")
       (format "[%s]")
       (flycheck-parse-json)
       (car)
       (mapcar (lambda (item)
                 (let-alist item
                   (let-alist (car .labels)
                     (flycheck-error-new-at
                      .start.line
                      .start.column
                      'warning
                      (format "%s - %s"
                              (alist-get 'message item)
                              (alist-get 'help item))
                      :end-line .end.line
                      :end-column .end.column
                      :checker checker)))))))

;; https://github.com/flycheck/flycheck/issues/1762#issuecomment-750458442
(defvar-local my/flycheck-local-cache nil)

(defun my/flycheck-checker-get (fn checker property)
  (or (alist-get property (alist-get checker my/flycheck-local-cache))
      (funcall fn checker property)))

(defun my/flycheck-setup ()
  (flycheck-define-checker deadnix
    "deadnix"
    :modes nix-mode
    :command ("deadnix" "-o" "json" source-original)
    :error-parser my/flycheck-deadnix
    :next-checkers (statix))

  (flycheck-define-checker zlint
    "zlint"
    :modes zig-mode
    :command ("my-zlint" source-original)
    :error-parser my/flycheck-zlint)

  (mapc (lambda (x) (add-to-list 'flycheck-checkers x))
        '(deadnix zlint))

  (advice-add #'flycheck-checker-get :around #'my/flycheck-checker-get))

(defmacro my/chain (mode &rest checkers)
  `(when (derived-mode-p ',mode)
     (setq my/flycheck-local-cache '((lsp . ((next-checkers . ,checkers)))))))
