;;; org-project.el --- Repository todo management for org-mode -*- lexical-binding: t; -*-

;; Copyright (C) 2022 Franklin Delehelle

;; Author: Franklin Delehelle <github@odena.eu>
;; Keywords: org-mode project todo tools
;; URL: https://github.com/delehef/org-project
;; Version: 1.0.0
;; Package-Requires: ((emacs "27.1"))

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; This package aims to provide an easy interface to creating per
;; project org-mode TODO headings.

;;; Code:

(require 'org)
(require 'project)

(defgroup org-project ()
  "Customizations for org-project."
  :group 'org
  :prefix "org-project-")

(defcustom org-project-projects-file "~/projects.org"
  "The path to the file in which project TODOs will be stored."
  :type '(string)
  :group 'org-project)

(defcustom org-project-per-project-file "TODO.org"
  "A project-specific file where TODOs will be stored.

This will only be used if `org-project-todos-per-project' is set."
  :type '(choice string function)
  :group 'org-project)

(defcustom org-project-todos-per-project nil
  "If true, TODOs are stored in a per-project org file.

This file will be saved under the name specified in
`org-project-per-project-file' at the root of the project."
  :type '(bool)
  :group 'org-project)

(defcustom org-project-capture-template "* TODO %?\n"
  "The default capture template to use for org-project TODOs."
  :type '(string)
  :group 'org-project)

(defcustom org-project-quick-capture-template "* TODO TEXT\n"
  "The default capture template to use for org-project quick TODOs.

TEXT will be replaced with the string prompted for."
  :type '(string)
  :group 'org-project)

(defcustom org-project-link-heading t
  "Whether to make project headings links to their projects."
  :type '(boolean)
  :group 'org-project)

(defcustom org-project-allow-tramp-projects nil
  "Whether to use tramp/sudo requiring projects."
  :type '(boolean)
  :group 'org-project)


(defun org-project--io-action-permitted (filepath)
  "Return whether org-project can work on FILEPATH."
  (or org-project-allow-tramp-projects
      (eq nil (find-file-name-handler filepath 'file-truename))))

(defun org-project--project-from-file (filepath)
  "Return the project root of a file given its FILEPATH."
  (when (org-project--io-action-permitted filepath)
    (project-current nil)))

(defun org-project--name-from-project (project-root)
  "Return the display name of a project identified by PROJECT-ROOT."
  (file-name-nondirectory (directory-file-name project-root)))

(defun org-project--get-capture-file (projectpath)
  "Return the file PROJECTPATH TODOs depending on org-project settings."
  (if org-project-todos-per-project
      (concat projectpath org-project-per-project-file)
    org-project-projects-file))

(defun org-project--linkize-heading (heading projectpath)
  "Create an org link to PROJECTPATH with name HEADING."
  (org-link-make-string (format "elisp:(project-switch-project \"%s\")" projectpath) heading))

(defun org-project--build-heading (projectpath)
  "Create an org heading for PROJECTPATH."
  (let* ((raw-heading (org-project--name-from-project projectpath))
         (heading-linkized (if org-project-link-heading
                               (org-project--linkize-heading raw-heading projectpath)
                             raw-heading))
         (heading-final heading-linkized))
    heading-final))

(defun org-project--current-project ()
  "Return the root of the current project if any, errors otherwise."
  (let ((project (project-current)))
    (if project
        (cdr project)
      (error "%s is not in a project" (buffer-name)))))

(defun org-project--completing-read (prompt choices &optional action)
  "Prompt for a string using `completing-read', featuring CHOICES.

The PROMPT is prefixed by the current project name. If ACTION is specified, it
is called with the entered value."
  (let* ((prompt (format "[%s] %s"
                         (org-project--name-from-project (org-project--current-project))
                         prompt))
         (res (completing-read prompt choices)))
    (if action
        (funcall action res)
      res)))

(defun org-project--capture (projectpath &optional content)
  "Capture a TODO for the project located at PROJECTPATH.
If CONTENT is provided, automatically use it as the new TODO."
  (let* ((org-capture-templates `(("d" "default" entry
                                   (file+headline
                                    ,(org-project--get-capture-file projectpath)
                                    ,(org-project--build-heading projectpath))
                                   ,(if content (string-replace
                                         "TEXT" content org-project-quick-capture-template)
                                      org-project-capture-template)
                                   :immediate-finish ,(not (null content))))))
    (org-capture nil "d")))

;;;###autoload
(cl-defun org-project-quick-capture ()
  "Prompt for and directly record a TODO for the current project."
  (interactive)
  (org-project--capture
   (org-project--current-project)
   (org-project--completing-read "TODO: " nil)))

;;;###autoload
(defun org-project-capture ()
  "Use `org-capture' to record a TODO for the current project."
  (interactive)
  (org-project--capture (org-project--current-project)))

(provide 'org-project)
;;; org-project.el ends here
