;; -*- lexical-binding: t; -*-
;; 此文件目前已不用
(defun my/get-gemini-key ()
  "从 ~/.authinfo 中获取 Gemini API Key."
  ;; 确保 auth-sources 列表里包含你的文件
  (let* ((auth-sources '("~/.authinfo"))
         (found (auth-source-search :host "gemini-service" :user "apikey" :require '(:secret))))
    (if found
        (let ((secret (plist-get (car found) :secret)))
            (if (functionp secret) (funcall secret) secret))
      (error "未在 .authinfo 中找到 gemini-service 的条目"))))

(use-package aider
  :straight (:host github :repo "tninja/aider.el")
  :init
  ;; 确保在初始化阶段就能拿到 Key
  (condition-case nil
      (setenv "GEMINI_API_KEY" (my/get-gemini-key))
    (error (message "警告：未能从 .authinfo 加载 Gemini Key")))
  :config
  (setq aider-program "~/.pyenv/versions/3.11.8/bin/aider")
  (setq aider-args '("--model" "gemini/gemini-2.5-flash"))
  (setenv "HTTPS_PROXY" "http://127.0.0.1:7897")
 ;; 告诉所有子进程：访问本地地址时，严禁走代理
  (setenv "no_proxy" "127.0.0.1,localhost,0.0.0.0,.local")
  ;; 快捷键
  (global-set-key (kbd "C-c a r") 'aider-run-aider)
  (global-set-key (kbd "C-c a a") 'aider-add-current-file)
  (global-set-key (kbd "C-c a c") 'aider-code-change))
(provide 'init-ai)
;;; init-ai.el ends here
