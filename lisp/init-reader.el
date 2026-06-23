;; -*- lexical-binding: t; -*-
(use-package org-noter
  :config
  (setq org-noter-always-create-frame nil)
  (setq org-noter-notes-search-path '("~/org/notes/")))

(use-package nov
  :mode ("\\.epub\\'" . nov-mode))
(setq nov-text-width t) ;; 自动调整宽度
(setq shr-indentation 2)

(with-eval-after-load 'evil
  (evil-set-initial-state 'nov-mode 'emacs))

;; ==========================================
;; 核心查词与联动逻辑
;; ==========================================

(defun my/search-in-goldendict ()
  "抓取光标词或划选区域，强行转换为全小写，并发送到 GoldenDict"
  (interactive)
  (let ((word (if (use-region-p)
                  (buffer-substring-no-properties (region-beginning) (region-end))
                (thing-at-point 'word t))))
    (if (and word (not (string-empty-p word)))
        (let ((clean-word (downcase (string-trim word))))
          (start-process "goldendict-call" nil "goldendict" clean-word))
      (message "没找到可以查询的单词"))))

(defun my/nov-mouse-click-search (event)
  "鼠标点击时自动移过去，并触发 GoldenDict 查词"
  (interactive "e")
  (posn-set-point (event-end event))
  (my/search-in-goldendict))

(defun my/avy-goto-word-and-search ()
  "用 avy 跳转落地后，直接触发 GoldenDict 查词"
  (interactive)
  (call-interactively #'avy-goto-word-1)
  (my/search-in-goldendict))

;; ==========================================
;; 快捷键与特定 Mode-Map 绑定
;; ==========================================

(with-eval-after-load 'nov
  (define-key nov-mode-map (kbd "v") #'my/search-in-goldendict)
  (define-key nov-mode-map (kbd "y") #'evil-yank)
  (define-key nov-mode-map (kbd "o") #'nov-goto-toc)
  (define-key nov-mode-map (kbd "f") #'my/avy-goto-word-and-search) ; 仅在 nov-mode 绑定联动版
  (define-key nov-mode-map [mouse-1] #'my/nov-mouse-click-search))

;; PDF 环境也安排上
(use-package pdf-tools
  :config
  (pdf-tools-install))
(with-eval-after-load 'pdf-view
  (define-key pdf-view-mode-map (kbd "v") #'my/search-in-goldendict)
  (define-key pdf-view-mode-map (kbd "f") #'my/avy-goto-word-and-search))
;; 1. 解决 PDF 视图下的全局行号冲突
(add-hook 'pdf-view-mode-hook (lambda () (display-line-numbers-mode -1)))
(with-eval-after-load 'evil
  (evil-define-key 'normal 'global (kbd "SPC v") #'my/search-in-goldendict))
(add-hook 'org-noter-notes-mode-hook
          (lambda ()
            ;; 在这个 buffer 局部，让 evil 的 motion/normal 映射直接向我们的函数让路
            (define-key evil-normal-state-local-map (kbd "RET") #'org-noter-sync-current-note)
            (define-key evil-motion-state-local-map (kbd "RET") #'org-noter-sync-current-note)))
(provide 'init-reader)
;;;init-reader.el ends here.
(provide 'init-reader)
;;; init-reader.el ends here.
