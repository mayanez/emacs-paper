
(require 'pdf-tools)

(defgroup paper nil
  "Interact with Mendeley/Zotero through emacs."
  :group 'tools
  :group 'convenience)

(defcustom paper-command "python /home/miguel/repos/emacs-paper/paper.py"
  "The Paper command."
  :group 'paper
  :type 'string)

(defun paper-search (query)
  "Search for a paper using some keyword"
  (interactive "sKeyword: ")
  (message (format "Searching for: %s" query))
  (eshell-command
   (format (concat paper-command " search %s")
   (shell-quote-argument query))))

(defconst pdf-tools-org-non-exportable-types
  (list 'link)
  "Types of annotation that are not to be exported.")
(defconst pdf-tools-org-exportable-properties
  (list 'page 'edges 'id 'flags 'color 'modified 'label 'subject 'opacity 'created 'markup-edges 'icon))

(defcustom pdf-tools-org-export-confirm-overwrite t
  "If nil, overwrite org file when exporting without asking for confirmation."
  :group 'pdf-tools-org
  :type 'boolean)

(defun pdf-tools-org-edges-to-region (edges)
  "Attempt to get 4-entry region \(LEFT TOP RIGHT BOTTOM\) from several EDGES.
We need this to import annotations and to get marked-up text, because
annotations are referenced by its edges, but functions for these tasks
need region."
  (let ((left0 (nth 0 (car edges)))
        (top0 (nth 1 (car edges)))
        (bottom0 (nth 3 (car edges)))
        (top1 (nth 1 (car (last edges))))
        (right1 (nth 2 (car (last edges))))
        (bottom1 (nth 3 (car (last edges))))
        (n (safe-length edges)))
    ;; we t:ry to guess the line height to move
    ;; the region away from the boundary and
    ;; avoid double lines
    (list left0
          (+ top0 (/ (- bottom0 top0) 3))
          right1
          (- bottom1 (/ (- bottom1 top1) 3)))))

(defun pdf-tools-markdown-export ()
  "Export annotations to an Markdown file for use with Geeknote"
  (interactive)
  (let ((annots (sort (pdf-annot-getannots) 'pdf-annot-compare-annotations))
        (filename (format "%s.md"
                          (file-name-sans-extension
                           (buffer-name))))
        (buffer (current-buffer)))
    (with-temp-buffer
      (insert (concat "#" (file-name-sans-extension filename) "\n"))
      (mapc (lambda (annot)
              (progn
      ;(insert (symbol-name (pdf-annot-get-type annot)))
      (when (pdf-annot-get annot 'markup-edges)
        (insert (concat "\n##Highlight\n\n"
                        (with-current-buffer buffer
                          (pdf-info-gettext (pdf-annot-get annot 'page)
                                            (pdf-tools-org-edges-to-region
                                             (pdf-annot-get annot 'markup-edges)))) "\n")))
      (insert (concat "\n##Note\n\n" (pdf-annot-get annot 'contents)))))
      (cl-remove-if
       (lambda (annot) (member (pdf-annot-get-type annot) pdf-tools-org-non-exportable-types)) annots))

      (write-file (concat "../" filename) pdf-tools-org-export-confirm-overwrite))))

(provide 'paper)
