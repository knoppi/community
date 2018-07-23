# community
Containerized community bundle using Drupal and phpBB backed by LDAP

![Structure diagram](doc/structure.svg)

# Prerequisites

Have the following tools installed:

* ldap-utils
* mysql-client

Access to some k8s cluster.

# Preparations

You need some volumes to store user data and user content. In detail this is the storage for the LDAP server, for the forum and for the drupal page content. Plug-ins and Themes should be controlled via the Docker images.

The steps described here should be understood when repeating the process. Nevertheless there exists a script `prepare.sh` that performs a lot of the required actions.

I recommend using a unique namespace for the pods of this bundle. 
Declare it and set the context before performing further steps. 
In this example the namespace is the same as the domainname and the shell-variable `$domainname` contains it.
If you source `prepare.sh` the variables are set correspondingly.

```bash
kubectl create namespace $domainname
kubectl config set-context $(kubectl config current-context) --namespace=$domainname
```

## Storage

Setting up the storage is a highly individual aspect. 
Make sure you adapt the contents of this repository to your needs and your environment. 
The example case uses local paths (`hostPath`). 
In production setups this is usually not available and cloud storage should be used.

The LDAP-server needs two folder: one for the config and one for the actual data. 
Additionally the database instances for each Drupal and phpBB also need storage. 
The rest is ephemeral. 
So we end with the following PersistentVolums:

* ldap-data
* ldap-config
* drupal-db
* phpbb-db

The corresponding PersistentVolumeClaims are

* claim-ldap-data
* claim-ldap-config
* claim-drupal-db
* claim-phpbb-db

Create the PersistentVolumes with

```bash
kubectl create -f storage.yaml
```

The claims are made from the same files as the deployments.

## LDAP database

The central element glueing together all the different playgrounds of the online community (phpBB, Drupal and later something like Nextcloud) is the central LDAP server.
Currently this project uses openLDAP, we also evaluate Samba as an alternative.

If you start from scratch it is sufficient to declare the organization and the organizational units within your LDAP-directory. 
This step has to be done, too, if you fill LDAP with older data. 
It is convenient to store the organization as value in a ConfigMap for the automatization of the overall process and the master password in a Secret.

```bash
kubectl create configmap ldap-config --from-literal=config_basedn=="o=$domainname"
kubectl create secret generic ldap-pass --from-literal=ldap-passwd=${ldap_pass}
```

The entries will later be controlled from Drupal.
The Docker image `beli/ldap` creates an admin user: `admin...`
Start it:

```bash
kubectl create -f deployment_ldap.yaml
```

The base structure should be something like this:

```ldap
dn: o=your_organization
changetype: add
objectclass: top
objectclass: organization
o: your_organization
```
and the three organizational units `people`, `groups`, and `admin`.
Basic knowledge about LDAP is useful.

The sample structure (as created from `prepare.sh`) can be found in `ldap/basis.ldif`, sample user data in `ldap/users.ldif`
We usually don't need direct access to the LDAP server so no service is defined.
For the initial setup we should open a route so we can address it directly with Linux command line tools:

```bash
kubectl create service nodeport ldap --tcp=389:389
export kub_ip=`kubectl config view | grep server | cut -d : -f 3 | cut -d / -f 3`
export ldap_port=`kubectl describe svc ldap | grep NodePort: | awk '{print $3}' | cut -d / -f 1`
ldapadd -x -h ${kub_ip} -p ${ldap_port} -D cn=admin,o=${domainname} -w ${ldap_pass} -f ldap/basis.ldif
ldapadd -x -h ${kub_ip} -p ${ldap_port} -D cn=admin,o=${domainname} -w ${ldap_pass} -f ldap/fill.ldif
```

Test that the entries have been added:
```
ldapsearch -h ${kub_ip} -p ${ldap_port} -D cn=admin,o=${domainname} -w ${ldap_pass}  -b ou=people,o=${domainname} "objectClass=*"
```

Note that the entry type `inetOrgPerson` suits very well the needs of both Drupal and phpBB but other choices might apply as well depending on which other services should be attached to the core.

# Drupal

The Drupal installation consists of a MySQL database with an attached storage and the Drupal container.
They have to started in any case:

```bash
kubectl create secret generic drupal-db-pass --from-literal=drupal-db-root-passwd=${drupal_db_root_passwd} --from-literal=drupal-db-admin-passwd=${drupal_db_admin_passwd}
kubectl create -f deployment_drupal_db.yaml
kubectl create -f deployment_drupal_app.yaml
```

## Installation

If Drupal is not yet set up you have to

1. install the Drupal site
1. setup Drupal to interact with the LDAP server

This is a bit hacky, since I currently only see the way of directly logging into a Drupal container and starting a prepared script which is part of my Drupal container.
You yould do this by hand, so I also give instructions and an explanation how to do it.
But, in particular, the LDAP configuration is a bit tedious.

The commandline installation is performed with the following command:

```bash
drush si standard --db-url=mysql://${MYSQL_USER}:${MYSQL_PASSWORD}@${MYSQL_HOST}/${MYSQL_DATABASE} --account-name admin --account-pass ${LDAP_PASSWD}
```
Of course you can also choose the browser based installation. 
If on the other hand the database is already set up you only need to have a settings file with the correct entries.
The default definition simply performs this modification of `/var/www/html/sites/default/settings.php`, you only overwrite it when doing a manual install.
Note that in this case you have to make the changes somehow persistent.


# tl;dr

```bash
# preparations
. prepare.sh
kubectl create namespace $domainname
kubectl config set-context $(kubectl config current-context) --namespace=$domainname
kubectl create -f storage.yaml
export kub_ip=`kubectl config view | grep server | cut -d : -f 3 | cut -d / -f 3`

# install and setup ldap
kubectl create configmap ldap-config --from-literal=config_basedn="o=$domainname"
kubectl create secret generic ldap-pass --from-literal=ldap-passwd=supersecret
kubectl create service nodeport ldap --tcp=389:389
export ldap_port=`kubectl describe svc ldap | grep NodePort: | awk '{print $3}' | cut -d / -f 1`
ldapadd -x -h ${kub_ip} -p ${ldap_port} -D cn=admin,o=${domainname} -w ${ldap_pass} -f ldap/basis.ldif
ldapadd -x -h ${kub_ip} -p ${ldap_port} -D cn=admin,o=${domainname} -w ${ldap_pass} -f ldap/fill.ldif
kubectl delete service ldap

# install and setup drupal
kubectl create secret generic drupal-db-pass --from-literal=drupal-db-pass=${drupal_db_pass}
kubectl create -f deployment_drupal_db.yaml
kubectl create -f deployment_drupal_app.yaml
```

# Migrate from an old phpBB database

 TODO


