# Backend Server README

---

## Setting up your development environment

### .env file

In order for Django and the database to have the same credentials, a `.env` file must be created in this directory.
Docker uses this `.env` file to set the environment variables that will be used in initalization of the database and the server.

Currently, the `.env` file has the following format:

```env
DB_USER={database_user}
DB_PASS={database_password}
DB_NAME={database_name}
DJANGO_SECRETKEY={secret_key}
DJANGO_LOG_LEVEL=INFO
DJANGO_DEBUG=True
```

- All `DB_*` environment variables will be used by the PostgreSQL container upon initialization and the Django container to access the database. These must be constant from the first initialization to avoid duplicate databases from forming. If you're only developing `views.py` for game logic, you wouldn't need to touch this file once it's set up.
- In the production environment, `DJANGO_DEBUG` should always be set to `False` and `DJANGO_SECRETKEY` must be a secure key.
- In the development environment, `DJANGO_DEBUG` should probably be set to `True` for Django to return verbose error logs.
- The `.env` file is in `.gitignore`, so don't worry about your `.env` file being committed to the repository.

### Deployment

Deploying the server for personal development and testing is very simple.

1. Install [Docker](https://www.docker.com/)
2. Open a terminal and change its working directory to `./server/` (aka this directory)
3. Create the `.env` file (see above)
4. Deploy the container by doing `docker-compose up -d --build`
5. Wait for it to finish building
6. Once it's done building, the website will be available on `localhost:8000`

### Setting up a new superuser

In order to create a new superuser (for testing purposes, and for using `/admin/`):

1. Type `docker ps` in your terminal.
2. Take note of the `CONTAINER ID` of the image `server_web`
3. Type `docker exec -it <container_id> bash`
4. Type `cd PusoyDosOnline`
5. Type `python manage.py createsuperuser`
6. Follow the steps with the appropriate credentials
7. Exit the shell and login with the credentials you just put in on `localhost:8000/admin/`

---

## To-Do List

1. ~~`id`s should not be visible outside of self-profile view~~ **Done!**
2. `RegisterViewSet` should throttle registrations to at least once every 5 minutes
3. ~~`django-channels` integration to create websockets to the game~~ **Done!**
4. Integrate website to the main game logic (wins, losses, game logs)
5. Integrate Godot client to site root
6. Automate Godot client deployment
7. ~~Setup Redis for caching game and lobby states~~ **Done!**
8. Turn Websocket code from sync to async
9. ~~Proper authorization for lobby websocket code~~ **Done!**
10. Integrate Celery to clean up dangling lobbies and games
