
#!/bin/sh

set +e
clear

echo "============================================"
echo "Creating Namespace Nike & Reebok"
echo "============================================"
echo
echo "vault namespace create nike"
vault namespace create nike
echo
echo "vault namespace create reebok"
vault namespace create reebok
echo
read
clear

echo "============================================"
echo "Enabling the Vault KV secret engine in Nike & Reebok namespace"
echo "============================================"
echo
echo "vault secrets enable --namespace=nike -path="secrets" kv-v2"
vault secrets enable --namespace=nike -path="secrets" kv-v2
echo
echo "vault secrets enable --namespace=reebok -path="secrets" kv-v2"
vault secrets enable --namespace=reebok -path="secrets" kv-v2
echo
read
clear

echo "================================================="
echo "Enabling Authentication using username/password in Nike & Reebok namespace"
echo "================================================="
echo
echo "vault auth enable -namespace=nike userpass"
vault auth enable -namespace=nike userpass
echo
echo "vault auth enable -namespace=reebok userpass"
vault auth enable -namespace=reebok userpass
echo
read
clear

echo "================================================="
echo "Writing Nike and Reebok secrets to appropriate locations"
echo "================================================="
echo
echo "vault kv put --namespace=nike secrets/production username=nike-admin password=nike123 servername=hr-prod.nike.com"
vault kv put --namespace=nike secrets/production username=nike-admin password=nike123 servername=hr-prod.nike.com > /dev/null 2>&1
echo
read
echo "vault kv put --namespace=reebok secrets/production username=reebok-admin password=reebok123 servername=finance-prod.reebok.com"
vault kv put --namespace=reebok secrets/production username=reebok-admin password=reebok123 servername=finance-prod.reebok.com > /dev/null 2>&1
echo
read
clear

echo "================================================="
echo "Creating ACL policy for Nike and Reebok secrets"
echo "================================================="
echo
echo "vault policy write --namespace=nike customer-prod-secret-policy customer-prod-secret-policy.hcl"
vault policy write --namespace=nike customer-prod-secret-policy customer-prod-secret-policy.hcl
echo
read
echo "vault policy write --namespace=reebok customer-prod-secret-policy customer-prod-secret-policy.hcl"
vault policy write --namespace=reebok customer-prod-secret-policy customer-prod-secret-policy.hcl
echo
read
clear

echo "================================================="
echo "Create User 'bob' in Nike namespace; Create user 'david' in Reebok namespace"
echo "================================================="
echo
echo "vault write --namespace=nike auth/userpass/users/bob password=nike123 policies=customer-prod-secret-policy"
vault write --namespace=nike auth/userpass/users/bob password=nike123 policies=customer-prod-secret-policy
echo
echo
echo "vault write --namespace=reebok auth/userpass/users/david password=reebok123 policies=customer-prod-secret-policy"
vault write --namespace=reebok auth/userpass/users/david password=reebok123 policies=customer-prod-secret-policy
echo
read
clear

echo "================================================="
echo "Logging into Vault as 'bob' for Nike secrets"
echo "================================================="
echo
echo "vault login -namespace=nike -method=userpass username=bob password=nike123"
bob_token=`vault login -namespace=nike -method=userpass username=bob password=nike123 -format=json | jq -r '.auth.client_token'`
export VAULT_TOKEN=$bob_token
echo
read
clear

echo "================================================="
echo "Accessing Nike production secrets as Bob"
echo "================================================="
echo
echo "vault kv get --namespace=nike secrets/production"
vault kv get --namespace=nike secrets/production
echo
read
clear

echo "================================================="
echo "Attempting to access Reebok production secrets as Bob - Access will be Denied"
echo "================================================="
echo
echo "vault kv get --namespace=reebok secrets/production"
vault kv get --namespace=reebok secrets/production
echo
read
clear

echo "================================================="
echo "Logging into Vault as 'david' for Reebok secrets"
echo "================================================="
echo
echo "vault login -namespace=reebok -method=userpass username=david password=reebok123"
david_token=`vault login -namespace=reebok -method=userpass username=david password=reebok123 -format=json | jq -r '.auth.client_token'`
export VAULT_TOKEN=$david_token
echo
read
clear

echo "================================================="
echo "Accessing Rebook production secrets as David"
echo "================================================="
echo
echo "vault kv get --namespace=reebok secrets/production"
vault kv get --namespace=reebok secrets/production
echo
read
clear

echo "================================================="
echo "Attempting to access Nike production secrets as David - Access will be Denied"
echo "================================================="
echo
echo "vault kv get --namespace=nike secrets/production"
vault kv get --namespace=nike secrets/production
echo
read
clear




