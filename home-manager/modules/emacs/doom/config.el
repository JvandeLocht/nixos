;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
;; (setq user-full-name "John Doe"
;;       user-mail-address "john@doe.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom:
;;
;; - `doom-font' -- the primary font to use
;; - `doom-variable-pitch-font' -- a non-monospace font (where applicable)
;; - `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;; - `doom-symbol-font' -- for symbols
;; - `doom-serif-font' -- for the `fixed-pitch-serif' face
;;
;; See 'C-h v doom-font' for documentation and more examples of what they
;; accept. For example:

(when (string-match "nixwsl" (system-name))
  (setq doom-font (font-spec :family "Fira Code" :size 11 :weight 'semi-light)
        doom-variable-pitch-font (font-spec :family "Fira Sans" :size 11))
  (setq vterm-shell "/home/jan/.nix-profile/bin/zsh"))


(when (string-match "groot" (system-name))
  (setq doom-font (font-spec :family "Fira Code" :size 18 :weight 'semi-light)
        doom-variable-pitch-font (font-spec :family "Fira Sans" :size 18)))

;; (setq doom-font (font-spec :family "Fira Code" :size 20 :weight 'semi-light)
;;       doom-variable-pitch-font (font-spec :family "Fira Sans" :size 20))
;;
;; If you or Emacs can't find your font, use 'M-x describe-font' to look them
;; up, `M-x eval-region' to execute elisp code, and 'M-x doom/reload-font' to
;; refresh your font settings. If Emacs still can't find your font, it likely
;; wasn't installed correctly. Font issues are rarely Doom issues!

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-one)

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type 'relative)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")


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
;; they are implemented.
(use-package lsp-mode
  :ensure t
  :config
  ;; Ensure lsp-mode is loaded before modifying lsp-language-id-configuration
  (add-to-list 'lsp-language-id-configuration '(typst-ts-mode . "tinymist")))

(use-package websocket)
(use-package typst-preview
  :load-path "directory-of-typst-preview.el"
  :config
  (setq typst-preview-open-browser-automatically nil)
  (setq typst-preview-ask-if-pin-main nil)
  (setq typst-preview-host "127.0.0.1:11111")
  )
(use-package typst-ts-mode
  :load-path "directory-of-typst-ts-mode.el"
  :custom
  ;; don't add "--open" if you'd like `watch` to be an error detector
  (typst-ts-mode-watch-options "--open")
  :config
  (add-to-list 'lsp-language-id-configuration '(typst-ts-mode . "typst"))
  (lsp-register-client
   (make-lsp-client
    :new-connection (lsp-stdio-connection "typst-lsp")
    :major-modes '(typst-ts-mode)
    :server-id 'typst-lsp))
  )

(defun +vterm/here-lazygit ()
  "Open lazygit in vterm buffer named after Git repository"
  (interactive)
  (require 'magit)
  (let* ((git-root (magit-toplevel))
         (remote-url (magit-git-string "remote" "get-url" "origin"))
         (repo-name (if remote-url
                        (replace-regexp-in-string
                         ".*/\\([^/]+?\\)\\(\.git\\)?$" "\\1" remote-url)
                      (file-name-nondirectory
                       (directory-file-name git-root))))
         (buffer-name (format "lazygit-%s" repo-name)))
    (unless git-root
      (error "Not in a Git repository"))
    (+vterm/here nil)
    (vterm-send-string "lazygit")
    (vterm-send-return)
    (rename-buffer buffer-name t)))
(map! :leader
      :prefix "o"
      :desc "Lazygit" "L" #'+vterm/here-lazygit)

(use-package eee
  ;; :load-path "~/Projects/github.com/eval-exec/eee.el/"
  :after-call (doom-real-buffer-p) ; Defer loading until after startup
  :bind-keymap
  :bind-keymap
  ("s-e" . ee-keymap)
  :config

  ;; Should have wezterm or alacritty installed, more terminal application is supporting...
  ;; Issues and pull requests are welcome
  ;; (setq ee-terminal-command "st -z 16 -G 1400x1000")
  (when (string-match "nixwsl" (system-name))
    (setq ee-terminal-command "st -z 16 -G 1400x1000"))
  (when (string-match "groot" (system-name))
    (setq ee-terminal-command "kitty"))

  ;; (global-definer "f" 'ee-find)
  ;; (global-definer "g" 'ee-lazygit)
  ;; (global-definer "y" 'ee-yazi-project)
  ;; (general-def "C-x C-f" 'ee-yazi)
  ;; (general-def "C-S-f" 'ee-rg)
  ;; (general-evil-define-key 'normal 'global "M-f" 'ee-line
  )

;; Keybinds
(map! :leader
      :prefix "e"
      :desc "Yazi" "y" #'ee-yazi)
(map! :leader
      :prefix "e"
      :desc "Find" "f" #'ee-rg)
(map! :leader
      :prefix "e"
      :desc "Lazygit" "g" #'ee-lazygit)
(map! :leader
      :prefix "t"
      :desc "Typst Preview" "p" #'typst-preview-mode)
(map! :leader
      :prefix "t"
      :desc "Typst Preview Sync" "P" #'typst-preview-send-position)
(map! :leader
      :prefix "t"
      :desc "Treemacs" "t" #'treemacs)

;; C++ Development Configuration
(after! cc-mode
  ;; Set C++ indentation style
  (setq c-default-style "linux"
        c-basic-offset 4)

  ;; Auto-format on save for C/C++ files
  (add-hook 'c-mode-hook
            (lambda () (add-hook 'before-save-hook 'lsp-format-buffer nil t)))
  (add-hook 'c++-mode-hook
            (lambda () (add-hook 'before-save-hook 'lsp-format-buffer nil t)))

  ;; Modern C++ standards
  (setq c-c++-default-mode-for-headers 'c++-mode)  ; Treat .h files as C++

  ;; C++ specific keybindings
  (map! :map c++-mode-map
        :localleader
        :desc "Compile" "c" #'compile
        :desc "Recompile" "C" #'recompile
        :desc "Switch header/source" "a" #'ff-find-other-file))

;; LSP configuration for C++
(after! lsp-mode
  ;; Configure clangd for C++
  (setq lsp-clients-clangd-args
        '("--background-index"
          "--clang-tidy"
          "--completion-style=detailed"
          "--header-insertion=never"
          "--header-insertion-decorators=0"
          "-j=4"
          "--pch-storage=memory"))

  ;; Performance tuning
  (setq lsp-idle-delay 0.5
        lsp-log-io nil))

;; CMake integration
(after! cmake-mode
  (add-hook 'cmake-mode-hook #'lsp!))

(use-package! direnv
  :config
  (direnv-mode)
  ;; Optional: update environment when switching projects
  (add-hook 'projectile-after-switch-project-hook #'direnv-update-environment))
