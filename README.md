# wsjtx_docker

## USO

docker run -it --device /dev/snd:/dev/snd -v /tmp/.X11-unix:/tmp/.X11-unix -e DISPLAY=unix:0 CesarGallego/wsjtx
