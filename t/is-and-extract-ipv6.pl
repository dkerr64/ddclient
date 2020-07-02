use Test::More;

SKIP: { eval { require Test::Warnings; } or skip($@, 1); }
eval { require 'ddclient'; } or BAIL_OUT($@);

# Note, for GUA addresses we use 2001:DB8::/32 as that is reserved for
# documentation per RFC 3849 and so not routable on public internet.
# But we do have to add some others starting in 3xxx:: because they 
# are also valid GUA.
my @valid_ipv6_gua = (
    "2000::",
    "2001:DB8:4341:0781:1111:2222:3333:4444",
    "2001:DB8:4341:0781::4444",
    "2001:DB8:4341:0781:1111::",
    "2001:DB8:4341:0781::100",
    "2001:DB8:4341:0781::1",
    "2001:DB8:4341:0781::0001",
    "2fff:ffff:ffff:ffff:ffff:ffff:ffff:ffff",
    "3000::",
    "3001:DB8:4341:0781:1111:2222:3333:4444",
    "3001:DB8:4341:0781::4444",
    "3001:DB8:4341:0781:1111::",
    "3001:DB8:4341:0781::100",
    "3001:DB8:4341:0781::1",
    "3001:DB8:4341:0781::0001",
    "3fff:ffff:ffff:ffff:ffff:ffff:ffff:ffff",
);

# For ULA addresses we randomly generated a /48 prefix per RFC 4193
# and are using subnet ID of 1 because why not.
my @valid_ipv6_ula = (
    "fd00::",
    "fdb6:1d86:d9bd:1:1111:2222:3333:4444",
    "fdb6:1d86:d9bd:1::4444",
    "fdb6:1d86:d9bd:1:1111::",
    "fdb6:1d86:d9bd:1::100",
    "fdb6:1d86:d9bd:1::1",
    "fdb6:1d86:d9bd:1::0001",
    "fdff:ffff:ffff:ffff:ffff:ffff:ffff:ffff",
);

# 
my @valid_ipv6_lla = (
    "fe80::",
    "fe80::1111:2222:3333:4444",
    "fe80::4444",
    "fe80::1111",
    "febf:ffff:ffff:ffff:ffff:ffff:ffff:ffff",
);

my @valid_ipv6 = (
    # with thanks to http://home.deds.nl/~aeron/regex/valid_ipv6.txt
    "1111:2222:3333:4444:5555:6666:7777:8888",
    "1111:2222:3333:4444:5555:6666:7777::",
    "1111:2222:3333:4444:5555:6666::",
    "1111:2222:3333:4444:5555::",
    "1111:2222:3333:4444::",
    "1111:2222:3333::",
    "1111:2222::",
    "1111::",
    "::",
    "1111:2222:3333:4444:5555:6666::8888",
    "1111:2222:3333:4444:5555::8888",
    "1111:2222:3333:4444::8888",
    "1111:2222:3333::8888",
    "1111:2222::8888",
    "1111::8888",
    "::8888",
    "1111:2222:3333:4444:5555::7777:8888",
    "1111:2222:3333:4444::7777:8888",
    "1111:2222:3333::7777:8888",
    "1111:2222::7777:8888",
    "1111::7777:8888",
    "::7777:8888",
    "1111:2222:3333:4444::6666:7777:8888",
    "1111:2222:3333::6666:7777:8888",
    "1111:2222::6666:7777:8888",
    "1111::6666:7777:8888",
    "::6666:7777:8888",
    "1111:2222:3333::5555:6666:7777:8888",
    "1111:2222::5555:6666:7777:8888",
    "1111::5555:6666:7777:8888",
    "::5555:6666:7777:8888",
    "1111:2222::4444:5555:6666:7777:8888",
    "1111::4444:5555:6666:7777:8888",
    "::4444:5555:6666:7777:8888",
    "1111::3333:4444:5555:6666:7777:8888",
    "::3333:4444:5555:6666:7777:8888",
    "::2222:3333:4444:5555:6666:7777:8888",
);

