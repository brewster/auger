# Auger

## Overview
* auger is DSL with which you can write tests for just about everything you run in your environment
* it's like magic pixie dust for IBM servers...

## Usage
* the binary, aug, should be placed in your PATH, or aliased: ```alias aug="/path/to/auger/bin/aug"```
* sample configs included in examples/ can be moved into cfg/ and then run via ```aug redis```, etc. Edit as required for your env
* alternatively, you can place your configs anywhere you'd like and set the env_var AUGER_CFG=/path/to/your/configs

## Command Line Completion
* BASH completion:
    function _augcomp () {
      augcfgs=$(aug -l|xargs) local word=${COMP_WORDS[COMP_CWORD]}
      COMPREPLY=($(compgen -W "$augcfgs" -- "${word}"))
    }
    complete -F _augcomp aug```


* ZSH completion:
    _augprojects () {
      compadd $(aug -l)
    }
    compdef _augprojects aug```

