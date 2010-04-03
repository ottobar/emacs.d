;; You know, like Readline
(global-set-key (kbd "C-M-h") 'backward-kill-word)

;; Align your code in a pretty way
(global-set-key (kbd "C-x \\") 'align-regexp)

;; Completion that uses many different methods to find options
(global-set-key (kbd "M-/") 'hippie-expand)

;; Comment out code
(global-set-key (kbd "C-;") 'comment-or-uncomment-region-or-line)

;; Perform general cleanup
(global-set-key (kbd "C-c n") 'cleanup-buffer)

;; Turn on the menu bar for exploring new modes
(global-set-key (kbd "C-<f10>") 'menu-bar-mode)

;; Font size
(define-key global-map (kbd "C-+") 'text-scale-increase)
(define-key global-map (kbd "C--") 'text-scale-decrease)

;; Use regex searches by default
(global-set-key (kbd "C-s") 'isearch-forward-regexp)
(global-set-key (kbd "\C-r") 'isearch-backward-regexp)
(global-set-key (kbd "C-M-s") 'isearch-forward)
(global-set-key (kbd "C-M-r") 'isearch-backward)

;; Jump to a definition in the current file (This is awesome)
(global-set-key (kbd "C-x C-i") 'ido-imenu)

;; File finding
(global-set-key (kbd "C-x M-f") 'ido-find-file-other-window)
(global-set-key (kbd "C-x C-M-f") 'find-file-in-project)
(global-set-key (kbd "C-x f") 'recentf-ido-find-file)
(global-set-key (kbd "C-c y") 'bury-buffer)
(global-set-key (kbd "C-c r") 'revert-buffer)
(global-set-key (kbd "M-`") 'file-cache-minibuffer-complete)
(global-set-key (kbd "C-x C-b") 'ibuffer)

;; Window switching (C-x o goes to the next window)
(windmove-default-keybindings) ;; Shift+direction
(global-set-key (kbd "C-x O") (lambda () (interactive) (other-window -1))) ;; back one
(global-set-key (kbd "C-x C-o") (lambda () (interactive) (other-window 2))) ;; forward two

;; Indentation help
(global-set-key (kbd "C-x ^") 'join-line)

;; If you want to be able to M-x without meta
(global-set-key (kbd "C-x C-m") 'execute-extended-command)

;; Fetch the contents at a URL, display it raw
(global-set-key (kbd "C-x C-h") 'view-url)
 
;; Git
(global-set-key (kbd "C-x g") 'magit-status)
;; This is a little hacky since VC doesn't support git add internally
(eval-after-load 'vc
  (define-key vc-prefix-map "i" '(lambda () (interactive)
                                   (if (not (eq 'Git (vc-backend buffer-file-name)))
                                       (vc-register)
                                     (shell-command (format "git add %s" buffer-file-name))
                                     (message "Staged changes.")))))

;; Activate occur easily inside isearch
(define-key isearch-mode-map (kbd "C-o")
  (lambda () (interactive)
    (let ((case-fold-search isearch-case-fold-search))
      (occur (if isearch-regexp isearch-string (regexp-quote isearch-string))))))


(provide 'init-bindings)