my @valid_mixed_ipv6 = (
    # with thanks to http://home.deds.nl/~aeron/regex/valid_ipv6.txt
    "1111:2222:3333:4444:5555:6666:123.123.123.123",
    "1111:2222:3333:4444:5555::123.123.123.123",
    "1111:2222:3333:4444::123.123.123.123",
    "1111:2222:3333::123.123.123.123",
    "1111:2222::123.123.123.123",
    "1111::123.123.123.123",
    "::123.123.123.123",
    "1111:2222:3333:4444::6666:123.123.123.123",
    "1111:2222:3333::6666:123.123.123.123",
    "1111:2222::6666:123.123.123.123",
    "1111::6666:123.123.123.123",
    "::6666:123.123.123.123",
    "1111:2222:3333::5555:6666:123.123.123.123",
    "1111:2222::5555:6666:123.123.123.123",
    "1111::5555:6666:123.123.123.123",
    "::5555:6666:123.123.123.123",
    "1111:2222::4444:5555:6666:123.123.123.123",
    "1111::4444:5555:6666:123.123.123.123",
    "::4444:5555:6666:123.123.123.123",
    "1111::3333:4444:5555:6666:123.123.123.123",
    "::3333:4444:5555:6666:123.123.123.123",
    "::2222:3333:4444:5555:6666:123.123.123.123",
);

