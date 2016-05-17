#!/usr/bin/env perl
# Author Dave Lanning. davelcpanelnet < davel@cpanel.net >
# Name: genssl.pl
# Summary: This script is dead simple and is only designed to spit out a self-signed certificate
#   that won't expire for 10 years.  This is a task I repeatedly did while testing SSL functionality
#   so I finally decided to spit out a dead simple script to accomlpish the task.

my ($domain) = @ARGV;
my $tmp      = '/tmp/genssl1';
my $ssl      = {};

mkdir $tmp unless -d $tmp;
system("openssl genrsa -des3 -passout pass:x -out $tmp/$domain.pass.key 2048");
system("openssl rsa -passin pass:x -in $tmp/$domain.pass.key -out $tmp/$domain.key");
system("openssl req -new -key $tmp/$domain.key -out $tmp/$domain.csr");
system("openssl x509 -req -days 3650 -in $tmp/$domain.csr -signkey $tmp/$domain.key -out $tmp/$domain.crt");

# Read Files into Variables.
@{ $ssl->{'key'} } = _get_file_content("$tmp/$domain.key");
@{ $ssl->{'crt'} } = _get_file_content("$tmp/$domain.crt");

## DISPLAY CONTENTS
print "\nNow Displaying CRT for $domain\n\n";
foreach ( @{ $ssl->{'crt'} } ) {
    print $_;
}

print "\nNow Displaying KEY for $domain\n\n";
foreach ( @{ $ssl->{'key'} } ) {
    print $_;
}
print "\n\n";

## DESTROY
system("rm -Rf $tmp");

sub _get_file_content {
    my $file = shift;
    my @content;
    if ( -e $file ) {
        if ( open( my $fh, "<", $file ) ) {
            @content = <$fh>;
            close($fh);
            return @content;
        }
    }
}
