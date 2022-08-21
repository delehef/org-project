;;; org-project-test.el --- org-project test suite -*- lexical-binding: t; -*-

;; Copyright (C) 2022 Franklin Delehelle

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

;; The unit test suite of org-project

;;; Code:

(require 'ert)

(require 'org-project)
(setq org-adapt-indentation 1)

(defun equal-as-sets (seq1 seq2)
  (and
   (-all? (lambda (element) (member element seq2)) seq1)
   (-all? (lambda (element) (member element seq1)) seq2)))


(provide 'org-project-test)
;;; org-project-test.el ends here
