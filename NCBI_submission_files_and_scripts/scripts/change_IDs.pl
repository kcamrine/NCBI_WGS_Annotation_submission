#!/usr/bin/perl -w

open(NEW,"newIDs.new.ncbi.txt"); #tab-delimited file with new and old identifiers
my $start = 0;
while(<NEW>){
    chomp;
    if($start==1){
	@line = split(/\t/,$_);
	$line[1] =~ s/\.t1//g;
	$line[1] =~ s/\s//g;
	$line[0] =~ s/\s//g;
	$tids{$line[1]} = $line[0];
	$tid = $line[0];
	$tid =~ s/g/t/g;
	$pids{$line[1]} = $tid;
    }
    $start = 1;
}
close(NEW);

while(<>){ #tbl file
    if(/locus_tag/){
        $_ =~ m/locus_tag\t(.+)\.t1$/;
        $pid = $tids{$1};
	$pid =~ s/\.t1//;
	$pid =~ /^(.+_g)([0-9]+)$/;
        $begin = $1;
        $pid = $2;
        $begin =~ s/\-/\_/;
        if($pid< 10){ $pid = join "",$begin,"000",$pid;}elsif($pid < 100){$pid = join "",$begin,"00",$pid;}
        elsif($pid < 1000){$pid = join "",$begin,"0",$pid;}else{$pid = join "",$begin,$pid;}
	$_ =~ s/locus_tag\t(.+)$/locus_tag\t$pid/;
	print $_;
    }
    elsif(/transcript_id/){
	$_ =~ m/transcript_id\t(.+)\.t1/;
	$pid = $pids{$1};
	$pid =~ s/\.t1//;
        $pid =~ /^(.+_t)([0-9]+)$/;
	$begin = $1;
	$pid = $2;
	$begin =~ s/\-/\_/;
	if($pid< 10){ $pid = join "",$begin,"000",$pid;}elsif($pid < 100){$pid = join "",$begin,"00",$pid;}
	elsif($pid < 1000){$pid = join "",$begin,"0",$pid;}else{$pid = join "",$begin,$pid;}
	$_ =~ s/transcript_id\t(.+)$/transcript_id\tgnl\|ncbi\|$pid/;
        print $_;
    }
    elsif(/protein_id/){
	$_ =~ m/protein_id\t([^\s]+)/;
        $pid = $tids{$1};
	$pid =~ s/\.t1//;
	$pid =~ /^(.+_g)([0-9]+)$/;
        $begin = $1;
        $pid = $2;
        $begin =~ s/\-/\_/;
        if($pid< 10){ $pid = join "",$begin,"000",$pid;}elsif($pid < 100){$pid = join "",$begin,"00",$pid;}
        elsif($pid < 1000){$pid = join "",$begin,"0",$pid;}else{$pid = join "",$begin,$pid;}
	$_ =~ s/protein_id\t(.+)$/protein_id\tgnl\|ncbi\|$pid/;
	print $_;
    }
    else{
	print $_;
    }
}
