# Copyright (c) 2014 Paul Gilbert
# Copyright (c) 2014-2017 Trevor L. Davis
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


context("Any python")
test_that("python works as expected", {
    cmdExists <- can_find_python_cmd()
    if (!cmdExists) { skip("Can't find any version of python") }
    cmd <- attr(cmdExists, 'python_cmd')
    # 'sys' should always be installed
    expect_true(can_find_python_cmd(required_modules ='sys'))
    expect_true(is_python_sufficient(cmd, required_modules = 'sys'))

    # 'xxxyyyzzz' is being found and should not exist.")
    expect_false(can_find_python_cmd(required_modules ='xxxyyyzzz',
                                     silent=TRUE))

    # Can't figure out how to capture try output via testthat...
    # expect_output(can_find_python_cmd(required_modules ='xxxyyyzzz'), 
    #               "Couldn't find a sufficient Python binary.")
    expect_false(is_python_sufficient(cmd, required_modules ='xxxyyyzzz'))
})

context("Python 2")
test_that("Python 2 works as expected", {
    python2_exists <- can_find_python_cmd(minimum_version = '2.0', maximum_version = '2.7', silent=TRUE)
    if (!python2_exists) { skip("Can't find Python 2") }
    cmd <- attr(python2_exists, 'python_cmd')
    # 'sys' should always be installed
    expect_true(is_python_sufficient(cmd, required_modules = 'sys'))

    # 'xxxyyyzzz' is being found and should not exist.")
    expect_false(is_python_sufficient(cmd, required_modules ='xxxyyyzzz'))
})

context("Python 3")
test_that("Python 3 works as expected", {
    python3_exists <- can_find_python_cmd(minimum_version = '3.0', silent=TRUE)
    if (!python3_exists) { skip("Can't find Python 3") }
    cmd <- attr(python3_exists, 'python_cmd')
    # 'sys' should always be installed
    expect_true(is_python_sufficient(cmd, required_modules = 'sys'))

    expect_true(is_python_sufficient(cmd, required_modules = 'json | simplejson'))

    # 'xxxyyyzzz' is being found and should not exist.")
    expect_false(is_python_sufficient(cmd, required_modules ='xxxyyyzzz'))
})

context("Python 4")
test_that("Python 4 works as expected", {
    # Check Python 4 doesn't exist when testing other machines
    python4_exists <- can_find_python_cmd(minimum_version = '4.0', silent=TRUE)
    if (!python4_exists) { skip("Python 4 not found") }
    cmd <- attr(python4_exists, 'python_cmd')
    # 'sys' should always be installed
    expect_true(is_python_sufficient(cmd, required_modules = 'sys'))

    # 'xxxyyyzzz' is being found and should not exist.")
    expect_false(is_python_sufficient(cmd, required_modules ='xxxyyyzzz'))
})

