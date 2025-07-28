;;; ../doom##os.Darwin/email.el -*- lexical-binding: t; -*-

(set-email-account! "ucl"
  '((+mu4e-personal-addresses "mashy.green@ucl.ac.uk")
    (mu4e-sent-folder       . "/ucl/Sent Items")
    (mu4e-drafts-folder     . "/ucl/Drafts")
    (mu4e-trash-folder      . "/ucl/Deleted Items")
    (mu4e-refile-folder     . "/ucl/Archive")
    (+maildir-shortcuts     . ((:maildir "/ucl/INBOX"         :key ?i)
                               (:maildir "/ucl/Sent Items"    :key ?s)
                               (:maildir "/ucl/Drafts"        :key ?d)
                               (:maildir "/ucl/Archive"       :key ?a)
                               (:maildir "/ucl/Deleted Items" :key ?t))))
  t)

(set-email-account! "icloud"
  '((+mu4e-personal-addresses "mashy@me.com")
    (mu4e-sent-folder       . "/icloud/Sent Messages")
    (mu4e-drafts-folder     . "/icloud/Drafts")
    (mu4e-trash-folder      . "/icloud/Deleted Messages")
    (mu4e-refile-folder     . "/icloud/Archive")
    (+maildir-shortcuts     . ((:maildir "/icloud/INBOX"            :key ?i)
                               (:maildir "/icloud/Sent Messages"    :key ?s)
                               (:maildir "/icloud/Drafts"           :key ?d)
                               (:maildir "/icloud/Archive"          :key ?a)
                               (:maildir "/icloud/Deleted Messages" :key ?t))))
  t)



;; signature that works with org-msg
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
