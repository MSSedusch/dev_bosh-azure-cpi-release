# TL;DR
Run init.sh to create configuration cache and Azure resources. Run deploy.sh to deploy the BOSH director, run deploy_zookeeper.sh to deploy your first demo app.

## Buidling a new CPI release and use it
Run build-cpi.sh to build a new dev version of the CPI. The script will create the archive and upload it to it to the storage account into container cpi. To use it, change the CPI in /workspaces/dev_bosh-azure-cpi-release/.local/bosh-deployment/azure/cpi.yml. Change the url and sha1 to the values provided by the build-cpi.sh script.
