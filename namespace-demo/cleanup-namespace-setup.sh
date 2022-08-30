#!/bin/sh
set -e


export VAULT_NAMESPACE=nike
vault secrets disable /secrets
vault auth disable userpass
vault policy delete customer-prod-secret-policy


export VAULT_NAMESPACE=reebok
vault secrets disable /secrets
vault auth disable userpass
vault policy delete customer-prod-secret-policy

export VAULT_NAMESPACE=root
vault namespace delete reebok
vault namespace delete nike