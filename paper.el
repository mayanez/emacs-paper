
(defgroup paper nil
  "Interact with Mendeley/Zotero through emacs."
  :group 'tools
  :group 'convenience)

(defcustom paper-command "paper"
  "The Paper command."
  :group 'paper
  :type 'string)

(defun paper-search (query)
  "Search for a paper using some keyword"
  (interactive "keyword: ")
  (message (format "Searching for: %s" query))
  (eshell-command
   (format (concat paper-command " search %s")
           (shell-quote-argument query))))
