#!/bin/bash

# exit when any command fails
set -e

# setup kong
docker-compose build kong
sleep 2
docker-compose up -d kong-db
sleep 2
docker-compose run --rm kong kong migrations bootstrap
sleep 2
docker-compose run --rm kong kong migrations up
sleep 2
docker-compose up -d kong
docker-compose ps
curl -s http://localhost:8001 | jq .plugins.available_on_server.oidc

# setup konga and wait some time X to be sure that all services are up and running
docker-compose up -d konga
sleep 2m

#setup keycloak
docker-compose up -d keycloak-db
docker-compose up -d keycloak
docker-compose ps

# Test liveness for Konga
curl -v http://localhost:1337

# Test liveness for Keycloak
curl -v http://localhost:8180

# setup prometheus and grafana
docker-compose up -d prometheus
docker-compose up -d grafana
docker-compose ps

# Test liveness for Prometheus
curl -v http://localhost:9090

# Test liveness for Grafana
curl -v http://localhost:3000