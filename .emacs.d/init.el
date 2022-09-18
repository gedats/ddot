;; The default is 800 kilobytes.  Measured in bytes.
(setq gc-cons-threshold (* 50 1000 1000))

(defun efs/display-startup-time ()
  (message "Emacs loaded in %s with %d garbage collections."
           (format "%.2f seconds"
                   (float-time
                     (time-subtract after-init-time before-init-time)))
           gcs-done))

(add-hook 'emacs-startup-hook #'efs/display-startup-time)

(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name "straight/repos/straight.el/bootstrap.el" user-emacs-directory))
      (bootstrap-version 6))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/radian-software/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))

(straight-use-package 'use-package)

(require 'use-package)

(setf
 straight-vc-git-default-protocol 'https
 straight-use-package-by-default t
 use-package-verbose t
 use-package-always-demand t)
(setq package-archives
      '(("melpa" . "https://melpa.org/packages/")
        ("melpa-stable" . "https://stable.melpa.org/packages/")
        ("org" . "https://orgmode.org/elpa/")
        ("elpa" . "https://elpa.gnu.org/packages/")))

(use-package emacs
  :config
  (load-theme 'modus-operandi)
  (defun crm-indicator (args)
    (cons (format "[CRM%s] %s"
		  (replace-regexp-in-string
		   "\\`\\[.*?]\\*\\|\\[.*?]\\*\\'" ""
		   crm-separator)
		  (car args))
	  (cdr args)))
  (advice-add #'completing-read-multiple :filter-args #'crm-indicator)
  (setq inhibit-startup-message t)

  (scroll-bar-mode -1)			; Disable visible scrollbar
  (tool-bar-mode -1)			; Disable the toolbar
  (tooltip-mode -1)			; Disable tooltips
  (set-fringe-mode 8)
  (menu-bar-mode -1)			; Disable the menu bar
  (setq visible-bell t)
  (blink-cursor-mode -1)
  (column-number-mode)
  ;; (setf display-line-numbers-type 'relative)
  (global-display-line-numbers-mode t)

  ;; Disable line numbers for some modes
  (dolist (mode '(org-mode-hook
                  term-mode-hook
                  shell-mode-hook
                  treemacs-mode-hook
                  eshell-mode-hook))
    (add-hook mode (lambda () (display-line-numbers-mode 0))))

  (global-set-key (kbd "<escape>") 'keyboard-escape-quit)
  (setq use-dialog-box nil)
  (defalias 'yes-or-no-p 'y-or-n-p)
  (setq create-lockfiles nil)

  ;; Do not allow the cursor in the minibuffer prompt
  (setq minibuffer-prompt-properties
	'(read-only t cursor-intangible t face minibuffer-prompt))
  (add-hook 'minibuffer-setup-hook #'cursor-intangible-mode)
  (setq inhibit-startup-message t
	initial-scratch-message "")
;;; Show matching parenthesis
  (show-paren-mode 1)
;;; By default, there’s a small delay before showing a matching parenthesis. Set
;;; it to 0 to deactivate.
  (setq show-paren-delay 0)
  (setq show-paren-when-point-inside-paren t)

  (setq show-paren-style 'parenthesis)
;;; Electric Pairs to auto-complete () [] {} "" etc. It works on regions.

  (electric-pair-mode)
  (setq redisplay-skip-fontification-on-input t
	fast-but-imprecise-scrolling t)
  (global-so-long-mode 1)
;;; set default browser
  (setq browse-url-browser-function 'browse-url-xdg-open)
  :bind ("<f5>" . modus-themes-toggle)
  )

(use-package magit)

(use-package mood-line
  :straight (:host github :repo "benjamin-asdf/mood-line")
  :config
  (setf mood-line-show-cursor-point t)
  (mood-line-mode))

;; vertico
(use-package vertico
  :config
  ;; Set up minibuffer.
  (setq enable-recursive-minibuffers t
        read-extended-command-predicate #'command-completion-default-include-p
        minibuffer-prompt-properties '(read-only t cursor-intangible t face minibuffer-prompt))
  (add-hook 'minibuffer-setup-hook #'cursor-intangible-mode)

  (vertico-mode)
  :custom
  (vertico-cycle t)
  (vertico-scroll-margin 0)
  (vertico-count 20)
  (vertico-sort-function #'vertico-sort-history-alpha)
  :defer 1)
;; (use-package vertico
;;   :init
;;   (vertico-mode)
;;   (setq vertico-scroll-margin 0)
;;   (setq vertico-count 20)
;;   (setq vertico-cycle t))
;; Configure vertico-quick extension
;; (use-package vertico-quick
;;   :straight nil
;;   :bind
;;   (:map vertico-map
;;    ("M-q" . vertico-quick-exit)
;;    ("C-q" . vertico-quick-insert))
;;   :demand
;;   :after vertico
;;   :ensure nil)

(use-package avy)

(use-package savehist :init (savehist-mode))

(use-package orderless
  :init
  (setq
   completion-styles '(orderless)
   completion-category-defaults nil
   completion-category-overrides '((file (styles partial-completion)))))

(require 'dired)

;; https://github.com/Gavinok/emacs.d
(use-package consult
  :bind (("C-x b"       . consult-buffer)
         ("C-x C-k C-k" . consult-kmacro)
         ("M-y"         . consult-yank-pop)
         ("M-g g"       . consult-goto-line)
         ("M-g M-g"     . consult-goto-line)
         ("M-g f"       . consult-flymake)
         ("M-g i"       . consult-imenu)
         ("M-s l"       . consult-line)
         ("M-s L"       . consult-line-multi)
         ("M-s u"       . consult-focus-lines)
         ("M-s g"       . consult-grep)
         ("M-s M-g"     . consult-grep)
         ("C-x C-SPC"   . consult-global-mark)
         ("C-x M-:"     . consult-complex-command)
         ("C-c n"       . consult-org-agenda)
         :map dired-mode-map
         ("O" . consult-file-externally)
         :map help-map
         ("a" . consult-apropos)
         :map minibuffer-local-map
         ("M-r" . consult-history))
  :custom
  (completion-in-region-function #'consult-completion-in-region)
  :config
  (recentf-mode t))

;; marginalia: add info in mini-buffer
(use-package marginalia
  :ensure t
  :config
  (marginalia-mode))

;; embark
(use-package embark
  :ensure t

  :bind
  (("C-." . embark-act)         ;; pick some comfortable binding
   ("C-;" . embark-dwim)        ;; good alternative: M-.
   ("C-h B" . embark-bindings)) ;; alternative for `describe-bindings'

  :init

  ;; Optionally replace the key help with a completing-read interface
  (setq prefix-help-command #'embark-prefix-help-command)

  :config

  ;; Hide the mode line of the Embark live/completions buffers
  (add-to-list 'display-buffer-alist
               '("\\`\\*Embark Collect \\(Live\\|Completions\\)\\*"
                 nil
                 (window-parameters (mode-line-format . none)))))

;; Consult users will also want the embark-consult package.
(use-package embark-consult
  :ensure t
  :after (embark consult)
  :demand t ; only necessary if you have the hook below
  ;; if you want to have consult previews as you move around an
  ;; auto-updating embark collect buffer
  :hook
  (embark-collect-mode . consult-preview-at-point-mode))

;; avy-embark-collect
(use-package avy-embark-collect)

;; swiper
(use-package swiper)

;; counsel
(use-package counsel)

;; ivy
(use-package ivy
  :config
  (ivy-mode 1)
  (setq ivy-use-virtual-buffers t)
  (setq ivy-count-format "(%d/%d) ")
  (setq ivy-height 20)
  (setq ivy-wrap t)
  (global-set-key (kbd "C-s") 'swiper-isearch)
  ;; (global-set-key (kbd "M-x") 'counsel-M-x)
    (global-set-key (kbd "C-x C-f") 'counsel-find-file)
    (global-set-key (kbd "M-y") 'counsel-yank-pop)
    (global-set-key (kbd "<f1> f") 'counsel-describe-function)
    (global-set-key (kbd "<f1> v") 'counsel-describe-variable)
    (global-set-key (kbd "<f1> l") 'counsel-find-library)
    (global-set-key (kbd "<f2> i") 'counsel-info-lookup-symbol)
    (global-set-key (kbd "<f2> u") 'counsel-unicode-char)
    (global-set-key (kbd "<f2> j") 'counsel-set-variable)
    (global-set-key (kbd "C-c C-r") 'ivy-resume)
    (global-set-key (kbd "C-x b") 'ivy-switch-buffer)
    (global-set-key (kbd "C-c v") 'ivy-push-view)
    (global-set-key (kbd "C-c V") 'ivy-pop-view)
    (global-set-key (kbd "C-c c") 'counsel-compile)
    (global-set-key (kbd "C-c g") 'counsel-git)
    (global-set-key (kbd "C-c j") 'counsel-git-grep)
    (global-set-key (kbd "C-c L") 'counsel-git-log)
    (global-set-key (kbd "C-c k") 'counsel-rg)
    (global-set-key (kbd "C-c m") 'counsel-linux-app)
    (global-set-key (kbd "C-c n") 'counsel-fzf)
    (global-set-key (kbd "C-x l") 'counsel-locate)
    (global-set-key (kbd "C-c J") 'counsel-file-jump)
    (global-set-key (kbd "C-S-o") 'counsel-rhythmbox)
    (global-set-key (kbd "C-c w") 'counsel-wmctrl)
    (global-set-key (kbd "C-c b") 'counsel-bookmark)
    (global-set-key (kbd "C-c d") 'counsel-descbinds)
    (global-set-key (kbd "C-c o") 'counsel-outline)
    (global-set-key (kbd "C-c F") 'counsel-org-file)
  )

(use-package ivy-avy)


(use-package evil
  :init
  (setq
   evil-want-integration t
   evil-want-keybinding nil
   evil-move-cursor-back nil
   evil-move-beyond-eol t
   evil-want-fine-undo t)

  :config
  (evil-mode 1)
  (define-key evil-insert-state-map (kbd "C-g") 'evil-normal-state)
  (define-key evil-insert-state-map (kbd "C-h") 'evil-delete-backward-char)
  (define-key evil-insert-state-map (kbd "C-S-h") 'evil-delete-backward-word)
  (define-key evil-insert-state-map (kbd "<f7>") 'evil-avy-goto-line)
  (evil-set-initial-state 'messages-buffer-mode 'normal)
  (evil-set-initial-state 'dashboard-mode 'normal)

  (defadvice evil-show-registers
      (after mm/evil-show-registers-adv activate)
    (text-mode)))

(use-package evil-collection
  :after evil
  :ensure t
  :config
  (setf evil-collection-mode-list
	(remove 'lispy evil-collection-mode-list))
  (evil-collection-init))

;; cider
(use-package cider
  :config
  (setq cider-babashka-parameters "nrepl-server 0"
	clojure-toplevel-inside-comment-form t)

(defun simple-easy-clojure-hello ()
  (interactive)
  (unless
      (executable-find "clj")
    (user-error
     "Install clojure first! browsing to %s"
     (let ((url "https://clojure.org/guides/install_clojure")) (browse-url url) url)))
  (let*
      ((dir "~/simple-easy-clojure-hello")
       (_ (make-directory dir t))
       (default-directory dir))
    (shell-command "echo '{}' > deps.edn")
    (make-directory "src" t)
    (find-file "src/hello.clj")
    (when (eq (point-min) (point-max))
      (insert "(ns hello)\n\n(defn main []\n  (println \"hello world\"))\n\n\n;; this is a Rich comment, use it to try out pieces of code while you develop.\n(comment\n  (def rand-num (rand-int 10))\n  (println \"Here is a random number: \" rand-num))"))
    (call-interactively #'cider-jack-in-clj))))

;;
;; ace jump mode major function
;;
(use-package ace-jump-mode
    :load-path "/full/path/where/ace-jump-mode.el/in/"
    :init
    ;;
    ;; enable a more powerful jump back function from ace jump mode
    ;;
    (autoload 'ace-jump-mode-pop-mark "ace-jump-mode" "Ace jump back:-)" t)
    :config
    (ace-jump-mode-enable-mark-sync)
    ;; you can select the key you prefer to
    (define-key global-map (kbd "C-c SPC") 'ace-jump-mode)
    (define-key global-map (kbd "C-x SPC") 'ace-jump-mode-pop-mark)
    ;;If you use viper mode :
    ;; (define-key viper-vi-global-user-map (kbd "SPC") 'ace-jump-mode)
    ;;If you use evil
    (define-key evil-normal-state-map (kbd "SPC") 'ace-jump-mode))

(use-package ace-isearch
  :init
  (setq global-ace-isearch-mode +1))
