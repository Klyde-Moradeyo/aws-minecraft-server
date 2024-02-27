# Commands to build and push to docker hub

# ARM Architecture
```bash
docker buildx rm mybuilder-player-activity-monitor-arm64 \
&& docker buildx create --name mybuilder-player-activity-monitor-arm64 --use \
&& docker run --rm --privileged multiarch/qemu-user-static --reset -p yes \
&& docker buildx build --platform linux/arm/v7,linux/arm64/v8 -t klydem/mc-player-activity-monitor:arm64-latest . --push

docker buildx rm mybuilder-player-activity-monitor-amd64 \
&& docker buildx create --name mybuilder-player-activity-monitor-amd64 --use \
&& docker run --rm --privileged multiarch/qemu-user-static --reset -p yes \
&& docker buildx build --platform linux/amd64 -t klydem/mc-player-activity-monitor:amd64-latest . --push
```


