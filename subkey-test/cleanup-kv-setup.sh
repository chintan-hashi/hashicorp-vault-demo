#!/bin/sh
set -e


vault secrets disable /secrets
vault auth disable userpass

vault policy delete nike-secret-policy
vault policy delete reebok-secret-policy