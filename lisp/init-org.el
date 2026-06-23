;; -*- lexical-binding: t; -*-

(use-package org-roam
  :straight t
  :demand t
  :init(setq org-roam-v2-ack t)
  :custom
  (org-roam-directory (file-truename "~/org-notes"))
  (org-roam-dailies-directory "daily/")
  (org-roam-completion-everywhere t)
  :config
  (org-roam-db-autosync-mode)
  (setq org-roam-completion-everywhere t))
(with-eval-after-load 'evil
  (evil-define-key 'normal 'global (kbd "SPC o") 'org-roam-node-find))
(with-eval-after-load 'flycheck
  (setq-default flycheck-disabled-checkers '(org-lint)))
(use-package consult-org-roam
  :straight t
  :after org-roam
  :demand t
  :init
  (require 'consult-org-roam)
  ;; 激活微模式，它会自动让原生的 org-roam-node-find 等命令支持预览
  (consult-org-roam-mode 1)
  :custom
  ;; 搜索时使用你 init-tools.el 里配好的 ripgrep
  (consult-org-roam-grep-func #'consult-ripgrep)
  :bind
  ;; 绑定几个极其好用的预览搜索命令
  ("s-n f" . consult-org-roam-file-find)
  ("s-n b" . consult-org-roam-backlinks)
  ("s-n l" . consult-org-roam-forward-links) ; 解决你之前想看“正向引用”的需求
  ("s-n s" . consult-org-roam-search))
(provide 'init-org)

