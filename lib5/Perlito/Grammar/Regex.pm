# Do not edit this file - Generated by Perlito 6.0
use v5;
use utf8;
use strict;
use warnings;
no warnings ('redefine', 'once', 'void', 'uninitialized', 'misc', 'recursion');
use Perlito::Perl5::Runtime;
our $MATCH = Perlito::Match->new();
{
package GLOBAL;
sub new { shift; bless { @_ }, "GLOBAL" }

# use v6 
;
{
package Perlito::Grammar::Regex;
sub new { shift; bless { @_ }, "Perlito::Grammar::Regex" }
(my  $Hash_rule_terms = {});
sub ws { my $grammar = $_[0]; my $str = $_[1]; my $pos = $_[2]; (my  $MATCH = undef); ($MATCH = Perlito::Match->new(('str' => $str), ('from' => $pos), ('to' => $pos), ('bool' => 1))); (($MATCH)->{bool} = ((do { do { ((my  $pos1 = undef) = $MATCH->to()); (do { do { ((do { do { ((my  $m2 = undef) = Perlito::Grammar->ws($str, $MATCH->to())); if (Main::bool($m2)) { (($MATCH)->{to} = $m2->to()); 1 } else { 0 } } })) } }) } }))); $MATCH };
sub rule_ident { my $grammar = $_[0]; my $str = $_[1]; my $pos = $_[2]; (my  $MATCH = undef); ($MATCH = Perlito::Match->new(('str' => $str), ('from' => $pos), ('to' => $pos), ('bool' => 1))); (($MATCH)->{bool} = ((do { do { ((my  $pos1 = undef) = $MATCH->to()); ((do { do { ((do { do { ((my  $m2 = undef) = Perlito::Grammar->full_ident($str, $MATCH->to())); if (Main::bool($m2)) { (($MATCH)->{to} = $m2->to()); 1 } else { 0 } } })) } }) || (do { do { (($MATCH)->{to} = $pos1); ((do { do { ((my  $m2 = undef) = $grammar->digit($str, $MATCH->to())); if (Main::bool($m2)) { (($MATCH)->{to} = $m2->to()); ($MATCH->{'digit'} = $m2); 1 } else { 0 } } })) } })) } }))); $MATCH };
sub any { my $grammar = $_[0]; my $str = $_[1]; my $pos = $_[2]; (my  $MATCH = undef); ($MATCH = Perlito::Match->new(('str' => $str), ('from' => $pos), ('to' => $pos), ('bool' => 1))); (($MATCH)->{bool} = ((do { do { ((my  $pos1 = undef) = $MATCH->to()); (do { do { (((('' ne substr($str, $MATCH->to(), 1)) && ((($MATCH)->{to} = (1 + $MATCH->to())))))) } }) } }))); $MATCH };
sub literal { my $grammar = $_[0]; my $str = $_[1]; my $pos = $_[2]; (my  $MATCH = undef); ($MATCH = Perlito::Match->new(('str' => $str), ('from' => $pos), ('to' => $pos), ('bool' => 1))); (($MATCH)->{bool} = ((do { do { ((my  $pos1 = undef) = $MATCH->to()); (do { do { ((do { do { ((my  $last_match_null = undef) = 0); ((my  $last_pos = undef) = $MATCH->to()); for ( ; Main::bool(((do { do { ((my  $pos1 = undef) = $MATCH->to()); ((do { do { ((((('\\' eq substr($str, $MATCH->to(), 1)) && ((($MATCH)->{to} = (1 + $MATCH->to()))))) && ((('' ne substr($str, $MATCH->to(), 1)) && ((($MATCH)->{to} = (1 + $MATCH->to()))))))) } }) || (do { do { (($MATCH)->{to} = $pos1); (((do { do { ((my  $tmp = undef) = $MATCH); ($MATCH = Perlito::Match->new(('str' => $str), ('from' => $tmp->to()), ('to' => $tmp->to()), ('bool' => 1))); (($MATCH)->{bool} = (do { do { ((my  $pos1 = undef) = $MATCH->to()); (do { do { (((('\'' eq substr($str, $MATCH->to(), 1)) && ((($MATCH)->{to} = (1 + $MATCH->to())))))) } }) } })); (($tmp)->{bool} = ($MATCH ? 0 : 1)); ($MATCH = $tmp); ($MATCH ? 1 : 0) } }) && ((('' ne substr($str, $MATCH->to(), 1)) && ((($MATCH)->{to} = (1 + $MATCH->to()))))))) } })) } }) && (($last_match_null < 2))));  ) { if (Main::bool(($last_pos == $MATCH->to()))) { ($last_match_null = ($last_match_null + 1)) } else { ($last_match_null = 0) }; ($last_pos = $MATCH->to()) }; (($MATCH)->{to} = $last_pos); 1 } })) } }) } }))); $MATCH };
sub metasyntax_exp { my $grammar = $_[0]; my $str = $_[1]; my $pos = $_[2]; (my  $MATCH = undef); ($MATCH = Perlito::Match->new(('str' => $str), ('from' => $pos), ('to' => $pos), ('bool' => 1))); (($MATCH)->{bool} = ((do { do { ((my  $pos1 = undef) = $MATCH->to()); (do { do { ((do { do { ((my  $last_match_null = undef) = 0); ((my  $last_pos = undef) = $MATCH->to()); ((my  $count = undef) = 0); for ( ; Main::bool(((do { do { ((my  $pos1 = undef) = $MATCH->to()); (((((do { do { ((((('\\' eq substr($str, $MATCH->to(), 1)) && ((($MATCH)->{to} = (1 + $MATCH->to()))))) && ((('' ne substr($str, $MATCH->to(), 1)) && ((($MATCH)->{to} = (1 + $MATCH->to()))))))) } }) || (do { do { (($MATCH)->{to} = $pos1); (((((('\'' eq substr($str, $MATCH->to(), 1)) && ((($MATCH)->{to} = (1 + $MATCH->to()))))) && (do { do { ((my  $m2 = undef) = $grammar->literal($str, $MATCH->to())); if (Main::bool($m2)) { (($MATCH)->{to} = $m2->to()); 1 } else { 0 } } })) && ((('\'' eq substr($str, $MATCH->to(), 1)) && ((($MATCH)->{to} = (1 + $MATCH->to()))))))) } })) || (do { do { (($MATCH)->{to} = $pos1); (((((('{' eq substr($str, $MATCH->to(), 1)) && ((($MATCH)->{to} = (1 + $MATCH->to()))))) && (do { do { ((my  $m2 = undef) = $grammar->string_code($str, $MATCH->to())); if (Main::bool($m2)) { (($MATCH)->{to} = $m2->to()); 1 } else { 0 } } })) && ((('}' eq substr($str, $MATCH->to(), 1)) && ((($MATCH)->{to} = (1 + $MATCH->to()))))))) } })) || (do { do { (($MATCH)->{to} = $pos1); (((((('<' eq substr($str, $MATCH->to(), 1)) && ((($MATCH)->{to} = (1 + $MATCH->to()))))) && (do { do { ((my  $m2 = undef) = $grammar->metasyntax_exp($str, $MATCH->to())); if (Main::bool($m2)) { (($MATCH)->{to} = $m2->to()); 1 } else { 0 } } })) && ((('>' eq substr($str, $MATCH->to(), 1)) && ((($MATCH)->{to} = (1 + $MATCH->to()))))))) } })) || (do { do { (($MATCH)->{to} = $pos1); (((do { do { ((my  $tmp = undef) = $MATCH); ($MATCH = Perlito::Match->new(('str' => $str), ('from' => $tmp->to()), ('to' => $tmp->to()), ('bool' => 1))); (($MATCH)->{bool} = (do { do { ((my  $pos1 = undef) = $MATCH->to()); (do { do { (((('>' eq substr($str, $MATCH->to(), 1)) && ((($MATCH)->{to} = (1 + $MATCH->to())))))) } }) } })); (($tmp)->{bool} = ($MATCH ? 0 : 1)); ($MATCH = $tmp); ($MATCH ? 1 : 0) } }) && ((('' ne substr($str, $MATCH->to(), 1)) && ((($MATCH)->{to} = (1 + $MATCH->to()))))))) } })) } }) && (($last_match_null < 2))));  ) { if (Main::bool(($last_pos == $MATCH->to()))) { ($last_match_null = ($last_match_null + 1)) } else { ($last_match_null = 0) }; ($last_pos = $MATCH->to()); ($count = ($count + 1)) }; (($MATCH)->{to} = $last_pos); ($count > 0) } })) } }) } }))); $MATCH };
sub char_range { my $grammar = $_[0]; my $str = $_[1]; my $pos = $_[2]; (my  $MATCH = undef); ($MATCH = Perlito::Match->new(('str' => $str), ('from' => $pos), ('to' => $pos), ('bool' => 1))); (($MATCH)->{bool} = ((do { do { ((my  $pos1 = undef) = $MATCH->to()); (do { do { ((do { do { ((my  $last_match_null = undef) = 0); ((my  $last_pos = undef) = $MATCH->to()); ((my  $count = undef) = 0); for ( ; Main::bool(((do { do { ((my  $pos1 = undef) = $MATCH->to()); ((do { do { ((((('\\' eq substr($str, $MATCH->to(), 1)) && ((($MATCH)->{to} = (1 + $MATCH->to()))))) && ((('' ne substr($str, $MATCH->to(), 1)) && ((($MATCH)->{to} = (1 + $MATCH->to()))))))) } }) || (do { do { (($MATCH)->{to} = $pos1); (((do { do { ((my  $tmp = undef) = $MATCH); ($MATCH = Perlito::Match->new(('str' => $str), ('from' => $tmp->to()), ('to' => $tmp->to()), ('bool' => 1))); (($MATCH)->{bool} = (do { do { ((my  $pos1 = undef) = $MATCH->to()); (do { do { ((((']' eq substr($str, $MATCH->to(), 1)) && ((($MATCH)->{to} = (1 + $MATCH->to())))))) } }) } })); (($tmp)->{bool} = ($MATCH ? 0 : 1)); ($MATCH = $tmp); ($MATCH ? 1 : 0) } }) && ((('' ne substr($str, $MATCH->to(), 1)) && ((($MATCH)->{to} = (1 + $MATCH->to()))))))) } })) } }) && (($last_match_null < 2))));  ) { if (Main::bool(($last_pos == $MATCH->to()))) { ($last_match_null = ($last_match_null + 1)) } else { ($last_match_null = 0) }; ($last_pos = $MATCH->to()); ($count = ($count + 1)) }; (($MATCH)->{to} = $last_pos); ($count > 0) } })) } }) } }))); $MATCH };
sub char_class { my $grammar = $_[0]; my $str = $_[1]; my $pos = $_[2]; (my  $MATCH = undef); ($MATCH = Perlito::Match->new(('str' => $str), ('from' => $pos), ('to' => $pos), ('bool' => 1))); (($MATCH)->{bool} = ((do { do { ((my  $pos1 = undef) = $MATCH->to()); ((do { do { ((do { do { ((my  $m2 = undef) = $grammar->rule_ident($str, $MATCH->to())); if (Main::bool($m2)) { (($MATCH)->{to} = $m2->to()); 1 } else { 0 } } })) } }) || (do { do { (($MATCH)->{to} = $pos1); (((((('[' eq substr($str, $MATCH->to(), 1)) && ((($MATCH)->{to} = (1 + $MATCH->to()))))) && (do { do { ((my  $m2 = undef) = $grammar->char_range($str, $MATCH->to())); if (Main::bool($m2)) { (($MATCH)->{to} = $m2->to()); 1 } else { 0 } } })) && (((']' eq substr($str, $MATCH->to(), 1)) && ((($MATCH)->{to} = (1 + $MATCH->to()))))))) } })) } }))); $MATCH };
sub string_code { my $grammar = $_[0]; my $str = $_[1]; my $pos = $_[2]; (my  $MATCH = undef); ($MATCH = Perlito::Match->new(('str' => $str), ('from' => $pos), ('to' => $pos), ('bool' => 1))); (($MATCH)->{bool} = ((do { do { ((my  $pos1 = undef) = $MATCH->to()); (do { do { ((do { do { ((my  $last_match_null = undef) = 0); ((my  $last_pos = undef) = $MATCH->to()); ((my  $count = undef) = 0); for ( ; Main::bool(((do { do { ((my  $pos1 = undef) = $MATCH->to()); ((((do { do { ((((('\\' eq substr($str, $MATCH->to(), 1)) && ((($MATCH)->{to} = (1 + $MATCH->to()))))) && ((('' ne substr($str, $MATCH->to(), 1)) && ((($MATCH)->{to} = (1 + $MATCH->to()))))))) } }) || (do { do { (($MATCH)->{to} = $pos1); (((((('\'' eq substr($str, $MATCH->to(), 1)) && ((($MATCH)->{to} = (1 + $MATCH->to()))))) && (do { do { ((my  $m2 = undef) = $grammar->literal($str, $MATCH->to())); if (Main::bool($m2)) { (($MATCH)->{to} = $m2->to()); 1 } else { 0 } } })) && ((('\'' eq substr($str, $MATCH->to(), 1)) && ((($MATCH)->{to} = (1 + $MATCH->to()))))))) } })) || (do { do { (($MATCH)->{to} = $pos1); (((((('{' eq substr($str, $MATCH->to(), 1)) && ((($MATCH)->{to} = (1 + $MATCH->to()))))) && (do { do { ((my  $m2 = undef) = $grammar->string_code($str, $MATCH->to())); if (Main::bool($m2)) { (($MATCH)->{to} = $m2->to()); 1 } else { 0 } } })) && ((('}' eq substr($str, $MATCH->to(), 1)) && ((($MATCH)->{to} = (1 + $MATCH->to()))))))) } })) || (do { do { (($MATCH)->{to} = $pos1); (((do { do { ((my  $tmp = undef) = $MATCH); ($MATCH = Perlito::Match->new(('str' => $str), ('from' => $tmp->to()), ('to' => $tmp->to()), ('bool' => 1))); (($MATCH)->{bool} = (do { do { ((my  $pos1 = undef) = $MATCH->to()); (do { do { (((('}' eq substr($str, $MATCH->to(), 1)) && ((($MATCH)->{to} = (1 + $MATCH->to())))))) } }) } })); (($tmp)->{bool} = ($MATCH ? 0 : 1)); ($MATCH = $tmp); ($MATCH ? 1 : 0) } }) && ((('' ne substr($str, $MATCH->to(), 1)) && ((($MATCH)->{to} = (1 + $MATCH->to()))))))) } })) } }) && (($last_match_null < 2))));  ) { if (Main::bool(($last_pos == $MATCH->to()))) { ($last_match_null = ($last_match_null + 1)) } else { ($last_match_null = 0) }; ($last_pos = $MATCH->to()); ($count = ($count + 1)) }; (($MATCH)->{to} = $last_pos); ($count > 0) } })) } }) } }))); $MATCH };
sub parsed_code { my $grammar = $_[0]; my $str = $_[1]; my $pos = $_[2]; (my  $MATCH = undef); ($MATCH = Perlito::Match->new(('str' => $str), ('from' => $pos), ('to' => $pos), ('bool' => 1))); (($MATCH)->{bool} = ((do { do { ((my  $pos1 = undef) = $MATCH->to()); (do { do { (((do { do { ((my  $m2 = undef) = $grammar->string_code($str, $MATCH->to())); if (Main::bool($m2)) { (($MATCH)->{to} = $m2->to()); 1 } else { 0 } } }) && (((do { do { ($MATCH->{capture} = (("" . $MATCH))) } }) || 1)))) } }) } }))); $MATCH };
sub named_capture_body { my $grammar = $_[0]; my $str = $_[1]; my $pos = $_[2]; (my  $MATCH = undef); ($MATCH = Perlito::Match->new(('str' => $str), ('from' => $pos), ('to' => $pos), ('bool' => 1))); (($MATCH)->{bool} = ((do { do { ((my  $pos1 = undef) = $MATCH->to()); ((((do { do { ((((((('(' eq substr($str, $MATCH->to(), 1)) && ((($MATCH)->{to} = (1 + $MATCH->to()))))) && (do { do { ((my  $m2 = undef) = $grammar->rule($str, $MATCH->to())); if (Main::bool($m2)) { (($MATCH)->{to} = $m2->to()); ($MATCH->{'rule'} = $m2); 1 } else { 0 } } })) && (((')' eq substr($str, $MATCH->to(), 1)) && ((($MATCH)->{to} = (1 + $MATCH->to())))))) && (((do { do { ($MATCH->{capture} = ({ ('capturing_group' => ${$MATCH->{'rule'}}) })) } }) || 1)))) } }) || (do { do { (($MATCH)->{to} = $pos1); ((((((('[' eq substr($str, $MATCH->to(), 1)) && ((($MATCH)->{to} = (1 + $MATCH->to()))))) && (do { do { ((my  $m2 = undef) = $grammar->rule($str, $MATCH->to())); if (Main::bool($m2)) { (($MATCH)->{to} = $m2->to()); ($MATCH->{'rule'} = $m2); 1 } else { 0 } } })) && (((']' eq substr($str, $MATCH->to(), 1)) && ((($MATCH)->{to} = (1 + $MATCH->to())))))) && (((do { do { ($MATCH->{capture} = (${$MATCH->{'rule'}})) } }) || 1)))) } })) || (do { do { (($MATCH)->{to} = $pos1); ((((((('<' eq substr($str, $MATCH->to(), 1)) && ((($MATCH)->{to} = (1 + $MATCH->to()))))) && (do { do { ((my  $m2 = undef) = $grammar->metasyntax_exp($str, $MATCH->to())); if (Main::bool($m2)) { (($MATCH)->{to} = $m2->to()); ($MATCH->{'metasyntax_exp'} = $m2); 1 } else { 0 } } })) && ((('>' eq substr($str, $MATCH->to(), 1)) && ((($MATCH)->{to} = (1 + $MATCH->to())))))) && (((do { do { ($MATCH->{capture} = (Rul::Subrule->new(('metasyntax' => ${$MATCH->{'metasyntax_exp'}}), ('captures' => 1)))) } }) || 1)))) } })) || (do { do { (($MATCH)->{to} = $pos1); ((((do { do { die('invalid alias syntax') } }) || 1))) } })) } }))); $MATCH };
sub variables { my $grammar = $_[0]; my $str = $_[1]; my $pos = $_[2]; (my  $MATCH = undef); ($MATCH = Perlito::Match->new(('str' => $str), ('from' => $pos), ('to' => $pos), ('bool' => 1))); (($MATCH)->{bool} = ((do { do { ((my  $pos1 = undef) = $MATCH->to()); (((do { do { ((((((('$<' eq substr($str, $MATCH->to(), 2)) && ((($MATCH)->{to} = (2 + $MATCH->to()))))) && (do { do { ((my  $m2 = undef) = $grammar->rule_ident($str, $MATCH->to())); if (Main::bool($m2)) { (($MATCH)->{to} = $m2->to()); ($MATCH->{'rule_ident'} = $m2); 1 } else { 0 } } })) && ((('>' eq substr($str, $MATCH->to(), 1)) && ((($MATCH)->{to} = (1 + $MATCH->to())))))) && (((do { do { ($MATCH->{capture} = ('$/{' . '\'' . $MATCH->{'rule_ident'} . '\'' . '}')) } }) || 1)))) } }) || (do { do { (($MATCH)->{to} = $pos1); ((((do { do { ((my  $m2 = undef) = Perlito::Grammar->var_sigil($str, $MATCH->to())); if (Main::bool($m2)) { (($MATCH)->{to} = $m2->to()); ($MATCH->{'Perlito::Grammar.var_sigil'} = $m2); 1 } else { 0 } } }) && (do { do { ((my  $m2 = undef) = Perlito::Grammar->val_int($str, $MATCH->to())); if (Main::bool($m2)) { (($MATCH)->{to} = $m2->to()); ($MATCH->{'Perlito::Grammar.val_int'} = $m2); 1 } else { 0 } } })) && (((do { do { ($MATCH->{capture} = ($MATCH->{'Perlito::Grammar.var_sigil'} . '/[' . $MATCH->{'Perlito::Grammar.val_int'} . ']')) } }) || 1)))) } })) || (do { do { (($MATCH)->{to} = $pos1); (((((do { do { ((my  $m2 = undef) = Perlito::Grammar->var_sigil($str, $MATCH->to())); if (Main::bool($m2)) { (($MATCH)->{to} = $m2->to()); ($MATCH->{'Perlito::Grammar.var_sigil'} = $m2); 1 } else { 0 } } }) && (do { do { ((my  $m2 = undef) = Perlito::Grammar->var_twigil($str, $MATCH->to())); if (Main::bool($m2)) { (($MATCH)->{to} = $m2->to()); ($MATCH->{'Perlito::Grammar.var_twigil'} = $m2); 1 } else { 0 } } })) && (do { do { ((my  $m2 = undef) = Perlito::Grammar->full_ident($str, $MATCH->to())); if (Main::bool($m2)) { (($MATCH)->{to} = $m2->to()); ($MATCH->{'Perlito::Grammar.full_ident'} = $m2); 1 } else { 0 } } })) && (((do { do { ($MATCH->{capture} = (Rul::Var->new(('sigil' => ("" . $MATCH->{'Perlito::Grammar.var_sigil'})), ('twigil' => ("" . $MATCH->{'Perlito::Grammar.var_twigil'})), ('name' => ("" . $MATCH->{'Perlito::Grammar.full_ident'}))))) } }) || 1)))) } })) } }))); $MATCH };
sub rule_terms { my $grammar = $_[0]; my $str = $_[1]; my $pos = $_[2]; (my  $MATCH = undef); ($MATCH = Perlito::Match->new(('str' => $str), ('from' => $pos), ('to' => $pos), ('bool' => 1))); (($MATCH)->{bool} = ((do { do { ((my  $pos1 = undef) = $MATCH->to()); (((((((((((((((do { do { ((((((('(' eq substr($str, $MATCH->to(), 1)) && ((($MATCH)->{to} = (1 + $MATCH->to()))))) && (do { do { ((my  $m2 = undef) = $grammar->rule($str, $MATCH->to())); if (Main::bool($m2)) { (($MATCH)->{to} = $m2->to()); ($MATCH->{'rule'} = $m2); 1 } else { 0 } } })) && (((')' eq substr($str, $MATCH->to(), 1)) && ((($MATCH)->{to} = (1 + $MATCH->to())))))) && (((do { do { ($MATCH->{capture} = (Rul::Capture->new(('rule_exp' => ${$MATCH->{'rule'}})))) } }) || 1)))) } }) || (do { do { (($MATCH)->{to} = $pos1); ((((((('<(' eq substr($str, $MATCH->to(), 2)) && ((($MATCH)->{to} = (2 + $MATCH->to()))))) && (do { do { ((my  $m2 = undef) = $grammar->rule($str, $MATCH->to())); if (Main::bool($m2)) { (($MATCH)->{to} = $m2->to()); ($MATCH->{'rule'} = $m2); 1 } else { 0 } } })) && (((')>' eq substr($str, $MATCH->to(), 2)) && ((($MATCH)->{to} = (2 + $MATCH->to())))))) && (((do { do { ($MATCH->{capture} = (Rul::CaptureResult->new(('rule_exp' => ${$MATCH->{'rule'}})))) } }) || 1)))) } })) || (do { do { (($MATCH)->{to} = $pos1); (((((((('<after' eq substr($str, $MATCH->to(), 6)) && ((($MATCH)->{to} = (6 + $MATCH->to()))))) && (do { do { ((my  $m2 = undef) = $grammar->ws($str, $MATCH->to())); if (Main::bool($m2)) { (($MATCH)->{to} = $m2->to()); 1 } else { 0 } } })) && (do { do { ((my  $m2 = undef) = $grammar->rule($str, $MATCH->to())); if (Main::bool($m2)) { (($MATCH)->{to} = $m2->to()); ($MATCH->{'rule'} = $m2); 1 } else { 0 } } })) && ((('>' eq substr($str, $MATCH->to(), 1)) && ((($MATCH)->{to} = (1 + $MATCH->to())))))) && (((do { do { ($MATCH->{capture} = (Rul::After->new(('rule_exp' => ${$MATCH->{'rule'}})))) } }) || 1)))) } })) || (do { do { (($MATCH)->{to} = $pos1); (((((((('<before' eq substr($str, $MATCH->to(), 7)) && ((($MATCH)->{to} = (7 + $MATCH->to()))))) && (do { do { ((my  $m2 = undef) = $grammar->ws($str, $MATCH->to())); if (Main::bool($m2)) { (($MATCH)->{to} = $m2->to()); 1 } else { 0 } } })) && (do { do { ((my  $m2 = undef) = $grammar->rule($str, $MATCH->to())); if (Main::bool($m2)) { (($MATCH)->{to} = $m2->to()); ($MATCH->{'rule'} = $m2); 1 } else { 0 } } })) && ((('>' eq substr($str, $MATCH->to(), 1)) && ((($MATCH)->{to} = (1 + $MATCH->to())))))) && (((do { do { ($MATCH->{capture} = (Rul::Before->new(('rule_exp' => ${$MATCH->{'rule'}})))) } }) || 1)))) } })) || (do { do { (($MATCH)->{to} = $pos1); (((((((('<!before' eq substr($str, $MATCH->to(), 8)) && ((($MATCH)->{to} = (8 + $MATCH->to()))))) && (do { do { ((my  $m2 = undef) = $grammar->ws($str, $MATCH->to())); if (Main::bool($m2)) { (($MATCH)->{to} = $m2->to()); 1 } else { 0 } } })) && (do { do { ((my  $m2 = undef) = $grammar->rule($str, $MATCH->to())); if (Main::bool($m2)) { (($MATCH)->{to} = $m2->to()); ($MATCH->{'rule'} = $m2); 1 } else { 0 } } })) && ((('>' eq substr($str, $MATCH->to(), 1)) && ((($MATCH)->{to} = (1 + $MATCH->to())))))) && (((do { do { ($MATCH->{capture} = (Rul::NotBefore->new(('rule_exp' => ${$MATCH->{'rule'}})))) } }) || 1)))) } })) || (do { do { (($MATCH)->{to} = $pos1); ((((((('<!' eq substr($str, $MATCH->to(), 2)) && ((($MATCH)->{to} = (2 + $MATCH->to()))))) && (do { do { ((my  $m2 = undef) = $grammar->metasyntax_exp($str, $MATCH->to())); if (Main::bool($m2)) { (($MATCH)->{to} = $m2->to()); ($MATCH->{'metasyntax_exp'} = $m2); 1 } else { 0 } } })) && ((('>' eq substr($str, $MATCH->to(), 1)) && ((($MATCH)->{to} = (1 + $MATCH->to())))))) && (((do { do { ($MATCH->{capture} = ({ ('negate' => { ('metasyntax' => ${$MATCH->{'metasyntax_exp'}}) }) })) } }) || 1)))) } })) || (do { do { (($MATCH)->{to} = $pos1); ((((((('<+' eq substr($str, $MATCH->to(), 2)) && ((($MATCH)->{to} = (2 + $MATCH->to()))))) && (do { do { ((my  $m2 = undef) = $grammar->char_class($str, $MATCH->to())); if (Main::bool($m2)) { (($MATCH)->{to} = $m2->to()); ($MATCH->{'char_class'} = $m2); 1 } else { 0 } } })) && ((('>' eq substr($str, $MATCH->to(), 1)) && ((($MATCH)->{to} = (1 + $MATCH->to())))))) && (((do { do { ($MATCH->{capture} = (Rul::CharClass->new(('chars' => ("" . $MATCH->{'char_class'}))))) } }) || 1)))) } })) || (do { do { (($MATCH)->{to} = $pos1); ((((((('<-' eq substr($str, $MATCH->to(), 2)) && ((($MATCH)->{to} = (2 + $MATCH->to()))))) && (do { do { ((my  $m2 = undef) = $grammar->char_class($str, $MATCH->to())); if (Main::bool($m2)) { (($MATCH)->{to} = $m2->to()); ($MATCH->{'char_class'} = $m2); 1 } else { 0 } } })) && ((('>' eq substr($str, $MATCH->to(), 1)) && ((($MATCH)->{to} = (1 + $MATCH->to())))))) && (((do { do { ($MATCH->{capture} = (Rul::NegateCharClass->new(('chars' => ("" . $MATCH->{'char_class'}))))) } }) || 1)))) } })) || (do { do { (($MATCH)->{to} = $pos1); ((((((('\'' eq substr($str, $MATCH->to(), 1)) && ((($MATCH)->{to} = (1 + $MATCH->to()))))) && (do { do { ((my  $m2 = undef) = $grammar->literal($str, $MATCH->to())); if (Main::bool($m2)) { (($MATCH)->{to} = $m2->to()); ($MATCH->{'literal'} = $m2); 1 } else { 0 } } })) && ((('\'' eq substr($str, $MATCH->to(), 1)) && ((($MATCH)->{to} = (1 + $MATCH->to())))))) && (((do { do { ($MATCH->{capture} = (Rul::Constant->new(('constant' => ${$MATCH->{'literal'}})))) } }) || 1)))) } })) || (do { do { (($MATCH)->{to} = $pos1); ((((((((('<' eq substr($str, $MATCH->to(), 1)) && ((($MATCH)->{to} = (1 + $MATCH->to()))))) && ((('\'' eq substr($str, $MATCH->to(), 1)) && ((($MATCH)->{to} = (1 + $MATCH->to())))))) && (do { do { ((my  $m2 = undef) = $grammar->literal($str, $MATCH->to())); if (Main::bool($m2)) { (($MATCH)->{to} = $m2->to()); ($MATCH->{'literal'} = $m2); 1 } else { 0 } } })) && ((('\'' eq substr($str, $MATCH->to(), 1)) && ((($MATCH)->{to} = (1 + $MATCH->to())))))) && ((('>' eq substr($str, $MATCH->to(), 1)) && ((($MATCH)->{to} = (1 + $MATCH->to())))))) && (((do { do { ($MATCH->{capture} = (Rul::Constant->new(('constant' => ${$MATCH->{'literal'}})))) } }) || 1)))) } })) || (do { do { (($MATCH)->{to} = $pos1); ((((('<' eq substr($str, $MATCH->to(), 1)) && ((($MATCH)->{to} = (1 + $MATCH->to()))))) && (do { do { ((my  $pos1 = undef) = $MATCH->to()); ((((do { do { ((((do { do { ((my  $m2 = undef) = $grammar->variables($str, $MATCH->to())); if (Main::bool($m2)) { (($MATCH)->{to} = $m2->to()); ($MATCH->{'variables'} = $m2); 1 } else { 0 } } }) && ((('>' eq substr($str, $MATCH->to(), 1)) && ((($MATCH)->{to} = (1 + $MATCH->to())))))) && (((do { do { ($MATCH->{capture} = (Rul::InterpolateVar->new(('var' => ${$MATCH->{'variables'}})))) } }) || 1)))) } }) || (do { do { (($MATCH)->{to} = $pos1); ((((((('?' eq substr($str, $MATCH->to(), 1)) && ((($MATCH)->{to} = (1 + $MATCH->to()))))) && (do { do { ((my  $m2 = undef) = $grammar->metasyntax_exp($str, $MATCH->to())); if (Main::bool($m2)) { (($MATCH)->{to} = $m2->to()); ($MATCH->{'metasyntax_exp'} = $m2); 1 } else { 0 } } })) && ((('>' eq substr($str, $MATCH->to(), 1)) && ((($MATCH)->{to} = (1 + $MATCH->to())))))) && (((do { do { ($MATCH->{capture} = (Rul::Subrule->new(('metasyntax' => ${$MATCH->{'metasyntax_exp'}}), ('captures' => 0)))) } }) || 1)))) } })) || (do { do { (($MATCH)->{to} = $pos1); ((((((('.' eq substr($str, $MATCH->to(), 1)) && ((($MATCH)->{to} = (1 + $MATCH->to()))))) && (do { do { ((my  $m2 = undef) = $grammar->metasyntax_exp($str, $MATCH->to())); if (Main::bool($m2)) { (($MATCH)->{to} = $m2->to()); ($MATCH->{'metasyntax_exp'} = $m2); 1 } else { 0 } } })) && ((('>' eq substr($str, $MATCH->to(), 1)) && ((($MATCH)->{to} = (1 + $MATCH->to())))))) && (((do { do { ($MATCH->{capture} = (Rul::Subrule->new(('metasyntax' => ${$MATCH->{'metasyntax_exp'}}), ('captures' => 0)))) } }) || 1)))) } })) || (do { do { (($MATCH)->{to} = $pos1); ((((do { do { ((my  $m2 = undef) = $grammar->metasyntax_exp($str, $MATCH->to())); if (Main::bool($m2)) { (($MATCH)->{to} = $m2->to()); ($MATCH->{'metasyntax_exp'} = $m2); 1 } else { 0 } } }) && ((('>' eq substr($str, $MATCH->to(), 1)) && ((($MATCH)->{to} = (1 + $MATCH->to())))))) && (((do { do { ($MATCH->{capture} = (Rul::Subrule->new(('metasyntax' => ${$MATCH->{'metasyntax_exp'}}), ('captures' => 1)))) } }) || 1)))) } })) } }))) } })) || (do { do { (($MATCH)->{to} = $pos1); ((((((('{' eq substr($str, $MATCH->to(), 1)) && ((($MATCH)->{to} = (1 + $MATCH->to()))))) && (do { do { ((my  $m2 = undef) = $grammar->parsed_code($str, $MATCH->to())); if (Main::bool($m2)) { (($MATCH)->{to} = $m2->to()); ($MATCH->{'parsed_code'} = $m2); 1 } else { 0 } } })) && ((('}' eq substr($str, $MATCH->to(), 1)) && ((($MATCH)->{to} = (1 + $MATCH->to())))))) && (((do { do { ($MATCH->{capture} = (Rul::Block->new(('closure' => ${$MATCH->{'parsed_code'}})))) } }) || 1)))) } })) || (do { do { (($MATCH)->{to} = $pos1); ((((('\\' eq substr($str, $MATCH->to(), 1)) && ((($MATCH)->{to} = (1 + $MATCH->to()))))) && (do { do { ((my  $pos1 = undef) = $MATCH->to()); (do { do { (((do { do { ((my  $m2 = undef) = $grammar->any($str, $MATCH->to())); if (Main::bool($m2)) { (($MATCH)->{to} = $m2->to()); ($MATCH->{'any'} = $m2); 1 } else { 0 } } }) && (((do { do { ($MATCH->{capture} = (Rul::SpecialChar->new(('char' => ${$MATCH->{'any'}})))) } }) || 1)))) } }) } }))) } })) || (do { do { (($MATCH)->{to} = $pos1); ((((('.' eq substr($str, $MATCH->to(), 1)) && ((($MATCH)->{to} = (1 + $MATCH->to()))))) && (((do { do { ($MATCH->{capture} = (Rul::Dot->new())) } }) || 1)))) } })) || (do { do { (($MATCH)->{to} = $pos1); ((((((('[' eq substr($str, $MATCH->to(), 1)) && ((($MATCH)->{to} = (1 + $MATCH->to()))))) && (do { do { ((my  $m2 = undef) = $grammar->rule($str, $MATCH->to())); if (Main::bool($m2)) { (($MATCH)->{to} = $m2->to()); ($MATCH->{'rule'} = $m2); 1 } else { 0 } } })) && (((']' eq substr($str, $MATCH->to(), 1)) && ((($MATCH)->{to} = (1 + $MATCH->to())))))) && (((do { do { ($MATCH->{capture} = (${$MATCH->{'rule'}})) } }) || 1)))) } })) } }))); $MATCH };
sub rule_term { my $grammar = $_[0]; my $str = $_[1]; my $pos = $_[2]; (my  $MATCH = undef); ($MATCH = Perlito::Match->new(('str' => $str), ('from' => $pos), ('to' => $pos), ('bool' => 1))); (($MATCH)->{bool} = ((do { do { ((my  $pos1 = undef) = $MATCH->to()); (((do { do { (((do { do { ((my  $m2 = undef) = $grammar->variables($str, $MATCH->to())); if (Main::bool($m2)) { (($MATCH)->{to} = $m2->to()); ($MATCH->{'variables'} = $m2); 1 } else { 0 } } }) && (do { do { ((my  $pos1 = undef) = $MATCH->to()); ((do { do { ((((((do { do { ((my  $last_pos = undef) = $MATCH->to()); if (Main::bool(((do { do { (do { do { ((my  $m2 = undef) = $grammar->ws($str, $MATCH->to())); if (Main::bool($m2)) { (($MATCH)->{to} = $m2->to()); 1 } else { 0 } } }) } }) ? 0 : 1))) { (($MATCH)->{to} = $last_pos) } ; 1 } }) && ((('=' eq substr($str, $MATCH->to(), 1)) && ((($MATCH)->{to} = (1 + $MATCH->to())))))) && (do { do { ((my  $last_pos = undef) = $MATCH->to()); if (Main::bool(((do { do { (do { do { ((my  $m2 = undef) = $grammar->ws($str, $MATCH->to())); if (Main::bool($m2)) { (($MATCH)->{to} = $m2->to()); 1 } else { 0 } } }) } }) ? 0 : 1))) { (($MATCH)->{to} = $last_pos) } ; 1 } })) && (do { do { ((my  $m2 = undef) = $grammar->named_capture_body($str, $MATCH->to())); if (Main::bool($m2)) { (($MATCH)->{to} = $m2->to()); ($MATCH->{'named_capture_body'} = $m2); 1 } else { 0 } } })) && (((do { do { ($MATCH->{capture} = (Rul::NamedCapture->new(('rule_exp' => ${$MATCH->{'named_capture_body'}}), ('capture_ident' => ${$MATCH->{'variables'}})))) } }) || 1)))) } }) || (do { do { (($MATCH)->{to} = $pos1); ((((do { do { ($MATCH->{capture} = (${$MATCH->{'variables'}})) } }) || 1))) } })) } }))) } }) || (do { do { (($MATCH)->{to} = $pos1); (((do { do { ((my  $m2 = undef) = $grammar->rule_terms($str, $MATCH->to())); if (Main::bool($m2)) { (($MATCH)->{to} = $m2->to()); ($MATCH->{'rule_terms'} = $m2); 1 } else { 0 } } }) && (((do { do { ($MATCH->{capture} = (${$MATCH->{'rule_terms'}})) } }) || 1)))) } })) || (do { do { (($MATCH)->{to} = $pos1); ((((do { do { ((my  $tmp = undef) = $MATCH); ($MATCH = Perlito::Match->new(('str' => $str), ('from' => $tmp->to()), ('to' => $tmp->to()), ('bool' => 1))); (($MATCH)->{bool} = (do { do { ((my  $pos1 = undef) = $MATCH->to()); (((((((((((do { do { ((((']' eq substr($str, $MATCH->to(), 1)) && ((($MATCH)->{to} = (1 + $MATCH->to())))))) } }) || (do { do { (($MATCH)->{to} = $pos1); (((('}' eq substr($str, $MATCH->to(), 1)) && ((($MATCH)->{to} = (1 + $MATCH->to())))))) } })) || (do { do { (($MATCH)->{to} = $pos1); ((((')' eq substr($str, $MATCH->to(), 1)) && ((($MATCH)->{to} = (1 + $MATCH->to())))))) } })) || (do { do { (($MATCH)->{to} = $pos1); (((('>' eq substr($str, $MATCH->to(), 1)) && ((($MATCH)->{to} = (1 + $MATCH->to())))))) } })) || (do { do { (($MATCH)->{to} = $pos1); ((((':' eq substr($str, $MATCH->to(), 1)) && ((($MATCH)->{to} = (1 + $MATCH->to())))))) } })) || (do { do { (($MATCH)->{to} = $pos1); (((('?' eq substr($str, $MATCH->to(), 1)) && ((($MATCH)->{to} = (1 + $MATCH->to())))))) } })) || (do { do { (($MATCH)->{to} = $pos1); (((('+' eq substr($str, $MATCH->to(), 1)) && ((($MATCH)->{to} = (1 + $MATCH->to())))))) } })) || (do { do { (($MATCH)->{to} = $pos1); (((('*' eq substr($str, $MATCH->to(), 1)) && ((($MATCH)->{to} = (1 + $MATCH->to())))))) } })) || (do { do { (($MATCH)->{to} = $pos1); (((('|' eq substr($str, $MATCH->to(), 1)) && ((($MATCH)->{to} = (1 + $MATCH->to())))))) } })) || (do { do { (($MATCH)->{to} = $pos1); (((('&' eq substr($str, $MATCH->to(), 1)) && ((($MATCH)->{to} = (1 + $MATCH->to())))))) } })) || (do { do { (($MATCH)->{to} = $pos1); (((('/' eq substr($str, $MATCH->to(), 1)) && ((($MATCH)->{to} = (1 + $MATCH->to())))))) } })) } })); (($tmp)->{bool} = ($MATCH ? 0 : 1)); ($MATCH = $tmp); ($MATCH ? 1 : 0) } }) && (do { do { ((my  $m2 = undef) = $grammar->any($str, $MATCH->to())); if (Main::bool($m2)) { (($MATCH)->{to} = $m2->to()); ($MATCH->{'any'} = $m2); 1 } else { 0 } } })) && (((do { do { ($MATCH->{capture} = (Rul::Constant->new(('constant' => ${$MATCH->{'any'}})))) } }) || 1)))) } })) } }))); $MATCH };
sub quant_exp { my $grammar = $_[0]; my $str = $_[1]; my $pos = $_[2]; (my  $MATCH = undef); ($MATCH = Perlito::Match->new(('str' => $str), ('from' => $pos), ('to' => $pos), ('bool' => 1))); (($MATCH)->{bool} = ((do { do { ((my  $pos1 = undef) = $MATCH->to()); ((do { do { (((((('**' eq substr($str, $MATCH->to(), 2)) && ((($MATCH)->{to} = (2 + $MATCH->to()))))) && (do { do { ((my  $m2 = undef) = Perlito::Grammar->opt_ws($str, $MATCH->to())); if (Main::bool($m2)) { (($MATCH)->{to} = $m2->to()); 1 } else { 0 } } })) && (do { do { ((my  $pos1 = undef) = $MATCH->to()); ((do { do { (((do { do { ((my  $m2 = undef) = Perlito::Grammar->val_int($str, $MATCH->to())); if (Main::bool($m2)) { (($MATCH)->{to} = $m2->to()); ($MATCH->{'Perlito::Grammar.val_int'} = $m2); 1 } else { 0 } } }) && (((do { do { ($MATCH->{capture} = (${$MATCH->{'Perlito::Grammar.val_int'}})) } }) || 1)))) } }) || (do { do { (($MATCH)->{to} = $pos1); (((do { do { ((my  $m2 = undef) = $grammar->rule_term($str, $MATCH->to())); if (Main::bool($m2)) { (($MATCH)->{to} = $m2->to()); ($MATCH->{'rule_term'} = $m2); 1 } else { 0 } } }) && (((do { do { ($MATCH->{capture} = (${$MATCH->{'rule_term'}})) } }) || 1)))) } })) } }))) } }) || (do { do { (($MATCH)->{to} = $pos1); ((do { do { ((my  $pos1 = undef) = $MATCH->to()); (((do { do { (((('?' eq substr($str, $MATCH->to(), 1)) && ((($MATCH)->{to} = (1 + $MATCH->to())))))) } }) || (do { do { (($MATCH)->{to} = $pos1); (((('*' eq substr($str, $MATCH->to(), 1)) && ((($MATCH)->{to} = (1 + $MATCH->to())))))) } })) || (do { do { (($MATCH)->{to} = $pos1); (((('+' eq substr($str, $MATCH->to(), 1)) && ((($MATCH)->{to} = (1 + $MATCH->to())))))) } })) } })) } })) } }))); $MATCH };
sub greedy_exp { my $grammar = $_[0]; my $str = $_[1]; my $pos = $_[2]; (my  $MATCH = undef); ($MATCH = Perlito::Match->new(('str' => $str), ('from' => $pos), ('to' => $pos), ('bool' => 1))); (($MATCH)->{bool} = ((do { do { ((my  $pos1 = undef) = $MATCH->to()); (((do { do { (((('?' eq substr($str, $MATCH->to(), 1)) && ((($MATCH)->{to} = (1 + $MATCH->to())))))) } }) || (do { do { (($MATCH)->{to} = $pos1); (((('+' eq substr($str, $MATCH->to(), 1)) && ((($MATCH)->{to} = (1 + $MATCH->to())))))) } })) || (do { do { (($MATCH)->{to} = $pos1); (1) } })) } }))); $MATCH };
sub quantifier { my $grammar = $_[0]; my $str = $_[1]; my $pos = $_[2]; (my  $MATCH = undef); ($MATCH = Perlito::Match->new(('str' => $str), ('from' => $pos), ('to' => $pos), ('bool' => 1))); (($MATCH)->{bool} = ((do { do { ((my  $pos1 = undef) = $MATCH->to()); (do { do { (((((do { do { ((my  $m2 = undef) = Perlito::Grammar->opt_ws($str, $MATCH->to())); if (Main::bool($m2)) { (($MATCH)->{to} = $m2->to()); 1 } else { 0 } } }) && (do { do { ((my  $m2 = undef) = $grammar->rule_term($str, $MATCH->to())); if (Main::bool($m2)) { (($MATCH)->{to} = $m2->to()); ($MATCH->{'rule_term'} = $m2); 1 } else { 0 } } })) && (do { do { ((my  $m2 = undef) = Perlito::Grammar->opt_ws2($str, $MATCH->to())); if (Main::bool($m2)) { (($MATCH)->{to} = $m2->to()); 1 } else { 0 } } })) && (do { do { ((my  $pos1 = undef) = $MATCH->to()); ((do { do { (((((do { do { ((my  $m2 = undef) = $grammar->quant_exp($str, $MATCH->to())); if (Main::bool($m2)) { (($MATCH)->{to} = $m2->to()); ($MATCH->{'quant_exp'} = $m2); 1 } else { 0 } } }) && (do { do { ((my  $m2 = undef) = $grammar->greedy_exp($str, $MATCH->to())); if (Main::bool($m2)) { (($MATCH)->{to} = $m2->to()); ($MATCH->{'greedy_exp'} = $m2); 1 } else { 0 } } })) && (do { do { ((my  $m2 = undef) = Perlito::Grammar->opt_ws3($str, $MATCH->to())); if (Main::bool($m2)) { (($MATCH)->{to} = $m2->to()); 1 } else { 0 } } })) && (((do { do { ($MATCH->{capture} = (Rul::Quantifier->new(('term' => ${$MATCH->{'rule_term'}}), ('quant' => ${$MATCH->{'quant_exp'}}), ('greedy' => ${$MATCH->{'greedy_exp'}}), ('ws1' => ${$MATCH->{'Perlito::Grammar.opt_ws'}}), ('ws2' => ${$MATCH->{'Perlito::Grammar.opt_ws2'}}), ('ws3' => ${$MATCH->{'Perlito::Grammar.opt_ws3'}})))) } }) || 1)))) } }) || (do { do { (($MATCH)->{to} = $pos1); ((((do { do { ($MATCH->{capture} = (${$MATCH->{'rule_term'}})) } }) || 1))) } })) } }))) } }) } }))); $MATCH };
sub concat_list { my $grammar = $_[0]; my $str = $_[1]; my $pos = $_[2]; (my  $MATCH = undef); ($MATCH = Perlito::Match->new(('str' => $str), ('from' => $pos), ('to' => $pos), ('bool' => 1))); (($MATCH)->{bool} = ((do { do { ((my  $pos1 = undef) = $MATCH->to()); ((do { do { (((do { do { ((my  $m2 = undef) = $grammar->quantifier($str, $MATCH->to())); if (Main::bool($m2)) { (($MATCH)->{to} = $m2->to()); ($MATCH->{'quantifier'} = $m2); 1 } else { 0 } } }) && (do { do { ((my  $pos1 = undef) = $MATCH->to()); ((do { do { (((do { do { ((my  $m2 = undef) = $grammar->concat_list($str, $MATCH->to())); if (Main::bool($m2)) { (($MATCH)->{to} = $m2->to()); ($MATCH->{'concat_list'} = $m2); 1 } else { 0 } } }) && (((do { do { ($MATCH->{capture} = (do { (my  $List_a = []); (my  $List_v = []); push( @{$List_a}, ${$MATCH->{'quantifier'}} ); ($List_v = ((${$MATCH->{'concat_list'}}) || [])); for my $x ( @{[0 .. ((scalar( @{$List_v} ) - 1))] || []} ) { push( @{$List_a}, $List_v->[$x] ) }; $List_a })) } }) || 1)))) } }) || (do { do { (($MATCH)->{to} = $pos1); ((((do { do { ($MATCH->{capture} = ([${$MATCH->{'quantifier'}}])) } }) || 1))) } })) } }))) } }) || (do { do { (($MATCH)->{to} = $pos1); ((((do { do { ($MATCH->{capture} = ([])) } }) || 1))) } })) } }))); $MATCH };
sub concat_exp { my $grammar = $_[0]; my $str = $_[1]; my $pos = $_[2]; (my  $MATCH = undef); ($MATCH = Perlito::Match->new(('str' => $str), ('from' => $pos), ('to' => $pos), ('bool' => 1))); (($MATCH)->{bool} = ((do { do { ((my  $pos1 = undef) = $MATCH->to()); (do { do { (((do { do { ((my  $m2 = undef) = $grammar->concat_list($str, $MATCH->to())); if (Main::bool($m2)) { (($MATCH)->{to} = $m2->to()); ($MATCH->{'concat_list'} = $m2); 1 } else { 0 } } }) && (((do { do { ($MATCH->{capture} = (Rul::Concat->new(('concat' => ${$MATCH->{'concat_list'}})))) } }) || 1)))) } }) } }))); $MATCH };
sub or_list_exp { my $grammar = $_[0]; my $str = $_[1]; my $pos = $_[2]; (my  $MATCH = undef); ($MATCH = Perlito::Match->new(('str' => $str), ('from' => $pos), ('to' => $pos), ('bool' => 1))); (($MATCH)->{bool} = ((do { do { ((my  $pos1 = undef) = $MATCH->to()); ((do { do { (((do { do { ((my  $m2 = undef) = $grammar->concat_exp($str, $MATCH->to())); if (Main::bool($m2)) { (($MATCH)->{to} = $m2->to()); ($MATCH->{'concat_exp'} = $m2); 1 } else { 0 } } }) && (do { do { ((my  $pos1 = undef) = $MATCH->to()); ((do { do { (((((('|' eq substr($str, $MATCH->to(), 1)) && ((($MATCH)->{to} = (1 + $MATCH->to()))))) && (do { do { ((my  $m2 = undef) = $grammar->or_list_exp($str, $MATCH->to())); if (Main::bool($m2)) { (($MATCH)->{to} = $m2->to()); ($MATCH->{'or_list_exp'} = $m2); 1 } else { 0 } } })) && (((do { do { ($MATCH->{capture} = (do { (my  $List_a = []); (my  $List_v = []); push( @{$List_a}, ${$MATCH->{'concat_exp'}} ); ($List_v = ((${$MATCH->{'or_list_exp'}}) || [])); for my $x ( @{[0 .. ((scalar( @{$List_v} ) - 1))] || []} ) { push( @{$List_a}, $List_v->[$x] ) }; $List_a })) } }) || 1)))) } }) || (do { do { (($MATCH)->{to} = $pos1); ((((do { do { ($MATCH->{capture} = ([${$MATCH->{'concat_exp'}}])) } }) || 1))) } })) } }))) } }) || (do { do { (($MATCH)->{to} = $pos1); ((((do { do { ($MATCH->{capture} = ([])) } }) || 1))) } })) } }))); $MATCH };
sub rule { my $grammar = $_[0]; my $str = $_[1]; my $pos = $_[2]; (my  $MATCH = undef); ($MATCH = Perlito::Match->new(('str' => $str), ('from' => $pos), ('to' => $pos), ('bool' => 1))); (($MATCH)->{bool} = ((do { do { ((my  $pos1 = undef) = $MATCH->to()); (do { do { ((((do { do { ((my  $pos1 = undef) = $MATCH->to()); ((do { do { (((do { do { ((my  $last_pos = undef) = $MATCH->to()); if (Main::bool(((do { do { (do { do { ((my  $m2 = undef) = $grammar->ws($str, $MATCH->to())); if (Main::bool($m2)) { (($MATCH)->{to} = $m2->to()); 1 } else { 0 } } }) } }) ? 0 : 1))) { (($MATCH)->{to} = $last_pos) } ; 1 } }) && ((('|' eq substr($str, $MATCH->to(), 1)) && ((($MATCH)->{to} = (1 + $MATCH->to()))))))) } }) || (do { do { (($MATCH)->{to} = $pos1); (1) } })) } }) && (do { do { ((my  $m2 = undef) = $grammar->or_list_exp($str, $MATCH->to())); if (Main::bool($m2)) { (($MATCH)->{to} = $m2->to()); ($MATCH->{'or_list_exp'} = $m2); 1 } else { 0 } } })) && (((do { do { ($MATCH->{capture} = (Rul::Or->new(('or_list' => ${$MATCH->{'or_list_exp'}})))) } }) || 1)))) } }) } }))); $MATCH }
}


}

1;
