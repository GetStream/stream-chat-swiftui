#!/usr/bin/env bash
#
# Usage: ./removePublicDeclarations.sh Sources/StreamChatSwiftUI/StreamSwiftyGif
#
# This script would iterate over the files on a particular directory, and perform basic replacement operations.
# It heavily relies on 'sed':
#     sed -i '<backup-file-extension>' -e 's/<original-string>/<replacement>/g' <file>
#             ^
#             Passing empty string prevents the creation of backup files

args=("$@")
directory=$1

replaceDeclaration() {
	original=$1
	replacement=$2
	file=$3
	`sed -i '' -e "s/$original/$replacement/g" $file`
}

files=`find $directory -name "*.swift"`
for f in $files
do
	replaceDeclaration 'public internal(set) ' '' $f
	replaceDeclaration 'open ' '' $f
	replaceDeclaration 'public ' '' $f
done
