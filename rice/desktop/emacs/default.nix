{ pkgs, lib, config, ... }: {
  options.rice.desktop.emacs = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };

    alpha = lib.mkOption {
      type = lib.types.str;
      default = toString config.rice.desktop.alpha;
    };
  };

  config = lib.mkIf config.rice.desktop.emacs.enable {
    home-manager.sharedModules = [{
      services.emacs = {
        enable = true;
        startWithUserSession = "graphical";
      };

      systemd.user.services.emacs.Service.Restart = lib.mkForce "always";

      xdg.configFile."fourmolu.yaml".source = ./fourmolu.yaml;

      aquaris.persist = { ".config/emacs" = { }; };

      aquaris.emacs = {
        enable = true;
        package = pkgs.emacs30-pgtk;

        extraPackages = epkgs: with epkgs; [
          (treesit-grammars.with-grammars (g: with g; [
            tree-sitter-typst
          ]))
        ];

        usePackage.statistics = true;

        prelude = ''
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
              (back-to-indentation)
              (and (= oldpos (point)) (beginning-of-line))))

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
        '';

        postlude = ''
          (setq cua-remap-control-v nil)
          (cua-mode 1)
          (bind-key "C-v" 'cua-paste)
        '';

        config = {
          ##### Basic configuration #####

          emacs = {
            bind = ''
              ("C-a" . my/smart-home)
            '';

            bind' = ''(
              ("C-M-<backspace>" . my/join-line)
              ("C-s"             . save-buffer)

              ("C-x C-f" . find-file)

              ("C-#"   . (lambda () (interactive) (select-window (next-window))))
              ("M-#"   . (lambda () (interactive) (select-window (previous-window))))
              ("M-e"   . forward-word)
              ("M-f"   . forward-to-word)
              ("M-n"   . scroll-up-command)
              ("M-p"   . scroll-down-command)

              ("C-M-i"   . ispell-buffer)
              ("C-x C-a" . mark-whole-buffer)
              ("C-x C-k" . (lambda () (interactive) (kill-buffer (current-buffer))))

              ("C-+" . text-scale-increase)
              ("C--" . text-scale-decrease)
              ("C-=" . text-scale-mode)

              ("C-M-<return>" . my/autosplit)
              ("C-x C-0"      . delete-window)
              ("C-x C-1"      . delete-other-windows)
              ("C-x C-2"      . my/split-switch-below)
              ("C-x C-3"      . my/split-switch-right)
              ("C-x C-4"      . kill-buffer-and-window)

              :map read--expression-map
              ("C-n" . next-line-or-history-element)
              ("C-p" . previous-line-or-history-element)

              :map minibuffer-local-shell-command-map
              ("C-n" . next-line-or-history-element)
              ("C-p" . previous-line-or-history-element)
            )'';

            hook = ''
              ; delete trailing whitespace on save
              (before-save . delete-trailing-whitespace)

              ; send a graphical notification on startup
              (emacs-startup . my/startup-notify)

              ; indicate the 80th column on each line
              (display-fill-column-indicator-mode .
                (lambda () (set-fill-column 80)))

              ; disable tabs in org-mode
              (org-mode . (lambda () (indent-tabs-mode 0)))
            '';

            config = ''
              (blink-cursor-mode 0) ; no blinking cursor
              (menu-bar-mode     0) ; no menu bar
              (scroll-bar-mode   0) ; no scroll bar
              (tool-bar-mode     0) ; no tool bar

              (global-auto-revert-mode                   1) ; revert buffer when physical file changes
              (global-display-fill-column-indicator-mode 1) ; display the fill column
              (global-hl-line-mode                       1) ; highlight current line
              (global-prettify-symbols-mode              1) ; e.g display lambda as that character

              ; disable verbose yes-or-no questions
              (defalias 'yes-or-no-p 'y-or-n-p)

              ; transparency
              (push '(alpha-background .
                ${config.rice.desktop.emacs.alpha})
                default-frame-alist)

              ; all frames use monospace font
              (add-to-list 'default-frame-alist '(font . "monospace:size=14"))

              ; indent elisp "if" normally
              (put 'if 'lisp-indent-function 'defun)

              ; show possible keybind continuations
              (which-key-mode 1)
              (which-key-setup-side-window-bottom)
            '';

            custom = ''
              (auto-save-file-name-transforms `((".*"  ,my/temp-dir t)))
              (auto-save-list-file-prefix               my/temp-dir)
              (backup-directory-alist         `(("." . ,my/temp-dir)))

              (c-backspace-function 'delete-backward-char)
              (c-basic-offset 4)
              (sgml-basic-offset 4)
              (tab-width 4)

              (inhibit-startup-screen t)
              (initial-major-mode 'fundamental-mode)
              (initial-scratch-message "")
              (native-comp-async-report-warnings-errors nil)
              (recentf-max-saved-items 100)
              (ring-bell-function 'ignore)
              (use-dialog-box nil)

              ; case-insensitive completion
              (completion-ignore-case t)
              (read-file-name-completion-ignore-case t)

              (xref-show-xrefs-function       'consult-xref)
              (xref-show-definitions-function 'consult-xref)
              (xref-prompt-for-identifier     nil)

              (which-key-idle-delay 0.5)
              (which-key-idle-secondary-delay 0)
            '';

            extraPackages = with pkgs; [
              ghostscript # PDF rendering support
            ];
          };

          server = {
            custom = "(server-client-instructions nil)";
          };

          straight = {
            commands = ''
              straight-remove-unused-repos
              straight-use-package
            '';
          };

          ##### Appearance #####

          "00-theme" = {
            package = "gruvbox-theme";
            config = "(load-theme 'gruvbox-dark-medium t)";
          };

          rainbow-delimiters = {
            config = ''
              (set-face-foreground 'rainbow-delimiters-depth-1-face "#cc241d")
              (set-face-foreground 'rainbow-delimiters-depth-2-face "#98971a")
              (set-face-foreground 'rainbow-delimiters-depth-3-face "#d79921")
              (set-face-foreground 'rainbow-delimiters-depth-4-face "#458588")
              (set-face-foreground 'rainbow-delimiters-depth-5-face "#b16286")
              (set-face-foreground 'rainbow-delimiters-depth-6-face "#689d6a")

              (define-globalized-minor-mode my/global-raindow-delims-mode rainbow-delimiters-mode
                (lambda () (rainbow-delimiters-mode 1)))
              (my/global-raindow-delims-mode 1)
            '';

            custom = "(rainbow-delimiters-max-face-count 6)";
          };

          rainbow-mode = {
            hook = "prog-mode text-mode";
          };

          git-gutter = {
            hook = "prog-mode";

            config = ''
              (set-face-background 'git-gutter:added    nil)
              (set-face-background 'git-gutter:modified nil)
              (set-face-background 'git-gutter:deleted  nil)
              (global-git-gutter-mode 1)
            '';

            custom = ''
              (git-gutter:added-sign    "+")
              (git-gutter:modified-sign "~")
              (git-gutter:deleted-sign  "-")
              (git-gutter:update-interval 2)
            '';
          };

          all-the-icons = {
            extraPackages = with pkgs; [ emacs-all-the-icons-fonts ];
          };

          hl-todo = {
            hook = "prog-mode text-mode";
            config = "(global-hl-todo-mode 1)";
          };

          display-line-numbers = {
            config = ''
              (set-face-foreground 'line-number "#ebdbb2")
              (set-face-background 'line-number nil)
              (global-display-line-numbers-mode 1)
            '';

            custom = "(display-line-numbers-type 'relative)";
          };

          telephone-line = {
            config = ''
              (telephone-line-defsegment my/telephone-line-project-cached-segment ()
                (if (boundp 'my/project-cached) my/project-cached
                  (let ((result (funcall (funcall #'telephone-line-project-segment) face)))
                    (setq-local my/project-cached result)
                    result)))

              (telephone-line-mode 1)
            '';

            custom = ''
              (telephone-line-lhs
               '((accent . (telephone-line-vc-segment
                            telephone-line-process-segment))
                 (nil    . (my/telephone-line-project-cached-segment
                            telephone-line-buffer-segment))))
            '';
          };

          centaur-tabs = {
            demand = true;

            bind' = ''
              ("C-<next>"  . centaur-tabs-forward)
              ("C-<prior>" . centaur-tabs-backward)
            '';

            config = ''
              (centaur-tabs-mode 1)
              (centaur-tabs-change-fonts "monospace" 100)
              (centaur-tabs-headline-match)
            '';

            custom = ''
              (centaur-tabs-cycle-scope 'tabs)
              (centaur-tabs-modified-marker "●")
              (centaur-tabs-set-bar 'under)
              (centaur-tabs-show-new-tab-button nil)
              (centaur-tabs-set-close-button nil)
              (centaur-tabs-set-icons t)
              (centaur-tabs-set-modified-marker t)
              (centaur-tabs-style "bar")
              (x-underline-at-descent-line 1)
            '';
          };

          whitespace = {
            config = "(global-whitespace-mode 1)";

            custom = ''
              (whitespace-style '(face tab-mark trailing missig-newline-at-eof))
            '';
          };

          ##### Behaviour #####

          ace-window = {
            bind' = ''
              ("C-M-#" . ace-window)
            '';

            custom = ''
              (aw-keys '(?a ?s ?d ?f   ?h ?j ?k ?l
                         ?q ?w ?e ?r   ?u ?i ?o ?p))
              (aw-scope 'frame)
            '';
          };

          direnv = {
            config = "(direnv-mode 1)";
            custom = "(direnv-always-show-summary nil)";
          };

          flycheck = {
            hook = "prog-mode";
            custom = ''
              (flycheck-check-syntax-automatically '(mode-enabled save))
              (flycheck-display-errors-delay 0)
            '';
          };

          apheleia = {
            bind' = ''
              ("C-<tab>" . apheleia-format-buffer)
            '';

            hook = "prog-mode typst-ts-mode";

            config = ''
              (add-to-list 'apheleia-mode-alist '(sh-mode . shfmt))
            '';

            extraPackages = with pkgs; [
              black # python-mode
              nodePackages.prettier
              shfmt
            ];
          };

          avy = {
            bind' = ''
              ("M-c"   . avy-goto-char)
              ("C-M-c" . avy-goto-char-timer)
            '';

            custom = ''
              (avy-keys
               (nconc
                (number-sequence ?a ?z)
                (number-sequence ?0 ?9)))

              (avy-background t)
              (avy-case-fold-search nil) ; only caps trigger case matching
              (avy-style 'de-bruijn)
            '';

            config = ''
              (set-face-attribute 'avy-lead-face   nil :foreground "#fb4934" :background "#282828" :bold t) ; first
              (set-face-attribute 'avy-lead-face-0 nil :foreground "#b8bb26" :background "#282828" :bold t) ; second
              (set-face-attribute 'avy-lead-face-1 nil :foreground "#282828" :background "#282828" :bold t) ; matched
              (set-face-attribute 'avy-lead-face-2 nil :foreground "#83a598" :background "#282828" :bold t) ; third
            '';
          };

          helpful = {
            bind' = ''
              ("C-h C-f" . helpful-callable)
              ("C-h C-k" . helpful-key)
              ("C-h C-v" . helpful-variable)
            '';
          };

          link-hint = {
            autoload = "link-hint--get-links";

            init = ''
              (defun my/open-link ()
                (interactive)
                (when (link-hint--get-links)
                 (message "Links found!")
                 (link-hint-open-link)))

              (bind-key* "C-M-l" #'my/open-link)
            '';
          };

          multiple-cursors = {
            bind' = ''
              ("C-," . mc/mark-previous-like-this)
              ("C-." . mc/mark-next-like-this)
            '';
          };

          popwin = {
            config = ''
              (push '("^[*]" :regex t) popwin:special-display-config)
              (popwin-mode 1)
            '';
          };

          smooth-scrolling = {
            config = "(smooth-scrolling-mode 1)";
          };

          yasnippet = {
            hook = "(lsp-mode . yas-minor-mode)";
          };

          undo-tree = {
            bind' = ''
              ("C-x C-u" . undo-tree-visualize)
              ("C-y"     . undo-tree-redo)
              ("C-z"     . undo-tree-undo)
            '';

            config = "(global-undo-tree-mode 1)";
            custom = ''
              (undo-tree-history-directory-alist `(("." . ,my/temp-dir)))
            '';
          };

          org-drill = {
            package = epkgs: epkgs.org-drill.overrideAttrs (old: {
              # org is part of emacs
              packageRequires = lib.remove epkgs.org old.packageRequires;
            });

            commands = "org-drill-strip-all-data";
          };

          smartparens = {
            hook = "prog-mode text-mode conf-mode";
            config = ''
              (require 'smartparens-config)

              (defun indent-between-pair (&rest _ignored)
                (newline)
                (indent-according-to-mode)
                (forward-line -1)
                (indent-according-to-mode))

              (sp-local-pair 'prog-mode "(" nil :post-handlers '((indent-between-pair "RET")))
              (sp-local-pair 'prog-mode "[" nil :post-handlers '((indent-between-pair "RET")))
              (sp-local-pair 'prog-mode "{" nil :post-handlers '((indent-between-pair "RET")))
            '';
          };

          ##### Completion #####

          prescient = {
            config = "(prescient-persist-mode 1)";
          };

          vertico-prescient = {
            config = "(vertico-prescient-mode 1)";
          };

          consult = {
            bind' = ''
              ("C-h C-m" . consult-man)
              ("C-x C-b" . consult-bookmark)
              ("C-x C-i" . my/consult-imenu-or-outline)
              ("C-x C-m" . consult-minor-mode-menu)
              ("C-x C-r" . consult-ripgrep)
              ("C-x C-s" . consult-buffer)
              ("M-l"     . consult-goto-line)
              ("M-s"     . consult-line)
              ("M-v"     . consult-yank-from-kill-ring)
            '';

            init = "(recentf-mode 1)";
            custom = "(completion-in-region-function 'consult-completion-in-region)";
          };

          marginalia = {
            config = "(marginalia-mode 1)";
          };

          vertico = {
            config = "(vertico-mode 1)";
            custom = ''
              (vertico-count 30)
              (vertico-cycle t)
            '';
          };

          company = {
            hook = "prog-mode haskell-interactive-mode";
            custom = ''
              (company-dabbrev-downcase nil)
              (company-dabbrev-ignore-case t)
              (company-idle-delay 0)
              (company-minimum-prefix-length 1)
              (company-show-numbers t)
            '';
          };

          lsp-mode = {
            bind' = ''
              ("C-c C-a"     . lsp-execute-code-action)
              ("C-c C-d"     . lsp-ui-doc-focus-frame)
              ("C-c C-f C-d" . xref-find-definitions)
              ("C-c C-f C-i" . lsp-find-implementation)
              ("C-c C-f C-r" . xref-find-references)
              ("C-c C-o"     . lsp-organize-imports)
              ("C-c C-r"     . lsp-rename)
            '';

            hook = ''
              (c++-mode        . lsp-deferred)
              (c-mode          . lsp-deferred)
              (caddyfile-mode  . lsp-deferred)
              (glsl-mode       . lsp-deferred)
              (go-mode         . lsp-deferred)
              (haskell-mode    . lsp-deferred)
              (js-mode         . lsp-deferred)
              (nix-mode        . lsp-deferred)
              (rustic-mode     . lsp-deferred)
              (sh-mode         . lsp-deferred)
              (typescript-mode . lsp-deferred)
              (typst-ts-mode   . lsp-deferred)
              (web-mode        . lsp-deferred)
              (zig-mode        . lsp-deferred)
            '';

            custom = ''
              (eldoc-idle-delay 0)
              (lsp-headerline-breadcrumb-enable nil)
              (lsp-idle-delay 0)
              (lsp-inlay-hint-enable t)
              (lsp-log-io nil)
              (read-process-output-max (* 1024 1024))

              ; custom client args
              (lsp-clients-clangd-args '("--header-insertion=never"))
            '';

            config = ''
              (advice-add 'lsp-mode :before
                #'lsp-inline-completion-company-integration-mode)
            '';

            extraPackages = with pkgs; [
              clang-tools # c-mode

              # sh-mode
              bash-language-server
              shellcheck
            ];
          };

          lsp-ui = {
            hook = "lsp-mode";
            custom = ''
              (lsp-ui-sideline-show-code-actions t)
              (lsp-ui-sideline-show-diagnostics t)
              (lsp-ui-sideline-show-hover nil)
              (lsp-ui-sideline-delay 0)
              (lsp-ui-doc-delay 0)
              (lsp-ui-doc-show-with-cursor t)
            '';
          };

          ##### Languages #####

          caddyfile-mode = {
            mode = ''"Caddyfile"'';

            hook = ''
              (caddyfile-mode . (lambda ()
                (setq-local tab-width 4)))
            '';

            config = ''
              (require 'lsp-mode)
              (add-to-list 'lsp-language-id-configuration '(caddyfile-mode . "caddyfile"))
              (lsp-register-client (make-lsp-client
                                    :new-connection (lsp-stdio-connection '("caddyfile-language-server" "--stdio"))
                                    :activation-fn (lsp-activate-on "caddyfile")
                                    :server-id 'caddyfile-language-server))
            '';

            extraPackages = with pkgs; [
              caddy # formatting
              caddyfile-language-server
            ];
          };

          glsl-mode = {
            mode = ''
              "\\.frag\\'"
              "\\.glsl\\'"
              "\\.vert\\'"
            '';

            config = ''
              (require 'lsp-mode)
              (setq lsp-glsl-executable '("glsl_analyzer"))

              (require 'apheleia)
              (add-to-list 'apheleia-mode-alist '(glsl-mode . clang-format))
            '';

            extraPackages = with pkgs; [ glsl_analyzer ];
          };

          go-mode = {
            mode = ''"\\.go\\'"'';
            extraPackages = with pkgs; [ gopls ];
          };

          haskell-mode = {
            mode = ''"\\.hs\\'"'';

            bind' = ''(
            :map haskell-mode-map
            ("C-c C-p" . haskell-interactive-switch)
          )'';

            hook = ''
              (haskell-interactive-mode . (lambda ()
                (bind-key "C-a" 'haskell-interactive-mode-beginning        'haskell-interactive-mode-map)
                (bind-key "C-l" 'haskell-interactive-mode-clear            'haskell-interactive-mode-map)
                (bind-key "C-n" 'haskell-interactive-mode-history-next     'haskell-interactive-mode-map)
                (bind-key "C-p" 'haskell-interactive-mode-history-previous 'haskell-interactive-mode-map)
                (bind-key "C-r" 'my/haskell-reload                         'haskell-interactive-mode-map)))
            '';

            config = ''
              (advice-add 'haskell-mode :before (lambda ()
                (require 'lsp-haskell)))

              (advice-add 'haskell-mode :after (lambda ()
                (add-hook 'after-save-hook 'my/haskell-reload)))

              (require 'apheleia)
              (add-to-list 'apheleia-mode-alist '(haskell-mode . fourmolu))
              (add-to-list 'apheleia-formatters '(fourmolu "fourmolu" "--no-cabal"))
            '';

            custom = ''
              (haskell-interactive-popup-errors nil)
            '';

            extraPackages = with pkgs; [ fourmolu ];
          };

          json-mode = { mode = ''"\\.json\\'"''; };

          lsp-haskell = { defer = true; };

          lsp-pyright = {
            hook = ''
              (python-mode . (lambda ()
                (require 'lsp-pyright)
                (lsp-deferred)))
            '';

            custom = ''
              (lsp-pyright-langserver-command "basedpyright")
            '';

            extraPackages = with pkgs; [ basedpyright ];
          };

          nftables-mode = { mode = ''"\\.nft\\'"''; };

          nix-mode = {
            mode = ''"\\.nix\\'"'';
            extraPackages = with pkgs; [
              nil
              nixpkgs-fmt
            ];

            config = ''
              (require 'apheleia)
              (add-to-list 'apheleia-mode-alist '(nix-mode . nixpkgs-fmt))
              (add-to-list 'apheleia-formatters '(nixpkgs-fmt "nixpkgs-fmt"))
            '';
          };

          pug-mode = {
            mode = ''"\\.pug\\'"'';

            hook = "(pug-mode . (lambda () (indent-tabs-mode 0)))";

            config = ''
              (require 'apheleia)
              (add-to-list 'apheleia-mode-alist '(pug-mode . prettier))
            '';
          };

          rustic = {
            mode = ''("\\.rs\\'" . rustic-mode)'';
            custom = ''
              (lsp-rust-analyzer-cargo-watch-command "clippy")
            '';
            extraPackages = with pkgs; [
              clippy
              rust-analyzer
              rustfmt
            ];
          };

          yaml-mode = {
            mode = ''
              "\\.yaml\\'"
              "\\.yml\\'"
            '';
          };

          typescript-mode = {
            mode = ''"\\.ts\\'"'';
            extraPackages = with pkgs.nodePackages; [
              typescript
              typescript-language-server
            ];
          };

          web-mode = {
            mode = ''
              "\\.svelte\\'"
            '';

            extraPackages = with pkgs; [
              svelte-language-server
            ];
          };

          zig-mode = {
            package = epkgs: epkgs.zig-mode.overrideAttrs {
              # stub out reformatter (zig-mode wants it, but we use apheleia)
              packageRequires = [
                (epkgs.trivialBuild {
                  pname = "reformatter";
                  version = "0";

                  src = pkgs.writeText "reformatter.el" ''
                    (defmacro reformatter-define (&rest args)
                      '(defun zig-format-on-save-mode (&rest args)))

                    (provide 'reformatter)
                  '';
                })
              ];
            };

            mode = ''"\\.zig\\'"'';

            extraPackages = with pkgs; [ zls ];
          };

          # Lisp

          lisp-extra-font-lock = {
            hook = "lisp-data-mode";
            config = "(lisp-extra-font-lock-global-mode 1)";
          };

          parinfer-rust-mode = {
            hook = "lisp-data-mode";
            custom = "(parinfer-rust-auto-download t)";
            config = ''
              ; disable things that break Lisp editing
              (advice-add 'parinfer-rust-mode :before (lambda ()
                (indent-tabs-mode 0)))
            '';
          };

          # Typst

          typst-ts-mode = {
            package = epkgs: epkgs.trivialBuild {
              pname = "typst-ts-mode";
              version = "2024-12-07";

              src = pkgs.fetchFromSourcehut {
                owner = "~meow_king";
                repo = "typst-ts-mode";
                rev = "1367003e2ad55a2f6f9e43178584683028ab56e9";
                hash = "sha256-0RAJ/Td3G7FDvzf7t8csNs/uc07WUPGvMo8ako5iyl0=";
              };
            };

            extraPackages = with pkgs; [
              typst
              prettypst # formatter

              # tinymist (LSP) patched to remove partial-rendering
              # (which breaks the live preview)
              (pkgs.writeShellApplication {
                name = "tinymist";
                runtimeInputs = with pkgs; [ tinymist ];
                text = ''
                  args=()
                  for i in "$@"; do
                    [ "$i" != "--partial-rendering" ] && args+=("$i")
                  done
                  exec tinymist "''${args[@]}"
                '';
              })
            ];

            mode = ''"\\.typ\\'"'';

            config = ''
              (require 'lsp-mode)
              (add-to-list 'lsp-language-id-configuration '(typst-ts-mode . "typst"))
              (lsp-register-client
               (make-lsp-client
                :new-connection (lsp-stdio-connection "tinymist")
                :major-modes '(typst-ts-mode)
                :server-id 'tinymist))

              (require 'apheleia)
              (add-to-list 'apheleia-mode-alist '(typst-ts-mode . prettypst))
              (add-to-list 'apheleia-formatters '(prettypst "prettypst" "--use-std-in" "--use-std-out"))
            '';
          };

          typst-preview = {
            package = epkgs: epkgs.trivialBuild {
              pname = "typst-preview";
              version = "2024-10-26";

              src = pkgs.fetchFromGitHub {
                owner = "havarddj";
                repo = "typst-preview.el";
                rev = "7443e227462f6563559fde45dc500cb03ee253bb";
                hash = "sha256-7YWPWLRNgF9N91xW0QpMPhwZ57iCsgkDY4rNY/6lf6c=";
              };

              packageRequires = with epkgs; [ websocket ];
            };

            hook = "typst-ts-mode";

            custom = ''
              (typst-preview-invert-colors "never")
              (typst-preview-open-browser-automatically t)
            '';

            config = ''
              (advice-add 'typst-preview-start :before (lambda (&rest r)
                (setq tp--master-file buffer-file-name)))
            '';
          };

          # tip = {
          #   package = epkgs: epkgs.trivialBuild {
          #     pname = "tip";
          #     version = "2024-09-07";

          #     src = pkgs.fetchFromSourcehut {
          #       owner = "~mafty";
          #       repo = "tip";
          #       rev = "2ccfe1e7f9675ed612275d88f046fead0bb9dc6d";
          #       hash = "sha256-G2GxnvSFz35Ay8FNdAfUF+Nvhf25xlEm6vKJQtN/350=";
          #     };

          #     patches = [
          #       ./patches/tip/0001-use-cl-sort-instead-of-builtin-sort.patch
          #     ];
          #   };

          #   hook = "typst-ts-mode";

          #   extraPackages = [ (import ./tip-server.nix pkgs) ];
          # };
        };
      };
    }];
  };
}
