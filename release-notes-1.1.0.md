#### Version Number
${version-number}

#### New Features
 - Image renamed to "opensuse-base"  
    The image has been renamed to "opensuse-base" to reflect that it is intended for use as a general service base image and includes
    facilities other than just Tini.

 - PostgreSQL Client pre-installed  
    The PostgreSQL Client, `psql`, is now pre-installed.

 - The `check-create-pgdb.sh` script has been added to the startup.d folder  
    This script enables consumers of this image to define a PostgreSQL database that will be created when the container starts up.

#### Known Issues
 - None
