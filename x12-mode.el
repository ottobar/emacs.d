;;; x12-mode.el --- major mode for editing X12 messages

;; Copyright (C) 2005 APP Design, Inc.

;; Author: Ivan K, x12 at users.sourceforge.net
;; Maintainer: Ivan K, x12 at users.sourceforge.net
;; Version: 1.0
;; Keywords: X12 evil must die message file EDI major mode
;; Created: 2005-02-08
;; Modified: 2005-02-08
;; X-URL:   http://x12-mode.sourceforge.net

;; This file is NOT part of GNU Emacs.

;; x12-mode is free software; you can redistribute it and/or modify it
;; under the terms of the GNU General Public License as published by the
;; Free Software Foundation; either version 2, or (at your option) any
;; later version.
;;
;; x12-mode is distributed in the hope that it will be useful, but
;; WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;; General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to the
;; Free Software Foundation, Inc., 59 Temple Place - Suite 330,
;; Boston, MA 02111-1307, USA.

;;; Commentary:

;; In 1978, The American National Standards Institute (ANSI) chartered
;; a Accredited Standard Committee (ASC) X12. This committee's
;; objective was "...to develop uniform standards for inter-industry
;; electronic interchange of business transactions". The result was an
;; example of the "design by committee" - a set of EDI (electronic
;; data interchange) standards now known as X12 - more than 300
;; specifications published so far.

;; The next most exciting bureaucratic organization in the world,
;; naturally, could not stay away for long and in 1986, the United
;; Nations Economic Commission for Europe (UN/ECE) adopted UN/EDIFACT
;; (United Nations Electronic Data Interchange for Administration,
;; Commerce and Transport), which is roughly the same thing as ANSI's X12.

;; Both standards (and I use the term rather ironically here) should
;; be long dead by now, but a lot of innocent people - like your humble
;; correspondent, for example, are stuck because X12 has made its way
;; into government regulations and, therefore, is mandated for use in
;; government-regulated industries. Unfortunately, United State's
;; health care is one of those.

;; The http://www.x12.org contains a broader and prouder overview of the
;; whole thing.

;; But it the meantime, we, the working stiffs, need to edit this
;; character goo rather directly and the x12-mode is written to help
;; out. This is what it will do for you:

;; a) Colorize segment names and delimiters.

;; b) Define navigation by fields (called "data elements" in X12
;; argot) - these commands are implemented as `forward-sexp' and
;; `backward-sexp' and bound accordingly.

;; c) Define navigation by segments - implemented as and bound to
;; `forward-sentence' and `backward-sentence', respectively.

;; d) Split an X12 message to be presented as one segment per line,
;; bound by default to ESC-Ctrl/x-b. It's easier to read this way.

;; e) Glue segments together into one big string, bound by default to
;; ESC-Ctrl/x-g. It is usually the way the messages are transmitted.

;; f) Visualize blank space in the message. It's particurlaly useful for
;; the fixed length fields and for spotting un-printable characters that
;; got into the message accidentally.

;; Delimiters for the X12 message can be customized in the mode's own
;; customization group Emacs/Data/x12.

;;; Installation

