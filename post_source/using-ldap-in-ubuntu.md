---
title: Using LDAP in Ubuntu
date: 2017-06-20 10:32:00
updated: 2017-06-25
Category: howto
Tags:
- mail
---

### 1. Install

```bash
sudo apt-get install lbdb libnet-ldap-perl
```

### 2. Setup

```bash
mkdir ~/.lbdb
touch ~/.lbdb/rc
touch ~/.lbdb/ldap.rc
```
`.lbdb/rc`

```perl
METHODS="m_ldap"
LDAP_NICKS="anynick"
```

`.lbdb/ldqp.rc`

```perl
%ldap_server_db = (
    'anynick' => ['ldaps://xxx.xxx.xxx:636',
                    'ou=people',
                    'cn mail', 'cn mail department',
                    '${mail}', '${cn}', '${department}']
);

$ignorant = 1;
$ldap_bind_dn = 'domian\id';
$ldap_bind_password = 'password';
1;
```

### 3. Usage
```bash
lbdbq xxx
```

### 4. integrating into mutt

add below line to ~/.muttrc

```
set query_command="lbdbq '%s'"
```

### 5. Links

- <a href="http://jasonwryan.com/blog/2012/04/21/lbdb/" target="_blank">Using Mutt, LDAP and SSL</a>

- <a href="http://www.christianschenk.org/blog/integrating-ldap-into-mutt/" target="_blank">Integrating LDAP into Mutt</a>
