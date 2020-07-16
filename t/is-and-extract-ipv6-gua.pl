use Test::More;
use B qw(perlstring);

SKIP: { eval { require Test::Warnings; } or skip($@, 1); }
eval { require 'ddclient'; } or BAIL_OUT($@);

my @valid_ipv6_not_gua = (
    # Unassigned address
    "::",
    "::0",
    "::0:0",
    "::0:0:0:0:0:0:0",
    "0:0:0:0:0:0:0:0",
    "0::0",
    # link local address
    "::1",
    "::0:0:0:01",
    "::0:0:0:001",
    "::0:0:0:0001",
    "0::1",
    "0:0::1",
    "0:0:0:0:0:0:0:1",
    # Must start with a non-zero xxxx::/16
    "::123.123.123.123",
    "::2222:3333:4444:5555:6666:123.123.123.123",
    "::3333:4444:5555:6666:123.123.123.123",
    "::4444:5555:6666:123.123.123.123",
    "::5555:6666:123.123.123.123",
    "::6666:123.123.123.123",
    "::ffff:192.168.1.1",
    # Unique local address (ULA)
    "FC11:2222:3333:4444:5555:6666:7777:8888",
    "FC11::6666:7777:8888",
    "FC11::",
    "FC11:2222::123.123.123.123",
    "FD11:2222:3333:4444:5555:6666::8888",
    "FD11:2222:3333:4444:5555::8888",
    "FD11:2222::8888",
    "FD11::3333:4444:5555:6666:123.123.123.123",
    "FD11::4444:5555:6666:123.123.123.123",
    "FD11::5555:6666:123.123.123.123",
    "FD11::6666:123.123.123.123",
    "FD11::8888",
    # Link local unicast addresses
    "FE81:2222:3333:4444:5555::7777:8888",
    "FE81:2222:3333:4444::7777:8888",
    "FE81::8888",
    "FE91:2222:3333::7777:8888",
    "FEA1:2222::7777:8888",
    "FEB1::7777:8888",
    # Multicast addresses
    "FF11::",
    "FF11:2222::",
    "FF11:2222:3333::",
    "FF11:2222:3333:4444::",
    "FF11:2222:3333:4444:5555::",
    "FF11:2222:3333:4444:5555:6666::",
    "FF11:2222:3333:4444:5555:6666:7777::",
    "FF11:2222:3333:4444:5555:6666:7777:8888",
);

my @valid_ipv6_gua = (
    "2001::abcd:efAB:CDEF",  # case sensitivity
    "2001:09:0a:0b:0c:0d:0e:0f",  # leading zeros
    # Miscelaneous valid GUAs
    "1111:2222:3333:4444:5555:6666:7777:8888",
    "1111::3333:4444:5555:6666:7777:8888",
    "1111::4444:5555:6666:7777:8888",
    "1111::5555:6666:7777:8888",
    "1111::6666:7777:8888",
    "2000::",
    "2001:DB8:4341:0781::0001",
    "2001:DB8:4341:0781::1",
    "2001:DB8:4341:0781::100",
    "2001:DB8:4341:0781:1111::",
    "2001:DB8:4341:0781:1111:2222:3333:4444",
    "2001:DB8:4341:0781::4444",
    "2fff:ffff:ffff:ffff:ffff:ffff:ffff:ffff",
    "3000::",
    "3001:DB8:4341:0781::0001",
    "3001:DB8:4341:0781::1",
    "3001:DB8:4341:0781::100",
    "3001:DB8:4341:0781:1111::",
    "3001:DB8:4341:0781:1111:2222:3333:4444",
    "3001:DB8:4341:0781::4444",
    "3fff:ffff:ffff:ffff:ffff:ffff:ffff:ffff",
    # IPv4-mapped IPv6 addresses
    "2111::123.123.123.123",
    "2111:2222::123.123.123.123",
    "2111:2222:3333::123.123.123.123",
    "2111:2222:3333:4444::123.123.123.123",
    "2111:2222:3333:4444:5555::123.123.123.123",
    "2111:2222:3333:4444:5555:6666:123.123.123.123",
    "2111:2222:3333:4444::6666:123.123.123.123",
    "2111:2222:3333::5555:6666:123.123.123.123",
    "2111:2222:3333::6666:123.123.123.123",
    "2111:2222::4444:5555:6666:123.123.123.123",
    "2111:2222::5555:6666:123.123.123.123",
    "2111:2222::6666:123.123.123.123",
    "2111::3333:4444:5555:6666:123.123.123.123",
    "2111::4444:5555:6666:123.123.123.123",
    "2111::5555:6666:123.123.123.123",
    "2111::6666:123.123.123.123",
    "64:ff9b::123.123.123.123",
    "64:ff9b:1::123.123.123.123",
);

