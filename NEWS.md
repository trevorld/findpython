findpython 1.0.9
================
* `find_python_cmd()` and `is_python_sufficient()` now run 
  `normalizePath(mustWork = FALSE)` on potential python binary paths.
* `is_python_sufficient()` now uses `system2()` instead of `system()`.

findpython 1.0.8
================
* Looks for more python binaries (Python 3.13 through 3.20).
  This will help future-proof the package for later Python releases.

findpython 1.0.7
================
* Looks for more python binaries (Python 3.10 through 3.12).

findpython 1.0.5
================
* Minor internal refactoring and documentation improvements.

findpython 1.0.4
================
* No longer throws an unintended error when can't find a suitable python command AND ``reticulate`` package is not installed.

findpython 1.0.3
================
* Uses ``reticulate::py_discover_config()`` to find more python
  binaries if can't otherwise find a suitable python command.

findpython 1.0.2
================
* Looks for more python binaries and likely folders in Windows (i.e. Python 3.5 through Python 3.9).  
  Thanks Jori Liesenborgs for request.

findpython 1.0.1
================
* Initial released version on CRAN.



