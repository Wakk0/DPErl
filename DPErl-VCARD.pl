#!/usr/bin/perl -w
use strict;
use WWW::Mechanize;

# Routine to Separate the string by bytes and get decimal values.
sub unDecode {
    return my $val = sprintf("%d", hex(substr $_[0], $_[1], 2));
}

# Routine to un-obfuscate the email
sub deCrypt {
    my $email = "";
    my $key = unDecode($_[0], 0);
        for ( my $i = 2; $i < length $_[0] ; $i += 2) {
            my $a = unDecode($_[0], $i);
            my $char = chr(int($a) ^ int($key));
            $email = $email . $char;
        }
    return $email;
}

my $dfatwww = "https://protocol.dfat.gov.au/Public/MissionsInAustralia" ;
my $browse = WWW::Mechanize->new( autocheck => 1 );

$browse->get($dfatwww);
my @embassieslinks = $browse->find_all_links(url_regex => qr/\/Public\/Missions\/\d{1,}/);
for my $embassy ( @embassieslinks ) {
	print "BEGIN:VCARD\nVERSION:3.0\nFN:Embassy of $embassy->[1]\n";
	$browse->get("https://protocol.dfat.gov.au$embassy->[0]");
	my @emails = $browse->find_all_links( url_regex => qr/\/cdn-cgi\/l\/email-protection\#/);
		for my $mail (@emails) {
			my @obfemail = split(/#/,$mail->[0]);
            my $mail = deCrypt($obfemail[1]);
		print "EMAIL;TYPE=WORK:$mail\n"; }
	print "ORG:Embassy of $embassy->[1]\nEND:VCARD\n";
}
