(in-package :cl-user)
(defpackage codex.manifest
  (:use :cl :trivial-types)
  (:documentation "Parsing Codex manifest files."))

(defpackage :codex-manifest-user
  (:use :cl :codex.manifest)
  (:documentation "The package in which Codex manifests are read."))

(in-package :codex.manifest)

(defclass document ()
  ((document-title :reader document-title
                   :initarg :title
                   :type string
                   :documentation "The document's title.")
   (document-sources :reader document-sources
                     :initarg :sources
                     :type (proper-list pathname)
                     :documentation "A list of pathnames to source files to
 build the document from."))
  (:documentation "A Codex document. Project manifests can define multiple
  documents, e.g. a manual, a tutorial, an advanced manual."))

(defclass manifest ()
  ((project-name :reader project-name
                 :initarg :project-name
                 :type string
                 :documentation "The project's name.")
   (markup-format :reader markup-format
                  :initarg :markup-format
                  :type keyword
                  :documentation "The markup format used in docstrings.")
   (packages :reader packages
             :initarg :packages
             :type (proper-list keyword)
             :documentation "A list of packages to document.")
   (documents :reader documents
              :initarg :documents
              :type (proper-list document)
              :documentation "A list of documents."))
  (:documentation "Manifest options."))

(defun read-manifest (pathname)
  "Read a manifest file into an S-expression."
  (uiop:with-safe-io-syntax (:package (find-package :codex-manifest-user))
    (uiop:read-file-form pathname)))

(defun parse-document (document-plist)
  "Parse a manifest's document plist into a document object."
  (apply 'make-instance (cons 'document document-plist)))

(defun parse-manifest (pathname)
  "Parse a manifest from a pathname."
  (let ((plist (read-manifest pathname)))
    (destructuring-bind
        (&key project-name markup-format packages documents)
        plist
      (make-instance 'manifest
                     :project-name project-name
                     :markup-format markup-format
                     :packages packages
                     :documents (loop for doc in documents collecting
                                  (parse-document doc))))))
