# Copyright (c) 2024 Trevor L. Davis
# Copyright (c) 2014 Paul Gilbert
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

test_that("Python works as expected", {
    cmd_exists <- can_find_python_cmd()
    skip_if_not(as.logical(cmd_exists), "Can't find any version of python")
    cmd <- attr(cmd_exists, "python_cmd")

    expect_true(can_find_python_cmd(required_modules = "sys"))
    expect_true(is_python_sufficient(cmd, required_modules = "sys"))
    expect_false(can_find_python_cmd(required_modules = "xxxyyyzzz",
                                     silent = TRUE))
    expect_false(is_python_sufficient(cmd, required_modules = "xxxyyyzzz"))
})

test_that("Python 2 works as expected", {
    has_python2 <- can_find_python_cmd(
        minimum_version = "2.0", maximum_version = "2.7", silent = TRUE
    )
    skip_if_not(as.logical(has_python2), "Can't find Python 2")
    cmd <- attr(has_python2, "python_cmd")

    expect_true(is_python_sufficient(cmd, required_modules = "sys"))
    expect_false(is_python_sufficient(cmd, required_modules = "xxxyyyzzz"))
})

test_that("Python 3 works as expected", {
    has_python3 <- can_find_python_cmd(
        minimum_version = "3.0", silent = TRUE
    )
    skip_if_not(as.logical(has_python3), "Can't find Python 3")
    cmd <- attr(has_python3, "python_cmd")

    expect_true(is_python_sufficient(cmd, required_modules = "sys"))
    expect_true(is_python_sufficient(cmd,
                                     required_modules = "json | simplejson"))
    expect_false(is_python_sufficient(cmd, required_modules = "xxxyyyzzz"))
})
