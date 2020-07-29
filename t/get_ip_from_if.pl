use Test::More;
use B qw(perlstring);

SKIP: { eval { require Test::Warnings; } or skip($@, 1); }
eval { require 'ddclient'; } or BAIL_OUT($@);

# To aid in debugging, uncomment the following lines. (They are normally left commented to avoid
# accidentally interfering with the Test Anything Protocol messages written by Test::More.)
#STDOUT->autoflush(1);
#$ddclient::globals{'debug'} = 1;

my @default_if_tests = (
    # Outputs from ip route and netstat commands to find default route (and therefore interface)
    # Samples from Ubuntu 20.04, RHEL8, Buildroot, Busybox, MacOS 10.15, FreeBSD
    # NOTE: Any tabs/whitespace at start or end of lines are intentional to match real life data.
    {   name => "ip -4 -o route list match default (most linux)",
        ipver => 4,
        want => "ens33",
        text => <<EOF, },
default via 192.168.100.1 dev ens33 proto dhcp metric 100 
EOF
    {   name => "ip -4 -o route list match default (most linux)",
        ipver => 4,
        want => "ens33",
        text => <<EOF, },
default via fe80::4262:31ff:fe08:60b3 dev ens33 proto ra metric 20100 pref medium
EOF
    {   name => "ip -4 -o route list match default (buildroot)",
        ipver => 4,
        want => "eth0",
        text => <<EOF, },
default via 192.168.156.1 dev eth0 
EOF
    {   name => "ip -6 -o route list match default (buildroot)",
        ipver => 6,
        want => "eth0",
        text => <<EOF, },
default via fe80::1ee8:5dff:fef4:b822 dev eth0  proto ra  metric 1024  expires 1797sec mtu 1500 hoplimit 64
EOF
    {   name => "netstat -rn -4 (most linux)",
        ipver => 4,
        want => "ens33",
        text => <<EOF, },
Kernel IP routing table
Destination     Gateway         Genmask         Flags   MSS Window  irtt Iface
0.0.0.0         192.168.100.1    0.0.0.0         UG        0 0          0 ens33
169.254.0.0     0.0.0.0         255.255.0.0     U         0 0          0 ens33
192.168.100.0    0.0.0.0         255.255.255.0   U         0 0          0 ens33
EOF
    {   name => "netstat -rn -6 (most linux)",
        ipver => 6,
        want => "ens33",
        text => <<EOF, },
Kernel IPv6 routing table
Destination                    Next Hop                   Flag Met Ref Use If
::1/128                        ::                         U    256 2     0 lo
2001:db8:450a:e723::21/128     ::                         U    100 1     0 ens33
2001:db8:450a:e723::/64        ::                         U    100 4     0 ens33
fdb6:1d86:d9bd:3::21/128       ::                         U    100 1     0 ens33
fdb6:1d86:d9bd:3::/64          ::                         U    100 3     0 ens33
fe80::/64                      ::                         U    100 2     0 ens33
::/0                           fe80::4262:31ff:fe08:60b3  UG   20100 5     0 ens33
::1/128                        ::                         Un   0   4     0 lo
2001:db8:450a:e723::21/128     ::                         Un   0   4     0 ens33
2001:db8:450a:e723:514:cbd9:c55f:8e2a/128 ::                         Un   0   4     0 ens33
2001:db8:450a:e723:adee:be82:7fba:ffb2/128 ::                         Un   0   3     0 ens33
2001:db8:450a:e723:dbc5:1c4e:9e9b:97a2/128 ::                         Un   0   3     0 ens33
fdb6:1d86:d9bd:3::21/128       ::                         Un   0   2     0 ens33
fdb6:1d86:d9bd:3:514:cbd9:c55f:8e2a/128 ::                         Un   0   5     0 ens33
fdb6:1d86:d9bd:3:a1fd:1ed9:6211:4268/128 ::                         Un   0   4     0 ens33
fdb6:1d86:d9bd:3:adee:be82:7fba:ffb2/128 ::                         Un   0   2     0 ens33
fe80::32c0:b270:245b:d3b4/128  ::                         Un   0   3     0 ens33
ff00::/8                       ::                         U    256 7     0 ens33
::/0                           ::                         !n   -1  1     0 lo
EOF
    {   name => "netstat -rn -f inet (MacOS)",
        ipver => 4,
        want => "en0",
        text => <<EOF, },
Routing tables

Internet:
Destination        Gateway            Flags        Netif Expire
default            192.168.100.1       UGSc           en0       
default            192.168.100.1       UGScI          en1       
127                127.0.0.1          UCS            lo0       
127.0.0.1          127.0.0.1          UH             lo0       
169.254            link#4             UCS            en0      !
169.254            link#5             UCSI           en1      !
172.16.114/24      link#15            UC          vmnet8      !
172.16.114.1       0:50:56:c0:0:8     UHLWIi         lo0       
172.16.114.255     ff:ff:ff:ff:ff:ff  UHLWbI      vmnet8      !
192.168.17         link#4             UCS            en0      !
192.168.17         link#5             UCSI           en1      !
192.168.100.1/32    link#4             UCS            en0      !
192.168.100.1       40:62:31:8:60:b3   UHLWIir        en0   1180
192.168.100.1       40:62:31:8:60:b3   UHLWIir        en1   1160
192.168.100.1/32    link#5             UCSI           en1      !
192.168.100.2       0:c:29:47:b8:d1    UHLWI          en0   1108
192.168.100.5/32    link#4             UCS            en0      !
192.168.100.5       00:00:00:90:32:8f  UHLWIi         lo0       
192.168.100.5       00:00:00:90:32:8f  UHLWI          en1   1182
192.168.100.6       0:8:9b:ee:d4:e     UHLWIi         en0    158
192.168.100.12      0:c:29:70:89:8b    UHLWI          en0   1107
192.168.100.33      0:c:29:da:24:b1    UHLWI          en0   1108
192.168.100.34      0:c:29:6d:aa:8b    UHLWI          en0   1107
192.168.100.137     70:ea:5a:79:45:4b  UHLWI          en0    317
192.168.100.137     70:ea:5a:79:45:4b  UHLWI          en1    561
192.168.100.152     8c:79:67:a7:c4:45  UHLWI          en0    376
192.168.100.155     f0:18:98:29:ef:a3  UHLWIi         en0    694
192.168.100.167     a0:2:dc:f7:7a:9a   UHLWI          en0   1160
192.168.100.167     a0:2:dc:f7:7a:9a   UHLWI          en1   1161
192.168.100.184     8:66:98:92:0:55    UHLWIi         en0    644
192.168.100.187     link#4             UHLWIi         en0      !
192.168.100.187     link#5             UHLWIi         en1      !
192.168.100.199/32  link#5             UCS            en1      !
192.168.100.199     c8:e0:eb:42:96:eb  UHLWIi         lo0       
192.168.100.201     90:e1:7b:b9:e5:38  UHLWI          en0   1182
192.168.100.201     90:e1:7b:b9:e5:38  UHLWI          en1   1182
192.168.100.210     0:61:71:cd:0:10    UHLWI          en0    112
192.168.100.210     0:61:71:cd:0:10    UHLWI          en1    112
192.168.100.211     8c:85:90:55:49:a7  UHLWIi         en0    762
192.168.100.211     8c:85:90:55:49:a7  UHLWI          en1    762
192.168.100.240     f0:18:98:20:f9:d7  UHLWIi         en0   1172
192.168.100.240     f0:18:98:20:f9:d7  UHLWIi         en1   1173
192.168.100.241     e0:33:8e:38:44:3   UHLWIi         en0    961
192.168.100.241     e0:33:8e:38:44:3   UHLWI          en1    961
192.168.100.242     98:1:a7:49:1e:1c   UHLWIi         en0    899
192.168.100.242     98:1:a7:49:1e:1c   UHLWIi         en1    899
192.168.100.255     ff:ff:ff:ff:ff:ff  UHLWbI         en0      !
192.168.196        link#14            UC          vmnet1      !
192.168.196.1      0:50:56:c0:0:1     UHLWIi         lo0       
192.168.196.255    ff:ff:ff:ff:ff:ff  UHLWbI      vmnet1      !
224.0.0/4          link#4             UmCS           en0      !
224.0.0/4          link#5             UmCSI          en1      !
224.0.0.251        1:0:5e:0:0:fb      UHmLWI         en0       
224.0.0.251        1:0:5e:0:0:fb      UHmLWI         en1       
239.255.255.250    1:0:5e:7f:ff:fa    UHmLWI         en0       
239.255.255.250    1:0:5e:7f:ff:fa    UHmLWI         en1       
255.255.255.255/32 link#4             UCS            en0      !
255.255.255.255    ff:ff:ff:ff:ff:ff  UHLWbI         en0      !
255.255.255.255/32 link#5             UCSI           en1      !
EOF
    {   name => "netstat -rn -f inet6 (MacOS)",
        ipver => 6,
        want => "en0",
        text => <<EOF, },
Routing tables

Internet6:
Destination                             Gateway                         Flags         Netif Expire
default                                 fe80::4262:31ff:fe08:60b3%en0   UGc             en0       
default                                 fe80::4262:31ff:fe08:60b3%en1   UGcI            en1       
default                                 fe80::%utun0                    UGcI          utun0       
default                                 fe80::%utun1                    UGcI          utun1       
::1                                     ::1                             UHL             lo0       
2001:db8:450a:e723::/64                 link#4                          UC              en0       
2001:db8:450a:e723::/64                 link#5                          UCI             en1       
2001:db8:450a:e723::1                   40:62:31:8:60:b3                UHLWIi          en0       
2001:db8:450a:e723:208:9bff:feee:d40e   0:8:9b:ee:d4:e                  UHLWI           en0       
2001:db8:450a:e723:208:9bff:feee:d40f   0:8:9b:ee:d4:f                  UHLWI           en0       
2001:db8:450a:e723:881:db49:835c:e83e   c8:e0:eb:42:96:eb               UHL             lo0       
2001:db8:450a:e723:1820:2961:5878:fb72  c8:e0:eb:42:96:eb               UHL             lo0       
2001:db8:450a:e723:1c99:99e2:21d0:79e6  00:00:00:90:32:8f               UHL             lo0       
2001:db8:450a:e723:2474:39fd:f5c0:6845  00:00:00:90:32:8f               UHL             lo0       
2001:db8:450a:e723:808d:d894:e4db:157e  00:00:00:90:32:8f               UHL             lo0       
2001:db8:450a:e723:9022:cdf6:728c:81cc  c8:e0:eb:42:96:eb               UHL             lo0       
fdb6:1d86:d9bd:3::/64                   link#4                          UC              en0       
fdb6:1d86:d9bd:3::/64                   link#5                          UCI             en1       
fdb6:1d86:d9bd:3::1                     40:62:31:8:60:b3                UHLWI           en0       
fdb6:1d86:d9bd:3::8076                  00:00:00:90:32:8f               UHL             lo0       
fdb6:1d86:d9bd:3::85ba                  c8:e0:eb:42:96:eb               UHL             lo0       
fdb6:1d86:d9bd:3:208:9bff:feee:d40e     0:8:9b:ee:d4:e                  UHLWI           en0       
fdb6:1d86:d9bd:3:208:9bff:feee:d40f     0:8:9b:ee:d4:f                  UHLWI           en0       
fdb6:1d86:d9bd:3:837:e1c7:4895:269e     00:00:00:90:32:8f               UHL             lo0       
fdb6:1d86:d9bd:3:8a5:4e16:4924:ca7d     c8:e0:eb:42:96:eb               UHL             lo0       
fdb6:1d86:d9bd:3:dbb:dd72:928a:1f4      c8:e0:eb:42:96:eb               UHL             lo0       
fdb6:1d86:d9bd:3:2474:39fd:f5c0:6845    00:00:00:90:32:8f               UHL             lo0       
fdb6:1d86:d9bd:3:9022:cdf6:728c:81cc    c8:e0:eb:42:96:eb               UHL             lo0       
fdb6:1d86:d9bd:3:a0b3:aa4d:9e76:e1ab    00:00:00:90:32:8f               UHL             lo0       
fe80::%lo0/64                           fe80::1%lo0                     UcI             lo0       
fe80::1%lo0                             link#1                          UHLI            lo0       
fe80::%en0/64                           link#4                          UCI             en0       
fe80::2e:996d:54e6:daa0%en0             70:ea:5a:79:45:4b               UHLWI           en0       
fe80::208:9bff:feee:d40f%en0            0:8:9b:ee:d4:f                  UHLWI           en0       
fe80::4ba:362c:664:c432%en0             7c:a1:ae:f:4:f4                 UHLWI           en0       
fe80::85b:d150:cdd9:3198%en0            00:00:00:90:32:8f               UHLI            lo0       
fe80::8f2:20e6:a10b:3cdd%en0            70:56:81:ba:5f:37               UHLWI           en0       
fe80::c20:19a:2ac2:79a1%en0             cc:d2:81:5a:8d:ee               UHLWI           en0       
fe80::10e4:937a:51ce:a8d9%en0           f0:18:98:29:ef:a3               UHLWI           en0       
fe80::142a:3ac5:7cb9:2218%en0           90:e1:7b:b9:e5:38               UHLWI           en0       
fe80::1445:78b9:1d5c:11eb%en0           c8:e0:eb:42:96:eb               UHLWI           en0       
fe80::1450:3f80:6143:4f7c%en0           b8:e8:56:a3:67:5                UHLWI           en0       
fe80::18d5:2b64:b66b:88b%en0            e0:33:8e:38:44:3                UHLWI           en0       
fe80::1c88:3c7:f97b:e538%en0            98:1:a7:49:1e:1c                UHLWIi          en0       
fe80::4262:31ff:fe08:60b3%en0           40:62:31:8:60:b3                UHLWIir         en0       
fe80::%en1/64                           link#5                          UCI             en1       
fe80::2e:996d:54e6:daa0%en1             70:ea:5a:79:45:4b               UHLWI           en1       
fe80::70:2494:f602:7479%en1             0:61:71:cd:0:10                 UHLWI           en1       
fe80::4ba:362c:664:c432%en1             7c:a1:ae:f:4:f4                 UHLWI           en1       
fe80::85b:d150:cdd9:3198%en1            00:00:00:90:32:8f               UHLWI           en1       
fe80::8f2:20e6:a10b:3cdd%en1            70:56:81:ba:5f:37               UHLWI           en1       
fe80::c20:19a:2ac2:79a1%en1             cc:d2:81:5a:8d:ee               UHLWI           en1       
fe80::1445:78b9:1d5c:11eb%en1           c8:e0:eb:42:96:eb               UHLI            lo0       
fe80::18d5:2b64:b66b:88b%en1            e0:33:8e:38:44:3                UHLWI           en1       
fe80::1c88:3c7:f97b:e538%en1            98:1:a7:49:1e:1c                UHLWIi          en1       
fe80::4262:31ff:fe08:60b3%en1           40:62:31:8:60:b3                UHLWIir         en1       
fe80::%awdl0/64                         link#10                         UCI           awdl0       
fe80::54df:1aff:fee1:2df5%awdl0         56:df:1a:e1:2d:f5               UHLI            lo0       
fe80::%llw0/64                          link#11                         UCI            llw0       
fe80::54df:1aff:fee1:2df5%llw0          56:df:1a:e1:2d:f5               UHLI            lo0       
fe80::%utun0/64                         fe80::aeea:9fe9:9194:6e66%utun0 UcI           utun0       
fe80::aeea:9fe9:9194:6e66%utun0         link#12                         UHLI            lo0       
fe80::%utun1/64                         fe80::583f:da5f:e2bc:4773%utun1 UcI           utun1       
fe80::583f:da5f:e2bc:4773%utun1         link#13                         UHLI            lo0       
ff01::%lo0/32                           ::1                             UmCI            lo0       
ff01::%en0/32                           link#4                          UmCI            en0       
ff01::%en1/32                           link#5                          UmCI            en1       
ff01::%awdl0/32                         link#10                         UmCI          awdl0       
ff01::%llw0/32                          link#11                         UmCI           llw0       
ff01::%utun0/32                         fe80::aeea:9fe9:9194:6e66%utun0 UmCI          utun0       
ff01::%utun1/32                         fe80::583f:da5f:e2bc:4773%utun1 UmCI          utun1       
ff02::%lo0/32                           ::1                             UmCI            lo0       
ff02::%en0/32                           link#4                          UmCI            en0       
ff02::%en1/32                           link#5                          UmCI            en1       
ff02::%awdl0/32                         link#10                         UmCI          awdl0       
ff02::%llw0/32                          link#11                         UmCI           llw0       
ff02::%utun0/32                         fe80::aeea:9fe9:9194:6e66%utun0 UmCI          utun0       
ff02::%utun1/32                         fe80::583f:da5f:e2bc:4773%utun1 UmCI          utun1   
EOF
);
        
