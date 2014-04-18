#!/bin/bash

################################################################################
#
# Programme Name: GitSHell
# Application Name: gitshell.sh
# Description: Provides a command-line shell environment for Git. 
#
# Copyright (c) 2013-2014 Gregory D. Horne (horne at ncf dot ca)
# 
################################################################################
#
#    This program is free software; you can redistribute it and/or modify
#    it under the terms of the GNU General Public License (version 2) as
#    published by the Free Software Foundation.
#
#    The software is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with the software; if not, write to the Free Software
#    Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301 USA.
################################################################################


################################################################################
# Git Command Shell Commands:
################################################################################

declare -A gitsh_cmds=\
(
	["cd"]="Change subdirectory in the repository"
	["clear"]="Clear the terminal"
	["close"]="Leave the repository"
	["clone"]="Clone a repository into a new subdirectory"
	["configure"]="Configure name and email of the user(s)"
	["create"]="Create local/remote repository"
	["delete"]="Delete file/subdirectory/repository"
	["edit"]="Edit file within the repository"
	["exit"]="Exit the command shell"
	["fork"]="Fork an existing repository"
	["license"]="View license associated with this programme"
	["ls"]="List files within the repository"
	["mkdir"]="Create subdirectory in the repository"
	["names"]="List name of existing repositories"
	["open"]="Access named repository"
	["pwd"]="Print name of current/working subdirectory"
	["repo"]="Show information about the repository"
	["root"]="Displays repository root name, otherwise resets the repository"
	["stage"]="Create, delete, list branches within the repository"
	["sync"]="Synchronise the remote repository with its local counterpart"
	["view"]="View file within the repository"
)

################################################################################
# Function: Display the programme banner.
################################################################################

function banner
{
echo
echo "##########################################################################"
echo "#                              GitSHell                                  #"
echo "#                                                                        #"
echo "#                    Git Command Shell Environment                       #"
echo "#                             version 0.1                                #"
echo "#                                                                        #"
echo "##########################################################################"
echo
}

################################################################################
# Function: Display the programme disclaimer.
################################################################################

function disclaimer
{
	echo
	echo "GitSHell version 0.1, Copyright (C) 2013-2014 Gregory D. Horne"
	echo
    	echo "GitSHell comes with ABSOLUTELY NO WARRANTY, to the extent"
    	echo "permitted by applicable law; read the LICENSE by typing"
	echo "the command 'license'."
	echo
    	echo "This is free software, and you are welcome to redistribute it under"
    	echo "certain conditions; read the LICENSE by typing the command 'license'."
	echo
}

################################################################################
# Function: Display the help options.
################################################################################

function usage 
{
	cat $(dirname $(which gitsh.sh))/gitshell/HOW-TO
	echo
}

################################################################################
# Function: Display the version of the programme.
################################################################################

function version
{
	echo "gitsh version 0.1"
	exit 0
}

################################################################################

################################################################################
# Function: Read each command typed within Git command-shell 
#           environment and dispatch the appropriate handler. To exit the
#           command-shell type 'exit' (without the quotation marks).
################################################################################

function command_processor
{
	while true
	do
		if [ $(repository_root name) == "(none)" ]
		then
			echo -n "gitsh:[]> "
		else
			echo -n "gitsh:[$(repository_root name)]> "
		fi

		read cmd 
		[[ ${cmd} == "exit"  ]] && break

		if [[ ${cmd} =~ ^git ]]
		then
			# Sanitize commands beginning with 'git'.
			# Extract the command and arguments.
			# Arguments must be separated by a comma to permit passing to a function as a single unit.
			cmd_arg=$(printf "%s," `echo ${cmd} | cut -d \  -f 3-`)
			cmd=`echo ${cmd} | cut -d \  -f 1,2`
			if [ $(echo ${cmd} | cut -d \  -f 2) != "help" ]
			then
				echo "no help"
				# Strip off 'git' from the command leaving only the primary git
				# instruction such as contained in git_cmds.
				cmd=$(echo ${cmd} | cut -d \  -f 2)
			fi
			cmd=$(echo ${cmd} | awk '$1=$1' OFS="")
		else
			# Extract the command and arguments.
			# Arguments must be separated by a comma to permit passing to a function as a single unit.
			cmd_arg=$(printf "%s," `echo ${cmd} | cut -d \  -f 2-`)
			cmd=$(echo ${cmd} | cut -d \  -f 1)
		fi

		# Remove any trailing comma from the arguments.
		cmd_arg=$(echo ${cmd_arg} | sed -e 's/,$//')

		if [[ ${cmd} == ${cmd_arg} ]]
		then
			cmd_arg=""
		fi

		# Dispatch cmd with any associated cmd_arg to the appropriate handler.
		case ${cmd} in
			"")
				;;
            		gitshhelp)
                		gitsh_help ${cmd_arg}
                		;;
            		help)
                		help
                		;;
			license)
				license
				;;
			clear|clone|close|configure|cd|create|delete|deploy|edit|fork|ls|mkdir|names|open|pwd|rm|repo|root|stage|sync|view)
				gitsh_command_processor ${cmd} ${cmd_arg}
				;;
			*)
				i18n_display "invalid_command"
				;;
		esac
	done

	exit_check	
}

