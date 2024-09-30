# Setup

Prepare platforms following the platform specifications (GCP/AWS/Fly/DigitalOcean).

```sh
# connect to server
ssh root@[DOMAIN]

# create empty file required to install ssl certificate
mkdir -p /letsencrypt && touch /letsencrypt/acme.json && chmod 600 /letsencrypt/acme.json
exit

# locally define KAMAL_REGISTRY_PASSWORD environment variable:
# if service account key.json is available, use this command
echo "KAMAL_REGISTRY_PASSWORD=$(base64 -i key.json)" | tr -d "\\n"  >> .devcontainer/services_env/app.env

# otherwise, copy directly from another project using same repository
```

Rebuild container for environment vars reloading.

```sh
bin/kamal env
```

Execute kamal setup. This will install Docker in server.

```sh
bin/kamal setup
```

Execute kamal deploy. This will release a new version.

```sh
bin/kamal deploy
```
