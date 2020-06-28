#!/usr/bin/perl -w
use strict;
use WWW::Mechanize;
use HTML::HTML5::Entities;

# Var referencing
# $embassy->[1] = Country
# $embassy->[0] = link/url

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

my ($embname, $address, $loop);
my $ou = "ou=AddressBook,dc=domain,dc=com";
my $dfatwww = "https://protocol.dfat.gov.au/Public/MissionsInAustralia/" ;
my $browse = WWW::Mechanize->new( autocheck => 1 );

# Change the default agent as cloudflare doesn't like bots. Once the first request from your IP is accepted any agent is accepted for a certain period of time
# As cloudflare is protecting the email addresses with a JS code, this script won't get emails. There is a workaround to skip the cloudflare but I think this won't like the DFAT
# the other one is emulate the JS code to decrypt the email but I haven't done that yet.

# Some times takes me a couple of times to be accepted by cloudflare (I haven't read about it yet)
#$browse->agent_alias( 'Mac Safari' );
$browse->add_header( 'User-agent' => 'Mozilla/5.0 (Windows; U; Windows NT 6.1; nl; rv:1.9.2.13) Gecko/20101203 Firefox/3.6.13');

$browse->get($dfatwww);
my @embassieslinks = $browse->find_all_links(url_regex => qr/\/Public\/Missions\/\d{1,}/);

for my $embassy ( @embassieslinks ) {
        $browse->get("https://protocol.dfat.gov.au$embassy->[0]");
        $embassy->[1] =~ s/,//g;

        if ( $browse->content() =~ m/<h4 class="text-primary">(.*)<\/h4>/) {
                $embname = decode_entities($1);
                #print "$embassy->[1] - $embname\n"; 
        }

        # This line parse the address it needs to be fit on the ldap schema or field
        # if ( $browse->content() =~ m/address_Formatted">Details<\/label>(.*)/ ) { $address = decode_entities($1) ; }
        # print "$address\n";

        my @emails = $browse->find_all_links( url_regex => qr/\/cdn-cgi\/l\/email-protection\#/);
        
        for my $email (@emails) {
                my @obfemail = split(/#/,$email->[0]);
                my $email = deCrypt($obfemail[1]);
                print "dn: cn=$embassy->[1]$loop,$ou\ncn: $embname\ngivenName: $embname\nsn: $embassy->[1]\nmail: $email\nobjectClass: top\nobjectClass: inetOrgPerson\n\n";
                $loop++;
        }
}

# this is the entry I'm expecting

# dn: cn=CountryN,ou=AddressBook,dc=domain,dc=com
# cn: Embassy of the some country
# givenName: Embassy of the Somy country
# sn: Country
# mail: email@domain.some
# objectClass: top
# objectClass: inetOrgPerson