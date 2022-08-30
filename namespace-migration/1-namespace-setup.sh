
#!/bin/sh

set +e
clear

root_token=$VAULT_TOKEN

echo "============================================"
echo "Creating Namespace engineering & marketing"
echo "============================================"
echo
echo "vault namespace create engineering"
vault namespace create engineering
echo
echo "vault namespace create marketing"
vault namespace create marketing
echo
read
clear

echo "============================================"
echo "Enabling the Vault KV secret engine in engineering namespace"
echo "============================================"
echo
echo "vault secrets enable --namespace=engineering -path="secrets" kv-v2"
vault secrets enable --namespace=engineering -path="secrets" kv-v2
echo
read
clear

echo "================================================="
echo "Enabling Authentication using username/password in engineering namespace"
echo "================================================="
echo
echo "vault auth enable -namespace=engineering userpass"
vault auth enable -namespace=engineering userpass
echo
read
clear

echo "================================================="
echo "Writing engineering secrets to appropriate locations"
echo "================================================="
echo
echo "vault kv put --namespace=engineering secrets/production username=admin password=nike123 servername=analytics-svc.wfc.com"
vault kv put --namespace=engineering secrets/production username=admin password=nike123 servername=analytics-svc.wfc.com > /dev/null 2>&1
echo
read
clear

echo "================================================="
echo "Creating ACL policy for engineering secrets"
echo "================================================="
echo
echo "vault policy write --namespace=engineering customer-prod-secret-policy customer-prod-secret-policy.hcl"
vault policy write --namespace=engineering customer-prod-secret-policy customer-prod-secret-policy.hcl
echo
read
clear

echo "================================================="
echo "Create User 'bob' in engineering namespace"
echo "================================================="
echo
echo "vault write --namespace=engineering auth/userpass/users/bob password=wellsfargo123 policies=customer-prod-secret-policy"
vault write --namespace=engineering auth/userpass/users/bob password=wellsfargo123 policies=customer-prod-secret-policy

echo
read
clear

echo "================================================="
echo "Logging into Vault as 'bob' for engineering secrets"
echo "================================================="
echo
echo "vault login -namespace=engineering -method=userpass username=bob password=wellsfargo123"
bob_token=`vault login -namespace=engineering -method=userpass username=bob password=wellsfargo123 -format=json | jq -r '.auth.client_token'`
export VAULT_TOKEN=$bob_token
echo
read
clear

echo "================================================="
echo "Accessing engineering production secrets as Bob"
echo "================================================="
echo
echo "vault kv get --namespace=engineering secrets/production"
vault kv get --namespace=engineering secrets/production
echo
read
clear

