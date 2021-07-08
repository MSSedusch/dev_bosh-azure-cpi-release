cd /workspaces/dev_bosh-azure-cpi-release/bosh-azure-cpi-release
git add .
git commit -m "build commit"
cpi_dev_version=99.0.1.dev
bosh create-release --name=bosh-azure-cpi --version=${cpi_dev_version} --tarball=/workspaces/dev_bosh-azure-cpi-release/bosh-azure-cpi-release-${cpi_dev_version}.tgz