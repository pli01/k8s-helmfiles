The demo files and passwords are INTENTIONALY present to demonstrate the use of secrets with SOPs.

The following extensions files are explicitly ignored during commits.
*.yaml.enc
*.yaml
*.enc.yaml

This directory can contains encrypted secrets.enc.yaml file (note the .enc.yaml suffix)
and maintain in another git repo if needed.

Example:

To manage secrets for Grafana admin password using Helmfiles along with SOPS and age encryption, you can follow these steps:

- Verify sops and age binary are present

- Configure private keys and public keys with age-keygen

```yaml
# private key generated with age-keygen
export SOPS_AGE_KEY_FILE=$HOME/.sops/$USER.key
# or
export SOPS_AGE_KEY=AGE-SECRET-KEY-REPLACE_WITH_YOUR_PRIVATE_KEY
```

```yaml
# configure sops age and public keys
# GIT_ROOT/.sops.yaml
creation_rules:
  - age: >-
      age1XXXXXXXXXX_PUBLIC_KEY_1,
      age1XXXXXXXXXX_PUBLIC_KEY_2
```

- Create a YAML file with your secret `grafana-secrets.yaml`


```yaml
grafana:
  # INTENTIONALY present
  adminPassword: YOUR_PASSWORD_HERE
```
- Encrypt the secrets file using SOPS:
An example is available in `grafana-secrets.decrypt.yaml.sample`.
Rename it to grafana-secrets.yaml and encrypt to grafana-secrets.enc.yaml

```
sops -e grafana-secrets.yaml > grafana-secrets.enc.yaml
# or 
# Replace YOUR_AGE_PUBLIC_KEY_FILE with the path to your age public key file.
sops -e --age YOUR_AGE_PUBLIC_KEY_FILE grafana-secrets.yaml > grafana-secrets.enc.yaml
```

- Reference the encrypted secret in your Helmfile: In your Helmfile, reference the encrypted `grafana-secrets.enc.yaml` file.

```yaml
releases:
  - name: my-grafana
    namespace: grafana
    chart: stable/grafana
    version: 5.3.8
    secrets:
      - ./PATH_TO/secrets/grafana-secrets.enc.yaml
```

- Decrypt the secret during deployment:
When deploying your Helm chart, ensure you have the necessary access to decrypt the secrets. SOPS will handle the decryption process automatically if you have the appropriate keys configured.
