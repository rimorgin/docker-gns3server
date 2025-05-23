# docker-gns3server

This repository provides a Dockerized setup for running a GNS3 server. GNS3 (Graphical Network Simulator-3) is a powerful network emulator that enables the simulation of complex network topologies. Unlike the repository [jsimonetti/docker-gns3-server](https://github.com/jsimonetti/docker-gns3-server), which uses Alpine Linux, this version is based on Ubuntu, allowing it to support Cisco IOU images seamlessly. 

## Getting Started

1. Run the Docker container:

 Recommended to use network <mark>host</mark> or <mark>macvlan</mark> because if you don't, you gonna have to expose all ports yourself.

 Enter valid ip address with prefix length for <mark>BRIDGE_ADDRESS</mark> (e.g. 172.21.1.1). The prefix length is fixed to be 24

 To run IOUs in the gns3 server, you have to provide your own license and import it to `/data/iourc`

  ```bash
  docker run --rm -d --privileged --name gns3 --cap-add NET_ADMIN -h gns3vm --net host -e BRIDGE_ADDRESS=172.21.1.1/24 -e SSL=true -v $(pwd)/data:/data  rimorgin/gns3server
  ```

2. Access the GNS3 server via your browser at `http://localhost:3080`.