my @get_ip_tests = (
    # Outputs from ip addr and ifconfig commands to find IP address from IF name
    # Samples from Ubuntu 20.04, RHEL8, Buildroot, Busybox, MacOS 10.15, FreeBSD
    # NOTE: Any tabs/whitespace at start or end of lines are intentional to match real life data.
    {   name => "ip -4 -o addr show dev ens33 scope global (most linux IPv4)",
        ipver => 4,
        scope => undef,
        want => "192.168.100.33",
        text => <<EOF, },
2: ens33    inet 192.168.100.33/24 brd 192.168.100.255 scope global dynamic noprefixroute ens33\       valid_lft 77760sec preferred_lft 77760sec
EOF
    {   name => "ip -6 -o addr show dev ens33 scope global (most linux)",
        ipver => 6,
        scope => "gua",
        want => "2001:db8:450a:e723::21",
        text => <<EOF, },
2: ens33    inet6 2001:db8:450a:e723:adee:be82:7fba:ffb2/64 scope global temporary dynamic \       valid_lft 86282sec preferred_lft 81094sec
2: ens33    inet6 fdb6:1d86:d9bd:3:adee:be82:7fba:ffb2/64 scope global temporary dynamic \       valid_lft 86282sec preferred_lft 81094sec
2: ens33    inet6 fdb6:1d86:d9bd:3::21/128 scope global dynamic noprefixroute \       valid_lft 76832sec preferred_lft 76832sec
2: ens33    inet6 2001:db8:450a:e723::21/128 scope global dynamic noprefixroute \       valid_lft 76832sec preferred_lft 76832sec
2: ens33    inet6 fdb6:1d86:d9bd:3:514:cbd9:c55f:8e2a/64 scope global temporary deprecated dynamic \       valid_lft 86282sec preferred_lft 0sec
2: ens33    inet6 fdb6:1d86:d9bd:3:a1fd:1ed9:6211:4268/64 scope global dynamic mngtmpaddr noprefixroute \       valid_lft 86282sec preferred_lft 86282sec
2: ens33    inet6 2001:db8:450a:e723:514:cbd9:c55f:8e2a/64 scope global temporary deprecated dynamic \       valid_lft 86282sec preferred_lft 0sec
2: ens33    inet6 2001:db8:450a:e723:dbc5:1c4e:9e9b:97a2/64 scope global dynamic mngtmpaddr noprefixroute \       valid_lft 86282sec preferred_lft 86282sec
EOF
    {   name => "ip -6 -o addr show dev ens33 scope global (most linux IPv6 ULA)",
        ipver => 6,
        scope => "ula",
        want => "fdb6:1d86:d9bd:3::21",
        text => <<EOF, },
2: ens33    inet6 2001:db8:450a:e723:adee:be82:7fba:ffb2/64 scope global temporary dynamic \       valid_lft 86282sec preferred_lft 81094sec
2: ens33    inet6 fdb6:1d86:d9bd:3:adee:be82:7fba:ffb2/64 scope global temporary dynamic \       valid_lft 86282sec preferred_lft 81094sec
2: ens33    inet6 fdb6:1d86:d9bd:3::21/128 scope global dynamic noprefixroute \       valid_lft 76832sec preferred_lft 76832sec
2: ens33    inet6 2001:db8:450a:e723::21/128 scope global dynamic noprefixroute \       valid_lft 76832sec preferred_lft 76832sec
2: ens33    inet6 fdb6:1d86:d9bd:3:514:cbd9:c55f:8e2a/64 scope global temporary deprecated dynamic \       valid_lft 86282sec preferred_lft 0sec
2: ens33    inet6 fdb6:1d86:d9bd:3:a1fd:1ed9:6211:4268/64 scope global dynamic mngtmpaddr noprefixroute \       valid_lft 86282sec preferred_lft 86282sec
2: ens33    inet6 2001:db8:450a:e723:514:cbd9:c55f:8e2a/64 scope global temporary deprecated dynamic \       valid_lft 86282sec preferred_lft 0sec
2: ens33    inet6 2001:db8:450a:e723:dbc5:1c4e:9e9b:97a2/64 scope global dynamic mngtmpaddr noprefixroute \       valid_lft 86282sec preferred_lft 86282sec
EOF
    {   name => "ip -6 -o addr show dev ens33 scope global (most linux static IPv6)",
        ipver => 6,
        scope => undef,
        want => "2001:db8:450a:e723::101",
        text => <<EOF, },
2: ens33    inet6 2001:db8:450a:e723::101/64 scope global noprefixroute \       valid_lft forever preferred_lft forever
EOF
    {   name => "ifconfig ens33 (most linux autoconf IPv6)",
        ipver => 6,
        scope => undef,
        want => "2001:db8:450a:e723::21",
        text => <<EOF, },
ens33: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 192.168.100.33  netmask 255.255.255.0  broadcast 192.168.100.255
        inet6 fdb6:1d86:d9bd:3::21  prefixlen 128  scopeid 0x0<global>
        inet6 fe80::32c0:b270:245b:d3b4  prefixlen 64  scopeid 0x20<link>
        inet6 fdb6:1d86:d9bd:3:a1fd:1ed9:6211:4268  prefixlen 64  scopeid 0x0<global>
        inet6 2001:db8:450a:e723:adee:be82:7fba:ffb2  prefixlen 64  scopeid 0x0<global>
        inet6 2001:db8:450a:e723::21  prefixlen 128  scopeid 0x0<global>
        inet6 fdb6:1d86:d9bd:3:adee:be82:7fba:ffb2  prefixlen 64  scopeid 0x0<global>
        inet6 2001:db8:450a:e723:dbc5:1c4e:9e9b:97a2  prefixlen 64  scopeid 0x0<global>
        ether 00:00:00:da:24:b1  txqueuelen 1000  (Ethernet)
        RX packets 3782541  bytes 556082941 (556.0 MB)
        RX errors 0  dropped 513  overruns 0  frame 0
        TX packets 33294  bytes 6838768 (6.8 MB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0
EOF
    {   name => "ifconfig ens33 (most linux DHCPv6 only GUA)",
        ipver => 6,
        scope => "gua",
        want => "2001:db8:450a:e723::21",
        text => <<EOF, },
ens33: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 192.168.100.33  netmask 255.255.255.0  broadcast 192.168.100.255
        inet6 fdb6:1d86:d9bd:3::21  prefixlen 128  scopeid 0x0<global>
        inet6 fe80::32c0:b270:245b:d3b4  prefixlen 64  scopeid 0x20<link>
        inet6 2001:db8:450a:e723::21  prefixlen 128  scopeid 0x0<global>
        ether 00:00:00:da:24:b1  txqueuelen 1000  (Ethernet)
        RX packets 3781554  bytes 555602847 (555.6 MB)
        RX errors 0  dropped 513  overruns 0  frame 0
        TX packets 32493  bytes 6706131 (6.7 MB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0
EOF
    {   name => "ifconfig ens33 (most linux static IPv6)",
        ipver => 6,
        scope => undef,
        want => "2001:db8:450a:e723::101",
        text => <<EOF, },
ens33: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 192.168.100.33  netmask 255.255.255.0  broadcast 192.168.100.255
        inet6 fe80::32c0:b270:245b:d3b4  prefixlen 64  scopeid 0x20<link>
        inet6 2001:db8:450a:e723::101  prefixlen 64  scopeid 0x0<global>
        ether 00:00:00:da:24:b1  txqueuelen 1000  (Ethernet)
        RX packets 3780219  bytes 554967876 (554.9 MB)
        RX errors 0  dropped 513  overruns 0  frame 0
        TX packets 31556  bytes 6552122 (6.5 MB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0
EOF
    {   name => "ifconfig ens33 (most linux DHCPv6 only ULA)",
        ipver => 6,
        scope => "ula",
        want => "fdb6:1d86:d9bd:3::21",
        text => <<EOF, },
ens33: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 192.168.100.33  netmask 255.255.255.0  broadcast 192.168.100.255
        inet6 fdb6:1d86:d9bd:3::21  prefixlen 128  scopeid 0x0<global>
        inet6 fe80::32c0:b270:245b:d3b4  prefixlen 64  scopeid 0x20<link>
        inet6 2001:db8:450a:e723::21  prefixlen 128  scopeid 0x0<global>
        ether 00:00:00:da:24:b1  txqueuelen 1000  (Ethernet)
        RX packets 3781554  bytes 555602847 (555.6 MB)
        RX errors 0  dropped 513  overruns 0  frame 0
        TX packets 32493  bytes 6706131 (6.7 MB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0
EOF
        {   name => "ifconfig ens33 (most linux IPv4)",
        ipver => 4,
        scope => undef,
        want => "192.168.100.33",
        text => <<EOF, },
ens33: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 192.168.100.33  netmask 255.255.255.0  broadcast 192.168.100.255
        inet6 fdb6:1d86:d9bd:3::21  prefixlen 128  scopeid 0x0<global>
        inet6 fe80::32c0:b270:245b:d3b4  prefixlen 64  scopeid 0x20<link>
        inet6 2001:db8:450a:e723::21  prefixlen 128  scopeid 0x0<global>
        ether 00:00:00:da:24:b1  txqueuelen 1000  (Ethernet)
        RX packets 3781554  bytes 555602847 (555.6 MB)
        RX errors 0  dropped 513  overruns 0  frame 0
        TX packets 32493  bytes 6706131 (6.7 MB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0
EOF
    {   name => "ifconfig en0 (MacOS IPv4)",
        ipver => 4,
        scope => undef,
        want => "192.168.100.5",
        text => <<EOF, },
en0: flags=8963<UP,BROADCAST,SMART,RUNNING,PROMISC,SIMPLEX,MULTICAST> mtu 9000
	options=50b<RXCSUM,TXCSUM,VLAN_HWTAGGING,AV,CHANNEL_IO>
	ether 00:00:00:90:32:8f 
	inet6 fe80::85b:d150:cdd9:3198%en0 prefixlen 64 secured scopeid 0x4 
	inet6 2001:db8:450a:e723:1c99:99e2:21d0:79e6 prefixlen 64 autoconf secured 
	inet6 2001:db8:450a:e723:808d:d894:e4db:157e prefixlen 64 deprecated autoconf temporary 
	inet6 fdb6:1d86:d9bd:3:837:e1c7:4895:269e prefixlen 64 autoconf secured 
	inet6 fdb6:1d86:d9bd:3:a0b3:aa4d:9e76:e1ab prefixlen 64 deprecated autoconf temporary 
	inet 192.168.100.5 netmask 0xffffff00 broadcast 192.168.100.255
	inet6 2001:db8:450a:e723:2474:39fd:f5c0:6845 prefixlen 64 autoconf temporary 
	inet6 fdb6:1d86:d9bd:3:2474:39fd:f5c0:6845 prefixlen 64 autoconf temporary 
	inet6 fdb6:1d86:d9bd:3::8076 prefixlen 64 dynamic 
	nd6 options=201<PERFORMNUD,DAD>
	media: 1000baseT <full-duplex,flow-control,energy-efficient-ethernet>
	status: active
EOF
    {   name => "ifconfig -L en0 (MacOS autoconf IPv6)",
        ipver => 6,
        scope => undef,
        MaxOS => 1,
        want => "2001:db8:450a:e723:1c99:99e2:21d0:79e6",
        text => <<EOF, },
en0: flags=8963<UP,BROADCAST,SMART,RUNNING,PROMISC,SIMPLEX,MULTICAST> mtu 9000
	options=50b<RXCSUM,TXCSUM,VLAN_HWTAGGING,AV,CHANNEL_IO>
	ether 00:00:00:90:32:8f 
	inet6 fe80::85b:d150:cdd9:3198%en0 prefixlen 64 secured scopeid 0x4 
	inet6 2001:db8:450a:e723:1c99:99e2:21d0:79e6 prefixlen 64 autoconf secured pltime 86205 vltime 86205 
	inet6 2001:db8:450a:e723:808d:d894:e4db:157e prefixlen 64 deprecated autoconf temporary pltime 0 vltime 86205 
	inet6 fdb6:1d86:d9bd:3:837:e1c7:4895:269e prefixlen 64 autoconf secured pltime 86205 vltime 86205 
	inet6 fdb6:1d86:d9bd:3:a0b3:aa4d:9e76:e1ab prefixlen 64 deprecated autoconf temporary pltime 0 vltime 86205 
	inet 192.168.100.5 netmask 0xffffff00 broadcast 192.168.100.255
	inet6 2001:db8:450a:e723:2474:39fd:f5c0:6845 prefixlen 64 autoconf temporary pltime 76882 vltime 86205 
	inet6 fdb6:1d86:d9bd:3:2474:39fd:f5c0:6845 prefixlen 64 autoconf temporary pltime 76882 vltime 86205 
	inet6 fdb6:1d86:d9bd:3::8076 prefixlen 64 dynamic pltime 78010 vltime 78010 
	nd6 options=201<PERFORMNUD,DAD>
	media: 1000baseT <full-duplex,flow-control,energy-efficient-ethernet>
	status: active
EOF
    {   name => "ifconfig -L en0 (MacOS static IPv6)",
        ipver => 6,
        scope => undef,
        MaxOS => 1,
        want => "2001:db8:450a:e723::100",
        text => <<EOF, },
en1: flags=8863<UP,BROADCAST,SMART,RUNNING,SIMPLEX,MULTICAST> mtu 1500
	options=400<CHANNEL_IO>
	ether 00:00:00:42:96:eb 
	inet 192.168.100.199 netmask 0xffffff00 broadcast 192.168.100.255
	inet6 fe80::1445:78b9:1d5c:11eb%en1 prefixlen 64 secured scopeid 0x5 
	inet6 2001:db8:450a:e723::100 prefixlen 64 
	nd6 options=201<PERFORMNUD,DAD>
	media: autoselect
	status: active
EOF
    {   name => "ip -4 -o addr show dev eth0 scope global (Buildroot IPv4)",
        ipver => 4,
        scope => undef,
        want => "192.168.157.237",
        text => <<EOF, },
2: eth0    inet 192.168.157.237/22 brd 255.255.255.255 scope global eth0\       valid_lft forever preferred_lft forever
EOF
    {   name => "ip -6 -o addr show dev eth0 scope global (Buildroot IPv6)",
        ipver => 6,
        scope => undef,
        want => "2001:db8:450b:13f:ed44:eb63:b070:212f",
        text => <<EOF, },
2: eth0    inet6 2001:db8:450b:13f:ed44:eb63:b070:212f/128 scope global \       valid_lft forever preferred_lft forever
EOF
    {   name => "ifconfig eth0 (Busybox IPv4)",
        ipver => 4,
        scope => undef,
        want => "192.168.157.237",
        text => <<EOF, },
eth0      Link encap:Ethernet  HWaddr 00:00:00:08:60:B4  
          inet addr:192.168.157.237  Bcast:255.255.255.255  Mask:255.255.252.0
          inet6 addr: fe80::4262:31ff:fe08:60b4/64 Scope:Link
          inet6 addr: 2001:db8:450b:13f:ed44:eb63:b070:212f/128 Scope:Global
          UP BROADCAST RUNNING MULTICAST  MTU:9000  Metric:1
          RX packets:33209620 errors:0 dropped:0 overruns:0 frame:0
          TX packets:14638979 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000 
          RX bytes:41724254079 (38.8 GiB)  TX bytes:3221012240 (2.9 GiB)
EOF
    {   name => "ifconfig eth0 (Busybox IPv6)",
        ipver => 6,
        scope => undef,
        want => "2001:db8:450b:13f:ed44:eb63:b070:212f",
        text => <<EOF, },
eth0      Link encap:Ethernet  HWaddr 00:00:00:08:60:B4  
          inet addr:192.168.157.237  Bcast:255.255.255.255  Mask:255.255.252.0
          inet6 addr: fe80::4262:31ff:fe08:60b4/64 Scope:Link
          inet6 addr: 2001:db8:450b:13f:ed44:eb63:b070:212f/128 Scope:Global
          UP BROADCAST RUNNING MULTICAST  MTU:9000  Metric:1
          RX packets:33209620 errors:0 dropped:0 overruns:0 frame:0
          TX packets:14638979 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000 
          RX bytes:41724254079 (38.8 GiB)  TX bytes:3221012240 (2.9 GiB)
EOF
);

subtest "get_default_interface tests" => sub {
    for my $sample (@default_if_tests) {
        subtest $sample->{name} => sub {
            my $interface = ddclient::get_default_interface($sample->{ipver}, $sample->{text});
            is($interface, $sample->{want}, $sample->{name});
        }
    }
};

subtest "get_ip_from_interface tests" => sub {
    for my $sample (@get_ip_tests) {
        subtest $sample->{name} => sub {
            # intface name is undef as we are passing in test data
            my $ip = ddclient::get_ip_from_interface(undef, $sample->{ipver}, $sample->{scope}, $sample->{text}, $sample->{MacOS});
            is($ip, $sample->{want}, $sample->{name});
        }
    }
};

done_testing();
