# Edgeflip System Configurations

This repo contains the Puppet configuration and modules
for Edgeflip hosting of apps.


## Details
* Edgeflip-internally built app manifests in ./modules/apps/
* Standard provider packages built under ./modules
* This repo intended for hosting of Ubuntu 12.04 on AWS
* The initial apt-get update depends on the geppetto deploy user ssh
  credentials, and will fail without them. This key is normally provided
  by cloud-init. If using Vagrant, you'll need to provide them on your own.
* The current production version of Puppet is 2.7


## Node Management
* Some roles are defined in nodes.pp for standard builds, at the top of the other application definitions.
* Other server/tool roles are in ./modules/roles/
* Base class is explicitly added to a node.  If non-MoFo hosting, avoid utilizing base class.
* Creds for an app hosted by EF are injected on build, and pulled down via ./modules/creds/init.pp

## Keys, Creds, and Secrets
* During prep phase, all nodes get deployment creds
* During prep phase, app nodes with a specific class defined for creds::app get app secrets

## Notes
* Contact: devops@edgeflip.com
* Current to-do Kanban: http://huboard.mofoprod.net/edgeflip/ef_system_configurations/board


