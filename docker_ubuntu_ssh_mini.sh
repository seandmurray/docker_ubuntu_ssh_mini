#!/bin/bash

CONTAINER_EXT_INSTALL=''
CONTAINER_EXT_OPS=''
CONTAINER_TZ='America/Chicago'
LOGIN='dev'
NAME=${LOGIN}
PASSWD=`cat /dev/urandom | tr -dc 'a-z' | fold -w 8 | head -n 1`
SSH_HOST_PORT=2223
SSH_PRVT_FILE="${HOME}/.ssh/id_rsa"
SSH_PUBL_FILE="${SSH_PRVT_FILE}.pub"
VERSION_LINUX_BASE='ubuntu:20.04'

function help {
  echo 'Script to build an Ubuntu container with a SSH daemon running and an Admin user.'
  echo 'Use it as a development enviroment or a test environment.'
  echo '--container_ext_install <apt_package_name> the extra apt packages to install, Example'
  echo '	--container_ext_install "firefox git htop jq maven zip"'
  echo '--container_ext_ops <string> extra args to pass to the container build, Example:'
  echo "	--container_ext_ops '-p 8080:80' map host port 8080 to container port 80"
  echo "	--container_ext_ops '--dns 8.8.8.8 --dns x.x.x.x', If you do not know what your doing, do not use this"
  echo "--container_login <login> is the login name of the system admin user, default ${LOGIN}"
  echo "--container_tz <tz> is the container time zone, default ${CONTAINER_TZ}"
  echo "--name <name> is prefix name applied to the: image, container. Default ${LOGIN}"
  echo "--passwd <passwd> the backup password that will be used. Otherwise will generate random password of form: ${PASSWD}"
  echo "--ssh_host_port <port> the port on the host machine to map to the containers SSH port, default ${SSH_HOST_PORT}"
  echo "--ssh_prvt_file <file> the file name that contains the SSH private key, default ${SSH_PRVT_FILE}"
  echo "--ssh_publ_file <file> the file name that contains the SSH public key, default ${SSH_PUBL_FILE}"
  echo "--version-linux ubuntu:XX.YY the version of linux to use as the base, default ${VERSION_LINUX_BASE}, I hope you know what you are doing?"
  exit 0
}

while true; do
  key=$1
  shift
  val=$1
  case "$key" in
    --help)
      help
    ;;
    --container_ext_install)
      CONTAINER_EXT_INSTALL=$val
    ;;
    --container_ext_ops)
      CONTAINER_EXT_OPS=$val
    ;;
    --container_login)
      LOGIN=$val
    ;;
    --container_tz)
      CONTAINER_TZ=$val
    ;;
    --name)
      NAME=$val
    ;;
    --passwd)
      PASSWD=$val
    ;;
    --ssh_host_port)
      SSH_HOST_PORT=$val
    ;;
    --ssh_prvt_file)
      SSH_PRVT_FILE=$val
    ;;
    --ssh_publ_file)
      SSH_PUBL_FILE=$val
    ;;
    --version-linux)
      VERSION_LINUX_BASE=$val
    ;;
    *)
      break
    ;;
  esac
  shift
done

# Exit if commands throw an error.
set -e

if [ ! -e "${CONTAINER_EXT_INSTALL}" ] ; then
  CONTAINER_EXT_INSTALL="RUN apt-get -y install ${CONTAINER_EXT_INSTALL}"
fi
if [ ! -e "${SSH_PRVT_FILE}" ] ; then
  echo 'Did not find SSH private key file!'
  help
fi
if [ ! -e "${SSH_PUBL_FILE}" ] ; then
  echo 'Did not find SSH public key file!'
  help
fi

# Interal values
IMAGE=${NAME}
CONTAINER=${NAME}
AUTH_KEY=`cat ${SSH_PUBL_FILE}`
_UID=1000
_GID=${_UID}
_HOME="/home/${LOGIN}"

echo "Image name: ${IMAGE}"
echo "Container login: ${LOGIN}"
echo "Container name: ${CONTAINER}"
echo "Container extra operations : ${CONTAINER_EXT_OPS}"
echo "Container Time Zone: ${CONTAINER_TZ}"
echo "Host SSH port: ${SSH_HOST_PORT}"
echo "Using SSH private key file: ${SSH_PVT_KEY_FILE}"
echo 'press any key to continue'
read

###########
# The data that will be written into a temp Dockerfile
DOCKER_TMPL=$(cat <<-EOF
FROM ${VERSION_LINUX_BASE}

# Set up the time zone to avoid answering awkward interactive questions.
ENV TZ='${CONTAINER_TZ}'
# Install the minimal set of required apps
RUN apt-get -y update && apt-get --with-new-pkgs -y upgrade
RUN apt-get -y install openssh-server tzdata sudo curl vim screen
RUN apt-get -y autoremove

# Set up ssh to run
RUN mkdir /var/run/sshd && sed -i 's/#X11UseLocalhost yes/X11UseLocalhost no/' /etc/ssh/sshd_config

# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

# Set up the root user
RUN echo 'root:${PASSWD}' | chpasswd
RUN mkdir -p /root/.ssh
RUN echo '${AUTH_KEY}' > /root/.ssh/authorized_keys

# Set up the admin user
RUN echo "${LOGIN}:x:${_UID}:${_GID}:Admin,,,:${_HOME}:/bin/bash" >> /etc/passwd
RUN echo "${LOGIN}:x:${_UID}:" >> /etc/group
RUN echo "${LOGIN}:${PASSWD}" | chpasswd
RUN mkdir -p /etc/sudoers.d && echo "${LOGIN} ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/${LOGIN}
RUN mkdir -p ${_HOME}/.ssh
RUN echo '${AUTH_KEY}' > ${_HOME}/.ssh/authorized_keys
RUN chmod 0444 ${_HOME}/.ssh/authorized_keys && chown ${_UID}:${_GID} -R ${_HOME}

# Run the command, we are using ssh to keep this docker image up and running indefinitly
CMD ["/usr/sbin/sshd", "-D"]

${CONTAINER_EXT_INSTALL}
EOF
)
###########
TMP_DIR=`mktemp -d`
cd ${TMP_DIR}
echo "${DOCKER_TMPL}" > Dockerfile
echo "Creating the Dockerfile: ${TMP_DIR}/Dockerfile"

echo "Stop the container ${CONTAINER}, if started"
set +e
docker stop ${CONTAINER} || true
echo "Remove container ${CONTAINER}, if exists"
docker rm ${CONTAINER} || true
echo "Remove image ${IMAGE}, if exists"
docker rmi ${IMAGE} || true
set -e

echo "Create image ${IMAGE}"
docker build -t ${IMAGE} ./

echo "Build container ${CONTAINER} from image ${IMAGE}"
docker run -d -p${SSH_HOST_PORT}:22 \
--hostname ${CONTAINER} \
--name ${CONTAINER} \
-e DISPLAY=$DISPLAY \
${CONTAINER_EXT_OPS} \
${IMAGE}

# Clean up the generated temp files.
rm -fr ${TMP_DIR}

echo ''
echo 'To start the Container:'
echo "	docker start ${NAME}"
echo 'To stop the Container:'
echo "	docker stop ${NAME}"
echo ''
echo 'The Container is already started. To connect:'
echo "	ssh -i ${SSH_PRVT_FILE} ${LOGIN}@localhost -p ${SSH_HOST_PORT}"
