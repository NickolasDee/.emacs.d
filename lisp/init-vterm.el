;; -*- lexical-binding: t; -*-
;;terminal

(use-package vterm 
  :config (setq initial-buffer-choice (lambda () (unless (> (length command-line-args) 1)
						   (or (get-buffer "*vterm*") (vterm))))))
(defun get-current-buffer-dir ()
  (interactive)
  (let ((dir (shell-quote-argument default-directory)))
    (message "%s" dir)))
(defun my/vterm-sync-pwd-and-find-file ()
  "让 vterm 执行 pwd 并存入内存文件，然后 Emacs 读取它并打开 find-file。"
  (interactive)
  (let* ((shm-file "/dev/shm/vterm_pwd")
         (process (get-buffer-process (current-buffer))))
    (when process
      ;; 1. 向 vterm 发送命令：将 pwd 写入内存文件
      ;; 使用分号确保命令执行，加空格防止进入 bash 历史记录
      (vterm-send-string (format " pwd > %s\n" shm-file))
      
      ;; 2. 给 Shell 一点点时间写入文件（100ms 足够了，内存文件系统极快）
      (accept-process-output process 0.1)
      
      ;; 3. 读取该文件并设置路径
      (if (file-exists-p shm-file)
          (let* ((vterm-dir (with-temp-buffer
                              (insert-file-contents shm-file)
                              (string-trim (buffer-string))))
                 (default-directory (file-name-as-directory vterm-dir)))
            ;; 4. 调用 find-file
            (call-interactively 'find-file))
        (message "同步失败：未找到内存路径文件。")))))

;; 绑定到 vterm 的 C-x C-f
(with-eval-after-load 'vterm
  (define-key vterm-mode-map (kbd "C-x C-f") #'my/vterm-sync-pwd-and-find-file))
(defun my/toggle-terminal-smart ()
  (interactive)
  (let ((term-buf-name "*vterm*")
        (target-dir default-directory)) ;; 这一步就是获取当前目录
    
    (if (equal (buffer-name) term-buf-name)
        ;; 情况 A：当前在终端中，切换回之前 buffer
        (switch-to-buffer (other-buffer (current-buffer) 1))
      
      ;; 情况 B：当前不在终端中
      (if (get-buffer term-buf-name)
          (progn
            (switch-to-buffer term-buf-name)
            ;; 如果已经有终端，发送 cd 命令
            (vterm-send-string (concat "cd " (shell-quote-argument target-dir)))
            (vterm-send-return))
        
        ;; 情况 C：终端不存在，创建时直接指定目录
        ;; 核心技巧：let 动态绑定 default-directory 影响后续函数行为
        (let ((default-directory target-dir))
          (vterm))))))
(global-set-key (kbd "C-`") 'my/toggle-terminal-smart)
(provide 'init-vterm)
;;; init-vterm.el ends here.
