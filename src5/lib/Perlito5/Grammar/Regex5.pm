package Perlito5::Grammar::Regex5;

use Perlito5::Grammar::Precedence;
use strict;
use warnings;

token any { . };

token string_of_code {
    [  \\ .
    |  '{'  <.string_of_code> '}'
    |  <!before '}' > .
    ]+
};

token posix_character_class {
    | 'alpha'  
    | 'alnum'  
    | 'ascii'  
    | 'blank'  
    | 'cntrl'  
    | 'digit'  
    | 'graph'  
    | 'lower'  
    | 'print'  
    | 'punct'  
    | 'space'  
    | 'upper'  
    | 'word'
    | 'xdigit' 
    # | { die "POSIX class unknown in regex" }
};

token character {
    <!before ']' > <any>
    { $MATCH->{capture} = { character => Perlito5::Match::flat($MATCH->{any}) } }
};

token character2 {
    <!before ']' > <any>
    { $MATCH->{capture} = { character => Perlito5::Match::flat($MATCH->{any}) } }
};

token character_class {
        '[:' <posix_character_class> ':]'
          { $MATCH->{capture} = { posix_character_class => Perlito5::Match::flat($MATCH->{posix_character_class}) } }
    |
        '[:^' <posix_character_class> ':]'
          { $MATCH->{capture} = { negated_posix_character_class => Perlito5::Match::flat($MATCH->{posix_character_class}) } }
    |  <character>
        [ '-' <character2>
          { $MATCH->{capture} = { character_range => [ Perlito5::Match::flat($MATCH->{'character'}),
                                                       Perlito5::Match::flat($MATCH->{'character2'}), 
                                                     ]
          } }
        | { $MATCH->{capture} = Perlito5::Match::flat($MATCH->{'character'}) }
        ]
};

token character_class_list {
    <character_class>
    [   <character_class_list>
        { $MATCH->{capture} = [ Perlito5::Match::flat($MATCH->{character_class}),
                                @{Perlito5::Match::flat($MATCH->{character_class_list})} 
                              ]
        }
    |
        { $MATCH->{capture} = [ Perlito5::Match::flat($MATCH->{character_class}) ] }
    ]
    |   { $MATCH->{capture} = [] }
};

token verb {
    'PRUNE' | 'SKIP' | 'MARK' | 'THEN' | 'COMMIT' | 'FAIL' | 'F' | 'ACCEPT'
};

token rule_term {
    |   '^'     { $MATCH->{capture} = 'beginning_of_line' }
    |   '$'     { $MATCH->{capture} = 'end_of_line' }
    |   '.'     { $MATCH->{capture} = Perlito5::Rul::Dot->new() }

    |   '(' 
        [   '?'
            [   ':' <rule> ')'
                { $MATCH->{capture} = Perlito5::Match::flat($MATCH->{rule}) }
            |   '=' <rule> ')'
                { $MATCH->{capture} = Perlito5::Rul::Before->new( rule_exp => Perlito5::Match::flat($MATCH->{rule}) ) }
            |   '!' <rule> ')'
                { $MATCH->{capture} = Perlito5::Rul::NotBefore->new( rule_exp => Perlito5::Match::flat($MATCH->{rule}) ) }
            |   '>' <rule> ')'
                { $MATCH->{capture} = { 'possessive_quantifier' => Perlito5::Match::flat($MATCH->{rule}) } }
            |   '<' <Perlito5::Grammar.ident> '>' <rule> ')'
                { $MATCH->{capture} = { 'named_capture' => { name => Perlito5::Match::flat($MATCH->{'Perlito5::Grammar.ident'}),
                                                             term => Perlito5::Match::flat($MATCH->{rule}) } }
                }
            |   '{' <string_of_code>  '})'
                { $MATCH->{capture} = Perlito5::Rul::Block->new( closure => Perlito5::Match::flat($MATCH->{string_of_code}) ) }
            |   '#' [ <!before ')' > . ]* ')'
                { $MATCH->{capture} = 'comment' }
            ]
        |   '*'
            [   ':' <Perlito5::Grammar.ident> ')'
                { $MATCH->{capture} = { verb => 'MARK',
                                        name => Perlito5::Match::flat($MATCH->{'Perlito5::Grammar.ident'}) }
                }
            |   <verb>
                [   ':' <Perlito5::Grammar.ident> ')'
                    { $MATCH->{capture} = { verb => Perlito5::Match::flat($MATCH->{'verb'}),
                                            name => Perlito5::Match::flat($MATCH->{'Perlito5::Grammar.ident'}), }
                    }
                |   { $MATCH->{capture} = { verb => Perlito5::Match::flat($MATCH->{'verb'}) } }
                ]
            ]
        |   <rule> ')'
            { $MATCH->{capture} = Perlito5::Rul::Subrule->new( 
                                        metasyntax => Perlito5::Match::flat($MATCH->{rule}), captures => 1 ) 
            }
        ]

    |   \\
        [
        | 'c' \[ <Perlito5::Grammar::Number.digits> \]
          { $MATCH->{capture} = { character => chr( Perlito5::Match::flat($MATCH->{"Perlito5::Grammar::Number.digits"}) ) } }
        | 'c' <Perlito5::Grammar::Number.digits>
          { $MATCH->{capture} = { character => chr( Perlito5::Match::flat($MATCH->{"Perlito5::Grammar::Number.digits"}) ) } }
        | <any>   #  \e  \E
          { $MATCH->{capture} = { special_character => Perlito5::Match::flat($MATCH->{any}) } }
        ]

    |   '['
        [ '^' 
            [ ']' 
                [ <character_class_list> ']'
                  { $MATCH->{capture} = { negated_character_class => [
                                            { character => ']' },
                                            @{ Perlito5::Match::flat($MATCH->{character_class_list}) }
                                          ] 
                  } }
                | { die "Unmatched [ in regex" }
                ]
            | <character_class_list> ']'
              { $MATCH->{capture} = { negated_character_class => Perlito5::Match::flat($MATCH->{character_class_list}) } }
            | { die "Unmatched [ in regex" }
            ]
        | ']' 
            [ <character_class_list> ']'
              { $MATCH->{capture} = { character_class => [
                                        { character => ']' },
                                        @{ Perlito5::Match::flat($MATCH->{character_class_list}) }
                                      ] 
              } }
            | { die "Unmatched [ in regex" }
            ]
        | <character_class_list> ']'
          { $MATCH->{capture} = { character_class => Perlito5::Match::flat($MATCH->{character_class_list}) } }
        | { die "Unmatched [ in regex" }
        ]

    |   <!before '(' | ')' | '[' | ']' | '+' | '?' | '\\' | '|' | '*' >
        <any>
         { $MATCH->{capture} = { character => Perlito5::Match::flat($MATCH->{any}) } }
};

