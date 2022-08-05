#!/usr/bin/env perl
use strict;
use warnings;

my $filename = qq/teamnights.csv/;
use FileHandle;
use Data::Dumper;
use Date::Time;

my $fh = FileHandle->new("<$filename") or die "can't open $filename: $!";

my %divisions = ();
my @divisions = ();
my $division;
while (my $line = <$fh>) {
    print $line;
    chomp $line;
    if ($line !~ m/,/) {
        $division = $line;
        push @divisions, $division;
        next;
    }
    my ($number, $name, $night) = split(',', $line);
    print Dumper { Number => $number, Name => $name, Night => $night, Division => $division };
    $divisions{$division}{$number}{Name} = $name;
    $divisions{$division}{$number}{Night} = $night;

    print Dumper \%divisions;
}
my $filename2 = "FixtureGrid.csv";
my $fh2 = FileHandle->new("<$filename2") or die "can't open $filename2: $!";
my @weekcomms;
my @matches;
while (my $line = <$fh2>) {
    chomp $line;
    print $line;
    #    $line =~ m/\,\.*$//;
    if ($line =~ m/^WEEK COMM/i) {
        @weekcomms = split(',', $line);
        shift @weekcomms;
        print Dumper {weekcomms => \@weekcomms };
    }
    else {
        @matches = split(',', $line);
        shift @matches;
        print Dumper {matches => \@matches };
        foreach my $division (@divisions) {
            foreach my $match (@matches) {

    }
}
