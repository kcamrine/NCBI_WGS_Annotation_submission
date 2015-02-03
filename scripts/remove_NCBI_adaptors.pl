#!/usr/bin/perl -w
use Bio::SeqIO;


$coordfile = "adaptors_to_remove_newname.txt"; #so i remember what version these files were in, i have hard coded them
##make these files with the cookbook in Data/Fasta/README.katie in the PM genomics dropbox folders
$seqfile = "c-strain.contigs.rename2.fas";
$gfffile = "c-strain.contigs.rename.gff";

open(COORDFILE,$coordfile);

while(<COORDFILE>){
    chomp;
    @F = split(/\t/,$_);
    $fasgrep = $F[0];
    $range=$F[2];
    $max = $F[1];
    if(/\,/){
	@G=split(/\,/,$range);
	$min=1;
	for($i=0;$i<scalar(@G);$i++){
	    @C=split(/\.\./,$G[$i]);
	    $gaplen = $C[1]-$C[0];
	    $begin = $C[0];
	    push(@{$gaps{$fasgrep}},join("-",$begin,$gaplen));
	    if($i==0 && $C[0] != 1){
		$end = $C[0]-1;
		push(@{$coords{$fasgrep}},join("","1..",$end));
		$min=$C[1];
	    }
	    elsif($C[0] == 1){
		$min = $C[1];
	    }
	    elsif($C[1] != $max && $i == (scalar(@G)-1)){
		$start = $min+1;
		$end = $C[0] -1;
		push(@{$coords{$fasgrep}},join("",$start,"..",$end));
		$start = $C[1] + 1;
		push(@{$coords{$fasgrep}},join("",$start,"..",$max));
	    }
	    elsif($C[0] != 1){
		$start = $min+1;
		$end  = $C[0] -1;
		push(@{$coords{$fasgrep}},join("",$start,"..",$end));
		$min = $C[1];
	    }
	}
    }else{
	@C = split(/\.\./,$range);
	$gaplen = $C[1]-$C[0] +1;
	print ERRFILE $gaplen,"\t";
	$begin = $C[0];
	print ERRFILE $begin,"\n";
	push(@{$gaps{$fasgrep}},join("-",$begin,$gaplen));
	if($C[0] == 1){
	    $start = $C[1]+1;
	    push(@{$coords{$fasgrep}},join("",$start,"..",$max));
	}elsif($C[1] == $max){
	    $end = $C[0]-1;
	    push(@{$coords{$fasgrep}},join("",1,"..",$end));
	}else{
	    $end = $C[0]-1;
	    $start = $C[1]+1;
	    push(@{$coords{$fasgrep}},join("","1..",$end));
	    push(@{$coords{$fasgrep}},join("",$start,"..",$max));
	}
    }
}
close(COORDFILE);

#use bioperl now
$IN = Bio::SeqIO->new(-file => $seqfile, '-format' => 'fasta');
$OUT = Bio::SeqIO->newFh('-format' => 'fasta');
while (my $seq = $IN->next_seq()) {
    my @seqs = ();
    if(@{$coords{$seq->id()}}){ #you are going to get errors if this doesn't exist, ignore
	foreach my $coord (@{$coords{$seq->id()}}){
	    my ($e,$b);
	    if ($coord =~ /([\d-]+)\.\.([\d-]+)/) {
		$b = $1;
		$e = $2;    
	    }else{
		die("coordinates funky!\n");
	    }
	    push @seqs, $seq->subseq($b,$e);
	}
	my $seqseq = join "",@seqs;
	$subseq = new Bio::Seq(-seq => $seqseq,-id => $seq->id);
	print $OUT $subseq;
    }else{
	print $OUT $seq;
    }
}

#now change the Gff file to new coords to run through tbl2asn
open(GFFFILE,$gfffile) || die("no gff file to edit");
open(NEWGFF,">new_gff_v2.gff");
while(<GFFFILE>){
    chomp;
    @GFFline = split(/\t/,$_);
    if(@{$gaps{$GFFline[0]}}){ #you are going to get errors if this doesn't exist, ignore 
	$start = $GFFline[3];
	$end = $GFFline[4];
	for(@{$gaps{$GFFline[0]}}){
	    @seqs = split(/\-/,$_);
	    if($seqs[0] < $start){
		$GFFline[3] -= $seqs[1];
		$GFFline[4] -= $seqs[1];
	    }
	}
    }
    print NEWGFF join "\t",@GFFline;print NEWGFF "\n";
}
close(NEWGFF);
close(GFFFILE);

#open(SEQFILE,$seqfile);
#while(<SEQFILE>){
#    chomp;
#    if(/\>/){
#	if exists
#    }
#} 
