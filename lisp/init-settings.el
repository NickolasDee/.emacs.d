;; -*- lexical-binding: t; -*-
;; lisp/init-settings.el
(tool-bar-mode -1)
(menu-bar-mode -1)
(scroll-bar-mode -1)
(blink-cursor-mode 0)
(global-visual-line-mode 1)
(setq display-line-numbers-type t)
(global-display-line-numbers-mode 1)
(setq inhibit-startup-screen t)
(set-fontset-font t 'han (font-spec :family "WenQuanYi Micro Hei Mono" :size 10.5))
(set-face-attribute 'default nil :font "JetBrainsMono Nerd Font-10.5")
(use-package ace-window)
(global-set-key (kbd "C-x o") 'ace-window)
(custom-set-faces
 '(aw-leading-char-face
   ((t (:inherit ace-jump-face-foreground 
        :height 3.0           ; 3.0 表示放大到 3 倍
        :weight bold          ; 加粗
        :foreground "red"))))) ; 颜色改成显眼的红色
;;彩色emoji
(when (member "Noto Color Emoji" (font-family-list))
  ;; 让 Emacs 的默认字体集在遇到 'emoji 脚本区域时，使用 Noto Color Emoji 渲染
 ;; 全局规则：所有 *Warnings* 缓冲区都不允许自动弹窗
(add-to-list 'display-buffer-alist '("\\*Warnings\\*" . (display-buffer-no-window)))

;; 确保原生编译器也遵循“只记录不弹窗”的逻辑
(setq native-comp-async-report-warnings-errors 'silent)
(set-fontset-font t 'emoji (font-spec :family "Noto Color Emoji") nil 'prepend))
(provide 'init-settings)
