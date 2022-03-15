# Backend Server README

### Deployment

Deploying the server for personal development and testing is very simple.

1. Install [Docker](https://www.docker.com/)
2. Open a terminal and change its working directory to `./server/` (aka this directory)
3. Deploy the container by doing `docker-compose up -d --build`
4. Wait for it to finish building
5. Once it's done building, the website will be available on `localhost:8000`

### Setting up a new superuser

In order to create a new superuser (for testing purposes, and for using `/admin/`):

1. Type `docker ps` in your terminal.
2. Take note of the `CONTAINER ID` of the image `server_web`
3. Type `docker exec -it <container_id> bash`
4. Type `cd PusoyDosOnline`
5. Type `python manage.py createsuperuser`
6. Follow the steps with the appropriate credentials
7. Exit the shell and login with the credentials you just put in on `localhost:8000/admin/`
