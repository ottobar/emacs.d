(unless window-system (if (fboundp 'menu-bar-mode) (menu-bar-mode -1)))
(if (fboundp 'tool-bar-mode) (tool-bar-mode -1))
(if (fboundp 'scroll-bar-mode) (scroll-bar-mode -1))
(if (fboundp 'column-number-mode) (column-number-mode t))

(setq dot-emacs-dot-d (file-name-directory
                    (or (buffer-file-name) load-file-name)))

(add-to-list 'load-path dot-emacs-dot-d)
(setq autoload-file (concat dot-emacs-dot-d "loaddefs.el"))
(add-to-list 'load-path (concat dot-emacs-dot-d "elpa"))
(setq package-user-dir (concat dot-emacs-dot-d "elpa"))
(setq custom-file (concat dot-emacs-dot-d "custom.el"))
(setq-default fill-column 100)

;; These should be loaded on startup rather than autoloaded on demand
;; since they are likely to be used in every session
(require 'cl)
(require 'saveplace)
(require 'ffap)
(require 'uniquify)
(require 'ansi-color)
(require 'recentf)
(require 'midnight)

;; ELPA
(require 'package)
(package-initialize)

;; Play nice with screen
(global-set-key (kbd "C-h") 'delete-backward-char)
(global-set-key (kbd "C-6") 'scroll-down)

;; Stuff adapted from the emacs starter kit
(require 'init-defuns)
(require 'init-bindings)
(require 'init-misc)
(require 'init-js)
(require 'init-ruby)
(require 'init-yaml)

;; Interactively do things
(require 'ido)
(ido-mode t)

;; Color-theme
;; I generally use clarity, twilight, or zenburn
(add-to-list 'load-path (concat dot-emacs-dot-d "color-theme-6.6.0"))
(require 'color-theme)
(eval-after-load "color-theme"
  '(progn
     (color-theme-initialize)
     (load-file (concat dot-emacs-dot-d "twilight.el"))
     (load-file (concat dot-emacs-dot-d "zenburn.el"))
     (if window-system
       (color-theme-twilight)
       (color-theme-clarity))))

;; Basically, I just want my cutomized default font
(load custom-file 'noerror)

;; Save place
(require 'saveplace)
(setq-default save-place t)

(require 'x12-mode)
(global-set-key (kbd "M-C-x m") 'x12-mode)
