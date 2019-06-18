**Test environments**

* local (linux, R 3.4.4)
* win-builder (windows, R devel and R release)
* appveyor (windows, R devel and R release)
* travis-ci (linux, R devel and R release)
* travis-ci (osx, R release)

**R CMD check --as-cran results**

Status: OK

**Downstream dependencies**

I have also run R CMD check on downstream dependencies of findpython.
All packages had no ERRORs or WARNINGs.  
RWebLogo and popRange have NOTEs unrelated to my package.
