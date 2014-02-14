findpython
==========

R package currently designed to find acceptable Python binaries for your program.  Since there are often multiple python binaries installed on any given system and they aren't always added to the path this can be a non-trivial task.

To install the development version use::

    devtools::install_github("trevorld/findpython")

Usage
=====

`find_python_cmd` is the main function.  It returns the path to a python binary that meets certain requirements you specify.  Below are some examples.

If you need to find a Python 2 binary which is at least Python 2.4::

  find_python_cmd(minimum_version = '2.4', maximum_version = '2.7')

If you need to find a version of Python at least Python 2.5 (but don't care if it is a Python 3 binary)::

  find_python_cmd(minimum_version = '2.5')

If you don't care what version of Python you use but it needs to have access to a `argparse` module as well as either the `json` OR `simplejson` module::

  find_python_cmd(required_modules = c('argparse', 'json | simplejson'))

Although `find_python_cmd` will create a basic default message if left unspecified you can use the `error_message` argument to specify what error message your program will output if it is unable to find an acceptable binary::

  find_python_cmd(minimum_version = '3.0', 
        error_message = 'Was unable to find the Python 3 binary dependency.  See file INSTALL for more information')


If you already have a python binary you want to check you can use `is_python_sufficient` to test whether it has sufficient features.  It has the same arguments `minimum_version`, `maximum_version`, and `required_modules` as `find_python_cmd`::

  is_python_sufficient(path_to_binary, minimum_version = '2.6', required_modules = 'scipy')


