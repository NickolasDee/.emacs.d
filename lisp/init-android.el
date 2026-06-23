;; -*- lexical-binding: t; -*-
;; lisp/init-android.el

;; ====================================================================
;; 1. 正确初始化全局多字节与 UTF-8 编码环境（修复常量赋值报错）
;; ====================================================================
(set-language-environment "UTF-8")
(set-default-coding-systems 'utf-8)
(set-buffer-file-coding-system 'utf-8)
(set-selection-coding-system 'utf-8)
(let ((en-font "JetBrainsMono Nerd Font-14")
      (zh-font "Source Han Sans VF")
      ;; 💡 名字绝对对齐列表：死死焊住 Noto Color Emoji
      (emoji-font "Noto Color Emoji"))

  (set-face-attribute 'default nil :font en-font)

  ;; 中文拦截
  (set-fontset-font "fontset-default" 'han (font-spec :family zh-font))
  (set-fontset-font "fontset-default" 'cjk-misc (font-spec :family zh-font))

  ;; 符号与表情子集拦截
  (dolist (target '(symbol emoji mathematical braille))
    (set-fontset-font "fontset-default" target (font-spec :family emoji-font))
    (set-fontset-font "fontset-startup" target (font-spec :family emoji-font)))

  ;; 💡 精准拦截截图里满屏幕以 01F... 开头的高位 Emoji 物理码位区间
  (set-fontset-font "fontset-default" '(#x1F000 . #x1F9FF) (font-spec :family emoji-font))
  (set-fontset-font "fontset-startup" '(#x1F000 . #x1F9FF) (font-spec :family emoji-font)))

;; 2. android设备打开文件必须
(setq server-socket-dir "/data/data/com.termux/files/home/.emacs.d/server")
(require 'server)
(unless (server-running-p)
  (server-start))
;; 3. android 端emacs只能用term,eshell失败了，可能是我的配置哪里出了问题？

(with-eval-after-load 'term
  ;; A. 【至关重要】切断会导致 PTY 死锁的连接方式，改走标准通信
  (setq-default process-connection-type nil)
  (setq process-connection-type nil)
  
  ;; B. 拦截 term 内部对 shell 的查找，将其强行掰到 Termux 的 bash 绝对路径
  ;; 配合 android-use-exec-loader，Emacs 会用自身的安全沙箱去“偷渡”这个进程
  (setq explicit-shell-file-name "/data/data/com.termux/files/usr/bin/bash")
  (setq explicit-bash-args '("--login -i"))
  ;; C. 强制跳过term启动的确认
  ;;  现代正统写法 (Emacs 30+)
(define-advice term (:before (&rest _args) force-termux-bash)
  "强制将 term 的启动默认外壳掰到 Termux 绝对路径"
  (interactive (list "/data/data/com.termux/files/usr/bin/bash"))))
  
;; 仅在进入 term-mode 的 buffer 内部精准注入全局 $PATH
;; 确保 Termux 里的工具链、中文字符集能够在这个原生的终端窗口内完美显示
(add-hook 'term-mode-hook
          (lambda ()
            (make-local-variable 'process-environment)
            (setenv "PATH" (concat "/data/data/com.termux/files/usr/bin:" (getenv "PATH")))
            (setenv "LANG" "zh_CN.UTF-8")
            (setenv "TERM" "xterm-256color")))
(global-set-key (kbd "C-`") 'term)

;; 4. 其它设置
;; 将 PHONE 注册为 Emacs 及其子进程可见的环境变量
(setenv "PHONE" "/storage/emulated/0/")

;; 顺手将其同步到 path 隐式包装中，确保 eshell 等终端能直接 $PHONE 引用
(setq-default process-environment (cons "PHONE=/storage/emulated/0/" process-environment))

(provide 'init-android)
;;init-android.el ends here.
