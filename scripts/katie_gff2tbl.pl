#!/usr/bin/perl

## katie's take on making a gff file into an NCBI table file 
## embarrassing, but functional. This is not the end. look at
## katie_gff2tble2.pl for the rest of the script

$oldidentifier = "";
$begun = 0;
while(<>){
    chomp;
    @line = split(/\t/);
    $identifier = $line[0]; #store scaffold identifier
    $ID = $line[2]; # store type of record
    if($ID =~ /gene/){ #if you are looking at a gene
	$start = $line[3]; #set start of gene
	$finish = $line[4]; #set end of gene
	if($begun == 1){
	    print join "",$CDSstart[0],"\t",$CDSend[0],"\tmRNA\n"; 
	    if(scalar(@CDSstart) > 1){
		for($i=1;$i < scalar(@CDSstart);$i++){
		    print join "",$CDSstart[$i],"\t",$CDSend[$i],"\n";
		}
	    }
	    for($i=0;$i < scalar(@QK);$i++){
		print join "","\t\t\t",$QK[$i],"\t",$QV[$i],"\n";
	    }
	    print join "",$CDSstart[0],"\t",$CDSend[0],"\tCDS\n";
            if(scalar(@CDSstart) > 1){
                for($i=1;$i < scalar(@CDSstart);$i++){
                    print join "",$CDSstart[$i],"\t",$CDSend[$i],"\n";
                }
	    }
	    for($i=0;$i < scalar(@QK);$i++){
		print join "","\t\t\t",$QK[$i],"\t",$QV[$i],"\n";
	    }
	}
	$begun = 1;
	@CDSstart = ();
	@CDSend = ();
	@QK = ();
	@QV = ();
    }elsif($ID =~ /CDS/){
	if($direction =~ /forward/){
	    push(@CDSstart,$line[3]);
	    push(@CDSend,$line[4]);
	}else{
	    unshift(@CDSstart,$line[4]);
	    unshift(@CDSend,$line[3]);
	}
    }
    $WTF = $line[5];
    $dir = $line[6];
    if($ID =~ /transcript/ || $ID =~ /gene/){
	$locus_tag = $line[8];
    }elsif(!defined($QK[0])){
	@info =split(/; /,$line[8]);
	foreach my $item (@info){
	    @parts = split(/\s/,$item);
	    push(@QK,$parts[0]);
	    $num = scalar(@parts);
	    $string = join " ",@parts[1..$num];
	    $string =~ s/\"//g;
	    $string =~ s/;//g;
	    push(@QV,$string);
	}
    }
    if($identifier ne $oldidentifier){
	print join "",">Feature ",$identifier,"\n";
	$oldidentifier = $identifier;
    }
    if($ID =~ /gene/ && $dir =~ /\-/){
	$temp = $start;
	$start = $finish;
	$finish = $temp;
	$direction = "reverse";
    }elsif($ID =~ /gene/){
	$direction = "forward";
    }
    if($ID =~ /transcript/){
	print join "",$start,"\t",$finish,"\tgene\n\t\t\tlocus_tag\t",$locus_tag,"\n";
    }
}
print join "",$CDSstart[0],"\t",$CDSend[0],"\tmRNA\n";
if(scalar(@CDSstart) > 1){
    for($i=1;$i < scalar(@CDSstart);$i++){
	print join "",$CDSstart[$i],"\t",$CDSend[$i],"\n";
    }

}
for($i=0;$i < scalar(@QK);$i++){
    print join "","\t\t\t",$QK[$i],"\t",$QV[$i],"\n";
}
print join "",$CDSstart[0],"\t",$CDSend[0],"\tCDS\n";
if(scalar(@CDSstart) > 1){
    for($i=1;$i < scalar(@CDSstart);$i++){
	print join "",$CDSstart[$i],"\t",$CDSend[$i],"\n";
    }
}
for($i=0;$i < scalar(@QK);$i++){
    print join "","\t\t\t",$QK[$i],"\t",$QV[$i],"\n";
}
