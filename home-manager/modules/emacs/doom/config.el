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

(when (string-match "DTDEOBHNB303677" (system-name))
  (setq doom-font (font-spec :family "Fira Code" :size 11 :weight 'semi-light)
        doom-variable-pitch-font (font-spec :family "Fira Sans" :size 11)))

(when (string-match "groot" (system-name))
  (setq doom-font (font-spec :family "Fira Code" :size 20 :weight 'semi-light)
        doom-variable-pitch-font (font-spec :family "Fira Sans" :size 20)))

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
(setq display-line-numbers-type t)

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
  (setq typst-preview-open-browser-automatically -1)
  (setq typst-preview-host "127.0.0.1:11111")
  (define-key typst-preview-mode-map (kbd "C-c C-j") 'typst-preview-send-position)
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
