#!/usr/bin/perl
#
# This perl script should perform some replacements required for translating matlab functions
# previously contained in @maExperiment for moving it into @OmicsData


if(@ARGV!=2)
  {
    print "ReplaceVariableNames.pl input output";
  }
else
  {
    $in = $ARGV[0];
    $out= $ARGV[1];

    open(IN,$in);
    open(OUT,">$out");

    $rmUml = 0;

    while(<IN>)
      {
	$zeile=$_;
# regexp die mit Backslash normal benuetzt werden koennen sind: . ? * + ^ $ | \ ( ) [ {  
#        $zeile =~ s/regexp/Ersatz/Optionen; #i =case insensitive

	    $zeile =~ s/maExperiment/OmicsData/;
	    $zeile =~ s/maStruct/OmicsStruct/;
	    $zeile =~ s/hybrname/samplenames/;

	    print "$zeile";


#	if($zeile =~ /journal\s=/i)
#	  {
# Some examples for replacements:
#	    $zeile =~ s/([a-z])\}/\1 \}/i;
#	    $zeile =~ s/\{PNAS\}/\{Proc. Nat. Acad. Sci.\}/;
#	    $zeile =~ s/U\sS\sA//;
#
#	    $zeile =~ s/ACM\sT\sMath\sSoftware/ACM T. Math. Software/i;
#	    $zeile =~ s///i;
#	    $zeile =~ s///i;
#	    $zeile =~ s///i;
#	    $zeile =~ s///i;
#	    $zeile =~ s/IEEE/\{IEEE\} /i;
#	    $zeile =~ s/FEBS/\{FEBS\} /i;
#	    $zeile =~ s/plos/\{\{PLoS\} /i;
#	    $zeile =~ s/\{\{/\{ /i;
#	    $zeile =~ s/\}\}/\} /i;
#	  }
#	if($zeile =~ /title\s=/i)
#	{
#	  $zeile =~ s/([\s])cdna([\.\s])/\1\{cDNA\}\2 /i;
#	  $zeile =~ s/([\s])dna([\.\s])/\1\{DNA\}\2 /i;
#	  $zeile =~ s/\{\{/\{ /i;
#	  $zeile =~ s/\}\}/\} /i;
#	}
#	if($rmUml==1)
#	  {
#	    $zeile =~ s/�/\\"a/i;
#	    $zeile =~ s/�/\\"o/i;
#	    $zeile =~ s/�/\\"u/i;
#	  }


	print OUT "$zeile";
      }

    close(OUT);
    close(IN);
}