my @invalid_ipv6 = (
    # Empty string and bogus text
    undef,
    "",
    "   ",
    "foobar",
    # misformed loopback / zero
    ":::1",
    ":::0",
    "0:0:0:0:0:0:0:0:0",
    "0:0:0:0:0:0:0:0:1",
    "0:0:0::0:0:0:0:0",
    "0:0:0::0:0:0:0:1",
    # Valid IPv6 with extra text before or after
    "2001:DB8:4341:0781::0001bar",
    "2001:DB8:4341:0781::1 bar",
    "3001:DB8:4341:0781::0001%",
    "/3001:DB8:4341:0781::1/",
    "--3001:DB8:4341:0781::100--",
    "__3001:DB8:4341:0781:1111::__",
    "__3001:DB8:4341:0781::4444",
    "fdb6:1d86:d9bd:1::100%en0",
    "fdb6:1d86:d9bd:1:1111::%ens192",
    "fdb6:1d86:d9bd:1::1%eth1.100",
    "fdb6:1d86:d9bd:1::4444%eth0",
    "foo2001:DB8:4341:0781::100bar",
    "foo2001:DB8:4341:0781:1111:2222:3333:4444",
    "foo 2001:DB8:4341:0781:1111:: bar",
    "foo 2001:DB8:4341:0781::4444",
    "foo bar 3001:DB8:4341:0781:1111:2222:3333:4444 foo bar",
    # Invalid data
    "XXXX:XXXX:XXXX:XXXX:XXXX:XXXX:XXXX:XXXX",
    # Too many components
    "1111:2222:3333:4444:5555:6666:7777:8888:9999",
    "1111:2222:3333:4444:5555:6666:7777:8888::",
    "::2222:3333:4444:5555:6666:7777:8888:9999",
    # Too few components
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
    "1111:2222:3333:",
    "1111:2222:",
    "1111:",
    ":",
    ":8888",
    ":7777:8888",
    ":6666:7777:8888",
    ":2222:3333:4444:5555:6666:7777:8888",
    ":1111:2222:3333:4444:5555:6666:7777:8888",
    # :::
    ":::2222:3333:4444:5555:6666:7777:8888",
    "1111:::3333:4444:5555:6666:7777:8888",
    "1111:2222:3333:4444:5555:::7777:8888",
    "1111:2222:3333:4444:5555:6666:::8888",
    "1111:2222:3333:4444:5555:6666:7777:::",
    # Double ::
    "1111:2222:3333:4444:5555::7777::",
    "1111:2222:3333:4444::6666:7777::",
    "1111:2222:3333:4444::6666::8888",
    "1111:2222:3333::5555:6666:7777::",
    "1111:2222:3333::5555:6666::8888",
    "::2222:3333:4444:5555:7777:8888::",
    "::2222:3333:4444::6666:7777:8888",
    "::2222:3333::5555:6666:7777:8888",
    "::2222::4444:5555:6666:7777:8888",
    # Invalid data
    "XXXX:XXXX:XXXX:XXXX:XXXX:XXXX:1.2.3.4",
    "1111:2222:3333:4444:5555:6666:256.256.256.256",
    # Too many components
    "1111:2222:3333:4444:5555:6666:7777:8888:1.2.3",
    "1111:2222:3333:4444:5555:6666:7777:1.2.3.4",
    "1111:2222:3333:4444:5555:6666::1.2.3.4",
    "::2222:3333:4444:5555:6666:7777:1.2.3.4",
    "1111:2222:3333:4444:5555:6666:1.2.3.4.5",
    # Too few components
    "1111:2222:3333:4444:5555:1.2.3.4",
    "1111:2222:3333:4444:1.2.3.4",
    "1111:2222:3333:1.2.3.4",
    "1111:2222:1.2.3.4",
    "1111:1.2.3.4",
    "1.2.3.4",
    # Missing :
    "11112222:3333:4444:5555:6666:1.2.3.4",
    "1111:22223333:4444:5555:6666:1.2.3.4",
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
    ":1111:2222:3333:4444:5555:6666:1.2.3.4",
    # :::
    ":::2222:3333:4444:5555:6666:1.2.3.4",
    "1111:::3333:4444:5555:6666:1.2.3.4",
    "1111:2222:::4444:5555:6666:1.2.3.4",
    "1111:2222:3333:::5555:6666:1.2.3.4",
    "1111:2222:3333:4444:::6666:1.2.3.4",
    "1111:2222:3333:4444:5555:::1.2.3.4",
    # Double ::
    "1111:2222:3333::5555::1.2.3.4",
    "1111:2222::4444:5555::1.2.3.4",
    "1111:2222::4444::6666:1.2.3.4",
    "1111::3333:4444:5555::1.2.3.4",
    "1111::3333:4444::6666:1.2.3.4",
    "1111::3333::5555:6666:1.2.3.4",
    "::2222:3333:4444:5555::1.2.3.4",
    "::2222:3333:4444::6666:1.2.3.4",
    "::2222:3333::5555:6666:1.2.3.4",
    "::2222::4444:5555:6666:1.2.3.4",
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
    # Extra : in front
    ":::",
    ":1111::",
    ":1111::1.2.3.4",
    ":1111:2222::",
    ":1111:2222::1.2.3.4",
    ":1111:2222:3333::",
    ":1111:2222:3333::1.2.3.4",
    ":1111:2222:3333:4444::",
    ":1111:2222:3333:4444::1.2.3.4",
    ":1111:2222:3333:4444:5555::",
    ":1111:2222:3333:4444::7777:8888",
    ":1111:2222:3333:4444::8888",
    ":1111:2222:3333::5555:6666:1.2.3.4",
    ":1111:2222:3333::5555:6666:7777:8888",
    ":1111:2222:3333::6666:1.2.3.4",
    ":1111:2222:3333::6666:7777:8888",
    ":1111:2222::4444:5555:6666:7777:8888",
    ":1111:2222::5555:6666:1.2.3.4",
    ":1111:2222::5555:6666:7777:8888",
    ":1111:2222::6666:1.2.3.4",
    ":1111:2222::6666:7777:8888",
    ":1111:2222::7777:8888",
    ":1111:2222::8888",
    ":1111::3333:4444:5555:6666:1.2.3.4",
    ":1111::3333:4444:5555:6666:7777:8888",
    ":1111::4444:5555:6666:1.2.3.4",
    ":1111::4444:5555:6666:7777:8888",
    ":1111::5555:6666:1.2.3.4",
    ":1111::5555:6666:7777:8888",
    ":1111::6666:1.2.3.4",
    ":1111::6666:7777:8888",
    ":1111::7777:8888",
    ":1111::8888",
    ":::1.2.3.4",
    ":::2222:3333:4444:5555:6666:1.2.3.4",
    ":::2222:3333:4444:5555:6666:7777:8888",
    ":::3333:4444:5555:6666:1.2.3.4",
    ":::3333:4444:5555:6666:7777:8888",
    ":::4444:5555:6666:1.2.3.4",
    ":::4444:5555:6666:7777:8888",
    ":::5555:6666:1.2.3.4",
    ":::5555:6666:7777:8888",
    ":::6666:1.2.3.4",
    ":::6666:7777:8888",
    ":::7777:8888",
    ":::8888",
    # Extra : at end
    ":::",
    "1111:::",
    "1111:2222:::",
    "1111:2222:3333:4444:5555:6666:7777:::",
    "1111:2222:3333:4444:5555:6666::8888:",
    "1111:2222:3333:4444:5555::7777:8888:",
    "1111:2222:3333:4444:5555::8888:",
    "1111:2222:3333:4444::6666:7777:8888:",
    "1111:2222:3333:4444::7777:8888:",
    "1111:2222:3333:4444::8888:",
    "1111:2222:3333::8888:",
    "1111:2222::8888:",
    "1111::3333:4444:5555:6666:7777:8888:",
    "1111::7777:8888:",
    "1111::8888:",
    "::2222:3333:4444:5555:6666:7777:8888:",
    "::3333:4444:5555:6666:7777:8888:",
    "::4444:5555:6666:7777:8888:",
    "::5555:6666:7777:8888:",
    "::6666:7777:8888:",
    "::7777:8888:",
    "::8888:",
);

