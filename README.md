							GitSHell (version 0.2)


## Introduction

The idea for the Git Command Shell (GitSHell) originated while participating in the
"Start-up Engineering" course, during Summer 2013, offered by Stanford University
in conjunction with Coursera.

The GitSHell program, written entirely in Bourne Again Shell (BASH), is an interactive command-driven
development environment for git. The decision to develop GitSHell as a bash script was taken because
BASH is available for a variety of Unix environments and requires no external libraries beyond those
typically installed on modern-day Unix systems, including GNU/Linux and Apple Mac OS X systems.

## What does GitSHell provide the user?

* Git commands tend to come in groups. Avoid typing `git` repeatedly by executing them
  in a dedicated shell:

		sh$ gitsh
		gitsh:[]> create remote sample
		gitsh:[]: open sample
		gitsh:[sample]> # add, delete, modify files
		gitsh:[sample]> add .
		gitsh:[sample]> commit -m "Release to QA"
		gitsh:[sample]> push 
		gitsh:[sample]> close
		gitsh:[]>

* GitSHell provides a higher level abstraction in addition to the standard git
  commands. But the user can choose to use git commands to manage the
  entire lifecycle of the repository.

		sh$ gitsh
		gitsh:[]> create remote sample
		gitsh:[]> open sample
		gitsh:[sample]> # add, delete, modify files
		gitsh:[sample]> synchronise "<commit comment>"
		gitsh:[sample]> close
		gitsh:[]>

  The preceding examples are very simplified for illustrative purposes.

* Modifications to your Git configuration can be made globally or locally
  with 'gitsh configure' command depending upon the current context. If
  no arguments follow the command, an editable configuration file loads.
  The local configuration changes only effect git commands issued during the
  session and are forgotten when you exit, just like shell environment
  variables.

		gitsh:[sample]> configure

* Obtain information about the state of the git repository, without
  modifying your shell settings. This includes the name of the current HEAD, and
  a colour and sigil to indicate the status.

		gitsh:[sample]> repo

* Further information about the commands available within the GitSHell
  environment can be found by typing the command:

  (1) 'help' within GitShell; this includes both git and gitsh commands. 
  (2) typing the command 'git[sh] help [command]' within GitShell.
  (3) typing the command 'man git[sh] [command]' at the Unix shell prompt.

  A subset of the full Git command set is supported by GitShell although future
  releases will enable the full Git command set.

## Installing GitSHell

* On Unix systems:

    curl -O https://github.com/gregoryhorne/gitsh/gitsh-0.1.tar.gz
	tar -zxf gitsh-0.1.tar.gz
	cd gitsh-0.1
    sh install.sh

By default the gitsh software will be installed in the ${HOME}/bin/gitshell-0.1
subdirectory. If ${HOME}/bin does not exist, the subdirectory will be created.
A symbolic link from ${HOME}/bin/gitsh will be made to
${HOME}/bin/gitshell-0.1/gitsh.sh.

If an alternate installation subdirectory is preferred, edit the install.sh
script by adjusting the line containing INSTALL=${HOME}/bin.

## Contributing to gitsh

In the spirit of free/libre software pull requests and user contributions
are encouraged.

## License

Copyright © 2013,2014 Gregory D. Horne.

This software is released under the GNU GPL (version 2),
and may be redistributed under the terms specified in the
LICENSE file.
