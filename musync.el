;; musync.el -- Download music in batch -*- lexical-binding: t; -*-

;; Copyright (C) 2013-2021 Free Software Foundation, Inc.
;; Author: Giovanni Santini <santigio2003@gmail.com>
;; Maintainer: Giovanni Santini <santigio2003@gmail.com>
;; Version: 0.0.1
;; Package-Requires: ((emacs "22.1"))
;; Keywords: fetch, music
;; Homepage: https://github.com/San7o/musync.el.git

;; This file is not part of GNU Emacs.

;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;; Download music asynchronously given a list of songs, including the
;; name, author and category. You can save a description of all the
;; music you want to download as a lisp list, this script will
;; download the music that you do not already have in your
;; system. Hence, you can easily synchronize / version control your
;; local music across your machines.

;; Code:

(setq musync--base-directory
      "~/music")

(setq musync--audio-format
      "mp3")

(setq musync--command
      "yt-dlp -f bestaudio -x --audio-format FORMAT -o \"NAME\" -P PATH \"LINK\"")

(defun musync (entries)
  "Downloads a list of songs entries.

entries is a list of songs, each song must have at least the
property :name and :link, optional properties include :author and
:category. All properties are strings.

This function will asynchronously download music using yt-dlp,
which must be available in the $PATH. Each song is downloaded in
musync--base-directory plus a directory with the name of the
category if specified. The name of the song is composed of the
provided name and the author if specified, the file format is
taken from the variable musync--audio-format.

For example:

(musync
 (list
  (list
    :name \"Immanuel\"
    :author \"Tony Anderson\"
    :category \"Instrumental\"
    :link \"https://music.youtube.com/watch?v=yi2IdZuSgRI&si=Xus4F44e_qad7W8l\")
   (list
    :name \"Interstellar\"
    :author \"Hanz Zimmer\"
    :category \"Soundtracks\"
    :link \"https://music.youtube.com/watch?v=1ki7oATXdXc&si=0c52s2Ij25d-aKGm\"))
"
  (dolist (entry entries)
    (let* ((command musync--command)
            (name (plist-get entry :name))
            (author (plist-get entry :author))
            (category (plist-get entry :category))
            (link (plist-get entry :link))
            (path (concat musync--base-directory "/" category)))
      (if (and name link)
          (let* ((concat-name (if author
                                  (concat name " - " author)
                                name))
                 (full-name (concat concat-name ".mp3")))
            (if (not (file-exists-p (concat path "/" full-name)))
                (let* ((command (string-replace "FORMAT" musync--audio-format command))
                       (command (string-replace "NAME" full-name command))
                       (command (string-replace "PATH" path command))
                       (command (string-replace "LINK" link command))
                       (buf (generate-new-buffer "musync")))
                  (async-shell-command command buf buf))
              ;;(print command))
              (message "At lest :name and :url must be specified")))))))

(provide 'musync)

;;; musync.el ends here
