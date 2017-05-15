#!/bin/bash
set -ue
auth_ips=$(gcloud sql instances describe ${1}|grep '^    - '|tr -d '[:space:]')
auth_ips=${auth_ips:1}
format_nl="$(echo $auth_ips| tr '-' '\n')"
format_nl2=$format_nl

while read -r format_nl; do
  # Check if IP format is num.num.num.num / num between 0..255
  if [ "$(sipcalc $format_nl | grep ERR)" != "" ]; then
  echo "incorrect"
  exit 1
  fi
  echo "correct"
done <<< "$format_nl"

echo #
format_auth_ips=$(echo "$format_nl2"|tr " " "\n"|sort -u|tr "\n" ",")
format_auth_ips=${format_auth_ips::-1}
echo $format_auth_ips


node_ips_spaces=$(kubectl get nodes -o json | \
    jq -r '.items[].status.addresses[]|select(.type=="ExternalIP").address')
node_ips=$(echo $node_ips_spaces | tr ' ' ',')

# ADD Static IPs that are not GKE nodes below
#node_ips+=,126.91.148.186
#node_ips+=,127.26.123.5
#node_ips+=,127.13.145.18
#node_ips+=,122.161.87.191
#node_ips+=,124.18.36.15

format="$(echo $node_ips| tr ',' '\n')"
node_ips2=$format
# validate ip list
while read -r format; do
  # Check if IP format is num.num.num.num / num between 0..255
  if [ "$(sipcalc $format | grep ERR)" != "" ]; then
  echo "incorrect"
  exit 1
  fi
  echo "correct"
done <<< "$format"

format_node_ips=$(echo "$node_ips2"|tr " " "\n"|sort -u|tr "\n" ",")
format_node_ips=${format_node_ips::-1}
echo $format_node_ips

if [ "$format_auth_ips" == "$format_node_ips" ]
then
  echo matched no need to update
else
  echo updating
  gcloud sql instances patch $1 --authorized-networks $format_node_ips
fi
