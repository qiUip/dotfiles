;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
(setq user-full-name "Mashy Green"
      user-mail-address "mashy.green@ucl.ac.uk")

;; Doom exposes five (optional) variables for controlling fonts in Doom:
;;
;; - `doom-font' -- the primary font to use
;; - `doom-variable-pitch-font' -- a non-monospace font (where applicable)
;; - `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;; - `doom-symbol-font' -- for symbols
;; - `doom-serif-font' -- for the `fixed-pitch-serif' face

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-nord-aurora)

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type 'relative)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/Orgs/")

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

(add-to-list 'default-frame-alist '(undecorated-round . t))

(after! org
 (setq org-latex-pdf-process (list "pdflatex -shell-escape %f")))

(use-package! org-super-agenda
  :commands org-super-agenda-mode)

(after! org-agenda
  (org-super-agenda-mode))

(after! (org-roam org-agenda)
  (add-hook! 'org-after-todo-state-change-hook
    (when (and (string-prefix-p org-roam-directory
                                (buffer-file-name))
               (not (member (buffer-file-name)
                            org-agenda-files)))
      (add-to-list 'org-agenda-files (buffer-file-name)))))

(after! ein
  (setq ein:output-area-inlined-images t))

(defun org-babel-execute:yaml (body params) body)

(after! f90
  (set-formatter! 'fortitude '("fortitude" "check") :modes '(f90-mode fortran-mode)))

(setq lsp-julia-package-dir nil)
(setq lsp-julia-default-environment "~/.julia/environments/v1.11")

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
)
(map! :leader
      :desc "Aidermac menu"
      "p a" #'aidermacs-transient-menu)

;; Copilot completion
;; (use-package! copilot
;;   :hook (prog-mode . copilot-mode)
;;   :bind (:map copilot-completion-map
;;               ("<tab>" . 'copilot-accept-completion)
;;               ("TAB" . 'copilot-accept-completion)
;;               ("C-TAB" . 'copilot-accept-completion-by-word)
;;               ("C-<tab>" . 'copilot-accept-completion-by-word)))

;; GPTs
;; (use-package! gptel
;;   :commands (gptel gptel-menu gptel-send gptel-set-topic)
;;   :config
;;   (setq-default gptel-model "codellama:latest")
;;   (setq-default gptel-backend (gptel-make-ollama
;;                                   "Ollama"
;;                                 :host "localhost:11434"
;;                                 :models '("codellama:latest" "wizardcoder:latest" "mistral:latest")
;;                                 :stream t)))

;; Email
;; Basic mu4e
(set-email-account! "mashy.green@ucl.ac.uk"
  '((mu4e-sent-folder       . "/ucl/Sent Items")
    (mu4e-drafts-folder     . "/ucl/Drafts")
    (mu4e-trash-folder      . "/ucl/Deleted Items")
    (mu4e-refile-folder     . "/ucl/Archive"))
  t)

(setq mu4e-maildir-shortcuts  '((:maildir "/ucl/INBOX"         :key ?i)
                                (:maildir "/ucl/Sent Items"    :key ?s)
                                (:maildir "/ucl/Drafts"        :key ?d)
                                (:maildir "/ucl/Archive"       :key ?a)
                                (:maildir "/ucl/Deleted Items" :key ?t)))

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
        mu4e-index-lazy-check nil))

(run-at-time "5 min" 300 #'mu4e-update-index)

;; Signature that works with org-msg
(defvar +mu4e-signature
  (cons
   ;; Plain text version
   (string-join
    '("--"
      "Dr Mashy Green"
      "Senior Research Software Engineer"
      "Centre for Advanced Research Computing"
      "University College London")
    "\n")
   ;; Org/HTML version (org markup with HTML support via org-msg)
   (string-join
    '("--\\\\"
      "Dr Mashy Green\\\\"
      "Senior Research Software Engineer\\\\"
      "Centre for Advanced Research Computing\\\\"
      "University College London")
    "\n")))
(after! org-msg
  (setq org-msg-signature
        (concat "\n\n#+begin_signature\n"
                (cdr +mu4e-signature)
                "\n#+end_signature")))
