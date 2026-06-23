;; -*- lexical-binding: t; -*-

(require 'treesit)

(use-package kotlin-mode :mode ("\\.kt\\'" . kotlin-mode))
(use-package kotlin-ts-mode)
;; 1. 设置解析器下载路径 (Arch Linux 的自动下载源)
(setq treesit-language-source-alist
      '((bash "https://github.com/tree-sitter/tree-sitter-bash")
        (c "https://github.com/tree-sitter/tree-sitter-c")
        (cpp "https://github.com/tree-sitter/tree-sitter-cpp")
        (python "https://github.com/tree-sitter/tree-sitter-python")
        (rust "https://github.com/tree-sitter/tree-sitter-rust")
	(yaml "https://github.com/ikatyang/tree-sitter-yaml")
        (toml "https://github.com/tree-sitter/tree-sitter-toml")
        (json "https://github.com/tree-sitter/tree-sitter-json")
	(kotlin "https://github.com/fwcd/tree-sitter-kotlin.git")
        (markdown "https://github.com/ikatyang/tree-sitter-markdown")))

;; 2. 定义一个辅助函数，自动检查并安装缺失的解析器
(defun my/install-treesit-grammars ()
  "自动安装必要的 treesit 解析器。"
  (interactive)
  (dolist (lang (mapcar #'car treesit-language-source-alist))
    (unless (treesit-language-available-p lang)
      (message "正在下载解析器: %s..." lang)
      (treesit-install-language-grammar lang))))

;; 3. 模式映射 (Major Mode Remapping)
;; 这是最优雅的方式，无需改动现有代码，直接将原生 mode 映射为 ts-mode
(setq major-mode-remap-alist
      '((c-mode . c-ts-mode)
        (c++-mode . c++-ts-mode)
        (python-mode . python-ts-mode)
        (rust-mode . rust-ts-mode)
        (json-mode . json-ts-mode)
	(kotlin-mode . kotlin-ts-mode)
        (markdown-mode . markdown-ts-mode)))
;; 1. YAML 和 Elisp 自动开启大纲模式（纯正则，零开销，绝不崩溃）
(add-hook 'yaml-ts-mode-hook #'outline-minor-mode)
(add-hook 'yaml-mode-hook #'outline-minor-mode)
(add-hook 'emacs-lisp-mode-hook #'outline-minor-mode)

;; 2. 针对你后续要折腾的现代语言（如 rust-ts-mode 编程环境），开启现代语法树折叠
(use-package treesit-fold
  :straight (treesit-fold :type git :host github :repo "emacs-tree-sitter/treesit-fold")
  :hook ((rust-ts-mode-hook
          python-ts-mode-hook
          c-ts-mode-hook
          c++-ts-mode-hook) . treesit-fold-mode))
(with-eval-after-load 'evil
  ;; 【智能 TAB】：局部展开/折叠
  (define-key evil-normal-state-map (kbd "<tab>")
              (lambda () (interactive)
                (cond
                 ((derived-mode-p 'yaml-ts-mode 'yaml-mode 'emacs-lisp-mode)
                  (outline-toggle-children))
                 ((bound-and-true-p treesit-fold-mode)
                  (treesit-fold-toggle))
                 (t (evil-toggle-fold)))))
  (define-key evil-normal-state-map (kbd "TAB") (lookup-key evil-normal-state-map (kbd "<tab>")))

  ;; 【智能 Shift + TAB】：全局一键全折叠/全展开
  (define-key evil-normal-state-map (kbd "<backtab>")
              (lambda () (interactive)
                (cond
                 ;; YAML 和 Elisp 分流：用绝对不崩溃的 Outline 物理一秒超度
                 ((derived-mode-p 'yaml-ts-mode 'yaml-mode 'emacs-lisp-mode)
                  (if (let ((first-heading (save-excursion (goto-char (point-min)) (outline-next-heading))))
                        (and first-heading (invisible-p (get-char-property (save-excursion (goto-char (point-min)) (outline-next-heading) (line-end-position)) 'invisible))))
                      (outline-show-all)
                    (outline-hide-sublevels 1)))
                 ;; 现代编程语言分流：交给语法树
                 ((bound-and-true-p treesit-fold-mode)
                  (treesit-fold-close-all))
                 (t (evil-close-folds))))))
;; YAML 自动开启大纲模式
(add-hook 'yaml-ts-mode-hook #'outline-minor-mode)
(add-hook 'yaml-mode-hook #'outline-minor-mode)

;; Elisp 开启大纲模式，并强行改写其“大纲标题”判定规则
(add-hook 'emacs-lisp-mode-hook
          (lambda ()
            ;; 1. 依然死认行首的左括号
            (setq-local outline-regexp "(")
            ;; 2. 核心补丁：强行规定只要匹配到，层级就是固定的 1，防止互相吞噬
            (setq-local outline-level (lambda () 1))
            (outline-minor-mode 1)))
;; 辅助微调：让 Outline 的全折叠行为更符合直觉（隐藏所有子节点）
(defun infra-get-char-property-atfirst-heading (prop)
  (save-excursion
    (goto-char (point-min))
    (when (outline-next-heading)
      (get-char-property (line-end-position) prop))))
(use-package flycheck
  :straight t
  :init (global-flycheck-mode))
;; 1. 安装并配置 Corfu (界面)
(use-package corfu
  :straight t
  :custom
  (corfu-auto t)                 ; 关闭自动弹出，完全手动控制
  ;; --- 关键：定义空格为分隔符 ---
  (corfu-separator ?\s)            ; 告诉 Corfu，空格是特殊字符，别关框
  (corfu-quit-at-boundary 'separator) ; 遇到分隔符（空格）时不要退出补全
  :init
  (global-corfu-mode)
  :bind
  ("M-i" . completion-at-point))   ; 绑定手动触发键

;; --- 1. Orderless 配置：核心过滤引擎 ---
(use-package orderless
  :straight t
  :custom
  ;; 定义补全风格：先尝试 orderless，不行再用 basic 兜底
  (completion-styles '(orderless basic))
  ;; 针对 Eglot (LSP) 的特殊优化，确保它不会被前缀匹配限制死
  (completion-category-overrides '((eglot (styles orderless basic))))
  )
;; 2. 配置 Eglot (大脑)
(use-package eglot
  :straight (:type built-in) ;使用Emacs内置版本
  :hook
  ((python-mode . eglot-ensure)  ; 进入 python-mode 自动启动
   (kotlin-mode . eglot-ensure)
   (rust-mode . eglot-ensure))
  :config
  ;; 让 Eglot 配合 Corfu 弹出文档
  (setq eldoc-echo-area-use-elisp-prefill t)
  (add-to-list 'eglot-server-programs
               '((kotlin-mode kotlin-ts-mode) . ("kotlin-language-server"))))



(provide 'init-programming)
;;; init-programmin-tools.el ends here

