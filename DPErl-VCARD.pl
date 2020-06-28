#!/usr/bin/perl -w
use strict;
use WWW::Mechanize;

my $dfatwww = "https://protocol.dfat.gov.au/Public/MissionsInAustralia" ;
my $browse = WWW::Mechanize->new( autocheck => 1 );

$browse->get($dfatwww);
my @embassieslinks = $browse->find_all_links(url_regex => qr/\/Public\/Missions\/\d{1,}/);
for my $embassy ( @embassieslinks ) {
	print "BEGIN:VCARD\nVERSION:3.0\nFN:Embassy of $embassy->[1]\n";
	$browse->get("https://protocol.dfat.gov.au$embassy->[0]");
	my @emails = $browse->find_all_links( url_regex => qr/mailto:/);
		for my $email (@emails) {
		print "EMAIL;TYPE=WORK:$email->[1]\n"; }
	print "ORG:Embassy of $embassy->[1]\nEND:VCARD\n";
}
