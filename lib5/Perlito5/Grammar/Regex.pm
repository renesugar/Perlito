# Do not edit this file - Generated by Perlito5 8.0
use v5;
use utf8;
use strict;
use warnings;
no warnings ('redefine', 'once', 'void', 'uninitialized', 'misc', 'recursion');
use Perlito5::Perl5::Runtime;
our $MATCH = Perlito5::Match->new();
package main;
package Perlito5::Grammar::Regex;
sub ws {
    ((my  $grammar) = $_[0]);
    ((my  $str) = $_[1]);
    ((my  $pos) = $_[2]);
    ((my  $MATCH) = Perlito5::Match->new(('str' => $str), ('from' => $pos), ('to' => $pos), ('bool' => 1)));
    ($MATCH->{('bool')} = (((do {
    ((my  $pos1) = $MATCH->{('to')});
    ((do {
    ((my  $m2) = Perlito5::Grammar->ws($str, $MATCH->{('to')}));
    if (($m2->{('bool')})) {
        ($MATCH->{('to')} = $m2->{('to')});
        1
    }
    else {
        0
    }
}))
}))));
    $MATCH
};
sub any {
    ((my  $grammar) = $_[0]);
    ((my  $str) = $_[1]);
    ((my  $pos) = $_[2]);
    ((my  $MATCH) = Perlito5::Match->new(('str' => $str), ('from' => $pos), ('to' => $pos), ('bool' => 1)));
    ($MATCH->{('bool')} = (((do {
    ((my  $pos1) = $MATCH->{('to')});
    ((do {
    (('' ne substr($str, $MATCH->{('to')}, 1)) && (($MATCH->{('to')} = (1 + $MATCH->{('to')}))))
}))
}))));
    $MATCH
};
sub literal {
    ((my  $grammar) = $_[0]);
    ((my  $str) = $_[1]);
    ((my  $pos) = $_[2]);
    ((my  $MATCH) = Perlito5::Match->new(('str' => $str), ('from' => $pos), ('to' => $pos), ('bool' => 1)));
    ($MATCH->{('bool')} = (((do {
    ((my  $pos1) = $MATCH->{('to')});
    ((do {
    ((my  $last_match_null) = 0);
    ((my  $last_pos) = $MATCH->{('to')});
    for ( ; ((((do {
    ((my  $pos1) = $MATCH->{('to')});
    (((do {
    ((((chr(92) eq substr($str, $MATCH->{('to')}, 1)) && (($MATCH->{('to')} = (1 + $MATCH->{('to')}))))) && ((('' ne substr($str, $MATCH->{('to')}, 1)) && (($MATCH->{('to')} = (1 + $MATCH->{('to')}))))))
})) || ((do {
    ($MATCH->{('to')} = $pos1);
    ((((do {
    ((my  $tmp) = $MATCH);
    ($MATCH = Perlito5::Match->new(('str' => $str), ('from' => $tmp->{('to')}), ('to' => $tmp->{('to')}), ('bool' => 1)));
    ($MATCH->{('bool')} = ((do {
    ((my  $pos1) = $MATCH->{('to')});
    ((do {
    ((chr(39) eq substr($str, $MATCH->{('to')}, 1)) && (($MATCH->{('to')} = (1 + $MATCH->{('to')}))))
}))
})));
    ($tmp->{('bool')} = !($MATCH->{('bool')}));
    ($MATCH = $tmp);
    ($MATCH->{('bool')} ? 1 : 0)
})) && ((('' ne substr($str, $MATCH->{('to')}, 1)) && (($MATCH->{('to')} = (1 + $MATCH->{('to')})))))))
})))
})) && (($last_match_null < 2))));  ) {
        if ((($last_pos == $MATCH->{('to')}))) {
            ($last_match_null = ($last_match_null + 1))
        }
        else {
            ($last_match_null = 0)
        };
        ($last_pos = $MATCH->{('to')})
    };
    ($MATCH->{('to')} = $last_pos);
    1
}))
}))));
    $MATCH
};
sub metasyntax_exp {
    ((my  $grammar) = $_[0]);
    ((my  $str) = $_[1]);
    ((my  $pos) = $_[2]);
    ((my  $MATCH) = Perlito5::Match->new(('str' => $str), ('from' => $pos), ('to' => $pos), ('bool' => 1)));
    ($MATCH->{('bool')} = (((do {
    ((my  $pos1) = $MATCH->{('to')});
    ((do {
    ((my  $last_match_null) = 0);
    ((my  $last_pos) = $MATCH->{('to')});
    ((my  $count) = 0);
    for ( ; ((((do {
    ((my  $pos1) = $MATCH->{('to')});
    ((((((do {
    ((((chr(92) eq substr($str, $MATCH->{('to')}, 1)) && (($MATCH->{('to')} = (1 + $MATCH->{('to')}))))) && ((('' ne substr($str, $MATCH->{('to')}, 1)) && (($MATCH->{('to')} = (1 + $MATCH->{('to')}))))))
})) || ((do {
    ($MATCH->{('to')} = $pos1);
    ((((((chr(39) eq substr($str, $MATCH->{('to')}, 1)) && (($MATCH->{('to')} = (1 + $MATCH->{('to')}))))) && ((do {
    ((my  $m2) = $grammar->literal($str, $MATCH->{('to')}));
    if (($m2->{('bool')})) {
        ($MATCH->{('to')} = $m2->{('to')});
        1
    }
    else {
        0
    }
}))) && (((chr(39) eq substr($str, $MATCH->{('to')}, 1)) && (($MATCH->{('to')} = (1 + $MATCH->{('to')})))))))
}))) || ((do {
    ($MATCH->{('to')} = $pos1);
    ((((((chr(123) eq substr($str, $MATCH->{('to')}, 1)) && (($MATCH->{('to')} = (1 + $MATCH->{('to')}))))) && ((do {
    ((my  $m2) = $grammar->string_code($str, $MATCH->{('to')}));
    if (($m2->{('bool')})) {
        ($MATCH->{('to')} = $m2->{('to')});
        1
    }
    else {
        0
    }
}))) && (((chr(125) eq substr($str, $MATCH->{('to')}, 1)) && (($MATCH->{('to')} = (1 + $MATCH->{('to')})))))))
}))) || ((do {
    ($MATCH->{('to')} = $pos1);
    (((((('<' eq substr($str, $MATCH->{('to')}, 1)) && (($MATCH->{('to')} = (1 + $MATCH->{('to')}))))) && ((do {
    ((my  $m2) = $grammar->metasyntax_exp($str, $MATCH->{('to')}));
    if (($m2->{('bool')})) {
        ($MATCH->{('to')} = $m2->{('to')});
        1
    }
    else {
        0
    }
}))) && ((('>' eq substr($str, $MATCH->{('to')}, 1)) && (($MATCH->{('to')} = (1 + $MATCH->{('to')})))))))
}))) || ((do {
    ($MATCH->{('to')} = $pos1);
    ((((do {
    ((my  $tmp) = $MATCH);
    ($MATCH = Perlito5::Match->new(('str' => $str), ('from' => $tmp->{('to')}), ('to' => $tmp->{('to')}), ('bool' => 1)));
    ($MATCH->{('bool')} = ((do {
    ((my  $pos1) = $MATCH->{('to')});
    ((do {
    (('>' eq substr($str, $MATCH->{('to')}, 1)) && (($MATCH->{('to')} = (1 + $MATCH->{('to')}))))
}))
})));
    ($tmp->{('bool')} = !($MATCH->{('bool')}));
    ($MATCH = $tmp);
    ($MATCH->{('bool')} ? 1 : 0)
})) && ((('' ne substr($str, $MATCH->{('to')}, 1)) && (($MATCH->{('to')} = (1 + $MATCH->{('to')})))))))
})))
})) && (($last_match_null < 2))));  ) {
        if ((($last_pos == $MATCH->{('to')}))) {
            ($last_match_null = ($last_match_null + 1))
        }
        else {
            ($last_match_null = 0)
        };
        ($last_pos = $MATCH->{('to')});
        ($count = ($count + 1))
    };
    ($MATCH->{('to')} = $last_pos);
    ($count > 0)
}))
}))));
    $MATCH
};
sub string_code {
    ((my  $grammar) = $_[0]);
    ((my  $str) = $_[1]);
    ((my  $pos) = $_[2]);
    ((my  $MATCH) = Perlito5::Match->new(('str' => $str), ('from' => $pos), ('to' => $pos), ('bool' => 1)));
    ($MATCH->{('bool')} = (((do {
    ((my  $pos1) = $MATCH->{('to')});
    ((do {
    ((my  $last_match_null) = 0);
    ((my  $last_pos) = $MATCH->{('to')});
    ((my  $count) = 0);
    for ( ; ((((do {
    ((my  $pos1) = $MATCH->{('to')});
    (((((do {
    ((((chr(92) eq substr($str, $MATCH->{('to')}, 1)) && (($MATCH->{('to')} = (1 + $MATCH->{('to')}))))) && ((('' ne substr($str, $MATCH->{('to')}, 1)) && (($MATCH->{('to')} = (1 + $MATCH->{('to')}))))))
})) || ((do {
    ($MATCH->{('to')} = $pos1);
    ((((((chr(39) eq substr($str, $MATCH->{('to')}, 1)) && (($MATCH->{('to')} = (1 + $MATCH->{('to')}))))) && ((do {
    ((my  $m2) = $grammar->literal($str, $MATCH->{('to')}));
    if (($m2->{('bool')})) {
        ($MATCH->{('to')} = $m2->{('to')});
        1
    }
    else {
        0
    }
}))) && (((chr(39) eq substr($str, $MATCH->{('to')}, 1)) && (($MATCH->{('to')} = (1 + $MATCH->{('to')})))))))
}))) || ((do {
    ($MATCH->{('to')} = $pos1);
    ((((((chr(123) eq substr($str, $MATCH->{('to')}, 1)) && (($MATCH->{('to')} = (1 + $MATCH->{('to')}))))) && ((do {
    ((my  $m2) = $grammar->string_code($str, $MATCH->{('to')}));
    if (($m2->{('bool')})) {
        ($MATCH->{('to')} = $m2->{('to')});
        1
    }
    else {
        0
    }
}))) && (((chr(125) eq substr($str, $MATCH->{('to')}, 1)) && (($MATCH->{('to')} = (1 + $MATCH->{('to')})))))))
}))) || ((do {
    ($MATCH->{('to')} = $pos1);
    ((((do {
    ((my  $tmp) = $MATCH);
    ($MATCH = Perlito5::Match->new(('str' => $str), ('from' => $tmp->{('to')}), ('to' => $tmp->{('to')}), ('bool' => 1)));
    ($MATCH->{('bool')} = ((do {
    ((my  $pos1) = $MATCH->{('to')});
    ((do {
    ((chr(125) eq substr($str, $MATCH->{('to')}, 1)) && (($MATCH->{('to')} = (1 + $MATCH->{('to')}))))
}))
})));
    ($tmp->{('bool')} = !($MATCH->{('bool')}));
    ($MATCH = $tmp);
    ($MATCH->{('bool')} ? 1 : 0)
})) && ((('' ne substr($str, $MATCH->{('to')}, 1)) && (($MATCH->{('to')} = (1 + $MATCH->{('to')})))))))
})))
})) && (($last_match_null < 2))));  ) {
        if ((($last_pos == $MATCH->{('to')}))) {
            ($last_match_null = ($last_match_null + 1))
        }
        else {
            ($last_match_null = 0)
        };
        ($last_pos = $MATCH->{('to')});
        ($count = ($count + 1))
    };
    ($MATCH->{('to')} = $last_pos);
    ($count > 0)
}))
}))));
    $MATCH
};
sub parsed_code {
    ((my  $grammar) = $_[0]);
    ((my  $str) = $_[1]);
    ((my  $pos) = $_[2]);
    ((my  $MATCH) = Perlito5::Match->new(('str' => $str), ('from' => $pos), ('to' => $pos), ('bool' => 1)));
    ($MATCH->{('bool')} = (((do {
    ((my  $pos1) = $MATCH->{('to')});
    ((do {
    (((do {
    ((my  $m2) = $grammar->string_code($str, $MATCH->{('to')}));
    if (($m2->{('bool')})) {
        ($MATCH->{('to')} = $m2->{('to')});
        1
    }
    else {
        0
    }
})) && ((do {
    ($MATCH->{('capture')} = $MATCH->flat());
    1
})))
}))
}))));
    $MATCH
};
sub rule_terms {
    ((my  $grammar) = $_[0]);
    ((my  $str) = $_[1]);
    ((my  $pos) = $_[2]);
    ((my  $MATCH) = Perlito5::Match->new(('str' => $str), ('from' => $pos), ('to' => $pos), ('bool' => 1)));
    ($MATCH->{('bool')} = (((do {
    ((my  $pos1) = $MATCH->{('to')});
    (((((((((do {
    ((((((('<before' eq substr($str, $MATCH->{('to')}, 7)) && (($MATCH->{('to')} = (7 + $MATCH->{('to')}))))) && ((do {
    ((my  $m2) = $grammar->ws($str, $MATCH->{('to')}));
    if (($m2->{('bool')})) {
        ($MATCH->{('to')} = $m2->{('to')});
        1
    }
    else {
        0
    }
}))) && ((do {
    ((my  $m2) = $grammar->rule($str, $MATCH->{('to')}));
    if (($m2->{('bool')})) {
        ($MATCH->{('to')} = $m2->{('to')});
        ($MATCH->{'rule'} = $m2);
        1
    }
    else {
        0
    }
}))) && ((('>' eq substr($str, $MATCH->{('to')}, 1)) && (($MATCH->{('to')} = (1 + $MATCH->{('to')})))))) && ((do {
    ($MATCH->{('capture')} = Rul::Before->new(('rule_exp' => $MATCH->{('rule')}->flat())));
    1
})))
})) || ((do {
    ($MATCH->{('to')} = $pos1);
    (((((((('<' . chr(33) . 'before' eq substr($str, $MATCH->{('to')}, 8)) && (($MATCH->{('to')} = (8 + $MATCH->{('to')}))))) && ((do {
    ((my  $m2) = $grammar->ws($str, $MATCH->{('to')}));
    if (($m2->{('bool')})) {
        ($MATCH->{('to')} = $m2->{('to')});
        1
    }
    else {
        0
    }
}))) && ((do {
    ((my  $m2) = $grammar->rule($str, $MATCH->{('to')}));
    if (($m2->{('bool')})) {
        ($MATCH->{('to')} = $m2->{('to')});
        ($MATCH->{'rule'} = $m2);
        1
    }
    else {
        0
    }
}))) && ((('>' eq substr($str, $MATCH->{('to')}, 1)) && (($MATCH->{('to')} = (1 + $MATCH->{('to')})))))) && ((do {
    ($MATCH->{('capture')} = Rul::NotBefore->new(('rule_exp' => $MATCH->{('rule')}->flat())));
    1
}))))
}))) || ((do {
    ($MATCH->{('to')} = $pos1);
    (((((((chr(39) eq substr($str, $MATCH->{('to')}, 1)) && (($MATCH->{('to')} = (1 + $MATCH->{('to')}))))) && ((do {
    ((my  $m2) = $grammar->literal($str, $MATCH->{('to')}));
    if (($m2->{('bool')})) {
        ($MATCH->{('to')} = $m2->{('to')});
        ($MATCH->{'literal'} = $m2);
        1
    }
    else {
        0
    }
}))) && (((chr(39) eq substr($str, $MATCH->{('to')}, 1)) && (($MATCH->{('to')} = (1 + $MATCH->{('to')})))))) && ((do {
    ($MATCH->{('capture')} = Rul::Constant->new(('constant' => $MATCH->{('literal')}->flat())));
    1
}))))
}))) || ((do {
    ($MATCH->{('to')} = $pos1);
    ((((('<' eq substr($str, $MATCH->{('to')}, 1)) && (($MATCH->{('to')} = (1 + $MATCH->{('to')}))))) && ((do {
    ((my  $pos1) = $MATCH->{('to')});
    (((do {
    (((((('.' eq substr($str, $MATCH->{('to')}, 1)) && (($MATCH->{('to')} = (1 + $MATCH->{('to')}))))) && ((do {
    ((my  $m2) = $grammar->metasyntax_exp($str, $MATCH->{('to')}));
    if (($m2->{('bool')})) {
        ($MATCH->{('to')} = $m2->{('to')});
        ($MATCH->{'metasyntax_exp'} = $m2);
        1
    }
    else {
        0
    }
}))) && ((('>' eq substr($str, $MATCH->{('to')}, 1)) && (($MATCH->{('to')} = (1 + $MATCH->{('to')})))))) && ((do {
    ($MATCH->{('capture')} = Rul::Subrule->new(('metasyntax' => $MATCH->{('metasyntax_exp')}->flat()), ('captures' => 0)));
    1
})))
})) || ((do {
    ($MATCH->{('to')} = $pos1);
    (((((do {
    ((my  $m2) = $grammar->metasyntax_exp($str, $MATCH->{('to')}));
    if (($m2->{('bool')})) {
        ($MATCH->{('to')} = $m2->{('to')});
        ($MATCH->{'metasyntax_exp'} = $m2);
        1
    }
    else {
        0
    }
})) && ((('>' eq substr($str, $MATCH->{('to')}, 1)) && (($MATCH->{('to')} = (1 + $MATCH->{('to')})))))) && ((do {
    ($MATCH->{('capture')} = Rul::Subrule->new(('metasyntax' => $MATCH->{('metasyntax_exp')}->flat()), ('captures' => 1)));
    1
}))))
})))
}))))
}))) || ((do {
    ($MATCH->{('to')} = $pos1);
    (((((((chr(123) eq substr($str, $MATCH->{('to')}, 1)) && (($MATCH->{('to')} = (1 + $MATCH->{('to')}))))) && ((do {
    ((my  $m2) = $grammar->parsed_code($str, $MATCH->{('to')}));
    if (($m2->{('bool')})) {
        ($MATCH->{('to')} = $m2->{('to')});
        ($MATCH->{'parsed_code'} = $m2);
        1
    }
    else {
        0
    }
}))) && (((chr(125) eq substr($str, $MATCH->{('to')}, 1)) && (($MATCH->{('to')} = (1 + $MATCH->{('to')})))))) && ((do {
    ($MATCH->{('capture')} = Rul::Block->new(('closure' => $MATCH->{('parsed_code')}->flat())));
    1
}))))
}))) || ((do {
    ($MATCH->{('to')} = $pos1);
    (((((chr(92) eq substr($str, $MATCH->{('to')}, 1)) && (($MATCH->{('to')} = (1 + $MATCH->{('to')}))))) && ((do {
    ((my  $pos1) = $MATCH->{('to')});
    ((((do {
    ((((((('c' eq substr($str, $MATCH->{('to')}, 1)) && (($MATCH->{('to')} = (1 + $MATCH->{('to')}))))) && ((('[' eq substr($str, $MATCH->{('to')}, 1)) && (($MATCH->{('to')} = (1 + $MATCH->{('to')})))))) && ((do {
    ((my  $m2) = Perlito5::Grammar->digits($str, $MATCH->{('to')}));
    if (($m2->{('bool')})) {
        ($MATCH->{('to')} = $m2->{('to')});
        ($MATCH->{'Perlito5::Grammar.digits'} = $m2);
        1
    }
    else {
        0
    }
}))) && (((']' eq substr($str, $MATCH->{('to')}, 1)) && (($MATCH->{('to')} = (1 + $MATCH->{('to')})))))) && ((do {
    ($MATCH->{('capture')} = Rul::Constant->new(('constant' => chr($MATCH->{('Perlito5::Grammar.digits')}->flat()))));
    1
})))
})) || ((do {
    ($MATCH->{('to')} = $pos1);
    (((((('c' eq substr($str, $MATCH->{('to')}, 1)) && (($MATCH->{('to')} = (1 + $MATCH->{('to')}))))) && ((do {
    ((my  $m2) = Perlito5::Grammar->digits($str, $MATCH->{('to')}));
    if (($m2->{('bool')})) {
        ($MATCH->{('to')} = $m2->{('to')});
        ($MATCH->{'Perlito5::Grammar.digits'} = $m2);
        1
    }
    else {
        0
    }
}))) && ((do {
    ($MATCH->{('capture')} = Rul::Constant->new(('constant' => chr($MATCH->{('Perlito5::Grammar.digits')}->flat()))));
    1
}))))
}))) || ((do {
    ($MATCH->{('to')} = $pos1);
    ((((do {
    ((my  $m2) = $grammar->any($str, $MATCH->{('to')}));
    if (($m2->{('bool')})) {
        ($MATCH->{('to')} = $m2->{('to')});
        ($MATCH->{'any'} = $m2);
        1
    }
    else {
        0
    }
})) && ((do {
    ($MATCH->{('capture')} = Rul::SpecialChar->new(('char' => $MATCH->{('any')}->flat())));
    1
}))))
})))
}))))
}))) || ((do {
    ($MATCH->{('to')} = $pos1);
    ((((('.' eq substr($str, $MATCH->{('to')}, 1)) && (($MATCH->{('to')} = (1 + $MATCH->{('to')}))))) && ((do {
    ($MATCH->{('capture')} = Rul::Dot->new());
    1
}))))
}))) || ((do {
    ($MATCH->{('to')} = $pos1);
    ((((((('[' eq substr($str, $MATCH->{('to')}, 1)) && (($MATCH->{('to')} = (1 + $MATCH->{('to')}))))) && ((do {
    ((my  $m2) = $grammar->rule($str, $MATCH->{('to')}));
    if (($m2->{('bool')})) {
        ($MATCH->{('to')} = $m2->{('to')});
        ($MATCH->{'rule'} = $m2);
        1
    }
    else {
        0
    }
}))) && (((']' eq substr($str, $MATCH->{('to')}, 1)) && (($MATCH->{('to')} = (1 + $MATCH->{('to')})))))) && ((do {
    ($MATCH->{('capture')} = $MATCH->{('rule')}->flat());
    1
}))))
})))
}))));
    $MATCH
};
sub rule_term {
    ((my  $grammar) = $_[0]);
    ((my  $str) = $_[1]);
    ((my  $pos) = $_[2]);
    ((my  $MATCH) = Perlito5::Match->new(('str' => $str), ('from' => $pos), ('to' => $pos), ('bool' => 1)));
    ($MATCH->{('bool')} = (((do {
    ((my  $pos1) = $MATCH->{('to')});
    (((do {
    (((do {
    ((my  $m2) = $grammar->rule_terms($str, $MATCH->{('to')}));
    if (($m2->{('bool')})) {
        ($MATCH->{('to')} = $m2->{('to')});
        ($MATCH->{'rule_terms'} = $m2);
        1
    }
    else {
        0
    }
})) && ((do {
    ($MATCH->{('capture')} = $MATCH->{('rule_terms')}->flat());
    1
})))
})) || ((do {
    ($MATCH->{('to')} = $pos1);
    (((((do {
    ((my  $tmp) = $MATCH);
    ($MATCH = Perlito5::Match->new(('str' => $str), ('from' => $tmp->{('to')}), ('to' => $tmp->{('to')}), ('bool' => 1)));
    ($MATCH->{('bool')} = ((do {
    ((my  $pos1) = $MATCH->{('to')});
    ((((((((((((do {
    ((']' eq substr($str, $MATCH->{('to')}, 1)) && (($MATCH->{('to')} = (1 + $MATCH->{('to')}))))
})) || ((do {
    ($MATCH->{('to')} = $pos1);
    ((((chr(125) eq substr($str, $MATCH->{('to')}, 1)) && (($MATCH->{('to')} = (1 + $MATCH->{('to')}))))))
}))) || ((do {
    ($MATCH->{('to')} = $pos1);
    ((((')' eq substr($str, $MATCH->{('to')}, 1)) && (($MATCH->{('to')} = (1 + $MATCH->{('to')}))))))
}))) || ((do {
    ($MATCH->{('to')} = $pos1);
    (((('>' eq substr($str, $MATCH->{('to')}, 1)) && (($MATCH->{('to')} = (1 + $MATCH->{('to')}))))))
}))) || ((do {
    ($MATCH->{('to')} = $pos1);
    ((((':' eq substr($str, $MATCH->{('to')}, 1)) && (($MATCH->{('to')} = (1 + $MATCH->{('to')}))))))
}))) || ((do {
    ($MATCH->{('to')} = $pos1);
    ((((chr(63) eq substr($str, $MATCH->{('to')}, 1)) && (($MATCH->{('to')} = (1 + $MATCH->{('to')}))))))
}))) || ((do {
    ($MATCH->{('to')} = $pos1);
    (((('+' eq substr($str, $MATCH->{('to')}, 1)) && (($MATCH->{('to')} = (1 + $MATCH->{('to')}))))))
}))) || ((do {
    ($MATCH->{('to')} = $pos1);
    (((('*' eq substr($str, $MATCH->{('to')}, 1)) && (($MATCH->{('to')} = (1 + $MATCH->{('to')}))))))
}))) || ((do {
    ($MATCH->{('to')} = $pos1);
    ((((chr(124) eq substr($str, $MATCH->{('to')}, 1)) && (($MATCH->{('to')} = (1 + $MATCH->{('to')}))))))
}))) || ((do {
    ($MATCH->{('to')} = $pos1);
    ((((chr(38) eq substr($str, $MATCH->{('to')}, 1)) && (($MATCH->{('to')} = (1 + $MATCH->{('to')}))))))
}))) || ((do {
    ($MATCH->{('to')} = $pos1);
    ((((chr(47) eq substr($str, $MATCH->{('to')}, 1)) && (($MATCH->{('to')} = (1 + $MATCH->{('to')}))))))
})))
})));
    ($tmp->{('bool')} = !($MATCH->{('bool')}));
    ($MATCH = $tmp);
    ($MATCH->{('bool')} ? 1 : 0)
})) && ((do {
    ((my  $m2) = $grammar->any($str, $MATCH->{('to')}));
    if (($m2->{('bool')})) {
        ($MATCH->{('to')} = $m2->{('to')});
        ($MATCH->{'any'} = $m2);
        1
    }
    else {
        0
    }
}))) && ((do {
    ($MATCH->{('capture')} = Rul::Constant->new(('constant' => $MATCH->{('any')}->flat())));
    1
}))))
})))
}))));
    $MATCH
};
sub quant_exp {
    ((my  $grammar) = $_[0]);
    ((my  $str) = $_[1]);
    ((my  $pos) = $_[2]);
    ((my  $MATCH) = Perlito5::Match->new(('str' => $str), ('from' => $pos), ('to' => $pos), ('bool' => 1)));
    ($MATCH->{('bool')} = (((do {
    ((my  $pos1) = $MATCH->{('to')});
    ((((do {
    ((chr(63) eq substr($str, $MATCH->{('to')}, 1)) && (($MATCH->{('to')} = (1 + $MATCH->{('to')}))))
})) || ((do {
    ($MATCH->{('to')} = $pos1);
    (((('*' eq substr($str, $MATCH->{('to')}, 1)) && (($MATCH->{('to')} = (1 + $MATCH->{('to')}))))))
}))) || ((do {
    ($MATCH->{('to')} = $pos1);
    (((('+' eq substr($str, $MATCH->{('to')}, 1)) && (($MATCH->{('to')} = (1 + $MATCH->{('to')}))))))
})))
}))));
    $MATCH
};
sub greedy_exp {
    ((my  $grammar) = $_[0]);
    ((my  $str) = $_[1]);
    ((my  $pos) = $_[2]);
    ((my  $MATCH) = Perlito5::Match->new(('str' => $str), ('from' => $pos), ('to' => $pos), ('bool' => 1)));
    ($MATCH->{('bool')} = (((do {
    ((my  $pos1) = $MATCH->{('to')});
    ((((do {
    ((chr(63) eq substr($str, $MATCH->{('to')}, 1)) && (($MATCH->{('to')} = (1 + $MATCH->{('to')}))))
})) || ((do {
    ($MATCH->{('to')} = $pos1);
    (((('+' eq substr($str, $MATCH->{('to')}, 1)) && (($MATCH->{('to')} = (1 + $MATCH->{('to')}))))))
}))) || ((do {
    ($MATCH->{('to')} = $pos1);
    (1)
})))
}))));
    $MATCH
};
sub quantifier {
    ((my  $grammar) = $_[0]);
    ((my  $str) = $_[1]);
    ((my  $pos) = $_[2]);
    ((my  $MATCH) = Perlito5::Match->new(('str' => $str), ('from' => $pos), ('to' => $pos), ('bool' => 1)));
    ($MATCH->{('bool')} = (((do {
    ((my  $pos1) = $MATCH->{('to')});
    ((do {
    (((((do {
    ((my  $m2) = Perlito5::Grammar->opt_ws($str, $MATCH->{('to')}));
    if (($m2->{('bool')})) {
        ($MATCH->{('to')} = $m2->{('to')});
        ($MATCH->{'Perlito5::Grammar.opt_ws'} = $m2);
        1
    }
    else {
        0
    }
})) && ((do {
    ((my  $m2) = $grammar->rule_term($str, $MATCH->{('to')}));
    if (($m2->{('bool')})) {
        ($MATCH->{('to')} = $m2->{('to')});
        ($MATCH->{'rule_term'} = $m2);
        1
    }
    else {
        0
    }
}))) && ((do {
    ((my  $m2) = Perlito5::Grammar->opt_ws2($str, $MATCH->{('to')}));
    if (($m2->{('bool')})) {
        ($MATCH->{('to')} = $m2->{('to')});
        ($MATCH->{'Perlito5::Grammar.opt_ws2'} = $m2);
        1
    }
    else {
        0
    }
}))) && ((do {
    ((my  $pos1) = $MATCH->{('to')});
    (((do {
    (((((do {
    ((my  $m2) = $grammar->quant_exp($str, $MATCH->{('to')}));
    if (($m2->{('bool')})) {
        ($MATCH->{('to')} = $m2->{('to')});
        ($MATCH->{'quant_exp'} = $m2);
        1
    }
    else {
        0
    }
})) && ((do {
    ((my  $m2) = $grammar->greedy_exp($str, $MATCH->{('to')}));
    if (($m2->{('bool')})) {
        ($MATCH->{('to')} = $m2->{('to')});
        ($MATCH->{'greedy_exp'} = $m2);
        1
    }
    else {
        0
    }
}))) && ((do {
    ((my  $m2) = Perlito5::Grammar->opt_ws3($str, $MATCH->{('to')}));
    if (($m2->{('bool')})) {
        ($MATCH->{('to')} = $m2->{('to')});
        ($MATCH->{'Perlito5::Grammar.opt_ws3'} = $m2);
        1
    }
    else {
        0
    }
}))) && ((do {
    ($MATCH->{('capture')} = Rul::Quantifier->new(('term' => $MATCH->{('rule_term')}->flat()), ('quant' => $MATCH->{('quant_exp')}->flat()), ('greedy' => $MATCH->{('greedy_exp')}->flat()), ('ws1' => $MATCH->{('Perlito5::Grammar.opt_ws')}->flat()), ('ws2' => $MATCH->{('Perlito5::Grammar.opt_ws2')}->flat()), ('ws3' => $MATCH->{('Perlito5::Grammar.opt_ws3')}->flat())));
    1
})))
})) || ((do {
    ($MATCH->{('to')} = $pos1);
    (((do {
    ($MATCH->{('capture')} = $MATCH->{('rule_term')}->flat());
    1
})))
})))
})))
}))
}))));
    $MATCH
};
sub concat_list {
    ((my  $grammar) = $_[0]);
    ((my  $str) = $_[1]);
    ((my  $pos) = $_[2]);
    ((my  $MATCH) = Perlito5::Match->new(('str' => $str), ('from' => $pos), ('to' => $pos), ('bool' => 1)));
    ($MATCH->{('bool')} = (((do {
    ((my  $pos1) = $MATCH->{('to')});
    (((do {
    (((do {
    ((my  $m2) = $grammar->quantifier($str, $MATCH->{('to')}));
    if (($m2->{('bool')})) {
        ($MATCH->{('to')} = $m2->{('to')});
        ($MATCH->{'quantifier'} = $m2);
        1
    }
    else {
        0
    }
})) && ((do {
    ((my  $pos1) = $MATCH->{('to')});
    (((do {
    (((do {
    ((my  $m2) = $grammar->concat_list($str, $MATCH->{('to')}));
    if (($m2->{('bool')})) {
        ($MATCH->{('to')} = $m2->{('to')});
        ($MATCH->{'concat_list'} = $m2);
        1
    }
    else {
        0
    }
})) && ((do {
    ($MATCH->{('capture')} = (do {
    (my  @a);
    (my  @v);
    push(@a, $MATCH->{('quantifier')}->flat() );
    (@v = @{$MATCH->{('concat_list')}->flat()});
    for my $x ((0 .. ((scalar(@v) - 1)))) {
        push(@a, $v[$x] )
    };
    \@a
}));
    1
})))
})) || ((do {
    ($MATCH->{('to')} = $pos1);
    (((do {
    ($MATCH->{('capture')} = (do {
    (my  @a);
    (my  @v);
    push(@a, $MATCH->{('quantifier')}->flat() );
    \@a
}));
    1
})))
})))
})))
})) || ((do {
    ($MATCH->{('to')} = $pos1);
    (((do {
    ($MATCH->{('capture')} = (do {
    (my  @a);
    (my  @v);
    \@a
}));
    1
})))
})))
}))));
    $MATCH
};
sub concat_exp {
    ((my  $grammar) = $_[0]);
    ((my  $str) = $_[1]);
    ((my  $pos) = $_[2]);
    ((my  $MATCH) = Perlito5::Match->new(('str' => $str), ('from' => $pos), ('to' => $pos), ('bool' => 1)));
    ($MATCH->{('bool')} = (((do {
    ((my  $pos1) = $MATCH->{('to')});
    ((do {
    (((do {
    ((my  $m2) = $grammar->concat_list($str, $MATCH->{('to')}));
    if (($m2->{('bool')})) {
        ($MATCH->{('to')} = $m2->{('to')});
        ($MATCH->{'concat_list'} = $m2);
        1
    }
    else {
        0
    }
})) && ((do {
    ($MATCH->{('capture')} = Rul::Concat->new(('concat' => $MATCH->{('concat_list')}->flat())));
    1
})))
}))
}))));
    $MATCH
};
sub or_list_exp {
    ((my  $grammar) = $_[0]);
    ((my  $str) = $_[1]);
    ((my  $pos) = $_[2]);
    ((my  $MATCH) = Perlito5::Match->new(('str' => $str), ('from' => $pos), ('to' => $pos), ('bool' => 1)));
    ($MATCH->{('bool')} = (((do {
    ((my  $pos1) = $MATCH->{('to')});
    (((do {
    (((do {
    ((my  $m2) = $grammar->concat_exp($str, $MATCH->{('to')}));
    if (($m2->{('bool')})) {
        ($MATCH->{('to')} = $m2->{('to')});
        ($MATCH->{'concat_exp'} = $m2);
        1
    }
    else {
        0
    }
})) && ((do {
    ((my  $pos1) = $MATCH->{('to')});
    (((do {
    (((((chr(124) eq substr($str, $MATCH->{('to')}, 1)) && (($MATCH->{('to')} = (1 + $MATCH->{('to')}))))) && ((do {
    ((my  $m2) = $grammar->or_list_exp($str, $MATCH->{('to')}));
    if (($m2->{('bool')})) {
        ($MATCH->{('to')} = $m2->{('to')});
        ($MATCH->{'or_list_exp'} = $m2);
        1
    }
    else {
        0
    }
}))) && ((do {
    ($MATCH->{('capture')} = (do {
    (my  @a);
    (my  @v);
    push(@a, $MATCH->{('concat_exp')}->flat() );
    (@v = @{$MATCH->{('or_list_exp')}->flat()});
    for my $x ((0 .. ((scalar(@v) - 1)))) {
        push(@a, $v[$x] )
    };
    \@a
}));
    1
})))
})) || ((do {
    ($MATCH->{('to')} = $pos1);
    (((do {
    ($MATCH->{('capture')} = (do {
    (my  @a);
    (my  @v);
    push(@a, $MATCH->{('concat_exp')}->flat() );
    \@a
}));
    1
})))
})))
})))
})) || ((do {
    ($MATCH->{('to')} = $pos1);
    (((do {
    ($MATCH->{('capture')} = (do {
    (my  @a);
    (my  @v);
    \@a
}));
    1
})))
})))
}))));
    $MATCH
};
sub rule {
    ((my  $grammar) = $_[0]);
    ((my  $str) = $_[1]);
    ((my  $pos) = $_[2]);
    ((my  $MATCH) = Perlito5::Match->new(('str' => $str), ('from' => $pos), ('to' => $pos), ('bool' => 1)));
    ($MATCH->{('bool')} = (((do {
    ((my  $pos1) = $MATCH->{('to')});
    ((do {
    ((((do {
    ((my  $pos1) = $MATCH->{('to')});
    (((do {
    (((do {
    ((my  $last_pos) = $MATCH->{('to')});
    if ((!(((do {
    ((my  $m2) = $grammar->ws($str, $MATCH->{('to')}));
    if (($m2->{('bool')})) {
        ($MATCH->{('to')} = $m2->{('to')});
        1
    }
    else {
        0
    }
}))))) {
        ($MATCH->{('to')} = $last_pos)
    };
    1
})) && (((chr(124) eq substr($str, $MATCH->{('to')}, 1)) && (($MATCH->{('to')} = (1 + $MATCH->{('to')}))))))
})) || ((do {
    ($MATCH->{('to')} = $pos1);
    (1)
})))
})) && ((do {
    ((my  $m2) = $grammar->or_list_exp($str, $MATCH->{('to')}));
    if (($m2->{('bool')})) {
        ($MATCH->{('to')} = $m2->{('to')});
        ($MATCH->{'or_list_exp'} = $m2);
        1
    }
    else {
        0
    }
}))) && ((do {
    ($MATCH->{('capture')} = Rul::Or->new(('or_list' => $MATCH->{('or_list_exp')}->flat())));
    1
})))
}))
}))));
    $MATCH
};

1;