my @if_samples = (
    # Sample output from:
    #   ip -6 -o addr show dev <interface> scope global
    # This seems to be consistent accross platforms. The last line is from Ubuntu of a static
    # assigned IPv6.
    ["ip -6 -o addr show dev <interface> scope global", <<'EOF'],
2: ens160    inet6 fdb6:1d86:d9bd:1::8214/128 scope global dynamic noprefixroute \       valid_lft 63197sec preferred_lft 63197sec
2: ens160    inet6 2001:DB8:4341:0781::8214/128 scope global dynamic noprefixroute \       valid_lft 63197sec preferred_lft 63197sec
2: ens160    inet6 2001:DB8:4341:0781:89b9:4b1c:186c:a0c7/64 scope global temporary dynamic \       valid_lft 85954sec preferred_lft 21767sec
2: ens160    inet6 fdb6:1d86:d9bd:1:89b9:4b1c:186c:a0c7/64 scope global temporary dynamic \       valid_lft 85954sec preferred_lft 21767sec
2: ens160    inet6 fdb6:1d86:d9bd:1:34a6:c329:c52e:8ba6/64 scope global temporary deprecated dynamic \       valid_lft 85954sec preferred_lft 0sec
2: ens160    inet6 fdb6:1d86:d9bd:1:b417:fe35:166b:4816/64 scope global dynamic mngtmpaddr noprefixroute \       valid_lft 85954sec preferred_lft 85954sec
2: ens160    inet6 2001:DB8:4341:0781:34a6:c329:c52e:8ba6/64 scope global temporary deprecated dynamic \       valid_lft 85954sec preferred_lft 0sec
2: ens160    inet6 2001:DB8:4341:0781:f911:a224:7e69:d22/64 scope global dynamic mngtmpaddr noprefixroute \       valid_lft 85954sec preferred_lft 85954sec
2: ens160    inet6 2001:DB8:4341:0781::100/128 scope global noprefixroute \       valid_lft forever preferred_lft forever
EOF
    # Sample output from MacOS:
    #   ifconfig <interface> | grep -w "inet6"
    # (Yes, there is a tab at start of each line.) The last two lines are with a manually
    # configured static GUA.
    ["MacOS: ifconfig <interface> | grep -w \"inet6\"", <<'EOF'],
	inet6 fe80::1419:abd0:5943:8bbb%en0 prefixlen 64 secured scopeid 0xa
	inet6 fdb6:1d86:d9bd:1:142c:8e9e:de48:843e prefixlen 64 autoconf secured
	inet6 fdb6:1d86:d9bd:1:7447:cf67:edbd:cea4 prefixlen 64 autoconf temporary
	inet6 fdb6:1d86:d9bd:1::c5b3 prefixlen 64 dynamic
	inet6 2001:DB8:4341:0781:141d:66b9:2ba1:b67d prefixlen 64 autoconf secured
	inet6 2001:DB8:4341:0781:64e1:b68f:e8af:5d6e prefixlen 64 autoconf temporary
	inet6 fe80::1419:abd0:5943:8bbb%en0 prefixlen 64 secured scopeid 0xa
	inet6 2001:DB8:4341:0781::101 prefixlen 64
EOF
    ["RHEL: ifconfig <interface> | grep -w \"inet6\"", <<'EOF'],
        inet6 2001:DB8:4341:0781::dc14  prefixlen 128  scopeid 0x0<global>
        inet6 fe80::cd48:4a58:3b0f:4d30  prefixlen 64  scopeid 0x20<link>
        inet6 2001:DB8:4341:0781:e720:3aec:a936:36d4  prefixlen 64  scopeid 0x0<global>
        inet6 fdb6:1d86:d9bd:1:9c16:8cbf:ae33:f1cc  prefixlen 64  scopeid 0x0<global>
        inet6 fdb6:1d86:d9bd:1::dc14  prefixlen 128  scopeid 0x0<global>
EOF
    ["Ubuntu: ifconfig <interface> | grep -w \"inet6\"", <<'EOF'],
        inet6 fdb6:1d86:d9bd:1:34a6:c329:c52e:8ba6  prefixlen 64  scopeid 0x0<global>
        inet6 fdb6:1d86:d9bd:1:89b9:4b1c:186c:a0c7  prefixlen 64  scopeid 0x0<global>
        inet6 fdb6:1d86:d9bd:1::8214  prefixlen 128  scopeid 0x0<global>
        inet6 fdb6:1d86:d9bd:1:b417:fe35:166b:4816  prefixlen 64  scopeid 0x0<global>
        inet6 fe80::5b31:fc63:d353:da68  prefixlen 64  scopeid 0x20<link>
        inet6 2001:DB8:4341:0781::8214  prefixlen 128  scopeid 0x0<global>
        inet6 2001:DB8:4341:0781:34a6:c329:c52e:8ba6  prefixlen 64  scopeid 0x0<global>
        inet6 2001:DB8:4341:0781:89b9:4b1c:186c:a0c7  prefixlen 64  scopeid 0x0<global>
        inet6 2001:DB8:4341:0781:f911:a224:7e69:d22  prefixlen 64  scopeid 0x0<global>
EOF
    ["Busybox: ifconfig <interface> | grep -w \"inet6\"", <<'EOF'],
          inet6 addr: fe80::4362:31ff:fe08:61b4/64 Scope:Link
          inet6 addr: 2001:DB8:4341:0781:ed44:eb63:b070:212f/128 Scope:Global
EOF
);


