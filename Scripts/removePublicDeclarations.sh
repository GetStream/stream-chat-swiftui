#!/usr/bin/env bash
#
# Usage: ./removePublicDeclarations.sh Sources/StreamNuke
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

	# Nuke
	if [[ $directory == *"Nuke"* ]]; then
		replaceDeclaration 'var log' 'var nukeLog' $f
		replaceDeclaration 'log =' 'nukeLog =' $f
		replaceDeclaration 'log: log' 'log: nukeLog' $f
		replaceDeclaration 'signpost(log' 'signpost(nukeLog' $f
		replaceDeclaration ' Cache(' ' NukeCache(' $f
		replaceDeclaration ' Cache<' ' NukeCache<' $f
		replaceDeclaration ' Image?' ' NukeImage?' $f
		replaceDeclaration ' Image(' ' NukeImage(' $f
		replaceDeclaration 'struct Image:' 'struct NukeImage:' $f
		replaceDeclaration 'extension Image {' 'extension NukeImage {' $f
		replaceDeclaration 'Content == Image' 'Content == NukeImage' $f
		replaceDeclaration ' VideoPlayerView' ' NukeVideoPlayerView' $f
		replaceDeclaration 'typealias Color' 'typealias NukeColor' $f
		replaceDeclaration 'extension Color' 'extension NukeColor' $f
		replaceDeclaration 'AssetType' 'NukeAssetType' $f
		replaceDeclaration 'typealias ImageRequest = Nuke.ImageRequest' '' $f
		replaceDeclaration 'typealias ImageResponse = Nuke.ImageResponse' '' $f
		replaceDeclaration 'typealias ImagePipeline = Nuke.ImagePipeline' '' $f
		replaceDeclaration 'typealias ImageContainer = Nuke.ImageContainer' '' $f
		replaceDeclaration 'open class ' '' $f
		replaceDeclaration 'import Nuke' '' $f

		# Remove Cancellable interface duplicate
		if [[ $f == *"DataLoader"* && `head -10 $f` == *"protocol Cancellable"* ]]; then
			`sed -i '' -e '7,11d' $f`
		fi

		# Rename files
		if [[ $f == *"Caching/Cache.swift" ]]; then
			new_f="${f/Cache.swift/NukeCache.swift}"
			mv "$f" "$new_f"
		elif [[ $f == *"NukeUI/VideoPlayerView.swift" ]]; then
			new_f="${f/VideoPlayerView.swift/NukeVideoPlayerView.swift}"
			mv "$f" "$new_f"
		fi
	fi
done
