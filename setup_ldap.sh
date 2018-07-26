#!/bin/sh

curl -s --data "name=admin&pass=$ldap_pass&form_id=user_login&op=Log in" --location --cookie cookies.txt --cookie-jar cookies.txt http://$kub_ip:30380/user/login > /dev/null
form_build_id=`curl -s --cookie cookies.txt --cookie-jar cookies.txt http://$kub_ip:30380/admin/config/people/ldap/user | grep form_build_id | sed 's/.*form_build_id" value="//' | sed 's+" />++'`
form_token=`curl -s --cookie cookies.txt --cookie-jar cookies.txt http://$kub_ip:30380/admin/config/people/ldap/user | grep form_token | sed 's/.*form_token" value="//' | sed 's+" />++'`

curl -s \
--data "manualAccountConflict=1" \
--data "drupalAcctProvisionServer=users" \
--data "drupalAcctProvisionTriggers[2]=2" \
--data "drupalAcctProvisionTriggers[1]=1" \
--data "disableAdminPasswordField=1" \
--data "userConflictResolve=2" \
--data "accountsWithSameEmail=0" \
--data "acctCreation=4" \
--data "orphanedDrupalAcctBehavior=ldap_user_orphan_email" \
--data "orphanedCheckQty=100" \
--data "ldapEntryProvisionServer=users" \
--data "ldapEntryProvisionTriggers[6]=6" \
--data "ldapEntryProvisionTriggers[7]=7" \
--data "ldapEntryProvisionTriggers[3]=3" \
--data "form_build_id=$form_build_id" \
--data "form_token=$form_token" \
--data "form_id=ldap_user_admin_form" \
--data "2__sm__user_attr__0=[property.mail]" \
--data "2__sm__ldap_attr__0=[mail]" \
--data "2__sm__user_attr__1=[property.name]" \
--data "2__sm__ldap_attr__1=[cn]" \
--data "2__sm__user_attr__2=user_tokens" \
--data "2__sm__user_tokens__2=cn=[property.name],ou=people,o=$domainname" \
--data "2__sm__ldap_attr__2=[dn]" \
--data "2__sm__user_attr__3=user_tokens" \
--data "2__sm__user_tokens__3=top" \
--data "2__sm__ldap_attr__3=[objectclass:0]" \
--location --cookie cookies.txt --cookie-jar cookies.txt \
http://$kub_ip:30380/admin/config/people/ldap/user \
> /dev/null

curl -s \
--data "manualAccountConflict=1" \
--data "drupalAcctProvisionServer=users" \
--data "drupalAcctProvisionTriggers[2]=2" \
--data "drupalAcctProvisionTriggers[1]=1" \
--data "disableAdminPasswordField=1" \
--data "userConflictResolve=2" \
--data "accountsWithSameEmail=0" \
--data "acctCreation=4" \
--data "orphanedDrupalAcctBehavior=ldap_user_orphan_email" \
--data "orphanedCheckQty=100" \
--data "ldapEntryProvisionServer=users" \
--data "ldapEntryProvisionTriggers[6]=6" \
--data "ldapEntryProvisionTriggers[7]=7" \
--data "ldapEntryProvisionTriggers[3]=3" \
--data "form_build_id=$form_build_id" \
--data "form_token=$form_token" \
--data "form_id=ldap_user_admin_form" \
--data "2__sm__user_attr__4=user_tokens" \
--data "2__sm__user_tokens__4=person" \
--data "2__sm__ldap_attr__4=[objectclass:1]" \
--data "2__sm__user_attr__5=user_tokens" \
--data "2__sm__user_tokens__5=organizationalPerson" \
--data "2__sm__ldap_attr__5=[objectclass:2]" \
--data "2__sm__user_attr__6=user_tokens" \
--data "2__sm__user_tokens__6=inetOrgPerson" \
--data "2__sm__ldap_attr__6=[objectclass:3]" \
--data "2__sm__user_attr__7=user_tokens" \
--data "2__sm__user_tokens__7=Drupal Provisioned LDAP account" \
--data "2__sm__ldap_attr__7=[description]" \
--location --cookie cookies.txt --cookie-jar cookies.txt \
http://$kub_ip:30380/admin/config/people/ldap/user \
> /dev/null

curl -s \
--data "manualAccountConflict=1" \
--data "drupalAcctProvisionServer=users" \
--data "drupalAcctProvisionTriggers[2]=2" \
--data "drupalAcctProvisionTriggers[1]=1" \
--data "disableAdminPasswordField=1" \
--data "userConflictResolve=2" \
--data "accountsWithSameEmail=0" \
--data "acctCreation=4" \
--data "orphanedDrupalAcctBehavior=ldap_user_orphan_email" \
--data "orphanedCheckQty=100" \
--data "ldapEntryProvisionServer=users" \
--data "ldapEntryProvisionTriggers[6]=6" \
--data "ldapEntryProvisionTriggers[7]=7" \
--data "ldapEntryProvisionTriggers[3]=3" \
--data "form_build_id=$form_build_id" \
--data "form_token=$form_token" \
--data "form_id=ldap_user_admin_form" \
--data "2__sm__user_attr__8=[property.name]" \
--data "2__sm__ldap_attr__8=[sn]" \
--data "2__sm__user_attr__9=[property.name]" \
--data "2__sm__ldap_attr__9=[uid]" \
--data "2__sm__user_attr__10=[password.user-random]" \
--data "2__sm__ldap_attr__10=[userPassword]" \
--data "2__sm__4__0=1" \
--data "2__sm__3__0=1" \
--data "2__sm__4__1=1" \
--data "2__sm__3__1=1" \
--data "2__sm__4__2=1" \
--data "2__sm__3__2=1" \
--data "2__sm__4__3=1" \
--data "2__sm__3__3=1" \
--data "2__sm__4__4=1" \
--data "2__sm__3__4=1" \
--data "2__sm__4__5=1" \
--data "2__sm__3__5=1" \
--data "2__sm__4__6=1" \
--data "2__sm__3__6=1" \
--data "2__sm__4__7=1" \
--data "2__sm__3__7=1" \
--data "2__sm__4__8=1" \
--data "2__sm__3__8=1" \
--data "2__sm__4__9=1" \
--data "2__sm__3__9=1" \
--data "2__sm__4__10=1" \
--data "2__sm__3__10=1" \
--location --cookie cookies.txt --cookie-jar cookies.txt \
http://$kub_ip:30380/admin/config/people/ldap/user \
> /dev/null

rm cookies.txt