################################################################################
# Function: Set GIT_AUTHOR_NAME to the specified value(s).
################################################################################

function commit_author
{
	local author_name=${1}

	if [ ! -z ${author_name} ]
	then
 		export GIT_AUTHOR_NAME=${author_name}
	fi
}

################################################################################
# Function: Set GIT_AUTHOR_EMAIL to the specified value(s).
################################################################################

function commit_email
{
	local author_email=${1}

	if [ ! -z ${author_email} ]
	then
		export GIT_AUTHOR_EMAIL=${author_email}
	fi
}

################################################################################
# Function: Configure the GitSHell environment and update the git environment.
################################################################################

function configure
{
	local gitsh_configuration_file=${1}
	local gitsh_configuration
	local config

	local oldIFS=${IFS}
	local IFS=$'\n'

	if [ ! -e ${gitsh_configuration_file} ]
	then
		gitsh_configuration_create
	fi

	config=($(< ${gitsh_configuration_file}))
	gitsh_configuration=(${config[@]})


	if [ ! -e $(repository_root)/.git ]
	then
		git init
	fi

	repository_base $(echo ${gitsh_configuration[1]} | cut -d \= -f 2 | sed -e 's/ //g')	
	user_name $(echo ${gitsh_configuration[3]} | cut -d \= -f 2 | sed -e 's/ //g')
	user_email $(echo ${gitsh_configuration[4]} | cut -d \= -f 2 | sed -e 's/ //g')
	commit_author "$(echo ${gitsh_configuration[6]} | cut -d \= -f 2 | sed -e 's/ //g')"
	commit_email "$(echo ${gitsh_configuration[7]} | cut -d \= -f 2 | sed -e 's/ //g')"

	if [[ $(repository_root) == ${HOME} ]]
	then
		if [ -N .gitsh ]
		then
			dotfile_configuration_create
    		fi
	fi

	IFS=${oldIFS}

	if [ ! -e $(repository_base) ]
	then
		mkdir $(repository_base)
	fi

}

################################################################################
# Function: Display Git Command Shell configuration.
################################################################################

function configuration
{
	echo
	echo -e "Git Repository Base:\t\t$(repository_base)" 
	echo -e "(git commit) User Name:\t\t$(user_name)"
	echo -e "(git commit) User Email:\t$(user_email)"
	echo -e "(git commit) Author(s) Names:\t${GIT_AUTHOR_NAME}"
	echo -e "(git commit) Author(s) Emails:\t${GIT_AUTHOR_EMAIL}"
	echo
}

################################################################################
# Function: Allows the user to edit the repository configuration file.
################################################################################

function configuration_edit
{
	local gitsh_configuration_file=$(repository_root)/.gitsh

	if [ -e ${gitsh_configuration_file} ]
	then
		chmod 664 ${gitsh_configuration_file}
		editor_call ${gitsh_configuration_file}
		chmod 400 ${gitsh_configuration_file}
		if [ -N ${gitsh_configuration_file} ]
		then
			configure ${gitsh_configuration_file}
			configuration
		fi
	else
		i18n_display "non_existent_file" ${gitsh_configuration_file}
	fi
}

################################################################################
# Function: Determine if the [repo]/.gitsh configuration file exists.
################################################################################

function configuration_exists
{
	local repository_path=$(repository_root)

	if [ -e ${repository_path}/.gitsh ] && \
		[ $(pwd) == ${repository_path} ]
	then
		echo true
	elif [ ! -z ${repository_path} ] \
			&& [ ${repository_path} != $(pwd) ] #\
		 	#&& [ ${repository_path} != ${HOME} ]
	then
		echo true
	else
		echo false
	fi
}

################################################################################
# Function: Create the git configuration file [repo]/.git/config from
#           the file [repo].gitconfig , if .gitconfig exists. Afterwards
#           .gitconfig is deleted, if it exists within the repository.  
################################################################################

