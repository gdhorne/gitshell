#!/bin/bash
##
# Thin library around basic I18N facilitated function
#   basic text display, file logging, error display, and prompting

export TEXTDOMAINDIR=/usr/share/locale

###############################################
##
## Display some text to stderr
## $1 is assumed to be the Message Catalog key
function i18n_error {
        echo "$(gettext -s "$1")" >&2
}

###############################################
##
## Display some text to sdtout
## $1 is assumed to be the Message Catalog key
## rest of args are used as misc information
function i18n_display {
        typeset key="$1"
        shift
        echo -e "$(gettext -s "$key") $@"
}

function i18n_display_nobreak {
        typeset key="$1"
        shift
        echo -e -n "$(gettext -s "$key") $@"
}

###############################################
## Append a log message to a file.
## use $1 as target file to append to
## use $2 as catalog key
## rest of args are used as misc information
function i18n_fileout {
        [[ $# -lt 2 ]] && return 1
        typeset file="$1"
        typeset key="$2"
        shift 2
        echo "$(gettext -s "$key") $@" >> ${file}
}

## Prompt the user with a message and echo back the response.
## $1 is assumed to be the Message Catalog key
function i18n_prompt {
        typeset rv=${2}
        [[ $# -lt 1 ]] && return 1
        read -e -i ${rv} -p "$(gettext "${1}") " rv
        echo $rv
}
