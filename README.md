# postgres-docker-watch

This repository is a sample repository for me to document the how (and the why) of running a Postgres database in a container, and having that container auto-update when a change occurs.

## Prerequisites
* Docker and Docker compose installed on your system

That's it. Hopefully.

## Usage/Workflow
The workflow for using this repository is relatively simple:

1. Clone this repository (`git clone https://github.com/porterdarby/auto-postgres-dev.git` or `git clone git@github.com:porterdarby/auto-postgres-dev.git`)
2. Navigate into the directory
3. Start the services with the `--watch` flag (i.e. `docker compose up --build --watch`). You should see the database container and the Adminer container start up.
4. Modify the contents of the `db` directory with whatever you want. The scripts that you put in will be in the order they are in the directory, so be careful. I personally use numbers to prefix my files to make sure they run in a specific order. 
5. Watch the Postgres container re-build itself and show you if something goes wrong! Use the Adminer interface (`localhost:8080`) to view the contents of the database.

## F.A.Q.
### Q. Why make this?
I'm a fan of building out little composable aspects of projects -- this is one of them. I've found myself at various times wanting to stub out databases and start loading in data, and instead of just messing with a database directly, I'd prefer to save my work in `.sql` files. I could just keep dropping and re-creating the tables as I want, but when I start making multiple inter-connected tables with data and views, I quickly don't want to continually iterate on modifying a database. With this sort of setup, I can create the database structure and test it in a hot-reload context.

### Q. Why use docker compose's watch functionality?
Mostly because I wanted to use it, and I wanted to see if I could solve this problem. I've seen a number of projects using watch commands, and I thought having a good, reusable tool that uses Docker's watch command would be beneficial. Being able to have a watch command exist for _everything_ that you write (in Docker containers) can give you real flexibility in terms of quickly prototyping applications.

### Q. Why did you override the `PGDATA` environment variable?
Go comment that line out, start the project, stop it (Ctrl + C), and then restart it. See what happens. I'll wait.

Welcome back. For those of you who didn't go try it out, this is the warning that you get when you don't have that line:

> `custom-db-1  | PostgreSQL Database directory appears to contain a database; Skipping initialization`

The error boils down to the Postgres database recognizing that a database already exists. Why does it exist? Because the Postgres image creates an [anonymous volume](https://docs.docker.com/engine/storage/volumes/#named-and-anonymous-volumes). Per the documentation:

> Just like named volumes, anonymous volumes persist even if you remove the container that uses them, except if you use the `--rm` flag when creating the container, in which case the anonymous volume associated with the container is destroyed.

That's the problem. In this scenario, we want to re-build the Docker image and re-deploy the container whenever a change is noticed. I haven't been able to find any indication of how to _remove_ a `VOLUME` directive from a container, so in lieu of someone pointing me to appropriate documentation, we need to have the anonymous volume not matter.

If we look at how the image is created, it helpfully [volumizes exactly the `/var/lib/postgresql/data` path](https://github.com/docker-library/postgres/blob/172d9e7dbcff681ed65899f9bb01ba8bcc5fc063/17/alpine3.22/Dockerfile#L196). 3 lines above that, we can see the [`PGDATA` environment variable being set](https://github.com/docker-library/postgres/blob/172d9e7dbcff681ed65899f9bb01ba8bcc5fc063/17/alpine3.22/Dockerfile#L193). From there, we can deduce that the default data directory is `/var/lib/postgresql/data` which is `PGDATA`, we should be able to override the `PGDATA` environment variable and have the data store out to a different location, stopping the database directory from persisting through restarts and forcing the database to re-initialize every time.