function dotfile_configuration_create
{
	local old_git_configuration
	local dotfile_git_configuration

	if [ ! -d .git ]
	then
		mkdir .git
	fi

	if [ -e .gitconfig ]
	then
		old_git_configuration=($(< .gitconfig))
		rm .gitconfig
	fi

	dotfile_git_configuration=.git/config

	if [ ! -z ${old_git_configuration} ]
	then
		for line in ${old_git_configuration[@]}
		do
			if [ -z $(echo ${line} | grep -o "user\|name\|email") ]
			then
				echo ${line} >> ${dotfile_git_configuration}
			fi
		done
	fi

	if [ ! -e ${dotfile_git_configuration} ]
	then
		touch ${dotfile_git_configuration}
	fi

	if [ -z $(cat ${dotfile_git_configuration} | grep -o "\[user\]") ]
	then
		echo "[user]" >> ${dotfile_git_configuration}
		echo "  name = $(user_name)" >> ${dotfile_git_configuration}
		echo "  email = $(user_email)" >> ${dotfile_git_configuration}
	fi
}

################################################################################
# Function: Open the file using the specified text editor or the
#           default editor. The editor argument is optional.
################################################################################

function editor_call
{
	local document=${1}
	local app=${2}

	if [ ! -z ${app} ]
	then
		${app} ${document}
	else
		editor ${document}
	fi
}

################################################################################
# Function: Close any open repository prior to termination.
################################################################################

function exit_check 
{
	echo

	if [ $(repository_status) != "closed" ]
    	then
		i18n_display "repository_close" "[$(repository_root name)]"
        	repository_close
    	fi

	i18n_display "exit_gitshell"
	echo

	exit 0
}

################################################################################
# Function: Delete a file or subdirectory.
################################################################################

function file_delete
{
	local afile=${1}

	local origin_repository_name
	local target_repository_name

    	if [ -z ${afile} ]
    	then
		i18n_display "argument_missing" "[<file>|<subdirectory>]"
	elif [ $(repository_root name) != "(none)" ] && [ $(is_git_repository $(basename ${afile})) == "true" ]
	then
		i18n_display "inside_of_repository"
	elif [ $(repository_root name) == "(none)" ]
	then
		if [ $(is_git_repository $(basename ${afile})) == "true" ]
		then
			repository_delete ${afile}
		else
			i18n_display "non_existing_git_repository"
		fi
	elif [ ! -e ${afile} ]
	then	
		i18n_display "non_existing_file"
	else
		origin_repository_name=$(repository_root name)
		wd=$(pwd)
		if [ -d ${afile} ]
		then
       			cd ${afile}
		else
			cd $(dirname ${afile})
		fi
       		target_repository_name=$(repository_root name)
       		if [ ${origin_repository_name} != ${target_repository_name} ]
       		then
           		i18n_display "not_current_repository"
			cd ${wd}
		else
			cd ${wd}
			git rm -rf ${afile}
		fi
    	fi
}

################################################################################
# Function: Allow the user to edit the specified file if it exists. Otherwise
#			the user is prompted to create the file.
################################################################################

function file_edit
{
	local document=${1}
	local opt_editor=${2}

	if [ $(repository_root name) == "(none)" ]
	then
		i18n_display "outside_of_repository"
	else
		if [ -e ${document} ]
		then
			editor_call ${document} ${opt_editor}
		else
			i18n_display "non_existing_file" "[${document}]"
        	response="y"
			response=$(i18n_prompt "file_creation_prompt" ${response})
			if printf "%s" "$response" | grep -Eq "$(locale yesexpr)"
			then
				editor_call ${document}
			fi
		fi
	fi	
}

################################################################################
# Function: Display a listing of the files in the subdirectory.
################################################################################

function file_list
{
	local cmd_arg=${1}

	local origin_repository_name
	local target_repository_name

	if [ $(repository_root name) == "(none)" ]
	then
		echo "/"
	elif [ -z ${cmd_arg} ] || [ ${cmd_arg} == "." ]
	then
		ls ${cmd_arg}
	elif [ ${cmd_arg} == "/" ]
	then
		ls $(repository_root)
	else
		origin_repository_name=$(repository_root name)
		wd=$(pwd)
		if [ -e ${cmd_arg} ] && [ ! -d ${cmd_arg} ]
		then
			cd $(dirname ${cmd_arg})
		elif [ -e ${cmd_arg} ]
		then
			cd ${cmd_arg}
		fi
		target_repository_name=$(repository_root name)
		cd ${wd}
		if [ ${origin_repository_name} != ${target_repository_name} ] || [ ${target_repository_name} == "(none)" ]
		then	
			i18n_display "not_current_repository" "[${origin_repository_name}]"
		elif [ -e ${cmd_arg} ]
		then
			ls ${cmd_arg}
		else
			i18n_display "non_existing_file"
		fi	
	fi			

}

################################################################################
# Function: View the contents of the specified file.
################################################################################

