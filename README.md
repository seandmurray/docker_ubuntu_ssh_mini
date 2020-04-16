#  Ubuntu Linux docker container, SSH daemon running and an admin user.

Script to make creating a container on both Linux and Mac a little simplier and quicker. Use container as development and/or testing environments.

## Example usage
docker_ubuntu_ssh_mini.sh --ssh_prvt_file ~/.ssh/work.pvt --ssh_publ_file ~/.ssh/work.pub --container_ext_ops "--dns 123.45.678.90 --dns 8.8.8.8"

## Parameters

--container_ext_install <apt_package_name> the extra apt packages to install, format 'pkg1 pkg2'.

--container_ext_ops <string> extra args to pass in like "--dns 8.8.8.8 --dns x.x.x.x".

--container_ip <IP> is the IP we try and assign to the container, default ${CONTAINER_IP}"

--container_login <login> is the login name of the system admin user, default ${LOGIN}"

--container_tz <tz> is the container time zone, default ${CONTAINER_TZ}"

--name <name> is prefix name applied to the all image, container and vm(mac only), default ${NAME}"

--passwd <passwd> the backup password that will be used, default ${DEFAUL_PASSWD}"

--ssh_host_port <port> the port on the host machine to map to the containers SSH port, default ${SSH_HOST_PORT}"

--ssh_prvt_file <file> the file name that contains the SSH private key, default ${SSH_PRVT_FILE}"

--ssh_publ_file <file> the file name that contains the SSH public key, default ${SSH_PUBL_FILE}"

## X11 over SSH

The simplest way to display X11 apps on the host machine window,
is to install firefox (or some other X11 app) in the container with
apt-get. Example:
`sudo apt-get -y install firefox`

Then connect to the container with the -Y or the -X flag. Example:
`ssh -Y -i /ssh/private.file <admin_name>@container_ip -p container_port`

## Mac

To run just a command line version on a MAC requires *homebrew* https://brew.sh/
Homebrew will install the following (if not already installed):
  * VirtualBox https://www.virtualbox.org/
  * docker-machine https://github.com/docker/machine
  * docker https://www.docker.com/

If you want use X11 apps from inside the container to display on MAC you will also need:
  * XCode (install from the Apple store)
  * Xquartz (install using `brew cask install xquartz`)
