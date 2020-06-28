# DPErl (DFAT Perl Email Scraper)
* (DFAT: Department of Foreign Affairs and Trade)

DPErl is a Perl script for create a LDIF/VCARD file to use as addressbook.

## NOTE
This script is not working due to cloudflare email obfuscation mechanism.
There ARE worksarounds for this but it is under your responsability.

## Installation

Use debian package manager to install dependencies.

```bash
apt install libwww-mechanize-perl libhtml-html5-entities-perl
```
CPAN method.
```bash
cpan App::cpanminus (optional)
cpanm www::Mechanize 
cpanm html5::Entities
```
## Configuration
Change your "ou" for the LDAP scope on the variable $ou
```perl
my $ou = "ou=AddressBook,dc=domain,dc=com";
```
## Usage

```bash
perl DPErl-LDIF.pl > my-ldif-file.ldif
perl DPErl-VCARD.pl > my-vcard-file.vcf
```
There are some pros a cons on use the vcard file, like the number of emails supported per contact depends on the software you use to import the file.

I really recommend the ldap version as this is a standard method that all clients supports.
Setup a ldap server is extremely easy these days. I recommend Debian/Linux to do it with a couple of command lines.

## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.
Please make sure to update tests as appropriate.

## ToDo
* Add function style programming to the code.
* Emulate the JS function to unhide the emails (if it's possible)

## License
[GPL-v3](https://choosealicense.com/licenses/gpl-3.0/)