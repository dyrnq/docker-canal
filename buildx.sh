#!/usr/bin/env bash
set -Eeo pipefail

base_image="${base_image:-}"
version="${version:-1.1.8-alpha-3}";
push="${push:-false}"
repo="${repo:-dyrnq}"
image_name="${image_name:-canal-server}"
platforms="${platforms:-linux/amd64,linux/arm64/v8}"
curl_opts="${curl_opts:-}"
while [ $# -gt 0 ]; do
    case "$1" in
        --base-image|--base)
            base_image="$2"
            shift
            ;;
        --version|--ver)
            version="$2"
            shift
            ;;
        --push)
            push="$2"
            shift
            ;;
        --curl-opts)
            curl_opts="$2"
            shift
            ;;
        --platforms)
            platforms="$2"
            shift
            ;;
        --repo)
            repo="$2"
            shift
            ;;
        --image-name|--image)
            image_name="$2"
            shift
            ;;
        --*)
            echo "Illegal option $1"
            ;;
    esac
    shift $(( $# > 0 ? 1 : 0 ))
done


latest=$(cat latest);
m="${image_name}";
ver="${version}";

latest_tag="";
if [[ "${base_image}" =~ "eclipse-temurin:8u" ]]; then
    latest_tag="${latest_tag} --tag ${repo}/${m}:${ver}"
    latest_tag="${latest_tag} --tag ${repo}/${m}:${ver}-jdk8"

    if [ "$latest" = "${ver}"  ]; then
        latest_tag="${latest_tag} --tag ${repo}/${m}:latest"
    fi
elif [[ "${base_image}" =~ "eclipse-temurin:17" ]]; then
    latest_tag="${latest_tag} --tag ${repo}/${m}:${ver}-jdk17"
elif [[ "${base_image}" =~ "eclipse-temurin:21" ]]; then
    latest_tag="${latest_tag} --tag ${repo}/${m}:${ver}-jdk21"
elif [[ "${base_image}" =~ "eclipse-temurin:11" ]]; then
    latest_tag="${latest_tag} --tag ${repo}/${m}:${ver}-jdk11"
fi

echo "${latest_tag}"
docker buildx build \
--platform ${platforms} \
--output "type=image,push=${push}" \
--file ./${m}/Dockerfile . \
--build-arg BASE_IMAGE="${base_image}" \
${latest_tag}
