# Enable basic-auth on ingress-nginx

2 modes available

- auth-file: htpasswd file format
- auth-map: key / value (env file format)

## auth-file: htpasswd file
- Generate htpasswd file 'my-auth-file': `user:password`
```
htpasswd -c -B -b my-auth-file user1 password1
htpasswd -c -B -b my-auth-file user2 password2

cat my-auth-file

user1:$2y$05$.....
user2:$2y$05$.....
```

- In namespace 'ingress-nginx', create secret 'basic-auth', with basic-auth user list file (note, the auth key)
```
kubectl create  -n ingress-nginx secret generic basic-auth --from-file=auth=my-auth-file --dry-run=client -o yaml | kubectl apply -f -
```

- Verify
```
kubectl get -n ingress-nginx  secret basic-auth -o yaml
```

```yaml
apiVersion: v1
kind: Secret
type: Opaque
metadata:
  annotations:
  name: basic-auth
  namespace: ingress-nginx
data:
  auth: dXNl............(base64 encoded file)
```



- Configure ingress-nginx annotations
```
app:
  ingress:
     annotations:
       nginx.ingress.kubernetes.io/auth-secret: ingress-nginx/basic-auth
       nginx.ingress.kubernetes.io/auth-type: basic
       nginx.ingress.kubernetes.io/auth-secret-type: auth-file
       nginx.ingress.kubernetes.io/auth-realm: "Progress Authentication"
```


## auth-map file

- Generate passwd file 'my-auth-file': `user=password`
```
echo "password1" | openssl passwd -apr1  -stdin |xargs printf "%s=%s\n" user1 |tee my-auth-file
echo "password2" | openssl passwd -apr1  -stdin |xargs printf "%s=%s\n" user2 |tee my-auth-file

cat my-auth-file

user1=$2y$05$.....
user2=$2y$05$.....
```

- In namespace 'ingress-nginx', create secret 'basic-auth', with basic-auth user env file (note, the from-env-file)
```
kubectl create  -n ingress-nginx secret generic basic-auth   --from-env-file=my-authfile --dry-run=client -o yaml  | kubectl apply -f -
```

```yaml
apiVersion: v1
kind: Secret
type: Opaque
metadata:
  name: basic-auth
  namespace: ingress-nginx
data:
  user1: JGFwcjEkW....
  user2: JGFwcjEkd....
```

- Configure ingress-nginx annotations
```
app:
  ingress:
     annotations:
       nginx.ingress.kubernetes.io/auth-secret: ingress-nginx/basic-auth
       nginx.ingress.kubernetes.io/auth-type: basic
       nginx.ingress.kubernetes.io/auth-secret-type: auth-map
       nginx.ingress.kubernetes.io/auth-realm: "Progress Authentication"
```


