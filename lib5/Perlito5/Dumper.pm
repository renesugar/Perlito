# Do not edit this file - Generated by Perlito5 8.0
use v5;
use Perlito5::Perl5::Runtime;
our $MATCH = Perlito5::Match->new();
package main;
package Perlito5::Dumper;
sub Perlito5::Dumper::Dumper {
    ((my  $obj) = $_[0]);
    ((my  $level) = ($_[1] || 0));
    ((my  $ref) = ref($obj));
    ((my  $tab) = join("", '    ' x $level));
    ((my  $tab1) = ($tab . '    '));
    if (($ref eq 'ARRAY')) {
        return (('[' . chr(10) . join('', map(($tab1 . Dumper($_, ($level + 1)) . ',' . chr(10)), @{$obj})) . $tab . ']'))
    }
    else {
        if (($ref eq 'HASH')) {
            return (('{' . chr(10) . join('', map(($tab1 . (chr(39) . $_ . chr(39) . ' => ') . Dumper($obj->{$_}, ($level + 1)) . ',' . chr(10)), sort(keys(%{$obj})))) . $tab . '}'))
        }
        else {
            if ($ref) {
                return (('bless(' . '...' . (', ' . chr(39) . $ref . chr(39) . ')')))
            }
        }
    };
    return ((chr(39) . $obj . chr(39)))
};
1;

1;