my @invalid_ipv6 = (
    # With thanks to http://home.deds.nl/~aeron/regex/invalid_ipv6.txt
    # Invalid data
    "XXXX:XXXX:XXXX:XXXX:XXXX:XXXX:XXXX:XXXX",

    # To much components
    "1111:2222:3333:4444:5555:6666:7777:8888:9999",
    "1111:2222:3333:4444:5555:6666:7777:8888::",
    "::2222:3333:4444:5555:6666:7777:8888:9999",

    # To less components
    "1111:2222:3333:4444:5555:6666:7777",
    "1111:2222:3333:4444:5555:6666",
    "1111:2222:3333:4444:5555",
    "1111:2222:3333:4444",
    "1111:2222:3333",
    "1111:2222",
    "1111",

    # Missing :
    "11112222:3333:4444:5555:6666:7777:8888",
    "1111:22223333:4444:5555:6666:7777:8888",
    "1111:2222:33334444:5555:6666:7777:8888",
    "1111:2222:3333:44445555:6666:7777:8888",
    "1111:2222:3333:4444:55556666:7777:8888",
    "1111:2222:3333:4444:5555:66667777:8888",
    "1111:2222:3333:4444:5555:6666:77778888",

    # Missing : intended for ::
    "1111:2222:3333:4444:5555:6666:7777:8888:",
    "1111:2222:3333:4444:5555:6666:7777:",
    "1111:2222:3333:4444:5555:6666:",
    "1111:2222:3333:4444:5555:",
    "1111:2222:3333:4444:",
    "1111:2222:3333:",
    "1111:2222:",
    "1111:",
    ":",
    ":8888",
    ":7777:8888",
    ":6666:7777:8888",
    ":5555:6666:7777:8888",
    ":4444:5555:6666:7777:8888",
    ":3333:4444:5555:6666:7777:8888",
    ":2222:3333:4444:5555:6666:7777:8888",
    ":1111:2222:3333:4444:5555:6666:7777:8888",

    # :::
    ":::2222:3333:4444:5555:6666:7777:8888",
    "1111:::3333:4444:5555:6666:7777:8888",
    "1111:2222:::4444:5555:6666:7777:8888",
    "1111:2222:3333:::5555:6666:7777:8888",
    "1111:2222:3333:4444:::6666:7777:8888",
    "1111:2222:3333:4444:5555:::7777:8888",
    "1111:2222:3333:4444:5555:6666:::8888",
    "1111:2222:3333:4444:5555:6666:7777:::",

    # Double ::
    "::2222::4444:5555:6666:7777:8888",
    "::2222:3333::5555:6666:7777:8888",
    "::2222:3333:4444::6666:7777:8888",
    "::2222:3333:4444:5555::7777:8888",
    "::2222:3333:4444:5555:7777::8888",
    "::2222:3333:4444:5555:7777:8888::",

    "1111::3333::5555:6666:7777:8888",
    "1111::3333:4444::6666:7777:8888",
    "1111::3333:4444:5555::7777:8888",
    "1111::3333:4444:5555:6666::8888",
    "1111::3333:4444:5555:6666:7777::",

    "1111:2222::4444::6666:7777:8888",
    "1111:2222::4444:5555::7777:8888",
    "1111:2222::4444:5555:6666::8888",
    "1111:2222::4444:5555:6666:7777::",

    "1111:2222:3333::5555::7777:8888",
    "1111:2222:3333::5555:6666::8888",
    "1111:2222:3333::5555:6666:7777::",

    "1111:2222:3333:4444::6666::8888",
    "1111:2222:3333:4444::6666:7777::",

    "1111:2222:3333:4444:5555::7777::",

    # Invalid data
    "XXXX:XXXX:XXXX:XXXX:XXXX:XXXX:1.2.3.4",
#    "1111:2222:3333:4444:5555:6666:00.00.00.00",      actually valid
#    "1111:2222:3333:4444:5555:6666:000.000.000.000",  actually valid
    "1111:2222:3333:4444:5555:6666:256.256.256.256",

    # To much components
    "1111:2222:3333:4444:5555:6666:7777:8888:1.2.3",
    "1111:2222:3333:4444:5555:6666:7777:1.2.3.4",
    "1111:2222:3333:4444:5555:6666::1.2.3.4",
    "::2222:3333:4444:5555:6666:7777:1.2.3.4",
    "1111:2222:3333:4444:5555:6666:1.2.3.4.5",

    # To less components
    "1111:2222:3333:4444:5555:1.2.3.4",
    "1111:2222:3333:4444:1.2.3.4",
    "1111:2222:3333:1.2.3.4",
    "1111:2222:1.2.3.4",
    "1111:1.2.3.4",
    "1.2.3.4",

    # Missing :
    "11112222:3333:4444:5555:6666:1.2.3.4",
    "1111:22223333:4444:5555:6666:1.2.3.4",
    "1111:2222:33334444:5555:6666:1.2.3.4",
    "1111:2222:3333:44445555:6666:1.2.3.4",
    "1111:2222:3333:4444:55556666:1.2.3.4",
    "1111:2222:3333:4444:5555:66661.2.3.4",

    # Missing .
    "1111:2222:3333:4444:5555:6666:255255.255.255",
    "1111:2222:3333:4444:5555:6666:255.255255.255",
    "1111:2222:3333:4444:5555:6666:255.255.255255",

    # Missing : intended for ::
    ":1.2.3.4",
    ":6666:1.2.3.4",
    ":5555:6666:1.2.3.4",
    ":4444:5555:6666:1.2.3.4",
    ":3333:4444:5555:6666:1.2.3.4",
    ":2222:3333:4444:5555:6666:1.2.3.4",
    ":1111:2222:3333:4444:5555:6666:1.2.3.4",

    # :::
    ":::2222:3333:4444:5555:6666:1.2.3.4",
    "1111:::3333:4444:5555:6666:1.2.3.4",
    "1111:2222:::4444:5555:6666:1.2.3.4",
    "1111:2222:3333:::5555:6666:1.2.3.4",
    "1111:2222:3333:4444:::6666:1.2.3.4",
    "1111:2222:3333:4444:5555:::1.2.3.4",

    # Double ::
    "::2222::4444:5555:6666:1.2.3.4",
    "::2222:3333::5555:6666:1.2.3.4",
    "::2222:3333:4444::6666:1.2.3.4",
    "::2222:3333:4444:5555::1.2.3.4",

    "1111::3333::5555:6666:1.2.3.4",
    "1111::3333:4444::6666:1.2.3.4",
    "1111::3333:4444:5555::1.2.3.4",

    "1111:2222::4444::6666:1.2.3.4",
    "1111:2222::4444:5555::1.2.3.4",

    "1111:2222:3333::5555::1.2.3.4",

    # Missing parts
    "::.",
    "::..",
    "::...",
    "::1...",
    "::1.2..",
    "::1.2.3.",
    "::.2..",
    "::.2.3.",
    "::.2.3.4",
    "::..3.",
    "::..3.4",
    "::...4",

    # Empty string and bogus text
    "",
    "   ",
    "foobar",

    # Valid IPv6 with extra text before or after
    "foo2001:DB8:4341:0781:1111:2222:3333:4444",
    "foo 2001:DB8:4341:0781::4444",
    "foo 2001:DB8:4341:0781:1111:: bar",
    "foo2001:DB8:4341:0781::100bar",
    "2001:DB8:4341:0781::1 bar",
    "2001:DB8:4341:0781::0001bar",
    "foo bar 3001:DB8:4341:0781:1111:2222:3333:4444 foo bar",
    "__3001:DB8:4341:0781::4444",
    "__3001:DB8:4341:0781:1111::__",
    "--3001:DB8:4341:0781::100--",
    "/3001:DB8:4341:0781::1/",
    "3001:DB8:4341:0781::0001%",
    "fdb6:1d86:d9bd:1::4444%eth0",
    "fdb6:1d86:d9bd:1:1111::%ens192",
    "fdb6:1d86:d9bd:1::100%en0",
    "fdb6:1d86:d9bd:1::1%eth1.100",

    # Extra : in front
    ":1111:2222:3333:4444:5555:6666:7777::",
    ":1111:2222:3333:4444:5555:6666::",
    ":1111:2222:3333:4444:5555::",
    ":1111:2222:3333:4444::",
    ":1111:2222:3333::",
    ":1111:2222::",
    ":1111::",
    ":::",
    ":1111:2222:3333:4444:5555:6666::8888",
    ":1111:2222:3333:4444:5555::8888",
    ":1111:2222:3333:4444::8888",
    ":1111:2222:3333::8888",
    ":1111:2222::8888",
    ":1111::8888",
    ":::8888",
    ":1111:2222:3333:4444:5555::7777:8888",
    ":1111:2222:3333:4444::7777:8888",
    ":1111:2222:3333::7777:8888",
    ":1111:2222::7777:8888",
    ":1111::7777:8888",
    ":::7777:8888",
    ":1111:2222:3333:4444::6666:7777:8888",
    ":1111:2222:3333::6666:7777:8888",
    ":1111:2222::6666:7777:8888",
    ":1111::6666:7777:8888",
    ":::6666:7777:8888",
    ":1111:2222:3333::5555:6666:7777:8888",
    ":1111:2222::5555:6666:7777:8888",
    ":1111::5555:6666:7777:8888",
    ":::5555:6666:7777:8888",
    ":1111:2222::4444:5555:6666:7777:8888",
    ":1111::4444:5555:6666:7777:8888",
    ":::4444:5555:6666:7777:8888",
    ":1111::3333:4444:5555:6666:7777:8888",
    ":::3333:4444:5555:6666:7777:8888",
    ":::2222:3333:4444:5555:6666:7777:8888",
    ":1111:2222:3333:4444:5555:6666:1.2.3.4",
    ":1111:2222:3333:4444:5555::1.2.3.4",
    ":1111:2222:3333:4444::1.2.3.4",
    ":1111:2222:3333::1.2.3.4",
    ":1111:2222::1.2.3.4",
    ":1111::1.2.3.4",
    ":::1.2.3.4",
    ":1111:2222:3333:4444::6666:1.2.3.4",
    ":1111:2222:3333::6666:1.2.3.4",
    ":1111:2222::6666:1.2.3.4",
    ":1111::6666:1.2.3.4",
    ":::6666:1.2.3.4",
    ":1111:2222:3333::5555:6666:1.2.3.4",
    ":1111:2222::5555:6666:1.2.3.4",
    ":1111::5555:6666:1.2.3.4",
    ":::5555:6666:1.2.3.4",
    ":1111:2222::4444:5555:6666:1.2.3.4",
    ":1111::4444:5555:6666:1.2.3.4",
    ":::4444:5555:6666:1.2.3.4",
    ":1111::3333:4444:5555:6666:1.2.3.4",
    ":::3333:4444:5555:6666:1.2.3.4",
    ":::2222:3333:4444:5555:6666:1.2.3.4",

    # Extra : at end
    "1111:2222:3333:4444:5555:6666:7777:::",
    "1111:2222:3333:4444:5555:6666:::",
    "1111:2222:3333:4444:5555:::",
    "1111:2222:3333:4444:::",
    "1111:2222:3333:::",
    "1111:2222:::",
    "1111:::",
    ":::",
    "1111:2222:3333:4444:5555:6666::8888:",
    "1111:2222:3333:4444:5555::8888:",
    "1111:2222:3333:4444::8888:",
    "1111:2222:3333::8888:",
    "1111:2222::8888:",
    "1111::8888:",
    "::8888:",
    "1111:2222:3333:4444:5555::7777:8888:",
    "1111:2222:3333:4444::7777:8888:",
    "1111:2222:3333::7777:8888:",
    "1111:2222::7777:8888:",
    "1111::7777:8888:",
    "::7777:8888:",
    "1111:2222:3333:4444::6666:7777:8888:",
    "1111:2222:3333::6666:7777:8888:",
    "1111:2222::6666:7777:8888:",
    "1111::6666:7777:8888:",
    "::6666:7777:8888:",
    "1111:2222:3333::5555:6666:7777:8888:",
    "1111:2222::5555:6666:7777:8888:",
    "1111::5555:6666:7777:8888:",
    "::5555:6666:7777:8888:",
    "1111:2222::4444:5555:6666:7777:8888:",
    "1111::4444:5555:6666:7777:8888:",
    "::4444:5555:6666:7777:8888:",
    "1111::3333:4444:5555:6666:7777:8888:",
    "::3333:4444:5555:6666:7777:8888:",
    "::2222:3333:4444:5555:6666:7777:8888:",
);

