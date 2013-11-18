#!/usr/bin/env perl

use warnings;
use strict;
use XML::Simple;
use LWP;
use Data::Dumper;

my $worker="arilou";
my $build=85;

my $url="http://localhost:8080/job/assimmon/label=$worker/$build/api/xml";

my $ua = LWP::UserAgent->new;
my $req = HTTP::Request->new( GET => $url);
my $res = $ua->request( $req );

my $job = XML::Simple->new()->XMLin($res->content);

print Dumper($job);
print $job->{result};
