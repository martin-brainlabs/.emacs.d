;;; fluca-php --- Some useful PHP functions
;;; Commentary:
;; -----------------------------------------------------------------------------------
;; fluca-php.el
;; This file provides some simple functions to enhance the Emacs library
;; in order to allow and automate some PHP related tasks, such as creating
;; new classes, new properties into classes, and so on.
;; This extension does not require the php-mode to be loaded, even if
;; it is suggested that you load the mode in your configuration.
;;
;; Commands defined in this file:
;; - php-class defines a new class in a new buffer saving it in the current
;;             working directory
;; - php-class-in-path defines a new PHP class skeleton in a saved buffer
;;                     asking the user for the path where to save the buffer
;; - php-prop  defines a new property with getter and setter methods
;; -----------------------------------------------------------------------------------

;;; Code:
(defun php-class (class-name)
  "Create a new PHP class skeleton (CLASS-NAME) in the current directory."
  (interactive "sClass name: ")
  (php-class-in-path class-name ".")
  )

(defun php-class-in-path (class-name class-file-path )
  "Create a new class (CLASS-NAME) in an empty buffer.
The function generates a capitalized version of the class name and ensures
that no other files with the same class name already exist in the
current path (CLASS-FILE-PATH)"
  (interactive "sClass name: \nsClass file path: \nsOptional comment for the class: ")
  ;; check that the user has inserted a good class name
  (if (equal "" class-name)
      (message "Cannot create a class without a name!")
    (let* ((class-name (concat (capitalize (substring class-name 0 1) )
			       (substring class-name 1) ) )
	   (class-file-name (concat class-file-path "/" class-name ".php") ) ; the name of the file
	   )
      ;; ensure that the file that will hold the class does not exists
      ;; already
      (if (file-exists-p class-file-name)
	  (message "The file %s already exists, aborting!" class-file-name)
	(progn
	  ;; generate the buffer or visit it
	  (switch-to-buffer (find-file-noselect class-file-name))
	  ;; insert the beginning of the class
	  (insert "<?php" ?\n ?\n
		  "class " class-name ?\n " {" ?\n
		  "/**" ?\n
		  "*/" ?\n
		  "public function __construct()" ?\n "{" ?\n
		  "}" ?\n
		  )
	  ;; insert the end of the class
	  ;; use a save excursion so that the user will start editing from this point
	  (save-excursion
	    (insert ?\n ?\n ?\n
		    "}" ?\n
		    )			; end of the insert block
	    )
	  ;; indent the created region (whole buffer)
	  (c-indent-region (point-min) (point-max) t)
	  (save-buffer)
	  (message "Generation of the class %s done, file %s saved!"
		   class-name class-file-name )
	  )					; end of the progn
	)					; end of the if on the file name
      )					; end of the let
    )						; end of the if
  )					; end of defun

