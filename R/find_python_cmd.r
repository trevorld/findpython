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

#' Tests whether the python command is sufficient
#'
#' `is_python_sufficient()` checks whether a given python binary has all the
#' desired features (minimum and/or maximum version number and/or access to
#' certain modules).
#'
#' @param path The path to a given python binary.
#'      If binary is on system path just the binary name will work.
#' @param minimum_version The minimum version of python it should be.
#'      Should be a string with major and minor number separated by a `.`
#'      (e.g. `"3.8"`) or just a major number (e.g. `"3"`, equivalent to `"3.0"`).
#'      A [numeric_version()] object also works.
#'      If left NULL won't impose such a restriction.
#' @param maximum_version The maximum version of python it should be.
#'      Should be a string with major and minor number separated by a `.`
#'      (e.g. `"3.8"`) or just a major number (e.g. `"3"`, meaning any `3.x`).
#'      A [numeric_version()] object also works.
#'      If left NULL won't impose such a restriction.
#' @param required_modules Which modules should be required.
#'      Can use a single `|` to represent a single either-or requirement like `"json|simplejson"`.
#'      If left `NULL` won't impose such a restriction.
#' @return `TRUE` or `FALSE` depending on whether the python binary met all requirements
#' @examples
#' try({
#'   cmd <- find_python_cmd()
#'   is_python_sufficient(cmd, minimum_version = "3.3", required_modules = "sys")
#' })
#' @export
is_python_sufficient <- function(path, minimum_version=NULL,
                                 maximum_version=NULL, required_modules=NULL) {
    path <- normalizePath(path, mustWork = FALSE)
    python_code <- vector("character")
    if (!is.null(required_modules)) {
        import_code <- create_import_code(required_modules)
        python_code <- append(python_code, import_code)
    }
    version_code <- create_version_checking_code(minimum_version, maximum_version)
    python_code <- append(python_code, version_code)
    ok_message <- "Everything worked out okay"
    python_code <- append(python_code, paste("print(", shQuote(ok_message), ")", sep = ""))
    tryCatch({
            output <- system2(path, input = python_code, stdout = TRUE, stderr = FALSE)
            any(grepl(ok_message, output))
        },
        warning = function(w) {
            FALSE
        },
        error = function(e) {
            FALSE
        })
}

#' Find a suitable python cmd or give error if not possible
#'
#' `find_python_cmd()` finds a suitable python cmd or raises an error if not possible
#'
#' @inheritParams is_python_sufficient
#' @param error_message What error message the user will see if couldn't find a sufficient python binary.
#'     If left NULL will print out a default message.
#' @return The path to an appropriate python binary.  If such a path wasn't found then it will throw an error.
#' @examples
#' try(find_python_cmd())
#' try(find_python_cmd(minimum_version = "2.6", maximum_version = "2.7"))
#' try(find_python_cmd(required_modules = c("argparse", "json | simplejson")))
#' @seealso [can_find_python_cmd()] for a wrapper which doesn't throw an error
#' @export
find_python_cmd <- function(minimum_version = NULL, maximum_version = NULL,
                            required_modules = NULL, error_message = NULL) {
    # Validate version strings up front (result unused), even if no candidate binaries are found
    create_version_checking_code(minimum_version, maximum_version)
    python_cmds <- get_python_cmds()
    for (cmd in python_cmds) {
        if (is_python_sufficient(cmd, minimum_version, maximum_version, required_modules)) {
            return(cmd)
        }
    }
    # Try using reticulate::py_discover_config()$python_versions if can't find a suitable command
    if (requireNamespace("reticulate", quietly = TRUE)) {
        python_cmds <- reticulate::py_discover_config()$python_versions
        for (cmd in python_cmds) {
            if (is_python_sufficient(cmd, minimum_version, maximum_version, required_modules)) {
                return(cmd)
            }
        }
    }
    if (is.null(error_message)) {
        error_message <- default_error_message(minimum_version, maximum_version, required_modules)
    }
    stop(error_message)
}

default_error_message <- function(minimum_version = NULL, maximum_version = NULL, required_modules = NULL) {
    paste("Couldn't find a sufficient Python binary.",
          "If you haven't installed the Python dependency yet please do so.",
          "If you have but it isn't on the system path (as is default on Windows) please add it to path",
          "or set options('python_cmd'='/path/to/binary') ",
          "or set the PYTHON, PYTHON2, or PYTHON3 environmental variables.",
          if (!is.null(minimum_version)) paste("Python must be at least version", minimum_version),
          if (!is.null(maximum_version)) paste("Python must be at most version", maximum_version),
          if (!is.null(required_modules)) paste("Python must have access to the modules:",
                                                paste(required_modules, collapse = ", ")))

}