subtest "is_ipv6_gua() with valid addresses, but invalid GUA" => sub {
    foreach my $ip (@valid_ipv6_not_gua) {
        # gua test should fail, but non-gua should pass
        ok(!ddclient::is_ipv6_gua($ip), "!is_ipv6_gua('$ip')");
        ok(ddclient::is_ipv6($ip), "is_ipv6('$ip')");
    }
};

subtest "is_ipv6_gua() with valid GUA ddresses" => sub {
    foreach my $ip (@valid_ipv6_gua) {
        # both gua and non-gua tests should pass
        ok(ddclient::is_ipv6_gua($ip), "is_ipv6_gua('$ip')");
        ok(ddclient::is_ipv6($ip), "is_ipv6('$ip')");
    }
};

subtest "is_ipv6_gua() with invalid addresses" => sub {
    foreach my $ip (@invalid_ipv6) {
        ok(!ddclient::is_ipv6_gua($ip), sprintf("!is_ipv6_gua(%s)", defined($ip) ? "'$ip'" : 'undef'));
    }
};

subtest "is_ipv6_gua() with char adjacent to valid address" => sub {
    foreach my $ch (split(//, '/.,:z @$#&%!^*()_-+'), "\n") {
        subtest perlstring($ch) => sub {
            foreach my $ip (@valid_ipv6_gua) {
                subtest $ip => sub {
                    my $test = $ch . $ip;  # insert at front
                    ok(!ddclient::is_ipv6_gua($test), "!is_ipv6_gua('$test')");
                    $test = $ip . $ch;  # add at end
                    ok(!ddclient::is_ipv6_gua($test), "!is_ipv6_gua('$test')");
                    $test = $ch . $ip . $ch; # wrap front and end
                    ok(!ddclient::is_ipv6_gua($test), "!is_ipv6_gua('$test')");
                };
            }
        };
    }
};

subtest "extract_ipv6_gua()" => sub {
    my @test_cases = (
        {name => "undef",            text => undef,               want => undef},
        {name => "empty",            text => "",                  want => undef},
        {name => "invalid",          text => "::12345",           want => undef},
        {name => "two addrs",        text => "::1\n::2",          want => undef},
        {name => "zone index",       text => "fe80::1%0",         want => undef},
        {name => "url host+port",    text => "[::1]:123",         want => undef},
        {name => "url host+zi+port", text => "[fe80::1%250]:123", want => undef},
        {name => "zero pad",         text => "::0001",            want => undef},
        {name => "GUA two addrs",        text => "::1\n2001::1",      want => "2001::1"},
        {name => "GUA zone index",       text => "2001::1%0",         want => "2001::1"},
        {name => "GUA url host+port",    text => "[2001::1]:123",     want => "2001::1"},
        {name => "GUA url host+zi+port", text => "[2001::1%250]:123", want => "2001::1"},
        {name => "GUA zero pad",         text => "2001::0001",        want => "2001::1"},
    );
    foreach my $tc (@test_cases) {
        is(ddclient::extract_ipv6_gua($tc->{text}), $tc->{want}, $tc->{name});
    }
};

subtest "extract_ipv6_gua() of valid GUA addr with adjacent non-word char" => sub {
    foreach my $wb (split(//, '/, @$#&%!^*()_-+'), "\n") {
        subtest perlstring($wb) => sub {
            my $test = "";
            foreach my $ip (@valid_ipv6_gua) {
                $test = "foo" . $wb . $ip . $wb . "bar"; # wrap front and end
                $ip =~ s/\b0+\B//g; ## remove embedded leading zeros for testing
                is(ddclient::extract_ipv6_gua($test), $ip, perlstring($test));
            }
        };
    }
};

subtest "interface config samples" => sub {
    for my $sample (@if_samples) {
        my ($name, $text) = @$sample;
        subtest $name => sub {
            my $ip = ddclient::extract_ipv6_gua($text);  # all samples have at least one GUA
            ok(ddclient::is_ipv6_gua($ip), "extract_ipv6_gua(\$text) returns an IPv6 GUA address");
            foreach my $line (split(/\n/, $text)) {
                my $ip = ddclient::extract_ipv6($line);
                if (ddclient::is_ipv6_gua($ip)) {
                    # If we extraced a GUA we should get the same by explicitly extracting a GUA !
                    $ip = ddclient::extract_ipv6_gua($line);
                    ok(ddclient::is_ipv6_gua($ip),
                        sprintf("extract_ipv6_gua(%s) returns an IPv6 GUA address", perlstring($line)));
                } else {
                    # But if it wasn't a GUA then we shouldn't be able to extract it with GUA specific fn.
                    ok(!ddclient::extract_ipv6_gua($line),
                        sprintf("extract_ipv6_gua(%s) returns no IPv6 GUA address", perlstring($line)));
                }
            }
        }
    }
};

done_testing();
