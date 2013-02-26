#!/usr/bin/env bash

#########################################################
# Date: 2013/02/21
# Author: appleboy ( appleboy.tw AT gmail.com)
# Web: http://blog.wu-boy.com
#
# Program:
# Compress all css and js files
# before deploying your web project.
#########################################################

version="1.0"
print_version() {
    echo "Web build tool (c) 2013 by Bo-Yi Wu, version $version"
}

usage() {
    print_version
    echo
    echo "Usage: $0 [[-o | --output] output_folder] app_folder"
    echo "options:"
    echo "--output | -o output_folder set output build folder"
    echo "--version | -v              show version number"
    echo "--help | -h                 usage message"
    exit 0
}

command() {
    folder_name=$(dirname $0)
    echo "=> Please install command line tool first."
    echo "=> $ ${folder_name}/install.sh"
    exit
}

output() {
    case $2 in
        'ok')
            color="32"
            ;;
        'error')
            color="31"
            ;;
        *)
            color="33"
            ;;
    esac
    printf "\E[0;${color};40m"
    echo -n $1
    printf "\E[0m"
}

display() {
    echo -n "["
    output $2 $2
    echo -n "] compress the file: "
    output $1
    echo
}

which sqwish 1> /dev/null 2>&1
[ $? -ne 0 ] && command

which uglifyjs 1> /dev/null 2>&1
[ $? -ne 0 ] && command

# Process command line...
while [ $# -gt 0 ]; do
    case $1 in
        --help | -h)
            usage $0
            ;;
        --version | -v)
            print_version
            exit 0
            ;;
        --output | -o)
            shift
            output_folder=$1
            shift
            ;;
        *)
            app_folder=$1
            shift
            ;;
    esac
done

[ -z $app_folder ] && usage $0
app_folder=$(echo $app_folder | sed 's/\/+$//g')
[ -z $output_folder ] && output_folder=$app_folder

# copy all file to output folder if app_folder is not equal output_folder
if [ $app_folder != $output_folder ]; then
    [ -e $output_folder ] && rm -rf $output_folder
    cp -arv ${app_folder} ${output_folder}
fi

# find js file
file_list=$(find $output_folder -name '*.js')

for row in $file_list
do
    uglifyjs $row -m -o $row 1> /dev/null 2>&1
    if [ $? -ne 0 ]; then
        display $row "error"
    else
        display $row "ok"
    fi
done

# find css file
file_list=$(find $output_folder -name '*.css')

for row in $file_list
do
    sqwish $row -o $row 1> /dev/null 2>&1
    if [ $? -ne 0 ]; then
        display $row "error"
    else
        display $row "ok"
    fi
done