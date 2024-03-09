# user cert-manager to generate TLS certificate

For local and development purpose, we can use:
- cert-manager with CA Issuer and own root CA, when local url s not connected to internet (ex: 127.0.0.1.nip.io)
- cert-manager with ACME (http01 or dns01) Letsencrypt, when url connected to internet

## cert-manager with CA Issuer and own root CA

https://cert-manager.io/docs/configuration/ca/

In this example:
- generate rootCA with:

```
mkcert -install
```

- Import root CA cert and key in kubernetes secrets

```
./scripts/local-ca-root-issuer.sh

kubectl get secrets -n cert-manager ca-key-pair
```

- Enable  cert-manager and cert-manager-issuer charts
- Configure TLS for you app

```
whoami:
  installed: true
  ingress_class: nginx
  tls:
    - hosts:
      - whoami.127.0.0.1.nip.io
      secretName: whoami.127.0.0.1.nip.io
  hosts:
    - host: whoami.127.0.0.1.nip.io
      paths:
        - path: /
          pathType: Prefix
```

- To verify
```
# verify issuer
curl  https://whoami.127.0.0.1.nip.io -kv

# check certificate and issuer

kubectl get secrets -n cert-manager ca-key-pair
kubectl get clusterissuers -A
kubectl get issuers -A
kubectl get certificates -A

kubectl get secrets -n default whoami-127-0-0-1.nip.io
```
