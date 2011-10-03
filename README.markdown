gitfalls
========

.. a collection of git curiosities and idiosynchrasies

Why?
----

git is the most awesome version control software. It's distributed nature (and frankly: github) encourages
us to use it the way we _should_ have been using all those other version control systems in the past
(but we were afraid to - didn't know how - it was too opaque and complex).

But the more power features we use, the more we are likely to run into seemingly weird behaviour. Gitfalls is
a (nascent) collection of twilight-zone demostrations for some of the more interesting (.. and always looking for
more contributions).

Of course, being open is one of the great things about git and therefore it means it is possible to really get
down to a definitive understanding of why these things work the way they do; that's what gitfalls is for.

Catalogue
---------

1. Falling off a branch

    [gitfall_01-falling_off_a_branch.sh](https://github.com/tardate/gitfalls/blob/master/gitfall_01-falling_off_a_branch.sh)

    Ever had a merge fail with a 'fatal: git write-tree failed to write a tree' message?
    And then end up with the merge commit that only has one parent once you've fixed it?
    This script explores the issue and explains one cause of a merge that ends up losing a parent
    (having a file on one branch that has the same name as a folder on another branch)
    It also demonstrates two ways of fixing it: the easy way, and the hardcore way.

Ok, so it's currently a catalgue of "1"! Looking for more to fill this space ;-)

References
----------

A couple of references for sites and books that are useful for digging deeper than commit/push/pull:

* [git community book](http://book.git-scm.com/index.html)
* [git magic](http://www-cs-students.stanford.edu/~blynn/gitmagic/index.html)
* [Pro Git](http://progit.org/) - book and site
* [Version Control with Git](http://books.google.com/books/about/Version_control_with_Git.html?id=e9FsGUHjR5sC) - book
* [Pragmatic Version Control Using Git](http://pragprog.com/book/tsgit/pragmatic-version-control-using-git) - book

Contributing to gitfalls
------------------------

New demos, fixes and improvements are most welcome. Easiest way to collaborate is the usual github fashion:

* Check out the latest master
* Check out the issue tracker to see if there's already something underway
* Fork the project
* Start a feature/bugfix branch
* Commit and push until you are happy with your contribution
* Make sure it tests safely
* Push to github and send a pull request

Copyright
---------

Copyright (c) 2011 Paul Gallagher. See LICENSE for further details.