my @all_valid_ipv6 = (
    @valid_ipv6_gua,
    @valid_ipv6_ula,
    @valid_ipv6_lla,
    @valid_ipv6,
);

my @short_valid_ipv6 = (
    @valid_ipv6_gua,
    @valid_ipv6_ula,
    @valid_ipv6_lla,
);

# Sample output from ip: -6 -o addr show dev <interface> scope global
# this seems to be consistent accross platforms
my $ip_cmd =
"2: ens160    inet6 fdb6:1d86:d9bd:1::8214/128 scope global dynamic noprefixroute \       valid_lft 63197sec preferred_lft 63197sec
2: ens160    inet6 2001:DB8:4341:0781::8214/128 scope global dynamic noprefixroute \       valid_lft 63197sec preferred_lft 63197sec
2: ens160    inet6 2001:DB8:4341:0781:89b9:4b1c:186c:a0c7/64 scope global temporary dynamic \       valid_lft 85954sec preferred_lft 21767sec
2: ens160    inet6 fdb6:1d86:d9bd:1:89b9:4b1c:186c:a0c7/64 scope global temporary dynamic \       valid_lft 85954sec preferred_lft 21767sec
2: ens160    inet6 fdb6:1d86:d9bd:1:34a6:c329:c52e:8ba6/64 scope global temporary deprecated dynamic \       valid_lft 85954sec preferred_lft 0sec
2: ens160    inet6 fdb6:1d86:d9bd:1:b417:fe35:166b:4816/64 scope global dynamic mngtmpaddr noprefixroute \       valid_lft 85954sec preferred_lft 85954sec
2: ens160    inet6 2001:DB8:4341:0781:34a6:c329:c52e:8ba6/64 scope global temporary deprecated dynamic \       valid_lft 85954sec preferred_lft 0sec
2: ens160    inet6 2001:DB8:4341:0781:f911:a224:7e69:d22/64 scope global dynamic mngtmpaddr noprefixroute \       valid_lft 85954sec preferred_lft 85954sec";
# Sample output from Ubuntu of a static assigned IPv6
my $ip_cmd_static =
"2: ens160    inet6 2001:DB8:4341:0781::100/128 scope global noprefixroute \       valid_lft forever preferred_lft forever";
my $ip_cmd_both = $ip_cmd . '\n' . $ip_cmd_static;


