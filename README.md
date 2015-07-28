# Docker Precise pypiserver
This repository contains a `Dockerfile` for building a python package server
using [pypiserver](https://pypi.python.org/pypi/pypiserver). In addition, the
image allows for mounting an AWS S3 bucket as the repository location for the
packages.

## How it works?
The image uses an embedded shell script called up.sh. The script is used to
mount the S3 bucket and start the pypiserver on port 5000. In addition, the
up.sh script accepts an optional argument flag named -a. This flag is used to
pass options to the pypiserver as describe in its documentation.

## Configuration

### Password protection using htpasswd
The pypiserver uses htpasswd to protect access to the package server. Therefore,
you must create an .htaccess file. This can be done by using the apache2-utils
package.

### Mounting the S3 Bucket
In order for the image to properly mount an S3 bucket, the underlaying kernel
must support the [FUSE](http://fuse.sourceforge.net/) filesystem. Also, the
following environment variables must be passed to the image:

  * S3_BUCKET_NAME: The top-level name of your S3 bucket.
  * AWSACCESSKEYID: The access key id from the IAM profile.
  * AWSSECRETACCESSKEY: The secret access key from the IAM profile.


## Building the image

Clone the repository

    export IMGTAG="pitrho/rhopypi"
    git clone https://github.com/pitrho/docker-rhopypi.git
    cd docker-rhopypi

Now, you can build the image using the standard docker build command:

    docker build -t $IMGTAG .

Or you can use the build.sh script that comes with the repository. This command
will also walk you through the steps of creating the .htaccess file. Therefore,
we recommend that you use this method for building the image.

    ./build.sh

The build.sh script accepts the following options

    ./build.sh -h
    usage: ./build.sh [OPTIONS]
    Creates the .htaccess file and builds the docker image.
    Options:
    -h      Display this menu
    -p      The password associated with the .htaccess file
    -t      The tag name of the image. (e.g pitrho/rhopypi:latest)
    -u      The username associated with the .htaccess file

As you can see from above, you can automatically pass the image tag name, as
well as the username and password associated with the .htaccess file. This is
beneficial when using automated build systems. Also, if you don't like passing
the username or password to the script using the -u and -p flags, you can still
pass them by setting the environment variables HTUSERNAME and HTPASSWORD.

Verify you have the image locally

    docker images | grep "$IMGTAG"

## Running the image

Here's a configuration sample for docker-compose.

    rhopypi:
      image: pitrho/rhopypi
      command: bin/up.sh -a "-p 5000 -P .htaccess -a update,download,list /packages"
      ports:
        - "80:5000"
        privileged: true
        environment:
          S3_BUCKET_NAME: my-s3-bucket
          AWSACCESSKEYID: my-secret-key-id
          AWSSECRETACCESSKEY: my-secret-access-key
      volumes:
        - /home/vagrant/.htaccess:/home/rickybobby/.htaccess

Note from the docker-compose configuration above that we're passing the
.htaccess file to the image. This is not necessary if you use the build.sh.
