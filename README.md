# openSUSE Base image

This project builds an openSUSE-based image which includes Tini, cURL and the PostgreSQL client.

### Tini
[Tini](https://github.com/krallin/tini) is pre-installed in the container.  If the image entrypoint is not overwritten then it will be automatically used.

### PostgreSQL Client
[PostgreSQL Client](https://www.postgresql.org/docs/current/static/app-psql.html) is pre-installed in the container. psql is a terminal-based front-end to PostgreSQL. It enables you to type in queries interactively, issue them to PostgreSQL, and see the query results. Alternatively, input can be from a file or from command line arguments. In addition, psql provides a number of meta-commands and various shell-like features to facilitate writing scripts and automating a wide variety of tasks.

### Startup Scripts
Any executable scripts added to the `/startup/startup.d/` directory will be automatically run each time the container is started (assuming the image entrypoint is not overwritten).

### Pre-Installed Startup Scripts

#### Certificate Installation
The image comes pre-installed with a startup script which provides a mechanism to extend the CA certificates which should be trusted.

#### Database Check and Create Script
The image comes pre-installed with the `check-create-pgdb.sh` script that enables consumers of this image to define a PostgreSQL database that will be created during startup of the consuming container. The script will also check if the database already exists and if so will not attempt to create it.

The database details are configured by passing the following environment variables to the container:

| **Environment Variable** |                                                       **Description**                                                      |
|----------------------|------------------------------------------------------------------------------------------------------------------------|
| CAF_DATABASE_NAME      | The name of the PostgreSQL database to be created.                                                                       |
| CAF_DATABASE_HOST      | The host of the PostgreSQL instance where the database is to be created.                                                 |
| CAF_DATABASE_PORT      | The port of the PostgreSQL instance where the database is to be created.                                                 |
| CAF_DATABASE_USERNAME  | The PostgreSQL username to be used when creating the database.                                                           |
| CAF_DATABASE_PASSWORD  | The PostgreSQL password to be used when creating the database.                                                           |
| ENV_PREFIX             | This variable defines a custom prefix that can be added to each of the above variable names instead of the default `CAF_` |

**Note:** If you do not wish to utilise the create database functionality do not provide any of the listed Environment Variables and the script will not attempt to create a database.

