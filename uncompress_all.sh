#! /bin/bash


uncompress () {
	for file in "$1"/*; do
		if file "$file" | grep 'Zip' >/dev/null ; then
			echo "unzipping $file..."
			unzip "$file" >/dev/null
		elif file "$file" | grep -E 'gzip|bzip2' >/dev/null ; then
			echo "untarring $file..."
			tar -xf "$file" >/dev/null
		else
			echo "$file not an archive or unsupported archive"
		fi
	done
}

if [[ $1 == "" ]]; then
	uncompress .
else
	uncompress "$1"
fi
