;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
(setq user-full-name "Mashy Green"
      user-mail-address "mashy.green@ucl.ac.uk")

;; doom exposes five (optional) variables for controlling fonts in Doom:
;;
;; - `doom-font' -- the primary font to use
;; - `doom-variable-pitch-font' -- a non-monospace font (where applicable)
;; - `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;; - `doom-symbol-font' -- for symbols
;; - `doom-serif-font' -- for the `fixed-pitch-serif' face
(setq doom-font (font-spec :family "Hack Nerd Font Mono" :size 14))

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-gruvbox)

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type 'relative)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/Orgs/")
(setq +org-capture-todo-file "~/Orgs/tasks.org")

(setq projectile-ignored-projects '("~/" "/tmp" "~/.config/emacs/.local/straight/repos/"))

;; Whenever you reconfigure a package, make sure to wrap your config in an
;; `after!' block, otherwise Doom's defaults may override your settings. E.g.
;;
;;   (after! PACKAGE
;;     (setq x y))
;;
;; The exceptions to this rule:
;;
;;   - Setting file/directory variables (like `org-directory')
;;   - Setting variables which explicitly tell you to set them before their
;;     package is loaded (see 'C-h v VARIABLE' to look up their documentation).
;;   - Setting doom variables (which start with 'doom-' or '+').
;;
;; Here are some additional functions/macros that will help you configure Doom.
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;; Alternatively, use `C-h o' to look up a symbol (functions, variables, faces,
;; etc).
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.

;; Support for additional language features
(defun org-babel-execute:yaml (body params) body)

(after! ein
  (setq ein:output-area-inlined-images t))

(setq lsp-julia-package-dir nil)
(setq lsp-julia-default-environment "~/.julia/environments/v1.11")

(after! f90
  (set-formatter! 'fortitude '("fortitude" "check") :modes '(f90-mode fortran-mode)))

;; Fix for yadm dotfile manegment - strip '##...' suffix from files for mode detection.
(defun +yadm/set-mode-based-on-suffix ()
  "Set mode for files with '##' suffix by guessing based on base name."
  (let* ((filename (buffer-file-name))
         (base-name (when (string-match "\\(.*\\)##" filename)
                      (match-string 1 filename))))
    (when base-name
      (let ((mode (assoc-default base-name auto-mode-alist #'string-match)))
        (when mode
          (funcall mode))))))
(add-hook! 'find-file-hook
  (when (and buffer-file-name (string-match "##" buffer-file-name))
    (+yadm/set-mode-based-on-suffix)))

;; org-mode and org-roam
;; Settings
(after! org
 (setq org-latex-pdf-process (list "pdflatex -shell-escape %f")))

(use-package! org-super-agenda
  :after org-agenda
  :init (setq org-super-agenda-groups
              '((:name "Today"
                 :time-grid t
                 :todo "TODAY")
                (:name "Important"
                 :priority "A"
                 :order 1)
                (:priority<= "B"
                 :order 2)
                (:order-multi (4(:name "Personal"
                                 :and (:tag "personal"
                                       :not (:todo "PROJ")))
                                (:name "Work"
                                 :and (:tag "work"
                                       :not (:todo "PROJ")))))
                (:order-multi (5(:name "Meshing-related"
                                 :and (:tag "NekMesh"
                                       :not (:todo "PROJ")
                                       :and (:regexp ("mesh" "meshing"))))
                                (:name "SPH-related"
                                 :and (:tag "SPH"
                                       :not (:todo "PROJ")
                                       :and (:regexp ("SPH" "sloshing"))))))
                (:name "Research"
                 :and (:tag "Research"
                       :not (:todo "PROJ"))
                 :order 6)
                (:name "Projects"
                 :todo "PROJ"
                 :order 7)
                (:todo ("WAIT" "HOLD")
                 :order 8)))
  :config (org-super-agenda-mode)
  (setq org-super-agenda-header-map (make-sparse-keymap)))

(after! org-agenda
  (setq org-agenda-start-on-weekday t
        org-agenda-skip-scheduled-if-done t
        org-agenda-skip-deadline-if-done t
        org-agenda-include-deadlines t
        org-super-agenda-mode t)
  (set-face-attribute 'org-agenda-date nil
                      :foreground (doom-color 'magenta)
                      :weight 'bold
                      :height 1.5
                      :family "Tinos Nerd Font")
  (set-face-attribute 'org-agenda-date-weekend nil
                      :foreground (doom-color 'yellow)
                      :weight 'bold
                      :height 1.5
                      :family "Tinos Nerd Font")
  (set-face-attribute 'org-agenda-date-today nil
                      :foreground (doom-color 'orange)
                      :weight 'bold
                      :height 1.5
                      :family "Tinos Nerd Font")
  (set-face-attribute 'org-super-agenda-header nil
                      :foreground (doom-color 'cyan)
                      :weight 'bold
                      :height 1.3
                      :family "Tinos Nerd Font"))

(after! (org-roam org-agenda)
  (add-hook! 'org-after-todo-state-change-hook
    (when (and (string-prefix-p org-roam-directory
                                (buffer-file-name))
               (not (member (buffer-file-name)
                            org-agenda-files)))
      (add-to-list 'org-agenda-files (buffer-file-name)))))

;; Capture templates
(defun my/org-goto-proj-heading ()
  "Prompt for a PROJ heading in `+org-capture-todo-file` and return the marker to it."
  (let ((file +org-capture-todo-file)
        proj-headings)
    (with-current-buffer (find-file-noselect file)
      (org-element-map (org-element-parse-buffer 'headline)
          'headline
        (lambda (hl)
          (let ((todo (org-element-property :todo-keyword hl))
                (title (org-element-property :raw-value hl))
                (begin (org-element-property :begin hl)))
            (when (string= todo "PROJ")
              (push (cons title begin) proj-headings)))))
      (let* ((choices (reverse proj-headings))
             (selection (completing-read "Select Project: " (mapcar #'car choices)))
             (pos (cdr (assoc selection choices))))
        (goto-char pos)
        (org-show-context)
        (org-show-entry)
        (org-show-subtree)
        (point-marker)))))

(after! org
  (add-to-list 'org-capture-templates
               `("pp" "Project Task"
                 entry
                 (file+function ,+org-capture-todo-file my/org-goto-proj-heading)
                 "* TODO %?\n%U\n"
                 :empty-lines 1)))

