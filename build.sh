#!/bin/bash

PACKAGE_INFO_FILE=".packageinfo"

getPackageInfoProperty() {
  grep "$1" "$PACKAGE_INFO_FILE" | cut -d'=' -f2
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

echo "Building the archives file..."

ARCHIVES=("acptemplates" "files" "style" "templates")
PACKAGE_ARCHIVES=$(getPackageInfoProperty "packageArchives" | tr ";" "\n")

if [ -n "$PACKAGE_ARCHIVES" ]; then
  ARCHIVES+=($PACKAGE_ARCHIVES)
fi

printf "%s\n" "${ARCHIVES[@]}" > "$BUILD_DIRECTORY/archives"

echo "Building the package..."

# Disable copying of *_ files on macOS.
export COPYFILE_DISABLE=1

tar --format=ustar --exclude-vcs --exclude="$BUILD_DIRECTORY" --exclude=build.sh --exclude-from="$BUILD_DIRECTORY/archives" -cvf "$BUILD_DIRECTORY/$PACKAGE_FILENAME" -- *

for ARCHIVE in "${ARCHIVES[@]}"; do
  ARCHIVE_FILENAME="${ARCHIVE}.tar"

  if [ -d "$ARCHIVE" ]; then
    (cd "$ARCHIVE" && tar --format=ustar --exclude-vcs -cvf "../$BUILD_DIRECTORY/$ARCHIVE_FILENAME" -- *)
    (cd "$BUILD_DIRECTORY" && tar --format=ustar -rvf "$PACKAGE_FILENAME" "$ARCHIVE_FILENAME")
  fi
done

echo "Finished building the package!"
exit 0
