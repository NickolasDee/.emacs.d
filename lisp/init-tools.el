; -*- lexical-binding: t; -*-
;; lisp/init-tools.el
(use-package with-proxy)
(use-package magit)

;; 1. Vertico: 提供垂直补全界面
(use-package vertico  :init (vertico-mode))
;; 2. Marginalia: 在补全菜单右侧显示快捷键和注释
(use-package marginalia
  
  :init
  (marginalia-mode))

(use-package dirvish
  
  :init
  ;; 启用 dirvish
  (dirvish-override-dired-mode)
  :config
  ;; 配置 dirvish 的外观，开启预览和双栏
  (dirvish-peek-mode)
  (setq dirvish-mode-line-format '(:left (sort details) :right (omit yank index)))
  
  ;; 设置快捷键 C-c d 打开当前文件所在的目录
  (global-set-key (kbd "C-c C-d") 'dirvish-dwim))

(use-package consult
  
  :bind (;; 搜索当前项目中的文件 (配合 fd)
         ("C-c f" . consult-find)
         ;; 在当前项目中全局搜索内容 (配合 rg)
         ("C-c s" . consult-ripgrep)
         ;; 搜索当前 buffer 中的内容
         ("C-c l" . consult-line)
         ;; 快速跳转 buffer
         ("C-c b" . consult-buffer)
	 ("C-c i" . consult-imenu-multi)
	 )
  :config
  (recentf-mode 1)
  ;; 强制允许即使搜索结果为 0 时也不要抛出异常
  (setq consult-async-min-input 0)
  (setq consult-async-refresh-delay 0.2)
  (setq consult-async-input-throttle 0.1)

  ;; 关键修复：禁用 consult 对所有匹配结果的“强迫症”检查
  (setq consult-narrow-key "<")
  ;;(setq consult-ripgrep-args "rg --null --line-buffered --color=never --max-columns=1000 --path-separator / --smart-case --no-heading --line-number --glob '!.git/'")
  (setq consult-ripgrep-args "rg --null --line-buffered --color=never --max-columns=1000 --path-separator / --smart-case --no-heading --line-number")
)
(defun my/consult-ripgrep-project ()
  "安全调用 rg，如果不在项目中则搜索当前目录，防止报错。"
  (interactive)
  (let* ((proj (project-current t))
         (default-directory (if proj (project-root proj) default-directory)))
    (if (file-exists-p default-directory)
        (consult-ripgrep default-directory)
      (message "路径不存在: %s" default-directory))))


(use-package restart-emacs)
(defun my/straight-update-and-restart ()
  "先备份当前包版本，拉取所有更新，然后重启 Emacs。
建议在网络环境良好（Git 全局代理开启）时运行。"
  (interactive)
  (when (y-or-n-p "是否开始执行：先 Freeze 版本，再 Pull 更新并重启？")
    ;; 1. 执行快照 (Freeze)
    (message "正在备份当前包版本到 default.el...")
    (straight-freeze-versions)
    
    ;; 2. 执行拉取 (Pull All)
    (message "正在拉取所有 Git 仓库更新 (请观察 *straight-process* buffer)...")
    (straight-pull-all)
    
    ;; 3. 提示重启
    ;; 注意：由于 straight-pull-all 是同步执行(在主线程中等待)，
    ;; 执行到这里说明 Git 操作已完成。
    (if (y-or-n-p "更新拉取完成！是否立即重启 Emacs 以应用更改并重新编译？")
        (restart-emacs)
      (message "更新已下载，请手动重启以完成字节编译。"))))
;; auto save
;; 开启自动保存所有已修改的 buffer
(auto-save-visited-mode 1)

;; 设置闲置多少秒后自动保存（例如 5 秒）
(setq auto-save-visited-interval 5)

;; 另外，强制将临时的备份文件放在一个固定的文件夹，避免乱堆在项目目录下
(setq backup-directory-alist '(("." . "~/.cache/emacs/backup/")))
(setq auto-save-file-name-transforms '((".*" "~/.cache/emacs/backup/" t)))

(provide 'init-tools)