(after! org-roam
  (add-to-list 'org-roam-capture-templates
               '("r" "Create a note from marked region" plain
                 (file "~/Orgs/roam/templates/region.org")
                 :if-new (file+head "%<%Y%m%d%H%M%S>-${slug}.org" "#+title: ${title}\n")
                 :unnarrowed t)))

(after! org-roam
  (add-to-list 'org-roam-capture-templates
               '("e" "Create a note from email" plain
                 (file "~/Orgs/roam/templates/email.org")
                 :if-new (file+head "%<%Y%m%d%H%M%S>-${slug}.org" "#+title: ${title}\n")
                 :unnarrowed t)))

(defun my/clipboard-contents ()
  "Return the current contents of the macOS clipboard using pbpaste."
  (string-trim (shell-command-to-string "pbpaste")))

(defun my/org-roam-clipboard-template ()
  "Return a dynamic org-roam capture template that includes clipboard text."
  (concat "%T\n\n* Source\n%?\n\n* Captured context\n"
          (my/clipboard-contents)
          "\n\n* Notes"))

(after! org-roam
  (add-to-list 'org-roam-capture-templates
               `("c" "Create a note from the clipboard" plain
                 (function my/org-roam-clipboard-template)
                 :if-new (file+head "%<%Y%m%d%H%M%S>-${slug}.org"
                                    "#+title: ${title}\n")
                 :unnarrowed t)))

;; AI assistants
;; Aidermacs setup
(use-package! aidermacs
  :config
  (setq aidermacs-default-chat-mode 'architect)
  (setq aidermacs-default-model "gemini")
  (setq aidermacs-anthropic-api-key (getenv "ANTHROPIC_API_KEY"))
  (setq aidermacs-gemini-api-key (getenv "GEMINI_API_KEY"))
  (setq aidermacs-deepseek-api-key (getenv "DEEPSEEK_API_KEY"))
  (setq aidermacs-backend 'vterm)
  (add-to-list 'aidermacs-extra-args "--code-theme gruvbox")
  )

;; GPTs
(use-package! gptel
  :config
  ;; Set your Anthropic API key from the environment
  (setq gptel-api-key (getenv "ANTHROPIC_API_KEY"))

  (setq gptel-backend-anthropic
        (gptel-make-anthropic "Anthropic" :stream t :key gptel-api-key))
  (setq gptel-backend-gemini
        (gptel-make-gemini "Gemini" :stream t :key (getenv "GEMINI_API_KEY")))
  (setq gptel-backend-copilot (gptel-make-gh-copilot "Copilot"))
  (setq gptel-backend-ollama
        (gptel-make-ollama "Ollama"
                           :host "localhost:11434"
                           :models '("codellama:latest" "wizardcoder:latest" "mistral:latest")
                           :stream t))
  (setq gptel-backend gptel-backend-anthropic)
  (setq-default gptel-model 'claude-3-7-sonnet-20250219))

(map! :leader
      (:prefix ("e" . "AI")
       :desc "GPTel" "g" #'gptel-menu
       :desc "Start GPTel" "s" #'gptel
       :desc "Aidermac menu"
       "a" #'aidermacs-transient-menu))

(map! :map gptel-mode-map
      :localleader
      :desc "Send message" "RET" #'gptel-send
      :desc "Abort request" "a" #'gptel-abort)

;; Copilot completion
;; (use-package! copilot
;;   :hook (prog-mode . copilot-mode)
;;   :bind (:map copilot-completion-map
;;               ("<tab>" . 'copilot-accept-completion)
;;               ("TAB" . 'copilot-accept-completion)
;;               ("C-TAB" . 'copilot-accept-completion-by-word)
;;               ("C-<tab>" . 'copilot-accept-completion-by-word)))

;; Email
(let ((private-email "~/.config/doom/email.el"))
  (when (file-exists-p private-email)
    (load private-email)))

(after! mu4e
  (defun apply-maildir-shortcuts ()
    "Sets `mu4e-maildir-shortcuts` based on mu4e context."
    (let* ((context (mu4e-context-current))
           (vars (and context (mu4e-context-vars context)))
           (shortcuts (cdr (assoc '+maildir-shortcuts vars))))
      (when shortcuts
        (setq mu4e-maildir-shortcuts shortcuts))))

  (add-hook 'mu4e-main-mode-hook #'apply-maildir-shortcuts))
  (add-hook 'mu4e-context-changed-hook #'apply-maildir-shortcuts)

;; Change these key bindings for MacOS
(map! :after mu4e
      :map mu4e-view-mode-map
      :n "C-j" nil
      :n "M-j" #'mu4e-view-headers-next
      :n "C-k" nil
      :n "M-k" #'mu4e-view-headers-prev)

(after! mu4e
  (setq sendmail-program (executable-find "msmtp")
        send-mail-function #'smtpmail-send-it
        message-sendmail-f-is-evil t
        message-sendmail-extra-arguments '("--read-envelope-from")
        message-send-mail-function #'message-send-mail-with-sendmail
        mu4e-change-filenames-when-moving t
        mu4e-index-lazy-check nil
        mu4e-headers-folded-default t
        mu4e-sent-messages-behavior 'delete)

  ;; Force close buffer with draft email
  (add-hook 'mu4e-compose-mode-hook
            (lambda ()
              ;; Try to disable auto-save and Fcc
              (setq-local message-auto-save-directory nil)
              (setq-local message-auto-save-buffer-name nil)
              (setq-local message-do-fcc nil)
              (auto-save-mode -1)

              ;; Ensure the buffer isn't marked modified after sending
              (add-hook 'message-send-hook
                        (lambda ()
                          (set-buffer-modified-p nil))
                        nil t)

              ;; Kill the buffer if still around after send
              (add-hook 'message-sent-hook
                        (lambda ()
                          (let ((buf (current-buffer)))
                            (run-at-time
                             "1 sec" nil
                             (lambda ()
                               (when (buffer-live-p buf)
                                 (with-current-buffer buf
                                   (set-buffer-modified-p nil))
                                 (kill-buffer buf)))))
                        nil t)))))

(after! mu4e
    (custom-theme-set-faces!
      'user
      `(mu4e-header-from-face :foreground ,(doom-color 'magenta))
      `(mu4e-header-subject-face :foreground ,(doom-color 'cyne))
      `(mu4e-header-date-face :foreground ,(doom-color 'green))
      `(mu4e-header-highlight-face :foreground ,(doom-color 'yellow))))

;; ;; Rebuild mail index while using mu4e - adapted from https://tecosaur.github.io/emacs-config/config.html#fetching
;; (defvar mu4e-reindex-request-dir "/tmp/mu"
;;     "Location of the directory containing the reindex request file.")
;; (defvar mu4e-reindex-request-file "mu_reindex_now"
;;     "Filename that triggers reindex request, signaled by existance.")

;; (defvar mu4e-reindex-request-min-seperation 5.0
;;   "Don't refresh again until this many seconds have elapsed.
;; Prevents a series of redisplays from being called (when set to an appropriate value).")

;; (defvar mu4e-reindex-request--file-watcher nil)
;; (defvar mu4e-reindex-request--file-just-deleted nil)
;; (defvar mu4e-reindex-request--last-time 0)

;; (defun mu4e-reindex-request--file-path ()
;;   (expand-file-name mu4e-reindex-request-file mu4e-reindex-request-dir))

;; (defun mu4e-reindex-request--add-watcher ()
;;   (setq mu4e-reindex-request--file-just-deleted nil)
;;   (unless (file-directory-p mu4e-reindex-request-dir)
;;     (make-directory mu4e-reindex-request-dir t))
;;   (setq mu4e-reindex-request--file-watcher
;;         (file-notify-add-watch mu4e-reindex-request-dir
;;                                '(change)
;;                                #'mu4e-file-reindex-request)))

;; (defadvice! mu4e-stop-watching-for-reindex-request ()
;;   :after #'mu4e--server-kill
;;   (when mu4e-reindex-request--file-watcher
;;     (file-notify-rm-watch mu4e-reindex-request--file-watcher)))

;; (defadvice! mu4e-watch-for-reindex-request ()
;;   :after #'mu4e--server-start
;;   (mu4e-stop-watching-for-reindex-request)
;;   (let ((file (mu4e-reindex-request--file-path)))
;;     (when (file-exists-p file)
;;       (delete-file file)))
;;   (mu4e-reindex-request--add-watcher))

;; (defun mu4e-file-reindex-request (event)
;;   "Act based on the existance of `mu4e-reindex-request-file`."
;;   (let ((action (nth 1 event))
;;         (path (nth 2 event)))
;;     (if mu4e-reindex-request--file-just-deleted
;;         (mu4e-reindex-request--add-watcher)
;;       (when (and (eq action 'created)
;;                  (string= (file-name-nondirectory path) mu4e-reindex-request-file))
;;         (delete-file (mu4e-reindex-request--file-path))
;;         (setq mu4e-reindex-request--file-just-deleted t)
;;         (mu4e-reindex-maybe t)))))

;; (defun mu4e-reindex-maybe (&optional new-request)
;;   "Run `mu4e--server-index' if it's been more than
;; `mu4e-reindex-request-min-seperation' seconds since the last request."
;;   (let ((time-since-last-request (- (float-time)
;;                                     mu4e-reindex-request--last-time)))
;;     (when new-request
;;       (setq mu4e-reindex-request--last-time (float-time)))
;;     (if (> time-since-last-request mu4e-reindex-request-min-seperation)
;;         (mu4e--server-index nil t)
;;       (when new-request
;;         (run-at-time (* 1.1 mu4e-reindex-request-min-seperation) nil
;;                      #'mu4e-reindex-maybe)))))

