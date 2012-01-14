# Do not edit this file - Generated by Perlito5 8.0
use v5;
use utf8;
use strict;
use warnings;
no warnings ('redefine', 'once', 'void', 'uninitialized', 'misc', 'recursion');
use Perlito5::Perl5::Runtime;
use Perlito5::Perl5::Prelude;
our $MATCH = Perlito5::Match->new();
{
package main;
    sub new { shift; bless { @_ }, "main" }
    use v5;
    use Perlito5::AST;
    {
    package Perl5;
        sub new { shift; bless { @_ }, "Perl5" }
        sub tab {
            my $List__ = bless \@_, "ARRAY";
            ((my  $level) = shift());
            (('    ') x $level)
        };
        ((my  $Hash_safe_char = bless {}, 'HASH') = (sub {
    (my  $Hash_a = bless {}, 'HASH');
    ($Hash_a->{'_'} = 1);
    ($Hash_a->{','} = 1);
    ($Hash_a->{'.'} = 1);
    ($Hash_a->{':'} = 1);
    ($Hash_a->{'-'} = 1);
    ($Hash_a->{'+'} = 1);
    ($Hash_a->{'*'} = 1);
    ($Hash_a->{' '} = 1);
    ($Hash_a->{'('} = 1);
    ($Hash_a->{')'} = 1);
    ($Hash_a->{'<'} = 1);
    ($Hash_a->{'>'} = 1);
    ($Hash_a->{'['} = 1);
    ($Hash_a->{']'} = 1);
    $Hash_a
})->());
        sub escape_string {
            my $List__ = bless \@_, "ARRAY";
            ((my  $s) = shift());
            (my  $List_out = bless [], 'ARRAY');
            ((my  $tmp) = '');
            if (($s eq '')) {
                return ((chr(39) . chr(39)))
            };
            for my $i ( @{(bless [0 .. (length($s) - 1)], 'ARRAY')} ) {
                ((my  $c) = substr($s, $i, 1));
                if ((((((((($c ge 'a')) && (($c le 'z')))) || (((($c ge 'A')) && (($c le 'Z'))))) || (((($c ge '0')) && (($c le '9'))))) || exists($Hash_safe_char->{$c})))) {
                    ($tmp = ($tmp . $c))
                }
                else {
                    if (($tmp ne '')) {
                        push( @{$List_out}, (chr(39) . $tmp . chr(39)) )
                    };
                    push( @{$List_out}, ('chr(' . (sub {
    ord($c)
})->() . ')') );
                    ($tmp = '')
                }
            };
            if (($tmp ne '')) {
                push( @{$List_out}, (chr(39) . $tmp . chr(39)) )
            };
            return (join(' . ', @{$List_out}))
        }
    }

;
    {
    package CompUnit;
        sub new { shift; bless { @_ }, "CompUnit" }
        sub emit_perl5 {
            my $List__ = bless \@_, "ARRAY";
            $List__->[0]->emit_perl5_indented(0)
        };
        sub emit_perl5_indented {
            my $List__ = bless \@_, "ARRAY";
            ((my  $self) = $List__->[0]);
            ((my  $level) = $List__->[1]);
            (my  $List_body = bless [], 'ARRAY');
            for ( @{(defined $self->{body} ? $self->{body} : ($self->{body} ||= bless([], 'ARRAY')))} ) {
                if ((defined($_))) {
                    push( @{$List_body}, $_ )
                }
            };
            (Perl5::tab($level) . (chr(123) . chr(10)) . Perl5::tab($level) . 'package ' . $self->{name} . (chr(59)) . (chr(10)) . Perl5::tab(($level + 1)) . 'sub new ' . chr(123) . ' shift' . chr(59) . ' bless ' . chr(123) . ' ' . chr(64) . '_ ' . chr(125) . ', ' . chr(34) . $self->{name} . chr(34) . ' ' . chr(125) . (chr(10)) . join((chr(59) . chr(10)), @{[ map { $_->emit_perl5_indented(($level + 1)) } @{( $List_body )} ]}) . (chr(10)) . Perl5::tab($level) . (chr(125) . chr(10)) . (chr(10)))
        };
        sub emit_perl5_program {
            my $List__ = bless \@_, "ARRAY";
            ((my  $comp_units) = $List__->[0]);
            ((my  $str) = ('' . ('use v5' . chr(59) . chr(10)) . ('use utf8' . chr(59) . chr(10)) . ('use strict' . chr(59) . chr(10)) . ('use warnings' . chr(59) . chr(10)) . ('no warnings (' . chr(39) . 'redefine' . chr(39) . ', ' . chr(39) . 'once' . chr(39) . ', ' . chr(39) . 'void' . chr(39) . ', ' . chr(39) . 'uninitialized' . chr(39) . ', ' . chr(39) . 'misc' . chr(39) . ', ' . chr(39) . 'recursion' . chr(39) . ')' . chr(59) . chr(10)) . ('use Perlito5::Perl5::Runtime' . chr(59) . chr(10)) . ('use Perlito5::Perl5::Prelude' . chr(59) . chr(10)) . ('our ' . chr(36) . 'MATCH ' . chr(61) . ' Perlito5::Match->new()' . chr(59) . chr(10))));
            for my $comp_unit ( @{(($comp_units))} ) {
                ($str = ($str . $comp_unit->emit_perl5_indented(0)))
            };
            ($str = ($str . ('1' . chr(59) . chr(10))));
            return ($str)
        }
    }

;
    {
    package Val::Int;
        sub new { shift; bless { @_ }, "Val::Int" }
        sub emit_perl5 {
            my $List__ = bless \@_, "ARRAY";
            ((my  $self) = $List__->[0]);
            $self->emit_perl5_indented(0)
        };
        sub emit_perl5_indented {
            my $List__ = bless \@_, "ARRAY";
            ((my  $self) = $List__->[0]);
            ((my  $level) = $List__->[1]);
            (Perl5::tab($level) . $self->{int})
        }
    }

;
    {
    package Val::Bit;
        sub new { shift; bless { @_ }, "Val::Bit" }
        sub emit_perl5 {
            my $List__ = bless \@_, "ARRAY";
            ((my  $self) = $List__->[0]);
            $self->emit_perl5_indented(0)
        };
        sub emit_perl5_indented {
            my $List__ = bless \@_, "ARRAY";
            ((my  $self) = $List__->[0]);
            ((my  $level) = $List__->[1]);
            (Perl5::tab($level) . $self->{bit})
        }
    }

;
    {
    package Val::Num;
        sub new { shift; bless { @_ }, "Val::Num" }
        sub emit_perl5 {
            my $List__ = bless \@_, "ARRAY";
            ((my  $self) = $List__->[0]);
            $self->emit_perl5_indented(0)
        };
        sub emit_perl5_indented {
            my $List__ = bless \@_, "ARRAY";
            ((my  $self) = $List__->[0]);
            ((my  $level) = $List__->[1]);
            (Perl5::tab($level) . $self->{num})
        }
    }

;
    {
    package Val::Buf;
        sub new { shift; bless { @_ }, "Val::Buf" }
        sub emit_perl5 {
            my $List__ = bless \@_, "ARRAY";
            ((my  $self) = $List__->[0]);
            $self->emit_perl5_indented(0)
        };
        sub emit_perl5_indented {
            my $List__ = bless \@_, "ARRAY";
            ((my  $self) = $List__->[0]);
            ((my  $level) = $List__->[1]);
            (Perl5::tab($level) . Perl5::escape_string($self->{buf}))
        }
    }

;
    {
    package Lit::Block;
        sub new { shift; bless { @_ }, "Lit::Block" }
        sub emit_perl5 {
            my $List__ = bless \@_, "ARRAY";
            ((my  $self) = $List__->[0]);
            $self->emit_perl5_indented(0)
        };
        sub emit_perl5_indented {
            my $List__ = bless \@_, "ARRAY";
            ((my  $self) = $List__->[0]);
            ((my  $level) = $List__->[1]);
            (Perl5::tab($level) . ('sub ' . chr(123) . chr(10)) . join((chr(59) . chr(10)), @{[ map { $_->emit_perl5_indented(($level + 1)) } @{( (defined $self->{stmts} ? $self->{stmts} : ($self->{stmts} ||= bless([], 'ARRAY'))) )} ]}) . (chr(10)) . Perl5::tab($level) . (chr(125)))
        }
    }

;
    {
    package Lit::Array;
        sub new { shift; bless { @_ }, "Lit::Array" }
        sub emit_perl5 {
            my $List__ = bless \@_, "ARRAY";
            ((my  $self) = $List__->[0]);
            $self->emit_perl5_indented(0)
        };
        sub emit_perl5_indented {
            my $List__ = bless \@_, "ARRAY";
            ((my  $self) = $List__->[0]);
            ((my  $level) = $List__->[1]);
            ((my  $ast) = $self->expand_interpolation());
            return ($ast->emit_perl5_indented($level))
        }
    }

;
    {
    package Lit::Hash;
        sub new { shift; bless { @_ }, "Lit::Hash" }
        sub emit_perl5 {
            my $List__ = bless \@_, "ARRAY";
            ((my  $self) = $List__->[0]);
            $self->emit_perl5_indented(0)
        };
        sub emit_perl5_indented {
            my $List__ = bless \@_, "ARRAY";
            ((my  $self) = $List__->[0]);
            ((my  $level) = $List__->[1]);
            ((my  $ast) = $self->expand_interpolation());
            return ($ast->emit_perl5_indented($level))
        }
    }

;
    {
    package Index;
        sub new { shift; bless { @_ }, "Index" }
        sub emit_perl5 {
            my $List__ = bless \@_, "ARRAY";
            ((my  $self) = $List__->[0]);
            $self->emit_perl5_indented(0)
        };
        sub emit_perl5_indented {
            my $List__ = bless \@_, "ARRAY";
            ((my  $self) = $List__->[0]);
            ((my  $level) = $List__->[1]);
            if (((Main::isa($self->{obj}, 'Var') && ($self->{obj}->sigil() eq chr(36))))) {
                ((my  $v) = Var->new(('sigil' => chr(64)), ('twigil' => $self->{obj}->twigil()), ('namespace' => $self->{obj}->namespace()), ('name' => $self->{obj}->name())));
                return (($v->emit_perl5_indented($level) . '->[' . $self->{index_exp}->emit_perl5() . ']'))
            };
            ($self->{obj}->emit_perl5_indented($level) . '->[' . $self->{index_exp}->emit_perl5() . ']')
        }
    }

;
    {
    package Lookup;
        sub new { shift; bless { @_ }, "Lookup" }
        sub emit_perl5 {
            my $List__ = bless \@_, "ARRAY";
            ((my  $self) = $List__->[0]);
            $self->emit_perl5_indented(0)
        };
        sub emit_perl5_indented {
            my $List__ = bless \@_, "ARRAY";
            ((my  $self) = $List__->[0]);
            ((my  $level) = $List__->[1]);
            if ((((Main::isa($self->{obj}, 'Var') && ($self->{obj}->sigil() eq chr(36))) && ($self->{obj}->name() ne chr(47))))) {
                ((my  $v) = Var->new(('sigil' => chr(37)), ('twigil' => $self->{obj}->twigil()), ('namespace' => $self->{obj}->namespace()), ('name' => $self->{obj}->name())));
                return (($v->emit_perl5_indented($level) . '->' . chr(123) . $self->{index_exp}->emit_perl5() . chr(125)))
            };
            ($self->{obj}->emit_perl5_indented($level) . '->' . chr(123) . $self->{index_exp}->emit_perl5() . chr(125))
        }
    }

;
    {
    package Var;
        sub new { shift; bless { @_ }, "Var" }
        sub emit_perl5 {
            my $List__ = bless \@_, "ARRAY";
            ((my  $self) = $List__->[0]);
            $self->emit_perl5_indented(0)
        };
        sub emit_perl5_indented {
            my $List__ = bless \@_, "ARRAY";
            ((my  $self) = $List__->[0]);
            ((my  $level) = $List__->[1]);
            ((my  $table) = (sub {
    (my  $Hash_a = bless {}, 'HASH');
    ($Hash_a->{chr(36)} = chr(36));
    ($Hash_a->{chr(64)} = chr(36) . 'List_');
    ($Hash_a->{chr(37)} = chr(36) . 'Hash_');
    ($Hash_a->{chr(38)} = chr(36) . 'Code_');
    $Hash_a
})->());
            ((my  $ns) = '');
            if (($self->{namespace})) {
                ($ns = ($self->{namespace} . '::'))
            }
            else {
                if (((($self->{sigil} eq chr(64)) && ($self->{name} eq 'ARGV')))) {
                    return ((Perl5::tab($level) . '(' . chr(92) . chr(64) . 'ARGV)'))
                };
                if ((($self->{twigil} eq '.'))) {
                    if ((($self->{sigil} eq chr(37)))) {
                        return ((Perl5::tab($level) . '(' . 'defined ' . chr(36) . 'self->' . chr(123) . $self->{name} . chr(125) . ' ' . chr(63) . ' ' . chr(36) . 'self->' . chr(123) . $self->{name} . chr(125) . ' ' . ': (' . chr(36) . 'self->' . chr(123) . $self->{name} . (chr(125) . ' ' . chr(61) . ' bless(' . chr(123) . chr(125) . ', ' . chr(39) . 'HASH' . chr(39) . ')))')))
                    }
                    else {
                        if ((($self->{sigil} eq chr(64)))) {
                            return ((Perl5::tab($level) . '(' . 'defined ' . chr(36) . 'self->' . chr(123) . $self->{name} . chr(125) . ' ' . chr(63) . ' ' . chr(36) . 'self->' . chr(123) . $self->{name} . chr(125) . ' ' . ': (' . chr(36) . 'self->' . chr(123) . $self->{name} . (chr(125) . ' ' . chr(124) . chr(124) . chr(61) . ' bless([], ' . chr(39) . 'ARRAY' . chr(39) . ')))')))
                        }
                        else {
                            return ((Perl5::tab($level) . chr(36) . 'self->' . chr(123) . $self->{name} . chr(125)))
                        }
                    }
                };
                if ((($self->{name} eq chr(47)))) {
                    return ((Perl5::tab($level) . $table->{$self->{sigil}} . 'MATCH'))
                }
            };
            return ((Perl5::tab($level) . $table->{$self->{sigil}} . $ns . $self->{name}))
        };
        sub plain_name {
            my $List__ = bless \@_, "ARRAY";
            ((my  $self) = $List__->[0]);
            if (($self->{namespace})) {
                return (($self->{namespace} . '::' . $self->{name}))
            };
            return ($self->{name})
        }
    }

;
    {
    package Proto;
        sub new { shift; bless { @_ }, "Proto" }
        sub emit_perl5 {
            my $List__ = bless \@_, "ARRAY";
            ((my  $self) = $List__->[0]);
            $self->emit_perl5_indented(0)
        };
        sub emit_perl5_indented {
            my $List__ = bless \@_, "ARRAY";
            ((my  $self) = $List__->[0]);
            ((my  $level) = $List__->[1]);
            (Perl5::tab($level) . $self->{name})
        }
    }

;
    {
    package Call;
        sub new { shift; bless { @_ }, "Call" }
        ((my  $Hash_method_perl5 = bless {}, 'HASH') = (sub {
    (my  $Hash_a = bless {}, 'HASH');
    ($Hash_a->{'isa'} = 'Main::isa');
    $Hash_a
})->());
        sub emit_perl5 {
            my $List__ = bless \@_, "ARRAY";
            ((my  $self) = $List__->[0]);
            $self->emit_perl5_indented(0)
        };
        sub emit_perl5_indented {
            my $List__ = bless \@_, "ARRAY";
            ((my  $self) = $List__->[0]);
            ((my  $level) = $List__->[1]);
            ((my  $invocant) = $self->{invocant}->emit_perl5());
            if ((exists($Hash_method_perl5->{$self->{method}}))) {
                return ((Perl5::tab($level) . $Hash_method_perl5->{$self->{method}} . '(' . $invocant . ', ' . join(', ', @{[ map { $_->emit_perl5() } @{( (defined $self->{arguments} ? $self->{arguments} : ($self->{arguments} ||= bless([], 'ARRAY'))) )} ]}) . ')'))
            };
            if ((($self->{method} eq 'postcircumfix:<[ ]>'))) {
                return ((Perl5::tab($level) . $invocant . '->[' . (defined $self->{arguments} ? $self->{arguments} : ($self->{arguments} ||= bless([], 'ARRAY')))->emit_perl5() . ']'))
            };
            if ((($self->{method} eq 'postcircumfix:<' . chr(123) . ' ' . chr(125) . '>'))) {
                return ((Perl5::tab($level) . $invocant . '->' . chr(123) . (defined $self->{arguments} ? $self->{arguments} : ($self->{arguments} ||= bless([], 'ARRAY')))->emit_perl5() . chr(125)))
            };
            ((my  $meth) = $self->{method});
            if ((($meth eq 'postcircumfix:<( )>'))) {
                ($meth = '')
            };
            ((my  $call) = ('->' . $meth . '(' . join(', ', @{[ map { $_->emit_perl5() } @{( (defined $self->{arguments} ? $self->{arguments} : ($self->{arguments} ||= bless([], 'ARRAY'))) )} ]}) . ')'));
            if (($self->{hyper})) {
                if ((!(((Main::isa($self->{invocant}, 'Apply') && ($self->{invocant}->code() eq 'prefix:<' . chr(64) . '>')))))) {
                    ($invocant = (chr(64) . chr(123) . '( ' . $invocant . ' )' . chr(125)))
                };
                return ((Perl5::tab($level) . '[ map ' . chr(123) . ' ' . chr(36) . '_' . $call . ' ' . chr(125) . ' ' . $invocant . ' ]'))
            }
            else {
                (Perl5::tab($level) . $invocant . $call)
            }
        }
    }

;
    {
    package Apply;
        sub new { shift; bless { @_ }, "Apply" }
        ((my  $Hash_op_prefix_perl5 = bless {}, 'HASH') = (sub {
    (my  $Hash_a = bless {}, 'HASH');
    ($Hash_a->{'say'} = 'Main::say');
    ($Hash_a->{'print'} = 'Main::print');
    ($Hash_a->{'grep'} = 'Main::grep');
    ($Hash_a->{'sort'} = 'Main::sort');
    ($Hash_a->{'keys'} = 'Main::keys');
    ($Hash_a->{'values'} = 'Main::values');
    ($Hash_a->{'warn'} = 'warn');
    ($Hash_a->{'Int'} = '0+');
    ($Hash_a->{'Num'} = '0+');
    ($Hash_a->{'bool'} = chr(33) . chr(33));
    ($Hash_a->{'prefix:<' . chr(33) . '>'} = chr(33));
    ($Hash_a->{'prefix:<' . chr(63) . '>'} = chr(33) . chr(33));
    ($Hash_a->{'prefix:<++>'} = '++');
    ($Hash_a->{'prefix:<-->'} = '--');
    $Hash_a
})->());
        ((my  $Hash_op_infix_perl5 = bless {}, 'HASH') = (sub {
    (my  $Hash_a = bless {}, 'HASH');
    ($Hash_a->{'list:<.>'} = ' . ');
    ($Hash_a->{'infix:<+>'} = ' + ');
    ($Hash_a->{'infix:<->'} = ' - ');
    ($Hash_a->{'infix:<*>'} = ' * ');
    ($Hash_a->{'infix:<' . chr(47) . '>'} = ' ' . chr(47) . ' ');
    ($Hash_a->{'infix:<>>'} = ' > ');
    ($Hash_a->{'infix:<<>'} = ' < ');
    ($Hash_a->{'infix:<>' . chr(61) . '>'} = ' >' . chr(61) . ' ');
    ($Hash_a->{'infix:<<' . chr(61) . '>'} = ' <' . chr(61) . ' ');
    ($Hash_a->{'infix:<x>'} = ' x ');
    ($Hash_a->{'infix:<' . chr(38) . chr(38) . '>'} = ' ' . chr(38) . chr(38) . ' ');
    ($Hash_a->{'infix:<' . chr(124) . chr(124) . '>'} = ' ' . chr(124) . chr(124) . ' ');
    ($Hash_a->{'infix:<and>'} = ' and ');
    ($Hash_a->{'infix:<or>'} = ' or ');
    ($Hash_a->{'infix:<' . chr(47) . chr(47) . '>'} = ' ' . chr(47) . chr(47) . ' ');
    ($Hash_a->{'infix:<eq>'} = ' eq ');
    ($Hash_a->{'infix:<ne>'} = ' ne ');
    ($Hash_a->{'infix:<le>'} = ' le ');
    ($Hash_a->{'infix:<ge>'} = ' ge ');
    ($Hash_a->{'infix:<' . chr(61) . chr(61) . '>'} = ' ' . chr(61) . chr(61) . ' ');
    ($Hash_a->{'infix:<' . chr(33) . chr(61) . '>'} = ' ' . chr(33) . chr(61) . ' ');
    ($Hash_a->{'infix:<' . chr(61) . '>>'} = ' ' . chr(61) . '> ');
    $Hash_a
})->());
        sub emit_perl5 {
            my $List__ = bless \@_, "ARRAY";
            ((my  $self) = $List__->[0]);
            $self->emit_perl5_indented(0)
        };
        sub emit_perl5_indented {
            my $List__ = bless \@_, "ARRAY";
            ((my  $self) = $List__->[0]);
            ((my  $level) = $List__->[1]);
            ((my  $apply) = $self->op_assign());
            if (($apply)) {
                return ($apply->emit_perl5_indented($level))
            };
            ((my  $ns) = '');
            if (($self->{namespace})) {
                ($ns = ($self->{namespace} . '::'))
            };
            ((my  $code) = ($ns . $self->{code}));
            if ((Main::isa($code, 'Str'))) {

            }
            else {
                return ((Perl5::tab($level) . '(' . $self->{code}->emit_perl5() . ')->(' . join(', ', @{[ map { $_->emit_perl5() } @{( (defined $self->{arguments} ? $self->{arguments} : ($self->{arguments} ||= bless([], 'ARRAY'))) )} ]}) . ')'))
            };
            if ((exists($Hash_op_infix_perl5->{$code}))) {
                return ((Perl5::tab($level) . '(' . join($Hash_op_infix_perl5->{$code}, @{([ map { $_->emit_perl5() } @{( (defined $self->{arguments} ? $self->{arguments} : ($self->{arguments} ||= bless([], 'ARRAY'))) )} ])}) . ')'))
            };
            if ((exists($Hash_op_prefix_perl5->{$code}))) {
                return ((Perl5::tab($level) . $Hash_op_prefix_perl5->{$code} . '(' . join(', ', @{[ map { $_->emit_perl5() } @{( (defined $self->{arguments} ? $self->{arguments} : ($self->{arguments} ||= bless([], 'ARRAY'))) )} ]}) . ')'))
            };
            if ((($self->{code} eq 'package'))) {
                return ((Perl5::tab($level) . 'package ' . $self->{namespace}))
            };
            if ((($code eq 'undef'))) {
                return ((Perl5::tab($level) . 'undef()'))
            };
            if ((($code eq 'make'))) {
                return ((Perl5::tab($level) . '(' . chr(36) . 'MATCH->' . chr(123) . 'capture' . chr(125) . ' ' . chr(61) . ' (' . join(', ', @{[ map { $_->emit_perl5() } @{( (defined $self->{arguments} ? $self->{arguments} : ($self->{arguments} ||= bless([], 'ARRAY'))) )} ]}) . '))'))
            };
            if ((($code eq 'scalar'))) {
                return ((Perl5::tab($level) . 'scalar( ' . chr(64) . chr(123) . ((defined $self->{arguments} ? $self->{arguments} : ($self->{arguments} ||= bless([], 'ARRAY')))->[0]->emit_perl5()) . chr(125) . ' )'))
            };
            if ((($code eq 'pop'))) {
                return ((Perl5::tab($level) . 'pop( ' . chr(64) . chr(123) . ((defined $self->{arguments} ? $self->{arguments} : ($self->{arguments} ||= bless([], 'ARRAY')))->[0]->emit_perl5()) . chr(125) . ' )'))
            };
            if ((($code eq 'push'))) {
                return ((Perl5::tab($level) . 'push( ' . chr(64) . chr(123) . ((defined $self->{arguments} ? $self->{arguments} : ($self->{arguments} ||= bless([], 'ARRAY')))->[0])->emit_perl5() . chr(125) . ', ' . ((defined $self->{arguments} ? $self->{arguments} : ($self->{arguments} ||= bless([], 'ARRAY')))->[1])->emit_perl5() . ' )'))
            };
            if ((($code eq 'shift'))) {
                if (((defined $self->{arguments} ? $self->{arguments} : ($self->{arguments} ||= bless([], 'ARRAY'))))) {
                    return ((Perl5::tab($level) . 'shift( ' . chr(64) . chr(123) . join(' ', @{[ map { $_->emit_perl5() } @{( (defined $self->{arguments} ? $self->{arguments} : ($self->{arguments} ||= bless([], 'ARRAY'))) )} ]}) . chr(125) . ' )'))
                };
                return ('shift()')
            };
            if ((($code eq 'unshift'))) {
                return ((Perl5::tab($level) . 'unshift( ' . chr(64) . chr(123) . (defined $self->{arguments} ? $self->{arguments} : ($self->{arguments} ||= bless([], 'ARRAY')))->[0]->emit_perl5() . chr(125) . ', ' . (defined $self->{arguments} ? $self->{arguments} : ($self->{arguments} ||= bless([], 'ARRAY')))->[1]->emit_perl5() . ' )'))
            };
            if ((($code eq 'map'))) {
                ((my  $str) = shift( @{(defined $self->{arguments} ? $self->{arguments} : ($self->{arguments} ||= bless([], 'ARRAY')))} ));
                return ((Perl5::tab($level) . '[map(' . $str->emit_perl5() . ', ' . chr(64) . chr(123) . join(',', @{[ map { $_->emit_perl5() } @{( (defined $self->{arguments} ? $self->{arguments} : ($self->{arguments} ||= bless([], 'ARRAY'))) )} ]}) . chr(125) . ')]'))
            };
            if ((($code eq 'join'))) {
                ((my  $str) = shift( @{(defined $self->{arguments} ? $self->{arguments} : ($self->{arguments} ||= bless([], 'ARRAY')))} ));
                return ((Perl5::tab($level) . 'join(' . $str->emit_perl5() . ', ' . chr(64) . chr(123) . join(',', @{[ map { $_->emit_perl5() } @{( (defined $self->{arguments} ? $self->{arguments} : ($self->{arguments} ||= bless([], 'ARRAY'))) )} ]}) . chr(125) . ')'))
            };
            if ((($code eq 'prefix:<' . chr(92) . '>'))) {
                return ((Perl5::tab($level) . join(' ', @{[ map { $_->emit_perl5() } @{( (defined $self->{arguments} ? $self->{arguments} : ($self->{arguments} ||= bless([], 'ARRAY'))) )} ]})))
            };
            if ((($code eq 'prefix:<' . chr(36) . '>'))) {
                return ((Perl5::tab($level) . chr(36) . chr(123) . join(' ', @{[ map { $_->emit_perl5() } @{( (defined $self->{arguments} ? $self->{arguments} : ($self->{arguments} ||= bless([], 'ARRAY'))) )} ]}) . chr(125)))
            };
            if ((($code eq 'prefix:<' . chr(64) . '>'))) {
                return ((Perl5::tab($level) . '(' . join(' ', @{[ map { $_->emit_perl5() } @{( (defined $self->{arguments} ? $self->{arguments} : ($self->{arguments} ||= bless([], 'ARRAY'))) )} ]}) . ')'))
            };
            if ((($code eq 'prefix:<' . chr(37) . '>'))) {
                return ((Perl5::tab($level) . chr(37) . chr(123) . join(' ', @{[ map { $_->emit_perl5() } @{( (defined $self->{arguments} ? $self->{arguments} : ($self->{arguments} ||= bless([], 'ARRAY'))) )} ]}) . chr(125)))
            };
            if ((($code eq 'postfix:<++>'))) {
                return ((Perl5::tab($level) . '(' . join(' ', @{[ map { $_->emit_perl5() } @{( (defined $self->{arguments} ? $self->{arguments} : ($self->{arguments} ||= bless([], 'ARRAY'))) )} ]}) . ')++'))
            };
            if ((($code eq 'postfix:<-->'))) {
                return ((Perl5::tab($level) . '(' . join(' ', @{[ map { $_->emit_perl5() } @{( (defined $self->{arguments} ? $self->{arguments} : ($self->{arguments} ||= bless([], 'ARRAY'))) )} ]}) . ')--'))
            };
            if ((($code eq 'infix:<..>'))) {
                return ((Perl5::tab($level) . '(bless [' . join(' .. ', @{[ map { $_->emit_perl5() } @{( (defined $self->{arguments} ? $self->{arguments} : ($self->{arguments} ||= bless([], 'ARRAY'))) )} ]}) . ('], ' . chr(39) . 'ARRAY' . chr(39) . ')')))
            };
            if ((($code eq 'ternary:<' . chr(63) . chr(63) . ' ' . chr(33) . chr(33) . '>'))) {
                return ((Perl5::tab($level) . '(' . (defined $self->{arguments} ? $self->{arguments} : ($self->{arguments} ||= bless([], 'ARRAY')))->[0]->emit_perl5() . ' ' . chr(63) . ' ' . (defined $self->{arguments} ? $self->{arguments} : ($self->{arguments} ||= bless([], 'ARRAY')))->[1]->emit_perl5() . ' : ' . (defined $self->{arguments} ? $self->{arguments} : ($self->{arguments} ||= bless([], 'ARRAY')))->[2]->emit_perl5() . ')'))
            };
            if ((($code eq 'circumfix:<( )>'))) {
                return ((Perl5::tab($level) . '(' . join(', ', @{[ map { $_->emit_perl5() } @{( (defined $self->{arguments} ? $self->{arguments} : ($self->{arguments} ||= bless([], 'ARRAY'))) )} ]}) . ')'))
            };
            if ((($code eq 'infix:<' . chr(61) . '>'))) {
                return ((Perl5::tab($level) . emit_perl5_bind((defined $self->{arguments} ? $self->{arguments} : ($self->{arguments} ||= bless([], 'ARRAY')))->[0], (defined $self->{arguments} ? $self->{arguments} : ($self->{arguments} ||= bless([], 'ARRAY')))->[1])))
            };
            if ((($code eq 'return'))) {
                return ((Perl5::tab($level) . 'return (' . join(', ', @{[ map { $_->emit_perl5() } @{( (defined $self->{arguments} ? $self->{arguments} : ($self->{arguments} ||= bless([], 'ARRAY'))) )} ]}) . ')'))
            };
            (Perl5::tab($level) . $code . '(' . join(', ', @{[ map { $_->emit_perl5() } @{( (defined $self->{arguments} ? $self->{arguments} : ($self->{arguments} ||= bless([], 'ARRAY'))) )} ]}) . ')')
        };
        sub emit_perl5_bind {
            my $List__ = bless \@_, "ARRAY";
            ((my  $parameters) = shift());
            ((my  $arguments) = shift());
            if ((Main::isa($parameters, 'Call'))) {
                if (((($parameters->method() eq 'postcircumfix:<' . chr(123) . ' ' . chr(125) . '>') || ($parameters->method() eq 'postcircumfix:<[ ]>')))) {
                    return (('(' . $parameters->emit_perl5() . ' ' . chr(61) . ' ' . $arguments->emit_perl5() . ')'))
                };
                ((my  $a) = $parameters);
                return (('((' . ($a->invocant())->emit_perl5() . ')->' . chr(123) . $a->method() . chr(125) . ' ' . chr(61) . ' ' . $arguments->emit_perl5() . ')'))
            };
            if (((Main::isa($parameters, 'Var') && ($parameters->sigil() eq chr(64))) || (Main::isa($parameters, 'Decl') && ($parameters->var()->sigil() eq chr(64))))) {
                ($arguments = Lit::Array->new(('array1' => (sub {
    (my  $List_a = bless [], 'ARRAY');
    (my  $List_v = bless [], 'ARRAY');
    push( @{$List_a}, $arguments );
    $List_a
})->())))
            }
            else {
                if (((Main::isa($parameters, 'Var') && ($parameters->sigil() eq chr(37))) || (Main::isa($parameters, 'Decl') && ($parameters->var()->sigil() eq chr(37))))) {
                    ($arguments = Lit::Hash->new(('hash1' => (sub {
    (my  $List_a = bless [], 'ARRAY');
    (my  $List_v = bless [], 'ARRAY');
    push( @{$List_a}, $arguments );
    $List_a
})->())))
                }
            };
            ('(' . $parameters->emit_perl5() . ' ' . chr(61) . ' ' . $arguments->emit_perl5() . ')')
        }
    }

;
    {
    package If;
        sub new { shift; bless { @_ }, "If" }
        sub emit_perl5 {
            my $List__ = bless \@_, "ARRAY";
            ((my  $self) = $List__->[0]);
            $self->emit_perl5_indented(0)
        };
        sub emit_perl5_indented {
            my $List__ = bless \@_, "ARRAY";
            ((my  $self) = $List__->[0]);
            ((my  $level) = $List__->[1]);
            return ((Perl5::tab($level) . 'if (' . $self->{cond}->emit_perl5() . (') ' . chr(123) . chr(10)) . (($self->{body} ? (join((chr(59) . chr(10)), @{[ map { $_->emit_perl5_indented(($level + 1)) } @{( $self->{body}->stmts() )} ]}) . (chr(10))) : '')) . Perl5::tab($level) . (chr(125)) . ((($self->{otherwise} && scalar( @{($self->{otherwise}->stmts())} )) ? ((chr(10) . Perl5::tab($level) . ('else ' . chr(123) . chr(10)) . join((chr(59) . chr(10)), @{[ map { $_->emit_perl5_indented(($level + 1)) } @{( $self->{otherwise}->stmts() )} ]}) . (chr(10)) . Perl5::tab($level) . (chr(125)))) : ''))))
        }
    }

;
    {
    package While;
        sub new { shift; bless { @_ }, "While" }
        sub emit_perl5 {
            my $List__ = bless \@_, "ARRAY";
            ((my  $self) = $List__->[0]);
            $self->emit_perl5_indented(0)
        };
        sub emit_perl5_indented {
            my $List__ = bless \@_, "ARRAY";
            ((my  $self) = $List__->[0]);
            ((my  $level) = $List__->[1]);
            ((my  $cond) = $self->{cond});
            if ((Main::isa($cond, 'Var') && ($cond->sigil() eq chr(64)))) {
                ($cond = Apply->new(('code' => 'prefix:<' . chr(64) . '>'), ('arguments' => (sub {
    (my  $List_a = bless [], 'ARRAY');
    (my  $List_v = bless [], 'ARRAY');
    push( @{$List_a}, $cond );
    $List_a
})->())))
            };
            (Perl5::tab($level) . 'for ( ' . (($self->{init} ? ($self->{init}->emit_perl5() . chr(59) . ' ') : chr(59) . ' ')) . (($cond ? ($cond->emit_perl5() . chr(59) . ' ') : chr(59) . ' ')) . (($self->{continue} ? ($self->{continue}->emit_perl5() . ' ') : ' ')) . ') ' . chr(123) . (chr(10)) . join((chr(59) . chr(10)), @{[ map { $_->emit_perl5_indented(($level + 1)) } @{( $self->{body}->stmts() )} ]}) . (chr(10)) . Perl5::tab($level) . (chr(125)))
        }
    }

;
    {
    package For;
        sub new { shift; bless { @_ }, "For" }
        sub emit_perl5 {
            my $List__ = bless \@_, "ARRAY";
            ((my  $self) = $List__->[0]);
            $self->emit_perl5_indented(0)
        };
        sub emit_perl5_indented {
            my $List__ = bless \@_, "ARRAY";
            ((my  $self) = $List__->[0]);
            ((my  $level) = $List__->[1]);
            ((my  $cond) = $self->{cond});
            if ((!(((Main::isa($cond, 'Var') && ($cond->sigil() eq chr(64))))))) {
                ($cond = Lit::Array->new(('array1' => (sub {
    (my  $List_a = bless [], 'ARRAY');
    (my  $List_v = bless [], 'ARRAY');
    push( @{$List_a}, $cond );
    $List_a
})->())))
            };
            (my  $sig);
            if (($self->{body}->sig())) {
                ($sig = ('my ' . $self->{body}->sig()->emit_perl5() . ' '))
            };
            return ((Perl5::tab($level) . 'for ' . $sig . '( ' . chr(64) . chr(123) . $cond->emit_perl5() . chr(125) . ' ) ' . chr(123) . (chr(10)) . join((chr(59) . chr(10)), @{[ map { $_->emit_perl5_indented(($level + 1)) } @{( $self->{body}->stmts() )} ]}) . (chr(10)) . Perl5::tab($level) . (chr(125))))
        }
    }

;
    {
    package Decl;
        sub new { shift; bless { @_ }, "Decl" }
        sub emit_perl5 {
            my $List__ = bless \@_, "ARRAY";
            ((my  $self) = $List__->[0]);
            $self->emit_perl5_indented(0)
        };
        sub emit_perl5_indented {
            my $List__ = bless \@_, "ARRAY";
            ((my  $self) = $List__->[0]);
            ((my  $level) = $List__->[1]);
            ((my  $decl) = $self->{decl});
            ((my  $name) = $self->{var}->plain_name());
            if ((($decl eq 'has'))) {
                return ((Perl5::tab($level) . 'sub ' . $name . ' ' . chr(123) . ' ' . chr(36) . '_[0]->' . chr(123) . $name . chr(125) . ' ' . chr(125)))
            };
            ((my  $str) = ('(' . $self->{decl} . ' ' . $self->{type} . ' ' . $self->{var}->emit_perl5()));
            if ((($self->{var})->sigil() eq chr(37))) {
                ($str = ($str . ' ' . chr(61) . ' bless ' . chr(123) . chr(125) . ', ' . chr(39) . 'HASH' . chr(39) . ')'))
            }
            else {
                if ((($self->{var})->sigil() eq chr(64))) {
                    ($str = ($str . ' ' . chr(61) . ' bless [], ' . chr(39) . 'ARRAY' . chr(39) . ')'))
                }
                else {
                    ($str = ($str . ')'))
                }
            };
            return ((Perl5::tab($level) . $str))
        }
    }

;
    {
    package Sub;
        sub new { shift; bless { @_ }, "Sub" }
        sub emit_perl5 {
            my $List__ = bless \@_, "ARRAY";
            ((my  $self) = $List__->[0]);
            $self->emit_perl5_indented(0)
        };
        sub emit_perl5_indented {
            my $List__ = bless \@_, "ARRAY";
            ((my  $self) = $List__->[0]);
            ((my  $level) = $List__->[1]);
            ((my  $sig) = $self->{sig});
            ((my  $pos) = $sig->positional());
            ((my  $str) = '');
            ((my  $i) = 0);
            for my $field ( @{($pos)} ) {
                ($str = ($str . (Perl5::tab(($level + 1)) . 'my ' . $field->emit_perl5() . ' ' . chr(61) . ' ' . chr(36) . '_[' . $i . ']' . chr(59) . (chr(10)))));
                ($i = ($i + 1))
            };
            (Perl5::tab($level) . 'sub ' . $self->{name} . (' ' . chr(123) . chr(10)) . Perl5::tab(($level + 1)) . 'my ' . chr(36) . 'List__ ' . chr(61) . ' bless ' . chr(92) . chr(64) . '_, ' . chr(34) . 'ARRAY' . chr(34) . chr(59) . (chr(10)) . $str . join((chr(59) . chr(10)), @{[ map { $_->emit_perl5_indented(($level + 1)) } @{( (defined $self->{block} ? $self->{block} : ($self->{block} ||= bless([], 'ARRAY'))) )} ]}) . (chr(10)) . Perl5::tab($level) . (chr(125)))
        }
    }

;
    {
    package Do;
        sub new { shift; bless { @_ }, "Do" }
        sub emit_perl5 {
            my $List__ = bless \@_, "ARRAY";
            ((my  $self) = $List__->[0]);
            $self->emit_perl5_indented(0)
        };
        sub emit_perl5_indented {
            my $List__ = bless \@_, "ARRAY";
            ((my  $self) = $List__->[0]);
            ((my  $level) = $List__->[1]);
            ((my  $block) = $self->simplify()->block());
            (Perl5::tab($level) . ('(sub ' . chr(123) . chr(10)) . join((chr(59) . chr(10)), @{[ map { $_->emit_perl5_indented(($level + 1)) } @{( $block )} ]}) . (chr(10)) . Perl5::tab($level) . (chr(125) . ')->()'))
        }
    }

;
    {
    package Use;
        sub new { shift; bless { @_ }, "Use" }
        sub emit_perl5 {
            my $List__ = bless \@_, "ARRAY";
            ((my  $self) = $List__->[0]);
            $self->emit_perl5_indented(0)
        };
        sub emit_perl5_indented {
            my $List__ = bless \@_, "ARRAY";
            ((my  $self) = $List__->[0]);
            ((my  $level) = $List__->[1]);
            if ((($self->{mod} eq 'strict') || ($self->{mod} eq 'feature'))) {
                return ((chr(10) . Perl5::tab($level) . (chr(35) . ' use ' . $self->{mod} . ' ' . chr(10))))
            };
            (Perl5::tab($level) . 'use ' . $self->{mod})
        }
    }


}

1;
