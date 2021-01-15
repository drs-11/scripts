#! /bin/bash

# Solution to: https://tldp.org/LDP/abs/html/writingscripts.html (Safe Delete)

SOURCE_PATH="$PWD/$(basename $BASH_SOURCE)"
SOURCE_NAME="sdel"	# TODO: remove this hardcoded variable

# check if trash dir exists otherwise create it
if [ ! -d "$HOME/trash" ] ; then
	mkdir "$HOME/trash"
fi

# check if cron contains trash cleanup; otherwise add it
if ! crontab -l | grep "$SOURCE_NAME clean" >/dev/null ; then
	crontab -l > temp >/dev/null
	# run every Sunday at 10 pm
	echo "0 22 * * sun \"$SOURCE_NAME\" clean" >> temp
	crontab temp
	rm temp
fi

# clean trash
clean () {
	# get time now
	NOW=(date "+%s")

	if [ -d "$HOME/trash" ] ; then
		for file in "$HOME/trash"/* ; do
			# get file's last modified time
			FILE_NOW=(date -r "$file" "+%s")

			# if file older than 48 hours(48*60*60 seconds) then delete file
			if [ $(($NOW-$FILE_NOW>48*60*60)) ] ; then
				rm "$file"
			fi
		done
	fi
}

# sdel file
sdel_file () {
	# compress file if not already compressed
	if file "$1" | grep -i "compressed" ; then
		COMPR="$1"
	else
		gzip "$1"
		COMPR="$1.gz"
	fi

	# move compressed file to trash
	mv "$COMPR" "$HOME/trash/"
}

# sdel dir
sdel_dir () {
	path=$1
	if [ -d "$path" ] ; then
		for i in "$path/"*
		do
			sdel_dir "$i"
		done
	elif [ -f "$path" ] ; then
		sdel_file "$path"
	fi

	# delete empty dir  <-- broken fix this
	if [ -d "$path" ] ; then
		rmdir "$path"
	fi
}


if [ "$1" = "clean" ] ; then
	clean
elif [ -d "$1" ] ; then
	sdel_dir "$1"
else
	sdel_file "$1"
fi

