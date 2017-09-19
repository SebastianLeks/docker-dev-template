
# Overview
Docker development tools template container.

Includes recent versions of:
- Node (latest, 8.5)
- Python 2.7
- ngrok
- Postgres Client 9.5
- AWS cli

# Getting Started
## Build container
```bash
make build
```

## Run shell
```bash
make run
```

# Container Directory Mappings



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


# References
[Uses official Node image](https://github.com/nodejs/docker-node)

[Markdown cheatsheet](https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet)

[Node on Docker notes](https://webapplog.com/node-docker/)

[Docker commands cheatsheet](https://gist.github.com/bahmutov/1003fa86980dda147ff6)
