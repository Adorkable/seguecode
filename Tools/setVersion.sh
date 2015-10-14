#!/bin/sh

if [ -z "$1" ]
then
	echo "setVersion [version]" >&2
	exit -1
fi
version=$1

if [ -z "$2" ]
then
	root='../'
else
	root=$2
fi

echo "Set Version to $version, using root $root"

function updatePlist()
{
	if [ -z "$1" ]
	then
		echo "updatePlist() expects a version for first parameter" >&2
		return -1
	fi
	version=$1

	if [ -z "$2" ]
	then
		echo "updatePlist() expects a file name for second parameter" >&2
		return -1
	fi
	plistFile=$2

	# TODO: support both PlistBuddy and plutil, test for which available
	#PlistBuddy "$2" Set "CFBundleShortVersionString" "$1"
	if plutil -replace "CFBundleShortVersionString" -string "$version" "$root/$plistFile"
	then
		echo "Updated plist file $plistFile to version $version"
	else
		return -1
	fi

	return 0
}

plistFiles=("seguecodeBundle/Info.plist" "seguecodeKit/Info.plist" "seguecodePlugin/Info.plist")
for plistFile in ${plistFiles[@]}
do
	if !(updatePlist "$version" "$plistFile")
	then
		echo "Error while updatingPlist($version, $plistFile)" >&2
		exit -1
	fi
done

function updateSourceFile()
{
	if [ -z "$1" ]
	then
		echo "updatePlist() expects a version for first parameter"
		return -1
	fi
	version=$1

	sourceFile="seguecode/SeguecodeCLIApp.m"
	search="s/#define SegueCodeAppVersion @\"[0-9.]*\"/#define SegueCodeAppVersion @\"$version\"/g"
	if sed -i -e "$search" "$root/$sourceFile"
	then
		echo "Updated source file $sourceFile to version $version"
	else
		return -1
	fi
	return 0
}

if !(updateSourceFile "$version")
then
	echo "Error while updateSourceFile($version)" >&2
	exit -1
fi
