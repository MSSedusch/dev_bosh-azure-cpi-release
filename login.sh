echo "SOURCE ME!"
bosh alias-env bosh-1 -e "${DIRECTOR_IP}" --ca-cert <(bosh int .local/creds.yml --path /director_ssl/ca)

# Log in to the Director
export BOSH_CLIENT=admin
export BOSH_CLIENT_SECRET=`bosh int .local/creds.yml --path /admin_password`

# Query the Director for more info
bosh -e bosh-1 env