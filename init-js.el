(add-to-list 'auto-mode-alist '("\\.js\\(on\\)?$" . js2-mode))

(add-hook 'js2-mode-hook 'run-coding-hook)
(add-hook 'js2-mode-hook 'idle-highlight)


(provide 'init-js)
