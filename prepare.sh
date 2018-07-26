# this script export environment variables for the bash
# call it using source

# Collect information
# ##########################################################################
echo "What's your community's/organization's name? (usable as domainname)"

read domainname

echo "Enter your LDAP-administration password"

read -s ldap_pass

echo "Enter your database password for the root user (drupal-db)"

read -s drupal_db_root_passwd

echo "Enter your database password for the Drupal user"

read -s drupal_db_admin_passwd

export domainname
export ldap_pass
export drupal_db_root_passwd
export drupal_db_admin_passwd

# Create files for raw LDAP directory
# ##########################################################################
echo "dn: o=$domainname" > ldap/basis.ldif
echo "changetype: add" >> ldap/basis.ldif
echo "objectclass: top" >> ldap/basis.ldif
echo "objectclass: organization" >> ldap/basis.ldif
echo "o: $domainname" >> ldap/basis.ldif

for ou in people groups admin
do
    echo "" >> ldap/basis.ldif
    echo "dn: ou=$ou,o=$domainname" >> ldap/basis.ldif
    echo "changetype: add" >> ldap/basis.ldif
    echo "objectclass: top" >> ldap/basis.ldif
    echo "objectclass: organizationalUnit" >> ldap/basis.ldif
    echo "ou: $ou" >> ldap/basis.ldif

done

echo "dn: cn=admin,ou=people,o=$domainname" > ldap/fill.ldif
echo "changetype: add" >> ldap/fill.ldif
echo "objectclass: top" >> ldap/fill.ldif
echo "objectclass: person" >> ldap/fill.ldif
echo "objectclass: organizationalPerson" >> ldap/fill.ldif
echo "objectclass: inetOrgPerson" >> ldap/fill.ldif
echo "cn: admin" >> ldap/fill.ldif
echo "sn: admin" >> ldap/fill.ldif
echo "uid: admin" >> ldap/fill.ldif
echo "mail: admin@$domainname.org" >> ldap/fill.ldif

for i in `seq 10`
do
    echo "" >> ldap/fill.ldif
    echo "dn: cn=user$i,ou=people,o=$domainname" >> ldap/fill.ldif
    echo "changetype: add" >> ldap/fill.ldif
    echo "objectclass: top" >> ldap/fill.ldif
    echo "objectclass: person" >> ldap/fill.ldif
    echo "objectclass: organizationalPerson" >> ldap/fill.ldif
    echo "objectclass: inetOrgPerson" >> ldap/fill.ldif
    echo "cn: user$i" >> ldap/fill.ldif
    echo "sn: user$i" >> ldap/fill.ldif
    echo "uid: user$i" >> ldap/fill.ldif
    echo "mail: user$i@$domainname.org" >> ldap/fill.ldif
done

# Config files for drupal
# ##########################################################################
echo 'INSERT INTO ldap_servers' > setup_drupal_database.sql
echo '    (sid, name, status, ldap_type, ' >> setup_drupal_database.sql
echo '     address, port, tls, followrefs, ' >> setup_drupal_database.sql
echo '     bind_method, binddn, bindpw, ' >> setup_drupal_database.sql
echo '     basedn, user_attr, account_name_attr, ' >> setup_drupal_database.sql
echo '     mail_attr, user_dn_expression )' >> setup_drupal_database.sql
echo 'VALUES' >> setup_drupal_database.sql
echo '    ("users", "Users", 1, "openldap", ' >> setup_drupal_database.sql
echo '     "ldap-intern", 389, 0, 0, 1, ' >> setup_drupal_database.sql
echo '     "cn=admin,o='$domainname'", "'$ldap_pass'", ' >> setup_drupal_database.sql
echo '     "a:1:{i:0;s:10:\"o='$domainname'\";}", ' >> setup_drupal_database.sql
echo '     "cn", "cn", "mail", ' >> setup_drupal_database.sql
echo '     "cn=%username,%basedn");' >> setup_drupal_database.sql

# Prepare kubernetes
# ##########################################################################

