;; -*- lexical-binding: t; -*-

;; 1. 识别当前系统环境
(defconst IS-ANDROID (eq system-type 'android))
(defconst IS-LINUX   (eq system-type 'gnu/linux))

;; 2. 针对 Android APK 版 Emacs 的专属底层打通逻辑
(when IS-ANDROID
  (let ((custom-bin "/data/local/bin")
        (termux-bin "/data/data/com.termux/files/usr/bin")
        (termux-lib "/data/data/com.termux/files/usr/lib"))
    
    ;; 优先检测 Root 映射的公共目录，如果不存在则尝试直接备用 Termux 目录
    (let ((target-bin (if (file-directory-p custom-bin) custom-bin termux-bin)))
      (when (file-directory-p target-bin)
        ;; 注入二进制执行路径
        (setenv "PATH" (concat target-bin ":" (getenv "PATH")))
        (setq exec-path (cons target-bin exec-path)))
      
      ;; 强制注入 Termux 的 .so 动态链接库路径（解决 git/clang 依赖报错的关键）
      (when (file-directory-p termux-lib)
        (setenv "LD_LIBRARY_PATH" 
                (concat termux-lib 
                        (if (getenv "LD_LIBRARY_PATH") 
                            (concat ":" (getenv "LD_LIBRARY_PATH")) 
                          "")))))))

;; 彻底禁用 package.el 自动启动，把控制权完全交给 straight.el
(setq package-enable-at-startup nil)
(provide 'early-init)
;;; early-init.el ends here.
