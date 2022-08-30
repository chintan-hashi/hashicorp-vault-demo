
path "secrets/data/nike/*"
{
    capabilities = ["create", "update", "delete", "list"]
}

path "secrets/subkeys/nike/*"
{
    capabilities = ["read"]
}