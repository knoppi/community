# community
Containerized community bundle using Drupal and phpBB backed by LDAP

# Preparations

You need some volumes to store user data and user content. In detail this is the storage for the LDAP server, for the forum and for the drupal page content. Plug-ins and Themes should be controlled via the Docker images.

The steps described here should be understood when repeating the process. Nevertheless there exists a script `prepare.sh` that performs a lot of the required actions.

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

```bash
 kubectl create -f storage.yaml
```

## LDAP database

The central element glueing together all the different playgrounds of the online community (phpBB, Drupal and later something like Nextcloud) is the central LDAP server.
Currently this project uses openLDAP, we also evaluate Samba as an alternative.

If you start from scratch it is sufficient to declare the organization and the organizational units within your LDAP-directory. 
This step has to be done, too, if you fill LDAP with older data. 
It is convenient to store the organization as value in a ConfigMap for the automatization of the overall process and the master password in a Secret.

```bash
kubectl create configmap ldap-config --from-literal=config_basedn=="o=$domainname"
```

The entries will be added from Drupal - which also acts as a management tool for the LDAP server.
In that case you have to add the organization

```ldap
dn: o=your_organization
changetype: add
objectclass: top
objectclass: organization
o: your_organization
```
and the three organizational units `people`, `groups`, and `admin`.

In the next step LDAP is to be filled with data.

# tl;dr

```bash
. prepare.sh
kubectl create namespace $domainname
kubectl config set-context $(kubectl config current-context) --namespace=$domainname
kubectl create configmap ldap-config --from-literal=config_basedn=="o=$domainname"
```

# Migrate from an old phpBB database

 TODO


