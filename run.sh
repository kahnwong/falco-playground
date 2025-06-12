#!/bin/bash

# install falco
helm repo add falcosecurity https://falcosecurity.github.io/charts
helm repo update

helm install --replace falco --namespace falco --create-namespace --set tty=true falcosecurity/falco

# create deployment
kubectl create deployment nginx --image=nginx

# Deploy Falcosidekick and Falcosidekick UI
helm upgrade --namespace falco falco falcosecurity/falco -f falco_custom_rules_cm.yaml --set falcosidekick.enabled=true --set falcosidekick.webui.enabled=true

# this command triggers a falco rule
kubectl exec -it $(kubectl get pods --selector=app=nginx -o name) -- cat /etc/shadow

# check falco logs
kubectl logs -l app.kubernetes.io/name=falco -n falco -c falco | grep Warning
