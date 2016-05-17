#!/usr/bin/env perl

my ( $domain ) = @ARGV;
my $tmp = '/tmp/genssl1';

use Data::Dumper;

mkdir $tmp unless -d $tmp;
system("openssl genrsa -des3 -passout pass:x -out $tmp/$domain.pass.key 2048");
system("openssl rsa -passin pass:x -in $tmp/$domain.pass.key -out $tmp/$domain.key" );
system("openssl req -new -key $tmp/$domain.key -out $tmp/$domain.csr");
system("openssl x509 -req -days 3650 -in $tmp/$domain.csr -signkey $tmp/$domain.key -out $tmp/$domain.crt" );

## DISPLAY CONTENTS
print "\nNow Displaying CRT for $domain\n\n";
system("cat $tmp/$domain.crt");

print "\nNow Displaying KEY for $domain\n\n";
system( "cat $tmp/$domain.key" );
print "\n\n";

## DESTROY
system( "rm -Rfv $tmp" );

