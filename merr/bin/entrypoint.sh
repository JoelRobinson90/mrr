#!/bin/bash
set -e
# Remove a potentially pre-existing server.pid for Rails.
rm -f /myapp/tmp/pids/server.pid

echo "Executing entrypoint.sh"

# this should be scripted in Ruby to avoid needing to install Python

# Production tasks
if [ "$RAILS_ENV" = "production" ]
then
  apt-get install -y python3-pip=18.1-5 \
    python3-setuptools=40.8.0-1 \
    python3-wheel=0.32.3-2 \
    jq=1.5+dfsg-2+b1 \
    --no-install-recommends

  pip3 install awscli==1.27.20

  echo "Production environment detected"
  cd /myapp

  aws secretsmanager get-secret-value --secret-id "$HOST_ENV-core" --query SecretString --output text | jq -r 'to_entries|map("\(.key)=\(.value|tostring)")|.[]' > /tmp/secrets.env
  echo Exporting secrets
  eval "$(sed 's/^/export /' < /tmp/secrets.env)"

  aws secretsmanager get-secret-value --secret-id "$HOST_ENV-core-parameters" --query SecretString --output text | jq -r 'to_entries|map("\(.key)=\(.value|tostring)")|.[]' > /tmp/parameters.env
  echo Exporting parameters
  eval "$(sed 's/^/export /' < /tmp/parameters.env)"
fi

if [ -n "$ENABLE_SSH" ]
then
    # ensure variables passed to docker container are also exposed to ssh sessions
    env | grep _ >> /etc/environment
    mkdir -p /run/sshd
    mkdir -p "$HOME/.ssh"
    chmod 0700 "$HOME/.ssh"
    echo "${SSH_PUBLIC_KEY}" > "$HOME/.ssh/authorized_keys"
    /usr/sbin/sshd -e -f /etc/ssh/sshd_config
fi

# Then exec the container's main process (what's set as CMD in the Dockerfile).
exec "$@"
