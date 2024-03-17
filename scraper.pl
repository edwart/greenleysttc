#!/usr/bin/env perl
use feature 'say';
use strict;
use warnings;
use HTTP::Tiny;
use HTML::TreeBuilder;
use Data::Dumper;

my $http = HTTP::Tiny->new();
my $response = $http->get('https://www.mkttl.co.uk/clubs/greenleys');
my $tree = HTML::TreeBuilder->new_from_content( $response->{content} );
#say $response->{content};
#my $e = $tree->look_down('table', 'datatable');
my $table = $tree->look_down(
	sub {
    # the lcs are to fold case
    lc($_[0]->tag()) eq 'table'
	    and lc($_[0]->attr('id')) eq 'datatable'
  }
);
say $table->as_HTML;
