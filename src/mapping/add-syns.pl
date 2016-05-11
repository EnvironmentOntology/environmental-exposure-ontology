#!/usr/bin/perl
while(<>) {
    chomp;
    print "$_\n";
    if (m@name: (uv.*)\s+light\s+(.*)@i) {
        print "synonym: \"$1 $2\" EXACT []\n";
    }
    if (m@name: Overexposure to (.*)@) {
        print "synonym: \"Exposure to $1\" BROAD []\n";
    }
    if (m@name: controlled (.*)@) {
        print "synonym: \"$1\" BROAD []\n";
    }
    if (m@name: (.*) quality$@) {
        print "synonym: \"$1\" RELATED []\n";
    }

}
