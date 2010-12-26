(in-package #:cleepz)

(defclass menu-template (list-template)
  ())

(defmethod fetch-item-clip ((menu-template menu-template) &key is-current?)
  (fetch-clip menu-template :item (if is-current?
                                      (list :mode "current")
                                      nil)))

(defmethod templates-for-items ((menu-template menu-template) menu-data)
  (mapcar #'clip-template
          (loop for menu-item in menu-data
             collect (fetch-item-clip menu-template
                                      :is-current? (and (boundp 'hunchentoot::*request*)
                                                        (string= (hunchentoot::url-decode
                                                                  (hunchentoot::request-uri hunchentoot::*request*))
                                                                 (getf menu-item :url)))))))
