;; Package repository (MELPA has most community packages)
(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)

;; Emacs started from the Dock doesn't get your shell's PATH, so it can't
;; find Homebrew programs (pandoc, sbcl, ...). Add Homebrew's bin folder.
(let ((brew-bin "/opt/homebrew/bin"))
  (unless (member brew-bin exec-path)
    (add-to-list 'exec-path brew-bin)
    (setenv "PATH" (concat brew-bin ":" (getenv "PATH")))))

;; SLIME, installed via Quicklisp: (ql:quickload "quicklisp-slime-helper").
;; Skipped if Quicklisp isn't set up yet, so a fresh machine still starts.
(let ((slime-helper (expand-file-name "~/.quicklisp/slime-helper.el")))
  (when (file-exists-p slime-helper)
    (load slime-helper)))
(setq inferior-lisp-program "sbcl")

;; Fill the screen (a normal window, not macOS full-screen mode).
(add-to-list 'default-frame-alist '(fullscreen . maximized))

;; Hide the tool bar (the row of icons at the top of the window).
(tool-bar-mode -1)

;; Themes: install the packages here...
(add-to-list 'custom-theme-load-path "~/.emacs.d/themes") ; local themes (Dracula Pro)
(use-package base16-theme :ensure t :defer t) ; ~350 base16 schemes (base16-valua, base16-ocean, ...)
(use-package darcula-theme :ensure t :defer t) ; https://emacsthemes.com/themes/darcula
(use-package jetbrains-darcula-theme :ensure t :defer t) ; closer port of JetBrains' Darcula
(use-package doom-themes :ensure t :defer t) ; ~77 Doom Emacs themes (doom-one, doom-dracula, ...)
(use-package solarized-theme :ensure t :defer t) ; solarized + selenized variants (dark/black/light/white)

;; ...and keep exactly one of these active; comment out the others.
;; (load-theme 'dracula-pro-blade t)
;; (load-theme 'base16-valua t)
;; (load-theme 'darcula t)
;; (load-theme 'jetbrains-darcula t)
;; (load-theme 'doom-one t)
;; (load-theme 'doom-material t)
;; (load-theme 'doom-material-dark t)
;; (load-theme 'doom-oceanic-next t)
;; (load-theme 'doom-vibrant t)
(load-theme 'solarized-selenized-dark t)

;; File tree on the left
(defun my/treemacs-on-startup ()
  "Open the tree when Emacs starts, keeping the cursor in the main window."
  (when (display-graphic-p)         ; skip background/terminal Emacs (no window to show it in)
    (treemacs-start-on-boot)))

(use-package treemacs
  :ensure t                         ; install automatically on first start
  :hook (emacs-startup . my/treemacs-on-startup)
  :bind (("C-c t" . treemacs)       ; toggle the tree
         ("C-c T" . treemacs-select-window))
  :config
  (treemacs-follow-mode t)          ; highlight the file you're editing
  (treemacs-project-follow-mode t)) ; switch the tree to the current project

;; Window navigation
;; Ctrl+Shift+arrow moves to the window in that direction
;; (leaves plain Shift+arrow for selecting text).
(windmove-default-keybindings '(control shift))

(use-package ace-window
  :ensure t
  :bind ("M-o" . ace-window))       ; number the windows, type one to jump there

;; Terminal (eat: a full terminal emulator written in Emacs Lisp)

;; The terminal gets its own colour scheme, separate from the main theme. Themes are global, so instead:
;;  - background/text: remapped buffer-locally in eat buffers;
;;  - the 16 ANSI colours (used by ls, git, the prompt, ...): eat reads them
;;    from faces named per terminal, so each new terminal is pointed at our
;;    own faces (my/eat-color-0..15) instead of the theme's.
;; Pick a palette in `my/eat-palette'; applies to terminals opened afterwards.
;; :colors are 0-7 black red green yellow blue magenta cyan white, then 8-15
;; the bright versions.

(defvar my/eat-palette-homebrew
  ;; macOS Terminal's "Homebrew" profile: background/text read from Terminal's
  ;; preferences; it doesn't set ANSI colours, so these are Terminal.app's
  ;; default palette.
  '(:background "#000000" :foreground "#28fe14"
    :colors ["#000000" "#c23621" "#25bc24" "#adad27" "#492ee1" "#d338d3" "#33bbc8" "#cbcccd"
             "#818383" "#fc391f" "#31e722" "#eaec23" "#5833ff" "#f935f8" "#14f0f0" "#e9ebeb"]))

(defvar my/eat-palette-tokyo-night
  '(:background "#1a1b26" :foreground "#c0caf5"
    :colors ["#15161e" "#f7768e" "#9ece6a" "#e0af68" "#7aa2f7" "#bb9af7" "#7dcfff" "#a9b1d6"
             "#414868" "#ff899d" "#9fe044" "#faba4a" "#8db0ff" "#c7a9ff" "#a4daff" "#c0caf5"]))

(defvar my/eat-palette my/eat-palette-homebrew
  "Colour scheme for eat terminal buffers.")

(defun my/eat-apply-palette ()
  "Give the current eat buffer the background/text from `my/eat-palette'."
  (let ((bg (plist-get my/eat-palette :background))
        (fg (plist-get my/eat-palette :foreground)))
    (face-remap-add-relative 'default :background bg :foreground fg)
    (face-remap-add-relative 'fringe :background bg)))

(defun my/eat-use-palette-colors (&rest _)
  "Point the current eat terminal's 16 ANSI colours at `my/eat-palette'."
  (let ((colors (plist-get my/eat-palette :colors)))
    (dotimes (i 16)
      (let ((face (intern (format "my/eat-color-%d" i)))
            (c (aref colors i)))
        (make-face face)
        ;; Each colour is used for both text and cell backgrounds.
        (set-face-attribute face nil :foreground c :background c)
        ;; (Not SETF: eat isn't loaded when this is defined, so its setter
        ;; wouldn't be known yet.)
        (eat-term-set-parameter eat-terminal (intern (format "color-%d-face" i)) face)))))

(defun my/eat-toggle ()
  "Show or hide the terminal panel at the bottom of the window."
  (interactive)
  (let ((window (get-buffer-window "*eat*")))
    (cond (window (delete-window window))
          ((get-buffer "*eat*") (pop-to-buffer "*eat*"))
          (t (eat)))))

(use-package eat
  :ensure t
  :bind ("C-c e" . my/eat-toggle)   ; also works from inside the terminal
  :hook ((eat-mode . my/eat-apply-palette)
         (eat-exec . my/eat-use-palette-colors))
  :init
  ;; Open the terminal as a panel along the bottom, 30% of the height.
  (add-to-list 'display-buffer-alist
               '("\\*eat\\*"
                 (display-buffer-in-side-window)
                 (side . bottom)
                 (window-height . 0.3)))
  :config
  ;; macOS fix: eat's bundled terminfo is compiled in a newer format than
  ;; macOS's ncurses can read, so zsh couldn't find the terminal's key
  ;; definitions (broken Backspace). Use a copy compiled with macOS's own
  ;; `tic' instead. It's built automatically when missing (e.g. on a new
  ;; machine). After updating eat, delete ~/.emacs.d/eat-terminfo to rebuild.
  (let ((dir (expand-file-name "~/.emacs.d/eat-terminfo"))
        (source (expand-file-name "eat.ti" (file-name-directory (locate-library "eat")))))
    (when (and (eq system-type 'darwin)
               (not (file-directory-p dir))
               (file-exists-p source))
      (call-process "/usr/bin/tic" nil nil nil "-x" "-o" dir source))
    (setq eat-term-terminfo-directory dir))
  ;; Let M-o (ace-window) reach Emacs instead of the terminal.
  ;; Ctrl+Shift+arrows (windmove) already do by default.
  (add-to-list 'eat-semi-char-non-bound-keys [?\e ?o])
  (eat-update-semi-char-mode-map)
  ;; Cmd+V pastes into the shell (by default it pastes into the buffer only).
  (define-key eat-semi-char-mode-map [?\s-v] #'eat-yank))

;; Markdown: syntax highlighting + preview (rendered with pandoc).
;;   C-c C-c l  live preview beside the source (updates on save)
;;   C-c C-c p  open the rendered file in your web browser
(use-package markdown-mode
  :ensure t
  :mode ("\\.md\\'" . gfm-mode)     ; GitHub-flavoured: tables, ``` code blocks
  :config
  (setq markdown-command
        "pandoc --from gfm --to html5 --standalone --metadata pagetitle=Preview"))

;; Colour matching parens/brackets by nesting depth.
(use-package rainbow-delimiters
  :ensure t
  :hook ((prog-mode . rainbow-delimiters-mode)          ; all code: Lisp, elisp, ...
         (slime-repl-mode . rainbow-delimiters-mode))   ; and the SLIME REPL
  :config
  ;; Our own colours instead of the theme's: themes tend to reuse their syntax
  ;; colours, so brackets blended in with nearby code. Four well-separated,
  ;; bold colours that solarized-selenized-dark doesn't use for code, ordered
  ;; so neighbouring depths contrast: orange, mint, raspberry, white, repeat.
  ;; CUSTOM-SET-FACES overrides any theme, so this survives theme switches.
  (setq rainbow-delimiters-max-face-count 4)
  (custom-set-faces
   '(rainbow-delimiters-depth-1-face ((t (:foreground "#ed8649" :weight bold)))) ; orange
   '(rainbow-delimiters-depth-2-face ((t (:foreground "#5af78e" :weight bold)))) ; mint green
   '(rainbow-delimiters-depth-3-face ((t (:foreground "#ff4f9a" :weight bold)))) ; raspberry
   '(rainbow-delimiters-depth-4-face ((t (:foreground "#f2f2f2" :weight bold)))) ; near-white
   ;; A bracket with no partner, or closing the wrong kind: red background.
   '(rainbow-delimiters-unmatched-face ((t (:foreground "white" :background "#d2212d" :weight bold))))
   '(rainbow-delimiters-mismatched-face ((t (:foreground "white" :background "#d2212d" :weight bold))))))
