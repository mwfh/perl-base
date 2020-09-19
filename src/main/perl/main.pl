#!/usr/bin/perl
use v5.32;
use strict;
use warnings;
use diagnostics;

use FindBin;

say "Hello World";

my @questions;

# my $filename = "../data/data.txt";
my $filename = "$FindBin::Bin/../data/data.txt";

open(my $fh, '<:encoding(UTF-8)', $filename)
    or die "Could not open file '$filename' $!";

#while (my $nextline = <$fh>) {
while (my $nextline = readline($fh)) {
    chomp $nextline; # removes any trailing new line character

    # Recognize and remember the next question...
    if($nextline =~ / ^ \s* \d+ /x) # Starts with Number (/x for whitespace)
    {
        print "$nextline\n";
        push @questions,
            {
                question => $nextline,
                answers  => [],
            };
    }
    # Recognize and rememeber the next question...
    elsif (($nextline =~ / ^ \s* \[ /x) and @questions) # Starts with "[" (/x for whitespace) but only if questions exists
    {
        print "$nextline\n";
        push $questions[-1]->{answers}->@*, $nextline;
    }
    else
    {
        # Do nothing
    }
}

print "------------------------------------------------------\n";
print "------------------ RANDOM SORT Answer ----------------\n";

foreach my $question (@questions)
{
    print $question->{question};
    print "\n";
    foreach my $key ( sort { rand cmp 0.5 } $question->{answers}->@* ) {
        print $key . "\n";
    }
}

print "------------------------------------------------------\n";

