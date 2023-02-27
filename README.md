# patent-explorer

Shiny app to explore patent data of innovation group.

# Docker

To build:
`docker build --tag docker.kof.ethz.ch/kof/patent-explorer:<tag> .`

Run locally:
`docker run -p 8080:3838 docker.kof.ethz.ch/kof/patent-explorer:<tag>`

To push to KOF registry:
`docker push docker.kof.ethz.ch/kof/patent-explorer:<tag>`

## Deploy
After building and pushing the new image, go to portainer, select the container,
Edit, choose new image, Deploy.