# Sample output from MacOS: ifconfig <interface> | grep -w "inet6" (yes there is a tab at start of each line)
my $ifconfig_macos =
"	inet6 fe80::1419:abd0:5943:8bbb%en0 prefixlen 64 secured scopeid 0xa
	inet6 fdb6:1d86:d9bd:1:142c:8e9e:de48:843e prefixlen 64 autoconf secured
	inet6 fdb6:1d86:d9bd:1:7447:cf67:edbd:cea4 prefixlen 64 autoconf temporary
	inet6 fdb6:1d86:d9bd:1::c5b3 prefixlen 64 dynamic
	inet6 2001:DB8:4341:0781:141d:66b9:2ba1:b67d prefixlen 64 autoconf secured
	inet6 2001:DB8:4341:0781:64e1:b68f:e8af:5d6e prefixlen 64 autoconf temporary";
# Sample output from MacOS when a manually configured static GUA is set.
my $ifconfig_macos_static =
"	inet6 fe80::1419:abd0:5943:8bbb%en0 prefixlen 64 secured scopeid 0xa
	inet6 2001:DB8:4341:0781::101 prefixlen 64";
my $ifconfig_macos_both = $ifconfig_macos . '\n' . $ifconfig_macos_static;

# Sample output from RHEL: ifconfig <interface> | grep -w "inet6"
my $ifconfig_rhel =
"        inet6 2001:DB8:4341:0781::dc14  prefixlen 128  scopeid 0x0<global>
        inet6 fe80::cd48:4a58:3b0f:4d30  prefixlen 64  scopeid 0x20<link>
        inet6 2001:DB8:4341:0781:e720:3aec:a936:36d4  prefixlen 64  scopeid 0x0<global>
        inet6 fdb6:1d86:d9bd:1:9c16:8cbf:ae33:f1cc  prefixlen 64  scopeid 0x0<global>
        inet6 fdb6:1d86:d9bd:1::dc14  prefixlen 128  scopeid 0x0<global>";

