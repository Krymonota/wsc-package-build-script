#!/bin/bash

PACKAGE_INFO_FILE=".packageinfo"

function getPackageInfoProperty {
  PROPERTY_KEY=$1
  PROPERTY_VALUE=$(grep "$PROPERTY_KEY" "$PACKAGE_INFO_FILE" | cut -d'=' -f2)

  echo "$PROPERTY_VALUE"
}

echo "Starting to build the package..."
echo "Reading the ${PACKAGE_INFO_FILE} file..."

if [ ! -f "$PACKAGE_INFO_FILE" ]; then
  echo "The ${PACKAGE_INFO_FILE} file does not exist, but it required to build the package."
  exit 1
fi

PACKAGE_IDENTIFIER=$(getPackageInfoProperty "packageIdentifier")

if [ -z "$PACKAGE_IDENTIFIER" ]; then
  echo "Please specify a valid packageIdentifier property in the ${PACKAGE_INFO_FILE} file."
  exit 1
fi

BUILD_DIRECTORY="build"
PACKAGE_FILENAME="${PACKAGE_IDENTIFIER}.tar"

echo "Cleaning up build directory..."
rm -rf $BUILD_DIRECTORY
mkdir -p $BUILD_DIRECTORY

echo "Building the archives file...";

ARCHIVES=("acptemplates" "files" "style" "templates");
PACKAGE_ARCHIVES=$(getPackageInfoProperty "packageArchives" | tr ";" "\n")

if [ -n "$PACKAGE_ARCHIVES" ]; then
  for PACKAGE_ARCHIVE in $PACKAGE_ARCHIVES; do
    ARCHIVES+=("$PACKAGE_ARCHIVE")
  done;
fi;

printf "%s\n" "${ARCHIVES[@]}" > ./$BUILD_DIRECTORY/archives

echo "Building the package..."

tar --exclude-vcs --exclude=$BUILD_DIRECTORY --exclude=build.sh --exclude-from=./$BUILD_DIRECTORY/archives -cvf ./$BUILD_DIRECTORY/"$PACKAGE_FILENAME" -- *

for ARCHIVE in "${ARCHIVES[@]}"; do
  ARCHIVE_FILENAME="${ARCHIVE}.tar"

  if [ -d "$ARCHIVE" ]; then
    cd "$ARCHIVE" && tar --exclude-vcs -cvf ../$BUILD_DIRECTORY/"$ARCHIVE_FILENAME" -- * && cd - || exit
    cd $BUILD_DIRECTORY && tar -rvf "$PACKAGE_FILENAME" "$ARCHIVE_FILENAME" && cd - || exit
  fi
done;

echo "Finished building the package!"
exit 0
