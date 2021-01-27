# openSUSE Base image

This project builds an openSUSE-based image intended for use as a general service base image.

### Tini
[Tini](https://github.com/krallin/tini) is pre-installed in the container.  If the image entrypoint is not overwritten then it will be automatically used.

### PostgreSQL Client
[PostgreSQL Client](https://www.postgresql.org/docs/current/static/app-psql.html) is pre-installed in the container. psql is a terminal-based front-end to PostgreSQL. It enables you to type in queries interactively, issue them to PostgreSQL, and see the query results. Alternatively, input can be from a file or from command line arguments. In addition, psql provides a number of meta-commands and various shell-like features to facilitate writing scripts and automating a wide variety of tasks.

### DejaVu Fonts
[DejaVu Fonts](https://dejavu-fonts.github.io/) is pre-installed in the container. The DejaVu fonts are a font family based on the Bitstream Vera Fonts. Its purpose is to provide a wider range of characters while maintaining the original look and feel through the process of collaborative development.

### Startup Scripts
Any executable scripts added to the `/startup/startup.d/` directory will be automatically run each time the container is started (assuming the image entrypoint is not overwritten).

### Pre-Installed Startup Scripts

#### Certificate Installation
The image comes pre-installed with a startup script which provides a mechanism to extend the CA certificates which should be trusted.

### Pre-Installed Utility Scripts

#### Database Creation Script
The image comes pre-installed with a utility script which can be used to check if a PostgreSQL database exists and to create it if it does not.

When the script is called it must be passed an environment variable prefix for the service:

    /scripts/check-create-pgdb.sh SERVICE_

The script then reads the database details from a set of environment variables with the specified prefix:

| **Environment Variable**    |                                          **Description**                                               |
|-----------------------------|--------------------------------------------------------------------------------------------------------|
| `SERVICE_`DATABASE_HOST     | The host name of the machine on which the PostgreSQL server is running.                                |
| `SERVICE_`DATABASE_PORT     | The TCP port on which the PostgreSQL server is listening for connections.                              |
| `SERVICE_`DATABASE_USERNAME | The username to use when establishing the connection to the PostgreSQL server.                         |
| `SERVICE_`DATABASE_PASSWORD | The password to use when establishing the connection to the PostgreSQL server.                         |
| `SERVICE_`DATABASE_APPNAME  | The application name that PostgreSQL should associate with the connection for logging and monitoring.  |
| `SERVICE_`DATABASE_NAME     | The name of the PostgreSQL database to be created.                                                     |

### Changing the Image User
This image runs as the default root user. This is necessary as the root user will have the appropriate privileges to be able to run the startup scripts. However, you can change the user running within the image after the startup scripts have been run. The following steps describe how to do this.

1. Create a new `entrypoint.sh` script

   Create a new script named `entrypoint.sh` that will:
   - Call the original entrypoint to run the startup scripts. This step will be executed as the default root user, which is required.
   - Add a new user 
   - Run a supplied command (for example a `CMD` in the Dockerfile) as the new user:

   ```
   #!/bin/bash

   set -e

   # Call original entrypoint (as the default root user)
   /tini -s /startup/startup.sh

   # Add a new user.
   useradd --shell /bin/bash --system --user-group --create-home my-new-user

   # Run CMD in Dockerfile as the new user
   exec /usr/local/bin/gosu my-new-user "$@"
   ```

   Alternatively, if there is a existing user you would like to use, just leave out the step to add a new user:

   ```
   #!/bin/bash

   set -e

   # Call original entrypoint
   /tini -s /startup/startup.sh

   # Run CMD in Dockerfile as the existing user
   exec /usr/local/bin/gosu my-existing-user "$@"
   ```

2. Install [gosu](https://github.com/tianon/gosu/) and invoke the new `entrypoint.sh` script 

   In the `Dockerfile` of the image deriving from this base image, install the [gosu](https://github.com/tianon/gosu/) utility, and then override the `ENTRYPOINT` of the base image with a new `ENTRYPOINT` that will invoke `entrypoint.sh`:

   ```
   # Install gosu
   RUN    gpg --batch --keyserver hkps://keys.openpgp.org --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
      && curl -o /usr/local/bin/gosu -SL "https://github.com/tianon/gosu/releases/download/1.10/gosu-amd64" \
      && curl -o /usr/local/bin/gosu.asc -SL "https://github.com/tianon/gosu/releases/download/1.10/gosu-amd64.asc" \
      && gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu \
      && rm /usr/local/bin/gosu.asc \
      && chmod +x /usr/local/bin/gosu

   # Add and invoke entrypoint.sh
   ADD ./entrypoint.sh /usr/local/bin/entrypoint.sh
   RUN chmod +x /usr/local/bin/entrypoint.sh
   ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
   
   # The following CMD will be executed as the user defined in entrypoint.sh
   CMD ["whoami"]  
   ```
