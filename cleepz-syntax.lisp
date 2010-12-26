(in-package #:cleepz)

(defmacro define-parser (name &rest sequence)
  `(defparameter ,(symb "*" (string-upcase name) "-REGEX*")
     (create-scanner '(:sequence ,@sequence) :single-line-mode t)))

;; 12{0y0} Whoo? {-y-}34 => 1234

(define-parser comment
    "{0y0}" (:non-greedy-repetition 0 nil :everything) "{-y-}"
    )

;; 12 {*y*}  34 => 1234

(define-parser space
    (:greedy-repetition 0 nil :whitespace-char-class)
    "{*y*}"
    (:greedy-repetition 0 nil :whitespace-char-class)
    )

;; {^y(data :source some-package::printable-data)}

(define-parser simple
    "{^y(" (:register (:regex "\\w+")) (:regex "\\s+") (:register (:non-greedy-repetition 0 nil :everything)) ")}"
    )

;; {0y(list :source some-package::list-data :item :my-item)} clips* {-y(list)}

(define-parser complex
    "{0y(" (:register (:regex "\\w+")) (:regex "\\s+") (:register (:non-greedy-repetition 0 nil :everything)) ")}"
    (:register (:non-greedy-repetition 0 nil :everything))
    "{-y(" (:back-reference 1) ")}"
    )

;; * clips:
;;    (= (getf request :clip) :item)
;;      8< {^y(data :source (cleepz::template-datum :my-item))} >8
;;    (and (eql (getf request :clip) :separator)
;;         (= (getf request :iterator)
;;            (length some-package::list-data)))
;;      8< , and also  >8

(define-parser clip
    (:register (:sequence "(" (:non-greedy-repetition 0 nil :everything) ")"))
    (:regex "\\s*")
    "8<"
    ;(:regex "\\s?")
    (:register (:non-greedy-repetition 0 nil :everything))
    ;(:regex "\\s?")
    ">8"
    )
