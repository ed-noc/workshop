set -a
source .env

docker exec -it noc-gitlab-runner gitlab-runner register \
  --non-interactive \
  --url "http://noc-gitlab-ce" \
  --clone-url "http://noc-gitlab-ce" \
  --registration-token "${GITLAB_RUNNER_REGISTRATION_TOKEN}" \
  --executor "${GITLAB_RUNNER_EXECUTOR}" \
  --docker-image ${GITLAB_RUNNER_DOCKER_IMAGE}:${GITLAB_RUNNER_DOCKER_IMAGE_VERSION} \
  --description "${GITLAB_RUNNER_DOCKER_DESCRIPTION}" \
  --run-untagged="true" \
  --locked="false" \
  --docker-cap-add="CAP_IPC_LOCK" \
  --access-level="not_protected" \
  --docker-network-mode "toolchain-network" \
  --docker-volumes "/var/run/docker.sock:/var/run/docker.sock"
