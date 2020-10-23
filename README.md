#  Ubuntu Linux docker container, SSH daemon running and an admin user.

Script to make creating a container on Linux a little simplier and quicker. Use container as development and/or testing environments.

## Example usage
docker_ubuntu_ssh_mini.sh --ssh_prvt_file ~/.ssh/work.pvt --ssh_publ_file ~/.ssh/work.pub --container_ext_ops "-p 8080:80 --dns 123.45.678.90 --dns 8.8.8.8"

## Parameters

`--container_ext_install <apt_package_name>` the extra apt packages to install

`--container_ext_ops <string>` extra args to pass to the container run

`--container_login <login>` is the login name of the system admin user, default `dev`

`--container_tz <tz>` is the container time zone, default `America/Chicago`

`--name <name>` is name used for: image, container. Default `dev`

`--passwd <passwd>` the backup password that will be used, default `pcfzmbuh`. Login via SSH by password is turned off by default. Change it.

`--ssh_host_port <port>` the port on the host machine to map to the containers SSH port, default `2223`
`--host_guest_port_mapping` '<host_port1>:<guest_port1>|<host_port2>:<guest_port2>' The host and guest port mappings,
example '2223:22|8080:80'. The first is the host port, the second is the
guest port and multiple host:guest port mapings if there are more than one
are seperated by a | If you do not have a map to guest port 22 you will
not be able to ssh into the container. Default is: 2223:22

`--ssh_prvt_file <file>` the file name that contains the SSH private key, default `~/.ssh/id_rsa`

`--ssh_publ_file <file>` the file name that contains the SSH public key, default `~/.ssh/id_rsa.pub`

`--version-linux ubuntu:XX.YY` the version of linux to use as the base, default ${VERSION_LINUX_BASE}, I hope you know what you are doing?

## Starting/Stopping/Connecting

To start the Container: `docker start <name>`
To stop the Container: `docker stop <name>`
To connect: `ssh -i <ssh_prvt_file> <login>@localhost -p <ssh_host_port>`

## X11 over SSH

The simplest way to display X11 apps on the host machine window, is to
install firefox (or some other X11 app, I chose firefox as it will include
a jdk and libraries for java apps) in the container with apt-get. Example:
`sudo apt-get -y install firefox`

Then connect to the container with the -Y or the -X flag. Example:
`ssh -Y -i <ssh_prvt_file> <login>@localhost -p <ssh_host_port>`
