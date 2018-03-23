
#### Version Number
${version-number}

#### New Features
- The image has been renamed to "opensuse-base" as it contains more than just Tini now.
- PostgreSQL Client is now pre-installed in the base image.
- The `check-create-pgdb.sh` script has been added to the startup.d folder  
This script enables consumers of this image to define a PostgreSQL database that will be created when the container starts up.

#### Known Issues
