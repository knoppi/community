# community
Containerized community bundle using Drupal and phpBB backed by LDAP

![Structure diagram](doc/structure.svg)

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
The example case uses local paths. 
In production setups cloud storage might be used.

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
kubectl create secret generic ldap-pass --from-literal=ldap-passwd=supersecret
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

# tl;dr

```bash
. prepare.sh
kubectl create namespace $domainname
kubectl config set-context $(kubectl config current-context) --namespace=$domainname
kubectl create -f storage.yaml
kubectl create configmap ldap-config --from-literal=config_basedn="o=$domainname"
kubectl create secret generic ldap-pass --from-literal=ldap-passwd=supersecret
kubectl create service nodeport ldap --tcp=389:389
export kub_ip=`kubectl config view | grep server | cut -d : -f 3 | cut -d / -f 3`
export ldap_port=`kubectl describe svc ldap | grep NodePort: | awk '{print $3}' | cut -d / -f 1`
ldapadd -x -h ${kub_ip} -p ${ldap_port} -D cn=admin,o=${domainname} -w ${ldap_pass} -f ldap/basis.ldif
ldapadd -x -h ${kub_ip} -p ${ldap_port} -D cn=admin,o=${domainname} -w ${ldap_pass} -f ldap/fill.ldif
kubectl delete service ldap
```

# Migrate from an old phpBB database

 TODO