token quant_exp  {
    [
    | '?'
    | '*'
    | '+' 
    | '{' <Perlito5::Grammar::Number.digits> '}'
    | '{' <Perlito5::Grammar::Number.digits> ',' '}'
    | '{' <Perlito5::Grammar::Number.digits> ',' <Perlito5::Grammar::Number.digits> '}'
    ]
    [ '?' | '+' | '' ]
};

token quantifier {
    <rule_term> 
    [   <quant_exp> 
        { $MATCH->{capture} = { quantifier => {
                term    => Perlito5::Match::flat($MATCH->{rule_term}),
                quant   => Perlito5::Match::flat($MATCH->{quant_exp}),
            } }
        }
    |   { $MATCH->{capture} = Perlito5::Match::flat($MATCH->{rule_term}) }
    ]
};

token concat_list {
    <quantifier>
    [   <concat_list>
        { $MATCH->{capture} = [ Perlito5::Match::flat($MATCH->{quantifier}), @{Perlito5::Match::flat($MATCH->{concat_list})} ] }
    |
        { $MATCH->{capture} = [ Perlito5::Match::flat($MATCH->{quantifier}) ] }
    ]
    |   { $MATCH->{capture} = [] }
};

token concat_exp {
    <concat_list>
    {
        $arg = Perlito5::Match::flat($MATCH->{concat_list});
        if (@$arg < 1) {
            $MATCH->{capture} = "empty";
        }
        elsif (@$arg < 2) {
            ($MATCH->{capture}) = @$arg;
        }
        else {
            $MATCH->{capture} = { concat_list => $arg }
        }
    }
};

token or_list_exp {
    <concat_exp>
    [   '|' <or_list_exp>
        { $MATCH->{capture} = [ Perlito5::Match::flat($MATCH->{concat_exp}), @{Perlito5::Match::flat($MATCH->{or_list_exp})} ] }
    |
        { $MATCH->{capture} = [ Perlito5::Match::flat($MATCH->{concat_exp}) ] }
    ]
    |   { $MATCH->{capture} = [] }
};

token rule {
    <or_list_exp>
    {
        $arg = Perlito5::Match::flat($MATCH->{or_list_exp});
        if (@$arg < 1) {
            $MATCH->{capture} = "empty";
        }
        elsif (@$arg < 2) {
            ($MATCH->{capture}) = @$arg;
        }
        else {
            $MATCH->{capture} = { or_list => $arg }
        }
    }
};

=begin

=head1 NAME

Perlito5::Grammar::Regex5 - Grammar for Perl5 regex

=head1 SYNOPSIS

    my $match = Perlito5::Grammar::Regex5->rule( $source, $pos );
    Perlito5::Match::flat($match);    # generated Regex5 AST

=head1 DESCRIPTION

This module generates a syntax tree for the Regex5 compiler.

=head1 AUTHORS

Flavio Soibelmann Glock <fglock@gmail.com>.

=head1 COPYRIGHT

Copyright 2014 by Flavio Soibelmann Glock.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

See L<http://www.perl.com/perl/misc/Artistic.html>

=end
