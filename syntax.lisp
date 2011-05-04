;; (c) Дмитрий Пинский <demetrius@neverblued.info>
;; Допускаю использование и распространение согласно
;; LLGPL -> http://opensource.franz.com/preamble.html

(in-package #:cleepz)

(defmacro define-parser (name &rest sequence)
  (let ((var (symb "*" (string-upcase name) "-REGEX*"))
        (scanner `(create-scanner '(:sequence ,@sequence) :single-line-mode t)))
    `(progn (defparameter ,var ,scanner))))

;; 12 -:-  34 => 1234

(define-parser reduce
    (:greedy-repetition 0 nil :whitespace-char-class)
    "-:-"
    (:greedy-repetition 0 nil :whitespace-char-class))

;; 12<!--: OH SHI~ :-->34 => 1234

(define-parser comment
    "<!--:" (:non-greedy-repetition 0 nil :everything) ":-->")

;; <? data :source some-package::printable-data /?>

(define-parser simple
    "<?" (:regex "\\s*")
         (:register (:regex "\\w+"))
         (:regex "\\s+")
         (:register (:non-greedy-repetition 0 nil :everything))
         (:regex "\\s*")
         "/?>")

;; <? example-view list
;;                 :source some-package::list-data
;;                 :item my-item ?>
;;       clips*
;; <? /example-view ?>

(define-parser complex
    "<?" (:regex "\\s*")
         (:named-register "view-name" (:regex "[\\w\\-]+"))
         (:regex "\\s+")
         (:named-register "view-class" (:regex "\\w+"))
         (:regex "\\s+")
         (:register (:non-greedy-repetition 0 nil :everything)) (:regex "\\s*")
         "?>"
    (:register (:non-greedy-repetition 0 nil :everything))
    "<?" (:regex "\\s*") "/" (:back-reference "view-name") (:regex "\\s*") "?>")

;; * clips:
;;    <: (eql view-data::clip-purpose :item)                           :> <? data :source view-data::my-item ?>
;;    <: (and (eql view-data::clip-purpose :separator)
;;            (= view-data::counter (length some-package::list-data))) :> , and also

(define-parser clip
    "<:" (:regex "\\s+") (:register (:non-greedy-repetition 0 nil :everything)) (:regex "\\s+") ":>"
    (:register (:non-greedy-repetition 0 nil :everything))
    "<:/:>")
