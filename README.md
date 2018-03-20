# openSUSE Base image

This project builds an openSUSE-based image which includes Tini, cURL and the PostgreSQL client.

### Tini
[Tini](https://github.com/krallin/tini) is pre-installed in the container.  If the image entrypoint is not overwritten then it will be automatically used.

### PostgreSQL Client
[PostgreSQL](https://wiki.postgresql.org/wiki/Main_Page) Client is pre-installed in the container. This enables projects to automatically install required PostgreSQL databases if required.

### Startup Scripts
Any executable scripts added to the `/startup/startup.d/` directory will be automatically run each time the container is started (assuming the image entrypoint is not overwritten).

### Certificate Installation
The image comes pre-installed with a startup script which provides a mechanism to extend the CA certificates which should be trusted.
