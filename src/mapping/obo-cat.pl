#!/usr/bin/perl -w

use strict;
my $headerfile;
my $noheader;
my $include;
while ($ARGV[0] =~ /^\-/) {
    my $opt = shift @ARGV;
    if ($opt eq '--headerfile') {
        $headerfile = shift @ARGV;
    }
    elsif ($opt eq '--noheader') {
        $noheader = 1;
    }
    elsif ($opt eq '-i' || $opt eq '--include') {
        $noheader = 1;
        $include = 1;
    }
}

print_obo_header();

foreach (@ARGV) {
    catfile($_);
}

exit 0;

sub catfile {
    my $f=shift;
    print STDERR "F=$f INC=$include\n";
    my $ok = open(F,$f);
    if (!$ok)  {
        warn("no such file: $f\n");
        return;
    }
    if (!$include) {
        print STDERR "Skipping header INC=$include\n";

        # skip header
        while (<F>) {
            last if /^\s*$/;
        }
    }
    # never do this again
    $include = 0;
    while (<F>) {
        print;
    }
    print "\n\n";
    close(F);
    #print `cat $f`;
    #print "\n";
}

sub print_obo_header {
    if ($noheader) {
        return;
    }
    if ($headerfile) {
        catfile($headerfile,1);
        print "\n";
        return;
    }
    print <<EOM;
format-version: 1.2
date: 23:09:2005 14:37
saved-by: obo-cat.pl
default-namespace: none

EOM

}
