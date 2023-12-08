# Commands to build and push to docker hub

# ARM Architecture
```bash
export DOCKER_BUILDKIT=1
docker buildx create --name mybuilder --use
docker buildx inspect --bootstrap
docker buildx build --platform linux/arm/v7 -t [your-docker-hub-username]/mc-player-activity-monitor:latest .
docker buildx build --platform linux/arm/v7 -t [your-docker-hub-username]/mc-player-activity-monitor:latest . --push
```