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

;; <? data :source printable-data /?>

(define-parser simple
    "<?" (:regex "\\s*")
         (:register (:regex "\\w+"))
         (:regex "\\s+")
         (:register (:non-greedy-repetition 0 nil :everything))
         (:regex "\\s*")
         "/?>")

;; <? digits list
;;           :source (list 1 2 3 4 5)
;;           :item digit
;;           ?>
;;   clips*
;; <? /digits ?>

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

;; *clips:
;;    <: (eql clip-purpose :item)               :><? data :source digit /?><:/:>
;;    <: (and (eql clip-purpose :separator)
;;            (= counter (1- (length source)))) :> and also <:/:>
;;    <: (eql clip-purpose :separator)          :>, <:/:>

(define-parser clip
    "<:" (:regex "\\s+") (:register (:non-greedy-repetition 0 nil :everything)) (:regex "\\s+") ":>"
    (:register (:non-greedy-repetition 0 nil :everything))
    "<:/:>")
