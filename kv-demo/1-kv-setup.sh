#!/bin/sh
set +e

clear
echo "============================================"
echo "Enabling the Vault KV secret engine"
echo "============================================"
echo
echo "vault secrets enable -path="secrets" kv-v2"
vault secrets enable -path="secrets" kv-v2
echo
read
clear

echo "================================================="
echo "Enabling Authentication using username/password"
echo "================================================="
echo
echo "vault auth enable userpass"
vault auth enable userpass
echo
read
clear

echo "================================================="
echo "Writing Nike and Reebok secrets to appropriate locations"
echo "================================================="
echo
echo "vault kv put secrets/nike/production username=nike-admin password=nike123 servername=hr-prod.nike.com"
vault kv put secrets/nike/production username=nike-admin password=nike123 servername=hr-prod.nike.com > /dev/null 2>&1
echo
read
echo "vault kv put secrets/reebok/production username=reebok-admin password=reebok123 servername=finance-prod.reebok.com"
vault kv put secrets/reebok/production username=reebok-admin password=reebok123 servername=finance-prod.reebok.com > /dev/null 2>&1
echo
read
clear

echo "================================================="
echo "Creating ACL policy for Nike and Reebok secrets"
echo "================================================="
echo
echo "vault policy write nike-secret-policy nike-secret-policy.hcl"
vault policy write nike-secret-policy nike-secret-policy.hcl
echo
read
echo "vault policy write reebok-secret-policy reebok-secret-policy.hcl"
vault policy write reebok-secret-policy reebok-secret-policy.hcl
echo
read
clear

echo "================================================="
echo "Create User 'bob' and assign Nike policy; Create user 'david' and assign Reebok policy"
echo "================================================="
echo
echo "vault write auth/userpass/users/bob password=nike123 policies=nike-secret-policy"
vault write auth/userpass/users/bob password=nike123 policies=nike-secret-policy 
echo
echo
echo "vault write auth/userpass/users/david password=reebok123 policies=reebok-secret-policy"
vault write auth/userpass/users/david password=reebok123 policies=reebok-secret-policy
echo
read
clear

echo "================================================="
echo "Logging into Vault as 'bob' for Nike secrets"
echo "================================================="
echo
echo "vault login -method=userpass username=bob password=nike123"
bob_token=`vault login -method=userpass username=bob password=nike123 -format=json | jq -r '.auth.client_token'`
export VAULT_TOKEN=$bob_token
echo
read
clear

echo "================================================="
echo "Accessing Nike production secrets as Bob"
echo "================================================="
echo
echo "vault kv get secrets/nike/production"
vault kv get secrets/nike/production
echo
read
clear

echo "================================================="
echo "Attempting to access Reebok production secrets as Bob - Access will be Denied"
echo "================================================="
echo
echo "vault kv get secrets/reebok/production"
vault kv get secrets/reebok/production
echo
read
clear

echo "================================================="
echo "Logging into Vault as 'david' for Reebok secrets"
echo "================================================="
echo
echo "vault login -method=userpass username=david password=reebok123"
david_token=`vault login -method=userpass username=david password=reebok123 -format=json | jq -r '.auth.client_token'`
export VAULT_TOKEN=$david_token
echo
read
clear

echo "================================================="
echo "Accessing Rebook production secrets as David"
echo "================================================="
echo
echo "vault kv get secrets/reebok/production"
vault kv get secrets/reebok/production
echo
read
clear

echo "================================================="
echo "Attempting to access Nike production secrets as David - Access will be Denied"
echo "================================================="
echo
echo "vault kv get secrets/nike/production"
vault kv get secrets/nike/production
echo
read
clear