function file_view
{
	local document=${1}

	local origin_repository_name
	local target_repository_name

	if [ $(repository_root name) == "(none)" ]
	then
		i18n_display "outside_of_repository"
	else
    		if [ -z ${document} ]
    		then
        		i18n_display "missing_file"
		else
        		origin_repository_name=$(repository_root name)
        		wd=$(pwd)
			cd $(dirname ${document})
        		target_repository_name=$(repository_root name)
			cd ${wd}
        		if [ ${origin_repository_name} != ${target_repository_name} ]
        		then
            			i18n_display "not_current_repository"
			elif [ ! -e ${document} ] || [ -d ${document} ]
			then
				i18n_display "non_existing_file" "[${document}]"
        		else
				less ${document}
        		fi
		fi
	fi
}

################################################################################
# Function: Dispatcher for each recognised gitsh command. 
################################################################################

function gitsh_command_processor
{
    cmd=${1}
    cmd_arg=$(echo ${2} | sed -e 's/,/ /g' | sed -e 's/ $//')

	case ${cmd} in
		cd)
			subdirectory_change ${cmd_arg}
			;;
		clear)
			terminal_clear
			;;
		clone)
			repository_clone ${cmd_arg}
			;;
		close)
			repository_close
			;;
		configure)
                	configuration_edit
                	;;
            	create)
                	repository_create ${cmd_arg}
                	;;
            	delete)
                	file_delete ${cmd_arg}
                	;;
		deploy)
			repository_deployment ${cmd_arg}
			;;
		edit)
			file_edit ${cmd_arg}
			;;
		fork)
			repository_fork ${cmd_arg}
			;;
		ls)
			file_list ${cmd_arg}
			;;
		mkdir)
			subdirectory_make ${cmd_arg}
			;;
            	names)
                	repository_names
                	;;
		open)
			repository_open ${cmd_arg}
			;;
		pwd)
			subdirectory_print_working	
			;;
		repo)
			repository_information
			;;
            	root)
			if [ -z ${cmd_arg} ]
			then
				cmd_arg="name"
			fi
               	 	repository_root ${cmd_arg}
                	;;
		stage)
			repository_branch ${cmd_arg}
			;;
		sync)
			repository_synchronise ${cmd_arg}
			;;
		view)
			file_view ${cmd_arg}
			;;
            *)
			i18n_display "invalid_command"
                	;;
            esac
}

################################################################################
# Function: GitSHell command summary. Display list of available commands or the
#			manual page for a command.
################################################################################

