(fset 'yes-or-no-p 'y-or-n-p)
(global-set-key (kbd "<s-up>") 'toggle-frame-fullscreen)
(show-paren-mode)
(global-column-enforce-mode t)

;; Zenburn
(use-package zenburn-theme
  :ensure t)

(use-package org
  :ensure org-plus-contrib
  :bind (("C-c l" . org-store-link)
	 ("C-c a" . org-agenda)
	 ("C-c c" . org-capture)
	 ("C-c b" . org-iswitchb))
  :init
  (setq org-directory "~/orgfiles"
	org-default-notes-file (concat org-directory "/notes.org")
	org-capture-templates '(("t" "Task" entry (file "~/orgfiles/tasks.org")
				 "* TODO %?\n  %i\n  %a")
				("e" "Calendar Event" entry (file "~/orgfiles/gcal.org")
				 "* %?\n\n%^T\n\n")
				("o" "Trello Card" entry (file "~/orgfiles/trello.org")
				 "* To-Do %?\n %i\n %a")))
  )

;; Company
(use-package company
  :ensure t
  :config
  (global-company-mode)
  (setq company-dabbrev-downcase nil)
  )

;; Flycheck
(use-package flycheck
  :defer t
  :ensure t
  :config
  (global-flycheck-mode)
  )

(use-package eldoc
  :config
  (global-eldoc-mode))

(use-package magit
  :ensure t
  :bind (("C-x g" . magit-status)))
(use-package magithub)

(use-package php-auto-yasnippets
  :ensure t
  :bind (:map php-mode-map
	      ("C-c C-y" . yas/create-php-snippet))
  ;;  :config (define-key php-mode-map (kbd "C-c C-y") 'yas/create-php-snippet)
  )

(use-package php-refactor-mode
  :defer t)

(use-package phpcbf
  :ensure t
  :config
  (setq phpcbf-standard 'PSR2))

(use-package ggtags
  :ensure t)

(use-package php-mode
  :defer t
  :ensure t
  :mode "\\.php$"
  :init
  (add-hook 'php-mode-hook
	    (lambda ()
              (php-refactor-mode)
	      (ggtags-mode)
	      (php-eldoc-enable)
              (php-enable-psr2-coding-style)
	      (add-to-list 'company-backends '(company-gtags php-extras-company))
	      )
	    )
  )

(use-package fluca-php
:load-path "site-lisp/")

(use-package company-tern
  :ensure t
  )

(use-package js2-mode
  :ensure t
  :defer t
  :mode "\\.js\\'"
  :interpreter "node"
  :init
  (add-hook 'js2-mode-hook (tern-mode))
  :config 
  (add-to-list 'company-backends 'company-tern))

(use-package elpy
  :defer t
  :ensure t
  :interpreter "python3"
  :config
  (elpy-enable))
