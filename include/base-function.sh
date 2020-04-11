#! /usr/bin/env bash

title() {
	echo -e "###### $1"
}

msg() {
    echo "$1"
}

yellow() {
	echo -e "\033[33m$1\033[0m"
}

green() {
	echo -e "\033[32m$1\033[0m"

}

red() {
    echo -e "\033[31m$1\033[0m"
}

##
# Ask the user to take an action (yes or no).
#   Arg : $0 [default_no|default_yes]
# Return 0 if enter default option, otherwise return 1
# Use :
#   ask_action default_no
#   if [ $? -eq 0 ]; then default_option; else other; fi
##
ask_action() {
    read action
    if [ "$1" == 'default_yes' ]; then
        if [ "${action}" == 'n' -o "${action}" == 'N' -o "${action}" == 'no' -o "${action}" == 'No' ]; then
            return 1
        fi
        return 0
    fi
    
    if [ "${action}" == 'y' -o "${action}" == 'Y' -o "${action}" == 'yes' -o "${action}" == 'Yes' ]; then
        return 1
    fi
    return 0
}

check_err() {
    if [ $? -ne 0 ]; then
        return 1
    fi
    if [ "$nbErr" != '' ]; then
        if [ $nbErr -gt 0 ]; then
            return 1
        fi
    fi
    return 0
}

check_cmd() {
    if [ $? -ne 0 ]; then
        ((nbErr++))
        return 1
    fi
    return 0
}
