#! /bin/bash

# Steps:
# 1) write sdel for single files first
# 2) extend to directories
# 3) extend to directories recursively
# 4) write a periodic trash deleter

# check if trash dir exists otherwise create it
if [ ! -d "$HOME/trash" ] ; then
	mkdir "$HOME/trash"
fi

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

	# delete empty dir
	if [ -d "$path" ] ; then
		rmdir "$path"
	fi
}


if [ -d "$1" ] ; then
	sdel_dir "$1"
else
	sdel_file "$1"
fi

