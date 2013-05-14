;; (c) Дмитрий Пинский <demetrius@neverblued.info>
;; Допускаю использование и распространение согласно
;; LLGPL -> http://opensource.franz.com/preamble.html

(defpackage #:cleepz
  (:use #:cl #:bj #:ppcre #:alexandria #:iterate)
  (:export
                                        ; api
   #:with-view-datum #:with-view-data
   #:parse-view-string #:parse-view-file
   #:view-home #:view/
                                        ; view
   #:view
   #:simple-view #:print-view #:scope-view
   #:include-view #:data-view #:format-view
   #:complex-view #:complex-data-view
   #:list-view #:switch-view))
