\name{is_python_sufficient}
\alias{is_python_sufficient}
\title{Tests whether the python command is sufficient}
\usage{
  is_python_sufficient(path, minimum_version = NULL,
    maximum_version = NULL, required_modules = NULL)
}
\arguments{
  \item{path}{The path to a given python binary.  If binary
  is on system path just the binary name will work.}

  \item{minimum_version}{The minimum version of python it
  should be.  Should be a string with major and minor
  number separated by a '.'.  If left NULL won't impose
  such a restriction.}

  \item{maximum_version}{The maximum version of python it
  should be.  Should be a string with major and minor
  number separated by a '.'.  If left NULL won't impose
  such a restriction.}

  \item{required_modules}{Which modules should be required.
  Can use a single "|" to represent a single either-or
  requirement like "json|simplejson".  If left NULL won't
  impose such a restriction.}
}
\value{
  \code{TRUE} or \code{FALSE} depending on whether the
  python binary met all requirements
}
\description{
  \code{is_python_sufficient} checks whether a given python
  binary has all the desired features (minimum and/or
  maximum version number and/or access to certain modules).
}

