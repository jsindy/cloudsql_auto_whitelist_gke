# Update CloudSQL IP whitelist with GKE(kubernetes) nodes

----

This script is designed to update your CloudSQL IP whitelist with kubernetes node ips. This helps when enabling auto scaling.

----

Prereqs for this bash script

```
gcloud # configured with proper permissions
kubectl
jq
sipcalc
```

----

Usage

```
$ chmod +x update_whitelist.sh
$ ./update_whitelist.sh CLOUDSQL_INSTANCE_NAME
```

