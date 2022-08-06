#!/usr/bin/env perl
use strict;
use warnings;

my $filename = qq/teamnights.csv/;
use FileHandle;
use Data::Dumper;
use DateTime;
use Template;
use Path::Tiny;
#use Getopts::Long;
use Log::Log4perl qw/:easy/;
Log::Log4perl->easy_init( { level => $DEBUG , layout => "%l %m%n"});
my %clubs = ( 
                CHACKMORE           => { Name => 'Chackmore',
                                         VenueLink => 'https://www.mkttl.co.uk/venues/chackmore-parish-hall',
                                         VenueName => 'Chackmore Parish Hall' },
                'GREAT BRICKHILL'   => { Name => 'Great Brickhill',
                                         VenueLink => 'https://www.mkttl.co.uk/venues/great-brickhill-village-hall',
                                         VenueName => 'Great Brockhill Village Hall' },
                GREENLEYS          => { Name => 'Greenleys',
                                         VenueLink => 'https://www.mkttl.co.uk/venues/greenleys-junior-school',
                                         VenueName => 'Greenleys Junior School' },
                'LEIGHTON BUZZARD'  => { Name => 'Leighton Buzzard',
                                         VenueLink => 'https://www.mkttl.co.uk/venues/wing-village-hall',
                                         VenueName => 'Wing Village Hall' },
                'L HORWOOD'         => { Name => 'Little Horwood',
                                         VenueLink => 'https://www.mkttl.co.uk/venues/maud-denny-memorial-hall-little-horwood',
                                         VenueName => 'Maud Denny Memorial Hall' },
                MK                  => { Name => 'Milton Keynes',
                                         VenueLink => 'https://www.mkttl.co.uk/venues/milton-keynes-table-tennis-centre',
                                         VenueName => 'Milton Keynes Table Tennis Centre' },
                MURSLEY             => { Name => 'Mursley',
                                         VenueLink => 'https://www.mkttl.co.uk/venues/mursley-village-hall',
                                         VenueName => 'Mursley Village Hall' },
                NP                  => { Name => 'Newport Pagnell',
                                         VenueLink => 'https://www.mkttl.co.uk/venues/lovat-hall-newport-pagnell',
                                         VenueName => 'Lovat Hall, Newport Pagnell' },
                OU                  => { Name => 'Open University',
                                         VenueLink => 'https://www.mkttl.co.uk/venues/open-university',
                                         VenueName => 'Open University' },
                PADBURY             => { Name => 'Padbury',
                                         VenueLink => 'https://www.mkttl.co.uk/venues/padbury-village-hall',
                                         VenueName => 'Padbury Village Hall' },
                #Shenley Wood
                #Stony Stratford Cricket Club
                #Stony Stratford Lawn Tennis Club
                'WOBURN SANDS'      => { Name => 'Woburn Sands',
                                         VenueLink => 'https://www.mkttl.co.uk/venues/woburn-sands-methodist-hall',
                                         VenueName => 'Woburn Sands Methodist Hall' },
);

