# Enable wild card SSL certificate in ingress-nginx

Example:

Generate self signed certificate for '127.0.0.1.nip.io' and wildcard '*.127.0.0.1.nip.io'

- generate a certificate: here, self signed certificate with mkcert
```
( cd /tmp
mkcert -install
mkcert "127.0.0.1.nip.io" "*.127.0.0.1.nip.io"
)
```

- In /tmp , the following key file and cert file:
```
# key
/tmp/127.0.0.1.nip.io+1-key.pem
# cert
/tmp/127.0.0.1.nip.io+1.pem
```

- Import certificates in your kubernetes cluster:

- In the namespace 'ingress-nginx', create tls secret '127.0.0.1.nip.io', with key and cert files
```
( cd /tmp ; kubectl -n ingress-nginx create secret tls 127.0.0.1.nip.io --key 127.0.0.1.nip.io+1-key.pem --cert 127.0.0.1.nip.io+1.pem )
```

- Verify
```
kubectl -n ingress-nginx get secret/127.0.0.1.nip.io -o yaml
```

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: 127.0.0.1.nip.io
  namespace: ingress-nginx
type: kubernetes.io/tls
data:
  tls.crt: LS0t..........
  tls.key: LS0t..........
```

- In the ingress-nginx controller, use default-ssl-certificate:

```
controller:
  extraArgs:
    default-ssl-certificate: "ingress-nginx/127.0.0.1.nip.io"
```
