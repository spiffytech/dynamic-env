#!/usr/bin/env bash

BASE_DIR=${BASE_DIR:-.}
ENV_DEST=${ENV_DEST:-public}
WHITELIST_FILE=${WHITELIST_FILE:-.env.example}
ENV_JS=${ENV_JS:-env.js}

if [[ -f .env ]]
then
    export $(grep -v '^#' .env | xargs)
fi

# get any environment vars set in `env` which are whitelisted variables.
read -r -d '' DYNAMIC_VARS <<GENERATED_ENV
##############################################
# WARNING: This file is generated by env-gen #
#          Do not modify this file directly! #
##############################################
`env |sort |grep -f <(cat ${BASE_DIR}/${WHITELIST_FILE} |grep -o '^[A-Z0-9_]*=' |sed 's/^/^/')`
GENERATED_ENV

# create env.js file from config json so that app can access it via window._env_
ENV_JSON=`echo "${DYNAMIC_VARS}" |dotenv-to-json |jq .` \
    && cat <<JS_ENV > ${BASE_DIR}/${ENV_DEST}/${ENV_JS}
/**
 * WARNING: This file is generated by env-gen
 * Do not modify this file directly!
 */
window._env_ = ${ENV_JSON};
JS_ENV
