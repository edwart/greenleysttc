#!/usr/bin/env perl
use strict;
use warnings;
use HTTP::Tiny;
use HTML::TreeBuilder;

my $http = HTTP::Tiny->new();
my $response = $http->get('https://www.mkttl.co.uk/clubs/greenleys');

my $html_content = $response->{content};
print $html_content;
