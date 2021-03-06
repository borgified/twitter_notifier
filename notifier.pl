#!/usr/bin/env perl

use warnings;
use strict;

use Net::Twitter;
use Scalar::Util 'blessed';
use XML::Simple;
use LWP;


my %config = do '/secret/twitter.config';

my $consumer_key		= $config{consumer_key};
my $consumer_secret		= $config{consumer_secret};
my $token			= $config{token};
my $token_secret		= $config{token_secret};

my $nt = Net::Twitter->new(
	ssl									=> 1,
	traits							=> [qw/API::RESTv1_1/],
	consumer_key        => $consumer_key,
	consumer_secret     => $consumer_secret,
	access_token        => $token,
	access_token_secret => $token_secret,
);

my %gistconfig = do '/secret/gists.config';

my($worker,$build,$job_name)=@ARGV;

#get build status for $worker,$build

my @temp = split(/\//,$job_name);
$job_name = $temp[0];

my$url="http://localhost:8080/job/$job_name/label=$worker/$build/api/xml";


my $ua = LWP::UserAgent->new;
my $req = HTTP::Request->new( GET => $url);
my $res = $ua->request( $req );

my $job = XML::Simple->new()->XMLin($res->content);

my $status = $job->{result};


#end of get build status

#identify worker
my %worker = do '/secret/workers.txt';
#end of identify worker

my $result = $nt->update("build \#$build has finished with status = $status on $worker ($worker{$worker}). check it out https://gist.github.com/borgified/$gistconfig{$worker}");

if ( my $err = $@ ) {
	die $@ unless blessed $err && $err->isa('Net::Twitter::Error');

	warn "HTTP Response Code: ", $err->code, "\n",
	"HTTP Message......: ", $err->message, "\n",
	"Twitter error.....: ", $err->error, "\n";
}

