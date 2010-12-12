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

;; {0y0} The comments are visible only to the owl. {-y-}

(defparameter *comment-regex*
  (create-scanner '(:sequence "{0y0}"
                    (:non-greedy-repetition 0 nil :everything)
                    "{-y-}"
                    )
                  :single-line-mode t))
