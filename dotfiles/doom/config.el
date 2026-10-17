;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!

;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
;; (setq user-full-name "John Doe"
;;       user-mail-address "john@doe.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom:
;;
;; - `doom-font' -- the primary font to use
;; - `doom-variable-pitch-font' -- a non-monospace font (where applicable)
;; - `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;; - `doom-symbol-font' -- for symbols
;; - `doom-serif-font' -- for the `fixed-pitch-serif' face
;;
;; See 'C-h v doom-font' for documentation and more examples of what they
;; accept. For example:
;;
;;(setq doom-font (font-spec :family "Fira Code" :size 12 :weight 'semi-light)
;;      doom-variable-pitch-font (font-spec :family "Fira Sans" :size 13))
;;
;; If you or Emacs can't find your font, use 'M-x describe-font' to look them
;; up, `M-x eval-region' to execute elisp code, and 'M-x doom/reload-font' to
;; refresh your font settings. If Emacs still can't find your font, it likely
;; wasn't installed correctly. Font issues are rarely Doom issues!

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'catppuccin)
(setq catppuccin-flavor 'latte) ;; or 'latte, 'macchiato, or 'mocha

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")

;; Whenever you reconfigure a package, make sure to wrap your config in an
;; `after!' block, otherwise Doom's defaults may override your settings. E.g.
;;
;;   (after! PACKAGE
;;     (setq x y))
;;
;; The exceptions to this rule:
;;
;;   - Setting file/directory variables (like `org-directory')
;;   - Setting variables which explicitly tell you to set them before their
;;     package is loaded (see 'C-h v VARIABLE' to look up their documentation).
;;   - Setting doom variables (which start with 'doom-' or '+').
;;
;; Here are some additional functions/macros that will help you configure Doom.
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;; Alternatively, use `C-h o' to look up a symbol (functions, variables, faces,
;; etc).
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.

;; accept completion from copilot and fallback to company
;;(use-package! copilot
;;  :hook (prog-mode . copilot-mode)
;;  :bind (:map copilot-completion-map
;;              ("<tab>" . 'copilot-accept-completion)
;;              ("TAB" . 'copilot-accept-completion)
;;              ("C-TAB" . 'copilot-accept-completion-by-word)
;;              ("C-<tab>" . 'copilot-accept-completion-by-word)))

;; org-bullets
(use-package! org-bullets
  :hook (org-mode . org-bullets-mode))

(after! treemacs
  (setq treemacs-is-never-other-window nil
        treemacs-show-hidden-files t)) ;;

(use-package org-roam
  :ensure t
  :custom
  (org-roam-directory (file-truename "~/Documents/business/org"))
  (org-roam-completion-everywhere t)
  :bind (("C-c n l" . org-roam-buffer-toggle)
         ("C-c n f" . org-roam-node-find)
         ("C-c n g" . org-roam-graph)
         ("C-c n i" . org-roam-node-insert)
         ("C-c n c" . org-roam-capture)
         ;; Dailies
         ("C-c n j" . org-roam-dailies-capture-today)
         ("C-M-i" . completion-at-point))
  :config
  ;; If you're using a vertical completion framework, you might want a more informative completion interface
  (setq org-roam-node-display-template (concat "${title:*} " (propertize "${tags:10}" 'face 'org-tag)))
  (org-roam-db-autosync-mode)
  ;; If using org-roam-protocol
  (require 'org-roam-protocol)

  ;; Configure daily capture templates
  (setq org-roam-dailies-capture-templates
        '(("d" "default" entry
           "* %<%H:%M> - %?\n"
           :if-new (file+head "%<%Y-%m-%d>.org"
                              "#+title: %<%Y-%m-%d>\n* Tasks\n - [ ] [[id:12b7ff58-82ee-4a1e-882a-8659945a1e83][Check your daily habits]]\n\n* Planning\n\n* Notes\n"))))

  ;; Define capture templates for creating and appending notes
  (setq org-roam-capture-templates
      '(("d" "default" entry
         "*"
         :target (file+head "%<%Y%m%d%H%M%S>-${slug}.org"
                            "#+title: ${title}\n#+date: %<%a %b %d %H:%M:%S %Y>\n#+FILETAGS: %^{Tags}\n")
         :unnarrowed t)
        ("n" "Note" entry
         "* %<%H:%M> - %?${title}"
         :target (file+head+olp "daily/%<%Y-%m-%d>.org"
                                "#+title: %<%Y-%m-%d>" ("Notes"))
         :unnarrowed t)
        ("j" "Job Application" entry
         "** TODO ${title}\n  :PROPERTIES:\n  :Company: %^{Company}\n  :Application_Date: %T\n  :Source: %^{Source}\n  :Location: %^{Location}\n  :Link: %^{Link}\n :END:\nDEADLINE: %^{Deadline}t\n*** Job Description\n*** Motivation Letter\n#+BEGIN_SRC latex\n#+END_SRC"
         :target (file+olp "20240911141520-job_tracking.org" ("Job Applications"))
         :unnarrowed t)))

  ;; Automatically return to previous buffer after org-capture
  (defun my/org-capture-return-to-original ()
    "Return to the original buffer after org-capture is finalized."
    (when (not (minibufferp))
      (previous-buffer)))

  (add-hook 'org-capture-after-finalize-hook 'my/org-capture-return-to-original))

;; Configure LedgerMode
(use-package! ledger-mode
  :defer t
  :mode ("\\.ledger\\'" . ledger-mode)
  :config
  (setq ledger-clear-whole-transactions 1))

;; Enable Org Babel languages
(after! org
  (org-babel-do-load-languages
   'org-babel-load-languages
   '((emacs-lisp . t)
     (ledger . t)
     (python . t)
     (shell . t))))

;; Configure Org Babel for Ledger
(use-package! ob-ledger
  :after org
  :config
  (setq org-babel-ledger-command "ledger"))

(use-package! org-download
  :after org
  :config
  (setq org-download-image-dir "~/Documents/business/org/images") ;; Directory to save images
  (setq org-download-screenshot-method "pngpaste %s")
  (add-hook 'dired-mode-hook 'org-download-enable)
  (map! :map org-mode-map
        :leader
        :prefix "n"
        :desc "Paste image" "p" #'org-download-clipboard))

;; Org-habit
(use-package! org-habit
  :after org
  :config
  (setq org-habit-following-days 7
        org-habit-preceding-days 35
        org-habit-show-habits t)  )

;; Org Agenda Configuration to remove the file name in the agenda view
(after! org
  (setq org-agenda-prefix-format
        '((agenda . " %i %?-12t% s")
          (todo . " %i %l")
          (tags . " %i ")
          (search . " %i "))))
;; Qt/C++ support additions
(use-package! cmake-mode
  :defer t
  :mode ("CMakeLists\\.txt\\'" "\\.cmake\\'"))

(after! company
  (setq company-backends '((company-capf company-files))))

(after! ccls
  (setq ccls-executable "/usr/bin/ccls")
  (setq ccls-sem-highlight-method 'font-lock)
  (set-lsp-priority! 'ccls 0))

(after! org
  (load-library "find-lisp")
  (setq org-agenda-files
        (find-lisp-find-files (expand-file-name "~/Documents/business/org/")
                              "\\.org$")))

;; Ignore complètement la touche "sans symbole" que XKB envoie
(global-set-key (kbd "<void-symbol>") #'ignore)
