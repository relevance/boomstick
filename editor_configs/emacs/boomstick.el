(add-hook 'prog-mode-hook 'rainbow-delimiters-mode)                        ; Enable rainbow delimiters when programming

(global-linum-mode t)                                                      ; Always show line numbers on left
(show-paren-mode t)                                                        ; show-paren-mode on
(hlinum-activate)                                                          ; Activate highlighting of current line in line numbers
(ido-mode)                                                                 ; Convenient buffer-switching

(line-number-mode 1)                                                       ; Mode line shows line numbers
(column-number-mode 1)                                                     ; Mode line shows column numbers

(setq-default tab-width 2)                                                 ; Tab width of 2
(fset 'yes-or-no-p 'y-or-n-p)                                              ; Emacs prompts should accept "y" or "n" instead of the full word

(setq visible-bell nil)                                                    ; No more Mr. Visual Bell Guy.


;; Clojure
(setq auto-mode-alist (cons '("\\.edn$" . clojure-mode) auto-mode-alist))  ; *.edn are Clojure files
(setq auto-mode-alist (cons '("\\.cljs$" . clojure-mode) auto-mode-alist)) ; *.cljs are Clojure files


;; nREPL customizations
(setq cider-hide-special-buffers t)                                        ; Don't show buffers like connection or server
(setq cider-popup-on-error nil)                                            ; Don't popup new buffer for errors (show in nrepl buffer)
(setq cider-popup-stacktraces-in-repl t)                                   ; Display stacktrace inline

(add-hook 'cider-interaction-mode-hook 'cider-turn-on-eldoc-mode)          ; Enable eldoc - shows fn argument list in echo area
(add-hook 'cider-mode-hook 'paredit-mode)                                  ; Use paredit in *cider* buffer

(add-to-list 'same-window-buffer-names "*cider*")                          ; Make C-c C-z switch to *cider*


;; Ido-mode customizations
(setq ido-decorations                                                      ; Make ido-mode display vertically
      (quote
       ("\n-> "           ; Opening bracket around prospect list
        ""                ; Closing bracket around prospect list
        "\n   "           ; separator between prospects
        "\n   ..."        ; appears at end of truncated list of prospects
        "["               ; opening bracket around common match string
        "]"               ; closing bracket around common match string
        " [No match]"     ; displayed when there is no match
        " [Matched]"      ; displayed if there is a single match
        " [Not readable]" ; current diretory is not readable
        " [Too big]"      ; directory too big
        " [Confirm]")))   ; confirm creation of new file or buffer

(add-hook 'ido-setup-hook                                                  ; Navigate ido-mode vertically
          (lambda ()
            (define-key ido-completion-map [down] 'ido-next-match)
            (define-key ido-completion-map [up] 'ido-prev-match)
            (define-key ido-completion-map (kbd "C-n") 'ido-next-match)
            (define-key ido-completion-map (kbd "C-p") 'ido-prev-match)))


;; Custom faces.
(set-face-attribute 'font-lock-warning-face nil :inherit nil :foreground "red" :background nil)
(set-face-attribute 'linum-highlight-face nil :background "color-238" :foreground "white")
(set-face-attribute 'show-paren-match-face nil :inherit 'default :foreground "red" :background "black")


;; Move auto-save and backup files to a central location.
(defvar user-temporary-file-directory
  (setq temporary-file-directory 
        (concat user-emacs-directory ".autosaves/")))
(make-directory user-temporary-file-directory t)
(setq backup-by-copying t)
(setq backup-directory-alist
      `(("." . ,user-temporary-file-directory)
                (,tramp-file-name-regexp nil)))
(setq auto-save-list-file-prefix
      (concat user-temporary-file-directory ".auto-saves"))
(setq auto-save-file-name-transforms
      `((".*" ,user-temporary-file-directory t)))

;; Allow pasting selection outside of Emacs
(setq x-select-enable-clipboard t)

;; Auto refresh buffers
(global-auto-revert-mode 1)

;; UTF-8 please
(setq locale-coding-system 'utf-8) ; pretty
(set-terminal-coding-system 'utf-8) ; pretty
(set-keyboard-coding-system 'utf-8) ; pretty
(set-selection-coding-system 'utf-8) ; please
(prefer-coding-system 'utf-8) ; with sugar on top

;; Show active region
(transient-mark-mode 1)
(make-variable-buffer-local 'transient-mark-mode)
(put 'transient-mark-mode 'permanent-local t)
(setq-default transient-mark-mode t)

;; Save a list of recent files visited. (open recent file with C-x f)
(recentf-mode 1)
(setq recentf-max-saved-items 100) ;; just 20 is too recent

;; Save minibuffer history
(savehist-mode 1)
(setq history-length 1000)

;; Undo/redo window configuration with C-c <left>/<right>
(winner-mode 1)

;; Never insert tabs
(set-default 'indent-tabs-mode nil)

;; Show me empty lines after buffer end
(set-default 'indicate-empty-lines t)

;; Easily navigate sillycased words
(global-subword-mode 1)

;; Don't break lines for me, please
(setq-default truncate-lines t)

;; Add parts of each file's directory to the buffer name if not unique
(require 'uniquify)
(setq uniquify-buffer-name-style 'forward)

(require 'smex)
(smex-initialize)
(global-set-key (kbd "M-x") 'smex)
(global-set-key (kbd "M-X") 'smex-major-mode-commands)
;; This is your old M-x.
(global-set-key (kbd "C-c M-x") 'execute-extended-command)