function gitsh_help
{
    local request=${1}

    local valid=false

    if [[ -z ${request} ]]
    then
        echo
        i18n_display "gitsh_commands"
            
        for cmd in "${!gitsh_cmds[@]}"
        do  
            if [[ ${#cmd} -le 7 ]]
            then
                echo -e "\t${cmd}\t\t${gitsh_cmds[${cmd}]}"
            else
                echo -e "\t${cmd}\t${gitsh_cmds[${cmd}]}"
            fi  
        done | sort

		echo
	else
		for cmd in ${!gitsh_cmds[@]}
        do
            if [ ${cmd} == ${request} ]
            then
                man gitsh ${request}
                valid=true
                break
            fi
        done
        if [ ${valid} == false ]
        then
            echo "no manual entry for ${request}"
		fi
	fi
}

################################################################################
# Function: Create the Git Command Shell configuration file ([repo]/.gitsh)
#           using ${HOME}/.gitsh if available, otherwise from scratch. 
################################################################################

function gitsh_configuration_create
{
	local gitsh_configuration_file

	#if [ ! -e ${HOME}/.gitsh ]
	if [ ! -e $(repository_root)/.gitsh ]
	then
		echo "[gitsh]" >> $(repository_root)/.gitsh
		echo "  repo_base = $(repository_base)" >> $(repository_root)/.gitsh
		echo "[$(basename $(pwd))]" >> $(repository_root)/.gitsh
		echo "  name = $(user_name)" >> $(repository_root)/.gitsh
		echo "  email = $(user_email)" >> $(repository_root)/.gitsh
		echo "[authors]" >> $(repository_root)/.gitsh
		echo "  name = $(user_name)" >> $(repository_root)/.gitsh
		echo "  email = $(user_email)" >> $(repository_root)/.gitsh
	fi

	gitsh_configuration_file=$(repository_root)/.gitsh

	chmod 400 ${gitsh_configuration_file}

	i18n_display "gitshell_configuration"
}

################################################################################
# Function: Git and GitSHell command summary.
################################################################################

function help
{
	gitsh_help
}

################################################################################
# Function: Load the configuration file ([repo]./gitsh). If non-existent, create
#           the configuration file. Display the current configuration.
################################################################################

function initialise
{
	local gitsh_configuration_file

	repository_base ${HOME}
	repository_status closed

    if [[ $(configuration_exists) ]] || [[ ! $(configuration_exists) && $(is_git_repository) ]]
    then
    	gitsh_configuration_file=$(repository_root)/.gitsh
		configure ${gitsh_configuration_file}
	else
		gitsh_configuration_file=$(repository_root)/.gitsh
		configure ${gitsh_configuration_file}

		echo
		response="o"
		response=$(i18n_prompt "open_or_create_repository" ${response})
                
		if printf "%s" ${response} | grep -iq "o"
		then
			repository_open
		else
			i18n_display "create_repository"
			repo_name="dummy"
			repo_name=$(i18n_prompt "repository_name_prompt")
			repository_create local ${repo_name}
		fi
	fi

	configuration

	cd $(repository_base)
}

################################################################################
# Function: Determine if the specified repository, defaults to the
#			current repository, is a git repository.
################################################################################

function is_git_repository
{
	local repository_name=${1}

	if [ -z ${repository_name} ]
	then
		if [ -d .git ]
		then
			echo true
		else
			echo false
		fi
	else
		if [ -e $(repository_base)/${repository_name}/.git ] || \
			[ -e $(repository_base)/${repository_name}/.gitsh ]
		then
			echo true
		else
			echo false
		fi
	fi
}

################################################################################
# Function: Display the license terms attached to the programme.
################################################################################

function license
{
	less $(dirname $(which gitsh.sh))/gitshell/LICENSE
}

################################################################################
# Function: Assign or retrieve the repository base. 
################################################################################

function repository_base
{
	local base_path=${1}

	if [ -z ${base_path} ]
	then
		echo ${repository_base_path}
	else
		repository_base_path=${1}
	fi
}

################################################################################
# Function: Clone a repository.
################################################################################

function repository_clone
{
	local repository_url=${1}
	local repository_name=${2}

	if [ $(repository_root name) != "(none)" ]
	then
		i18n_display "inside_of_repository"
	else
		if [ -z ${repository_url} ]
		then
			i18n_display "argument_missing" "[repository_url]"
    	elif [ $(repository_root name) != "(none)" ]
    	then
        	i18n_display_nobreak "open_repository_warning_preface" "[$(repository_root name)]"
        	i18n_display "open_repository_warning_epilogue"
		else
			if [ -z ${repository_name} ]
			then
        		for repository_name in $(echo ${repository_url} | sed -e 's/\// /g')
        		do
            		echo >> /dev/null 2>&1
        		done
        		repository_name=$(echo ${repository_name} | cut -d \. -f 1)
       		fi

			git clone ${repository_url} ${repository_name}

			wd=$(pwd)
        	cd $(repository_base)/${repository_name}
        	git remote rm origin
       	 	cd ${wd}

        	repository_create remote ${repository_name}
		fi
	fi
}

################################################################################
# Function: Close the currently open repository. 
################################################################################

function repository_close
{
	local gitsh_configuration_file

	gitsh_configuration_file=${HOME}/.gitsh
	configure ${gitsh_configuration_file}
	cd $(repository_base)
	repository_status closed
}

################################################################################
# Function: Create a local git repository and if requested a remote repository
#           at https://github.com. Only public repositories are supported.
################################################################################

function repository_create
{
	local repository_type=${1}
	local repository_name=${2}
	shift
	shift
	local repository_description=$(echo $@ | sed -e 's/\"//g')

	if [ $(repository_root name) != "(none)" ]
	then
		i18n_display "inside_of_repository"
	else
		if [[ -z ${repository_description} ]]
		then
			repo_description=${repository_name}
		fi

		if [ -z ${repository_type} ] || [ -z ${repository_name} ]
		then
			i18n_display "git_repository_type_or_name_missing"
		else
			if [ ${repository_type} == "remote" ]
			then
				i18n_display "remote_git_repository_creation" "https://github.com/$(user_name)/${repository_name}"
				curl -u $(user_name) https://api.github.com/user/repos -d "{\"name\":\"${repository_name}\",\"description\":\"${repository_description}\"}"
			fi

			if [ ! -e $(repository_base)/${repository_name} ]	
			then
				i18n_display "local_git_repository_creation" "$(repository_base)/${repository_name}"
				mkdir $(repository_base)/${repository_name}
				wd=$(pwd)
				cd $(repository_base)/${repository_name}

				#if [ ! -e "README.md" ]
				#then
				#	touch README.md
				#fi

				wd=$(pwd)
            	cd $(repository_base)/${repository_name}
            	echo >> .gitignore
            	echo "# Ignore these files in this directory" >> .gitignore
            	echo ".gitsh" >> .gitignore
            	echo "# Except this file" >> .gitignore
            	echo "\!.gitignore" >> .gitignore
				cd ${wd}

				git init
				git add -A
				git commit -am "initial commit"
		
				cd ${wd}
			fi
			if [ ${repository_type} == "remote" ]
			then
				wd=$(pwd)
				cd $(repository_base)/${repository_name}
				#git remote add origin git@github.com:$(user_name)/${repository_name}.git
				git remote add origin https://$(user_name)@github.com/$(user_name)/${repository_name}.git
				git push origin master
				cd ${wd}
			fi
			gitsh_configuration_create
		fi
	fi
}

################################################################################
# Function: Delete an existing local git repository and if requested the remote
#           repository at https://github.com.
################################################################################

function repository_delete
{
	local repository_name=${1}

	if [ -z ${repository_name} ]
	then
		i18n_display "argument_missing" "[<repository name>]"
	elif [ $(repository_root name) != "(none)" ]
	then
			i18n_display "outside_of_repository"
	else
		local response='n'
    	response=$(i18n_prompt "repository_deletion_confirmation" ${response})
    	if printf "%s" "${response}" | grep -Eq "$(locale yesexpr)"
    	then
			if [[ $(cat $(repository_base)/${repository_name}/.git/config | grep -i "\[remote") ]]
			then
				echo "*remote repository deletion is not supported by GitHub;"
				echo "*to remove remote repository (${repository_name}) login at https://github.com"
			fi
			echo "deleting local repository"
    		rm -rf $(repository_base)/${repository_name} 
    	fi
	fi
}

################################################################################
# Function: Delete an existing local git repository and if requested the remote
#           repository at https://github.com.
################################################################################

function repository_deployment
{
	echo "deployment to services such as Heroku is not currently available"
}

################################################################################
# Function: Private. Deploy code between branches of an existing local git
#			repository or a remote repository at https://github.com.
################################################################################

function repository_branch
{
    local repository_branch=${1}

	if [ $(repository_root name) == "(none)" ]
	then
		i18n_display "outside_of_repository"
	else
		if [ -z ${repository_branch} ]
		then
			# list existing branches within repository
			git branch
		elif [[ $(git branch | grep ${repository_branch} | sed -e 's/\*//' | sed -e 's/ //g') != ${repository_branch} ]]
		then
			# create new branch within repository
			git checkout -b ${repository_branch}
			git push -u origin ${repository_branch}
		else
			# change repository branch focus
			git checkout ${repository_branch}
		fi
	fi
}

################################################################################
# Function: Forks an existing git repository creating a remote repository at
#           https://github.com as well as a local repository containing a
#			clone of the original repository.
################################################################################

function repository_fork
{
	local repository_name=${1}
	local repository_url=${2}
	shift
	shift
    local repository_description=$(echo $@ | sed -e 's/\"//g')

    if [ -z ${repository_name} ] || [ -z ${repository_url} ]
    then
        i18n_display "git_repository_type_or_name_missing"
    elif [ $(repository_root name) != "(none)" ]
    then
        i18n_display_nobreak "open_repository_warning_preface" ${repository_name}
        i18n_display "open_repository_warning_epilogue"
    else
		echo "forking ${repository_url}"
		git clone --origin=upstream ${repository_url} ${repository_name}
		repository_create remote ${repository_name} ${repository_description}
		local wd=$(pwd)
		cd $(repository_base)/${repository_name}
		#git remote add origin git@github.com:$(user_name)/${repository_name}.git
		git push -u origin --all
		cd ${wd}
	fi	
}

################################################################################
# Function: Display information about the current repository.
################################################################################

function repository_information
{
	if [ $(pwd) == $(repository_base) ]
   	then
   		echo "(none)"
	else
		echo
   		repo=$(repository_root)
		echo -n "$(basename ${repo}) "
		if [ -e ${repo}/.git ]
		then
			#echo "[valid git repository]"
			i18n_display "valid_git_repository"
			echo "Repository Base: $(repository_base)"
		else
			#echo "[not valid git repository]"
			i18n_display "invalid_git_repository"
       	fi
		echo
   fi
}

################################################################################
# Function: Display a listing of existing repository names.
################################################################################

function repository_names
{
	for item in $(ls $(repository_base))
	do
		if $(is_git_repository ${item})
		then
			echo -n "${item}  "
		fi
	done
	echo
}

################################################################################
# Function: Open the specified repository or present a list of available
#			repositories and prompt user.
################################################################################

function repository_open
{
	local repo_name=${1}
	local gitsh_config_file

	if [[ $(repository_status) == "closed" ]]
	then
		if [ -z ${repo_name} ]
		then
			echo
			i18n_display "git_repository_base" "\n$(repository_base)\n"
			i18n_display "git_repository_heading"

			repository_names	
			echo

    			repo_name=$(basename $(ls $(repository_base) | head -n 1))
			repo_name=$(i18n_prompt "repository_name_prompt" ${repo_name})

			if [ -z ${repo_name} ]
			then
				repo_name="(none)"
			fi
		fi

		if  [ ! -z ${repo_name} ] &&  [ -e $(repository_base)/${repo_name} ]  && \
		 	$(is_git_repository ${repo_name}) 
		then
			repository_status open
			cd $(repository_base)/${repo_name}
			configure $(repository_root)/.gitsh
			if [ -N ${gitsh_config_file} ]
			then
				configuration
			fi
		else
			i18n_display "non_existing_git_repository" "[${repo_name}]"
		fi
	else
		i18n_display_nobreak "repository_open_warning_preface" "[$(repository_root name)]"
		i18n_display "repository_open_warning_epilogue"
	fi
}

################################################################################
# Function: Return the name of the repository by default. If the 'reset'
#           argument is present, change to the repository's root subdirectory.  
################################################################################

function repository_root
{
	local cmd_arg=${1}

	if [ -z ${cmd_arg} ]
	then
		echo $(repository_root_helper)
	elif [ ${cmd_arg} == "name" ]
	then
		if [ $(pwd) == "/" ] || [ $(pwd) == $(repository_base) ]
		then
			echo "(none)"
		else
			if [ ! -z $(repository_root_helper) ]
			then
				echo $(basename $(repository_root_helper))
			else
				echo "/"
			fi
		fi
	elif [ ${cmd_arg} == "reset" ]
	then
		cd $(repository_root_helper)
	else
		i18n_display "invalid_argument"
	fi
}

################################################################################
# Function:  Search current directory path for .gitconfig or .git/config
################################################################################

function repository_root_helper
{
	local dir=""
    	local paths=($(echo $(pwd) | grep -oE '[A-Za-z0-9_-]+'))
	local repo_root=""

	for path in ${paths[@]}
	do
   		dir+="/${path}"
        if [ -f ${dir}/.gitconfig ] || [ -f ${dir}/.git/config ]
        then
            repo_root=${dir}
        fi
    	done

	echo ${repo_root}
}

################################################################################
# Function: Assign or retrieve the repository base.
################################################################################

function repository_status
{
	local status=${1}

	if [ ! -z ${status} ]
	then
		repository_state=${status}
	else	
    		echo ${repository_state}
	fi
}

################################################################################
# Function: Assign or retrieve the repository base.
################################################################################

function repository_synchronise
{
	local origin_branch=${1}
	local target_branch=${2}
	shift
	shift
	local comment=$@

	if [ $(repository_root name) == "(none)" ]
	then
		i18n_display "outside_of_repository"
	else
    	i18n_display "synchronising_repository" "$(repository_root name)"

		local current_branch=$(git branch | grep \* | sed -e 's/\*//' | sed -e 's/ //g')

		wd=$(pwd)
		repository_root reset

		if [ $(grep -c fetch .git/config) -gt 1 ]
		then
			git fetch upstream
			git merge master upstream/master
			git push
		fi
		
		cd ${wd}

		if [ -z ${origin_branch} ]
		then
			i18n_display "argument_missing" "[<origin branch>]"
		else
        	git checkout ${origin_branch}
		fi

        if [ -z ${target_branch} ]
        then
        	target_branch=${origin_branch}
        fi

		local count=0

		if [ ${count} -eq 0 ] && [ ! -z ${target_branch} ] && \
			[[ $(git branch | grep ${origin_branch} | sed -e 's/\*//' | sed -e 's/ //g') == ${origin_branch} ]] && \
			[[ $(git branch | grep ${target_branch} | sed -e 's/\*//' | sed -e 's/ //g') == ${target_branch} ]]
		then
			git add --all .
			if [ ${#comment} -eq 0 ]
			then
				git commit -a
			else
				git commit -a --message "${comment}"
			fi
			git push origin ${origin_branch}
			if [[ ${origin_branch} != ${target_branch} ]]
			then
				git checkout ${target_branch}
				git merge ${origin_branch}
				git push origin ${target_branch}
			fi
		fi
		git checkout ${current_branch}
	fi
}

################################################################################
# Function: Change to another subdirectory.
################################################################################

function subdirectory_change
{
	local dir=${1}

	if [ $(repository_root name) == "(none)" ]
	then
		i18n_display "outside_of_repository"
	else
		if [ -z ${dir} ] || [ ! -d ${dir} ]
		then
			i18n_display "missing_subdirectory"
		elif [ ${dir} == "/" ]
		then
			if [ $(repository_root name) == "(none)" ]
			then
				i18n_display "invalid_file_operation"
			else
				cd $(repository_base)/$(repository_root name)
			fi	
    		elif [ $(repository_root name) == "(none)" ]
    		then
			i18n_display "invalid_file_operation"
		else
			origin_repo_name=$(repository_root name)
			origin_wd=$(pwd)
		
        		cd ${dir}

			destination_repo_name=$(repository_root name)

			if [ ${origin_repo_name} != ${destination_repo_name} ]
			then
				i18n_display "not_current_repository" "[${origin_repo_name}]"
				cd ${origin_wd} 
			fi
		fi
    fi
}

################################################################################
# Function: Create a subdirectory.
################################################################################

function subdirectory_make
{
	local dir=${1}

	if [ -z ${dir} ]
	then
		i18n_display "missing_subdirectory"
	elif [ $(repository_root name) == "(none)" ]
    	then
		i18n_display "invalid_file_operation"
	else
        	origin_repo_name=$(repository_root name)
        	origin_wd=$(pwd)
 
		if [ -e ${dir} ] && [ -d ${dir} ]
		then
			i18n_display "subdirectory_exists"
		elif [ -e ${dir} ] && [ -f ${dir} ]
		then
			echo "file exists" 
		else
			sdir=""
			paths=($(echo ${dir} | sed -e 's/\// /g' | grep -oE '[A-Za-z0-9_-.]+'))
			for s in ${paths[@]}
			do
				sdir+="${s}/"
				if [[ ! -e ${sdir} ]]
				then
					mkdir ${sdir}
				fi
			done

        		cd ${dir}

        		destination_repo_name=$(repository_root name)

       			if [ ${origin_repo_name} != ${destination_repo_name} ]
       			then
           			i18n_display "not_current_repository"
       				rm -rf ${dir}
			else
				# necessary to force GitHub to create otherwise empty sundirectories.
				echo "# Ignore everything in this directory" > .gitignore
				echo "*" >> .gitignore
				echo "# Except this file" >> .gitignore
				echo "!.gitignore" >> .gitignore
			fi
			cd ${origin_wd}
		fi
    	fi
}

################################################################################
# Function: Display the name of the current working subdirectory.
################################################################################

function subdirectory_print_working 
{
	local repo_path="/"
	local wd
	local rb

	if [ $(pwd) != $(repository_base) ]
	then
		wd=($(echo $(pwd) | sed -e 's/\//\n/g'))
		rb=($(echo $(repository_base) | sed -e 's/\//\n/g'))
		for element in ${!wd[@]}
		do
			if [[ ${wd[$element]} != ${rb[$element]} ]]
			then
				if $(is_git_repository ${wd[$element]})
				then
					repo_path="/"
				else
					repo_path=${repo_path}/${wd[$element]}
				fi
			fi	
		done
	fi

	echo $(echo ${repo_path} | sed -e 's/\/\//\//g')
}

################################################################################
# Function: Clear the terminal console and display the Git Command Shell banner.
################################################################################

function terminal_clear
{
	clear
	banner
}

################################################################################
# Function: Trap Control-C to prevent accidental termination of the command
#           shell.
################################################################################

function trap_control_c()
{
	echo
	response=y 
	response=$(i18n_prompt "exit_gitshell_confirmation" ${response})

	if printf "%s" "${response}" | grep -Eq "$(locale yesexpr)"
	then
		exit_check	
	else
		# Stay in the shell...
		if [ $(repository_root name) == "(none)" ]
        	then
            		echo -n "gitsh:[]> "
        	else
            		echo -n "gitsh:[$(repository_root name)]> "
        	fi
	fi
}

################################################################################
# Function: Assign or retrieve the git user email.
################################################################################

function user_email
{
	local email=${1}

	if [ -z ${email} ]
	then
    		if [[ ! -z $(git config user.name) ]]
    		then
        		echo $(git config user.email)
    		else
        		echo -n ${USER}@${HOSTNAME}
        		if [ $(domainname) != "(none)" ]
        		then
            			echo .$(domainname)
        		fi
    		fi
	else
		git config --global user.email ${email}

	fi
}

################################################################################
# Function: Assign or retrieve the git user name.
################################################################################

function user_name
{
	local name=${1}

	if [ -z ${name} ]
	then
    		if  [[ ! -z $(git config user.name) ]]
    		then
        		echo $(git config user.name)
    		else
        		echo ${USER}
    		fi
	else
		git config --global user.name ${name}

	fi
}

################################################################################
#
#	Git Command Shell Environment
#
################################################################################


# Print the GitSHell version.
if [[ ${1} == "--version" ]]
then
    version
fi

# Set language preference with the following assumptions
# about language and country code format as indicated.
if [[ ${1} = "--lang" ]]
then
    export LC_ALL="$2_$3.UTF-8"
fi

export TEXTDOMAIN=gitsh.sh
I18NLIB=$(dirname $(which gitsh.sh))/gitshell/i18n-lib.sh
if [[ -f ${I18NLIB} ]]
then
    source ${I18NLIB}
else
    echo "ERROR - ${I18NLIB} NOT FOUND"
    exit 1
fi


trap trap_control_c SIGINT
terminal_clear
disclaimer
usage
initialise
command_processor
exit 0
