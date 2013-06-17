#!/bin/env perl

use strict;
use warnings;

use Getopt::Long;

use FindBin;
use File::Path;

eval {
  my %opts;
	GetOptions(
		\%opts,
		'test_file|t=s',
	);

	main(\%opts);
};
if ($@) {
	print $@."\n";
	print <<"USAGE";
$0 -t t/App/Model/sample.t
USAGE
}

sub main {
	my $opts = shift;

	if (!$opts->{test_file} || $opts->{test_file} !~ m#(t/(.*))/[^/]+\.t#) {
		die 'wrong format';
	}
	my ($t_path, $pm_path) = ($1, $2);

	my $package = $pm_path;
	$package =~ s#/#::#g;

	my $base_path     = $FindBin::Bin;
	my $skeleton_file = $base_path . "/skeleton.t";

	open(my $in, $skeleton_file) or die $!;
	my $skeleton_code = join('', <$in>);
	close($in);

	$skeleton_code =~ s/#PACKAGE#/$package/g;

	File::Path::mkpath($t_path) if (!-d $t_path);

	if (-e $opts->{test_file}) {
		print "replace ok? [y/n]: ";
		while (<STDIN>) {
			chomp;
			my $res = $_;
			last if ($res eq 'y');
			if ($res eq 'n') {
				print "CANCEL\n";
				exit;
			}
			print "replace ok? [y/n]: ";
		}
	}

	open(my $out, "> $opts->{test_file}") or die $!;
	print $out $skeleton_code;
	close($out);
}
