;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets.
(setq user-full-name "Mashy D Green"
      user-mail-address "mdgreen@ic.ac.uk")

;; Doom exposes five (optional) variables for controlling fonts in Doom. Here
;; are the three important ones:
;;
;; + `doom-font'
;; + `doom-variable-pitch-font'
;; + `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;;
;; They all accept either a font-spec, font string ("Input Mono-12"), or xlfd
;; font string. You generally only need these two:
(setq doom-font (font-spec :family "monospace" :size 14))

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-molokai)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/Orgs/")

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type 'relative)


;; Here are some additional functions/macros that could help you configure Doom:
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c g k').
;; This will open documentation for it, including demos of how they are used.
;;
;; You can also try 'gd' (or 'C-c g d') to jump to their definition and see how
;; they are implemented.
;;
;; (after! mu4e
;;   (defun my-string-width (str)
;;     "Return the width in pixels of a string in the current
;; window's default font. If the font is mono-spaced, this
;; will also be the width of all other printable characters."
;;     (let ((window (selected-window))
;;           (remapping face-remapping-alist))
;;       (with-temp-buffer
;;         (make-local-variable 'face-remapping-alist)
;;         (setq face-remapping-alist remapping)
;;         (set-window-buffer window (current-buffer))
;;         (insert str)
;;         (car (window-text-pixel-size)))))


;;   (cl-defun mu4e~normalised-icon (name &key set colour height v-adjust)
;;     "Convert :icon declaration to icon"
;;     (let* ((icon-set (intern (concat "all-the-icons-" (or set "faicon"))))
;;            (v-adjust (or v-adjust 0.02))
;;            (height (or height 0.8))
;;            (icon (if colour
;;                      (apply icon-set `(,name :face ,(intern (concat "all-the-icons-" colour)) :height ,height :v-adjust ,v-adjust))
;;                    (apply icon-set `(,name  :height ,height :v-adjust ,v-adjust))))
;;            (icon-width (my-string-width icon))
;;            (space-width (my-string-width " "))
;;            (space-factor (- 2 (/ (float icon-width) space-width))))
;;       (concat (propertize " " 'display `(space . (:width ,space-factor))) icon)
;;       ))

;;   (setq mu4e-use-fancy-chars t
;;         mu4e-headers-draft-mark      (cons "D" (mu4e~normalised-icon "pencil"))
;;         mu4e-headers-flagged-mark    (cons "F" (mu4e~normalised-icon "flag"))
;;         mu4e-headers-new-mark        (cons "N" (mu4e~normalised-icon "sync" :set "material" :height 0.8 :v-adjust -0.10))
;;         mu4e-headers-passed-mark     (cons "P" (mu4e~normalised-icon "arrow-right"))
;;         mu4e-headers-replied-mark    (cons "R" (mu4e~normalised-icon "arrow-right"))
;;         mu4e-headers-seen-mark       (cons "S" "") ;(mu4e~normalised-icon "eye" :height 0.6 :v-adjust 0.07 :colour "dsilver"))
;;         mu4e-headers-trashed-mark    (cons "T" (mu4e~normalised-icon "trash"))
;;         mu4e-headers-attach-mark     (cons "a" (mu4e~normalised-icon "file-text-o" :colour "silver"))
;;         mu4e-headers-encrypted-mark  (cons "x" (mu4e~normalised-icon "lock"))
;;         mu4e-headers-signed-mark     (cons "s" (mu4e~normalised-icon "certificate" :height 0.7 :colour "dpurple"))
;;         mu4e-headers-unread-mark     (cons "u" (mu4e~normalised-icon "eye-slash" :v-adjust 0.05))))

