;; -*- lexical-binding: t; -*-

;; init.el
;; 1. 声明引导代码
(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name "straight/repos/straight.el/bootstrap.el" user-emacs-directory))
      (bootstrap-get-url
       "https://raw.githubusercontent.com/radian-software/straight.el/develop/install.el"))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously bootstrap-get-url 'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))

;; 1. 必须最先执行，防止内置 Org 抢跑
(straight-use-package 'org)

;; 2. 让 use-package 默认使用 straight 安装
(setq straight-use-package-by-default t)
(straight-use-package 'use-package)
;; 告诉 straight 永远不要尝试安装这些内置包
(setq straight-built-in-pseudo-packages
      '(emacs project flymake eldoc xref eglot))

;;; 删掉或注释掉以下这几行,防止和straight竞争
;;;(require 'package)

;; 清空默认源，防止干扰
;;(setq package-archives nil)

;; 设置中国科学技术大学 (USTC) 镜像源
;; Melpa 是 Emacs 插件最全的仓库
;;(add-to-list 'package-archives '("melpa" . "https://mirrors.ustc.edu.cn/elpa/melpa/") t)
;; Org 源
;;(add-to-list 'package-archives '("org" . "https://mirrors.ustc.edu.cn/elpa/org/") t)
;; GNU ELPA 源
;;(add-to-list 'package-archives '("gnu" . "https://mirrors.ustc.edu.cn/elpa/gnu/") t)


;; 设置 lisp 目录到搜索路径
(add-to-list 'load-path (expand-file-name "lisp" user-emacs-directory))

;; 加载各个模块

(require 'init-settings)
(require 'init-evil)
(require 'init-reader)
(require 'init-tools)
;; vterm 不适合windows或android
(when (and (eq system-type 'gnu/linux)
	   (not (featurep 'android)))
  (require 'init-vterm))
(require 'init-org)
(require 'init-keys)
(require 'init-programming)
(message "Emacs 配置文件加载完成！")

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
