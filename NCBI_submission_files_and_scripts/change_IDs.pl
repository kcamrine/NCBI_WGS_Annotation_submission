#!/usr/bin/perl -w

open(NEW,"newIDs.new.ncbi.txt"); #tab-delimited file with new and old identifiers
while(<NEW>){
    chomp;
    if(/^E/){
	@line = split(/\t/,$_);
	$line[1] =~ s/\.t1//g;
	$line[1] =~ s/\s//g;
	$line[0] =~ s/\s//g;
#	print $line[1],"\n";
	$tids{$line[1]} = $line[0];
	$tid = $line[0];
	$tid =~ s/g/t/g;
	$pids{$line[1]} = $tid;
    }
}
close(NEW);

while(<>){ #tbl file
    if(/locus_tag/){
#	$_ =~ m/(enecator.*)\.t1/;
#	print $ids{$1},"\n";
        $_ =~ /(enecator.*)\.t1/;
        $pid = $tids{$1};
        $pid =~ /(EV44\-g)([0-9]+)$/;
        $begin = $1;
        $pid = $2;
	$begin =~ s/\-/\_/;
        if($pid< 10){ $pid = join "",$begin,"000",$pid;}elsif($pid < 100){$pid = join "",$begin,"00",$pid;}
        elsif($pid < 1000){$pid = join "",$begin,"0",$pid;}else{$pid = join "",$begin,$pid;}
	$_ =~ s/(enecator.*)\.t1/$pid/;
	print $_;
    }
    elsif(/transcript_id/){
	$_ =~ /(enecator.*)\.t1/;
	$pid = $pids{$1};
        $pid =~ /(EV44\-t)([0-9]+)$/;
	$begin = $1;
	$pid = $2;
	$begin =~ s/\-/\_/;
	if($pid< 10){ $pid = join "",$begin,"000",$pid;}elsif($pid < 100){$pid = join "",$begin,"00",$pid;}
	elsif($pid < 1000){$pid = join "",$begin,"0",$pid;}else{$pid = join "",$begin,$pid;}
	$_ =~ s/(enecator.*)\.t1/gnl\|ncbi\|$pid/;
        print $_;
    }
    elsif(/protein_id/){
        $_ =~ /(enecator.*\.g[0-9]+)/;
        $pid = $tids{$1};
        $pid =~ /(EV44\-g)([0-9]+)$/;
	$begin = $1;
        $pid = $2;
	$begin =~ s/\-/\_/;
        if($pid< 10){ $pid = join "",$begin,"000",$pid;}elsif($pid < 100){$pid = join "",$begin,"00",$pid;}
        elsif($pid < 1000){$pid = join "",$begin,"0",$pid;}else{$pid = join "",$begin,$pid;}
	$_ =~ s/(enecator-c-strain-scaffold_[0-9]+\.g[0-9]+)/gnl\|ncbi\|$pid/;
	print $_;
    }
    else{
	print $_;
    }
}
