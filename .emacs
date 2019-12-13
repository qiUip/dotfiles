;; ----Melpa----
(when (>= emacs-major-version 24)
  (require 'package)
  (add-to-list
   'package-archives
   '("melpa" . "http://melpa.org/packages/")
   t)
  (package-initialize))
;; ----Check if packages are installed and if not install them----
(defun ensure-package-installed (&rest packages)
  "Assure every package is installed, ask for installation if it’s not.

Return a list of installed packages or nil for every skipped package."
  (mapcar
   (lambda (package)
     ;; (package-installed-p 'evil)
     (if (package-installed-p package)
         nil
       (if (y-or-n-p (format "Package %s is missing. Install it? " package))
           (package-install package)
         package)))
   packages))

;; make sure to have downloaded archive description.
;; Or use package-archive-contents as suggested by Nicolas Dudebout
(or (file-exists-p package-user-dir)
    (package-refresh-contents))

(ensure-package-installed 'iedit 'magit) ;  --> (nil nil) if iedit and magit are already installed

;; activate installed packages
(package-initialize)

;; ----Change some defualts----
(setq explicit-shell-file-name "/bin/zsh")
(setq shell-file-name "zsh")
(setq browse-url-browser-function 'browse-url-firefox)

;; ----Windows and frames management----
(global-set-key (kbd "C-x <left>")  'windmove-left)
(global-set-key (kbd "C-x <right>") 'windmove-right)
(global-set-key (kbd "C-x <up>")    'windmove-up)
(global-set-key (kbd "C-x <down>")  'windmove-down)
(global-set-key (kbd "C-x x <left>") 'shrink-window-horizontally)
(global-set-key (kbd "C-x x <right>") 'enlarge-window-horizontally)
(global-set-key (kbd "C-x x <down>") 'shrink-window)
(global-set-key (kbd "C-x x <up>") 'enlarge-window)
(require 'transpose-frame)

;; ----Additional packages to make emacs "better"----
;; ----Add pretty highlights----
(require 'volatile-highlights)
(volatile-highlights-mode t)
;; ----Better undo----
(require 'undo-tree)
(global-undo-tree-mode) 
;; ----Better commands interface----
(global-set-key (kbd "M-x") 'smex)
(global-set-key (kbd "M-X") 'smex-major-mode-commands)
(global-set-key (kbd "C-c C-c M-x") 'execute-extended-command)
;; ----File browser side-pane----
(require 'neotree)
(global-set-key [f8] 'neotree-toggle)
(setq neo-theme (if (display-graphic-p) 'icons 'arrow))
;; ----Share clipboard with X----
(xclip-mode)
;; ----Autocomplition----
(require 'company)
(require 'company-reftex)
(add-hook 'after-init-hook 'global-company-mode)
(setq company-idle-delay 0)
(setq company-minimum-prefix-length 2)
(setq company-selection-wrap-around t)
; Use tab key to cycle through suggestions.
; ('tng' means 'tab and go')
(company-tng-configure-default)
;; ----Close parenthesis automatically---- 
(require 'smartparens)
(require 'smartparens-config)
(smartparens-global-mode)
;; ----Better searching----
(global-anzu-mode t)
(global-set-key [remap query-replace-regexp] 'anzu-query-replace-regexp)
(global-set-key [remap query-replace] 'anzu-query-replace)
;; Activate occur easily inside isearch
(define-key isearch-mode-map (kbd "C-o") 'isearch-occur)

;; ----Embrace the dark side!----
(setq evil-want-C-i-jump nil)
(setq evil-want-integration t) ;; This is optional since it's already set to t by default.
(setq evil-want-keybinding nil)
(require 'evil)
(evil-mode 1)
(when (require 'evil-collection nil t)
  (evil-collection-init))
(global-evil-surround-mode 1)
(global-evil-matchit-mode 1)
(evilnc-default-hotkeys)
(with-eval-after-load 'evil
  (require 'evil-anzu))
;;   (require 'evil-vimish-fold))
;; (evil-vimish-fold-mode 1)
;; ----Line numbering----
(require 'linum-relative)
(setq linum-relative-current-symbol "")
(add-hook 'prog-mode-hook 'linum-relative-global-mode)
(linum-relative-global-mode t)
(global-set-key (kbd "<f7>") 'linum-relative-global-mode)
(setq-default fill-column 100)
;; ----Folding----
(require 'origami)
(defun nin-origami-toggle-node ()
  (interactive)
  (save-excursion ;; leave point where it is
    (goto-char (point-at-eol)) ;; then go to the end of line
    (origami-toggle-node (current-buffer) (point)))) ;; and try to fold
(use-package origami :ensure t
  :config
    (add-hook 'prog-mode-hook
      (lambda ()
        (origami-mode)
        (origami-close-all-nodes (current-buffer)))))
(evil-define-key 'normal prog-mode-map (kbd "TAB") 'nin-origami-toggle-node)

;; ----Org-mode settings----
;; ----Keybindings----
(global-set-key (kbd "C-c l") 'org-store-link)
(global-set-key (kbd "C-c a") 'org-agenda)
(global-set-key (kbd "C-c c") 'org-capture)
(require 'org-super-agenda)
(require 'org-autolist)
(add-hook 'org-mode-hook (lambda () (org-autolist-mode)))
(add-to-list 'auto-mode-alist '("\\.org$" . org-mode))
(global-font-lock-mode 1)
(require 'org-ref)
(setq org-latex-pdf-process
      '("pdflatex -interaction nonstopmode -output-directory %o %f"
        "bibtex %b"
        "pdflatex -interaction nonstopmode -output-directory %o %f"
        "pdflatex -interaction nonstopmode -output-directory %o %f"))

;; ---- LaTeX and AUCTeX settings---
(setq inhibit-startup-echo-area-message t)
(setq latex-run-command "pdflatex")
(with-eval-after-load "tex"
  (add-to-list 'TeX-view-program-list '("zathura" "/usr/bin/zathura %o"))
  (setcdr (assq 'output-pdf TeX-view-program-selection) '("zathura")))

;; ----who needs an IDE?----
(require 'elpy)
;; add CUDA support
(add-to-list 'auto-mode-alist '("\\.cu$" . cuda-mode))

;; ----email, cal etc.----
(require 'calfw)
(require 'calfw-cal)
(require 'calfw-org)
(setq cfw:org-agenda-schedule-args '(:timestamp))
(setq calendar-holidays nil)
(defun my-open-calendar ()
  (interactive)
  (cfw:open-calendar-buffer
   :contents-sources
   (list
    (cfw:org-create-source "Green")  ; orgmode source
    (cfw:cal-create-source "Red") ; diary source
    )))
;; (require 'calfw-ical)
;; (cfw:open-ical-calendar "https://outlook.office365.com/owa/calendar/918566d5060b45989ad4d29c648b1b89@imperial.ac.uk/001230c4179e4fd9a7cf9f2b5c24e7df209232812636455867/S-1-8-572234251-1248706973-3380247728-3213087179/reachcalendar.ics")
(require 'excorporate)
(require 'mutt-mode)
(setq auto-mode-alist
      (append '(("muttrc\\'" . mutt-mode))
	      auto-mode-alist))
;; ----Mutt support----
(setq auto-mode-alist (append '(("/tmp/mutt.*" . mail-mode)) auto-mode-alist))

;; ----Themes----
(load-theme 'monokai t)
(require 'powerline)
(powerline-center-theme)
;; ----Loads theme only in windowed mode----
(defun on-frame-open (frame)
  (if (not (display-graphic-p frame))
      (set-face-background 'default "unspecified-bg" frame)
    (require 'org-bullets)
    (add-hook 'org-mode-hook (lambda () (org-bullets-mode 1)))
    (setq org-hide-leading-stars t)
    ))
(on-frame-open (selected-frame))
(add-hook 'after-make-frame-functions 'on-frame-open)
(defun on-after-init ()
  (unless (display-graphic-p (selected-frame))
    (set-face-background 'default "unspecified-bg" (selected-frame))
    (menu-bar-mode -1)))
(add-hook 'window-setup-hook 'on-after-init)

;; ----Out of my hands!----
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes
   (quote
    ("a0feb1322de9e26a4d209d1cfa236deaf64662bb604fa513cca6a057ddf0ef64" "628278136f88aa1a151bb2d6c8a86bf2b7631fbea5f0f76cba2a0079cd910f7d" "04dd0236a367865e591927a3810f178e8d33c372ad5bfef48b5ce90d4b476481" default)))
 '(excorporate-configuration
   (quote
    ("mdh10@ic.ac.uk" . "https://outlook.office365.com/EWS/Exchange.asmx")))
 '(inhibit-startup-screen t)
 '(org-agenda-files
   (quote
    ("~/Orgs/Report.org" "~/Orgs/tasks.org" "~/Orgs/notes.org" "~/Orgs/personal.org" "~/Documents/Reviews/review.org")))
 '(package-selected-packages
   (quote
    (magit iedit auto-complete-rst auto-complete-sage auto-correct auto-dictionary auto-dim-other-buffers auto-highlight-symbol auto-indent-mode auto-minor-mode auto-org-md auto-overlays auto-pause comment-tags company-box company-ctags company-fuzzy counsel counsel-etags counsel-gtags counsel-notmuch smex anzu evil-anzu evil-leader evil-matchit evil-nerd-commenter evil-surround evil-vimish-fold use-package use-package-chords use-package-el-get use-package-ensure-system-package use-package-hydra dash s-buffer scp origami yafolding evil-numbers evil-org evil-search-highlight-persist evil-smartparens smartparens company company-auctex company-bibtex company-c-headers company-lua company-math company-reftex company-shell company-ycmd org-ref linum-relative calfw calfw-cal calfw-gcal calfw-howm calfw-ical calfw-org call-graph mutt-mode org-msg evil evil-collection evil-commentary evil-ediff evil-expat darkokai-theme monokai-alt-theme monokai-pro-theme monokai-theme org-super-agenda org-timeline org-wild-notifier ac-math excorporate alect-themes cyberpunk-theme cherry-blossom-theme soothe-theme powerline transpose-frame org-bullets code-archive code-library epresent ob-browser ob-http org-ac org-autolist org-babel-eval-in-repl org-beautify-theme org-cliplink org-edit-latex org-gcal org-gnome org-grep org-iv org-repo-todo org-seek org-transform-tree-table org-tree-slide xclip all-the-icons all-the-icons-dired all-the-icons-gnus all-the-icons-ivy neotree ivy ace-flyspell ace-isearch ace-jump-buffer ace-window ace-jump-mode elpy auctex volatile-highlights undo-tree matlab-mode ggtags cuda-mode color-theme-sanityinc-tomorrow color-theme)))
 '(speedbar-show-unknown-files t))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
