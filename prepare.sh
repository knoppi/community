# this script export environment variables for the bash
# call it using source

# Collect information
# ##########################################################################
echo "What's your community's/organization's name? (usable as domainname)"

read domainname

echo "Enter your LDAP-administration password"

read -s ldap_pass

echo $domainname

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

# Prepare kubernetes
# ##########################################################################

