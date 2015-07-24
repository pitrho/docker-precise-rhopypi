#!/bin/bash

# Custom die function.
#
die () { echo >&2 -e "\nRUN ERROR: $@\n"; exit 1; }


usage()
{
  echo "usage: ./up.sh [-a \"<pypiserver options>\"]";
  echo "Starts the pypiserver, with the option of mounting an S3 as the repository location"
  echo "To mount an S3 bucket, make sure to set the environment variables S3_BUCKET_NAME, AWSACCESSKEYID and AWSSECRETACCESSKEY.";
}

ARGS="-p 5000 /packages"

# Parse command line ARGS
while getopts "ha:" opt; do
  case $opt in
    a)
      ARGS=${OPTARG}
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

# Mount the S3 bucket
#
if [[ ! -z "$S3_BUCKET_NAME" && ! -z "$AWSACCESSKEYID" && ! -z "$AWSSECRETACCESSKEY" ]]
then
  s3fs $S3_BUCKET_NAME /packages

  if [ "$?" = "1" ]; then
    die "Could not mount S3 bucket $S3_BUCKET_NAME"
  fi
fi


# Run the pypiserver
pypi-server $ARGS
