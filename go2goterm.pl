#!/usr/bin/perl

# From a file

use GO::Parser;

$infile=$ARGV[0];
$obo=$ARGV[1];

open FB, "$ARGV[0]" or die "cannot open input file $infile\n";
#my $outfile = $infile.".goterm";
#open OUT, ">$outfile" or die "cannot open output file $outfile\n";

my $parser = new GO::Parser({handler=>'obj'}); # create parser object
$parser->parse($obo); # parse file -> objects
my $graph = $parser->handler->graph;  # get L<GO::Model::Graph> object

while (my $line = <FB>) {
  my ($col1, $col2, $col3, $col4, $GO) = split /\t/, $line;
  $GO = &trim($GO);

  my $term = $graph->get_term($GO);   # fetch a term by ID
  $GO_term = $term->acc . "\t" . $term->name;
  $GO_namespace = $term->namespace;

  #print OUT ($col1, "\t", $col2, "\t", $col3, "\t", $col4, "\t", $GO_term, "\t", $GO_namespace, "\n");
  print ($col1, "\t", $col2, "\t", $col3, "\t", $col4, "\t", $GO_term, "\t", $GO_namespace, "\n");
}

close FB;
#close OUT;

exit(0);



sub trim() {
  my ($string) = @_;

  $string =~ s/^\s+//;
  $string =~ s/\s+$//;
  return $string;
}