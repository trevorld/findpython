require('findpython')

cmdExists <- can_find_python_cmd()

if (!cmdExists) warning('python was not found. No other checks performed.') else {

  if (! can_find_python_cmd(required_modules ='sys'))
     stop("error finding module 'sys' which should always be installed.")

  if (can_find_python_cmd(required_modules = 'xxxyyyzzz', silent=TRUE))
     stop("error. module 'xxxyyyzzz' is being found and should not exist.")

  cmd <- attr(cmdExists, 'python_cmd')
  
  if (is_python_sufficient(cmd, minimum_version = '2.6')) {
     if (! is_python_sufficient(cmd, minimum_version = '2.6', required_modules = 'sys')) 
	    stop("is_python_sufficient is not finding 'sys'")
     
     if (is_python_sufficient(cmd, minimum_version = '2.6', required_modules = 'xxxyyyzzz'))
     stop("error. module 'xxxyyyzzz' is being found by is_python_sufficient.")
     }

  }
