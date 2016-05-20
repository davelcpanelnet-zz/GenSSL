#!/usr/bin/env perl
# Author Dave Lanning. davelcpanelnet < davel@cpanel.net >
# Name: genssl.pl
# Summary: This script is dead simple and is only designed to spit out a self-signed certificate
#   that won't expire for 10 years.  This is a task I repeatedly did while testing SSL functionality
#   so I finally decided to spit out a dead simple script to accomlpish the task.

use Getopt::Long;

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

sub _help {
    print <<"HELP";
Usage $0 --domain domain.name

This is a simple script that will generate a self-signed certificate and output the *\.[crt|key] files for the domain.

    Example: $0 --domain www.cpanel.net --keep

--domain
    The domain an SSL should be generated for.

--keep|-k 
    This option will prevent the removal of the CRT and KEY files.  By default these will be in /tmp/genssl-mmddyyyy/.

HELP
    exit;
}

sub _print {
    my ( $content, $domain ) = @_;
    if ( @$content && $domain ) {
        foreach (@$content) {
            print $_;
        }
    }
}

sub create_ssl {
    my ( $ssl, $tmp, $domain ) = @_;
    system("openssl genrsa -des3 -passout pass:x -out $tmp/$domain.pass.key 2048");
    system("openssl rsa -passin pass:x -in $tmp/$domain.pass.key -out $tmp/$domain.key");
    system("openssl req -new -key $tmp/$domain.key -out $tmp/$domain.csr");
    system("openssl x509 -req -days 3650 -in $tmp/$domain.csr -signkey $tmp/$domain.key -out $tmp/$domain.crt");

    # Read Files into Variables.
    @{ $ssl->{'key'} } = _get_file_content("$tmp/$domain.key");
    @{ $ssl->{'crt'} } = _get_file_content("$tmp/$domain.crt");
    _print( \@{ $ssl->{'crt'} }, $domain );
    _print( \@{ $ssl->{'key'} }, $domain );
    return 1 if -e "$tmp/$domain.crt" && "$tmp/$domain.key";
    return;
}

sub script {
    my (@argv) = @_;
    my ( $domain, $help, $keep );
    my $opts = Getopt::Long::GetOptionsFromArray(
        \@argv,
        'domain=s' => \$domain,
        'help'     => \$help,
        'keep|k'   => \$keep
    ) or _help();

    if ( defined $help || !defined $domain ) {
        _help();
    }

    my $date = `date +%F`;
    chomp($date);
    my $tmp = "/tmp/genssl1-$date";
    my $ssl = {};

    mkdir $tmp unless -d $tmp;
    die "The $domain.csr or $domain.key files were unable to be created." unless create_ssl( $ssl, $tmp, $domain );
    print "\n";
## DESTROY
    if ( defined $keep ) {
        print "The following files have been preserved:\n\n";
        print "$tmp/$domain.key\n";
        print "$tmp/$domain.crt\n\n";
    }
    else {
        system("rm -Rf $tmp");
    }
}

exit( script(@ARGV) ) unless caller();

1;
