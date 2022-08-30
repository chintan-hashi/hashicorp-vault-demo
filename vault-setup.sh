#!/bin/sh

#CURR_DIR=/Users/chintangosalia/HashiCorp/vault/demo/hashicorp-vault-demo
#DOCKER_VAULT_DIR=/Users/chintangosalia/HashiCorp/docker/vault/
export VAULT_ADDR='http://127.0.0.1:8200'
echo "export VAULT_ADDR='http://127.0.0.1:8200'" > vault_env.config

#cd $DOCKER_VAULT_DIR
docker-compose up 2>&1 > volumes/logs/output.log &

#cd $CURR_DIR

sleep 10

init_val=`vault status -format=json | jq '.initialized'`
seal_val=`vault status -format=json | jq '.sealed'`

echo "init:" $init_val
echo "seal:" $seal_val

if [ "$init_val" == "false" ]; then
        echo "vault is not initialized"
        vault operator init -key-shares=3 -key-threshold=2 -format=json > vault-unseal-keys.json
fi

vault_token=`cat vault-unseal-keys.json| jq -r '.root_token'`
export VAULT_TOKEN=$vault_token
echo "export VAULT_TOKEN=$vault_token" >> vault_env.config

if [ $seal_val == "true" ]; then
        echo "vault is sealed"
        unseal_key1=`cat vault-unseal-keys.json | jq -r '.unseal_keys_b64[0]'`
        unseal_key2=`cat vault-unseal-keys.json | jq -r '.unseal_keys_b64[1]'`

        vault operator unseal $unseal_key1
        vault operator unseal $unseal_key2
fi
