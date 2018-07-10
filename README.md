# community
Containerized community bundle using Drupal and phpBB backed by LDAP

# Preparations

You need some volumes to store user data and user content. In detail this is the storage for the LDAP server, for the forum and for the drupal page content. Plug-ins and Themes should be controlled via the Docker images.

## Storage

Setting up the storage is a highly individual aspect. Make sure you adapt the contents of this repository to your needs and your environment. The example case uses local paths. In production setups cloud storage might be used.

The LDAP-server needs two folder: one for the config and one for the actual data. Additionally the database instances for each Drupal and phpBB also need storage. The rest is ephemeral. So we end with the following PersistentVolums:

* ldap-data
* ldap-config
* drupal-db
* phpbb-db

The corresponding PersistentVolumeClaims are

* claim-ldap-data
* claim-ldap-config
* claim-drupal-db
* claim-phpbb-db

Create those with

 kubectl create -f storage.yaml


