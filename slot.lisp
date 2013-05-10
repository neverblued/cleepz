;; (c) Дмитрий Пинский <demetrius@neverblued.info>
;; Допускаю использование и распространение согласно
;; LLGPL -> http://opensource.franz.com/preamble.html

(in-package #:cleepz)

(defmacro define-patcher (name slot (&rest parts) &body body)
  (unless (find 'type parts)
    (error "TYPE part is required to define a ~a slot." slot))
  (let ((make-view* (cleepz-symbol "make-" slot "-view"))
        (view-parts* (mapcar (lambda (part)
                               (list (cleepz-symbol "parse-view-" part) part))
                             parts)))
    `(labels ((,name (match ,@parts &rest registers)
                (declare (ignore match registers))
                (handler-case (progn
                                (unless (fboundp ',make-view*)
                                  (error "Missing slot patcher function ~a." #',make-view*))
                                (let ((view (,make-view* ,@view-parts*)))
                                  (unless (typep view 'view)
                                    (error 'type-error :datum view :expected-type 'view))
                                  (build-view view)))
                  (condition (condition)
                    (build-view (make-error-view condition))))))
       ,@body)))

(defparameter *slot-processors* nil)

(defmacro define-slot (slot &rest parts)
  (let* ((define-markup-processor* (gensym))
         (processor-name* (apply #'cleepz-symbol (if parts
                                                     `("patch-" ,slot "-view")
                                                     `("cut-" ,slot))))
         (slot-regex* (cleepz-symbol "*" slot "-regex*")))
    `(macrolet ((,define-markup-processor* (&body body)
                  `(defun ,',processor-name* (markup) (values ,@body))))
       ,(if parts
            (let ((patcher* (gensym "patcher")))
              `(define-patcher ,patcher* ,slot (,@parts)
                 (,define-markup-processor* (regex-replace-all ,slot-regex* markup #',patcher* :simple-calls t))))
            `(,define-markup-processor* (regex-cut ,slot-regex* markup)))
       (setf *slot-processors*
             (nconc *slot-processors*
                    (list #',processor-name*))))))

;; parse order

(define-slot complex name type args clips)

(define-slot simple type args)

;;(define-slot simple) ; @TODO refactor

(define-slot reduce)

(define-slot comment)
