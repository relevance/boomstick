(require 'package)

(add-to-list 'package-archives
             '("melpa" . "http://melpa.milkbox.net/packages/") t)
(package-initialize)

(when (not package-archive-contents)
  (package-refresh-contents))

(defvar my-packages '(clojure-mode
                      cider
                      rainbow-delimiters
                      hlinum
                      smex)
  "A list of packages to ensure are installed at launch.")

;; Automatically install any missing packages
(dolist (p my-packages)
  (when (not (package-installed-p p))
    (package-install p)))

;; Hide surprising compilation split window
(let ((win (get-buffer-window "*Compile-Log*")))
  (when win (delete-window win)))

(load (concat user-emacs-directory "boomstick.el"))
