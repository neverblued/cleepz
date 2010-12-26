(in-package #:cleepz)

;; {{slot:menu-item}}

(defparameter *slot-regex*
  "\\{\\{slot:([^\\}]+)\\}\\}")

;; {{clip:menu-item?mode=current}}<li><a href= *** /a></li>{{/clip}}

(defparameter *clip-regex*
  (create-scanner '(:sequence "{{clip:"
                    (:register (:non-greedy-repetition 0 nil :everything))
                    "}}"
                    (:regex "\\s*")
                    (:register (:non-greedy-repetition 0 nil :everything))
                    (:regex "\\s*")
                    "{{/clip}}"
                    )
                  :single-line-mode t))

;; {-y-} While the reader owl sleeps, all content is missed. {0y0}

(defparameter *comment-begin* "{-y-}")
(defparameter *comment-end*   "{0y0}")
(define-symbol-macro *comment-regex*
    (create-scanner `(:sequence
                      ,*comment-begin*
                      (:non-greedy-repetition 0 nil :everything)
                      ,*comment-end*
                      )
                    :single-line-mode t))
