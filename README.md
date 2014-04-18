							GitSHell (version 0.1)


## Introduction

The idea for the Git Command Shell (GitSHell) originated while participating in the
"Start-up Engineering" course, during Summer 2013, offered by Stanford University
in conjunction with Coursera.

The GitSHell program, written entirely in Bourne Again Shell (BASH), is an interactive command-driven
development environment for git. The decision to develop GitSHell as a bash script was taken because
BASH is available for a variety of Unix environments and requires no external libraries beyond those
typically installed on modern-day Unix systems, including GNU/Linux and Apple Mac OS X systems.

## What does GitSHell provide the user?

* GitSHell provides a higher level abstraction in addition to the standard git
  commands to manage the repository's lifecycle.

* Avoid repeatedly typing 'git' before every command.

        sh$ gitsh
        gitsh:[]> create remote sample
        gitsh:[]: open sample
        gitsh:[sample]> # add, delete, modify files
        gitsh:[sample]> sync master master "Initial commit"
        gitsh:[sample]> close
        gitsh:[]>

  The preceding example is simplified for illustrative purposes.

* Modifications to your Git configuration can be made with GitSHell's
  'configure' command.

		gitsh:[sample]> configure

* Obtain information about the state of the git repository.

		gitsh:[sample]> repo

* Further information about the commands available within the GitSHell
  environment can be found by typing the command:

  (1) 'help' within GitShell
  (2) 'gitsh help [command]' within GitShell
  (3) 'man git[sh] [command]' at the Unix shell prompt

  A subset of the full Git command set is supported by GitShell while 
  providing the the most useful functionality.

## Installing GitSHell

Instructions forthcoming.

## License

Copyright © 2013,2014 Gregory D. Horne.

This software is released under the GNU GPL (version 2),
and may be redistributed under the terms specified in the
LICENSE file.
