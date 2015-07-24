#!/bin/bash

# Custom die function.
#
die () { echo >&2 -e "\nRUN ERROR: $@\n"; exit 1; }

usage()
{
  echo "usage: ./build.sh [OPTIONS]";
  echo "Creates the .htaccess file and builds the dokcer image."
  echo "Options:";
  echo "-h      Display this menu"
  echo "-p      The password associated with the .htaccess file"
  echo "-t      The tag name of the image. (e.g pitrho/rhopypi:latest)"
  echo "-u      The username associated with the .htaccess file"
}

TAG_NAME=pitrho/rhopypi:latest

# Parse the command line flags.
#
while getopts ":p:t:u:h" opt; do
  case $opt in
    u)
      HTUSERNAME=${OPTARG}
      ;;
    t)
      TAG_NAME=${OPTARG}
      ;;
    p)
      HTPASSWORD=${OPTARG}
      ;;
    h)
      usage
      exit 0;
      ;;
    \?)
      die "Invalid option: -$OPTARG"
      ;;
  esac
done

# Check that htpasswd is installed
HTPASSWD=$(command -v htpasswd || die "htpasswd is not in your path or not installed")

# Generate the .htaccess file
HTUSER="${HTUSERNAME:=rickybobby}"
if [[ -z "$HTPASSWORD" ]]
then
  htpasswd -sc .htaccess $HTUSER
else
  htpasswd -scb .htaccess $HTUSER $HTPASSWORD
fi

docker build -t $TAG_NAME .

rm .htaccess

echo "Done!"
