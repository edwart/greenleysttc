#!/usr/bin/env perl
## DAV script that connects to a webserver, safely makes 
# a new directory and uploads all html files in 
# the /tmp directory.
 
use HTTP::DAV;
 
$d = HTTP::DAV->new();
$url = "http://TonyEdwdsonsPro:1980/";
 
$d->credentials(
   -user  => "admin",
   -pass  => "admin", 
   -url   => $url,
   -realm => "DAV Realm"
);
 
my $teams = {
    
Name	Captain	Division	Home night	Fixtures
Crusaders	Ian Grainger	Division Four	Tuesday	2023/24
Dukes	David Fletcher	Division Four	Tuesday	2023/24
Glory	Jacob Midson	Premier Division	Tuesday	2023/24
Knights	Thomas Reddall	Division Five	Wednesday	2023/24
Moghuls	Orrin Edwards	Division Three	Tuesday	2023/24
Monarchs	Martin Hall	Premier Division	Wednesday	2023/24
Princes	Saravana Kumar	Division One	Wednesday	2023/24
Sovereigns	Stefan Swift	Division Six	Tuesday	2023/24
Sultans of Spin	Tony Edwardson	Division Two	Wednesday	2023/24
Valiants	Esther Carter	Division Two	Tuesday	2023/24
Warriors	Ricky Taiwo	Premier Division	Wednesday	2023/24
Zainabiya	Faraz Mohsin	Division Four	Wednesday	2023/24
};
$d->open( -url => $url )
   or die("Couldn't open $url: " .$d->message . "\n");
 
# Make a null lock on newdir
$d->lock( -url => "$url/newdir", -timeout => "10m" ) 
   or die "Won't put unless I can lock for 10 minutes\n";
 
# Make a new directory
$d->mkcol( -url => "$url/newdir" )
   or die "Couldn't make newdir at $url\n";
 
# Upload multiple files to newdir.
if ( $d->put( -local => "/tmp/*.html", -url => $url ) ) {
   print "successfully uploaded multiple files to $url\n";
} else {
   print "put failed: " . $d->message . "\n";
}
 
$d->unlock( -url => $url );
