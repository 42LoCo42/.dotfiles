{ aquaris, config, lib, pkgs, ... }:
let
  inherit (lib) getExe mkForce mkIf mkOption remove;
  inherit (lib.types) bool str;

  cfg = config.rice.desktop.emacs;

  meson-fmt = pkgs.writeShellApplication {
    name = "meson-fmt";
    runtimeInputs = with pkgs; [ meson ];
    text = ''
      if out="$(meson fmt - | sed 's|    |	|g')"; then
        echo "$out"
      else
        echo "$out" >&2
        exit 1
      fi
    '';
  };
in
{
  options.rice.desktop.emacs = {
    enable = mkOption {
      type = bool;
      default = false;
    };

    alpha = mkOption {
      type = str;
      default = toString config.rice.desktop.alpha;
    };
  };

  config = mkIf cfg.enable {
    home-manager.sharedModules = [{
      home.shellAliases."e" = "emacsclient -cn";

      programs.emacs.overrides = _: epkgs: {
        lsp-mode = epkgs.lsp-mode.overrideAttrs (old: {
          buildPhase = ''
            export LSP_USE_PLISTS=true
          '' + (old.buildPhase or "");
        });

        # stub out reformatter (zig-mode wants it, but we use apheleia)
        reformatter = epkgs.trivialBuild {
          pname = "reformatter";
          version = "0";

          src = pkgs.writeText "reformatter.el" ''
            (defmacro reformatter-define (&rest args)
              '(defun zig-format-on-save-mode (&rest args)))

            (provide 'reformatter)
          '';
        };
      };

      services.emacs = {
        enable = true;
        startWithUserSession = "graphical";
      };

      systemd.user = {
        tmpfiles.rules = lib.pipe [ "en_US-large" "de_DE" ] [
          (map (x: pkgs.hunspellDicts.${x}))
          (x: pkgs.symlinkJoin {
            name = "hunspell-dicts";
            paths = x;
          })
          (x: [ "L+ %h/.config/enchant/hunspell - - - - ${x}/share/hunspell" ])
        ];

        services.emacs.Service = {
          Environment = [ "LSP_USE_PLISTS=true" ];
          Restart = mkForce "always";
        };
      };

      xdg.configFile = {
        "fourmolu.yaml".source = ./fourmolu.yaml;
        "pedantix/pedantix.toml".source = ./pedantix.toml;
      };

      aquaris.persist = { ".config/emacs" = { }; };

      aquaris.emacs = {
        enable = true;
        package = pkgs.emacs-pgtk;

        extraPackages = epkgs: with epkgs; [
          (treesit-grammars.with-grammars (g: with g; [
            tree-sitter-hyprlang
            tree-sitter-typst
          ]))
        ];

        usePackage.statistics = true;

        prelude = aquaris.lib.subsT ./prelude.el {
          splash = builtins.path {
            path = ./splash.webp;
          };
        };

        postlude = ''
          (setq cua-remap-control-v nil)
          (cua-mode 1)
          (bind-key "C-v" 'cua-paste)
          (load "bootstrap") ; init straight.el
        '';

        config = {
          ##### Basic configuration #####

          emacs = {
            bind = ''
              ("C-a" . my/smart-home)
              ("M-=" . count-words)

              ;; delete a Nix sha256 hash
              ("C-M-d" . (lambda () (interactive) (delete-char 51)))
            '';

            bind' = ''
              ("C-M-<backspace>" . my/join-line)
              ("C-s"             . save-buffer)

              ("C-x C-f" . find-file)
              ("C-x C-l" . scratch-buffer) ; L for Lisp

              ("C-#"   . (lambda () (interactive) (select-window (next-window))))
              ("M-#"   . (lambda () (interactive) (select-window (previous-window))))
              ("M-e"   . forward-word)
              ("M-f"   . forward-to-word)
              ("M-n"   . scroll-up-command)
              ("M-p"   . scroll-down-command)

              ("C-x C-a" . mark-whole-buffer)
              ("C-x C-k" . (lambda () (interactive) (kill-buffer (current-buffer))))

              ("C-c C-s" . sort-lines)
              ("C-c C-x" . my/align-regexp)

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
            '';

            hook = ''
              ; delete trailing whitespace on save
              (before-save . delete-trailing-whitespace)

              ; send a graphical notification on startup
              (emacs-startup . my/startup-notify)

              ; disable tabs in org-mode
              (org-mode . (lambda () (indent-tabs-mode 0)))

              ; show matching parentheses
              (prog-mode . show-paren-mode)
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
                ${cfg.alpha})
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
              (backup-directory-alist         `(("." . ,my/temp-dir  )))
              (lock-file-name-transforms      `((".*"  ,my/temp-dir t)))

              (backward-delete-char-untabify-method nil)
              (c-backspace-function 'delete-backward-char)

              (c-basic-offset 4)
              (sgml-basic-offset 4)
              (tab-width 4)

              (fill-column 80)
              (inhibit-startup-screen t)
              (initial-scratch-message ";;; -*- lexical-binding: t -*-\n")
              (native-comp-async-report-warnings-errors nil)
              (recenter-positions '(middle top))
              (recentf-max-saved-items 100)
              (require-final-newline t)
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

              (show-paren-delay                   0)
              (show-paren-when-point-in-periphery t)
              (show-paren-context-when-offscreen  'overlay)

              (org-startup-indented t)
            '';

            extraPackages = with pkgs; [
              ghostscript # PDF rendering support
            ];
          };

          server = {
            custom = "(server-client-instructions nil)";
          };

          straight = {
            defer = true;
          };

          gcmh = {
            init = "(gcmh-mode 1)";
            custom = "(gcmh-verbose t)";
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

            custom = "(display-line-numbers-type 'visual)";
          };

          telephone-line = {
            config = ''
              (telephone-line-mode 1)
            '';

            custom = ''
              (telephone-line-secondary-left-separator my/telephone-line-space)

              (telephone-line-lhs
               '((accent . (telephone-line-vc-segment
                            telephone-line-process-segment))
                 (nil    . (my/telephone-line-project-cached-segment
                            my/telephone-line-buffer-segment
                            my/telephone-line-crdt-segment
                            my/telephone-line-symbol-segment))))
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
              (whitespace-style '(face tab-mark trailing missing-newline-at-eof))
            '';
          };

          org-bullets = {
            hook = "org-mode";
          };

          dimmer = {
            custom = ''
              (dimmer-fraction 0.3)
            '';

            config = ''
              (dimmer-mode 1)
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
              (flycheck-display-errors-function nil)
              (flycheck-help-echo-function nil)
            '';

            config = ''
              (my/flycheck-setup)
            '';
          };

          jinx = {
            hook = "typst-ts-mode org-mode text-mode";

            bind' = ''
              ("C-M-i" . jinx-correct)
            '';

            config = ''
              (require 'vertico-multiform)

              (add-to-list 'vertico-multiform-categories
                '(jinx grid (vertico-grid-annotate . 20) (vertico-count . 4)))

              (vertico-multiform-mode)
            '';

            custom = ''
              (jinx-languages "en_US de_DE")
            '';
          };

          apheleia = {
            bind' = ''
              ("C-<tab>" . apheleia-format-buffer)
            '';

            hook = "prog-mode typst-ts-mode bibtex-mode";

            config = ''
              (add-to-list 'apheleia-mode-alist '(sh-mode . shfmt))

              (add-to-list 'apheleia-mode-alist '(bibtex-mode . bibtex-tidy))
              (add-to-list 'apheleia-formatters '(bibtex-tidy
                "bibtex-tidy" "--tab" "--blank-lines"))

              (add-to-list 'apheleia-mode-alist '(c-mode   . my/clang-format))
              (add-to-list 'apheleia-mode-alist '(c++-mode . my/clang-format))
              (add-to-list 'apheleia-formatters '(my/clang-format
                "clang-format" "--style=file:${./clang-format.yaml}"))

              (setf (alist-get 'python-mode apheleia-mode-alist)
                    '(isort black))
            '';

            extraPackages = with pkgs; [
              bibtex-tidy
              black # python-mode
              isort # python-mode
              prettier # JS and others
              shfmt # shell
            ];
          };

          flash = {
            bind' = ''
              ("M-c" . flash-jump)
            '';

            custom = ''
              (flash-rainbow       t)
              (flash-rainbow-shade 5)
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
              ("C-;" . mc/unmark-previous-like-this)

              ("C-." . mc/mark-next-like-this)
              ("C-:" . mc/unmark-next-like-this)
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
              packageRequires = remove epkgs.org old.packageRequires;
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

            bind' = ''
              :map minibuffer-mode-map
              ("M-DEL" . sp-backward-kill-symbol)
            '';
          };

          crdt = {
            bind' = ''
              ("C-r C-c" . crdt-connect)
              ("C-r C-f" . crdt-follow-user)
              ("C-r C-g" . crdt-goto-user)
              ("C-r C-l" . crdt-list-buffers)
              ("C-r C-o" . crdt-share-buffer) ; "open"
              ("C-r C-s" . crdt-switch-to-buffer)
              ("C-r C-u" . crdt-stop-follow) ; "unfollow"
            '';

            custom = ''
              (crdt-default-name "nori")
            '';

            config = ''
              (advice-add #'crdt-follow-user :after #'crdt-goto-user)
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
              ("C-x C-v" . consult-fd)
              ("M-l"     . consult-goto-line)
              ("M-s"     . consult-line)
              ("M-v"     . consult-yank-from-kill-ring)
            '';

            init = "(recentf-mode 1)";
            custom = "(completion-in-region-function 'consult-completion-in-region)";

            extraPackages = with pkgs; [
              fd
              ripgrep
            ];
          };

          consult-flycheck = {
            bind' = ''
              ("C-x C-c" . consult-flycheck)
            '';
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

            bind' = ''
              ("M-SPC" . company-complete)
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
              (glsl-mode       . lsp-deferred)
              (go-mode         . lsp-deferred)
              (haskell-mode    . lsp-deferred)
              (js-mode         . lsp-deferred)
              (lua-mode        . lsp-deferred)
              (nix-mode        . lsp-deferred)
              (php-mode        . lsp-deferred)
              (rustic-mode     . lsp-deferred)
              (sh-mode         . lsp-deferred)
              (terraform-mode  . lsp-deferred)
              (typescript-mode . lsp-deferred)
              (typst-ts-mode   . lsp-deferred)
              (web-mode        . lsp-deferred)
              (zig-mode        . lsp-deferred)

              (lsp-managed-mode . (lambda ()
                (require 'lsp-headerline)
                (add-hook 'eldoc-documentation-functions #'my/flycheck-eldoc 90 t)
                (my/chain nix-mode deadnix)
                (my/chain zig-mode zlint)))
            '';

            custom = ''
              (eldoc-idle-delay 0)
              (eldoc-documentation-strategy 'eldoc-documentation-compose-eagerly)

              (lsp-headerline-breadcrumb-enable nil)
              (lsp-idle-delay 0)
              (lsp-inlay-hint-enable t)
              (lsp-log-io nil)
              (lsp-modeline-diagnostics-scope :file)
              (read-process-output-max (* 1024 1024))

              ; custom client settings
              (lsp-clients-clangd-args '("--header-insertion=never"))
              (lsp-clients-lua-language-server-command "lua-language-server")

              (lsp-disabled-clients '(php-ls))
            '';

            config = ''
              (advice-add 'lsp-mode :before
                #'lsp-inline-completion-company-integration-mode)

              (advice-add 'json-parse-buffer :around
                #'lsp-booster--advice-json-parse)

              (advice-add 'lsp-resolve-final-command :around
                #'lsp-booster--advice-final-command)

              (advice-add 'lsp-clients-lua-language-server-test :override
                (lambda () t))
            '';

            extraPackages = with pkgs; [
              emacs-lsp-booster

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
            defer = true;

            hook = ''
              (caddyfile-mode . (lambda () (setq-local tab-width 4)))
            '';

            extraPackages = with pkgs; [
              caddy # formatting
            ];
          };

          glsl-mode = {
            defer = true;

            config = ''
              (require 'lsp-mode)
              (setq lsp-glsl-executable '("glsl_analyzer"))

              (require 'apheleia)
              (add-to-list 'apheleia-mode-alist '(glsl-mode . clang-format))
            '';

            extraPackages = with pkgs; [ glsl_analyzer ];
          };

          go-mode = {
            defer = true;
            extraPackages = with pkgs; [ gopls ];
          };

          haskell-mode = {
            bind' = ''
              :map haskell-mode-map
              ("C-c C-p" . haskell-interactive-switch)
            '';

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

          json-mode = { defer = true; };

          lsp-haskell = { defer = true; };

          lsp-pyright = {
            defer = true;

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

          nftables-mode = { defer = true; };

          nix-mode = {
            defer = true;

            extraPackages = with pkgs; [
              nil
              nixpkgs-fmt
              pedantix
            ];

            config = ''
              (require 'apheleia)
              (add-to-list 'apheleia-mode-alist '(nix-mode . pedantix))
              (add-to-list 'apheleia-formatters '(pedantix "pedantix"))
            '';
          };

          pug-mode = {
            defer = true;

            hook = "(pug-mode . (lambda () (indent-tabs-mode 0)))";

            config = ''
              (require 'apheleia)
              (add-to-list 'apheleia-mode-alist '(pug-mode . prettier))
            '';
          };

          rustic = {
            defer = true;

            custom = ''
              (lsp-rust-analyzer-cargo-watch-command "clippy")
            '';

            extraPackages = with pkgs; [
              clippy
              rust-analyzer
              rustfmt
            ];
          };

          yaml-mode = { defer = true; };

          typescript-mode = {
            defer = true;

            extraPackages = with pkgs; [
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
            defer = true;
            extraPackages = with pkgs; [
              zls

              zig-zlint
              (writeShellScriptBin "my-zlint" ''
                echo "$1" | zlint --stdin --format json
              '')
            ];
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
            defer = true;

            extraPackages = with pkgs; [
              prettypst # formatter
              tinymist # language server
              typst
            ];

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

            custom = ''
              (typst-ts-mode-indent-offset 2)
              (typst-ts-mode-enable-raw-blocks-highlight)
            '';
          };

          typst-preview = {
            hook = "typst-ts-mode";

            custom = ''
              (typst-preview-invert-colors "never")
              (typst-preview-open-browser-automatically t)
            '';

            config = ''
              ;; always set master file to current buffer; skip manual input
              (advice-add 'typst-preview-start :before (lambda (&rest r)
                (setq typst-preview--master-file (f-canonical buffer-file-name))))
            '';
          };

          hyprlang-ts-mode = {
            mode = ''"hypr.*\\.conf\\'"'';

            custom = ''
              (hyprlang-ts-mode-indent-offset 4)
            '';
          };

          terraform-mode = {
            defer = true;

            custom = ''
              (terraform-command "tofu")
            '';

            config = ''
              (require 'apheleia)
              (add-to-list 'apheleia-formatters '(terraform "tofu" "fmt" "-"))

              (require 'lsp-terraform)
              (setq lsp-terraform-server '("tofu-ls" "serve"))
            '';

            hook = ''
              (terraform-mode . (lambda () (indent-tabs-mode 0)))
            '';

            extraPackages = with pkgs; [
              opentofu
              tofu-ls
            ];
          };

          meson-mode = {
            custom = ''
              (meson-indent-basic 4)
            '';

            config = ''
              (require 'apheleia)
              (add-to-list 'apheleia-mode-alist '(meson-mode . meson-fmt))
              (add-to-list 'apheleia-formatters '(meson-fmt "${getExe meson-fmt}"))
            '';

            hook = ''
              (meson-mode . indent-tabs-mode)
            '';
          };

          just-mode = {
            defer = true;

            extraPackages = with pkgs; [
              just
            ];
          };

          php-mode = {
            defer = true;

            extraPackages = with pkgs; [
              phpactor
            ];
          };

          markdown-mode = {
            defer = true;

            hook = ''
              (markdown-mode . (lambda () (indent-tabs-mode 0)))
            '';
          };

          lua-mode = {
            defer = true;
            extraPackages = with pkgs; [
              lua-language-server
              stylua
            ];
          };
        };
      };
    }];
  };
}
