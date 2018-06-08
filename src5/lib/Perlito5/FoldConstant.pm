
package Perlito5::FoldConstant;

use v5;
use Perlito5::AST;
use Perlito5::Dumper;
use strict;

sub fold_constant {
    my $self = shift;
    my $ref = ref($self);
    return $self
        if     $ref eq 'Perlito5::AST::Int'
            || $ref eq 'Perlito5::AST::Num'
            || $ref eq 'Perlito5::AST::Buf';
 
    if ($ref eq 'Perlito5::AST::Apply' ) {
        if ($self->{code} eq 'infix:<+>') {
            my $arg0 = fold_constant($self->{arguments}[0]);
            my $arg1 = fold_constant($self->{arguments}[1]);
            if (is_constant($arg0) && is_constant($arg1)) {
                my $v = $arg0->value + $arg1->value;
                if ($v == int($v)) {
                    return Perlito5::AST::Int->new(int => $v);
                }
                return Perlito5::AST::Num->new(num => $v);
            }
        }
        if ($self->{code} eq 'infix:<*>') {
            my $arg0 = fold_constant($self->{arguments}[0]);
            my $arg1 = fold_constant($self->{arguments}[1]);
            if (is_constant($arg0) && is_constant($arg1)) {
                my $v = $arg0->value * $arg1->value;
                if ($v == int($v)) {
                    return Perlito5::AST::Int->new(int => $v);
                }
                return Perlito5::AST::Num->new(num => $v);
            }
        }
        if ($self->{code} eq 'infix:<!=>') {
            my $arg0 = fold_constant($self->{arguments}[0]);
            my $arg1 = fold_constant($self->{arguments}[1]);
            if (is_constant($arg0) && is_constant($arg1)) {
                my $v = $arg0->value != $arg1->value;
                if ($v) {
                    return Perlito5::AST::Int->new(int => 1);
                }
                return Perlito5::AST::Apply->UNDEF();
            }
        }
        if ($self->{code} eq 'prefix:<!>') {
            my $arg0 = fold_constant($self->{arguments}[0]);
            if (is_constant($arg0)) {
                my $v = !$arg0->value;
                if ($v) {
                    return Perlito5::AST::Int->new(int => 1);
                }
                return Perlito5::AST::Apply->UNDEF();
            }
        }

        if (my $const = $Perlito5::CONSTANT{ $self->{namespace} . '::' . $self->{code} }) {
            return $const;
        }
    }
    return $self;
}

sub is_constant {
    my $self = shift;
    my $ref = ref($self);
    return     $ref eq 'Perlito5::AST::Int'
            || $ref eq 'Perlito5::AST::Num'
            || $ref eq 'Perlito5::AST::Buf'
            || ( $ref eq 'Perlito5::AST::Apply' && $self->{code} eq 'undef' );
}
 
1;

