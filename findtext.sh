#!/bin/bash

# Author: Taylor Flatt
#
# Version 1 will find any files in ROOT_DIRECTORY whose content 
# matches PATTERN and will optionally run a program on that file 
# or simply print out the relative location of the file if 
# PROGRAM isn't supplied.
#
# Usage: ./findtext ROOT_DIRECTORY PATTERN [PROGRAM]

# Check for too few parameters.
if [[ $# < 2 ]]; then
    echo "Usage: findtext ROOT_DIRECTORY PATTERN [PROGRAM]"
    exit 1
fi

# Check for too many parameters.
if [[ $# > 3 ]]; then
	echo "Usage: findtext ROOT_DIRECTORY PATTERN [PROGRAM]"
	exit 1
fi

# Assign names to the parameters.
rootdirectory=$1
pattern=$2
found=false

# If PROGRAM is given, then we need to give it a name and store 
# the absolute path prior to moving directories.
if [[ $# -eq 3 ]]; then
	program=$3
	if ! absprogdirectory=$(realpath "$program" 2> /dev/null); then
		echo "$program: The program that you have specified cannot be found."
		exit 1
	fi
fi

# Move into the directory that they supplied.
if ! cd "$rootdirectory" &> /dev/null; then
	echo "Error attempting to enter the directory supplied. Are you sure that is the correct path or that  \"$rootdirectory\" is a directory?"
	exit 1
fi

# If the PROGRAM parameter was not used (2 parameters), we need 
# to print out the relative path of the file to ROOT_DIRECTORY.
if [[ $# -eq 2 ]]; then
	for file in .* *; do
		if  grep -q "$pattern" "$file" 2> /dev/null; then
			found=true
			echo "./$file"
		fi
	done

# If the PROGRAM parameter is used (3 parameters), we need to call the program
# with the full path of a matched file as the only input.
else
	for file in .* *; do
		if  grep -q "$pattern" "$file" 2> /dev/null; then
			found=true
			scriptcommand="$absprogdirectory $(pwd)/$file"
			sh $scriptcommand
		fi
	done
fi

# If nothing was found, let the user know.
if ! "$found" -eq true; then
	echo -e "$pattern: Did not match the contents of any file in the search directory."
fi

exit 0

# EOF
