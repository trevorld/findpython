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

test_that("version strings are parsed correctly", {
    expect_false(any(grepl("NA", create_version_checking_code("3", "3"))))
    expect_length(create_version_checking_code(maximum_version = "3"), 3L)
    expect_length(create_version_checking_code("3.8", "3.10"), 5L)
    expect_error(create_version_checking_code("three"), "minimum_version")
    expect_error(create_version_checking_code(maximum_version = "3."), "maximum_version")

    has_python3 <- can_find_python_cmd(minimum_version = "3.0", silent = TRUE)
    skip_if_not(as.logical(has_python3), "Can't find Python 3")
    cmd <- attr(has_python3, "python_cmd")
    expect_true(is_python_sufficient(cmd, minimum_version = "3"))
    expect_true(is_python_sufficient(cmd, maximum_version = "3"))
    v <- system2(cmd, c("-c", shQuote("import sys; print('%d.%d' % sys.version_info[:2])")),
                 stdout = TRUE)
    expect_true(is_python_sufficient(cmd, minimum_version = v, maximum_version = v))
    expect_false(is_python_sufficient(cmd, maximum_version = "2"))
    expect_false(is_python_sufficient(cmd, minimum_version = "4"))
})

test_that("parse_version() fills in a missing minor version", {
    expect_identical(parse_version("3", "minimum"), c(3L, 0L))
    expect_identical(parse_version("3", "maximum"), c(3L, .Machine$integer.max))
    expect_identical(parse_version("3.10.2", "maximum"), c(3L, 10L))
})

test_that("parse_version() validates its input", {
    expect_identical(parse_version(" 3.8 ", "minimum"), c(3L, 8L))
    expect_error(parse_version(3.10, "minimum"), "minimum_version")
    expect_identical(parse_version(numeric_version("3.10"), "minimum"), c(3L, 10L))
    expect_identical(parse_version(numeric_version("3"), "maximum"), c(3L, .Machine$integer.max))
    expect_identical(parse_version(package_version("3.10.1"), "maximum"), c(3L, 10L))
    expect_error(parse_version(numeric_version(c("3.8", "3.9")), "minimum"), "minimum_version")
    expect_error(parse_version(numeric_version("x", strict = FALSE), "minimum"), "minimum_version")
    expect_error(parse_version(c("3", "4"), "minimum"), "minimum_version")
    expect_error(parse_version(NA_character_, "maximum"), "maximum_version")
    expect_error(parse_version("99999999999", "minimum"), "too large")
    expect_error(parse_version("3.99999999999", "maximum"), "too large")
    expect_identical(parse_version("3.10.99999999999", "minimum"), c(3L, 10L))
})

test_that("find_python_cmd() validates versions before searching", {
    local_mocked_bindings(get_python_cmds = function() character(0))
    expect_error(find_python_cmd(minimum_version = "three"), "minimum_version")
    expect_error(can_find_python_cmd(minimum_version = "three", silent = TRUE), "minimum_version")
})
