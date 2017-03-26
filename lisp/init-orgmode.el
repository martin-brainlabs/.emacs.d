;;; init-orgmode --- My org-related settings
;;; Code:
(global-set-key "\C-cl" 'org-store-link)
(global-set-key "\C-ca" 'org-agenda)
(global-set-key "\C-cc" 'org-capture)
(global-set-key "\C-cb" 'org-iswitchb)
(setq org-directory "~/orgfiles"
      org-default-notes-file (concat org-directory "/notes.org")
      org-capture-templates '(("t" "Task" entry (file "~/orgfiles/tasks.org")
			       "* TODO %?\n  %i\n  %a")
			      ("e" "Calendar Event" entry (file "~/orgfiles/gcal.org")
			       "* %?\n\n%^T\n\n")
			      ("o" "Trello Card" entry (file "~/orgfiles/trello.org")
			       "* To-Do %?\n %i\n %a")))
(provide 'init-orgmode)

;;; Commentary:

;; Local Variables:
;; byte-compile-warnings: (not free-vars)
;; End:
;;; init-orgmode ends here