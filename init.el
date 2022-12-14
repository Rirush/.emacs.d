;;; Load packages and add melpa to the archives
(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)

;;; Ensure that 'use-package' is installed.
;;; This configuration healivy relies on it
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

;;; I'm not entirely sure why it should be 'eval-when-compile'
;;; but 'use-package' documentation suggests this
(eval-when-compile
  (require 'use-package)) ; Load use-package

(setq inhibit-startup-message t) ; Disable startup message

(load-theme 'modus-vivendi t) ; Load a dark theme

(set-face-attribute 'default t :font "Iosevka-14") ; Change font to Iosevka
(set-frame-font "Iosevka-16" nil t)

(require 'cl-lib)

;;; Move customization information into a separate file
(setq custom-file (locate-user-emacs-file "custom.el"))
(load custom-file 'NOERROR 'NOMESSAGE 'NOSUFFIX)

(setq inferior-lisp-program "sbcl")

;;; Resize the default frame, and enable 'display-fill-column-indicator-mode'
(add-hook 'after-init-hook (lambda ()
			     (when window-system (set-frame-size (selected-frame) 160 50))
			     (global-display-fill-column-indicator-mode 1)))

;;; Disable toolbar
(tool-bar-mode -1)

;;; Set 'display-fill-column-indicator-mode' to 140 columns
(add-hook 'display-fill-column-indicator-mode-hook
	  (lambda ()
	    (setq display-fill-column-indicator-column 140)))

(use-package magit
  :ensure)

(use-package paredit
  :ensure
  :init (autoload 'enable-paredit-mode "paredit" "Turn on pseudo-structural editing of Lisp code." t)
  :hook ((emacs-lisp-mode . enable-paredit-mode)
	 (eval-expression-minibuffer-setup . enable-paredit-mode)
	 (ielm-mode . enable-paredit-mode)
	 (lisp-mode . enable-paredit-mode)
	 (lisp-interaction-mode . enable-paredit-mode)
	 (scheme-mode . enable-paredit-mode)
	 (sly-mrepl . enable-paredit-mode)))

(defun spawn-sly-if-not-exists ()
  (unless (sly-connected-p)
    (save-excursion
      (sly))))

(use-package sly
  :ensure
  :config (cl-pushnew '("\\*sly-mrepl*" (display-buffer-at-bottom)) display-buffer-alist :test #'equal)
  :hook (sly-mode . spawn-sly-if-not-exists))

(use-package company
  :ensure
  :hook (after-init . global-company-mode)
  :config (progn
	    (setq company-idle-delay 0.5)
	    (setq company-minimum-prefix-length 1)
	    (setq company-tooltip-minimum-width 40)
	    (add-to-list 'company-backends 'company-irony)))

(use-package company-box
  :ensure
  :after (company)
  :hook (company-mode . company-box-mode))

(use-package which-key
  :ensure
  :hook (change-major-mode . which-key-mode))

(use-package go-mode
  :ensure
  :mode "\\.go\\'"
  :hook ((go-mode . lsp-deferred)
	 (before-save-hook . gofmt-before-save))
  :config (setq tab-width 4))

(use-package irony
  :ensure
  :hook ((c++-mode . irony-mode)
	 (c-mode . irony-mode)
	 (objc-mode . irony-mode)))

(use-package treemacs
  :ensure)

(use-package treemacs-magit
  :ensure)

(defun mini-frame-set-font ()
  (set (make-local-variable 'face-remapping-alist)
       '((default :height 1.3))))

(add-hook 'minibuffer-setup-hook 'mini-frame-set-font)

;;; Makes sure M-x and some other commands are properly vertical
(use-package ivy
  :ensure
  :hook ((after-init . ivy-mode)))

;;; Provides a centered vertical frame
(use-package mini-frame
  :ensure
  :hook ((after-init . mini-frame-mode)))

(defun project-new (path)
  (interactive "DProject path: ")
  (let ((project (cons 'vc path)))
    (project-remember-project project)
    (project-switch-project path)))