# Sample output from Ubuntu: ifconfig <interface> | grep -w "inet6"
my $ifconfig_ubuntu =
"        inet6 fdb6:1d86:d9bd:1:34a6:c329:c52e:8ba6  prefixlen 64  scopeid 0x0<global>
        inet6 fdb6:1d86:d9bd:1:89b9:4b1c:186c:a0c7  prefixlen 64  scopeid 0x0<global>
        inet6 fdb6:1d86:d9bd:1::8214  prefixlen 128  scopeid 0x0<global>
        inet6 fdb6:1d86:d9bd:1:b417:fe35:166b:4816  prefixlen 64  scopeid 0x0<global>
        inet6 fe80::5b31:fc63:d353:da68  prefixlen 64  scopeid 0x20<link>
        inet6 2001:DB8:4341:0781::8214  prefixlen 128  scopeid 0x0<global>
        inet6 2001:DB8:4341:0781:34a6:c329:c52e:8ba6  prefixlen 64  scopeid 0x0<global>
        inet6 2001:DB8:4341:0781:89b9:4b1c:186c:a0c7  prefixlen 64  scopeid 0x0<global>
        inet6 2001:DB8:4341:0781:f911:a224:7e69:d22  prefixlen 64  scopeid 0x0<global>";
my $ifconfig_ubuntu_static =
"        inet6 fe80::5b31:fc63:d353:da68  prefixlen 64  scopeid 0x20<link>
        inet6 2001:DB8:4341:0781::100  prefixlen 128  scopeid 0x0<global>";
my $ifconfig_ubuntu_both = $ifconfig_ubuntu . '\n' . $ifconfig_ubuntu_static;

