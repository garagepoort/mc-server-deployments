# Introduction

MCSD is a small script created for bukkit server configuration git repositories.
It supports using ENV variables inside configuration files and can create and run the server with one simple command.
This eases development of mc servers.

## Installation

Run the following command:

### Linux
```
sudo curl -Lo- "https://raw.githubusercontent.com/garagepoort/mc-server-deployments/master/setup.sh" | bash
```

### Windows

To run mcsd on windows you need a linux terminal. I recommend using git bash as it is installed automatically with a default git installation on Windows.

- Open Git Bash as administrator. Run the following command:
```
curl -Lo- "https://raw.githubusercontent.com/garagepoort/mc-server-deployments/master/setup.sh" | sudo bash
```

## Commands
```
mcsd init | create the files needed for a mcsd repository. Use this if you want to create a repository from scratch
mcsd install | copy everything from server_source to server_dist and replace environment variables.
mcsd run | start the minecraft server. Make sure to have 
mcsd ir | short form for running `mcsd install` and `mcsd run` in one command
mcsd deploy <branchname> <directory> | deploy a branch into a given directory. The given directory should exist and contain the .env file 
```

## Source Files

You will notice there is a directory called "server_source". This directory contains all the configuration files for the server.
The server_source directory should only contain configuration files. No .db, .dat or any file that contains player specific data should be added here.

## .env file
This files contains all the necessary properties which need to injected into the server configuration files.
If you want to run the server repository locally, you will need to create one.
The .env file should always be added to the .gitignore file as it contains credentials.

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
- Add the path to that configuration file inside the .envfiles file. (make sure the last line of the file is always an empty line.)