;; The usual code in your .emacs file will do:
;;     (require 'x12-mode)
;;     (setq auto-mode-alist (cons '("\\.[xX]12\\'" . x12-mode) auto-mode-alist))

;;; To Do

;; 1. Implement more inteligent blank highlighting mode similar to
;; "blank-mode" written by Vinicius Jose Latorre
;; <vinicius@cpqd.com.br>, see http://www.cpqd.com.br/~vinicius/emacs/

;; 2. Implement delimiter auto-detection feature.

;; 3. Implement the mode line interface that will show current
;; segment's name and number and also the current character code.

;;; Known Bugs

;; 1. Customizing blank's face does not have any effect: the mode uses
;; the default one defined in the code.

;;; Thanks

;; Bob Glickstein, who's book "Writing GNU Emacs Extensions" (O'Reilly,
;; 1997, ISBN 1-56592-261-1) has inspired me to undertake this little
;; project while staying at home fighting a flu.

;;; History:
;; February 2005 - first public release, v.1.0

;;; Code:

;; Customization

(require 'derived)

;;; Customizable variables
(defgroup x12 nil
  "X12 file editing."
  :group 'data)

;;;###autoload
(defcustom x12-segment-terminator ?\~
  "*Character that terminates segments in X12 message."
  :type 'character
  :group 'x12)

;;;###autoload
(defcustom x12-data-element-separator ?\*
  "*Character that separates fields (a.k.a. data elements in X12 lingo) in X12 message."
  :type 'character
  :group 'x12)

;;;###autoload
(defcustom x12-subelement-separator ?\:
  "*Character that separates sub-fields (a.k.a. sub-elements in X12 lingo) in X12 message."
  :type 'character
  :group 'x12)

;;;###autoload
(defcustom x12-autodetect-delimiters nil
  "*Sets the autodetection policy for delimiters (not currently implemented). 

If true, the mode will try to figure out delimiter out of ISA segment
using the specified regexp.  Each match group in the regexp must match
exatcly one character in exactly this order: 1 - data element
separator, 2 - sub-element separator, 3 - segment terminator. If nil,
the mode will use the contsant characters defined above."
  :type '(choice (const :tag "No" nil)
		 (regexp :value "ISA\\(.\\).{99}\\1\\(.\\)\\(.\\)"))
  :group 'x12)

;;;###autoload
(defcustom x12-blank-face 'x12-blank-face
  "*Symbol face used to visualize blank space."
  :type 'face
  :group 'x12)

;; Implementation

(defface x12-blank-face
  '((((class mono)) :inverse-video t)
    (t (:underline "red")))
  "Face used to visualize blank space in x12 mode.")

(defmacro limited-save-excursion (&rest subexprs)
  "Like save-excursion, but only restores point.
Optional argument SUBEXPRS is a list of expressions to execute."
  (let ((orig-point-symbol (make-symbol "orig-point")))
    `(let ((,orig-point-symbol (point-marker)))
       (unwind-protect
           (progn ,@subexprs)
         (goto-char ,orig-point-symbol)))))

(defvar x12-mode-map nil
  "Keymap for X12 major mode.")

(if x12-mode-map
    nil
  (setq x12-mode-map (make-keymap))
  (define-key x12-mode-map "\M-\C-xb" 'x12-break)
  (define-key x12-mode-map "\M-\C-xg" 'x12-glue)

  ;; These are inherited from the text mode (?) and need to be disabled
  (define-key x12-mode-map "\M-s"     'undefined) ; center-line
  (define-key x12-mode-map "\M-S"     'undefined) ; center-paragraph
  (define-key x12-mode-map "\M-\t"    'undefined) ; ispell-complete-word
  )

(defun x12-break ()
  "Breaks an X12 message to be one segment per line."
  (interactive)
  (limited-save-excursion
   (goto-char (point-min))
   (while (search-forward-regexp (concat (regexp-quote (char-to-string x12-segment-terminator)) "\\b") nil t)
     (replace-match (concat (char-to-string x12-segment-terminator) "\n") nil t))))

(defun x12-glue ()
  "Puts together an X12 message to be one line."
  (interactive)
  (limited-save-excursion
   (goto-char (point-min))
   (while (search-forward-regexp (concat (regexp-quote (char-to-string x12-segment-terminator)) "\n") nil t)
     (replace-match (char-to-string x12-segment-terminator) nil t))))

;; Since the syntax of the file is dynamic, each font-lock regexp has be
;; a run-time evaluated function.
(defvar x12-font-lock-keywords
  '(
    (x12-search-separators    1 'font-lock-comment-face) ; separators
    (x12-search-segment-names 1 'font-lock-keyword-face) ; segments' names
    ("\\([ \n\t]\\)"          1 'x12-blank-face) ; blank space
    )
  "Expressions to highlight in X12 mode.")

(defun x12-search-segment-names (n)
  "Search for a regexp to highlight segment names.
The regexp should look
like \"\\\\([^*~]+\\\\)\\*\\\\(.+?\\\\)~\" if default delimiters are used.
Argument N specifies the search limit."
   (search-forward-regexp
    (concat
     "\\([^"
     (char-to-string x12-data-element-separator)
     (char-to-string x12-segment-terminator)
     "]+\\)"
     (regexp-quote (char-to-string x12-data-element-separator))
     "\\(.+?\\)"
     (char-to-string x12-segment-terminator)
   )
    n t))

(defun x12-search-separators (n)
  "Search for a regexp to highlight separators.
The regexp should look like \"\\\\([*~:]\\\\)\" if default delimiters are used.
Argument N specifies the seach limit."
   (search-forward-regexp
    (concat
     "\\(["
     (char-to-string x12-data-element-separator)
     (char-to-string x12-segment-terminator)
     (char-to-string x12-subelement-separator)
     "]\\)")
    n t))

(define-derived-mode x12-mode text-mode "X12"
  "Major mode for editing X12 files.
Special commands:
\\{x12-mode-map}"

  (set (make-local-variable 'font-lock-defaults)    '(x12-font-lock-keywords t))
  (set (make-local-variable 'forward-sexp-function) 'x12-field-forward)
  (set (make-local-variable 'sentence-end)          (regexp-quote (char-to-string x12-segment-terminator)))
  )

(defun x12-field-boundary-re ()
  "Make a dynamic regexp for a field boundary."
  (concat
   "$\\|^\\|"
   (regexp-opt (list (char-to-string x12-data-element-separator) (char-to-string x12-segment-terminator)))))

(defun x12-field-forward (&optional n)
  "Move pointer to the begining of the next data field.
Optional argument N specifies now many fields to advance.  Negative value moves backward."
  (interactive "p")
  (cond
   ;; We have to do some extra movement because we want to end up at the beginnig
   ;; of the field, i.e., immediately after the field delimiter we are seaching for.
   ((>  n 0)
    (if (search-backward-regexp (x12-field-boundary-re) (- (point) 1) t)
        (goto-char (+ (point) 1)))
    (search-forward-regexp (x12-field-boundary-re) nil t)
    (x12-field-forward (- n 1)))
   ((<  n 0)
    (if (search-backward-regexp (x12-field-boundary-re) (- (point) 1) t)
        (goto-char (- (point) 1)))
    (search-backward-regexp (x12-field-boundary-re) nil t)
    (x12-field-forward (+ n 1)))
   ;; And if we ended up at the delimiter - as a result of backward search, for example,
   ;; we need to make one step forward
   (t
    (search-forward-regexp (x12-field-boundary-re) (+ (point) 1) t))))

(provide 'x12-mode)

;;; x12-mode.el ends here