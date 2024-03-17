#!/usr/bin/env perl
## DAV script that connects to a webserver, safely makes 
# a new directory and uploads all html files in 
# the /tmp directory.
 
use feature 'say';
use strict;
use warnings;
use HTTP::Tiny;
use HTML::TreeBuilder;
use Data::Dumper;
use HTTP::DAV;
use FileHandle;
 
my $d = HTTP::DAV->new();
HTTP::DAV::DebugLevel(3);

my $url = "http://192.168.178.56:1980/greenleysttc";
 
$d->credentials(
   -user  => "admin",
   -pass  => "admin", 
   -realm => 'Zope',
   -url   => $url)
   or die("Couldn't set cred : " .$d->message . "\n");

 
$d->open( -url => $url )
   or die("Couldn't open $url: " .$d->message . "\n");
 
my $front_page = "$url/front-page";
#$d->unlock( -url => $front_page );
# Make a null lock on newdir
#$d->lock( -url => $front_page, -timeout => "10m" ) 
#   or die "Won't put unless I can lock for 10 minutes\n";

my $html;
$d->get($front_page, \$html);
save_data("newsite.html", $html);
my $table = scrape('http://www.mkttl.co.uk/clubs/greenleys'); 
$html =~ s/^<div.*$/$table/;
save_data("newpage.html", $html);
# Make a new directory
 
# Upload multiple files to newdir.
if ( $d->put( -local => "newpage.html", -url => $url ) ) {
   print "successfully uploaded multiple files to $url\n";
} else {
   print "put failed: " . $d->message . "\n";
}
 
$d->unlock( -url => $front_page );

sub scrape {
	my ($url) = @_;

	my $http = HTTP::Tiny->new();
	my $response = $http->get($url);
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
	save_data("mainsite.html", $table->as_HTML);
	return $table->as_HTML;
}
sub save_data {
	my ($filename, $content) = @_;
	my $fh = FileHandle->new(">$filename") or die "Can't open $filename: $!";
	$fh->print($content);
	$fh->close();
}
