#### Version Number
${version-number}

#### New Features
- The base image is now based on [openSUSE Leap 15.3](https://en.opensuse.org/Portal:15.3).  
The release notes for openSUSE Leap 15.3 can be found [here](https://doc.opensuse.org/release-notes/x86_64/openSUSE/Leap/15.3/).
- SCMOD-14011: Updated to support file-based secrets  
  The image now comes pre-installed with a startup script which provides support for file-based secrets. It works by looking for
  environment variables ending with the _FILE prefix and setting the environment variable base name to the contents of the file. For
  example, given this environment variable ending in the _FILE suffix: `ABC_PASSWORD_FILE=/var/somefile.txt`, the script will read the
  contents of /var/somefile.txt (for example 'mypassword'), and export an environment variable named ABC_PASSWORD:
  `ABC_PASSWORD=mypassword`. This feature is disabled by default. To enable it, ensure a `USE_FILE_BASED_SECRETS` environment variable
  is present, with a value of `true`, for example, `USE_FILE_BASED_SECRETS=true`.

#### Known Issues
- None