our $divisions = {};
if (-f "fixtures.data") {
       do "./fixtures.data";
       INFO Dumper $divisions;
}
else {
    my @divisions = ();
    my $division;
    my $fh = FileHandle->new("<teamnights.csv") or die "can't open teamnights.csv: $!";;
    while (my $line = <$fh>) {
        INFO $line;
        chomp $line;
        if ($line !~ m/,/) {
            $division = $line;
            push @divisions, $division;
            next;
        }
        my ($number, $name, $night) = split(/\s*,\s*/, $line);
        foreach my $club (keys %clubs) {
            INFO Dumper { Name => $name, Club => $club };
            if ($name =~ m/$club/i) {
                $name =~ s/$club\s*//;
                INFO "Match";
                my $dets = $clubs{$club};
                INFO Dumper { dets => $dets };
                $divisions->{$division}{$number}{Name} = $name,
                $divisions->{$division}{$number}{Club} = $dets->{Name};
                $divisions->{$division}{$number}{VenueName} = $dets->{VenueName};
                $divisions->{$division}{$number}{VenueLink} = $dets->{VenueLink};
                $divisions->{$division}{$number}{Night} = $night;
        INFO Dumper { details => $divisions->{$division}{$number} };
                last;
            }
            else {
                INFO "No Match";
            }
        }
        #        $divisions->{$division}{$number}{Name} = $name;
        #$divisions->{$division}{$number}{Night} = $night;
        INFO Dumper { details => $divisions->{$division}{$number} };
        #        INFO Dumper { divisions => $divisions };
    }
    my $filename2 = "FixtureGrid.csv";
    my $fh2 = FileHandle->new("<$filename2") or die "can't open $filename2: $!";
    my @weekcomms;
    my @matches;
    my %months = ( Jan => 1, Feb => 2, Mar => 3, Sep => 9, Oct => 10, Nov => 11, Dec => 12 );
    while (my $line = <$fh2>) {
        chomp $line;
        INFO Dumper { Line => $line };
        #    $line =~ m/\,\.*$//;
        my @bits = split(/\s*,\s*/, $line);
        if ($line =~ m/WEEK COMM/i) {
            @weekcomms = @bits;
            shift @weekcomms;
            INFO Dumper {weekcomms => \@weekcomms };
        }
        else {
            @matches = split(/\s*,\s*/, $line);
            my $team = shift @matches;
            my $hometeam = $team;
            my $awayteam;
            INFO Dumper {matches => \@matches , Team => $team, Divisions => \@divisions };
            foreach my $division (@divisions) {
                INFO Dumper { Division => $division };
                for (my $wk = 1; $wk < scalar(@matches); $wk++) {
                    my $match = $matches[$wk];
            INFO Dumper {weekcomms => \@weekcomms };
                    my $weekcomm = $weekcomms[$wk];
                    INFO Dumper { Week => $wk,  weekcomms => \@weekcomms, match => $match , weekcomm => $weekcomm};
                    next if $weekcomm eq "WEEK COMM";
                    INFO Dumper { Week => $wk,  match => $match , weekcomm => $weekcomm};
                    my ($dom, $mon) = split('-', $weekcomm);
                    INFO Dumper { Weekcom => $weekcomm, Dom =>$dom, Mon => $mon };
                    my $month = $months{$mon};
                    my $number = substr $match, 0, 1;
                    my $opponent = $divisions->{$division}{$number};
                    my $where = substr $match, 1, 1;
                    if ($where eq "H") {
                        $hometeam = $divisions->{$division}{$team};
                        $awayteam = $opponent;
                    }
                    else {
                        $hometeam = $opponent;
                        $awayteam = $divisions->{$division}{$team};
                    }
                    next if $hometeam->{Name} eq 'spare';
                    next unless defined $hometeam->{Night};
                    next if $awayteam->{Name} eq 'spare';
                    next unless defined $awayteam->{Night};
                    INFO Dumper { Hometeam => $hometeam,
                                  Awayteam => $awayteam };
                    my $homenight = $hometeam->{Night};
                    my $year = $month > 4 ? 2022 : 2023;
                    my $datecomm = DateTime->new(year       => $year,
                                                 month      => $month,
                                                 day        => $dom,
                                                 hour       => 12,
                                                 minute     => 0,
                                                 second     => 0 );
                    my $matchdate;
                    INFO Dumper { Datecom => $datecomm->day_name . " ". $datecomm->dmy('/') , homenight => $homenight};
                    if ($homenight =~ /Monday/i) {
                        $matchdate = $datecomm,
                        INFO Dumper { matchday => $matchdate->dmy('/') };
                    }
                    elsif ($homenight =~ /Tuesday/i) {
                        $matchdate = $datecomm->add( days => 1 );
                        INFO Dumper { matchday => $matchdate->dmy('/') };
                    }
                    elsif ($homenight =~ /Wednesday/i) {
                        $matchdate = $datecomm->add( days => 2 );
                        INFO Dumper { matchday => $matchdate->dmy('/') };
                    }
                    elsif ($homenight =~ /Thursday/i) {
                        $matchdate = $datecomm->add( days => 3 );
                        INFO Dumper { matchday => $matchdate->dmy('/') };
                    }
                    elsif ($homenight =~ /Friday/i) {
                        $matchdate = $datecomm->add( days => 4 );
                        INFO Dumper { matchday => $matchdate->dmy('/') };
                    }
                    $hometeam->{Fixtures} ||= [];
                    INFO Dumper ( Date => $matchdate->dmy('/'),
                                  DOY =>$matchdate->day_of_year
                              );
                    push(@{ $hometeam->{Fixtures} }, { 
                                                       HomeClub => $hometeam->{Club},
                                                       HomeTeam => $hometeam->{Name},
                                                       AwayClub => $awayteam->{Club},
                                                       AwayTeam => $awayteam->{Name},
                                                       VenueName => $hometeam->{VenueName},
                                                       VenueLink => $hometeam->{VenueLink},
                                                       HomeAway =>"Home",
                                                       epoch     => $matchdate->epoch,
                                                       DayOfYear     => $matchdate->day_of_year,
                                                       Date     => $matchdate->dmy('/'),
                                                       Day      => $matchdate->day_name });
                    $awayteam->{Fixtures} ||= [];
                    push(@{ $awayteam->{Fixtures} }, { 
                                                      HomeClub => $hometeam->{Club},
                                                      HomeTeam => $hometeam->{Name},
                                                      AwayClub => $awayteam->{Club},
                                                      AwayTeam => $awayteam->{Name},
                                                      HomeAway =>"Away",
                                                      VenueName => $hometeam->{VenueName},
                                                      VenueLink => $hometeam->{VenueLink},
                                                      DayOfYear => $matchdate->day_of_year,
                                                      epoch     => $matchdate->epoch,
                                                      Date     => $matchdate->dmy('/'),
                                                      Day      => $matchdate->day_name });
                    INFO Dumper { Division => $divisions->{$division}, Number => $number, Where => $where };

                }
            }
        }
    }
    my $fhout = FileHandle->new(">fixtures.data");
    $fhout->print(Data::Dumper->Dump([$divisions], [qw(divisions)] ));
    $fhout->close;
}
INFO "Here";
my $tt2 = new Template;
foreach my $division (keys %{ $divisions }) {
    #        INFO Dumper { division => $division,
    #                  details => $divisions->{$division} };
        
        $division =~ s/'//g;
        $division =~ s/^\s*//g;
        INFO Dumper { division => $division, details => $divisions->{$division} };
        path("$division")->mkpath unless -d $division;
    foreach my $team (keys %{ $divisions->{$division} }) {

        path("$division/Greenleys")->mkpath unless -d "$division/Greenleys";

        my $teamname = $divisions->{$division}{$team}->{Name};
        next unless  $divisions->{$division}{$team}->{Club} eq 'Greenleys';
        $teamname =~ s/'//g;
        $teamname =~ s/^\s*//g;
        $teamname =~ s/GREENLEYS\s+//;
        INFO Dumper { teamno => $team, team => $teamname, details => $divisions->{$division}{$team} };
        unless (-d "$division/Greenleys/$teamname") {
            path("$division/Greenleys/$teamname")->mkpath  or die "Can't mkpath: $!";
        }
        my $fhteam = FileHandle->new(qq!>$division/Greenleys/$teamname/fixtures.html!) or die "Can't open file:$division/Greenleys/$teamname/fixtures.html: $!";;
        INFO Dumper { data => $divisions->{$division}{$team} };
        my $html;
        my $data = $divisions->{$division}{$team};
        $tt2->process("fixtures.tt2", { data => $data }, $fhteam) or die "Can't process template: ".$tt2->error();
        $fhteam->close;
    }
}
