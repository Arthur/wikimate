# wikimate

Tool to make a wiki-like web site, storage in git, pages are in markdown format.
You can directly edit the pages, an wikimate build static html pages from them, or you can use wikimate as a server, to have direct previsualisation, with link to textmate for editing each paragraph.

## Usage

    wikimate path_to_markdown_dir   # launch the server
    wikimate --build                # make static html files in html/ dir.

## Install

Not an official gem yet, so :

    git clone https://github.com/Arthur/wikimate.git
    cd wikimate && rake install

## Note on Patches/Pull Requests
 
* Fork the project.
* Make your feature addition or bug fix.
* Add tests for it. This is important so I don't break it in a
  future version unintentionally.
* Commit, do not mess with rakefile, version, or history.
  (if you want to have your own version, that is fine but bump version in a commit by itself I can ignore when I pull)
* Send me a pull request. Bonus points for topic branches.

## Copyright

Copyright (c) 2010 Arthur Petry. See LICENSE for details.

OBS. good
