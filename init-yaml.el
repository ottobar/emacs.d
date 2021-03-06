(require 'yaml-mode)
(add-to-list 'auto-mode-alist '("\\.ya?ml$" . yaml-mode))

(add-hook 'yaml-mode-hook
          '(lambda ()
            (run-coding-hook)
            (idle-highlight)
            (define-key yaml-mode-map (kbd "RET") 'newline-and-indent)))


(provide 'init-yaml)
