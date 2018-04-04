# openSUSE Base image

This project builds an openSUSE-based image intended for use as a general service base image.

### Tini
[Tini](https://github.com/krallin/tini) is pre-installed in the container.  If the image entrypoint is not overwritten then it will be automatically used.

### PostgreSQL Client
[PostgreSQL Client](https://www.postgresql.org/docs/current/static/app-psql.html) is pre-installed in the container. psql is a terminal-based front-end to PostgreSQL. It enables you to type in queries interactively, issue them to PostgreSQL, and see the query results. Alternatively, input can be from a file or from command line arguments. In addition, psql provides a number of meta-commands and various shell-like features to facilitate writing scripts and automating a wide variety of tasks.

### Startup Scripts
Any executable scripts added to the `/startup/startup.d/` directory will be automatically run each time the container is started (assuming the image entrypoint is not overwritten).

### Pre-Installed Startup Scripts

#### Certificate Installation
The image comes pre-installed with a startup script which provides a mechanism to extend the CA certificates which should be trusted.

### Pre-Installed Utility Scripts

#### Database Check and Create Script
The image comes pre-installed with the `/scripts/check-create-pgdb.sh` script that enables consumers of this image to define a PostgreSQL database that will be created during startup of the consuming container. The script will also check if the database already exists and if so will not attempt to create it.

In order to utilise this script you need to call the script via a command and pass an environment variable prefix argument e.g. `/scripts/check-create-pgdb.sh ENV_PREFIX_`

The database details are configured by passing the following environment variables to the container. Note that the environment variable names contain the prefix value passed to the script as an argument:

| **Environment Variable** |                                                       **Description**                                                      |
|----------------------|------------------------------------------------------------------------------------------------------------------------|
| `ENV_PREFIX_`DATABASE_NAME      | The name of the PostgreSQL database to be created.                                                                       |
| `ENV_PREFIX_`DATABASE_HOST      | The host of the PostgreSQL instance where the database is to be created.                                                 |
| `ENV_PREFIX_`DATABASE_PORT      | The port of the PostgreSQL instance where the database is to be created.                                                 |
| `ENV_PREFIX_`DATABASE_USERNAME  | The PostgreSQL username to be used when creating the database.                                                           |
| `ENV_PREFIX_`DATABASE_PASSWORD  | The PostgreSQL password to be used when creating the database.                                                           |


