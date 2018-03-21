
# Overview
Docker development tools template container.

Includes recent versions of:
- Node 8.10
- Python 2.7
- ngrok (latest stable)
- Postgres Client 9.5
- AWS cli (latest stable)
- Oracle Java 8
- Scala 2.12

# Getting Started
## Build container
```bash
make build
```

## Run shell
```bash
make run
```

## Run container
```bash
docker run -ti --name dev-container sebastianleks/dev-template:1.0.2 bash
```

# Container Directory Mappings
AWS_WORKSPACE_DIR := "../aws-wrkspace"
PROJECTS_DIR := "../projects"


# Standalone Docker Commands
## Run node app
```bash
docker run node npm --loglevel=warn
```
# Attach to an existing instance shell
```bash
docker exec -i -t [container id]  /bin/bash
```


# Ngrok
## Install ngrok KEY
```bash
ngrok authtoken abcdefTOKEN...
```
## start ngrok
```bash
ngrok http 8080 -config=/root/.ngrok2/ngrok.yml
```
## use custom subdomain abc123.ngrok.io
```bash
ngrok http -subdomain=abc123 8080
```

# AWS CLI
## Coonfigure AWS keys
key storage ../aws-keys
volume mapping: [-v /host/directory:/container/directory]

configure command: aws configure

## Run aws commands with given profile
aws s3 ls --profile my-profile1

## Set default profile
export AWS_DEFAULT_PROFILE=my-profile1

# Dev cli tools
## Homebrew
https://brew.sh/
## Hub
https://github.com/github/
## Tig
https://github.com/jonas/tig
## pgCli
https://github.com/dbcli/pgcli
## Glances
https://nicolargo.github.io/glances/
## HTTPIE
https://github.com/jakubroztocil/httpie
## JQ
https://stedolan.github.io/jq/
## doitlive
https://github.com/sloria/doitlive




# References
[Uses official Node image](https://github.com/nodejs/docker-node)

[Markdown cheatsheet](https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet)

[Node on Docker notes](https://webapplog.com/node-docker/)

[Docker commands cheatsheet](https://gist.github.com/bahmutov/1003fa86980dda147ff6)

[JSON on command line](https://stedolan.github.io/jq/)

