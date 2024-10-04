This repo deploys mixtapestudy.com from https://github.com/douglasryanadams/mixtapestudy

Review the [makefile](./makefile) for commands you might to deploy to your AWS instance.

For my own sanity, some aspects of this repo may be particular to my own preferences but not required. Your needs may differ from mine.

Example make command:

```bash
make validate
```

## Architecture

This website does not currently receive the load or require the available that demand a more elastic or resilient infrastructure. My main priority is keeping costs low, making updates easy, and being able to rebuild quickly in the rare instance of service interruptions.

### RDS PostgreSQL

TBD

### EC2 VM Instance

TBD


### Application Load Balancer or Network Load Balancer

TBD

# Set up

Make sure to run `make init` and `make validate` to get started.

You will also need to set up some files in `.priv` directory and configure your `~/.ssh/config` for Ansible to be able to reach your hosts.

The contents of `.priv`:

- The ssh private key for your server(s) (if you generated a new one)
- The Ansible inventory pointing to your hosts

