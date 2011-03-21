;; (c) Demetrius Conde <condemetrius@gmail.com>
;; Допускаю использование и распространение согласно
;; LLGPL --> http://opensource.franz.com/preamble.html

(in-package #:cleepz)

(defun cleepz-symbol (&rest parts)
  (intern (string-upcase (apply #'join parts)) :cleepz))

(defun parse-view-name (name-template)
  name-template)

(defun parse-view-type (type-template)
  (cleepz-symbol type-template "-view"))

(macrolet ((read-with-data (form)
             `(let ((*package* (find-package :view-data)))
                (read-from-string ,form))))

  (defun parse-view-args (args-template)
    (read-with-data (join "(" args-template ")")))

  (defun parse-view-clause (clause-template)
    (read-with-data clause-template)))

(defun parse-view-clips (clips-template)
  (let ((enclosed-views (make-hash-table :test #'equal)))
    (labels ((make-id ()
               (symbol-name (gensym "view")))
             (make-patch (view-id)
               (join "<#~" view-id "~#>"))
             (remembered-patch (view-source &rest registers)
               (declare (ignore registers))
               (let ((view-patch (make-patch (make-id))))
                 (setf (gethash view-patch enclosed-views) view-source)
                 view-patch))
             (cut-enclosed-views (template)
               (regex-replace-all *complex-regex* template #'remembered-patch :simple-calls t))
             (put-views-back (patched-clip)
               (maphash (lambda (view-patch view-source)
                          (setf (clip-markup patched-clip)
                                (regex-replace (create-scanner view-patch :single-line-mode t)
                                               (clip-markup patched-clip)
                                               view-source
                                               :simple-calls nil)))
                        enclosed-views)
               patched-clip))
      (let* ((pure-clips-template (cut-enclosed-views clips-template))
             (clips (hamster (do-register-groups (clause markup)
                                 (*clip-regex* pure-clips-template)
                               (pick-up (make-view-clip (parse-view-clause clause) markup))))))
        (mapcar #'put-views-back clips)))))
