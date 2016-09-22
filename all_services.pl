#!/usr/bin/env perl

use strict;
use warnings;
use v5.10;
use utf8;

use LWP::UserAgent;
use JSON::PP qw(decode_json);
use List::MoreUtils qw(uniq);
use List::Util qw(any);

my $consul = $ENV{CONSUL_HTTP_ADDR};
die 'CONSUL_HTTP_ADDR not set' unless $consul;

my %tags = map { ( $_ => 1 ) } grep { defined($_) && length($_) } @ARGV;

my $ua = LWP::UserAgent->new();

my $resp = $ua->get("http://$consul/v1/catalog/datacenters");

my $datacenters = decode_json( $resp->decoded_content );

my @services;

foreach my $dc (@$datacenters) {
  $resp = $ua->get("http://$consul/v1/catalog/services?dc=$dc");
  my @names = keys %{ decode_json( $resp->decoded_content ) };

  unless ( keys %tags ) {
    push @services, @names;
    next;
  }

  foreach my $name (@names) {
    $resp = $ua->get("http://$consul/v1/catalog/service/$name?dc=$dc");
    my $data = decode_json( $resp->decoded_content );

    next unless any { $tags{$_} } @{ $data->[0]{ServiceTags} };
    push @services, $name;
  }
}

say join "\n", uniq sort @services;

exit 0;
