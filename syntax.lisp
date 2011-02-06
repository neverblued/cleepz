(in-package #:cleepz)

(defmacro define-parser (name &rest sequence)
  (let ((var (symb "*" (string-upcase name) "-REGEX*"))
        (scanner `(create-scanner '(:sequence ,@sequence) :single-line-mode t)))
    `(progn (defparameter ,var ,scanner))))

;; 12<!--: OH SHI~ :-->34 => 1234

(define-parser comment
    "<!--:" (:non-greedy-repetition 0 nil :everything) ":-->")

;; 12 -:-  34 => 1234

(define-parser space
    (:greedy-repetition 0 nil :whitespace-char-class)
    "-:-"
    (:greedy-repetition 0 nil :whitespace-char-class))

;; <? data :source some-package::printable-data /?>

(define-parser simple
    "<? " (:register (:regex "\\w+")) (:regex "\\s+") (:register (:non-greedy-repetition 0 nil :everything)) " /?>")

;; <? example-view list
;;                 :source some-package::list-data
;;                 :item my-item ?>
;;       clips*
;; <? /example-view ?>

(define-parser complex
    "<? " (:named-register "view-name" (:regex "[\\w\\-]+")) (:regex "\\s+")
          (:named-register "view-class" (:regex "\\w+")) (:regex "\\s+")
          (:register (:non-greedy-repetition 0 nil :everything)) " ?>"
    (:register (:non-greedy-repetition 0 nil :everything))
    "<? /" (:back-reference "view-name") " ?>")

;; * clips:
;;    <: (eql view-data::clip-purpose :item)                           :> <? data :source view-data::my-item ?>
;;    <: (and (eql view-data::clip-purpose :separator)
;;            (= view-data::counter (length some-package::list-data))) :> , and also

(define-parser clip
    "<:" (:regex "\\s+") (:register (:sequence "(" (:non-greedy-repetition 0 nil :everything) ")")) (:regex "\\s+") ":>"
    (:register (:non-greedy-repetition 0 nil :everything))
    "<:/:>")
