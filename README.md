# Introduction

MCSD is a small script created for bukkit server configuration git repositories.
It supports using ENV variables inside configuration files and can create and run the server with one simple command.
This eases development of mc servers.

## Installation

Run the following command:

```
curl -Lo- "https://raw.githubusercontent.com/garagepoort/mc-server-deployments/master/setup.sh" | bash
```

## Commands
```
mcsd install | copy everything from server_source to server_dist and replace environment variables.
mcsd run | start the minecraft server. Make sure to have 
mcsd ir | short form for running `mcsd install` and `mcsd run` in one command
mcsd deploy <branchname> <directory> | deploy a branch into a given directory. The given directory should exist and contain the .env file 
```

## .env file
Before you can run the server you need to add a `.env` file in the root of your project.
You can just copy the `.env-example` file.
The .env contains all the environment specific properties. You will use this mostly for credentials.

## Source Files

You will notice there is a directory called "server_source". This directory contains all the configuration files for the server.
Basically at startup of the server these files will be copied to their correct location. For plugins the files will be copied to the `plugins` directory.

The server_source directory should only contain configuration files. No .db, .dat or any file that contains player specific data should be added here.

## Environment variables
The concept of environment variables is introduced. 
The use of variables resolves 2 issues. 
- Sometimes configuration can be different depending on the environment we run the server in local, dev, prod.
- We need to make sure sensitive information like database credentials etc doesn't get exposed.

Environment variables are stored inside a file named “.env”. This file is ignored by git.
In this file we need to place all our sensitive information or environment dependent information.

### Adding new variables.
- add your variable inside the .env-example file. This file has only an informational purpose.
- Use your environment variable inside the configuration file you need.
- Add the path to that configuration file inside the .env-files file. (make sure the last line of the file is always an empty line.)

More information on env variables can be found here: https://docs.google.com/document/d/1sSMr_pkasmBb7OfRowXDUczZgMY07AW3UtHU6O9aYiQ
