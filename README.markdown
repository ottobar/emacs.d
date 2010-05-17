# emacs.d

Personal emacs configuration, adapted from the a number of places, 
including the [technomancy/emacs-starter-kit](http://github.com/technomancy/emacs-starter-kit).

## Installation

### ELPA

From [http://tromey.com/elpa/install.html](http://tromey.com/elpa/install.html):

If you are using Emacs 22, you already have the needed url package, and you can eval this code:

    (let ((buffer (url-retrieve-synchronously
                  "http://tromey.com/elpa/package-install.el")))
    (save-excursion
      (set-buffer buffer)
      (goto-char (point-min))
      (re-search-forward "^$" nil 'move)
      (eval-region (point) (point-max))
      (kill-buffer (current-buffer))))

You can type the this in the `*scratch*` buffer, and then type `C-j` after it to evaluate it.

Currently, I am using these ELPA packages and their dependencies:
(M-x package-list-packages)

- clojure-mode
- clojure-test-mode
- css-mode
- gist
- haml-mode
- idle-highlight
- inf-ruby
- js2-mode
- magit
- rinari
- rspec-mode
- ruby-mode
- ruby-test-mode
- sass-mode
- yaml-mode
- yasnippet-bundle

Other functionality is either in a git submodule, or part of this repository.

## License

    Copyright (c) 2009-2010 Don Barlow

    Permission is hereby granted, free of charge, to any person obtaining
    a copy of this software and associated documentation files (the
    "Software"), to deal in the Software without restriction, including
    without limitation the rights to use, copy, modify, merge, publish,
    distribute, sublicense, and/or sell copies of the Software, and to
    permit persons to whom the Software is furnished to do so, subject to
    the following conditions:

    The above copyright notice and this permission notice shall be
    included in all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
    EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
    MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
    NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
    LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
    OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
    WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