;; (after! mu4e
;;   (setq mu4e-headers-fields
;;         '((:account . 12)
;;           (:human-date . 8)
;;           (:flags . 6)
;;           (:from . 25)
;;           (:recipnum . 2)
;;           (:subject)))
;;   (plist-put (cdr (assoc :flags mu4e-header-info)) :shortname " Flags") ; default=Flgs
;;   (setq mu4e-header-info-custom
;;         '((:account .
;;            (:name "Account" :shortname "Account" :help "Which account this email belongs to" :function
;;             (lambda (msg)
;;               (let ((maildir
;;                      (mu4e-message-field msg :maildir)))
;;                 (replace-regexp-in-string "^gmail" (propertize "g" 'face 'bold-italic)
;;                                           (format "%s"
;;                                                   (substring maildir 1
;;                                                              (string-match-p "/" maildir 1))))))))
;;           (:recipnum .
;;            (:name "Number of recipients"
;;             :shortname " ⭷"
;;             :help "Number of recipients for this message"
;;             :function
;;             (lambda (msg)
;;               (propertize (format "%2d"
;;                                   (+ (length (mu4e-message-field msg :to))
;;                                      (length (mu4e-message-field msg :cc))))
;;                           'face 'mu4e-footer-face)))))))

;; (defadvice! mu4e~main-action-prettier-str (str &optional func-or-shortcut)
;;   "Highlight the first occurrence of [.] in STR.
;; If FUNC-OR-SHORTCUT is non-nil and if it is a function, call it
;; when STR is clicked (using RET or mouse-2); if FUNC-OR-SHORTCUT is
;; a string, execute the corresponding keyboard action when it is
;; clicked."
;;   :override #'mu4e~main-action-str
;;   (let ((newstr
;;          (replace-regexp-in-string
;;           "\\[\\(..?\\)\\]"
;;           (lambda(m)
;;             (format "%s"
;;                     (propertize (match-string 1 m) 'face '(mode-line-emphasis bold))))
;;           (replace-regexp-in-string "\t\\*" "\t⚫" str)))
;;         (map (make-sparse-keymap))
;;         (func (if (functionp func-or-shortcut)
;;                   func-or-shortcut
;;                 (if (stringp func-or-shortcut)
;;                     (lambda()(interactive)
;;                       (execute-kbd-macro func-or-shortcut))))))
;;     (define-key map [mouse-2] func)
;;     (define-key map (kbd "RET") func)
;;     (put-text-property 0 (length newstr) 'keymap map newstr)
;;     (put-text-property (string-match "[A-Za-z].+$" newstr)
;;                        (- (length newstr) 1) 'mouse-face 'highlight newstr)
;;     newstr))

;; (setq evil-collection-mu4e-end-region-misc "quit")

;; (map! :map mu4e-main-mode-map
;;       :after mu4e
;;       :nive "h" #'+workspace/other)
;; (after! mu4e
;;   (setq sendmail-program "/usr/local/bin/msmtp"
;;         send-mail-function 'smtpmail-send-it
;;         message-sendmail-f-is-evil t
;;         message-sendmail-extra-arguments '("--read-envelope-from"); , "--read-recipients")
;;         message-send-mail-function 'message-send-mail-with-sendmail))
;; (after! mu4e
;;   (defun my-mu4e-set-account ()
;;     "Set the account for composing a message."
;;     (unless (and mu4e-compose-parent-message
;;                (let ((mail (cdr (car (mu4e-message-field mu4e-compose-parent-message :to)))))
;;                  (if (member mail (plist-get mu4e~server-props :personal-addresses))
;;                      (setq user-mail-address mail)
;;                    nil)))
;;       (ivy-read "Account: " (plist-get mu4e~server-props :personal-addresses) :action (lambda (candidate) (setq user-mail-address candidate)))))
;; (add-hook 'mu4e-compose-pre-hook 'my-mu4e-set-account))

;; (defun mu4e-compose-from-mailto (mailto-string)
;;   (require 'mu4e)
;;   (unless mu4e~server-props (mu4e t) (sleep-for 0.1))
;;   (let* ((mailto (rfc2368-parse-mailto-url mailto-string))
;;          (to (cdr (assoc "To" mailto)))
;;          (subject (or (cdr (assoc "Subject" mailto)) ""))
;;          (body (cdr (assoc "Body" mailto)))
;;          (org-msg-greeting-fmt (if (assoc "Body" mailto)
;;                                    (replace-regexp-in-string "%" "%%"
;;                                                              (cdr (assoc "Body" mailto)))
;;                                  org-msg-greeting-fmt))
;;          (headers (-filter (lambda (spec) (not (-contains-p '("To" "Subject" "Body") (car spec)))) mailto)))
;;     (mu4e~compose-mail to subject headers)))