;; -----------------------------------------------------------------------
(defun php-prop (property-name property-type)
  "Create a new class property variable (PROPERTY-NAME).
With an type (PROPERTY-TYPE)  and with a getter
and a setter method at the point where the cursor is"
  (interactive "sProperty name: \nsProperty type: ")
  (progn
    ;; ensure that the property name is correct, that is not an empty
    ;; string and remove any leading $sign (the user could have typed $myProperty
    ;; instead of myProperty)
    (while (string-match "[\$ \s\t]^*" property-name)
      (setq property-name (replace-match "" nil nil property-name))
      )
    (while (string-match "[ \s\t]$*" property-name)
      (setq property-name (replace-match "" nil nil property-name))
      )
    (if (equal "" property-name)
	;; the user has not specified the property name!
	(message "Cannot insert a not specified property, aborting!")
      ;; if here the user has specified the property name, so
      ;; compute the names of getter/setter
      (let ((setter-name (concat "set"
				 (capitalize (substring property-name 0 1) )
				 (substring property-name 1) )
			 ) 		; end of the setter-name variable
	    (getter-name (concat "get"
				 (capitalize (substring property-name 0 1) )
				 (substring property-name 1) )
			 ) 		; end of the getter-name variable

	    (generate-getter t) 		; do I have to generate the getter?
	    (generate-setter t) 		; do I have to generate the setter?
	    (src-point (point)) 		; where am I?
	    (property-insertion-point (point) ) ; the point where the property will be inserted
	    (property-end-point (point) )	      ; the point where the property ends
	    (generate-property t)
	    (setter-arg-name (concat "$" property-name ) )
	    (method-insertion-point (point)) ;where the methods will be inserted
	    ) 				; end of the let variable list

	;; remember the current cursor position in the buffer
	(save-excursion
	  (progn

	    ;; I need to check if the getters and setters are already there
	    (goto-char (point-min) )
	    (search-forward "class")		; move to the beginning of the class
	    (if (re-search-forward (concat "[\s \t\n]*public[\s \t\n]*function[\s \t\n]*" setter-name "[\s \t\n]*\(.*\)") nil t 1)
		(setq generate-setter nil)
	      (setq generate-setter t)
	      )
	    (goto-char (point-min) )
	    (if (re-search-forward (concat "[\s \t\n]*public[\s \t\n]*function[\s \t\n]*" getter-name "[\s \t\n]*\([\s \t\n]*\)") nil t 1)
		(setq generate-getter nil)
	      (setq generate-getter t)
	      )
	    (goto-char (point-min) )
	    (if (re-search-forward (concat "[\s \t\n]* \\(private\\|public\\)[\s \t\n]*$" property-name) nil t 1)
		(progn
		  (setq generate-property nil)
		  (setq property-insertion-point (point))
		  )
	      (setq generate-property t)
	      )
	    ;; go back to the original position
	    (goto-char src-point)
	    ;; do I have to generate the property?
	    (if generate-property
		(progn
		  (insert "/** @var " property-type " " setter-arg-name "*/" ?\n
			  "private $" property-name ";" ?\n
			  ?\n
			  )			; end of the insert for the property
		  (setq property-end-point (point) ) ; store where the property ends
		  ;; indent the property region
		  (c-indent-region property-insertion-point property-end-point t)
		  ;; go to the end of the buffer and position before the last
		  ;; curly brace that should close the class
		  (goto-char (point-max))		; goto end of buffer
		  (re-search-backward "}")		; go back to the last }
		  (setq method-insertion-point (point) ) ; store where the methods will be added
		  (if generate-getter
		      (insert ?\n
			      "/**" ?\n
			      "* @return " property-type ?\n
			      "*/" ?\n
			      "public function " getter-name "()" ?\n
			      "{" ?\n
			      "return $this->" property-name ";"
			      ?\n
			      "}"
			      ?\n
			      )		; end of the insert for the getter
		    (message "Skipping the generation of the getter method")
		    )			; end of the if for the getter method
		  (if generate-setter
		      (insert
		       ?\n
		       "/**" ?\n
		       "* @param " property-type " " setter-arg-name ?\n
		       "* @return self" ?\n
		       "*/" ?\n
		       "public function " setter-name "(" setter-arg-name ")" ?\n
		       "{" ?\n
		       "$this->" property-name " = " setter-arg-name ";" ?\n
		       "return $this;" ?\n
		       "}"
		       ?\n
		       )			; end of the insert body for the setter method
		    (message "Skipping the generation of the setter method")
		    )				; end of the if for the setter method
		  ;; indent the region for the methods
		  (c-indent-region method-insertion-point (point) t)
		  ) 				; end of the progn on the generation of the property
	      (message "Cannot generate the property [%s], it already exists at line %d"
		       property-name
		       (count-lines 1 property-insertion-point ) )
	      )				; end of the if for the property generation
	    ) 					; end of progn within save excursion
	  )					; end of the save-escurion
	)						; end of the let main body
      )					;end of the if on the property name
    )					; end of the progn
  )				;end of defun

(provide 'fluca-php)

;;; fluca-php.el ends here
