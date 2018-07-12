# this script export environment variables for the bash
# call it using source

# Collect information
# ##########################################################################
echo "What's your community's/organization's name? (usable as domainname)"

read domainname

echo "Enter your LDAP-administration password"

read -s ldap_pass

export domainname
export ldap_pass

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

# Prepare kubernetes
# ##########################################################################

