ORIG_INPUT_PARAMS="$@"
params="$(getopt -o d:n: -l directory: -l name: --name "$(basename "$0")" -- "$@")"

if [ $? -ne 0 ]
then
	echo "Parameter error"
	print_usage
fi

print_usage() {
	printf "bash $0 [-d|--directory <workspace directory>] [--with-cuda] [--with-ros]\n"
}

eval set -- "$params"
unset params

IMAGE_BASE_NAME=agarwalsaurav/libtorch
IMAGE_TAG=arm64
IMAGE_NAME="${IMAGE_BASE_NAME}:${IMAGE_TAG}"
WS_DIR="/data/torch_ws"

while true; do
	case ${1} in
		-d|--directory) WS_DIR=("${2}");shift 2;;
		-n|--name) CONTAINER_NAME=("${2}");shift 2;;
		--) shift;break;;
		*) print_usage
			exit 1 ;;
	esac
done

CONTAINER_CC_WS="/workspace"

if [ -z ${WS_DIR} ]; then
	VOLUME_OPTION=""
else
	VOLUME_OPTION="-v ${WS_DIR}:${CONTAINER_CC_WS}:rw"
fi



if [ -z ${CONTAINER_NAME} ]; then
	CONTAINER_NAME="torch-${HOSTNAME}"
fi

docker run -it \
	--name=${CONTAINER_NAME} \
	${CONTAINER_OPTIONS} \
	--net=host \
	--privileged \
	--ipc=host \
	--pid=host \
	${VOLUME_OPTION} \
	--workdir=${CONTAINER_CC_WS} \
	${IMAGE_NAME} \
	bash