get_python_cmds <- function() {
    python_cmds <- c(getOption("python_cmd", ""), "python", Sys.getenv("PYTHON", ""),
                    paste0("python4.", seq(9, 0, by = -1)), Sys.getenv("PYTHON4", ""), "python4",
                    paste0("python3.", seq(20, 0, by = -1)), Sys.getenv("PYTHON3", ""), "python3",
                    paste0("python2.", seq(7, 0, by = -1)), Sys.getenv("PYTHON2", ""), "python2",
                    "pypy", sprintf("C:/Python%s/python", c(49:20)))
    python_cmds <- normalizePath(python_cmds, mustWork = FALSE)
    python_cmds <- unique(python_cmds)
    python_cmds <- Sys.which(python_cmds)
    python_cmds[which(python_cmds != "")]
}

#' Determines whether or not it can find a suitable python cmd
#'
#' `can_find_python_cmd()` runs [find_python_cmd()] and returns whether it could find a suitable python cmd.
#'  If it was successful its output also saves the found command as an attribute.
#'
#' @inheritParams find_python_cmd
#' @param silent Passed to `try`, whether any error messages from [find_python_cmd()] should be suppressed
#' @return `TRUE` or `FALSE` depending on whether
#'    [find_python_cmd()] could find an appropriate python binary.
#'     If `TRUE` the path to an appropriate python binary is also set as an attribute.
#'     Malformed `minimum_version` or `maximum_version` values throw an error.
#' @examples
#' did_find_cmd <- can_find_python_cmd()
#' python_cmd <- attr(did_find_cmd, "python_cmd")
#' @seealso [find_python_cmd()]
#' @export
can_find_python_cmd <- function(minimum_version = NULL,
          maximum_version = NULL, required_modules = NULL,
          error_message = NULL, silent = FALSE) {
    # Malformed version strings are an error rather than `FALSE`
    create_version_checking_code(minimum_version, maximum_version)
    python_cmd <- try(find_python_cmd(minimum_version = minimum_version,
                          maximum_version = maximum_version,
                          required_modules = required_modules,
                          error_message = error_message),
                    silent = silent)
    if (inherits(python_cmd, "try-error")) {
        r <- FALSE
    } else {
        r <- TRUE
        attr(r, "python_cmd") <- python_cmd
    }
    r
}

# Create appropriate module import code
create_import_code <- function(required_modules) {
    import_code <- vector("character")
    for (module in required_modules) {
        if (grepl("\\|", module)) {
            module <- gsub(" ", "", module)
            module <- strsplit(module, "\\|")[[1]]
            import_code <- append(import_code,
                                  c("try:",
                                   paste("    import", module[1]),
                                   "except ImportError:",
                                   paste("    import", module[2])))
        } else {
            import_code <- append(import_code, paste("import", module))
        }
    }
    import_code
}

# Create appropriate version checking code
create_version_checking_code <- function(minimum_version = NULL, maximum_version = NULL) {
    if (is.null(minimum_version) && is.null(maximum_version)) {
        return(c())
     } else {
        version_code <- c("import sys")
    }
    # Index `sys.version_info` as a tuple: named attributes require Python >= 2.7
    if (!is.null(minimum_version)) {
        v <- parse_version(minimum_version, "minimum")
        version_code <- append(version_code, c(
            sprintf("if sys.version_info[0] < %d : raise Exception('Major version too low')", v[1]),
            sprintf("if sys.version_info[0] == %d and sys.version_info[1] < %d : raise Exception('Minor version too low')",
                    v[1], v[2])))
    }
    if (!is.null(maximum_version)) {
        v <- parse_version(maximum_version, "maximum")
        version_code <- append(version_code, c(
            sprintf("if sys.version_info[0] > %d : raise Exception('Major version too high')", v[1]),
            sprintf("if sys.version_info[0] == %d and sys.version_info[1] > %d : raise Exception('Minor version too high')",
                    v[1], v[2])))
    }
    version_code
}

# Parse a version string like "3" or "3.8" into integer major and minor.
# A missing minor is 0 for a minimum ("3" means "3.0")
# and the largest R integer for a maximum ("3" means any "3.x").
# Python ints are unbounded, so this is a valid literal in every Python version.
parse_version <- function(version, type = c("minimum", "maximum")) {
    type <- match.arg(type)
    # `numeric_version()` objects keep their components so convert losslessly
    if (inherits(version, "numeric_version"))
        version <- as.character(version)
    # Otherwise require a string: a number like 3.10 would silently become "3.1"
    if (!is.character(version) || length(version) != 1L || is.na(version) ||
        !grepl("^[0-9]+(\\.[0-9]+)*$", trimws(version))) {
        stop(sprintf("`%s_version` must be a version string like \"3\" or \"3.10\", not %s",
                     type, deparse(version)), call. = FALSE)
    }
    # Only the major and minor versions are used so ignore any patch version etc.
    parts <- strsplit(trimws(version), ".", fixed = TRUE)[[1]][1:2]
    v <- suppressWarnings(as.integer(parts))
    if (any(is.na(v) & !is.na(parts))) {
        stop(sprintf("`%s_version` has a version number too large: %s",
                     type, deparse(version)), call. = FALSE)
    }
    if (is.na(v[2]))
        v[2] <- switch(type, minimum = 0L, maximum = .Machine$integer.max)
    v
}
