#!/usr/bin/perl -w

## puts the correct gene annotations in the right places in a tbl file for NCBI
## takes out "hypothetical protein similar to" which shouldnt be there
## and replaces it with "hypothetical protein". This will work even if you
## don't have that problem 

while(<>){
    chomp;
    if(/\>/){
	$hashtag = $_;
    }
    else{
	push(@{$hash{$hashtag}},$_);
    }
}

open(ANNFILE,"gene_name_conversions.txt"); #for example of what this file should look like, 
                                           #look at c-strain-annotation.sub.txt in this directory
$header=0;
while(<ANNFILE>){
    chomp;
    if($header == 1){ 
	@ann = split(/\t/,$_);
	$translate{$ann[0]} = $ann[1];
    }else{
	$header=1;
    }
}
close(ANNFILE);

foreach my $contig (sort keys %hash){
    print $contig,"\n";
    foreach my $line (@{$hash{$contig}}){
	if($line =~ /transcript_id/){
	    @parts = split(/\t/,$line);
	    $parts[4] =~ s/ //g;
	    if($translate{$parts[4]} =~ /hypothetical protein similar to/){
		$line =~ s/transcript_id\t$parts[4]/product\thypothetical protein\n\t\t\ttranscript_id\t$parts[4]/;
	    }
	    else{
		$line =~ s/transcript_id\t$parts[4]/product\t$translate{$parts[4]}\n\t\t\ttranscript_id\t$parts[4]/;
	    }
	}
	print $line,"\n";
    }
}
