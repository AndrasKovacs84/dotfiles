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
;;
;;(setq doom-font (font-spec :family "Fira Code" :size 12 :weight 'semi-light)
;;      doom-variable-pitch-font (font-spec :family "Fira Sans" :size 13))
;;
;; If you or Emacs can't find your font, use 'M-x describe-font' to look them
;; up, `M-x eval-region' to execute elisp code, and 'M-x doom/reload-font' to
;; refresh your font settings. If Emacs still can't find your font, it likely
;; wasn't installed correctly. Font issues are rarely Doom issues!
(setq doom-font (font-spec :family "VictorMono Nerd Font Mono" :size 12))

;; Make comments and strings use Victor Mono italic (cursive)
(custom-set-faces!
  '(font-lock-comment-face :slant italic)
  '(font-lock-doc-face     :slant italic)
  '(font-lock-string-face  :slant italic))

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-one)
;; (set-frame-parameter nil 'alpha-background 75)
;; (add-to-list 'default-frame-alist '(alpha-background . 75))


;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type 'relative)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")

;; Set tab width to 4 everywhere and use spaces instead of actual tabs
(setq-default tab-width 4)
(setq-default indent-tabs-mode nil)  ;; nil = use spaces, t = use tabs
(setq-default standard-indent 4)
(setq-default indent-line-function 'insert-tab)
(setq-default c-basic-offset 4)

(setq tab-always-indent 'complete)

;; Turn off aggressive indenting
(remove-hook 'doom-first-buffer-hook #'global-electric-indent-mode)
(add-hook! 'prog-mode-hook (electric-indent-local-mode -1))

;; Also set this for some major modes that like to do their own thing
(setq-hook! 'prog-mode-hook
  tab-width 4
  indent-tabs-mode nil)

(setq whitespace-style '(face tabs spaces trailing newline newline-mark tab-mark space-mark))
(global-whitespace-mode 1)

(setq whitespace-display-mappings
      '((space-mark   ?\     [183]     [46])      ; space → · (183) or .
        (newline-mark ?\n    [182 10])            ; newline → ¶ (182)
        (tab-mark     ?\t    [9655 9]  [92 9])))  ; tab → ▷ or \t

(add-hook 'prog-mode-hook #'whitespace-mode)

(after! emacs
  (pixel-scroll-precision-mode))
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
;;
;;
;; (use-package! hungry-delete
;;   :config
;;   (global-hungry-delete-mode))

(use-package! winum
  :config
  (winum-mode)
  ;; Optional: make SPC 1..9 switch to window 1..9
  (map! :leader
        "1" #'winum-select-window-1
        "2" #'winum-select-window-2
        "3" #'winum-select-window-3
        "4" #'winum-select-window-4
        "5" #'winum-select-window-5
        "6" #'winum-select-window-6
        "7" #'winum-select-window-7
        "8" #'winum-select-window-8
        "9" #'winum-select-window-9))

(after! gdb
  (setq gdb-many-windows t
        gdb-show-main t))

(after! persp-mode
  ;; Save session on exit
  (add-hook 'kill-emacs-hook
            (lambda ()
              (when (fboundp 'persp-state-save)
                (persp-state-save (concat doom-cache-dir "persp-auto-save")))))

  ;; Session management config
  (setq persp-autokill-buffer-on-remove 'kill-weak
        persp-save-dir (concat doom-cache-dir "persp/")
        persp-auto-save-num-of-backups 10
        persp-auto-resume-time 1
        persp-auto-save-opt 2
        +workspaces-on-startup-behavior 'restore-last))

;; Centaur tabs
(setq centaur-tabs-style "slant")
(setq centaur-tabs-set-bar "under")
