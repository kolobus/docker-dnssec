DN42 Modifications & misc
################

This fork adds DN42 env variable, which includes conf options essential for DN42 network: DNSSEC validation exception and .dn42 forwarders.

Changes:

- DN42=true will include DNSEC options required for DN42 and corresponding zones
- Modified mkzone file to add SRV records, which is now in a separate repo
- Changed default resolvers to CloudFlare IPv4/IPv6
- Upgraded python3 packages to correct (new) system-wide install

ToDo:

- Keys permission issue (see below)
- Validate reverse zones with CIDR notation used in DN42

DNSSEC Container
################

This is a rootless container running bind on alpine.
DNSSEC can be activated very easy over env variables.


Env Variables
#############

+--------------------+---------------------------------------------------------------------------------------+------------------+
| Name               | Description                                                                           | Default Value    |
+--------------------+---------------------------------------------------------------------------------------+------------------+
| ALLOW_RECURSION_IP | IP Source Range where you allow recursive queries from. Defaults to podman network.   | 10.0.2.0/24      |
+--------------------+---------------------------------------------------------------------------------------+------------------+
| FORWARDER_[0-9]    | DNS Server you want to forward unknown requests to. Up to 9 upstream servers possible.| 208.67.222.123   |
|                    | Defaults to Servers from https://www.opendns.com/                                     | 208.67.220.123   |
+--------------------+---------------------------------------------------------------------------------------+------------------+
| DNSSEC             | Wheter you want activate or deactivate dnssec. Defaults to true                       | true             |
+--------------------+---------------------------------------------------------------------------------------+------------------+
| SALT               | The salt dnssec-signzone is using to sign your zones.                                 | 7d70b91db47137cd |
|                    | Can be obtained by ```head -c 1000 /dev/random | sha1sum | cut -b 1-16```             |                  |
|                    | DO NOT USE THE DEFAULT SALT, THIS IS UNSECURE                                         |                  |
+--------------------+---------------------------------------------------------------------------------------+------------------+
| DN42               | Enable DN42 named.conf options - DNSSEC exception and .dn42 zones                     | false            |
+--------------------+---------------------------------------------------------------------------------------+------------------+

Volumes
#######

If you are using podman, consider your uid-maps. Withing the container, you are user "uid=100(named) gid=101(named) groups=101(named)"
https://www.redhat.com/sysadmin/rootless-podman-user-namespace-modes

- /domains - The yaml file mkzone is using to generate your zone files
- /var/bind/keys - Your private keys to sign your zones. Those are generated at startup using your salt if not existent.

Ports
#####

In order to run as user named within the container, this image is listenting on port 5353.
Map this either in podman itself or use redir or anything similar.

- https://github.com/containers/podman/blob/main/rootless.md

Development
###########

Execute ```./build-and-run.sh``` should build the container locally using podman and run it with the default values for testing.
The container is called "dnssec"

Debug
#####

- Wont start properly
  Add a sleep 50000 in the entrypoint.sh and debug the running container then
  ```podman exec -it dnssec named-checkconf /etc/bind/named.conf```

  
- Permission issues in mounted volumes ```chown -R 100099 $PWD/domainKeys # (uid(100) within container)```


Useful links
############

- https://github.com/mfs/mkzone/blob/master/mkzone
- https://securitytrails.com/blog/dns-servers-privacy-security
