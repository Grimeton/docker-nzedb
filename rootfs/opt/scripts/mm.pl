#!/usr/bin/with-contenv perl
use strict;
use warnings;
use diagnostics -v;
use Data::Dumper;
use Env;
use Text::MicroMason;
my %tParms;
my $templateDir;

if (!@ARGV) {
    print "Missing root directory of templates ... \n";
    exit 1;
} else {
    $templateDir=$ARGV[0];
}

if (! -d "$templateDir") {
    print "Template Directory '" . $templateDir . "' does not exist...\n";
    exit 2;
}

my $mm = Text::MicroMason::Base->new( -Embperl, -PassVariables);

foreach my $k (keys %ENV) {
    if ($k =~ /^_(.*)$/i) {
        $tParms{$1} = $ENV{$k};
    }
}

if (!exists($tParms{WEB_ROOT})) {
    $tParms{WEB_ROOT}="";
}

opendir(my $tdh, $templateDir) or die("Could not open template directory.");

while (my $f = readdir($tdh)) {

        next if ($f eq "." || $f eq ".." || $f !~ /^.*\.tpl$/i);
        
        my $output_file;
        my $res;
       
        open(my $fh, "<", $templateDir . "/" . $f) or next;

        if (readline($fh) =~ /^#####(.*)#####$/i) {
            $output_file=$1;
            print "Working on template: $f -> $output_file\n";
            $res = $mm->execute(handle => $fh, %tParms);
            open(my $fw, ">", "$output_file") or die("Could not write to file...");
            print $fw $res;
            close($fw);
        } else {
            print "Couldn't find destination file for template $f...\n";
        }
        close($fh);
}
close($tdh);

