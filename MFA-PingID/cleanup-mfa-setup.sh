#!/bin/sh
set -e


vault auth disable userpass

entity_id=`vault list -format=json identity/entity/id | jq -r '.[]'` 

vault delete identity/entity/id/$entity_id
