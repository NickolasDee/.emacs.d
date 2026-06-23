;; -*- lexical-binding: t; -*-


(global-set-key (kbd "s-K") 'kill-current-buffer)
(global-set-key (kbd "s-m") 'consult-bookmark)
(global-set-key (kbd "s-M-m") 'bookmark-delete)
(global-set-key (kbd "s-u") 'up-list)
(global-set-key (kbd "s-d") 'treesit-down-list)
(global-set-key (kbd "C-x b") 'consult-buffer)

(with-eval-after-load 'evil
    (global-set-key (kbd "s-g") 'evil-avy-goto-line)
  )
(provide 'init-keys)
