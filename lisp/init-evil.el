;; -*- lexical-binding: t; -*-
;; init-evil.el

(use-package evil
  
  :init
  ;; 在启动时立即启用 Evil 模式
  (setq evil-want-keybinding nil) ;; 配合 evil-collection 使用
  :config
  (evil-set-leader 'normal (kbd "SPC"))
  (evil-mode 1)
  )

;; evil-collection 是必装的，它能让 Evil 覆盖 Emacs 内置的各种模式
(use-package evil-collection
  
  :after evil
  :config
  (evil-collection-init))
(with-eval-after-load 'dirvish
  (evil-define-key 'normal 'global (kbd "SPC d") 'dirvish-dwim)
  (evil-define-key 'normal 'global (kbd "SPC f f") 'find-file)
  (evil-define-key 'normal 'global (kbd "f") 'evil-avy-goto-char)
  (evil-define-key 'visual 'global (kbd "f") 'evil-avy-goto-char)
  )

(with-eval-after-load 'dirvish
  (evil-define-key 'normal dirvish-mode-map
    (kbd "q") 'dirvish-quit       
    ))
(with-eval-after-load 'org-roam
  (evil-define-key 'normal 'global (kbd "SPC o") 'org-open-at-point))
(provide 'init-evil)
