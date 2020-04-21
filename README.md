#  Ubuntu Linux docker container, SSH daemon running and an admin user.

Script to make creating a container on both Linux and Mac a little simplier and quicker. Use container as development and/or testing environments.

## Example usage
docker_ubuntu_ssh_mini.sh --ssh_prvt_file ~/.ssh/work.pvt --ssh_publ_file ~/.ssh/work.pub --container_ext_ops "--dns 123.45.678.90 --dns 8.8.8.8"

## Parameters

`--container_ext_install <apt_package_name>` the extra apt packages to install, format 'pkg1 pkg2'.

`--container_ext_ops <string>` extra args to pass in like "--dns 8.8.8.8 --dns x.x.x.x".

`--container_ip <IP>` is the IP we try and assign to the container, default `172.17.0.1`

`--container_login <login>` is the login name of the system admin user, default `dev`

`--container_tz <tz>` is the container time zone, default `America/Chicago`

`--name <name>` is name used for: image, container and vm (Mac only), default `dev`

`--passwd <passwd>` the backup password that will be used, default `pcfzmbuh`. Login via SSH by password is turned off by default.

`--ssh_host_port <port>` the port on the host machine to map to the containers SSH port, default `2223`

`--ssh_prvt_file <file>` the file name that contains the SSH private key, default `~/.ssh/id_rsa`

`--ssh_publ_file <file>` the file name that contains the SSH public key, default `~/.ssh/id_rsa.pub`

## Starting/Stopping/Connecting

To start the Container: `docker start <name>`
To stop the Container: `docker stop <name>`
To connect: `ssh -i <ssh_prvt_file> <login>@<container_ip> -p <ssh_host_port>`

## X11 over SSH

The simplest way to display X11 apps on the host machine window, is to
install firefox (or some other X11 app, I chose firefox as it will include
a jdk and libraries for java apps) in the container with apt-get. Example:
`sudo apt-get -y install firefox`

Then connect to the container with the -Y or the -X flag. Example:
`ssh -Y -i <ssh_prvt_file> <login>@<container_ip> -p <ssh_host_port>`

## Mac only

To run just a command line version on a MAC requires *homebrew* https://brew.sh/
Homebrew will install the following (if not already installed):
  * VirtualBox https://www.virtualbox.org/
  * docker-machine https://github.com/docker/machine
  * docker https://www.docker.com/

Use docker-machine to start and stop the VM hosting the containers.
To start the VM: `docker-machine start <name>`
To stop the VM: `docker-machine stop <name>`
*IMPORTANT* after you start the VM run this command, otherwise docker will not find the VM and containers.
`eval $(docker-machine env ${NAME})`

If you want use X11 apps from inside the container to display on MAC you will also need:
  * XCode (install from the Apple store)
  * Xquartz (install using `brew cask install xquartz`)
