#!/usr/bin/perl -w

open(NS,"leading_Ns.txt");
while(<NS>){
    chomp;
    @line = split(/\t/,$_);
    $line[0] =~ s/\>//;
    $forprobs{$line[0]} = $line[1];
}

while(<>){ # gff file
    chomp;
    @line = split(/\t/,$_);
    if(exists($forprobs{$line[0]})){
	$line[3] = $line[3] - $forprobs{$line[0]};
	$line[4] = $line[4] - $forprobs{$line[0]};
	print join "\t",@line;
	print "\n";
    }
    else{print $_,"\n";}
}