# Sample output from Busybox: ifconfig <interface> | grep -w "inet6"
my $ifconfig_busybox =
"          inet6 addr: fe80::4362:31ff:fe08:61b4/64 Scope:Link
          inet6 addr: 2001:DB8:4341:0781:ed44:eb63:b070:212f/128 Scope:Global";

my @if_samples = (
    $ip_cmd_both,
    $ifconfig_macos_both,
    $ifconfig_rhel,
    $ifconfig_ubuntu_both,
    $ifconfig_busybox,
);


#######################################################################
## Run through a bunch of IPv6 addresses
foreach my $ip (@all_valid_ipv6) {
    is(ddclient::is_ipv6($ip),1,"Testing valid 'is_ipv6($ip)'");
}

# Run through valid mixed (IPv4 within IPv6 address).  We do not accept
# this format so expect valid check to fail.
foreach my $ip (@valid_mixed_ipv6) {
    is(ddclient::is_ipv6($ip),1,"Testing valid mixed 'is_ipv6($ip)'");
}

# Run through a bunch of invalid IPv6 addresses
foreach my $ip (@invalid_ipv6) {
    isnt(ddclient::is_ipv6($ip),1,"Testing invalid 'is_ipv6($ip)'");
}

#######################################################################
## Now work with the shorter list...
foreach my $ip (@short_valid_ipv6) {
    # Take valid IPv6 and wrap in some characters that should cause
    # testing to fail.  e.g. slashes, periods, commas, colons, alpha (other than
    # a-f which might still create a valid IPv6), even blank spaces (which
    # should be rejected when testing strictly for only an IP address)
    # first confirm that $ip is valid IPv6
    is(ddclient::is_ipv6($ip),1,"Testing valid 'is_ipv6($ip)'");
    my @chars = ('/','.',',',':','z',' ','@','$','#','&','%',"\n",'!','^','*','(',')','_','-','+');
    my $test = "";
    foreach my $ch (@chars) {
        $test = $ch . $ip;  # insert at front
        isnt(ddclient::is_ipv6($test),1,"Testing invalid 'is_ipv6($test)'");
        $test = $ip . $ch;  # add at end
        isnt(ddclient::is_ipv6($test),1,"Testing invalid 'is_ipv6($test)'");
        $test = $ch . $ip . $ch; # wrap front and end
        isnt(ddclient::is_ipv6($test),1,"Testing invalid 'is_ipv6($test)'");
    }
}

foreach my $ip (@short_valid_ipv6) {
    # But we should be able to wrap the IP address in a word boundry char
    # and extract it.  Periods and colons don't count as they can be part
    # of an IPv6 address, but we do allow underscores.
    my @word_boundry = ('/',',',' ','@','$','#','&','%',"\n",'!','^','*','(',')','_','-','+');
    my $test = "";
    foreach my $wb (@word_boundry) {
        $test = $wb . $ip . $wb; # wrap front and end
        $ip =~ s/\b0+\B//g; ## remove embedded leading zeros for testing
        is(ddclient::extract_ipv6($test),$ip,"Extracted '$ip' from '$test'");
    }
}

#######################################################################
## Now what we really want to do is extract IPv6 addresses from the
## output of the ip or ifconfig commands.  These will often return
## multiple lines.
foreach my $text (@if_samples) {
    # First try and extract the first IPv6 address.  If successful we
    # should get a valid IPv6 address back.
    my $ip = ddclient::extract_ipv6($text);
    is(ddclient::is_ipv6($ip),1,"Extracting '$ip' from sample ip/ifconfig");
    # TODO Extract first GUA

    # As we can have multi-line replies, we will test extracting the IPv6
    # from each line.
    my @text = split /\n/, $text;
    foreach my $line (@text) {
        my $ip = ddclient::extract_ipv6($line);
        is(ddclient::is_ipv6($ip),1,"Extracting '$ip' from '$line'")
    }
}
isnt(ddclient::is_ipv6(undef),1,"Testing is_ipv6 with undef");
isnt(ddclient::extract_ipv6(undef),1,"Testing extract_ipv6 with undef");

done_testing();
