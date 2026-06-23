;; -*- lexical-binding: t; -*-
;; This buffer is for text that is not saved, and for Lisp evaluation. 
;; To create a file, visit it with ‘SPC f f’ and enter text in its buffer.
(use-package with-proxy)
(require 'gptel)
(require 'with-proxy)
(require 'auth-source)

(setq debug-on-error t)
(auth-source-forget-all-cached)
;; --- 1. 从 authinfo 获取 API Key ---
(defun my/get-gemini-key ()
  "从 ~/.authinfo 中获取 Gemini API Key。"
  (let ((match (auth-source-search :host "generativelanguage.googleapis.com"
                                  :user "apikey")))
    (if match
        (let ((secret (plist-get (car match) :secret)))
          (if (functionp secret) (funcall secret) secret))
      (error "在 authinfo 中找不到 Gemini 的 API Key"))))
(setq gptel-log-level 'debug)
(with-eval-after-load 'gptel-curl
  (defun my/gptel-universal-extractor (raw-str)
    "使用正则表达式暴力提取所有 text 字段，并分离 thought。"
    (let ((text-acc "")
          (thought-acc ""))
      ;; 1. 记录原始数据到本地 (这次我们换个简单的写入方式)
      (append-to-file raw-str nil "~/.cache/gptel/raw_stream.log")
      
      ;; 2. 匹配所有的 "text": "..." 块
      ;; 注意：这里为了简单，我们假设返回的转义比较标准
      (with-temp-buffer
        (insert raw-str)
        (goto-char (point-min))
        ;; 寻找所有的 text 字段
        (while (re-search-forward "\"text\"\\s-*:\\s-*\"\\(\\(?:\\\\\"\\|[^\"]\\)*\\)\"" nil t)
          (let ((content (match-string 1)))
            ;; 简单的逻辑：如果这个 text 块后面紧跟着 "thought": true
            ;; 或者根据你在 log 里看到的顺序，通常第一个大块是思考
            (if (save-excursion (re-search-forward "\"thought\"\\s-*:\\s-*true" (+ (point) 20) t))
                (setq thought-acc (concat thought-acc content))
              (setq text-acc (concat text-acc content))))))
      
      ;; 3. 分流到 Buffer
      (when (not (string-empty-p thought-acc))
        (with-current-buffer (get-buffer-create "*gemini-thinking*")
          (save-excursion (goto-char (point-max)) (insert thought-acc))))
      
      ;; 4. 返回处理后的文本（去掉转义的引号）
      (replace-regexp-in-string "\\\\\"" "\"" text-acc)))

  ;; 拦截底层流处理器
  (advice-add 'gptel-curl--stream-filter :around
              (lambda (orig-fun process string)
                ;; string 就是 curl 传回的原始块
                (let ((cleaned-text (my/gptel-universal-extractor string)))
                  (funcall orig-fun process cleaned-text)))))
;; --- 2. 配置 gptel 的 Gemini 后端 ---
;; 1. 先定义一个全局后端，避免异步时变量被销毁
(defun my/gptel-gemini-chat-with-thinking ()
  "适配 7897 端口，将思考过程重定向至 *gemini-thinking* Buffer。"
  (interactive)
  (with-proxy
    :http-server "127.0.0.1:7897"
    :https-server "127.0.0.1:7897"
    (let ((gptel-backend (gptel-make-gemini "Gemini-Thinking-Mode"
                           :key (my/get-gemini-key)
                           :stream t))
          (gptel-model 'gemini-1.5-flash))
      (gptel-request 
       (read-string "询问 Gemini: ")
       :callback (lambda (response info)
                   (when response
                     (let ((text-content nil)
                           (thinking-content nil))
                       ;; --- 解析数据结构 ---
                       (cond
                        ;; 情况 A: 标准 Association List (包含 reasoning 和 text)
                        ((and (listp response) (assoc 'reasoning response))
                         (setq thinking-content (cdr (assoc 'reasoning response)))
                         (setq text-content (cdr (assoc 'text response))))
                        ;; 情况 B: 只有 text 的列表
                        ((and (listp response) (assoc 'text response))
                         (setq text-content (cdr (assoc 'text response))))
                        ;; 情况 C: 纯字符串
                        ((stringp response)
                         (setq text-content response)))

                       ;; --- 分流输出 ---
                       ;; 1. 处理思考内容
                       (when (and thinking-content (stringp thinking-content))
                         (with-current-buffer (get-buffer-create "*gemini-thinking*")
                           (save-excursion
                             (goto-char (point-max))
                             (insert "\n--- Thinking ---\n" thinking-content "\n"))
                           ;; 可选：自动滚动到底部
                           (let ((win (get-buffer-window "*gemini-thinking*")))
                             (when win (set-window-point win (point-max))))))

                       ;; 2. 处理最终回复
                       (when (and text-content (stringp text-content))
                         (insert text-content)))))))))
