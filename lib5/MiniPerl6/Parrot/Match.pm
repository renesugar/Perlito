# Do not edit this file - Generated by MiniPerl6 6.0
use v5;
use strict;
use MiniPerl6::Perl5::Runtime;
our $MATCH = MiniPerl6::Match->new();
{
package MiniPerl6::Perl5::Match;
sub new { shift; bless { @_ }, "MiniPerl6::Perl5::Match" }
sub str { $_[0]->{str} };
sub array { $_[0]->{array} };
sub hash { $_[0]->{hash} };
sub result_object { $_[0]->{result_object} };
sub from { $_[0]->{from} };
sub to { $_[0]->{to} };
sub bool { $_[0]->{bool} };
sub scalar { my $self = $_[0]; if (Main::bool($self->{bool})) { return((undef)) } else {  }; if (Main::bool(defined($self->{result_object}))) { return($self->{result_object}) } else {  }; return(substr($self->{str}, $self->{from}, (($self->{to} - $self->{from}) + 1))) };
sub __get_bool { my $self = $_[0]; return($self->{bool}) };
sub __get_int { my $self = $_[0]; return((0 + $self->scalar())) };
sub __get_number { my $self = $_[0]; return((0 + $self->scalar())) };
sub __get_string { my $self = $_[0]; return($self->scalar()) }
}

1;
