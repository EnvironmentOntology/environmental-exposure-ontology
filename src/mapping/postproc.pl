#!/usr/bin/perl
while(<>) {
    chomp;
    s@The treatment @@e;
    s@The condition of being subjected to @@;
    s@A colou*r consisting of @Radiation in the frequency of @;
    s@involving .*exposure.* to @@;
    print "$_\n";

}
