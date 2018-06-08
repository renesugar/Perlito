use v5;

package Perlito5::Java::Runtime;
use strict;

use Perlito5::Java::CORE;
use Perlito5::Java::Crypt;
use Perlito5::Java::JavaCompiler;

sub perl5_to_java {
    my ($source, $namespace, $want, $scope_java) = @_;

    # say "source: [" . $source . "]";

    local $_;
    local ${^GLOBAL_PHASE};
    local @Perlito5::BASE_SCOPE = ($scope_java);  # ->[0];
    local @Perlito5::SCOPE_STMT;
    local $Perlito5::CLOSURE_SCOPE = 0;
    local $Perlito5::PKG_NAME = $namespace;
    local @Perlito5::UNITCHECK_BLOCK;
    local @Perlito5::Java::Java_constants;
    local %Perlito5::Java::Java_constant_seen;

    # warn "in eval enter\n";
    # warn "External scope ", Perlito5::Dumper::Dumper($scope_java);
    # warn "BASE_SCOPE ", Perlito5::Dumper::Dumper($Perlito5::BASE_SCOPE);
    # warn "SCOPE_STMT ", Perlito5::Dumper::Dumper(\@Perlito5::SCOPE_STMT);

    my $match = Perlito5::Grammar::exp_stmts( $source, 0 );

    if ( !$match || $match->{to} < length($source) ) {
        die "Syntax error in eval near pos ", $match->{to};
    }

    # TODO - process type annotations like:
    #   package Java::Object { import => 'java.lang.Object' }
    #
    while ( @Perlito::ANNOTATION ) {
        my $ann = shift(@Perlito::ANNOTATION);
        my $str = Perlito5::AST::CompUnit::process_java_import_statement(@$ann);
        # warn "ANNOTATION: [[[\n$str\n]]]\n";
    }

    my $ast = 
        Perlito5::AST::Call->new(
            method => "postcircumfix:<( )>",
            arguments => [],
            invocant => Perlito5::AST::Sub->new(
                block => Perlito5::AST::Block->new(
                            stmts => $match->{capture},
                         ),
            ),
        );

    # use lexicals from BEGIN scratchpad
    $ast = $ast->emit_begin_scratchpad();

    # warn "perl_to_java: ", Perlito5::Dumper::Dumper( $ast );
    my $java_code = $ast->emit_java(2, $want);

    # say "java-source: [" . $java_code . "]";

    # warn "in perl_to_java: ", Perlito5::Dumper::Dumper( \@Perlito5::Java::Java_constants );

    my $java_classes = Perlito5::Java::get_java_class_info() // {};
    my $className = "PlEval" . $Perlito5::ID++;
    my $constants = "";
    $constants .= 
            "import org.perlito.Perlito5.*;\n"
          . "import java.util.regex.Pattern;\n"
          # . join("",
          #       # import the Java classes
          #       # that were declared with
          #       #
          #       #   package My::Java { import => "org.My.Java", ... }
          #       #
          #       map {
          #                   my $class = $java_classes->{$_};
          #                   $class->{import} ? "import $class->{import};\n" : ()
          #           }
          #           sort keys %$java_classes
          #   )
          . "public class " . $className . " {\n";
    for my $s ( @Perlito5::Java::Java_constants ) {
        # say "s: [[$s]] ", ref($s), "\n";
        $constants .= "    " . $s . ";\n";
    }
    $constants .= 
            "    public " . $className . "() {\n"
          . "    }\n";

    Perlito5::set_global_phase("UNITCHECK");
    $_->() while $_ = shift @Perlito5::UNITCHECK_BLOCK;

    # warn "in eval BASE_SCOPE exit: ", Perlito5::Dumper::Dumper($Perlito5::BASE_SCOPE);

    return ($className, $java_code, $constants);
}

sub eval_ast {
    my ($ast) = @_;
    my $want = 0;

    # TODO - process type annotations like:
    #   package Java::Object { import => 'java.lang.Object' }
    #
    while ( @Perlito::ANNOTATION ) {
        my $ann = shift(@Perlito::ANNOTATION);
        my $str = Perlito5::AST::CompUnit::process_java_import_statement(@$ann);
        # warn "ANNOTATION: [[[\n$str\n]]]\n";
    }

    # warn "AST:\n" . Perlito5::Dumper::Dumper($ast);

    # use lexicals from BEGIN scratchpad
    $ast = $ast->emit_begin_scratchpad();
    # warn "eval_ast: ", Perlito5::Dumper::Dumper( $ast );

    my $java_code = $ast->emit_java(2, $want);
    # say STDERR "java-source: [" . $java_code . "]";
    Perlito5::set_global_phase("UNITCHECK");
    $_->() while $_ = shift @Perlito5::UNITCHECK_BLOCK;
    # warn "in eval BASE_SCOPE exit: ", Perlito5::Dumper::Dumper($Perlito5::BASE_SCOPE);

    my $java_classes = Perlito5::Java::get_java_class_info() // {};
    my $className = "PlEval" . $Perlito5::ID++;
    my $constants = "";
    $constants .= 
            "import org.perlito.Perlito5.*;\n"
          . "import java.util.regex.Pattern;\n"
          # . join("",
          #       # import the Java classes
          #       # that were declared with
          #       #
          #       #   package My::Java { import => "org.My.Java", ... }
          #       #
          #       map {
          #                   my $class = $java_classes->{$_};
          #                   $class->{import} ? "import $class->{import};\n" : ()
          #           }
          #           sort keys %$java_classes
          #   )
          . "public class " . $className . " {\n";
    for my $s ( @Perlito5::Java::Java_constants ) {
        # say "s: [[$s]] ", ref($s), "\n";
        $constants .= "    " . $s . ";\n";
    }
    $constants .= 
            "    public " . $className . "() {\n"
          . "    }\n";

    # warn "constants [[\n$constants ]]\n";

    @_ = ($className, $java_code, $constants);
    return Java::inline('PlJavaCompiler.eval_java_string(List__)');
}

sub emit_java_extends {
    my ($class, $java_classes) = @_;
    # extends the imported Java classes
    # that were declared with
    #
    #   package My::X { extends => "My::Object" }
    #

    # 'extends' => 'My::Object',
    # 'extends_java_type' => 'Object',
    # 'java_native_to_perl' => 'pMyX',
    # 'java_type' => 'MyX',
    # 'perl_package' => 'My::X',
    # 'perl_to_java' => 'to_MyX',
    # 'Java::inline' => " // ... Java code ... \n",
    # 'methods' => [
    #     instance_meth => {
    #         decl => [ "public" ],
    #         return => "Int",
    #         args => [ "Int" ],     # this/$self is added to the Perl method arguments
    #         code => "MyClass::instance_meth",
    #     },
    #     class_meth => {
    #         decl => [ "public", "static" ],
    #         return => "Int",
    #         throws => [ "IOException" ],
    #         args => [ "Int" ],     # class name is added to the Perl method arguments
    #         code => "MyClass::class_meth",
    #     },
    #
    # TODO: constructors, variables
    #
    #     MyX => {
    #         decl => [ "public" ],
    #         return => undef,       # a constructor doesn't return anything
    #         args => [],
    #         Java::inline => '{ super(123) }',
    #     },
    # ],
    # 'variables' => [
    #     myName => {
    #         decl => [ "public" ],
    #         type => "String",
    #     },
    # ],

    my @out;
    my $java_decl = $class->{decl} // [];
    if ($class->{extends}) { 
        push @out, "@$java_decl class $class->{java_type} extends $class->{extends_java_type} {";
    }
    else {
        push @out, "@$java_decl class $class->{java_type} implements $class->{implements_java_type} {";
    }
    push @out, $class->{'Java::inline'} if $class->{'Java::inline'};
    while ( @{ $class->{variables} } ) {
        my $method = shift @{ $class->{variables} };
        my $data   = shift @{ $class->{variables} };
        # TODO
        #
    }
    while ( @{ $class->{methods} } ) {
        my $method = shift @{ $class->{methods} };
        my $data   = shift @{ $class->{methods} };
        my $decl   = $data->{decl};
        my $code   = $data->{code}   or die "Java extends: missing 'code' argument in method '$method'";
        my $return = $data->{return} or die "Java extends: missing 'return' argument in method '$method'";
        my @args;
        my $var = 0;
        for my $arg ( @{ $data->{args} } ) {
            my $type = $java_classes->{$arg};
            push @args, "$type->{java_type} param$var";
            $var++;
        }
        my @java_decl = @$decl;
        my $return_type = $return;
        if ( $return ne "void" ) {
            my $type = $java_classes->{$return};
            $return_type = $type->{java_type};
        }
        my $throws = '';
        if ( $data->{throws} ) {
            $throws = "throws @{ $data->{throws} }";
        }
        push @out, "    @java_decl $return_type $method(" . join(", ", @args) . ") $throws {";

        @args = ();
        if ( grep { $_ eq "static" } @$decl ) {
            # class method
            push @args, "new PlString(\"$class->{perl_package}\")";
        }
        else {
            # instance method
            push @args, "new $class->{java_native_to_perl}(this)";
        }
        $var = 0;
        for my $arg ( @{ $data->{args} } ) {
            my $type = $java_classes->{$arg};
            push @args, "new $type->{java_native_to_perl}(param$var)";
            $var++;
        }
        push @out, "        PlObject[] res = Main.apply(\"$code\", " . join(", ", @args) . ");";

        if ( $return eq "void" ) {
            # void method
            push @out, "        return;";
        }
        else {
            my $type = $java_classes->{$return}
              or die "Java class '$return' is not imported";
            push @out, "        return res[0].$type->{perl_to_java}();";
        }

        # public Int instance_meth(Int param1) {
        #     PlInt p1 = new PlInt(param1);
        #     PlObject[] res = Main.apply("MyClass::instance_meth", this, p1);
        #     return res[0].to_Int();
        # }
        # public Int class_meth(Int param1) {
        #     PlObject[] res = Main.apply("MyClass::class_meth", param1);
        #     return res[0].to_Int();
        # }

        push @out, "    }";
    }
    push @out, "}\n";
    return join("\n", @out);
}

sub emit_java {
    my ($self, %args) = @_;

    # This sub returns a list, to avoid the Java error: "constant string too long"

    my %java_classes = %{ $args{java_classes} // {} };

    if ($Perlito5::JAVA_EVAL) {
        return (
            <<'EOT'

// use perlito5-lib.jar
import org.perlito.Perlito5.*;
import java.util.regex.Pattern;
import java.time.*;
import java.time.format.*;
import java.lang.management.*;
EOT
            # import the Java classes
            # that were declared with
            #
            #   package My::Java { import => "org.My.Java", ... }
            #
            # , (( map {
            #             my $class = $java_classes{$_};
            #             $class->{import} ? "import $class->{import};\n" : ()
            #     }
            #     sort keys %java_classes
            #   ))
            # , "\n"
        );
    }

    my @number_unary = qw/ op_int neg complement abs sqrt cos sin exp log /;

    my @boolean_unary = (
        'is_int',
        'is_num',
        'is_string',
        'is_bool',
        'is_undef',
        'is_regex',
        'is_filehandle',
        'is_ref',
        'is_arrayref',
        'is_coderef',
        'is_hashref',
        'is_scalarref',
        'is_typeglobref',
    );

    my %number_binop = (
        add     => { op => '+',   returns => 'PlInt',    num_returns => 'PlDouble'}, 
        sub     => { op => '-',   returns => 'PlInt',    num_returns => 'PlDouble'},
        mul     => { op => '*',   returns => 'PlInt',    num_returns => 'PlDouble'},
        div     => { op => '/',   returns => 'PlDouble', num_returns => 'PlDouble'},
        num_eq  => { op => '==',  returns => 'PlBool',   num_returns => 'PlBool' },
        num_ne  => { op => '!=',  returns => 'PlBool',   num_returns => 'PlBool' },
        num_lt  => { op => '<',   returns => 'PlBool',   num_returns => 'PlBool' },
        num_le  => { op => '<=',  returns => 'PlBool',   num_returns => 'PlBool' },
        num_gt  => { op => '>',   returns => 'PlBool',   num_returns => 'PlBool' },
        num_ge  => { op => '>=',  returns => 'PlBool',   num_returns => 'PlBool' },
        int_and => { op => '&',   returns => 'PlInt',    num_returns => 'PlInt'  }, 
        int_or  => { op => '|',   returns => 'PlInt',    num_returns => 'PlInt'  }, 
        int_xor => { op => '^',   returns => 'PlInt',    num_returns => 'PlInt'  }, 
        int_shr => { op => '>>>', returns => 'PlInt',    num_returns => 'PlInt'  }, 
        int_shl => { op => '<<',  returns => 'PlInt',    num_returns => 'PlInt'  }, 
    );
    my %string_binop = (
        str_eq => { op => '==', str_op => 'eq',  returns => 'PlBool' },
        str_ne => { op => '!=', str_op => 'ne',  returns => 'PlBool' },
        str_lt => { op => '<',  str_op => 'lt',  returns => 'PlBool' },
        str_le => { op => '<=', str_op => 'le',  returns => 'PlBool' },
        str_gt => { op => '>',  str_op => 'gt',  returns => 'PlBool' },
        str_ge => { op => '>=', str_op => 'ge',  returns => 'PlBool' },
    );

    my %native_to_perl = (
        long    => 'PlInt',
        double  => 'PlDouble',
        boolean => 'PlBool',
        String  => 'PlString',
    );
    for (values %java_classes) {
        if ( $_->{perl_to_java} ) {
            if ( $_->{import} || $_->{extends} || $_->{implements} ) {
                $native_to_perl{$_->{java_type}} = $_->{java_native_to_perl};
            }
        }
    }

    my %self_assign_number_binop = (
        add     => { op => '+=', }, 
        sub     => { op => '-=', }, 
        mul     => { op => '*=', }, 
        div     => { op => '/=', }, 
        mod     => { op => '%=', }, 
        int_or  => { op => '|=', }, 
        int_and => { op => '&=', }, 
        int_xor => { op => '^=', }, 
        int_shr => { op => '>>=', }, 
        int_shl => { op => '<<=', }, 
        pow     => { op => '**=' },
    );
    # TODO self_assign:
    #   or                  ||
    #   and                 &&
    #   defined_or          //
    #   str_concat          .
    #   string_replicate    x.
    #   str_or              |.
    #   str_and             &.
    #   str_xor             ^.

    my %special_var_index = (
        # this is used by the variable localization methods
        '_'  => [ 4, 'PlLvalue' ],
        '\\' => [ 5, 'PlLvalue' ],
        '|'  => [ 6, 'PlLvalueSpecialVarAutoflush' ],
        '@'  => [ 7, 'PlLvalue' ],
    );

    return (
        <<'EOT'
// start Perl-Java runtime
// this is generated code - see: lib/Perlito5/Java/Runtime.pm

import java.lang.Math;
import java.lang.System;
import java.util.*;
import java.io.*;
import java.lang.management.*;
import java.nio.file.*;
import java.nio.file.attribute.*;
import java.nio.charset.*;
import java.nio.ByteBuffer;
import static java.nio.file.attribute.PosixFilePermission.*;
import java.time.*;
import java.time.format.*;
import java.util.regex.Pattern;
import java.util.regex.Matcher;
import java.util.concurrent.TimeUnit;
import java.lang.reflect.*;
EOT
    , ( $Perlito5::BOOTSTRAP_JAVA_EVAL ? Perlito5::Java::JavaCompiler->emit_java_imports() : () )

        # import the Java classes
        # that were declared with
        #
        #   package My::Java { import => "org.My.Java", ... }
        #
    , # (( map {
      #               my $class = $java_classes{$_};
      #               $class->{import} ? "import $class->{import};\n" : ()
      #       }
      #       sort keys %java_classes
      # ))
        # extends the imported Java classes
        # that were declared with
        #
        #   package My::Java { extends => "My::Java", ... }
        #
    , (( map {
                    my $class = $java_classes{$_};
                    $class->{extends} || $class->{implements} ? emit_java_extends($class, \%java_classes) : ()
            }
            sort keys %java_classes
      ))

    , Perlito5::Java::CORE->emit_java()

        # Perl-Java exceptions
    , <<'EOT'
class PlControlException extends RuntimeException {
}
class PlNextException    extends PlControlException {
    public int label_id;

    public PlNextException(int i) {
        this.label_id = i;
    }
}
class PlLastException    extends PlControlException {
    public int label_id;

    public PlLastException(int i) {
        this.label_id = i;
    }
}
class PlRedoException    extends PlControlException {
    public int label_id;

    public PlRedoException(int i) {
        this.label_id = i;
    }
}
class PlReturnException  extends PlControlException {
    public PlObject ret;

    public PlReturnException(PlObject ret) {
        this.ret = ret;
    }
}
class PlDieException  extends PlControlException {
    public PlObject ret;

    public PlDieException(PlObject ret) {
        this.ret = ret;
    }
    public String getMessage() {
        return this.ret.toString();
    }
}
class PlCx {
    public static final Thread mainThread = Thread.currentThread();
    public static final int     VOID   = 0;
    public static final int     SCALAR = 1;
    public static final int     LIST   = 2;
    public static final PlUndef  UNDEF  = new PlUndef();
    public static final PlBool   TRUE   = new PlBool(true);
    public static final PlBool   FALSE  = new PlBool(false);
    public static final Charset UTF8        = Charset.forName("UTF-8");
    public static final PlString EMPTY  = new PlString("");
    public static final PlNextException NEXT = new PlNextException(0);
    public static final PlLastException LAST = new PlLastException(0);
    public static final String OVERLOAD_STRING   = "(\"\"";  // (""
    public static final String OVERLOAD_NUM      = "(0+";
    public static final String OVERLOAD_BOOL     = "(bool";
    public static final String OVERLOAD_NOMETHOD = "(nomethod";
    public static final PlRegex SPLIT_SPACE      = new PlRegex("\\s+", Pattern.MULTILINE, false);
EOT
    , "    " . join("\n    ",
        map { "public static final PlInt " . ($_ < 0 ? "MIN" : "INT") . abs($_) . " = new PlInt($_);" }
            (-2 .. 9) ) . "\n"
    , "    " . join("\n    ", @{ $args{java_constants} // [] } ) . "\n"
    , <<'EOT'
}
EOT

    , Perlito5::Java::Crypt->emit_java()
    , ( $Perlito5::BOOTSTRAP_JAVA_EVAL ? Perlito5::Java::JavaCompiler->emit_java() : () )

    , <<'EOT'
class PerlCompare implements Comparator<PlObject> {
    public PlClosure sorter;
    public PlLvalue v_a;
    public PlLvalue v_b;
    public PlArray  list__;
    public PerlCompare (PlClosure sorter, PlLvalue a, PlLvalue b, PlArray list__) {
        this.sorter = sorter;
        this.v_a = a;
        this.v_b = b;
        this.list__ = list__;
    }
    public int compare (PlObject a, PlObject b) {
        v_a.set(a);
        v_b.set(b);
        return this.sorter.apply( PlCx.SCALAR, list__ ).to_int();
    }
}
class PerlRangeString implements Iterator<PlObject> {
    public PlString v_start;
    public String   v_end;
    public PerlRangeString(PlString v_start, String v_end) {
        this.v_start = v_start;
        this.v_end = v_end;
    }
    public PlObject next() {
        PlString ret = v_start;
        PlObject incr = v_start._incr();
        if (incr.is_string()) {
            v_start = (PlString)incr;
        }
        else {
            v_start = new PlString(incr.toString());
        }
        return new PlLvalue(ret);
    }
    public boolean hasNext() {
        return (  (v_start.int_length() < v_end.length())
               || (v_start.int_length() == v_end.length() && v_start.boolean_str_le(v_end)) );
    }
}
class PerlRangeInt implements Iterator<PlObject> {
    public long     v_start;
    public long     v_end;
    public PerlRangeInt(long v_start, long v_end) {
        this.v_start = v_start;
        this.v_end = v_end;
    }
    public PlObject next() {
        PlInt ret = new PlInt(v_start);
        v_start++;
        return new PlLvalue(ret);
    }
    public boolean hasNext() {
        return v_start <= v_end;
    }
}
class PlLvalueIterator implements Iterator<PlObject> {
    public PlLvalue v_start;
    public PlLvalueIterator(PlLvalue v_start) {
        this.v_start = v_start;
    }
    public PlObject next() {
        PlObject ret = v_start;
        v_start = null;
        return ret;
    }
    public boolean hasNext() {
        return (v_start != null);
    }
}
class PerlRange0 implements Iterator<PlObject> {
    public PerlRange0() {
    }
    public PlObject next() {
        return new PlObject();
    }
    public boolean hasNext() {
        return false;
    }
}
class PerlRange implements Iterable<PlObject> {
    public PlObject v_start;
    public PlObject v_end;
    private static HashMap<String, Integer> flip_flop = new HashMap<String, Integer>();
    public PerlRange(PlObject v_start, PlObject v_end) {
        this.v_start = v_start;
        this.v_end = v_end;
    }
    public Iterator<PlObject> iterator() {
        if (this.v_start.is_string() && this.v_end.is_string()) {
            String s = v_start.toString();
            final int length = s.length();
            if (length > 0) {
                boolean is_num_start = PerlOp.looks_like_number(s);
                boolean is_num_end = PerlOp.looks_like_number(this.v_end.toString());
                if (is_num_start && is_num_end && s.codePointAt(0) != '0') {
                    if (!this.v_start.is_integer_range() || !this.v_end.is_integer_range()) {
                        PlCORE.die("Range iterator outside integer range");
                    }
                    return new PerlRangeInt(this.v_start.to_long(), this.v_end.to_long());
                }
                // If the initial value specified isn't part of a magical increment sequence
                // (that is, a non-empty string matching /^[a-zA-Z]*[0-9]*\z/ ),
                // only the initial value will be returned.
                boolean is_incrementable = true;
                for (int offset = 0; offset < length; offset++) {
                    int c = s.codePointAt(offset);
                    if ((c >= 'A' && c <= 'Z') || (c >= 'a' && c <= 'z')) {
                        // good
                    }
                    else {
                        for ( ; offset < length; offset++) {
                            c = s.codePointAt(offset);
                            if (c >= '0' && c <= '9') {
                                // good
                            }
                            else {
                                is_incrementable = false;
                                offset = length;  // exit loop
                            }
                        }
                    }
                }
                if (is_incrementable) {
                    return new PerlRangeString(new PlString(s), this.v_end.toString());
                }
            }
            if (length > this.v_end.toString().length()) {
                return new PerlRange0();
            }
            return new PlLvalueIterator(new PlLvalue(new PlString(s)));
        }

        if (!this.v_start.is_integer_range() || !this.v_end.is_integer_range()) {
            PlCORE.die("Range iterator outside integer range");
        }
        return new PerlRangeInt(this.v_start.to_long(), this.v_end.to_long());
    }
    public final PlObject range(int want, String id, int three_dots) {
        if (want == PlCx.LIST) {
            PlArray ret = new PlArray();
            for (PlObject i : this) {
                ret.a.add(i);
            }
            return ret;
        }
        // http://perldoc.perl.org/perlop.html#Range-Operators
        Integer v = flip_flop.get(id);
        if (v != null && v != 0) {
            v++;
            if (v_end.to_boolean()) {
                flip_flop.put(id, 0);
                return new PlString("" + v + "E0");
            }
            else {
                flip_flop.put(id, v);
                return new PlInt(v);
            }
        }
        else {
            if (v_start.to_boolean()) {
                v = 1;
            }
            else {
                v = 0;
            }
            if (v != 0 && three_dots == 0 && v_end.to_boolean()) {
                flip_flop.put(id, 0);
                return new PlString("" + v + "E0");
            }
            else {
                flip_flop.put(id, v);
                if (v == 0) {
                    return PlCx.EMPTY;
                }
                return new PlInt(v);
            }
        }
    }
}
class PerlArgumentLookupResult {
    // public ArrayList<Class[]> params;
    public Object arg;
    public Class cl;

    public PerlArgumentLookupResult(Object arg, Class cl) {
        // , ArrayList<Class[]> params) {
        this.arg    = arg;
        this.cl     = cl;
        // this.params = params;
    }
}
class PerlOp {
    // PerlOp implements operators: && ||
    //      and auxiliary functions
    //
    // note: '+' add() and '-' sub() are PlObject methods, not implemented here.
    //
    // TODO - see Perlito5/JavaScript2/Runtime.pm for more operator implementations

    // symbol tables
    // like %Module::
    public static final PlObject getSymbolTable(String nameSpace) {
        // TODO - create the typeglobs that link to "inner" namespaces, like *Java:: in %Perlito5::Java::
        int pos = nameSpace.lastIndexOf("::");
        boolean isMain = nameSpace.equals("main::");
        PlHash out = new PlHash();
        getSymbolTableScan(out, PlStringConstant.constants, nameSpace, pos, isMain);
        return out;
    }

    private static final void getSymbolTableScan(PlHash out, HashMap<String, PlStringConstant> vars, String nameSpace, int pos, boolean isMain) {
        String[] keys = vars.keySet().toArray(new String[0]);
        if (isMain) {
            for (String name : keys) {
                if (name.length() > pos + 2 && name.indexOf(nameSpace) == 0 && name.lastIndexOf("::") == pos) {
                    // normal variable like "ARGV" in $main::ARGV
                    out.hset(name.substring(pos+2), PlV.fget(name));
                }
                else {
                    // "inner" namespace
                    String inner = name.substring(0, name.indexOf("::")+2);
                    out.hset(inner, PlV.fget(inner));
                }
            }
        }
        else {
            for (String name : keys) {
                if (name.length() > pos + 2 && name.indexOf(nameSpace) == 0) {
                    if (name.lastIndexOf("::") == pos) {
                        // normal variable like "ARGV" in $main::ARGV
                        out.hset(name.substring(pos+2), PlV.fget(name));
                    }
                    else {
                        // "inner" namespace
                        String inner = name.substring(pos+2, name.indexOf("::", pos+2)+2);
                        out.hset(inner, PlV.fget(name.substring(0, name.indexOf("::", pos+2)+2)));
                    }
                }
            }
        }
    }

    public static final PlObject deleteSymbolTable(String nameSpace, PlObject index) {
        // delete $Foo::{foo}
        String sname = nameSpace + index.toString();
        PlString name = new PlString(sname);
        PlStringConstant glob = PlStringConstant.getConstant(sname);
        glob.codeRef.set(PlCx.UNDEF);
        glob.scalarRef.set(PlCx.UNDEF);
        glob.arrayRef.set(new PlArrayRef());
        glob.hashRef.set(new PlHashRef());
        glob.fileRef.set(new PlFileHandle(sname));
        return PlCx.UNDEF; 
    }

    // filehandles
    public static final PlFileHandle get_filehandle(PlObject fh, String nameSpace) {
        if (fh.is_lvalue()) {
            if (fh.is_undef()) {
                // $fh autovivification to filehandle
                fh.set(new PlFileHandle(nameSpace));
            }
            fh = fh.get();
        }
        if (fh.is_filehandle()) {
            // *FILE
            return (PlFileHandle)fh;
        }
        if (fh.is_typeglobref()) {
            // \*FILE
            return ((PlGlobRef)fh).filehandle;
        }
        return get_filehandle(fh.toString(), nameSpace);    // get "GLOB" by name
    }
    public static final PlFileHandle get_filehandle(String s, String nameSpace) {
        int pos = s.indexOf("::");
        if (pos == 0) {
            // ::x
            s = "main" + s;
        }
        if (pos == -1) {
            if (s.equals("STDOUT")) {
                s = "main::STDOUT";
            }
            else if (s.equals("STDERR")) {
                s = "main::STDERR";
            }
            else if (s.equals("STDIN")) {
                s = "main::STDIN";
            }
            else if (s.equals("ARGV")) {
                s = "main::ARGV";
            }
            else {
                s = nameSpace + "::" + s;
            }
        }
        while (s.startsWith("main::main::")) {
            s = s.substring(6);
        }
        PlObject fh = PlV.fget(s);    // get "GLOB" by name
        return (PlFileHandle)(fh.get());
    }
    public static final Set<PosixFilePermission> MaskToPermissions(int mask) {
        final Set<PosixFilePermission> perm = new HashSet<PosixFilePermission>();
        // TODO - provide a workaround
        // if ((mask & 04000)==0) PlCORE.die("setuid bit not implemented");
        // if ((mask & 02000)==0) PlCORE.die("setgid bit not implemented");
        // if ((mask & 01000)==0) PlCORE.die("sticky bit not implemented");
        if ((mask & 00400)==0) perm.add(OWNER_READ);
        if ((mask & 00200)==0) perm.add(OWNER_WRITE);
        if ((mask & 00100)==0) perm.add(OWNER_EXECUTE);
        if ((mask & 00040)==0) perm.add(GROUP_READ);
        if ((mask & 00020)==0) perm.add(GROUP_WRITE);
        if ((mask & 00010)==0) perm.add(GROUP_EXECUTE);
        if ((mask & 00004)==0) perm.add(OTHERS_READ);
        if ((mask & 00002)==0) perm.add(OTHERS_WRITE);
        if ((mask & 00001)==0) perm.add(OTHERS_EXECUTE);
        return perm;
    }

    // objects

    public static final PlObject callSuper( String method, String packageName, PlArray args, int context ) {
        // SUPER calls:  $v->SUPER::x;
        PlObject methodCode = PlCx.UNDEF;
      ISA:
        for (PlObject className : PlV.array_get(packageName + "::ISA")) {
            methodCode = PlClass.getInstance(className).method_lookup(method, 0);
            if (!methodCode.is_undef()) {
                break ISA;
            }
        }
        if (methodCode.is_undef()) {
            PlCORE.die( "Can't locate object method \"" + method
                + "\" via package \"" + packageName + "\"");
        }
        return PerlOp.call(methodCode, args, context);
    }

    // coderef methods can be called on ANY invocant
    //  $m = sub {...};
    //  $a->$m
    public static final PlObject call( PlObject method, PlArray args, int context ) {
        if ( method.is_coderef() ) {
            return method.apply(context, args);
        }
        else if ( method.is_lvalue() ) {
            return call( method.get(), args, context );
        }
        else {
            return call( method.toString(), args, context );
        }
    }
    public static final PlObject call( PlStringConstant method, PlArray args, int context ) {
        return call( method.toString(), args, context );
    }
    public static final PlObject call( String method, PlArray args, int context ) {
        PlObject invocant = args.aget(0);

        PlClass pClass = invocant.blessed_class();

        if ( pClass != null ) {
            // invocant is a normal Perl object instance
            PlObject methodCode = pClass.method_lookup(method, 0);
            if (methodCode.is_undef()) {
                String className = pClass.className();
                return PlCORE.die( "Can't locate object method \"" + method
                    + "\" via package \"" + className
                    + "\" (perhaps you forgot to load \"" + className + "\"?)" );
            }
            return methodCode.apply(context, args);
        }

        if ( invocant.is_lvalue() ) {
            invocant = invocant.get();
        }
        if ( invocant.is_JavaObject() ) {
            args.shift();   // remove invocant
            Object obj = ((PlJavaObject)invocant).toJava();
            PlLvalue ret = new PlLvalue();
            Class cl;
            if (obj instanceof Class) {
                cl = (Class)obj;
            }
            else {
                cl = obj.getClass();
            }

            int argCount = args.to_int();
            if (argCount == 0) {
                // no arguments; this may be a "field"
                try {
                    Field fi = cl.getField(method);
                    if (obj instanceof Class) {
                        // obj is Class; method is "field"
                        ret.set( fi.get(null) );
                    }
                    else {
                        // obj is instance; method is "field"
                        ret.set( fi.get(obj) );
                    }
                    return ret;
                }
                catch (NoSuchFieldException e) {
                    // Array "length" is special
                    if (method.equals("length")) {
                        try {
                            ret.set(Array.getLength(obj));
                            return ret;
                        }
                        catch (Exception e2) {
                        }
                    }
                }
                catch (Exception e) {
                    return PlCORE.die(new PlStringLazyError(e));
                }
            }

            ArrayList<Class[]> params = new ArrayList<Class[]>();
            for (Method m : cl.getMethods()) {
                if (m.getName().equals(method)) {
                    Class[] mArgs = m.getParameterTypes();
                    if (mArgs.length > 0 && mArgs.length <= argCount) {
                        params.add(mArgs);
                    }
                }
            }
            if (method.equals("new")) {

                if (cl.isArray() && args.to_int() == 1) {
                    // $ArrayClass->new(10)
                    ret.set( java.lang.reflect.Array.newInstance(cl.getComponentType(), args.aget(0).to_int()) );
                    return ret;
                }

                for (Constructor m : cl.getConstructors()) {
                    Class[] mArgs = m.getParameterTypes();
                    if (mArgs.length > 0 && mArgs.length <= argCount) {
                        params.add(mArgs);
                    }
                }
            }

            // TODO - overloading
            //   - sort constructors by specificity
            //   - See: https://docs.oracle.com/javase/specs/jls/se7/html/jls-15.html#jls-15.12.2
            //          http://www.xyzws.com/javafaq/what-is-a-mostspecific-method/8
            //   - type promotion: byte -> short -> int -> long -> float -> double
            //   - boxing / unboxing
            //   - method arity: consider variable arity (Object...) "[Ljava.lang.Object;"
            //
            //          perl> eval { $aa = Java::inline q{ Class.forName("java.lang.String") }}
            //          Class(0xf3fcd59)
            //          perl> $aa->format("aaa", 123)
            //              java.lang.String    - param #1
            //              [Ljava.lang.Object; - param #2, ...
            //
            //   - check Class.getSuperclass()
            //   - special case when arglist is empty, but (Object...)
            //   - Creating arrays via Java Reflection is done using the java.lang.reflect.Array:
            //     See: http://tutorials.jenkov.com/java-reflection/arrays.html
            //
            //          cl.isArray()            // true
            //          cl.getComponentType()   // int.class
            //          int[] intArray = (int[]) Array.newInstance(int.class, 3);
            //

            // System.out.println("Candidate methods " + method);
            // for(int i = 0; i < params.size(); i++) {
            //     System.out.println("  params:");
            //     for(Class c : params.get(i)) {
            //         System.out.println("    " + c.getName());
            //     }
            // }

            int paramPos = 0;
            ArrayList<Class[]> param2;
            ArrayList<Class> classArgs = new ArrayList<Class>();
            ArrayList<Object> objArgs = new ArrayList<Object>();
            PerlArgumentLookupResult newArg;

          ARGS:
            while (args.to_int() > 0) {
                PlObject v = args.shift();
                newArg = v.castToClass( params, paramPos );
                // System.out.println("Closest class " + newArg.cl.getName());

                if (newArg.arg == null && newArg.cl.isArray()) {
                    // varargs
                    // System.out.println("Start varargs");
                    args.unshift(v);    // cast the argument again
                    Class varargsArrayClass = newArg.cl;
                    Class varargsClass = varargsArrayClass.getComponentType();
                    Object[] varargs = (Object[])java.lang.reflect.Array.newInstance(varargsClass, args.to_int());
                    params = new ArrayList<Class[]>();
                    params.add( new Class[]{ varargsClass } );
                    paramPos = 0;
                    int varargsPos = 0;
                    while (args.to_int() > 0) {
                        v = args.shift();
                        newArg = v.castToClass( params, paramPos );
                        // System.out.println("varargs: Closest class " + newArg.cl.getName());
                        varargs[varargsPos++] = newArg.arg;
                    }
                    classArgs.add(varargsArrayClass);
                    objArgs.add(varargs);
                    break ARGS;
                }

                classArgs.add(newArg.cl);
                objArgs.add(newArg.arg);

                // prune candidates
                param2 = new ArrayList<Class[]>();
                for (Class[] mArgs : params) {
                    if (mArgs[paramPos].equals(newArg.cl)) {
                        param2.add(mArgs);
                    }
                }
                params = param2;
                paramPos++;

                // System.out.println("Candidate methods " + method);
                // for(int i = 0; i < params.size(); i++) {
                //     System.out.println("  params:");
                //     for(Class c : params.get(i)) {
                //         System.out.println("    " + c.getName());
                //     }
                // }
            }

            try {
                Method meth = ((Class<?>)cl).getMethod(method, classArgs.toArray(new Class[classArgs.size()]));
                ret.set( meth.invoke(obj, objArgs.toArray(new Object[objArgs.size()])));
                return ret;
            }
            catch (NoSuchMethodException e) {
            }
            catch (Exception e) {
                return PlCORE.die(new PlStringLazyError(e));
            }
            if (method.equals("new")) {
                try {
                    Constructor co = ((Class<?>)cl).getConstructor(classArgs.toArray(new Class[classArgs.size()]));
                    ret.set( co.newInstance(objArgs.toArray(new Object[objArgs.size()])) );
                    return ret;
                }
                catch (NoSuchMethodException e) {
                }
                catch (Exception e) {
                    return PlCORE.die(new PlStringLazyError(e));
                }
            }
            return PlCORE.die( "Can't locate object method \"" + method
                + "\" via Java class \"" + cl.getCanonicalName()
                + "\" (perhaps the parameter types don\'t match?)" );
        }
        if ( invocant.is_undef() ) {
            return PlCORE.die( "Can't call method \"" + method + "\" on an undefined value" );
        }
        if (invocant.is_typeglobref()) {
            // \*FILE
            invocant = ((PlGlobRef)invocant).filehandle;
        }

        if (invocant.is_ref()) {
            return PlCORE.die( "Can't call method \"" + method + "\" on unblessed reference" );
        }

        if (invocant.is_filehandle()) {
            // invocant can be a nonref-typeglob
            // *FILE
            // $fh->print() is allowed, even if $fh is unblessed
            if (method.equals("print")) {
                args.shift();   // TODO - keep filehandle in arg list
                return PlCORE.print(context, (PlFileHandle)invocant, args.toString());
            }
        }

        // invocant can be a package name
        String invocant_str = invocant.toString();
        if ( invocant_str.equals("") ) {
            return PlCORE.die( "Can't call method \"" + method + "\" on an undefined value" );
        }
        PlObject methodCode = PlClass.getInstance(invocant_str).method_lookup(method, 0);
        if (methodCode.is_undef()) {
            return PlCORE.die( "Can't locate object method \"" + method
                + "\" via package \"" + invocant_str
                + "\" (perhaps you forgot to load \"" + invocant_str + "\"?)" );
        }
        return methodCode.apply(context, args);
    }

    // local()
    public static final PlObject push_local(PlHash container, String index) {
        PlV.local_stack.a.add(container);
        PlV.local_stack.a.add(new PlString(index));
        PlLvalue empty = new PlLvalue();
        PlV.local_stack.a.add(container.hget_lvalue(index));
        PlV.local_stack.a.add(PlCx.INT0);
        container.hset_alias(index, empty);
        return empty;
    }
    public static final PlObject push_local(PlArray container, int index) {
        PlV.local_stack.a.add(container);
        PlV.local_stack.a.add(new PlInt(index));
        PlLvalue empty = new PlLvalue();
        PlV.local_stack.a.add(container.aget_lvalue(index));
        PlV.local_stack.a.add(PlCx.INT1);
        container.aset_alias(index, empty);
        return empty;
    }
    public static final void push_local_regex_result() {
        PlRegexResult match = PlV.regex_result;
        PlV.local_stack.a.add(match);
        PlV.local_stack.a.add(PlCx.INT2);
        PlRegexResult new_match = new PlRegexResult();
        new_match.matcher = match.matcher;
        new_match.regex_string = match.regex_string;
        PlV.regex_result = new_match;
    }
    public static final PlObject push_local_named_sub(PlObject value, String name) {
        PlStringConstant glob = PlStringConstant.getConstant(name);
        PlV.local_stack.a.add(new PlString(name));
        PlV.local_stack.a.add(glob.codeRef);
        PlV.local_stack.a.add(PlCx.INT3);
        PlLvalue newValue = new PlLvalue();
        newValue.set(value);
        glob.cset_alias( newValue );
        return newValue;
    }
    public static final PlObject push_local_scalar(PlObject value, String name) {
        PlStringConstant glob = PlStringConstant.getConstant(name);
        PlV.local_stack.a.add(new PlString(name));
        PlV.local_stack.a.add(glob.scalarRef);
        PlV.local_stack.a.add(new PlInt(20));       // XXX magic number
        PlLvalue newValue = new PlLvalue();
        newValue.set(value);
        glob.scalarRef = newValue;
        return newValue;
    }
    public static final PlObject push_local_array(PlObject value, String name) {
        PlStringConstant glob = PlStringConstant.getConstant(name);
        PlV.local_stack.a.add(new PlString(name));
        PlV.local_stack.a.add(glob.arrayRef);
        PlV.local_stack.a.add(new PlInt(21));       // XXX magic number
        PlLvalue newValue = new PlLvalue();
        newValue.set(value);
        glob.arrayRef = newValue;
        return newValue;
    }
    public static final PlObject push_local_hash(PlObject value, String name) {
        PlStringConstant glob = PlStringConstant.getConstant(name);
        PlV.local_stack.a.add(new PlString(name));
        PlV.local_stack.a.add(glob.hashRef);
        PlV.local_stack.a.add(new PlInt(22));       // XXX magic number
        PlLvalue newValue = new PlLvalue();
        newValue.set(value);
        glob.hashRef = newValue;
        return newValue;
    }
    public static final PlObject push_local_file(PlObject value, String name) {
        PlStringConstant glob = PlStringConstant.getConstant(name);
        PlV.local_stack.a.add(new PlString(name));
        PlV.local_stack.a.add(glob.fileRef);
        PlV.local_stack.a.add(new PlInt(23));       // XXX magic number
        PlLvalue newValue = new PlLvalue();
        newValue.set(value);
        glob.fileRef = newValue;
        return newValue;
    }

    // localizers for special variables like $_ $\
EOT
    , (( map {
                my $java_name = $Perlito5::Java::special_scalar{$_};
                my $index     = $special_var_index{$_}[0];
                my $class     = $special_var_index{$_}[1];
"
    public static final void push_local_special_var_${java_name}() {
        PlV.local_stack.a.add(PlV.${java_name});
        PlV.local_stack.a.add(PlCx.INT${index});
        PlV.${java_name} = new $class();
    }
"
            }
            sort keys %Perlito5::Java::special_scalar
      ))
    , <<'EOT'

    public static final int local_length() {
        return PlV.local_stack.to_int();
    }
    public static final PlObject cleanup_local(int pos, PlObject ret) {
        while (PlV.local_stack.to_int() > pos) {
            int t = PlV.local_stack.pop().to_int();
            PlObject v = PlV.local_stack.pop();
            PlObject index;
            PlObject container;
            switch (t) {
                case 0:
                    index     = PlV.local_stack.pop();
                    container = PlV.local_stack.pop();
                    ((PlHash)container).hset_alias(index.toString(), (PlLvalue)v);
                    break;
                case 1:
                    index     = PlV.local_stack.pop();
                    container = PlV.local_stack.pop();
                    ((PlArray)container).aset_alias(index.to_int(), (PlLvalue)v);
                    break;
                case 2:
                    PlV.regex_result = (PlRegexResult)v;
                    break;
                case 3:
                    index     = PlV.local_stack.pop();
                    PlStringConstant.getConstant(index.toString()).cset_alias( (PlLvalue)v );
                    break;
                case 20:      // XXX magic number
                    index     = PlV.local_stack.pop();
                    PlStringConstant.getConstant(index.toString()).scalarRef = (PlLvalue)v;
                    break;
                case 21:      // XXX magic number
                    index     = PlV.local_stack.pop();
                    PlStringConstant.getConstant(index.toString()).arrayRef = (PlLvalue)v;
                    break;
                case 22:      // XXX magic number
                    index     = PlV.local_stack.pop();
                    PlStringConstant.getConstant(index.toString()).hashRef = (PlLvalue)v;
                    break;
                case 23:      // XXX magic number
                    index     = PlV.local_stack.pop();
                    PlStringConstant.getConstant(index.toString()).fileRef = (PlLvalue)v;
                    break;
EOT
    , (( map {
                my $java_name = $Perlito5::Java::special_scalar{$_};
                my $index     = $special_var_index{$_}[0];
                my $class     = $special_var_index{$_}[1];
"
                case ${index}:
                    PlV.${java_name} = ($class)v;
                    break;
"
            }
            sort keys %Perlito5::Java::special_scalar
      ))
    , <<'EOT'

            }
        }
        return ret;
    }

    // context()
    //      - handles run-time scalar/list/void context in expression results
    public static final PlObject context(int want, PlObject arg) {
        if (want == PlCx.LIST) {
            return arg;
        }
        return arg.scalar();
    }
    public static final PlObject context(int want, Object o) {
        PlObject arg = PlJavaObject.fromObject(o);
        if (want == PlCx.LIST) {
            return arg;
        }
        return arg.scalar();
    }
    public static final PlObject context(int want) {
        if (want == PlCx.LIST) {
            return new PlArray();
        }
        return PlCx.UNDEF;
    }
    public static final PlObject context(int want, PlObject... args) {
        if (want == PlCx.LIST) {
            return new PlArray(args);
        }
        return args[args.length-1].scalar();
    }
    public static final PlObject context(int want, String arg) {
        if (want == PlCx.LIST) {
            return new PlArray(new PlString(arg));
        }
        return new PlString(arg);
    }

    // process id
    public static PlObject getPID() {
      String processName =
        java.lang.management.ManagementFactory.getRuntimeMXBean().getName();
      return new PlString(processName.split("@")[0]);
    }

    // statement()
    //      - workaround for "Error: not a statement"
    //      - this is the compile-time version of context(null, arg)
    public static final void statement(PlObject... args) { }
    public static final void statement() { }

    // control-flow exceptions
    public static final PlObject next() {
        throw PlCx.NEXT;
    }
    public static final PlObject next(int label_id) {
        throw new PlNextException(label_id);
    }
    public static final PlObject last() {
        throw PlCx.LAST;
    }
    public static final PlObject last(int label_id) {
        throw new PlLastException(label_id);
    }
    public static final PlObject redo(int label_id) {
        throw new PlRedoException(label_id);
    }
    public static final PlObject ret(PlObject ret) {
        throw new PlReturnException(ret);
    }

    public static final PlObject gotoOp(int ctx, PlObject s, PlArray List__) {
        if (s.is_coderef()) {
            // goto &subr;
            throw new PlReturnException(s.apply(ctx, List__));
        }
        return PlCORE.die("goto() not implemented");
    }

EOT
    ,   # list break
<<'EOT'

    public static final PlObject mod(PlInt aa, PlObject bb) {
        long a = aa.to_long();
        long b = bb.to_long();
        long res = Math.abs(a) % Math.abs(b);
        // PlCORE.say("mod " + a + " % " + b + " = " + res);
        if (a < 0 && b > 0) {
            return new PlInt(b - res);
        }
        if (a > 0 && b < 0) {
            return new PlInt(b + res);
        }
        if (a < 0 && b < 0) {
            return new PlInt(- res);
        }
        return new PlInt(res);
    }
    public static final PlObject mod(PlDouble aa, PlObject bb) {
        double a = aa.to_double();
        double b = bb.to_double();
        double res = Math.abs(a) % Math.abs(b);
        // PlCORE.say("mod " + a + " % " + b + " = " + res);
        if (a < 0.0 && b > 0.0) {
            return new PlDouble(b - res);
        }
        if (a > 0.0 && b < 0.0) {
            return new PlDouble(b + res);
        }
        if (a < 0.0 && b < 0.0) {
            return new PlDouble(- res);
        }
        return new PlDouble(res);
    }

    public static final PlObject srand() {
        PlV.random = new Random();
        return PlCx.UNDEF;
    }
    public static final PlObject srand(PlObject o) {
        if (!o.is_integer_range()) {
            PlCORE.warn(PlCx.VOID, new PlArray(new PlString("Integer overflow in srand")));
        }
        long s = o.to_long();
        PlV.random = new Random(s);
        if (s == 0) {
            return new PlString("0E0");
        }
        return new PlInt(s);
    }

    public static final PlObject rand(double s) {
        if (s == 0.0) {
            s = 1.0;
        }
        return new PlDouble(s * PlV.random.nextDouble());
    }

    // and1(x) ? y : and3()
    public static final boolean and1(PlObject arg1) {
        if (arg1.to_boolean()) {
            return true;
        }
        else {
            PlV.boolean_stack = arg1;
            return false;
        }
    }
    public static final PlObject and3() {
        return PlV.boolean_stack;
    }

    // or1(x) ? or2() : y
    public static final boolean or1(PlObject arg1) {
        if (arg1.to_boolean()) {
            PlV.boolean_stack = arg1;
            return true;
        }
        else {
            return false;
        }
    }
    public static final PlObject or2() {
        return PlV.boolean_stack;
    }

    // defined_or1(x) ? defined_or2() : y
    public static final boolean defined_or1(PlObject arg1) {
        if (!arg1.is_undef()) {
            PlV.boolean_stack = arg1;
            return true;
        }
        else {
            return false;
        }
    }
    public static final PlObject defined_or2() {
        return PlV.boolean_stack;
    }

    public static final PlInt ord(PlObject s) {
        String item = s.toString();
        return new PlInt(item.length() > 0 ? Character.codePointAt(item, 0) : 0);
    }

    //    'prefix:<-A>' => 'PerlOp.p5atime',
    //    'prefix:<-C>' => 'PerlOp.p5ctime',
    //    'prefix:<-M>' => 'PerlOp.p5mtime',
    //    'prefix:<-d>' => 'PerlOp.p5is_directory',
    //    'prefix:<-e>' => 'PerlOp.p5file_exists',
    //    'prefix:<-f>' => 'PerlOp.p5is_file',
    //    'prefix:<-s>' => 'PerlOp.p5size',

    public static final Path resolve_file(PlObject s) throws IOException {
        String name = s.toString();
        if (name.equals("_") && PlV.lastStat != null) {
            return PlV.path.resolve(PlV.lastStat).toRealPath();
        }
        PlV.lastStat = name;
        return PlV.path.resolve(name).toRealPath();
    }

    public static final PlObject p5atime(PlObject s) {
        return PlCORE.die("-A not implemented");
    }
    public static final PlObject p5ctime(PlObject s) {
        return PlCORE.die("-C not implemented");
    }
    public static final PlObject p5mtime(PlObject s) {
        try {
            // TODO - "Script start time minus file modification time, in days"
            return new PlDouble(new File(resolve_file(s).toString()).lastModified() / 86400.0);
        }
        catch(IOException e) {
            PlV.sset("main::!", new PlStringLazyError(e));
            return PlCx.UNDEF;
        }
        catch(RuntimeException e) {
            PlV.sset("main::!", new PlStringLazyError(e));
            return PlCx.UNDEF;
        }
    }
    public static final PlObject p5is_directory(PlObject s) {
        try {
            return new PlBool(new File(resolve_file(s).toString()).isDirectory());
        }
        catch(IOException e) {
            PlV.sset("main::!", new PlStringLazyError(e));
            return PlCx.UNDEF;
        }
        catch(RuntimeException e) {
            PlV.sset("main::!", new PlStringLazyError(e));
            return PlCx.UNDEF;
        }
    }
    public static final PlObject p5file_exists(PlObject s) {
        try {
            return new PlBool(new File(resolve_file(s).toString()).exists());
        }
        catch(IOException e) {
            PlV.sset("main::!", new PlStringLazyError(e));
            return PlCx.UNDEF;
        }
        catch(RuntimeException e) {
            PlV.sset("main::!", new PlStringLazyError(e));
            return PlCx.UNDEF;
        }
    }
    public static final PlObject p5is_file(PlObject s) {
        try {
            return new PlBool(new File(resolve_file(s).toString()).isFile());
        }
        catch(IOException e) {
            PlV.sset("main::!", new PlStringLazyError(e));
            return PlCx.UNDEF;
        }
        catch(RuntimeException e) {
            PlV.sset("main::!", new PlStringLazyError(e));
            return PlCx.UNDEF;
        }
    }
    public static final PlObject p5size(PlObject s) {
        try {
            return new PlInt(new File(resolve_file(s).toString()).length());
        }
        catch(IOException e) {
            PlV.sset("main::!", new PlStringLazyError(e));
            return PlCx.UNDEF;
        }
        catch(RuntimeException e) {
            PlV.sset("main::!", new PlStringLazyError(e));
            return PlCx.UNDEF;
        }
    }
    public static final PlObject p5is_symbolic_link(PlObject s) {
        try {
            return new PlBool(Files.isSymbolicLink(resolve_file(s)));
        }
        catch(IOException e) {
            PlV.sset("main::!", new PlStringLazyError(e));
            return PlCx.UNDEF;
        }
        catch(RuntimeException e) {
            PlV.sset("main::!", new PlStringLazyError(e));
            return PlCx.UNDEF;
        }
    }
    public static final PlObject p5is_writable(PlObject s) {
        try {
            return new PlBool(Files.isWritable(resolve_file(s)));
        }
        catch(IOException e) {
            PlV.sset("main::!", new PlStringLazyError(e));
            return PlCx.UNDEF;
        }
        catch(RuntimeException e) {
            PlV.sset("main::!", new PlStringLazyError(e));
            return PlCx.UNDEF;
        }
    }
    public static final PlObject p5is_readable(PlObject s) {
        try {
            return new PlBool(Files.isReadable(resolve_file(s)));
        }
        catch(IOException e) {
            PlV.sset("main::!", new PlStringLazyError(e));
            return PlCx.UNDEF;
        }
        catch(RuntimeException e) {
            PlV.sset("main::!", new PlStringLazyError(e));
            return PlCx.UNDEF;
        }
    }
    public static final PlObject p5is_executable(PlObject s) {
        try {
            return new PlBool(Files.isExecutable(resolve_file(s)));
        }
        catch(IOException e) {
            PlV.sset("main::!", new PlStringLazyError(e));
            return PlCx.UNDEF;
        }
        catch(RuntimeException e) {
            PlV.sset("main::!", new PlStringLazyError(e));
            return PlCx.UNDEF;
        }
    }

    public static final PlObject p5is_named_pipe(PlObject s) {
        // TODO "-p"
        return new PlBool(false);
    }

    public static final PlObject list_replicate(PlArray o, PlObject c, int wantarray) {
        if (wantarray == PlCx.SCALAR) {
            return o.aget(-1).string_replicate(c);
        }
        int count = c.to_int();
        PlArray arr = new PlArray();
        int olength = o.to_int();
        if (count > 0) {
            for (int ci = 0; ci < count; ci++) {
                for (int oi = 0; oi < olength; oi++) {
                    // this pushes an alias to the original value, as discussed in
                    // https://beta.nntp.perl.org/group/perl.perl5.porters/2013/06/msg203177.html
                    arr.a.add( o.aget_lvalue(oi) );
                }
            }
        }
        return arr;
    }
    public static final PlObject grep(PlClosure c, PlArray a, PlArray list__, int wantarray) {
        PlArray ret = new PlArray();
        int size = a.to_int();
        PlLvalue v__ref = PlV.Scalar_ARG;
        PlObject v__val = v__ref.get();
        for (int i = 0; i < size; i++) {
            boolean result;
            PlObject temp = a.aget(i);
            v__ref.set(temp);
            result = c.apply(PlCx.SCALAR, list__).to_boolean();
            if (result) {
                ret.push_void(temp);
            }
        }
        v__ref.set(v__val);
        return (wantarray == PlCx.LIST ) ? ret : ret.length_of_array();
    }
    public static final PlObject map(PlClosure c, PlArray a, PlArray list__, int wantarray) {
        if (wantarray == PlCx.LIST ) {
            PlArray ret = new PlArray();
            int size = a.to_int();
            PlLvalue v__ref = PlV.Scalar_ARG;
            PlObject v__val = v__ref.get();
            for (int i = 0; i < size; i++) {
                v__ref.set(a.aget(i));
                ret.push_void(c.apply(PlCx.LIST, list__));
            }
            v__ref.set(v__val);
            return ret;
        }
        else {
            int ret = 0;
            int size = a.to_int();
            PlLvalue v__ref = PlV.Scalar_ARG;
            PlObject v__val = v__ref.get();
            for (int i = 0; i < size; i++) {
                v__ref.set(a.aget(i));
                ret += c.apply(PlCx.LIST, new PlArray()).length_of_array_int();
            }
            v__ref.set(v__val);
            return new PlInt(ret);
        }
    }
    public static final PlObject sort(PlClosure c, PlArray a, PlArray list__, int wantarray) {
        String pkg = c.pkg_name;
        PlArray ret = new PlArray(a);
        PlLvalue v_a_ref = (PlLvalue)PlV.sget(pkg + "::a");
        PlLvalue v_b_ref = (PlLvalue)PlV.sget(pkg + "::b");
        PerlCompare comp = new PerlCompare(c, v_a_ref, v_b_ref, list__);
        PlObject v_a_val = v_a_ref.get();
        PlObject v_b_val = v_b_ref.get();
        Collections.sort(ret.a, comp);
        v_a_ref.set(v_a_val);
        v_b_ref.set(v_b_val);
        return (wantarray == PlCx.LIST ) ? ret : ret.length_of_array();
    }
    public static final PlObject sort(PlObject c, PlArray a, PlArray list__, int wantarray) {
        if (c.is_coderef()) {
            if (c.is_lvalue()) {
                c = c.get();
            }
            return sort((PlClosure)c, a, list__, wantarray);
        }
        return PlCORE.die("Not implemented: first argument to sort() is not a closure");
    }

    public static PlObject prototype(PlObject arg, String packageName) {
        if (arg.is_coderef()) {
            if (arg.is_lvalue()) {
                arg = arg.get();
            }
            return ((PlClosure)arg).prototype();
        }
        String method = arg.toString();
        PlObject methodCode;
        if (method.indexOf("::") == -1) {
            methodCode = PlV.cget(packageName + "::" + method);
        }
        else {
            // fully qualified name
            methodCode = PlV.cget(method);
        }
        if (methodCode.is_coderef()) {
            return prototype(methodCode, packageName); 
        }
        return PlCx.UNDEF;
    }

    private static int _regex_character_class_escape(int offset, String s, StringBuilder sb, int length, boolean flag_xx,
        StringBuilder rejected)
    {
        // inside [ ... ]
        //      space    becomes: "\ " unless the /xx flag is used (flag_xx)
        //      \120     becomes: \0120 - Java requires octal sequences to start with zero
        //      \0       becomes: \00 - Java requires the extra zero
        //      \b       is rejected, Java doesn't support \b inside [...]
        boolean first = true;
        for ( ; offset < length; ) {
            final int c = s.codePointAt(offset);
            switch (c) {
                case ']':
                    if (first) {
                        sb.append("\\]");
                        break;
                    }
                    else {
                        sb.append(Character.toChars(c));
                        return offset;
                    }
                case '[':
                    sb.append("\\[");
                    break;
                case '\\':  // escape - \[ \120

                    if (offset < length) {
                        if (s.codePointAt(offset + 1) == 'b') {
                            rejected.append("\\b");      // Java doesn't support \b inside [...]
                            offset++;
                            break;
                        }
                    }

                    sb.append(Character.toChars(c));
                    if (offset < length) {
                        offset++;
                        int c2 = s.codePointAt(offset);
                        if (c2 >= '1' && c2 <= '3') {
                            if (offset < length+1) {
                                int off = offset;
                                int c3 = s.codePointAt(off++);
                                int c4 = s.codePointAt(off++);
                                if ((c3 >= '0' && c3 <= '7') && (c4 >= '0' && c4 <= '7')) {
                                    // a \000 octal sequence
                                    sb.append('0');
                                }
                            }
                        }
                        else if (c2 == '0') {
                            // rewrite \0 to \00
                            sb.append('0');
                        }
                        sb.append(Character.toChars(c2));
                    }
                    break;
                case ' ':
                    if (flag_xx) {
                        sb.append(Character.toChars(c));
                    }
                    else {
                        sb.append("\\ ");   // make this space a "token", even inside /x
                    }
                    break;
                default:
                    sb.append(Character.toChars(c));
                    break;
            }
            first = false;
            offset++;
        }
        return offset;
    }
    private static int _regex_skip_comment(int offset, String s, int length) {
        // [ ... ]
        int offset3 = offset;
        for ( ; offset3 < length; ) {
            final int c3 = s.codePointAt(offset3);
            switch (c3) {
                case ')':
                    return offset3;
                case '\\':
                    offset3++;
                    break;
                default:
                    break;
            }
            offset3++;
        }
        return offset;  // possible error - end of comment not found
    }

    // regex escape rules:
    //
    // \[       as-is
    // [xx xx]  becomes: [xx\ xx] - this will make sure space is a token, even when /x modifier is set
    // \120     becomes: \0120 - Java requires octal sequences to start with zero
    // \0       becomes: \00 - Java requires the extra zero
    // (?#...)  inline comment is removed
    // [xx \b xx]  becomes: (?:[xx xx]|\b) - java doesn't support \b as a character
    //
    public static String regex_escape(String s, boolean flag_xx) {
        // escape spaces in character classes
        final int length = s.length();
        StringBuilder sb = new StringBuilder();
        StringBuilder rejected = new StringBuilder();
        for (int offset = 0; offset < length; ) {
            final int c = s.codePointAt(offset);
            switch (c) {
                case '\\':  // escape - \[ \120
                            sb.append(Character.toChars(c));
                            if (offset < length) {
                                offset++;
                                int c2 = s.codePointAt(offset);
                                if (c2 >= '1' && c2 <= '3') {
                                    if (offset < length+1) {
                                        int off = offset;
                                        int c3 = s.codePointAt(off++);
                                        int c4 = s.codePointAt(off++);
                                        if ((c3 >= '0' && c3 <= '7') && (c4 >= '0' && c4 <= '7')) {
                                            // a \000 octal sequence
                                            sb.append('0');
                                        }
                                    }
                                }
                                else if (c2 == '0') {
                                    // rewrite \0 to \00
                                    sb.append('0');
                                }
                                sb.append(Character.toChars(c2));
                            }
                            break;
                case '[':   // character class
                            int len = sb.length();
                            sb.append(Character.toChars(c));
                            offset++;
                            offset = _regex_character_class_escape(offset, s, sb, length, flag_xx, rejected);
                            if (rejected.length() > 0) {
                                // process \b inside character class
                                String subseq;
                                if ((sb.length() - len) == 2) {
                                    subseq = "(?:" + rejected.toString() + ")";
                                }
                                else {
                                    subseq = "(?:" + sb.substring(len) + "|" + rejected.toString() + ")";
                                }
                                // PlCORE.warn(PlCx.VOID, new PlArray(new PlString("Rejected: " + subseq)));
                                rejected.setLength(0);
                                sb.setLength(len);
                                sb.append(subseq);
                            }
                            break;
                case '(':   
                            boolean append = true;
                            if (offset < length - 3) {
                                int c2 = s.codePointAt(offset+1);
                                int c3 = s.codePointAt(offset+2);
                                int c4 = s.codePointAt(offset+3);
                                if (c2 == '?' && c3 == '#') {
                                    // comment (?# ... )
                                    offset = _regex_skip_comment(offset, s, length);
                                    append = false;
                                }
                                else if (c2 == '?' && c3 == '<' &&
                                        ((c4 >= 'A' && c4 <= 'F') || (c4 >= 'a' && c4 <= 'f') || (c4 == '_'))
                                        )
                                {
                                    // named capture (?<one> ... )
                                    // TODO - replace underscore in name
                                    int endName = s.indexOf(">", offset+3);
                                    if (endName > offset) {
                                        String name = s.substring(offset+3, endName);
                                        // PlCORE.say("name [" + name + "]");
                                        name = name.replace("_", "UnderScore"); // See: regex_named_capture()
                                        sb.append("(?<");
                                        sb.append(name);
                                        sb.append(">");
                                        offset = endName;
                                        append = false;
                                    }
                                }
                            }
                            if (append) {
                                sb.append(Character.toChars(c));
                            }
                            break;
                default:    // normal char
                            sb.append(Character.toChars(c));
                            break;
            }
            offset++;
        }
        return sb.toString();
    }

    public static final PlObject set_pos(PlObject vv, PlObject value, PlRegexResult matcher, String str) {
        if (!vv.is_lvalue()) {
            return value;
        }
        PlLvalue var = (PlLvalue)vv;

        if (value.is_undef()) {
            var.pos = null;
            var.regex_zero_length_flag = false;
            return value;
        }

        int pos = value.to_int();

        // check for zero-length match
        int old_pos = var.pos().to_int();

        if (old_pos == pos) {
            // PlCORE.say("zero length match");
            if (var.regex_zero_length_flag) {
                if (matcher.matcher.find()) {
                    matcher.regex_string = str;
                    pos = matcher.matcher.end();

                    // TODO - $&
                    // String cap1 = str.substring(old_pos, pos);
                    // String cap = str.substring(matcher.start(), matcher.end());
                    // PlCORE.say("zero length match [true]: [" + cap + "] ["+ cap1+"] pos=" + pos + " start="+matcher.start() + " end="+matcher.end());

                    var.regex_zero_length_flag = false;
                }
                else {
                    reset_match();
                    var.pos = null;
                    return PlCx.UNDEF;
                }
            }
            else {
                var.regex_zero_length_flag = true;
            }
        }

        // TODO - test that pos < string length
        value = new PlInt(pos);
        var.pos = pos;
        return value;
    }

    // ****** regex variables
    // class PlRegexResult
    //     public Matcher matcher;      // regex captures
    //     public String  regex_string; // last string used in a regex

    public static final PlRegexResult set_match(Matcher m, String s) {
        PlRegexResult match = PlV.regex_result;
        match.matcher = m;
        match.regex_string = s;
        return match;
    }
    public static final void reset_match() {
        PlRegexResult match = PlV.regex_result;
        match.matcher = null;
        match.regex_string = null;
    }
    public static final PlObject regex_var(int var_number) {
        if (var_number == 0) {
            return PlV.sget("main::0");
        }
        Matcher matcher = PlV.regex_result.matcher;
        if (matcher == null || var_number > matcher.groupCount() || var_number < 1) {
            return PlCx.UNDEF;
        }
        String cap = matcher.group(var_number);
        if (cap == null) {
            return PlCx.UNDEF;
        }
        return new PlString(cap);
    }
    public static final PlObject regex_var(String var_name) {
        PlRegexResult match = PlV.regex_result;
        Matcher matcher = match.matcher;
        String str = match.regex_string;
        if (matcher == null || str == null) {
            return PlCx.UNDEF;
        }
        if (var_name.equals("&")) {    // $&
            return new PlString( str.substring(matcher.start(), matcher.end()) );
        }
        if (var_name.equals("`")) {    // $`
            return new PlString( str.substring(0, matcher.start()) );
        }
        if (var_name.equals("'")) {    // $'
            return new PlString( str.substring(matcher.end()) );
        }
        return PlCx.UNDEF;
    }
    public static final PlObject regex_named_capture(String var_name) {
        if (var_name == null) {
            return PlCx.UNDEF;
        }
        Matcher matcher = PlV.regex_result.matcher;
        if (matcher == null) {
            return PlCx.UNDEF;
        }
        try {
            var_name = var_name.replace("_", "UnderScore"); // See: regex_escape()
            String cap = matcher.group(var_name);
            if (cap == null) {
                return PlCx.UNDEF;
            }
            return new PlString(cap);
        } catch (Exception e) {
        }
        return PlCx.UNDEF;
    }

    // ****** end regex variables

    public static final PlObject match(PlObject input, PlRegex pat, int want, boolean global, boolean c_flag) {
        // 'want'    context (PlCx.LIST, PlCx.SCALAR, PlCx.VOID)
        // 'global'  g  - globally match the pattern repeatedly in the string
        // 'c_flag'  c  - keep the current position during repeated matching

        String str = input.toString();
        if (want != PlCx.LIST) {
            Matcher matcher = pat.p.matcher(str);
            if (global) {
                // scalar context, global match
                PlObject pos = input.pos();
                boolean find;
                if (pos.is_undef()) {
                    find = matcher.find();
                }
                else {
                    find = matcher.find(pos.to_int());
                }
                if (find) {
                    PlRegexResult match = set_match(matcher, str);
                    set_pos(input, new PlInt(matcher.end()), match, str);
                    return PlCx.TRUE;
                }
                else {
                    // reset_match();
                    if (!c_flag) {
                        set_pos(input, PlCx.UNDEF, null, null);
                    }
                    return PlCx.FALSE;
                }
            }
            else {
                // scalar context, non-global match
                if (matcher.find()) {
                    set_match(matcher, str);
                    return PlCx.TRUE;
                }
                else {
                    // reset_match();
                    return PlCx.FALSE;
                }
            }
        }
        // list context
        Matcher matcher = pat.p.matcher(str);
        PlArray ret = new PlArray();
        if (global) {
            // list context, global match
            // Note: if there are no captures, then return the matched substrings
            boolean found = false;
            while (matcher.find()) {
                found = true;
                int count = matcher.groupCount();
                if (count > 0) {
                    for (int i = 1; i <= count; i++) {
                        String cap = matcher.group(i);
                        if (cap == null) {
                            ret.push_void(PlCx.UNDEF);
                        }
                        else {
                            ret.push_void(cap);
                        }
                    }
                }
                else {
                    String cap = matcher.group();
                    if (cap == null) {
                        ret.push_void(PlCx.UNDEF);
                    }
                    else {
                        ret.push_void(cap);
                    }
                }
            }
            if (found) {
                set_match(matcher, str);
            }
            else {
                // reset_match();
            }
            set_pos(input, PlCx.UNDEF, null, null);
            return ret;
        }
        else {
            // list context, non-global match
            if (matcher.find()) {
                set_match(matcher, str);
                for (int i = 1; i <= matcher.groupCount(); i++) {
                    String cap = matcher.group(i);
                    if (cap == null) {
                        ret.push_void(PlCx.UNDEF);
                    }
                    else {
                        ret.push_void(cap);
                    }
                }
            }
            else {
                // reset_match();
            }
            return ret;
        }
    }
    public static final PlObject match(PlObject s, PlLvalue pat, int want, boolean global, boolean c_flag) {
        return match(s, pat.get(), want, global, c_flag);
    }
    public static final PlObject match(PlObject s, PlObject pat, int want, boolean global, boolean c_flag) {
        // TODO - cache the compiled pattern
        return match(s, new PlRegex(pat, 0, false), want, global, c_flag);
    }

    public static final PlObject replace(PlLvalue s, PlRegex pat, PlClosure rep, int want, boolean global, boolean replace_flag) {
        String str = s.toString();
        int count = 0;
        Matcher matcher = pat.p.matcher(str);
        if (global) {
            final StringBuilder buf = new StringBuilder(str.length() + 256);
            int pos = 0;
            while (matcher.find()) {
                count++;
                set_match(matcher, str);
                int start = matcher.start();
                int end   = matcher.end();
                String replace = rep.apply_do_block(PlCx.SCALAR, want, new PlArray()).toString();
                if (start > pos) {
                    buf.append( str.substring(pos, start) );
                }
                if (replace.length() > 0) {
                    buf.append( replace );
                }
                pos = end;
            }
            if (count > 0) {
                if (pos <= str.length()) {
                    buf.append( str.substring(pos) );
                }
                if (replace_flag) {
                    s.set(new PlString(buf.toString()));
                }
            }
        }
        else {
            if (matcher.find()) {
                count++;
                set_match(matcher, str);
                int start = matcher.start();
                int end   = matcher.end();
                String replace = rep.apply_do_block(PlCx.SCALAR, want, new PlArray()).toString();
                final StringBuilder buf = new StringBuilder(str.length() + replace.length());
                if (start > 0) {
                    buf.append( str.substring(0, start) );
                }
                if (replace.length() > 0) {
                    buf.append( replace );
                }
                if (end <= str.length()) {
                    buf.append( str.substring(end) );
                }
                if (replace_flag) {
                    s.set(new PlString(buf.toString()));
                }
            }
        }
        if (count == 0) {
            // no match
            return PlCx.FALSE;
        }
        return new PlInt(count);
    }
    public static final PlObject replace(PlLvalue s, PlRegex pat, String replace, int want, boolean global, boolean replace_flag) {
        String str = s.toString();
        int count = 0;
        Matcher matcher = pat.p.matcher(str);
        if (global) {
            final StringBuilder buf = new StringBuilder(str.length() + 256);
            int pos = 0;
            while (matcher.find()) {
                count++;
                set_match(matcher, str);
                int start = matcher.start();
                int end   = matcher.end();
                if (start > pos) {
                    buf.append( str.substring(pos, start) );
                }
                if (replace.length() > 0) {
                    buf.append( replace );
                }
                pos = end;
            }
            if (count > 0) {
                if (pos <= str.length()) {
                    buf.append( str.substring(pos) );
                }
                if (replace_flag) {
                    s.set(new PlString(buf.toString()));
                }
            }
        }
        else {
            if (matcher.find()) {
                count++;
                set_match(matcher, str);
                int start = matcher.start();
                int end   = matcher.end();
                final StringBuilder buf = new StringBuilder(str.length() + replace.length());
                if (start > 0) {
                    buf.append( str.substring(0, start) );
                }
                if (replace.length() > 0) {
                    buf.append( replace );
                }
                if (end <= str.length()) {
                    buf.append( str.substring(end) );
                }
                if (replace_flag) {
                    s.set(new PlString(buf.toString()));
                }
            }
        }
        if (count == 0) {
            // no match
            return PlCx.FALSE;
        }
        return new PlInt(count);
    }

    public static final PlObject replace(PlLvalue s, PlRegex pat, PlObject rep, int want, boolean global, boolean replace_flag) {
        if (rep.is_coderef()) {
            return replace(s, pat, (PlClosure)rep, want, global, replace_flag);
        }
        return replace(s, pat, rep.toString(), want, global, replace_flag);
    }
    public static final PlObject replace(PlObject s, PlObject pat, PlObject rep, int want, boolean global, boolean replace_flag) {
        if (!s.is_lvalue()) {
            if (!replace_flag) {
                PlLvalue lv = new PlLvalue(s);
                return replace(lv, new PlRegex(pat, 0, false), rep, want, global, replace_flag);
            }
            PlCORE.die("Can't modify constant item in substitution (s///)");
        }
        // TODO - cache the compiled pattern
        return replace((PlLvalue)s, new PlRegex(pat, 0, false), rep, want, global, replace_flag);
    }
    public static final PlObject replace(PlObject s, PlObject pat, String rep, int want, boolean global, boolean replace_flag) {
        if (!s.is_lvalue()) {
            if (!replace_flag) {
                PlLvalue lv = new PlLvalue(s);
                return replace(lv, new PlRegex(pat, 0, false), rep, want, global, replace_flag);
            }
            PlCORE.die("Can't modify constant item in substitution (s///)");
        }
        // TODO - cache the compiled pattern
        return replace((PlLvalue)s, new PlRegex(pat, 0, false), rep, want, global, replace_flag);
    }

    // $v =~ tr/xyz/abc/i
    // PerlOp.tr(v_v_100, new PlString("xyz"), new PlString("abc"), "", PlCx.VOID)
    public static final PlObject tr(PlObject pstr, PlObject psearchChars, PlObject preplaceChars, String modifier, int want) {
        String str          = pstr.toString();
        String searchChars  = psearchChars.toString();
        String replaceChars = preplaceChars.toString();
        boolean complement   = modifier.indexOf("c") < 0 ? false : true;  // c = complement
        boolean replace_flag = modifier.indexOf("r") < 0 ? true : false;  // r = replace flag
        int modified = 0;
        final int replaceCharsLength = replaceChars.length();
        final int strLength = str.length();
        final StringBuilder buf = new StringBuilder(strLength);

        if (complement) {
            for (int i = 0; i < strLength; i++) {
                final char ch = str.charAt(i);
                final int index = searchChars.indexOf(ch);
                if (index < 0) {
                    // not found
                    modified++;
                    if (replaceCharsLength > 0) {
                        buf.append(replaceChars.charAt(replaceCharsLength - 1));
                    }
                } else {
                    buf.append(ch);
                }
            }
        }
        else {
            for (int i = 0; i < strLength; i++) {
                final char ch = str.charAt(i);
                final int index = searchChars.indexOf(ch);
                if (index >= 0) {
                    modified++;
                    if (index < replaceCharsLength) {
                        buf.append(replaceChars.charAt(index));
                    }
                } else {
                    buf.append(ch);
                }
            }
        }

        if (modified > 0 && replace_flag) {
            pstr.set(new PlString(buf.toString()));
        }
        return new PlInt(modified);
    }


    // looks_like_number
    private static int _parse_space(String s, int length, int offset) {
        for ( ; offset < length; offset++ ) {
            final int c3 = s.codePointAt(offset);
            switch (c3) {
                case ' ': case '\t': case '\n': case '\r':
                    break;
                default:
                    return offset;
            }
        }
        return offset;
    }
    private static boolean _parse_space_to_end(String s, int length, int offset) {
        for ( ; offset < length; offset++ ) {
            final int c3 = s.codePointAt(offset);
            switch (c3) {
                case ' ': case '\t': case '\n': case '\r':
                    break;
                default:
                    return false;
            }
        }
        return true;
    }
    private static boolean _parse_exp(String s, int length, int offset) {
        // 123.45E^^^
        final int c = s.codePointAt(offset);
        if (c == '+' || c == '-') {
            offset++;
            if (offset >= length) {
                return false;
            }
        }
        for ( ; offset < length; offset++ ) {
            final int c3 = s.codePointAt(offset);
            switch (c3) {
                case '0': case '1': case '2': case '3': case '4':
                case '5': case '6': case '7': case '8': case '9':
                    break;
                default:
                    return _parse_space_to_end(s, length, offset);
            }
        }
        return true;
    }
    private static boolean _parse_dot(String s, int length, int offset) {
        // 123.^^^
        for ( ; offset < length; offset++ ) {
            final int c3 = s.codePointAt(offset);
            switch (c3) {
                case '0': case '1': case '2': case '3': case '4':
                case '5': case '6': case '7': case '8': case '9':
                    break;
                case 'E': case 'e':
                    return _parse_exp(s, length, offset+1);
                default:
                    return _parse_space_to_end(s, length, offset);
            }
        }
        return true;
    }
    private static boolean _parse_int(String s, int length, int offset) {
        // 123
        for ( ; offset < length; offset++ ) {
            final int c3 = s.codePointAt(offset);
            switch (c3) {
                case '0': case '1': case '2': case '3': case '4':
                case '5': case '6': case '7': case '8': case '9':
                    break;
                case '.':
                    return _parse_dot(s, length, offset+1);
                case 'E': case 'e':
                    return _parse_exp(s, length, offset+1);
                default:
                    return _parse_space_to_end(s, length, offset);
            }
        }
        return true;
    }
    public static boolean looks_like_number(String s) {
        final int length = s.length();
        int offset = _parse_space(s, length, 0);
        if (offset >= length) {
            return false;
        }
        int c = s.codePointAt(offset);
        if (c == '+' || c == '-') {
            offset++;
            if (offset >= length) {
                return false;
            }
            c = s.codePointAt(offset);
        }
        switch (c) {
            case 'i': case 'I':
                        return s.substring(offset, offset+3).equalsIgnoreCase("inf");
            case 'n': case 'N':
                        return s.substring(offset, offset+3).equalsIgnoreCase("nan");
            case '.':
                        offset++;
                        if (offset >= length) {
                            return false;
                        }
                        final int c3 = s.codePointAt(offset);
                        switch (c3) {
                            case '0': case '1': case '2': case '3': case '4':
                            case '5': case '6': case '7': case '8': case '9':
                                return _parse_dot(s, length, offset+1);
                        }
            case '0': case '1': case '2': case '3': case '4': case '5': case '6': case '7': case '8': case '9':
                        return _parse_int(s, length, offset+1);
        }
        return false;
    }
    public static boolean looks_like_number(PlObject arg) {
        if (arg.is_num() || arg.is_int()) {
            return true;
        }
        return looks_like_number(arg.toString());
    }
    public static long _parse_oct(String s, int base) {
        try {
            s = s.replace("_","");
            return Long.parseLong(s, base);
        } catch (NumberFormatException n) {
        } catch (Exception e) {
        }
        return 0;
    }
    public static long oct(String s) {
        final int length = s.length();
        int c;

        for (int i = 0; i < length; i++ ) {
            c = s.codePointAt(i);
            if (c > 254) {
                PlCORE.die("Wide character in oct");
            }
        }

        int offset = _parse_space(s, length, 0);
        if (offset >= length) {
            return 0;
        }
        int start = offset;
        c = s.codePointAt(offset);
        if (c == '0') {
            start++;
            offset++;
            if (offset >= length) {
                return 0;
            }
            c = s.codePointAt(offset);
        }
        boolean ul = false;
        switch (c) {
            case 'x': case 'X':
                    start++;
                    offset++;
                    for ( ; offset < length; offset++ ) {
                        c = s.codePointAt(offset);
                        if (c == '_') {
                            if (ul) {
                                return _parse_oct(s.substring(start, offset), 16);
                            }
                            ul = true;
                        }
                        else if ((c >= 'A' && c <= 'F') || (c >= 'a' && c <= 'f') || (c >= '0' && c <= '9')) {
                            ul = false;
                        }
                        else {
                            return _parse_oct(s.substring(start, offset), 16);
                        }
                    }
                    return _parse_oct(s.substring(start, offset), 16);
            case 'b': case 'B':
                    start++;
                    offset++;
                    for ( ; offset < length; offset++ ) {
                        c = s.codePointAt(offset);
                        switch (c) {
                            case '_':
                                if (ul) {
                                    return _parse_oct(s.substring(start, offset), 2);
                                }
                                ul = true;
                                break;
                            case '0': case '1':
                                ul = false;
                                break;
                            default:
                                return _parse_oct(s.substring(start, offset), 2);
                        }
                    }
                    return _parse_oct(s.substring(start, offset), 2);
            case '0': case '1': case '2': case '3': case '4':
            case '5': case '6': case '7': case '_':
                    for ( ; offset < length; offset++ ) {
                        c = s.codePointAt(offset);
                        switch (c) {
                            case '_':
                                if (ul) {
                                    return _parse_oct(s.substring(start, offset), 8);
                                }
                                ul = true;
                                break;
                            case '0': case '1': case '2': case '3': case '4':
                            case '5': case '6': case '7':
                                ul = false;
                                break;
                            default:
                                return _parse_oct(s.substring(start, offset), 8);
                        }
                    }
                    return _parse_oct(s.substring(start, offset), 8);
        }
        return 0;
    }

}

EOT
    ,   # list break
<<'EOT'

class PlV {
    // PlV implements namespaces and global variables
    //
    // TODO - import CORE subroutines in new namespaces, if needed

    public static PlRegexResult regex_result = new PlRegexResult();
    public static Path path;
    public static PlFileHandle STDIN  = (PlFileHandle)PlStringConstant.getConstant("main::STDIN").fileRef.o;
    public static PlFileHandle STDOUT = (PlFileHandle)PlStringConstant.getConstant("main::STDOUT").fileRef.o;
    public static PlFileHandle STDERR = (PlFileHandle)PlStringConstant.getConstant("main::STDERR").fileRef.o;

    // initialize special variables like $_ $\
EOT
    , (( map {
                my $java_name = $Perlito5::Java::special_scalar{$_};
                my $index     = $special_var_index{$_}[0];
                my $class     = $special_var_index{$_}[1];
"
    public static $class $java_name = new $class();    // \$$_
"
            }
            sort keys %Perlito5::Java::special_scalar
      ))
    , <<'EOT'

    public static PlObject boolean_stack;
    public static PlArray local_stack = new PlArray();
    public static Random random = new Random();
    public static String lastStat = null;

    public static final void init(String[] args) {
        // @ARGV
        PlV.array_set("main::ARGV", new PlArray(args));               // args is String[]
        // %ENV
        PlV.hash_set("main::ENV",   new PlArray(System.getenv()));    // env  is Map<String, String>
        // $" = " "
        PlV.sset("main::" + (char)34, new PlString(" "));
        // $^O = "Unix"; default = "perlito5"
        PlV.sset("main::" + (char)15, new PlString( System.getProperty("os.name", "perlito5") ));
        // $/ = "\n"
        PlV.sset("main::/", new PlString( System.getProperty("line.separator", "\n") ));
        // $; = \034
        PlV.sset("main::;", new PlString((char)28));
        // $^T = time at start
        PlV.sset("main::" + (char)20, PlCORE.time(PlCx.SCALAR, new PlArray()));

        PlV.STDIN.inputStream   = System.in;
        PlV.STDIN.reader        = new BufferedReader(new InputStreamReader(System.in));
        PlV.STDIN.eof           = false;
        PlV.STDIN.typeglob_name = "main::STDIN";
        PlV.STDIN.charset       = "UTF-8";
        PlFileHandle.allOpenFiles.add(PlV.STDIN);

        PlV.STDOUT.outputStream = System.out;
        PlV.STDOUT.typeglob_name = "main::STDOUT";
        PlV.STDOUT.charset       = "UTF-8";
        PlFileHandle.allOpenFiles.add(PlV.STDOUT);

        PlV.STDERR.outputStream = System.err;
        PlV.STDERR.typeglob_name = "main::STDERR";
        PlV.STDERR.charset       = "UTF-8";
        PlFileHandle.allOpenFiles.add(PlV.STDERR);

        try {
            PlV.path = Paths.get(".").toRealPath();
        }
        catch (IOException e) {
            // don't know what to do
        }

        PlV.fset("main::STDIN",  PlV.STDIN);                             // "GLOB"
        PlV.fset("main::STDOUT", PlV.STDOUT);
        PlV.fset("main::STDERR", PlV.STDERR);

        PlV.cset("UNIVERSAL::can", new PlClosure(PlCx.UNDEF, new PlObject[]{  }, "UNIVERSAL", true) {
            public PlObject apply(int want, PlArray List__) {
                PlObject self = List__.shift();
                String method_name = List__.shift().toString();
                PlClass bless = self.blessed_class();
                if ( bless != null ) {
                    PlObject methodCode = bless.method_lookup(method_name, 0);
                    if (methodCode.is_coderef()) {
                        return methodCode;
                    }
                    return PlCx.UNDEF;
                }

                // calling can() as a class method
                PlObject methodCode = PlClass.getInstance(self).method_lookup(method_name, 0);
                if (methodCode.is_coderef()) {
                    return methodCode;
                }

                return PlCx.UNDEF;
            }
        });
        PlV.cset("UNIVERSAL::isa", new PlClosure(PlCx.UNDEF, new PlObject[]{  }, "UNIVERSAL", true) {
            public PlObject apply(int want, PlArray List__) {
                PlObject self = List__.shift();
                String class_name = List__.shift().toString();
                PlClass bless = self.blessed_class();
                if ( bless != null ) {
                    return bless.isa(class_name, 0);
                }

                // reftype == "ARRAY"
                if (self.reftype().toString().equals(class_name)) {
                    return PlCx.INT1;
                }

                // calling isa() as a class method
                bless = PlClass.getInstance(self);
                if ( bless != null ) {
                    return bless.isa(class_name, 0);
                }

                return PlCx.UNDEF;
            }
        });

        PerlOp.reset_match();
    }
    public static final void teardown() {

        // TODO - catch error in END
        // Perlito5::set_global_phase("END");
        // eval {
        //     $_->() for @Perlito5::END_BLOCK;
        //     1;
        // }
        // or warn "$@\nEND failed--call queue aborted.\n"

        // Perlito5::set_global_phase("END");
        PlV.sset("main::" + (char)7 + "LOBAL_PHASE", new PlStringConstant("END"));

        // $_->() for @Perlito5::END_BLOCK;
        for (PlObject tmp : PlArray.construct_list_of_aliases(PlV.array_get("Perlito5::END_BLOCK"))) {
            tmp.apply(PlCx.VOID, new PlArray());
        }

        PlFileHandle.close_all_files();
    }

    // scalar
    public static final PlLvalue sget(String name) {
        return PlStringConstant.getConstant(name).scalarRef;
    }
    public static final PlLvalue sget_local(String name) {
        return (PlLvalue)PerlOp.push_local_scalar(PlCx.UNDEF, name);
    }
    public static final PlObject sset(String name, PlObject v) {
        return PlStringConstant.getConstant(name).scalarRef.set(v);
    }
    public static final PlObject sset(String name, Object o) {
        return PlStringConstant.getConstant(name).scalarRef.set(PlJavaObject.fromObject(o));
    }
    public static final PlObject sset_local(String name, PlObject v) {
        return PerlOp.push_local_scalar(v, name);
    }
    public static final void sset_alias(String name, PlLvalue v) {
        PlStringConstant.getConstant(name).scalarRef = v;
    }

    // accessors for special variables like $_ $\
EOT
    , (( map {
                my $java_name = $Perlito5::Java::special_scalar{$_};
                my $index     = $special_var_index{$_}[0];
                my $class     = $special_var_index{$_}[1];
"
    public static final PlLvalue sget_local_${java_name}() {
        PerlOp.push_local_special_var_${java_name}();
        return ${java_name};
    }
    public static final PlObject sset_local_${java_name}(PlObject v) {
        PerlOp.push_local_special_var_${java_name}();
        return ${java_name}.set(v);
    }
    public static final void sset_alias_${java_name}(${class} v) {
        ${java_name} = v;
    }
"
            }
            sort keys %Perlito5::Java::special_scalar
      ))
    , <<'EOT'

    public static final PlLvalue cget(String name) {
        // this implements " \&name "
        PlLvalue code = PlStringConstant.getConstant(name).codeRef;
        if ( code.is_coderef() ) {
            return code;
        }
        int pos = name.lastIndexOf("::");
        if (pos == -1) {
            return code;
        }
        String namespace = name.substring(0, pos);
        PlLvalue autoload = PlV.cget_no_autoload(namespace + "::AUTOLOAD");
        if ( autoload.is_coderef() ) {
            PlV.sset(namespace + "::AUTOLOAD", new PlString(name));
            return autoload;
        }
        return code;
    }
    public static final PlLvalue cget_local(String name) {
        return (PlLvalue)PerlOp.push_local_named_sub(PlCx.UNDEF, name);
    }
    public static final PlLvalue cget_no_autoload(String name) {
        return PlStringConstant.getConstant(name).codeRef;
    }
    public static final PlObject cset(String name, PlObject v) {
        return PlStringConstant.getConstant(name).cset(v);
    }
    public static final PlObject cset_local(String name, PlObject v) {
        return PerlOp.push_local_named_sub(v, name);
    }
    public static final void cset_alias(String name, PlLvalue v) {
        PlStringConstant.getConstant(name).cset_alias(v);
    }

    // hash
    public static final PlHash hash_get(String name) {
        return PlStringConstant.getConstant(name).hashRef.hash_deref_strict();
    }
    public static final PlHash hash_get_local(String name) {
        PlLvalue o = (PlLvalue)PerlOp.push_local_hash(new PlHashRef(), name);
        return o.hash_deref_strict();
    }
    public static final PlObject hash_set(String name, PlObject v) {
        PlLvalue o = PlStringConstant.getConstant(name).hashRef;
        return o.hash_deref_set(v);
    }
    public static final PlObject hash_set_local(String name, PlObject v) {
        PlLvalue o = (PlLvalue)PerlOp.push_local_hash(new PlHashRef(), name);
        return o.hash_deref_set(v);
    }
    public static final PlLvalue hget(String name) {
        return PlStringConstant.getConstant(name).hashRef;
    }
    public static final PlLvalue hget_local(String name) {
        return (PlLvalue)PerlOp.push_local_hash(new PlHashRef(), name);
    }
    public static final PlObject hset(String name, PlObject v) {
        return PlStringConstant.getConstant(name).hashRef.set(v);
    }
    public static final PlObject hset(String name, PlLvalue v) {
        return PlStringConstant.getConstant(name).hashRef.set(v);
    }
    public static final PlObject hset_local(String name, PlObject v) {
        return (PlLvalue)PerlOp.push_local_hash(v, name);
    }
    public static final void hset_alias(String name, PlHash v) {
        PlStringConstant.getConstant(name).hashRef = new PlLvalue(v);
    }

    // array
    public static final PlArray array_get(String name) {
        return PlStringConstant.getConstant(name).arrayRef.array_deref_strict();
    }
    public static final PlArray array_get_local(String name) {
        PlLvalue o = (PlLvalue)PerlOp.push_local_array(new PlArrayRef(), name);
        return o.array_deref_strict();
    }
    public static final PlObject array_set(String name, PlObject v) {
        PlLvalue o = PlStringConstant.getConstant(name).arrayRef;
        return o.array_deref_set(v);
    }
    public static final PlObject array_set_local(String name, PlObject v) {
        PlLvalue o = (PlLvalue)PerlOp.push_local_array(new PlArrayRef(), name);
        return o.array_deref_set(v);
    }
    public static final PlLvalue aget(String name) {
        return PlStringConstant.getConstant(name).arrayRef;
    }
    public static final PlLvalue aget_local(String name) {
        return (PlLvalue)PerlOp.push_local_array(new PlArrayRef(), name);
    }
    public static final PlObject aset(String name, PlObject v) {
        return PlStringConstant.getConstant(name).arrayRef.array_deref_set(v);
    }
    public static final PlObject aset_local(String name, PlObject v) {
        return (PlLvalue)PerlOp.push_local_array(v, name);
    }
    public static final void aset_alias(String name, PlArray v) {
        PlStringConstant.getConstant(name).arrayRef = new PlLvalue(v);
    }

    // filehandle
    public static final PlLvalue fget(String name) {
        return PlStringConstant.getConstant(name).fileRef;
    }
    public static final PlLvalue fget_local(String name) {
        return (PlLvalue)PerlOp.push_local_array(new PlFileHandle(name), name);
    }
    public static final PlObject fset(String name, PlObject v) {
        return PlStringConstant.getConstant(name).fileRef.set(v);
    }
    public static final PlObject fset_local(String name, PlObject v) {
        return (PlLvalue)PerlOp.push_local_array(v, name);
    }

    // code
    public static final PlObject code_lookup_by_name(String nameSpace, PlObject name) {
        if (name.is_coderef()) {
            return name;
        }
        if (name.is_bool() && name.to_boolean()) {
            // RT #63790:  calling PL_sv_yes as a sub is special-cased to silently
            // return (so Foo->import() silently fails if import() doesn't exist),
            return name;
        }
        String s = name.toString();
        if (s.indexOf("::") == -1) {
            s = nameSpace + "::" + s;
        }
        return PlV.cget(s);
    }
    public static final PlObject code_lookup_by_name_no_autoload(String nameSpace, PlObject name) {
        if (name.is_coderef()) {
            return name;
        }
        String s = name.toString();
        if (s.indexOf("::") == -1) {
            s = nameSpace + "::" + s;
        }
        return PlV.cget_no_autoload(s);
    }

    // glob
    public static final PlObject glob_set(PlObject name, PlObject value, String nameSpace) {
        return glob_set(name.toString(), value, nameSpace);
    }
    public static final PlObject glob_set(String name, PlObject value, String nameSpace) {
        if (value.is_lvalue()) {
            value = value.get();
        }
        if (value.is_coderef()) {
            PlV.cset(name, value);
        }
        else if (value.is_hashref()) {
            PlV.hset(name, value);
        }
        else if (value.is_arrayref()) {
            PlStringConstant.getConstant(name).arrayRef.set(value);
        }
        else if (value.is_scalarref()) {
            PlV.sset(name, value.scalar_deref(nameSpace));
        }
        else if (value.is_typeglobref()) {
            // *x = \*y
            PlGlobRef gl = (PlGlobRef)value;
            return glob_set(name, gl.filehandle, nameSpace);
        }
        else if (value.is_filehandle()) {
            // *x = *y
            PlFileHandle fh = (PlFileHandle)value;
            String typeglob_name = fh.typeglob_name;
            if (typeglob_name == null) {
                PlCORE.die("not implemented assign anonymous typeglob to typeglob");
            }
            return glob_set(name, new PlString(typeglob_name), nameSpace);
        }
        else if (!value.is_ref()) {
            String typeglob_name = value.toString();
            if (typeglob_name.indexOf("::") == -1) {
                typeglob_name = nameSpace + "::" + typeglob_name;
            }
            // TODO - share lvalue containers (alias)
            PlV.fset(name, PlV.fget(typeglob_name));
            PlV.cset_alias(name, PlV.cget(typeglob_name));
            PlV.sset_alias(name, PlV.sget(typeglob_name));
            PlV.aset(name, PlV.aget(typeglob_name));
            PlV.hset(name, PlV.hget(typeglob_name));
        }
        else {
            PlCORE.die("not implemented assign " + value.ref() + " to typeglob");
        }
        return value;
    }
    public static final PlObject glob_set_local(PlString name, PlObject value, String nameSpace) {
        return glob_set_local(name.toString(), value, nameSpace);
    }
    public static final PlObject glob_set_local(String name, PlObject value, String nameSpace) {
        if (value.is_coderef()) {
            PlV.cset_local(name, value);
        }
        else if (value.is_hashref()) {
            PlV.hset_local(name, value);
        }
        else if (value.is_arrayref()) {
            PlV.aset_local(name, value);
        }
        else if (value.is_scalarref()) {
            PlV.sset_local(name, value);
        }
        else if (value.is_typeglobref()) {
            // local *x = \*y
            PlGlobRef gl = (PlGlobRef)value;
            return glob_set_local(name, gl.filehandle, nameSpace);
        }
        else if (value.is_filehandle()) {
            // local *x = *y
            PlFileHandle fh = (PlFileHandle)value;
            String typeglob_name = fh.typeglob_name;
            if (typeglob_name == null) {
                PlCORE.die("not implemented assign anonymous typeglob to typeglob");
            }
            return glob_set_local(name, new PlString(typeglob_name), nameSpace);
        }
        else if (!value.is_ref()) {
            String typeglob_name = value.toString();
            if (typeglob_name.indexOf("::") == -1) {
                typeglob_name = nameSpace + "::" + typeglob_name;
            }
            // TODO - share lvalue containers (alias)
            PlV.fset_local(name, PlV.fget(typeglob_name));
            PlV.cset_local(name, PlCx.UNDEF);
            PlV.cset_alias(name, PlV.cget(typeglob_name));
            PlV.sset_local(name, PlCx.UNDEF);
            PlV.sset_alias(name, PlV.sget(typeglob_name));
            PlV.aset_local(name, PlV.aget(typeglob_name));
            PlV.hset_local(name, PlV.hget(typeglob_name));
        }
        else {
            PlCORE.die("not implemented assign " + value.ref() + " to typeglob");
        }
        return value;
    }
    public static final PlObject make_reference(PlObject value) {
        if (value.is_filehandle()) {
            return new PlGlobRef(value);
        }
        return new PlLvalueRef(value);
    }
    public static final PlObject make_reference(PlLvalue value) {
        if (value.is_filehandle()) {
            return new PlGlobRef(value);
        }
        return new PlLvalueRef(value);
    }

}
class PlObject implements Cloneable, Iterable<PlObject> {
    public static final String REF_str = new String("");
    public static final PlStringConstant REF = new PlStringConstant(REF_str);

    public Iterator<PlObject> iterator() {
        // if (this.is_array()) {
        //     return ((PlArray)this).iterator();
        // }
        // if (this.is_hash()) {
        //     return ((PlHash)this).iterator();
        // }
        // if (this.is_lvalue()) {
        //     return ((PlLvalue)this).iterator();
        // }
        return new PlLvalueIterator(new PlROvalue(this)); 
    }

    public PlObject() {
    }
EOT
        # add interfaces to Java classes
        # that were declared with
        #
        #   package MyJavaClass { Java }
        #
    , (( map {
                    my $class = $java_classes{$_};
                    my $java_class_name = $class->{java_type};
                    my $perl_to_java = $class->{perl_to_java};
                    $class->{import} || $class->{extends} || $class->{implements} ? 
                    "    public ${java_class_name} ${perl_to_java}() {\n"
                  . "        PlCORE.die(\"error .${perl_to_java}!\");\n"
                  . "        return null;\n"
                  . "    }\n" : ()
            }
            grep { $java_classes{$_}{perl_to_java} }
            sort keys %java_classes
      ))
    , <<'EOT'
    // public String toString() {
    //     return this.toString();
    // }
    public PerlArgumentLookupResult castToClass(ArrayList<Class[]> params, int pos) {
        // want String
        for (Class[] cl : params) {
            if (cl[pos].equals( "".getClass() )) {
                return new PerlArgumentLookupResult( this.toString(), cl[pos] );
            }
        }
        // want int
        for (Class[] cl : params) {
            if (cl[pos].equals( java.lang.Integer.TYPE )) {
                return new PerlArgumentLookupResult( this.to_int(), cl[pos] );
            }
        }
        // want long
        for (Class[] cl : params) {
            if (cl[pos].equals( java.lang.Long.TYPE )) {
                return new PerlArgumentLookupResult( this.to_long(), cl[pos] );
            }
        }
        // want boolean
        for (Class[] cl : params) {
            if (cl[pos].equals( java.lang.Boolean.TYPE )) {
                return new PerlArgumentLookupResult( this.to_boolean(), cl[pos] );
            }
        }
        // want double
        for (Class[] cl : params) {
            if (cl[pos].equals( java.lang.Double.TYPE )) {
                return new PerlArgumentLookupResult( this.to_double(), cl[pos] );
            }
        }
        // want float
        for (Class[] cl : params) {
            if (cl[pos].equals( java.lang.Float.TYPE )) {
                return new PerlArgumentLookupResult( this.to_float(), cl[pos] );
            }
        }
        // want array
        for (Class[] cl : params) {
            if (cl[pos].isArray() && pos == (cl.length - 1)) {
                // varargs
                return new PerlArgumentLookupResult( null, cl[pos] );
            }
        }

        // default: return the Perl class
        return new PerlArgumentLookupResult( this, this.getClass() );
    }
    public int to_int() {
        long v = this.to_long();
        if (v > Integer.MAX_VALUE || v < Integer.MIN_VALUE) {
            PlCORE.die("numeric overflow converting to int");
        }
        return (int)v;
    }
    public byte to_byte() {
        long v = this.to_long();
        if (v > Byte.MAX_VALUE || v < Byte.MIN_VALUE) {
            PlCORE.die("numeric overflow converting to byte");
        }
        return (byte)v;
    }
    public short to_short() {
        long v = this.to_long();
        if (v > Short.MAX_VALUE || v < Short.MIN_VALUE) {
            PlCORE.die("numeric overflow converting to short");
        }
        return (short)v;
    }
    public float to_float() {
        double v = this.to_double();
        if (v > Float.MAX_VALUE || v < Float.MIN_VALUE) {
            PlCORE.die("numeric overflow converting to float");
        }
        return (float)v;
    }
    public long to_long() {
        return 0;
    }
    public double to_double() {
        return 0.0;
    }
    public boolean to_boolean() {
        return false;
    }
    public PlObject to_num() {
        return PlCx.INT0;
    }
    public char to_char() {
        return (char)(this.to_int());
    }
    public PlObject pos() {
        return PlCx.UNDEF;
    }
    public PlObject set_pos(PlObject value) {
        return PlCORE.die("Can't modify constant item in match position");
    }

    public PlObject end_of_array_index() {
        return PlCORE.die("Not an ARRAY reference");
    }
    public PlObject set_end_of_array_index(PlObject o) {
        return PlCORE.die("Not an ARRAY reference");
    }
    public PlObject apply(int want, PlArray List__) {
        // $ perl -e ' $a = 5; $a->() '
        // Undefined subroutine &main::5 called
        String name = this.toString();
        PlObject code = PlStringConstant.getConstant(name).codeRef;
        if ( code.is_coderef() ) {
            return code.apply(want, List__);
        }
        int pos = name.lastIndexOf("::");
        if (pos != -1) {
            String namespace = name.substring(0, pos);
            PlLvalue autoload = PlV.cget_no_autoload(namespace + "::AUTOLOAD");
            if ( autoload.is_coderef() ) {
                PlV.sset(namespace + "::AUTOLOAD", new PlString(name));
                return autoload.apply(want, List__);
            }
        }
        return PlCORE.die("Undefined subroutine &" + name + " called");
    }

    public PlScalarImmutable length() {
        return new PlInt(this.toString().length());
    }
    public PlObject get_arrayref() {
        return PlCORE.die("Not an ARRAY reference");
    }

    public PlObject shift() {
        return PlCORE.die("Not an ARRAY reference");
    }

    public PlObject get_hashref() {
        return PlCORE.die("Not a HASH reference");
    }

    public PlObject hget_scalarref(String i) {
        PlCORE.die("Not a SCALAR reference");
        return this;
    }
    public PlObject scalar_deref_lvalue(String namespace) {
        return PlCORE.die("Not a SCALAR reference");
    }
    public PlObject scalar_deref(String namespace) {
        return PlCORE.die("Not a SCALAR reference");
    }
    public PlObject scalar_deref_strict() {
        return PlCORE.die("Not a SCALAR reference");
    }
    public PlObject scalar_deref_set(String namespace, PlObject v) {
        return PlCORE.die("Not a SCALAR reference");
    }
    public PlObject aget_list_of_aliases(int want, PlArray a) {
        if (this.is_array()) {
            return ((PlArray)this).aget_list_of_aliases(want, a);
        }
        return PlCORE.die("Not an ARRAY");
    }
    public PlObject aget_lvalue(int i) {
        return PlCORE.die("Not an ARRAY reference");
    }
    public PlObject aget_scalarref(int i) {
        PlCORE.die("Not a SCALAR reference");
        return this;
    }

    public PlArray array_deref_lvalue() {
        PlCORE.die("Not an ARRAY reference");
        return (PlArray)this;
    }
    public PlArray array_deref(String namespace) {
        PlCORE.die("Not an ARRAY reference");
        return (PlArray)this;
    }
    public PlArray array_deref_strict() {
        PlCORE.die("Not an ARRAY reference");
        return (PlArray)this;
    }
    public PlObject array_deref_set(PlObject i) {
        PlCORE.die("Not an ARRAY reference");
        return this;
    }

    public PlObject hget_arrayref(String i) {
        PlCORE.die("Not a HASH reference");
        return this;
    }
    public PlObject hget_hashref(String i) {
        PlCORE.die("Not a HASH reference");
        return this;
    }

    public PlObject aget_arrayref(int i) {
        PlCORE.die("Not an ARRAY reference");
        return this;
    }
    public PlObject aget_hashref(int i) {
        PlCORE.die("Not an ARRAY reference");
        return this;
    }

    public PlObject hash_deref(String namespace) {
        PlCORE.die("Not a HASH reference");
        return this;
    }
    public PlHash hash_deref_strict() {
        PlCORE.die("Not a HASH reference");
        return (PlHash)this;
    }
    public PlObject hash_deref_set(PlObject i) {
        PlCORE.die("Not a HASH reference");
        return this;
    }

    public PlObject hget(String i) {
        PlCORE.die("Not a HASH reference");
        return this;
    }
    public PlObject hget_lvalue(String i) {
        PlCORE.die("Not a HASH reference");
        return this;
    }
    public PlObject hget_lvalue_local(String i) {
        PlCORE.die("Not a HASH reference");
        return this;
    }

    public PlObject hset(String s, PlObject v) {
        PlCORE.die("Not a HASH reference");
        return this;
    }
    public PlObject hset(String s, PlLvalue v) {
        PlCORE.die("Not a HASH reference");
        return this;
    }

    public PlObject aget(int i) {
        PlCORE.die("Not an ARRAY reference");
        return this;
    }
    public PlObject aset(int i, PlObject v) {
        PlCORE.die("Not an ARRAY reference");
        return this;
    }

    public PlObject to_array() {
        PlCORE.die("Not an ARRAY reference");
        return this;
    }
    public PlScalarImmutable length_of_array() {
        PlCORE.die("Not an ARRAY reference");
        return PlCx.UNDEF;
    }
    public boolean length_of_array_boolean() {
        PlCORE.die("Not an ARRAY reference");
        return false;
    }
    public int length_of_array_int() {
        return 1;
    }
    public PlObject values() {
        PlCORE.die("Type of argument to values on reference must be unblessed hashref or arrayref");
        return this;
    }
    public PlObject keys() {
        PlCORE.die("Type of argument to keys on reference must be unblessed hashref or arrayref");
        return this;
    }
    public PlObject each() {
        PlCORE.die("Type of argument to each on reference must be unblessed hashref or arrayref");
        return this;
    }
    public PlObject aexists(PlObject i) {
        PlCORE.die("exists argument is not a HASH or ARRAY element or a subroutine");
        return this;
    }
    public PlObject hexists(String i) {
        PlCORE.die("exists argument is not a HASH or ARRAY element or a subroutine");
        return this;
    }
    public PlObject hexists(PlObject i) {
        return this.hexists(i.toString());
    }
    public PlObject adelete(int want, PlObject i) {
        PlCORE.die("delete argument is not a HASH or ARRAY element or slice");
        return this;
    }
    public PlObject hdelete(int want, PlObject i) {
        PlCORE.die("delete argument is not a HASH or ARRAY element or slice");
        return this;
    }
    public PlObject set(PlObject o) {
        PlCORE.die("Modification of a read-only value attempted");
        return this;
    }
    public PlObject vecSet(PlObject pOffset, PlObject pBits, PlObject pValue) {
        PlCORE.die("Can't modify constant item in scalar assignment");
        return this;
    }
    public PlObject vec(PlObject pOffset, PlObject pBits) {
        // vec($i,  0, 32)
        String sb  = this.toString();
        int offset = pOffset.to_int();
        if (offset < 0) {
            return PlCORE.die("Negative offset to vec in lvalue context: " + offset);
        }
        int bits   = pBits.to_int();
        if (bits == 1) {
            int byteOfs = offset / 8;
            int bitOfs  = offset - 8 * byteOfs;
            long mask = 0b0001;
            if (byteOfs < sb.length()) {
                return new PlInt((sb.charAt(byteOfs) >> bitOfs) & mask);
            }
            else {
                return PlCx.INT0;
            }
        }
        if (bits == 2) {
            int byteOfs = offset / 4;
            int bitOfs  = 2 * (offset - 4 * byteOfs);
            long mask = 0b0011;
            if (byteOfs < sb.length()) {
                return new PlInt((sb.charAt(byteOfs) >> bitOfs) & mask);
            }
            else {
                return PlCx.INT0;
            }
        }
        if (bits == 4) {
            int byteOfs = offset / 2;
            int bitOfs  = 4 * (offset - 2 * byteOfs);
            long mask = 0b1111;
            if (byteOfs < sb.length()) {
                return new PlInt((sb.charAt(byteOfs) >> bitOfs) & mask);
            }
            else {
                return PlCx.INT0;
            }
        }
        if (bits == 8) {
            if (offset < sb.length()) {
                return new PlInt(sb.charAt(offset) & 0xFF);
            }
            else {
                return PlCx.INT0;
            }
        }
        if (bits == 16) {
            long b0 = offset < sb.length() ? (sb.charAt(offset) & 0xFF) << 8 : 0;
            offset++;
            long b1 = offset < sb.length() ? sb.charAt(offset) & 0xFF : 0;
            long res = b0 + b1;
            if (res < 0) {
                res = 4294967296L + res;
            }
            return new PlInt(res);
        }
        if (bits == 32) {
            long b0 = offset < sb.length() ? (sb.charAt(offset) & 0xFF) << 24 : 0;
            offset++;
            long b1 = offset < sb.length() ? (sb.charAt(offset) & 0xFF) << 16 : 0;
            offset++;
            long b2 = offset < sb.length() ? (sb.charAt(offset) & 0xFF) << 8  : 0;
            offset++;
            long b3 = offset < sb.length() ? sb.charAt(offset) & 0xFF : 0;
            long res = b0 + b1 + b2 + b3;
            if (res < 0) {
                res = 4294967296L + res;
            }
            return new PlInt(res);
        }
        return PlCORE.die("Illegal number of bits in vec: " + bits);
    }
    public PlScalarImmutable get() {
        return (PlScalarImmutable)this;
    }
    public PlObject mod(PlObject o) {
        return this.to_num().mod(o);
    }

EOT
    , ((map {
            my $op = $_;
"    public boolean $op() {
        return false;
    }
"
            }
            sort @boolean_unary ))

    , <<'EOT'

    public boolean is_JavaObject() {
        return false;
    }
    public Object toJava() {
        return this;
    }
 
    public boolean is_hash() {
        return false;
    }
    public boolean is_slice() {
        return false;
    }
    public boolean is_array() {
        return false;
    }
    public boolean is_lvalue() {
        return false;
    }
    public boolean is_regex_result() {
        return false;
    }
    public boolean is_integer_range() {
        return new PlDouble(this.to_double()).is_integer_range();
    }
    public PlObject tie(PlArray args) {
        if (this.is_lvalue()) {
            return ((PlLvalue)this).tie(args);
        }
        return PlCORE.die("Can't modify constant item in tie");
    }
    public PlString ref() {
        return REF;
    }
    public String ref_str() {
        return REF_str;
    }
    public boolean ref_boolean() {
        return false;
    }
    public PlObject refaddr() {
        // Scalar::Util::refaddr()
        return PlCx.UNDEF;
    }
    public PlObject reftype() {
        // Scalar::Util::reftype()
        return PlCx.UNDEF;
    }
    public PlObject refstring() {
        if (this.is_ref()) {
            StringBuilder sb = new StringBuilder();
            PlClass bless = this.blessed_class();
            if ( bless != null ) {
                sb.append(this.ref_str());
                sb.append("=");
            }
            sb.append(this.reftype().toString());
            sb.append("(0x");
            sb.append(Integer.toHexString(this.refaddr().to_int()));
            sb.append(")");
            return new PlString(sb.toString());
        }
        return PlCx.EMPTY;
    }
    public PlObject blessed() {
        // Scalar::Util::blessed()
        return PlCx.UNDEF;
    }
    public PlObject tied() {
        return PlCx.UNDEF;
    }
    public PlObject _decr() {
        // --$x
        return PlCx.MIN1;
    }
    public PlObject _incr() {
        // ++$x
        return PlCx.INT1;
    }

    public PlObject op_int() {
        return new PlInt(this.to_long());
    }
    public PlObject neg() {
        return new PlInt(-this.to_long());
    }
    public PlObject complement() {
        long v = this.to_long();
        return new PlInt(v < 0 ? ~v : 4294967295L - v);
    }
    public PlObject str_complement() {
        return PlCORE.die("~. not implemented");
    }
    public PlObject abs() {
        long c = this.to_long();
        return new PlInt(c < 0 ? -c : c);
    }

    public PlObject sqrt() { return new PlDouble(Math.sqrt(this.to_double())); }
    public PlObject cos()  { return new PlDouble(Math.cos(this.to_double())); }
    public PlObject sin()  { return new PlDouble(Math.sin(this.to_double())); }
    public PlObject exp()  { return new PlDouble(Math.exp(this.to_double())); }
    public PlObject log()  { return new PlDouble(Math.log(this.to_double())); }
    public PlObject pow(PlObject arg)    { return new PlDouble(Math.pow(this.to_double(), arg.to_double()));   }
    public PlObject atan2(PlObject arg)  { return new PlDouble(Math.atan2(this.to_double(), arg.to_double())); }

    public PlObject pre_decr() {
        // --$x
        PlCORE.die("Can't modify constant item in predecrement (--)");
        return this;
    }
    public PlObject post_decr() {
        // $x--
        PlCORE.die("Can't modify constant item in postdecrement (--)");
        return this;
    }
    public PlObject pre_incr() {
        // ++$x
        PlCORE.die("Can't modify constant item in preincrement (++)");
        return this;
    }
    public PlObject post_incr() {
        // $x++
        PlCORE.die("Can't modify constant item in postincrement (++)");
        return this;
    }

    public PlObject lcfirst() {
        String s = this.toString();
        int len = s.length();
        if (len == 0) {
            return new PlString(s);
        }
        if (len == 1) {
            return new PlString(s.toLowerCase());
        }
        return new PlString( s.substring(0,1).toLowerCase() + s.substring(1) );
    }
    public PlObject ucfirst() {
        String s = this.toString();
        int len = s.length();
        if (len == 0) {
            return new PlString(s);
        }
        if (len == 1) {
            return new PlString(s.toUpperCase());
        }
        return new PlString( s.substring(0,1).toUpperCase() + s.substring(1) );
    }
    public PlObject quotemeta() {
        String s = this.toString();
        final int length = s.length();
        StringBuilder sb = new StringBuilder();
        for (int offset = 0; offset < length; offset++) {
            final int c = s.codePointAt(offset);
            if ((c >= 'A' && c <= 'Z') || (c >= 'a' && c <= 'z') || (c >= '0' && c <= '9')) {
                // good
            }
            else {
                sb.append("\\");
            }
            sb.append(Character.toChars(c));
        }
        return new PlString(sb.toString());
    }
    public PlInt index(PlObject substr) {
        String s = this.toString();
        String s1 = substr.toString();
        return new PlInt(s.indexOf(s1));
    }
    public PlInt index(PlObject substr, PlObject position) {
        String s = this.toString();
        String s1 = substr.toString();
        int i = position.to_int();
        if (i < 0) {
            i = 0;
        }
        return new PlInt(s.indexOf(s1, i));
    }
    public PlInt rindex(PlObject substr) {
        String s = this.toString();
        String s1 = substr.toString();
        return new PlInt(s.lastIndexOf(s1));
    }
    public PlInt rindex(PlObject substr, PlObject position) {
        String s = this.toString();
        String s1 = substr.toString();
        int i = position.to_int();
        if (i < 0) {
            if (s1.length() == 0) {
                return PlCx.INT0;
            }
            return PlCx.MIN1;
        }
        return new PlInt(s.lastIndexOf(s1, i));
    }
    public PlObject substr(int offset) {
        // substr EXPR,OFFSET
        String s = this.toString();
        int ofs = offset;
        if (ofs < 0) {
            ofs = s.length() + ofs;
        }
        if (ofs < 0) {
            ofs = 0;
        }
        if (ofs >= s.length()) {
            return PlCx.UNDEF;
        }
        return new PlString(s.substring(ofs));
    }
    public PlObject substr(int offset, int length) {
        // substr EXPR,OFFSET,LENGTH
        String s = this.toString();
        int ofs = offset;
        int len = length;
        if (ofs < 0) {
            ofs = s.length() + ofs;
        }
        if (ofs >= s.length()) {
            return PlCx.UNDEF;
        }

        if (len < 0) {
            len = s.length() + len;
        }
        else {
            len = ofs + len;
        }

        if (len >= s.length()) {
            len = s.length();
        }
        if (len <= 0) {
            return PlCx.UNDEF;
        }
        if (ofs < 0) {
            ofs = 0;
        }
        return new PlString(s.substring(ofs, len));
    }
    public PlObject substr(int offset, int length, PlObject replacement) {
        // substr EXPR,OFFSET,LENGTH,REPLACEMENT
        String s = this.toString();
        int ofs = offset;
        int len = length;
        if (ofs < 0) {
            ofs = s.length() + ofs;
        }
        if (ofs >= s.length()) {
            return PlCORE.die("substr outside of string");
        }

        if (len < 0) {
            len = s.length() + len;
        }
        else {
            len = ofs + len;
        }

        if (len >= s.length()) {
            len = s.length();
        }
        if (len <= 0) {
            return PlCx.UNDEF;
        }
        if (ofs < 0) {
            ofs = 0;
        }

        PlObject ret = new PlString(s.substring(ofs, len));
        String start = "";
        String end = "";
        
        if (ofs > 0) {
            start = s.substring(0, ofs);
        }
        if (len < s.length()) {
            end = s.substring(len);
        }
        this.set( new PlString( start + replacement.toString() + end ) );
        return ret;
    }
    public PlObject lvalue_substr(int offset) {
        return this.lvalue_substr(offset, this.toString().length());
    }
    public PlObject lvalue_substr(int offset, int length) {
        if (this.is_lvalue()) {
            return new PlLvalueSubstring(this, offset, length);
        }
        return this.substr(offset, length);
    }
    public PlObject bless(String className) {
        PlCORE.die("Can't bless non-reference value");
        return this;
    }
    public PlClass blessed_class() {
        return null;
    }
    public PlObject set_prototype(PlObject v) {
        return PlCORE.die("Type of arg 1 to Scalar::Util::set_prototype must be block or sub {}");
    }
    public PlScalarImmutable scalar() {
        return (PlScalarImmutable)this;
    }
    public PlObject clone() throws CloneNotSupportedException {
        return this;
    }
    public PlObject string_replicate(PlObject c) {
        int count = c.to_int();
        if ( count < 1 ) {
            return new PlString("");
        }
        else {
            String raw_s = this.toString();
            StringBuilder sb = new StringBuilder();
            for (int i = 0; i < count; i++) {
                sb.append(raw_s);
            }
            return new PlString(sb.toString());
        }
    }
    public PlObject str_cmp(PlObject b) {
        int c = this.toString().compareTo(b.toString());
        return (c == 0 ? PlCx.INT0 : c < 0 ? PlCx.MIN1 : PlCx.INT1);
    }
    public PlObject num_cmp(PlObject b) {
        return b.num_cmp2(this);
    }
    public PlObject num_cmp2(PlObject b) {
        if (b.is_num()) {
            return ((PlDouble)b).num_cmp(this);
        }
        Long blong = b.to_long();
        int c = blong.compareTo(this.to_long());
        return (c == 0 ? PlCx.INT0 : c < 0 ? PlCx.MIN1 : PlCx.INT1);
    }
    public PlObject str_xor(PlObject b) {
        return PlCORE.die("^. not implemented");
    }
    public PlObject str_and(PlObject b) {
        return PlCORE.die("&. not implemented");
    }
    public PlObject str_or(PlObject b) {
        return PlCORE.die("|. not implemented");
    }
    public PlObject smartmatch(PlObject arg2) {
        if (arg2.is_undef()) {
            return this.is_undef() ? PlCx.TRUE : PlCx.FALSE;
        }
        if (arg2.is_string()) {
            return this.str_eq(arg2);
        }
        if (arg2.is_num() || arg2.is_int()) {
            return this.num_eq(arg2);
        }
        if (arg2.is_ref()) {
            PlClass bless = arg2.blessed_class();
            if ( bless != null ) {
                // TODO - right side is object: invoke ~~ overloading on Object, or die
            }
        }
        if (arg2.is_array()) {
            // TODO - right side is array
            PlArray ret = new PlArray();
            for (PlObject aa : arg2) {
                PlObject rr = this.smartmatch(aa);
                if (rr.to_boolean()) {
                    ret.push_void(rr);
                }
            }
            return ret;
        }
        if (arg2.is_hash()) {
            // TODO - right side is hash
        }
        if (arg2.is_coderef()) {
            // TODO - right side is code
        }
        if (arg2.is_regex()) {
            // TODO - right side is regex
        }
        return PlCORE.die(PlCx.VOID, new PlArray(new PlString("Not implemented: smartmatch operator with argument type '"), arg2.ref(), new PlString("'")));
    }

EOT
    , ((map {
            my $perl = $_;
            my $native  = $number_binop{$perl}{op};
            my $returns = $number_binop{$perl}{returns};
"    public PlObject ${perl}(PlObject s) {
        return s.${perl}2(this);
    }
"
    .   ( $returns eq 'PlDouble' ?
"    public PlObject ${perl}2(PlObject s) {
        return new ${returns}( s.to_double() ${native} this.to_double() );
    }
"
        :
"    public PlObject ${perl}2(PlObject s) {
        return new ${returns}( s.to_long() ${native} this.to_long() );
    }
"       )
            }
            sort keys %number_binop ))

    , ((map {
            my $perl = $_;
            my $native  = $string_binop{$perl}{op};
            my $returns = $string_binop{$perl}{returns};
"    public PlObject ${perl}(PlObject b) {
        return new ${returns}(this.toString().compareTo(b.toString()) ${native} 0);
    }
"
            }
            sort keys %string_binop ))

    , ((map {
            my $perl = $_;
"    public PlObject self_assign_${perl}(PlObject s) {
        return PlCORE.die(\"Can't modify constant item\");
    }
"
            }
            sort ( 'string_replicate',
                   'and',
                   'or',
                   'str_and',
                   'str_or',
                   'str_xor',
                   keys %self_assign_number_binop,
            ),
      ))

    , ((map {
            my $perl = $_;
"    public PlObject _self_${perl}(PlObject s) {
        return this.${perl}(s);
    }
"
            }
            sort ( 'string_replicate',
                   keys %self_assign_number_binop,
            ),
      ))

    , <<'EOT'
}
class PlScalarObject extends PlObject {
    public PlScalarObject() {
    }
}
class PlScalarImmutable extends PlScalarObject {
    public PlScalarImmutable() {
    }

    public PlScalarImmutable get() {
        return this;
    }
    public PlScalarImmutable scalar() {
        return this;
    }
}
class PlReference extends PlScalarImmutable {
    public static final String REF_str = new String("REF");
    public static final PlStringConstant REF = new PlStringConstant(REF_str);
    public PlClass bless;

    public boolean is_ref() {
        return true;
    }
    public PlReference bless(String className) {
        this.bless = PlClass.getInstance(className);
        return this;
    }
    public PlClass blessed_class() {
        return this.bless;
    }

    public PlString ref() {
        if ( this.bless == null ) {
            return this.REF;
        }
        else {
            return this.bless.plClassName();
        }
    }
    public String ref_str() {
        if ( this.bless == null ) {
            return this.REF_str;
        }
        else {
            return this.bless.className();
        }
    }
    public boolean ref_boolean() {
        return true;
    }

    public PlInt refaddr() {
        // Scalar::Util::refaddr()
        return new PlInt(this.hashCode());
    }
    public PlObject blessed() {
        // Scalar::Util::blessed()
        if ( this.bless == null ) {
            return PlCx.UNDEF;
        }
        else {
            return this.bless.plClassName();
        }
    }
    public PlObject reftype() {
        // Scalar::Util::reftype()
        return REF;
    }

    // overload
    public String toString() {
        return PlClass.overload_to_string(this).toString();
    }
    public boolean to_boolean() {
        return PlClass.overload_to_boolean(this).to_boolean();
    }
    public double to_double() {
        return PlClass.overload_to_number(this).to_double();
    }
    public PlObject to_num() {
        return PlClass.overload_to_number(this);
    }
    public int to_int() {
        return PlClass.overload_to_number(this).to_int();
    }
    public long to_long() {
        return PlClass.overload_to_number(this).to_long();
    }
EOT
    , ((map {
            my $perl = $_;
"    public PlObject ${perl}2(PlObject s) {
        return PlClass.overload_${perl}(this, s, PlCx.INT1);
    }
"
            }
            sort (
                'num_cmp',
                keys(%number_binop),
            )
      ))

    , ((map {
            my $op = $_;
"    public PlObject $op() {
        return PlClass.overload_$op(this);
    }
"
            }
            sort (
                '_decr',
                '_incr',
                @number_unary,
            )
      ))

    , ((map {
            my $perl = $_;
"    public PlObject ${perl}(PlObject s) {
        return PlClass.overload_$perl(this, s, PlCx.UNDEF);
    }
"
            }
            sort (
                'str_cmp',
                'pow',
                'atan2',
                'mod',
                'num_cmp',
                'string_replicate',
                'smartmatch',
                keys(%string_binop),
                keys(%number_binop),
                ( map { "_self_$_" } keys %self_assign_number_binop ),
            )
      ))

    , <<'EOT'
}
class PlGlobRef extends PlReference {
    public static final String REF_str = new String("GLOB");
    public static final PlStringConstant REF = new PlStringConstant(REF_str);
    public PlFileHandle filehandle;

    public PlGlobRef(PlFileHandle filehandle) {
        this.filehandle = filehandle;
    }
    public PlGlobRef(PlLvalue v) {
        PlObject o = v.get();
        this.filehandle = (PlFileHandle)o;
    }
    public PlGlobRef(PlObject o) {
        this.filehandle = (PlFileHandle)o;
    }
    public boolean is_typeglobref() {
        return true;
    }
    public PlString ref() {
        if ( this.bless == null ) {
            return REF;
        }
        else {
            return this.bless.plClassName();
        }
    }
    public String ref_str() {
        if ( this.bless == null ) {
            return REF_str;
        }
        else {
            return this.bless.className();
        }
    }
    public boolean ref_boolean() {
        return true;
    }

    public PlObject reftype() {
        return REF;
    }
    public PlObject hget(String i) {
        // *{ $name }{CODE}->()
        // PlCORE.say( "PlGlobRef.hget " + i + " " + this.filehandle.hget(i) );
        return this.filehandle.hget(i);
    }
    public PlObject hset(String s, PlObject v) {
        return this.filehandle.hset(s, v);
    }
    public PlObject hset(String s, PlLvalue v) {
        return this.filehandle.hset(s, v.get());
    }
}

class PlStringReader extends Reader{
    // read from string
    String s;
    int pos;
    int mark;

    PlStringReader(PlObject o) {
        this.s = o.toString();
        this.pos = 0;
        this.mark = 0;
    }
    public int read(char[] cbuf, int off, int len) {
        if (pos >= s.length()) {
            return -1;
        }
        len = Math.min(len, s.length() - pos);
        int count = 0;
        while (count < len) {
            cbuf[off++] = s.charAt(pos++);
            count++;
        }
        return count;
    }

    public boolean markSupported() {
        return true;
    }
    public void mark(int readlimit) {
        mark = pos;
        return;
    }
    public void reset() {
        pos = mark;
    }
    public void close() {
        return;
    }
}

class PlFileHandle extends PlScalarImmutable {
    // public static final String REF_str = new String("GLOB");
    // public static final PlStringConstant REF = new PlStringConstant(REF_str);
    public String  typeglob_name;
    public OutputStream outputStream;    // System.out, System.err
    public InputStream inputStream;     // System.in
    public Iterator<Path> directoryIterator;
    public DirectoryStream<Path> directoryStream;
    public Reader  reader;       // Console.reader
    public StringBuilder readlineBuffer;
    public StringBuilder printBuffer;
    public boolean eof;
    public boolean is_argv;
    public Path    path;     // filename, can be null
    public String  mode;     // ">", "+<"
    public String  charset;  // "UTF-8"
    public boolean binmode;
    public boolean output_autoflush;
    public PlObject tied;

    public static final int BUFFER_SIZE = 4096;
    public static final int BUFFER_THRESHOLD = BUFFER_SIZE - 256;
    public static HashSet<PlFileHandle> allOpenFiles = new HashSet<PlFileHandle>();

    public PlFileHandle() {
        this.readlineBuffer = new StringBuilder();
        this.printBuffer = new StringBuilder(PlFileHandle.BUFFER_SIZE);
        this.eof = true;
        this.is_argv = false;
        this.binmode = false;
        this.output_autoflush = false;
    }

    public PlFileHandle(String name) {
        this();     // call the base constructor
        if (name.equals("main::ARGV")) {
            this.is_argv = true;
        }
        this.typeglob_name = name;
    }

    public void dupFileHandle(PlFileHandle o) {
        this.typeglob_name =     o.typeglob_name;
        this.outputStream =      o.outputStream;    // System.out, System.err
        this.inputStream =       o.inputStream;     // System.in
        this.directoryIterator = o.directoryIterator;
        this.directoryStream =   o.directoryStream;
        this.reader =            o.reader;       // Console.reader
        this.readlineBuffer =    o.readlineBuffer;
        this.printBuffer =       o.printBuffer;
        this.eof =               o.eof;
        this.is_argv =           o.is_argv;
        this.path =              o.path;     // filename
        this.mode =              o.mode;     // ">", "+<"
        this.charset =           o.charset;  // "UTF-8"
        this.binmode =           o.binmode;
        this.output_autoflush =  o.output_autoflush;
        this.tied =              o.tied;
    }

    public boolean is_filehandle() {
        return true;
    }

    // tie "handle"
    public PlObject tie(PlArray args) {
        if (this.tied != null) {
            this.untie();
        }
        PlObject self = PerlOp.call("TIEHANDLE", args, PlCx.VOID);
        this.tied = self;
        return self;
    }

    public PlObject untie() {
        if (this.tied != null) {
            PlObject tied = this.tied;
            PlObject untie = PerlOp.call("can", new PlArray(tied, new PlString("UNTIE")), PlCx.SCALAR);
            if (untie.to_boolean()) {
                untie.apply(PlCx.VOID, new PlArray(tied));
            };
            this.tied = null;
            return tied;
        }
        return this;
    }
    public PlObject tied() {
        if (this.tied != null) {
            return this.tied;
        }
        return PlCx.UNDEF;
    }
 
    public static void close_all_files() {
        // called at teardown - program finish, die() or exit()
        // Note: this is also called when the compiler finishes loading (the compiler is a Perl program)
        // System.out.println("PlFileHandle.close_all_files");
        for ( PlFileHandle fh : allOpenFiles ) {
            try {
                fh.flush();     // not sure if we should close STDOUT and STDERR
            }
            catch(Exception e) {
                PlV.sset("main::!", new PlStringLazyError(e));
            }
        }
    }
    public PlObject set_autoflush(PlObject o) {
        this.output_autoflush = o.to_boolean();
        if (this.output_autoflush) {
            try {
                this.flush();
            }
            catch(Exception e) {
                PlV.sset("main::!", new PlStringLazyError(e));
            }
        }
        return o;
    }
    public void flush() throws IOException, UnsupportedEncodingException {
        // System.out.println("PlFileHandle.flush " + typeglob_name);
        if (this.outputStream == null) {
            return;
        }
        if (this.binmode) {
            StringBuilder s = this.printBuffer;
            int ll = s.length();
            byte[] bytes = new byte[ll];
            for (int i2 = 0; i2 < ll; i2++) {
                bytes[i2] = (byte)(s.charAt(i2));
            }
            this.outputStream.write(bytes);
        }
        else {
            String s = this.printBuffer.toString();
            byte[] bytes = s.getBytes(this.charset);
            this.outputStream.write(bytes);
        }
        // this.printBuffer = new StringBuilder(PlFileHandle.BUFFER_SIZE);
        // this.outputStream.flush();   // no need to flush when using write()
        this.printBuffer.setLength(0);
    }
    public void close() throws IOException {
        this.readlineBuffer = new StringBuilder();
        this.eof = true;
        if (this.outputStream != null) {
            this.flush();
            this.outputStream.close();
        }
        if (this.reader != null) {
            this.reader.close();
        }
        PlFileHandle.allOpenFiles.remove(this);
    }
    public String toString() {
        if (this.typeglob_name == null) {
            return "";
        }
        if (this.typeglob_name.startsWith("main::")) {
            return "*" + this.typeglob_name.substring(4);
        }
        return "*" + this.typeglob_name;
    }
    public PlObject setUndef() {
        // undef *{$foo}
        // PlCORE.say( "PlFileHandle.setUndef " + typeglob_name);

        PlString name = new PlString(typeglob_name);

        try {
            // close filehandle if needed
            this.close();
        }
        catch(Exception e) {
            PlV.sset("main::!", new PlStringLazyError(e));
        }

        PlStringConstant glob = PlStringConstant.getConstant(typeglob_name);
        glob.cset(PlCx.UNDEF);
        glob.scalarRef.set(PlCx.UNDEF);
        glob.arrayRef.set(new PlArrayRef());
        glob.hashRef.set(new PlHashRef());
        glob.fileRef.set(new PlFileHandle(typeglob_name));
        if (typeglob_name.endsWith("::")) {
            // TODO - undefine inner symbol table
        }
        return PlCx.UNDEF; 
    }
    public PlObject hget(String i) {
        // *{ $name }{CODE}->()
        // PlCORE.say( "PlFileHandle.hget " + i );

        if (i.equals("SCALAR")) {
            return PlV.make_reference(PlV.sget(typeglob_name));
        }
        else if (i.equals("ARRAY")) {
            return PlV.aget(typeglob_name);
        }
        else if (i.equals("HASH")) {
            if (typeglob_name.endsWith("::")) {
                // %{"Module::"}
                return new PlHashRef(PerlOp.getSymbolTable(typeglob_name));
            }
            return PlV.hget(typeglob_name);
        }
        else if (i.equals("CODE")) {
            return PlV.cget(typeglob_name);
        }
        else if (i.equals("IO")) {
            return this;    // close enough
        }
        else if (i.equals("GLOB")) {
            return new PlGlobRef(this);
        }
        else if (i.equals("FORMAT")) {
            // TODO
        }
        else if (i.equals("NAME")) {
            int pos = typeglob_name.lastIndexOf("::");
            if (pos != -1) {
                String name = typeglob_name.substring(pos+2);
                return new PlString(name);
            }
        }
        else if (i.equals("PACKAGE")) {
            int pos = typeglob_name.lastIndexOf("::");
            if (pos != -1) {
                String namespace = typeglob_name.substring(0, pos);
                return new PlString(namespace);
            }
        }
        return PlCx.UNDEF;
    }
    public PlObject hset(String s, PlObject v) {
        return PlCORE.die("Can't modify glob elem in scalar assignment");
    }
    public PlObject hset(String s, PlLvalue v) {
        return PlCORE.die("Can't modify glob elem in scalar assignment");
    }
    public PlObject hget_scalarref(String i) {
        return this.hget(i);
    }
    public PlObject scalar_deref_set(String namespace, PlObject v) {
        return PlV.sset(typeglob_name, v);
    }
}

EOT
    ,   # list break
<<'EOT'

class PlLvalueSpecialVarAutoflush extends PlLvalue {
    // the $| variable
    public PlObject set(PlObject o) {
        // System.out.println("Set autoflush " + (o.to_boolean() ? "1" : "0"));
        PlV.STDOUT.set_autoflush(o);
        return super.set(o);
    }
    public PlObject set(PlScalarImmutable o) {
        return this.set((PlObject)o);
    }
    public PlObject set(PlLvalue o) {
        return this.set((PlObject)o.get());
    }
}

EOT
    ,   # list break
<<'EOT'

class PlRegex extends PlReference {
    public Pattern p;
    public String  original_string;
    // public Matcher m;
    public boolean flag_xx;
    public static final String REF_str = new String("Regexp");
    public static final PlStringConstant REF = new PlStringConstant(REF_str);

    public PlRegex(String p, int flags, boolean flag_xx) {
        this.flag_xx = flag_xx;
        this.p = Pattern.compile(PerlOp.regex_escape(p, flag_xx), flags);
    }
    public PlRegex(PlObject p, int flags, boolean flag_xx) {
        if (p.is_lvalue()) {
            p = p.get();
        }
        if (p.is_regex()) {
            this.p = ((PlRegex)p).p;    // reuse compiled regex; ignore any difference in flags
        }
        else {
            this.flag_xx = flag_xx;
            this.p = Pattern.compile(PerlOp.regex_escape(p.toString(), flag_xx), flags);
        }
    }
    public PlString ref() {
        if ( this.bless == null ) {
            return REF;
        }
        else {
            return this.bless.plClassName();
        }
    }
    public String ref_str() {
        if ( this.bless == null ) {
            return REF_str;
        }
        else {
            return this.bless.className();
        }
    }
    public boolean ref_boolean() {
        return true;
    }

    public PlObject reftype() {
        return REF;
    }
    public String toString() {
        if (original_string == null) {

            int flags = p.flags();
            StringBuilder sb = new StringBuilder();
            sb.append("(?");

            if ((flags & Pattern.CASE_INSENSITIVE) != 0)
                sb.append("i");
            if ((flags & Pattern.COMMENTS) != 0)
                sb.append("x");
            if (flag_xx)
                sb.append("x");
            if ((flags & Pattern.DOTALL) != 0)
                sb.append("s");
            if ((flags & Pattern.MULTILINE) != 0)
                sb.append("m");

            sb.append("-");

            if ((flags & Pattern.CASE_INSENSITIVE) == 0)
                sb.append("i");
            if ((flags & Pattern.COMMENTS) == 0)
                sb.append("x");
            if ((flags & Pattern.DOTALL) == 0)
                sb.append("s");
            if ((flags & Pattern.MULTILINE) == 0)
                sb.append("m");

            sb.append(":");
            sb.append(p.toString());
            sb.append(")");
            original_string = sb.toString();
 
            // TODO - show flags
            // Pattern.CANON_EQ
            // Pattern.LITERAL
            // Pattern.UNICODE_CASE
            // Pattern.UNICODE_CHARACTER_CLASS
            // Pattern.UNIX_LINES
        }
        return this.original_string;
    }
    public boolean is_regex() {
        return true;
    }
}
class PlRegexResult extends PlScalarImmutable {
    public Matcher matcher;      // regex captures
    public String  regex_string; // last string used in a regex

    public boolean is_regex_result() {
        return true;
    }
}
class PlClosure extends PlReference implements Runnable {
    public PlObject[] env;       // new PlObject[]{ v1, v2, v3 }
    public PlObject prototype;   // '$$$'
    public String pkg_name;      // 'main'
    public static final String REF_str = new String("CODE");
    public static final PlStringConstant REF = new PlStringConstant(REF_str);
    public PlClosure currentSub;
    public boolean is_defined;
    // metadata for caller()
    public String  _javaClassName;
    public Integer _firstLineNumber;
    public Integer _lastLineNumber;

    public PlClosure(PlObject prototype, PlObject[] env, String pkg_name, boolean is_defined) {
        this.prototype = prototype;
        this.env = env;
        this.pkg_name = pkg_name;
        this.currentSub = this;
        this.is_defined = is_defined;
    }
    public PlClosure(PlObject prototype, PlObject[] env, String pkg_name, boolean is_defined, PlClosure currentSub) {
        // this is the constructor for do-BLOCK; currentSub points to the "sub" outside
        this.prototype = prototype;
        this.env = env;
        this.pkg_name = pkg_name;
        this.currentSub = currentSub;
        this.is_defined = is_defined;
    }

    public String javaClassName() {
        if (_javaClassName == null) {
            StackTraceElement firstStack = this.firstLine();
            if ( firstStack != null ) {
                _javaClassName = firstStack.getClassName();
            }
        }
        return _javaClassName;
    }

    public Integer firstLineNumber() {
        if (_firstLineNumber == null) {
            StackTraceElement firstStack = this.firstLine();
            if ( firstStack != null ) {
                _firstLineNumber = firstStack.getLineNumber();
            }
        }
        return _firstLineNumber;
    }

    public Integer lastLineNumber() {
        if (_lastLineNumber == null) {
            StackTraceElement lastStack = this.lastLine();
            if ( lastStack != null ) {
                _lastLineNumber = lastStack.getLineNumber();
            }
        }
        return _lastLineNumber;
    }

    public PlClosure getCurrentSub() {
        return this.currentSub;
    }

    // subclasses override perlFileName() and perlLineNumber()
    public String perlFileName() {
        return null;
    }
    public Integer perlLineNumber() {
        return null;
    }

    // subclasses override firstLine() and lastLine()
    // these methods are used by caller() to identify where the sub is implemented in the source code
    public StackTraceElement firstLine() {
        return null;
    }
    // Note: apply() overrides PlObject.apply(), which throws an error
    public PlObject apply(int want, PlArray List__) {
        PlCORE.die("it looks like you have a closure without a block");
        return this;
    }
    public PlObject apply_do_block(int want, int return_context, PlArray List__) {
        PlCORE.die("it looks like you have a do-block without a block");
        return this;
    }
    public StackTraceElement lastLine() {
        return null;
    }
    public void run() {
        // run as a thread
        this.apply(PlCx.VOID, new PlArray());
    }

    public PerlArgumentLookupResult castToClass(ArrayList<Class[]> params, int pos) {
        // want java.lang.Runnable
        for (Class[] cl : params) {
            if (cl[pos].equals( java.lang.Runnable.class )) {
                return new PerlArgumentLookupResult( this, cl[pos] );
            }
        }
        // try other things
        return this.get().castToClass(params, pos);
    }

    public PlString ref() {
        if ( this.bless == null ) {
            return REF;
        }
        else {
            return this.bless.plClassName();
        }
    }
    public String ref_str() {
        if ( this.bless == null ) {
            return REF_str;
        }
        else {
            return this.bless.className();
        }
    }
    public boolean ref_boolean() {
        return true;
    }

    public PlObject reftype() {
        return REF;
    }
    public boolean is_coderef() {
        return true;
    }
    public boolean is_undef() {
        return !is_defined;
    }
    public PlObject prototype() {
        return this.prototype;
    }
    public PlObject set_prototype(PlObject v) {
        return this.prototype = new PlString(v.toString());
    }
}
class PlLvalueRef extends PlReference {
    private PlObject o;
    public static final String REF_str = new String("SCALAR");
    public static final PlStringConstant REF = new PlStringConstant(REF_str);
    public static final PlString REF_REF = new PlString("REF");

    public PlString ref() {
        if ( this.bless == null ) {
            if ( this.o.is_ref() ) {
                return REF_REF;
            }
            return REF;
        }
        else {
            return this.bless.plClassName();
        }
    }
    public String ref_str() {
        if ( this.bless == null ) {
            if ( this.o.is_ref() ) {
                return REF_REF.toString();
            }
            return REF_str;
        }
        else {
            return this.bless.className();
        }
    }
    public boolean ref_boolean() {
        return true;
    }

    public PlInt refaddr() {
        // Scalar::Util::refaddr()
        int id = System.identityHashCode(this.o);
        return new PlInt(id);
    }
    public PlLvalueRef(PlLvalue o) {
        this.o = o;
    }
    public PlLvalueRef(PlObject o) {
        this.o = o;
    }
    public PlLvalueRef(String o) {
        this.o = new PlString(o);
    }
    public PlObject scalar_deref_lvalue(String namespace) {
        return this.o;
    }
    public PlObject scalar_deref(String namespace) {
        return this.o;
    }
    public PlObject scalar_deref_strict() {
        return this.o;
    }
    public PlObject scalar_deref_set(String namespace, PlObject v) {
        return this.o.set(v);
    }
    public boolean is_scalarref() {
        return true;
    }
}
class PlArrayRef extends PlReference {
    public static final String REF_str = new String("ARRAY");
    public static final PlStringConstant REF = new PlStringConstant(REF_str);
    public PlArray ar;

    public PlArrayRef() {
        this.ar = new PlArray();
    }
    public PlArrayRef(PlArray o) {
        this.ar = o;
    }
    public PlArrayRef(PlObject o) {
        this.ar = (PlArray)o;
    }
    public PlInt refaddr() {
        // Scalar::Util::refaddr()
        int id = System.identityHashCode(this.ar);
        return new PlInt(id);
    }
    public PlObject set(PlArray o) {
        this.ar = o;
        return o;
    }
    public PlArray array_deref_lvalue() {
        return this.ar;
    }
    public PlArray array_deref(String namespace) {
        return this.ar;
    }
    public PlArray array_deref_strict() {
        return this.ar;
    }
    public PlObject array_deref_set(PlObject v) {
        this.ar.set(v);
        return v;
    }
    public boolean is_arrayref() {
        return true;
    }
    public PlString ref() {
        if ( this.bless == null ) {
            return REF;
        }
        else {
            return this.bless.plClassName();
        }
    }
    public String ref_str() {
        if ( this.bless == null ) {
            return REF_str;
        }
        else {
            return this.bless.className();
        }
    }
    public boolean ref_boolean() {
        return true;
    }

    public PlObject reftype() {
        return REF;
    }

    public PlObject aget(int i) {
        return this.ar.a.aget(i);
    }
    public PlObject aget_lvalue(int i) {
        return this.ar.aget_lvalue(i);
    }
    public PlObject aget_scalarref(int i) {
        return this.ar.aget_scalarref(i);
    }
    public PlObject aget_hashref(int i) {
        return this.ar.aget_hashref(i);
    }
    public PlObject aget_arrayref(int i) {
        return this.ar.aget_arrayref(i);
    }
    public PlObject aset(int i, PlObject v) {
        return this.ar.aset(i, v);
    }
 
    public PlObject aexists(PlObject i) {
        return this.ar.aexists(i);
    }
    public PlObject adelete(int want, PlObject i) {
        return this.ar.adelete(want, i);
    }
    public PlObject values() {
        return this.ar.values();
    }
    public PlObject keys() {
        return this.ar.keys();
    }
    public PlObject each() {
        return this.ar.each();
    }
}

class PlHashRef extends PlReference {
    public static final String REF_str = new String("HASH");
    public static final PlStringConstant REF = new PlStringConstant(REF_str);
    public PlHash ha;

    public PlHashRef() {
        this.ha = new PlHash();
    }
    public PlHashRef(PlHash o) {
        this.ha = o;
    }
    public PlHashRef(PlObject o) {
        this.ha = (PlHash)o;
    }
    public PlInt refaddr() {
        // Scalar::Util::refaddr()
        int id = System.identityHashCode(this.ha);
        return new PlInt(id);
    }
    public boolean is_hashref() {
        return true;
    }
    public PlString ref() {
        if ( this.bless == null ) {
            return REF;
        }
        else {
            return this.bless.plClassName();
        }
    }
    public String ref_str() {
        if ( this.bless == null ) {
            return REF_str;
        }
        else {
            return this.bless.className();
        }
    }
    public boolean ref_boolean() {
        return true;
    }

    public PlObject reftype() {
        return REF;
    }

    public PlObject set(PlHash o) {
        this.ha = o;
        return o;
    }
    public PlHash hash_deref(String namespace) {
        return this.ha;
    }
    public PlHash hash_deref_strict() {
        return this.ha;
    }
    public PlObject hash_deref_set(PlObject v) {
        this.ha.set(PlCx.VOID, v);
        return v;
    }

    public PlObject hget(String i) {
        PlObject o = this.ha.h.get(i);
        if (o == null) {
            return PlCx.UNDEF;
        }
        return o;
    }

    public PlObject hget_lvalue(String i) {
        return this.ha.hget_lvalue(i);
    }
    public PlObject hget_lvalue_local(String i) {
        return this.ha.hget_lvalue_local(i);
    }

    public PlObject hget_scalarref(String i) {
        return this.ha.hget_scalarref(i);
    }

    public PlObject hget_arrayref(String i) {
        return this.ha.hget_arrayref(i);
    }

    public PlObject hget_hashref(String i) {
        return this.ha.hget_hashref(i);
    }

    public PlObject hset(String i, PlObject v) {
        return this.ha.hset(i, v);
    }
    public PlObject hset(String i, PlLvalue v) {
        return this.ha.hset(i, v.get());
    }
    public PlObject hset(int want, PlArray i, PlArray v) {
        return this.ha.hset(want, i, v);
    }
    public PlObject hset_alias(String i, PlObject v) {
        return this.ha.hset_alias(i, v);
    }
    public PlObject hexists(String i) {
        return this.ha.hexists(i);
    }
    public PlObject hexists(PlObject i) {
        return this.ha.hexists(i);
    }
    public PlObject hdelete(int want, PlObject a) {
        return this.ha.hdelete(want, a);
    }
    public PlObject hdelete(int want, PlArray a) {
        return this.ha.hdelete(want, a);
    }
    public PlObject hdelete(int want, PlString a) {
        return this.ha.hdelete(want, a);
    }
    public PlObject hdelete(int want, PlLvalue a) {
        return this.ha.hdelete(want, a);
    }
    public PlObject values() {
        return this.ha.values();
    }
    public PlObject keys() {
        return this.ha.keys();
    }
    public PlObject each() {
        return this.ha.each();
    }
}
class PlClass {
    public static HashMap<String, PlClass> classes = new HashMap<String, PlClass>();
    public String className;
    public PlString plClassName;
    public Boolean overload_flag;
    public Boolean overload_fallback_flag;
    public HashMap<String, PlObject> methodCache;

    protected PlClass(String s) {
        this.className = s;
        this.plClassName = new PlString(s);
        this.overload_flag = null;
        this.overload_fallback_flag = null;
        this.methodCache = new HashMap<String, PlObject>();
    }
    public static PlClass getInstance(PlObject s) {
        return PlClass.getInstance(s.toString());
    }
    public static PlClass getInstance(String s) {
        PlClass c = classes.get(s);
        if (c == null) {
            c = new PlClass(s);
            classes.put(s, c);
        }
        return c;
    }
    public String className() {
        return this.className;
    }
    public PlString plClassName() {
        return this.plClassName;
    }
    public boolean is_undef() {
        return this.className == null;
    }
    public Boolean is_overloaded() {
        if (this.overload_flag == null) {
            PlObject methodCode1 = this.method_lookup("((", 0);
            PlObject methodCode2 = this.method_lookup("()", 0);
            this.overload_flag = methodCode1.is_coderef() || methodCode2.is_coderef();
        }
        return this.overload_flag;
    }
    public Boolean is_overload_fallback() {
        if (this.overload_fallback_flag == null) {
            PlObject methodCode = this.method_lookup("()", 0);
            this.overload_fallback_flag = methodCode.is_coderef();
        }
        return this.overload_fallback_flag;
    }

    public PlObject overload_lookup(String method, int level) {
        // method is like (*=
        PlObject methodCode;
        String methodName = className + "::" + method;
        methodCode = PlV.cget_no_autoload(methodName);
        if (methodCode.is_undef()) {
            // method not found
            // "overload" methods have no AUTOLOAD
            // lookup in @ISA
          search:
            for (PlObject className : PlV.array_get(className + "::ISA")) {
                // prevent infinite loop
                if (level >= 100) {
                    PlCORE.die("Recursive inheritance detected in package '" + className + "'");
                }
                methodCode = PlClass.getInstance(className).overload_lookup(method, level+1);
                if (!methodCode.is_undef()) {
                    return methodCode;
                }
            }
        }
        if (methodCode.is_undef()) {
            // overload does lookup in UNIVERSAL
            methodCode = PlV.cget_no_autoload("UNIVERSAL::" + method);
        }
        // method found

        PlObject nameLookup = PlV.sget(methodName);
        if (!nameLookup.is_undef()) {
            // PlCORE.say("overload_lookup " + methodName + " scalar [" + nameLookup.toString() + "]");
            return nameLookup;
        }

        return methodCode;
    }

    public void invalidate_method_cache(String method, int level) {
        if (this.methodCache.containsKey(method)) {
            this.methodCache.remove(method);
        }
        // TODO - lookup in all classes that inherit from us
        // for (PlObject className : PlV.array_get(className + "::ISA")) {
        //     // prevent infinite loop
        //     if (level >= 100) {
        //         PlCORE.die("Recursive inheritance detected in package '" + className + "'");
        //     }
        //     PlClass.getInstance(className).invalidate_method_cache(method, level+1);
        // }
    }

    public PlObject method_lookup(String method, int level) {
        if (this.methodCache.containsKey(method)) {
            // retrieve from method cache
            // PlCORE.warn("match " + method);
            return this.methodCache.get(method);
        }
        // PlCORE.warn("miss " + method);

        PlObject methodCode;
        int pos = method.indexOf("::");
        if (pos != -1) {
            // fully qualified method name
            if (method.startsWith("SUPER::")) {
                PlCORE.die("not implemented: " + method); 
            }
            return PlV.cget(method);
        }
        methodCode = PlV.cget_no_autoload(className + "::" + method);
        if (methodCode.is_undef()) {
            // method not found

            // lookup in AUTOLOAD
            methodCode = PlV.cget_no_autoload(className + "::AUTOLOAD");
            if (!methodCode.is_undef()) {
                if (method.charAt(0) == '('     // "overload" methods
                 || method.equals("import")
                 || method.equals("unimport")
                 || method.equals("isa")
                 || method.equals("can")
                ) {
                    // overload method - TODO
                }
                else {
                    PlV.sset(className + "::AUTOLOAD", new PlString(className + "::" + method));
                    // this.methodCache.put(method, methodCode);
                    return methodCode;
                }
            }

            // lookup in @ISA
            for (PlObject className : PlV.array_get(className + "::ISA")) {
                // prevent infinite loop
                if (level >= 100) {
                    PlCORE.die("Recursive inheritance detected in package '" + className + "'");
                }
                methodCode = PlClass.getInstance(className).method_lookup(method, level+1);
                if (!methodCode.is_undef()) {
                    // found
                    this.methodCache.put(method, methodCode);
                    return methodCode;
                }
            }

            // lookup in UNIVERSAL
            methodCode = PlV.cget_no_autoload("UNIVERSAL::" + method);
        }
        this.methodCache.put(method, methodCode);
        return methodCode;
    }
    public PlObject isa(String s, int level) {
        if (className.equals(s)) {
            return PlCx.INT1;
        }

        // lookup in @ISA
        for (PlObject isa_item : PlV.array_get(className + "::ISA")) {
            String className = isa_item.toString();
            // prevent infinite loop
            if (level >= 100) {
                PlCORE.die("Recursive inheritance detected in package '" + className.toString() + "'");
            }
            PlObject is = PlClass.getInstance(className).isa(s, level+1);
            if (is.to_boolean()) {
                return is;
            }
        }

        // lookup in UNIVERSAL
        if (s.equals("UNIVERSAL")) {
            return PlCx.INT1;
        }
        return PlCx.UNDEF;
    }
EOT

    # overload
    # TODO: "nomethod"
    # TODO: dispatch on indirect reference (method name instead of coderef); coderef = \&nil - See overload.pm
    # TODO: missing operators
    #       with_assign         => "+ - * / % ** << >> x .",
    #       assign              => "+= -= *= /= %= **= <<= >>= x= .=",
    #       num_comparison      => "< <= >  >= == !=",
    #       '3way_comparison'   => "<=> cmp",
    #       str_comparison      => "lt le gt ge eq ne",
    #       binary              => '& &= | |= ^ ^=',
    #       unary               => "neg ! ~",
    #       mutators            => '++ --',
    #       func                => "atan2 cos sin exp abs log sqrt int",
    #       conversion          => 'bool "" 0+ qr',
    #       iterators           => '<>',
    #       filetest            => "-X",
    #       dereferencing       => '${} @{} %{} &{} *{}',
    #       matching            => '~~',
    #       special             => 'nomethod fallback =',
    # 
    # TODO: new error message:
    #       Operation "*": no method found,
    #           left argument has no overloaded magic,
    #           right argument in overloaded package XYZ
    #       Operation "*": no method found,
    #           left argument in overloaded package XYZ,
    #           right argument has no overloaded magic

    , <<'EOT'
    public static PlObject overload_to_string(PlObject o) {
        PlClass bless = o.blessed_class();
        if ( bless != null && bless.is_overloaded() ) {
            // PlCORE.say("PlReference toString() " + bless.className);
            for (String ovl : new String[] { PlCx.OVERLOAD_STRING, PlCx.OVERLOAD_NUM, PlCx.OVERLOAD_BOOL }) {
                PlObject methodCode = bless.overload_lookup(ovl, 0);
                if (!methodCode.is_undef()) {
                    return PerlOp.call(methodCode, new PlArray(o), PlCx.SCALAR);
                }
                if (!bless.is_overload_fallback()) {
                    break;
                }
            }

            // nomethod
            PlObject methodCode = bless.overload_lookup(PlCx.OVERLOAD_NOMETHOD, 0);
            if (!methodCode.is_undef()) {
                return PerlOp.call(methodCode, new PlArray( o, PlCx.UNDEF, PlCx.UNDEF, new PlString(PlCx.OVERLOAD_STRING) ), PlCx.SCALAR);
            }
        }

        return o.refstring();
    }
    public static PlObject overload_to_number(PlObject o) {
        PlClass bless = o.blessed_class();
        if ( bless != null && bless.is_overloaded() ) {
            for (String ovl : new String[] { PlCx.OVERLOAD_NUM, PlCx.OVERLOAD_STRING, PlCx.OVERLOAD_BOOL }) {
                PlObject methodCode = bless.overload_lookup(ovl, 0);
                if (!methodCode.is_undef()) {
                    return PerlOp.call(methodCode, new PlArray(o), PlCx.SCALAR);
                }
                if (!bless.is_overload_fallback()) {
                    break;
                }
            }

            // nomethod
            PlObject methodCode = bless.overload_lookup(PlCx.OVERLOAD_NOMETHOD, 0);
            if (!methodCode.is_undef()) {
                return PerlOp.call(methodCode, new PlArray( o, PlCx.UNDEF, PlCx.UNDEF, new PlString(PlCx.OVERLOAD_STRING) ), PlCx.SCALAR);
            }
        }

        return o.refaddr();
    }
    public static PlObject overload_to_boolean(PlObject o) {
        PlClass bless = o.blessed_class();
        if ( bless != null && bless.is_overloaded() ) {
            for (String ovl : new String[] { PlCx.OVERLOAD_BOOL, PlCx.OVERLOAD_NUM, PlCx.OVERLOAD_STRING }) {
                PlObject methodCode = bless.overload_lookup(ovl, 0);
                if (!methodCode.is_undef()) {
                    return PerlOp.call(methodCode, new PlArray(o), PlCx.SCALAR);
                }
                if (!bless.is_overload_fallback()) {
                    break;
                }
            }

            // nomethod
            PlObject methodCode = bless.overload_lookup(PlCx.OVERLOAD_NOMETHOD, 0);
            if (!methodCode.is_undef()) {
                return PerlOp.call(methodCode, new PlArray( o, PlCx.UNDEF, PlCx.UNDEF, new PlString(PlCx.OVERLOAD_STRING) ), PlCx.SCALAR);
            }
        }

        return PlCx.TRUE;
    }
EOT
    , ((map {
            my $perl = $_;
            my $native;
            $native = $number_binop{$perl}{op} if exists $number_binop{$perl};
            $native = "<=>"   if $perl eq "num_cmp";
            $native = "**"    if $perl eq "pow";
            $native = "atan2" if $perl eq "atan2";
            $native = "%"     if $perl eq "mod";
            $native = ">>"    if $perl eq "int_shr";
"    public static PlObject overload_${perl}(PlObject o, PlObject other, PlObject swap) {
        PlClass bless = o.blessed_class();
        if ( bless != null && bless.is_overloaded() ) {
            PlObject methodCode = bless.overload_lookup(\"(${native}\", 0);
            if (!methodCode.is_undef()) {
                return PerlOp.call(methodCode, new PlArray(o, other, swap), PlCx.SCALAR);
            }
            if (bless.is_overload_fallback()) {
                o = PlClass.overload_to_number(o);
            }
            else {
                PlCORE.die(\"Operation ${native}: no method found\");
            }
        }
        else {
            o = o.refaddr();
        }
        if (swap.to_boolean()) {
            return other.${perl}(o);
        }
        return o.${perl}(other);
    }
"
            }
            sort (
                'num_cmp',
                'pow',
                'atan2',
                'mod',
                keys %number_binop,
            )
      ))

    , ((map {
            my $perl = $_;
            my $native = $perl;
            $native = "++"      if $perl eq "_incr";
            $native = "--"      if $perl eq "_decr";
"    public static PlObject overload_${perl}(PlObject o) {
        PlClass bless = o.blessed_class();
        if ( bless != null && bless.is_overloaded() ) {
            PlObject methodCode = bless.overload_lookup(\"(${native}\", 0);
            PlObject copyConstructorCode = bless.overload_lookup(\"(=\", 0);
            if (!methodCode.is_undef()) {

                if (!copyConstructorCode.is_undef()) {
                    o = PerlOp.call(copyConstructorCode, new PlArray(o), PlCx.SCALAR);
                }
                else if (o.is_scalarref()) {
                    // mutator: copy the reference
                    PlObject v = o.scalar_deref(\"main\");
                    if (v.is_lvalue()) {
                        v = new PlLvalue(v.get());
                    }
                    o = new PlLvalueRef(v);
                    o.bless( bless.className() );
                }

                return PerlOp.call(methodCode, new PlArray(o), PlCx.SCALAR);
            }
            // if (bless.is_overload_fallback()) {
            PlObject v = PlClass.overload_to_number(o).${perl}();
            if (o.is_scalarref()) {
                // auto generated mutator: copy the reference
                PlLvalueRef ret = new PlLvalueRef(v);
                ret.bless( bless.className() );
                return ret;
            }
            // TODO - call the 'Copy constructor'
            return v;
        }
        return o.refaddr().${perl}();
    }
"
            }
            sort (
                '_decr',
                '_incr',
            )
      ))

    , ((map {
            my $perl = $_;
            my $native = $perl;
            $native = "int"     if $perl eq "op_int";
            $native = "~"       if $perl eq "complement";
"    public static PlObject overload_${perl}(PlObject o) {
        PlClass bless = o.blessed_class();
        // PlCORE.say(\"overload_${perl}\");
        if ( bless != null && bless.is_overloaded() ) {
            PlObject methodCode = bless.overload_lookup(\"(${native}\", 0);
            if (!methodCode.is_undef()) {
                // PlCORE.say(\"overload_${perl} hit \");
                return PerlOp.call(methodCode, new PlArray(o), PlCx.SCALAR);
            }
"
. ( $perl eq "neg" ?
"
            // neg falls back to (0-v)
            methodCode = bless.overload_lookup(\"(-\", 0);
            if (!methodCode.is_undef()) {
                // PlCORE.say(\"overload_${perl} fallback (- \");
                return PerlOp.call(methodCode, new PlArray(o, PlCx.INT0, PlCx.TRUE), PlCx.SCALAR);
            }
"
  : ())
. ( $perl eq "abs" ?
"
            // abs falls back to (v < 0 ? 0-v : v)
            methodCode = bless.overload_lookup(\"(<\", 0);
            if (!methodCode.is_undef()) {
                // PlCORE.say(\"overload_${perl} fallback (< \");
                int cmp = PerlOp.call(methodCode, new PlArray(o, PlCx.INT0, PlCx.FALSE), PlCx.SCALAR).to_int();
                if (cmp > 0) {
                    return o.neg();
                }
                return o;
            }

            methodCode = bless.overload_lookup(\"(<=>\", 0);
            if (!methodCode.is_undef()) {
                // PlCORE.say(\"overload_${perl} fallback (<=> \");
                int cmp = PerlOp.call(methodCode, new PlArray(o, PlCx.INT0, PlCx.FALSE), PlCx.SCALAR).to_int();
                if (cmp >= 0) {
                    return o;
                }
                return o.neg();
            }
"
  : ())
. "
            if (bless.is_overload_fallback()) {
                // PlCORE.say(\"overload_${perl} plain fallback \");
                return PlClass.overload_to_number(o).${perl}();
            }
            // PlCORE.say(\"overload_${perl} fall through \");
            PlCORE.die(\"Operation ${native}: no method found\");
        }
        return o.refaddr().${perl}();
    }
"
            }
            sort (
                @number_unary,
            )
      ))

    , ((map {
            my $perl = $_;
            my $native;
            $native = $string_binop{$perl}{str_op} if exists $string_binop{$perl};
            $native = "cmp" if $perl eq "str_cmp";
            $native = "x"   if $perl eq "string_replicate";
            $native = "~~"  if $perl eq "smartmatch";
"    public static PlObject overload_${perl}(PlObject o, PlObject other, PlObject swap) {
        PlClass bless = o.blessed_class();
        if ( bless != null && bless.is_overloaded() ) {
            PlObject methodCode = bless.overload_lookup(\"(${native}\", 0);
            if (!methodCode.is_undef()) {
                return PerlOp.call(methodCode, new PlArray(o, other, swap), PlCx.SCALAR);
            }
            if (bless.is_overload_fallback()) {
                o = PlClass.overload_to_string(o);
            }
            else {
                o = o.refstring();
            }
        }
        else {
            o = o.refstring();
        }
        if (swap.to_boolean()) {
            return other.${perl}(o);
        }
        return o.${perl}(other);
    }
"
            }
            sort (
                'str_cmp',
                'string_replicate',
                'smartmatch',
                keys %string_binop,
            )
      ))

    , ((map {
            my $perl = $_;
            my $native;
            $native = $self_assign_number_binop{$perl}{op} if exists $self_assign_number_binop{$perl};
            $native = "x="   if $perl eq "string_replicate";
"    public static PlObject overload__self_${perl}(PlObject o, PlObject other, PlObject swap) {
        PlClass bless = o.blessed_class();
        // PlCORE.say(\"in self_assign ${native} \");
        if ( bless != null && bless.is_overloaded() ) {
            PlObject methodCode = bless.overload_lookup(\"(${native}\", 0);
            PlObject copyConstructorCode = bless.overload_lookup(\"(=\", 0);
            if (!methodCode.is_undef()) {
                // PlCORE.say(\"self_assign (${native} \" + other.toString());

                if (!copyConstructorCode.is_undef()) {
                    o = PerlOp.call(copyConstructorCode, new PlArray(o), PlCx.SCALAR);
                }
                else if (o.is_scalarref()) {
                    // mutator: copy the reference
                    PlObject v = o.scalar_deref(\"main\");
                    if (v.is_lvalue()) {
                        v = new PlLvalue(v.get());
                    }
                    o = new PlLvalueRef(v);
                    o.bless( bless.className() );
                }

                return PerlOp.call(methodCode, new PlArray(o, other, swap), PlCx.SCALAR);
            }
            // TODO - overload_self_assign_${perl}
            //if (bless.is_overload_fallback()) {
                // PlCORE.say(\"self_assign generated (${native} \" + other.toString());

                PlObject v;
                if (swap.to_boolean()) {
                    v = other.${perl}(PlClass.overload_to_number(o));
                }
                else {
                    v = PlClass.overload_to_number(o).${perl}(other);
                }
                if (o.is_scalarref()) {
                    // auto generated mutator: copy the reference
                    PlLvalueRef ret = new PlLvalueRef(v);
                    ret.bless( bless.className() );
                    return ret;
                }
                // TODO - call the 'Copy constructor'
                return v;

            //}
            //else {
            //    o = o.refstring();
            //}
        }
        else {
            o = o.refstring();
        }
        if (swap.to_boolean()) {
            return other.${perl}(o);
        }
        return o.${perl}(other);
    }
"
            }
            sort (
                'string_replicate',
                keys %self_assign_number_binop,
            )
      ))

    , <<'EOT'
}
class PlLazyIndex extends PlLazyLvalue {
    private PlArray la;    // @la
    private int i;         // $la[$i]

    public PlLazyIndex(PlArray la, int i) {
        this.la = la;
        this.i  = i;
    }

    // internal lazy api
    public PlLvalue create_scalar() {
        if (llv == null) {
            llv = la.create_scalar(i);
        }
        return llv;
    }

}

class PlLvalueSubstring extends PlLazyLvalue {
    private PlObject lv;
    private String start;
    private String end;
    private String replacement;

    public PlLvalueSubstring(PlObject lv, int offset, int length) {
        this.lv = lv;
        this.replacement = lv.get().substr(offset, length).toString();

        String s = lv.toString();
        int ofs = offset;
        int len = length;
        if (ofs < 0) {
            ofs = s.length() + ofs;
        }

        if (len < 0) {
            len = s.length() + len;
        }
        else {
            len = ofs + len;
        }

        if (len >= s.length()) {
            len = s.length();
        }
        if (ofs < 0) {
            ofs = 0;
        }

        PlObject ret = new PlString(s.substring(ofs, len));
        this.start = "";
        this.end = "";
        
        if (ofs > 0) {
            this.start = s.substring(0, ofs);
        }
        if (len < s.length()) {
            this.end = s.substring(len);
        }
    }

    // internal lazy api
    public PlLvalue create_scalar() {
        return (PlLvalue)this.lv;
    }

    public PlScalarImmutable get() {
        return new PlString( replacement );
    }

    public PlObject set(PlObject o) {
        this.replacement = o.toString();
        lv.set( new PlString( start + replacement + end ) );
        return this;
    }

    public PlObject pre_decr() {
        // --$x
        PlObject o = this.get()._decr();
        return this.set(o);
    }
    public PlObject post_decr() {
        // $x--
        PlObject o = this.get();
        this.set(o._decr());
        return o;
    }
    public PlObject pre_incr() {
        // ++$x
        PlObject o = this.get()._incr();
        return this.set(o);
    }
    public PlObject post_incr() {
        // $x++
        PlObject o = this.get();
        this.set(o._incr());
        return o;
    }
}
class PlLazyTiedLookup extends PlLazyLvalue {
    private PlHash la;    // %la
    private String i;     // $la{$i}

    public PlLazyTiedLookup(PlHash la, String i) {
        this.la = la;
        this.i  = i;
    }

    // internal lazy api
    public PlLvalue create_scalar() {
        if (llv == null) {
            llv = la.create_scalar(i);
        }
        return llv;
    }

    public PlScalarImmutable get() {
        return (PlScalarImmutable)la.hget(i);
    }

    public PlObject set(PlObject o) {
        la.hset(i, o);
        return this;
    }

    public PlObject pre_decr() {
        // --$x
        PlObject o = this.get()._decr();
        return this.set(o);
    }
    public PlObject post_decr() {
        // $x--
        PlObject o = this.get();
        this.set(o._decr());
        return o;
    }
    public PlObject pre_incr() {
        // ++$x
        PlObject o = this.get()._incr();
        return this.set(o);
    }
    public PlObject post_incr() {
        // $x++
        PlObject o = this.get();
        this.set(o._incr());
        return o;
    }
}
class PlLazyLookup extends PlLazyLvalue {
    private PlHash la;    // %la
    private String i;     // $la{$i}

    public PlLazyLookup(PlHash la, String i) {
        this.la = la;
        this.i  = i;
    }

    // internal lazy api
    public PlLvalue create_scalar() {
        if (llv == null) {
            llv = la.create_scalar(i);
        }
        return llv;
    }
}
class PlLazyScalarref extends PlLazyLvalue {
    private PlLvalue lv;    // $lv

    public PlLazyScalarref(PlLvalue lv) {
        this.lv = lv;
    }

    // internal lazy api
    public PlLvalue create_scalar() {
        if (this.llv == null) {
            PlLvalue s = new PlLvalue();
            lv.create_scalar().set(new PlLvalueRef(s));
            this.llv = s;
        }
        return this.llv;
    }
}

class PlLazyLvalue extends PlLvalue {
    public  PlLvalue llv;   // $$lv

    public PlLazyLvalue() {
    }

    public PlLvalue create_scalar() {
        return (PlLvalue)PlCORE.die("internal error: called PlLazyLvalue.create_scalar()");
    }

    public PlScalarImmutable get() {
        if (llv == null) {
            return PlCx.UNDEF;
        }
        return llv.get();
    }

    // Note: several versions of set()
    public PlObject set(PlObject o) {
        if (llv == null) {
            create_scalar();
        }
        return llv.set(o);
    }
    public PlObject set(PlScalarImmutable o) {
        if (llv == null) {
            create_scalar();
        }
        return llv.set(o);
    }
    public PlObject set(PlLvalue o) {
        if (llv == null) {
            create_scalar();
        }
        return llv.set(o);
    }
EOT
    , ((map {
            my $perl = $_;
"    public PlObject ${perl}(PlObject s) {
        return this.get().${perl}(s);
    }
    public PlObject ${perl}2(PlObject s) {
        return s.${perl}(this.get());
    }
"
            }
            sort (
                'num_cmp',
                'mod',
                keys %number_binop,
            )
      ))

        # unary operators
        #
    , ((map {
            my ($op, $type) = @$_;
"    public $type $op() {
        return this.get().$op();
    }
"
            }
            map( [ $_ => 'PlObject' ], (
                @number_unary,
                'blessed',
                'refaddr',      # Scalar::Util::refaddr()
                'reftype',      # Scalar::Util::reftype()
                'to_num',
            )),
            map( [ $_ => 'boolean' ], (
                @boolean_unary,
                'is_integer_range',
            )),
            [ 'toString'      => 'String'   ],
            [ 'to_int'        => 'int'      ],
            [ 'to_long'       => 'long'     ],
            [ 'to_double'     => 'double'   ],
            [ 'to_boolean'    => 'boolean'  ],
            [ 'blessed_class' => 'PlClass'  ],
            [ 'ref'           => 'PlString' ],
            [ 'ref_str'       => 'String'   ],
            [ 'ref_boolean'   => 'boolean'  ],

            # add "unbox" accessors to Java classes that were declared with:  'package MyJavaClass { Java }'
            (map {  my $class = $java_classes{$_};
                    $class->{import} || $class->{extends} || $class->{implements}
                      ? [ $class->{perl_to_java}, $class->{java_type} ]
                      : ()
                 }
                 grep { $java_classes{$_}{perl_to_java} }
                 sort keys %java_classes
            ),
      ))

    , <<'EOT'

}
class PlLvalue extends PlScalarObject {
    public PlScalarImmutable o;
    public Integer pos;
    public boolean regex_zero_length_flag;
    public PlObject tied;

    // Note: several versions of PlLvalue()
    public PlLvalue() {
        this.o = PlCx.UNDEF;
    }
    public PlLvalue(long o) {
        this.o = new PlInt(o);
    }
    public PlLvalue(PlObject o) {
        this.o = (PlScalarImmutable)o;
    }
    public PlLvalue(PlScalarImmutable o) {
        this.o = o;
    }
    public PlLvalue(PlLvalue o) {
        this.o = o.get();
    }
    public PlLvalue(PlArray o) {
        // $a = @x
        this.o = o.scalar();
    }
    public PlLvalue(PlHash o) {
        // $a = %x
        this.o = o.scalar();
    }

    public PerlArgumentLookupResult castToClass(ArrayList<Class[]> params, int pos) {
        // want PlLvalue
        for (Class[] cl : params) {
            if (cl[pos].equals( this.getClass() )) {
                return new PerlArgumentLookupResult( this, cl[pos] );
            }
        }
        // try other things
        return this.get().castToClass(params, pos);
    }

    public Iterator<PlObject> iterator() {
        return new PlLvalueIterator(this); 
    }

    // tie scalar
    public PlObject tie(PlArray args) {
        if (this.o.is_filehandle()) {
            return this.o.tie(args);
        }

        if (this.tied != null) {
            this.untie();
        }
        PlObject self = PerlOp.call("TIESCALAR", args, PlCx.VOID);
        this.tied = self;
        return self;
    }

    public PlObject untie() {
        if (this.o.is_filehandle()) {
            return ((PlFileHandle)this.o).untie();
        }

        if (this.tied != null) {
            PlObject tied = this.tied;
            PlObject untie = PerlOp.call("can", new PlArray(tied, new PlString("UNTIE")), PlCx.SCALAR);
            if (untie.to_boolean()) {
                untie.apply(PlCx.VOID, new PlArray(tied));
            };
            this.tied = null;
            return tied;
        }
        return this;
    }
    public PlObject tied() {
        if (this.o.is_filehandle()) {
            return this.o.tied();
        }

        if (this.tied != null) {
            return this.tied;
        }
        return PlCx.UNDEF;
    }
 
    // internal lazy api
    public PlLvalue create_scalar() {
        if (this.o.is_undef()) {
            PlLvalue llv = new PlLvalue();
            this.set(new PlLvalueRef(llv));
            return llv;
        }
        else if (this.o.is_scalarref()) {
            return (PlLvalue)this.o.scalar_deref("main");
        }
        return (PlLvalue)PlCORE.die("Not a SCALAR reference");
    }

    public PlObject pos() {
        // TODO - optimize: we are adding "pos" (Integer) to all PlLvalue objects
        if (this.pos == null) {
            return PlCx.UNDEF;
        }
        return new PlInt(this.pos);
    }
    public PlObject set_pos(PlObject value) {
        this.regex_zero_length_flag = false;
        if (value.is_undef()) {
            this.pos = null;
        }
        else {
            this.pos = value.to_int();
        }
        return value;
    }

    public PlScalarImmutable get() {
        if (this.tied != null) {
            PlScalarImmutable v = PerlOp.call("FETCH", new PlArray(tied), PlCx.VOID).scalar();
            this.o = v;
            return v;
        }
        return this.o;
    }
    public PlObject get_scalarref() {
        PlScalarImmutable o = this.get();
        if (o.is_undef()) {
            PlLvalueRef ar = new PlLvalueRef(new PlLvalue());
            this.set(ar);
            return ar;
        }
        else if (o.is_scalarref()) {
            return o;
        }
        // Modification of a read-only value attempted
        return o;
    }
    public PlObject get_arrayref() {
        PlScalarImmutable o = this.get();
        if (o.is_undef()) {
            PlArrayRef ar = new PlArrayRef();
            this.set(ar);
            return ar;
        }
        else if (o.is_arrayref()) {
            return o;
        }
        return PlCORE.die("Not an ARRAY reference");
    }
    public PlObject get_hashref() {
        PlScalarImmutable o = this.get();
        if (o.is_undef()) {
            PlHashRef hr = new PlHashRef();
            this.set(hr);
            return hr;
        }
        else if (o.is_hashref()) {
            return o;
        }
        return PlCORE.die("Not a HASH reference");
    }
    public PlObject aget(int i) {
        PlScalarImmutable o = this.get();
        if (o.is_undef()) {
            o = new PlArrayRef();
            this.set(o);
        }
        return o.aget(i);
    }

    public PlObject aget_scalarref(int i) {
        PlScalarImmutable o = this.get();
        if (o.is_undef()) {
            o = new PlArrayRef();
            this.set(o);
        }
        return o.aget_scalarref(i);
    }
    public PlObject aget_arrayref(int i) {
        PlScalarImmutable o = this.get();
        if (o.is_undef()) {
            o = new PlArrayRef();
            this.set(o);
        }
        return o.aget_arrayref(i);
    }
    public PlObject aget_lvalue(int pos) {
        PlScalarImmutable o = this.get();
        if (o.is_undef()) {
            o = new PlArrayRef();
            this.set(o);
        }
        return o.aget_lvalue(pos);
    }
    public PlObject aget_hashref(int i) {
        PlScalarImmutable o = this.get();
        if (o.is_undef()) {
            o = new PlArrayRef();
            this.set(o);
        }
        return o.aget_hashref(i);
    }

    public PlObject aset(int i, PlObject v) {
        PlScalarImmutable o = this.get();
        if (o.is_undef()) {
            o = new PlArrayRef();
            this.set(o);
        }
        return o.aset(i, v);
    }
    public PlObject hget(String i) {
        PlScalarImmutable o = this.get();
        if (o.is_undef()) {
            o = new PlHashRef();
            this.set(o);
        }
        return o.hget(i);
    }
    public PlObject hget_lvalue(String i) {
        PlScalarImmutable o = this.get();
        if (o.is_undef()) {
            o = new PlHashRef();
            this.set(o);
        }
        return o.hget_lvalue(i);
    }

    public PlObject hget_scalarref(String i) {
        PlScalarImmutable o = this.get();
        if (o.is_undef()) {
            o = new PlHashRef();
            this.set(o);
        }
        return o.hget_scalarref(i);
    }
    public PlObject hget_arrayref(String i) {
        PlScalarImmutable o = this.get();
        if (o.is_undef()) {
            o = new PlHashRef();
            this.set(o);
        }
        return o.hget_arrayref(i);
    }
    public PlObject hget_hashref(String i) {
        PlScalarImmutable o = this.get();
        if (o.is_undef()) {
            o = new PlHashRef();
            this.set(o);
        }
        return o.hget_hashref(i);
    }

    public PlObject hset(String s, PlObject v) {
        PlScalarImmutable o = this.get();
        if (o.is_undef()) {
            o = new PlHashRef();
            this.set(o);
        }
        return o.hset(s, v);
    }
    public PlObject hset(String s, PlLvalue v) {
        PlScalarImmutable o = this.get();
        if (o.is_undef()) {
            o = new PlHashRef();
            this.set(o);
        }
        return o.hset(s, v.get());
    }

    public PlObject scalar_deref(String namespace) {
        PlScalarImmutable o = this.get();
        if (o.is_undef()) {
            return new PlLazyScalarref(this);
        }
        return o.scalar_deref(namespace);
    }
    public PlObject scalar_deref_strict() {
        PlScalarImmutable o = this.get();
        return o.scalar_deref_strict();
    }
    public PlObject scalar_deref_lvalue(String namespace) {
        PlScalarImmutable o = this.get();
        if (o.is_undef()) {
            PlLvalue lv = new PlLvalue();
            this.set(new PlLvalueRef(lv));
            return lv;
        }
        return o.scalar_deref_lvalue(namespace);
    }
    public PlObject scalar_deref_set(String namespace, PlObject v) {
        PlScalarImmutable o = this.get();
        if (o.is_undef()) {
            PlLvalueRef ar = new PlLvalueRef(new PlLvalue());
            this.set(ar);
        }
        return o.scalar_deref_set(namespace, v);
    }

    public PlArray array_deref(String namespace) {
        // @$x doesn't autovivify
        PlScalarImmutable o = this.get();
        if (o.is_undef()) {
            return new PlArray();
        }
        else if (o.is_arrayref()) {
            return (PlArray)(o.array_deref(namespace));
        }
        return o.array_deref(namespace);
    }
    public PlArray array_deref_strict() {
        // @$x doesn't autovivify
        PlScalarImmutable o = this.get();
        return (PlArray)(o.array_deref_strict());
    }
    public PlArray array_deref_lvalue() {
        PlScalarImmutable o = this.get();
        if (o.is_undef()) {
            PlArrayRef ar = new PlArrayRef();
            this.set(ar);
            return (PlArray)(ar.array_deref_lvalue());
        }
        else if (o.is_arrayref()) {
            return (PlArray)(o.array_deref_lvalue());
        }
        return o.array_deref_strict();
    }
    public PlObject array_deref_set(PlObject v) {
        // @$x = ...
        PlScalarImmutable o = this.get();
        if (o.is_undef()) {
            o = new PlArrayRef();
            this.set(o);
            return o.array_deref_set(v);
        }
        else if (o.is_arrayref()) {
            return o.array_deref_set(v);
        }
        return o.array_deref_set(v);
    }

    public PlObject hash_deref(String namespace) {
        // %$x doesn't autovivify
        PlScalarImmutable o = this.get();
        if (o.is_undef()) {
            return new PlHash();
        }
        else if (o.is_hashref()) {
            return o.hash_deref(namespace);
        }
        return o.hash_deref(namespace);
    }
    public PlHash hash_deref_strict() {
        // %$x doesn't autovivify
        PlScalarImmutable o = this.get();
        return o.hash_deref_strict();
    }
    public PlObject hash_deref_set(PlObject v) {
        // %$x = ...
        PlScalarImmutable o = this.get();
        if (o.is_undef()) {
            o = new PlHashRef();
            this.set(o);
            return o.hash_deref_set(v);
        }
        else if (o.is_hashref()) {
            return o.hash_deref_set(v);
        }
        return o.hash_deref_set(v);
    }

    // Note: several versions of set()
    public PlObject set(PlObject o) {
        if (o == null) {
            o = PlCx.UNDEF;
        }
        if (o.is_lvalue()) {
            o = o.get();
        }
        if (this.tied != null) {
            PerlOp.call("STORE", new PlArray(tied, o), PlCx.VOID);
            return this;
        }
        this.o = (PlScalarImmutable)o;
        return this;
    }
    public PlObject set(PlScalarImmutable o) {
        if (this.tied != null) {
            PerlOp.call("STORE", new PlArray(tied, o), PlCx.VOID);
            return this;
        }
        this.o = o;
        return this;
    }
    public PlObject set(PlLvalue o) {
        if (this.tied != null) {
            PerlOp.call("STORE", new PlArray(tied, o), PlCx.VOID);
            return this;
        }
        this.o = o.get();
        return this;
    }
    public PlObject set(PlArray o) {
        // $a = @x
        return this.set(o.scalar());
    }
    public PlObject set(PlHash o) {
        // $a = %x
        return this.set(o.scalar());
    }
    public PlObject set(Object o) {
        // $a = new Object()
        return this.set(PlJavaObject.fromObject(o));
    }
    public PlObject set(String s) {
        if (s == null) {
            this.set(PlCx.UNDEF);
            return this;
        }
        this.set(new PlString(s));
        return this;
    }
    public PlObject set(boolean s) {
        this.set(new PlBool(s));
        return this;
    }
    public PlObject set(double s) {
        this.set(new PlDouble(s));
        return this;
    }
    public PlObject set(long s) {
        this.set(new PlInt(s));
        return this;
    }

    public PlScalarImmutable length() {
        return this.get().length();
    }
    public PlObject apply(int want, PlArray List__) {
        return this.get().apply(want, List__);
    }
    public PlObject hexists(String a) {
        // exists $v->{$a}
        return this.get().hexists(a);
    }
    public PlObject hexists(PlObject a) {
        // exists $v->{$a}
        return this.get().hexists(a);
    }
    public PlObject aexists(PlObject a) {
        // exists $v->[$a]
        return this.get().aexists(a);
    }
    public PlObject hdelete(int want, PlObject a) {
        // delete $v->{$a}
        return this.get().hdelete(want, a);
    }
    public PlObject adelete(int want, PlObject a) {
        // delete $v->[$a]
        return this.get().adelete(want, a);
    }

    public PlObject vecSet(PlObject pOffset, PlObject pBits, PlObject pValue) {
        // vec($i,  0, 32) = 0x5065726C
        String vv  = this.toString();
        int offset = pOffset.to_int();
        if (offset < 0) {
            return PlCORE.die("Negative offset to vec in lvalue context: " + offset);
        }
        int bits   = pBits.to_int();
        long value = pValue.to_long();
        StringBuilder sb = new StringBuilder(vv);
        if (bits == 1) {
            int byteOfs = offset / 8;
            int bitOfs  = offset - 8 * byteOfs;
            value = (value & 0b0001) << bitOfs;
            long mask = 0b0001 << bitOfs;
            if (byteOfs < sb.length()) {
                value = (sb.charAt(byteOfs) & ~mask) | value;
            }
            // fallback to 8bit
            offset = byteOfs;
            bits = 8;
        }
        if (bits == 2) {
            int byteOfs = offset / 4;
            int bitOfs  = 2 * (offset - 4 * byteOfs);
            value = (value & 0b0011) << bitOfs;
            long mask = 0b0011 << bitOfs;
            if (byteOfs < sb.length()) {
                value = (sb.charAt(byteOfs) & ~mask) | value;
            }
            // fallback to 8bit
            offset = byteOfs;
            bits = 8;
        }
        if (bits == 4) {
            int byteOfs = offset / 2;
            int bitOfs  = 4 * (offset - 2 * byteOfs);
            value = (value & 0b1111) << bitOfs;
            long mask = 0b1111 << bitOfs;
            if (byteOfs < sb.length()) {
                value = (sb.charAt(byteOfs) & ~mask) | value;
            }
            // fallback to 8bit
            offset = byteOfs;
            bits = 8;
        }
        if (bits == 8) {
            if (offset >= sb.length()) {
                sb.setLength(offset + 1);
            }
            sb.setCharAt(offset, (char)(value & 0xFF));
            return this.set(new PlString(sb.toString()));
        }
        if (bits == 16) {
            if ((offset + 1) >= sb.length()) {
                sb.setLength(offset + 2);
            }
            sb.setCharAt(offset,     (char)((value >> 8) & 0xFF));
            sb.setCharAt(offset + 1, (char)(value & 0xFF));
            return this.set(new PlString(sb.toString()));
        }
        if (bits == 32) {
            if ((offset + 3) >= sb.length()) {
                sb.setLength(offset + 4);
            }
            sb.setCharAt(offset,     (char)((value >> 24) & 0xFF));
            sb.setCharAt(offset + 1, (char)((value >> 16) & 0xFF));
            sb.setCharAt(offset + 2, (char)((value >>  8) & 0xFF));
            sb.setCharAt(offset + 3, (char)(value & 0xFF));
            return this.set(new PlString(sb.toString()));
        }
        return PlCORE.die("Illegal number of bits in vec: " + bits);
    }

    public boolean is_lvalue() {
        return true;
    }
    public Object toJava() {
        PlScalarImmutable res = this.get();
        if ( res.is_JavaObject() ) {
            return res.toJava();
        }
        return res;
    }
 
    public PlObject pre_decr() {
        // --$x
        PlScalarImmutable res = this.get();
        return this.set((PlScalarImmutable)res._decr());
    }
    public PlObject post_decr() {
        // $x--
        PlScalarImmutable res = this.get();
        this.set((PlScalarImmutable)res._decr());
        return res;
    }
    public PlObject pre_incr() {
        // ++$x
        PlScalarImmutable res = this.get();
        return this.set((PlScalarImmutable)res._incr());
    }
    public PlObject post_incr() {
        // $x++
        PlScalarImmutable res = this.get();
        this.set((PlScalarImmutable)res._incr());
        return res;
    }
    public PlObject bless(String className) {
        return this.get().bless(className);
    }

    public PlObject set_prototype(PlObject v) {
        return this.get().set_prototype(v);
    }

    public PlObject pow(PlObject arg)    { return this.get().pow(arg); }
    public PlObject atan2(PlObject arg)  { return this.get().atan2(arg); }

    public PlScalarImmutable scalar() {
        return this.get();
    }
    public PlObject clone() throws CloneNotSupportedException {
        return this.get().clone();
    }

    public PlObject self_assign_or(PlObject s) {
        return (this.to_boolean() ? this : this.set(s));
    }
    public PlObject self_assign_and(PlObject s) {
        return (this.to_boolean() ? this.set(s) : this);
    }
EOT
    , ((map {
            my $perl = $_;
"    public PlObject ${perl}(PlObject s) {
        if (this.tied != null) {
            PlScalarImmutable v = PerlOp.call(\"FETCH\", new PlArray(tied), PlCx.VOID).scalar();
            this.o = v;
        }
        return this.o.${perl}(s);
    }
    public PlObject ${perl}2(PlObject s) {
        if (this.tied != null) {
            PlScalarImmutable v = PerlOp.call(\"FETCH\", new PlArray(tied), PlCx.VOID).scalar();
            this.o = v;
        }
        return s.${perl}(this.o);
    }
"
            }
            sort (
                'num_cmp',
                'mod',
                keys %number_binop,
            )
      ))

    , ((map {
            my $perl = $_;
"    public PlObject self_assign_${perl}(PlObject s) {
        return this.set(this.get()._self_${perl}(s));
    }
"
            }
            sort ( 'string_replicate',
                   keys %self_assign_number_binop,
            ),
      ))

    , ((map {
            my $perl = $_;
"    public PlObject self_assign_${perl}(PlObject s) {
        return PlCORE.die(\"not implemented\");
    }
"
            }
            sort ( 'str_and',
                   'str_or',
                   'str_xor',
            ),
      ))

        # unary operators
        #
    , ((map {
            my ($op, $type) = @$_;
"    public $type $op() {
        if (this.tied != null) {
            PlScalarImmutable v = PerlOp.call(\"FETCH\", new PlArray(tied), PlCx.VOID).scalar();
            this.o = v;
        }
        return this.o.$op();
    }
"
            }
            map( [ $_ => 'PlObject' ], (
                @number_unary,
                'blessed',
                'refaddr',      # Scalar::Util::refaddr()
                'reftype',      # Scalar::Util::reftype()
                'to_num',
            )),
            map( [ $_ => 'boolean' ], (
                @boolean_unary,
                'is_integer_range',
            )),
            [ 'toString'      => 'String'   ],
            [ 'to_int'        => 'int'      ],
            [ 'to_long'       => 'long'     ],
            [ 'to_double'     => 'double'   ],
            [ 'to_boolean'    => 'boolean'  ],
            [ 'blessed_class' => 'PlClass'  ],
            [ 'ref'           => 'PlString' ],
            [ 'ref_str'       => 'String'   ],
            [ 'ref_boolean'   => 'boolean'  ],

            # add "unbox" accessors to Java classes that were declared with:  'package MyJavaClass { Java }'
            (map {  my $class = $java_classes{$_};
                    $class->{import} || $class->{extends} || $class->{implements}
                      ? [ $class->{perl_to_java}, $class->{java_type} ]
                      : ()
                 }
                 grep { $java_classes{$_}{perl_to_java} }
                 sort keys %java_classes
            ),
      ))

    , <<'EOT'

}

EOT
    ,   # list break
<<'EOT'

class PlROvalue extends PlLvalue {

    // Note: several versions of PlROvalue()
    public PlROvalue() {
        this.o = PlCx.UNDEF;
    }
    public PlROvalue(PlObject o) {
        this.o = (PlScalarImmutable)o;
    }
    public PlROvalue(PlScalarImmutable o) {
        this.o = o;
    }
    public PlROvalue(PlLvalue o) {
        this.o = o.get();
    }
    public PlROvalue(PlArray o) {
        // $a = @x
        this.o = o.scalar();
    }
    public PlROvalue(PlHash o) {
        // $a = %x
        this.o = o.scalar();
    }

    public PlObject set(Object o) {
        PlCORE.die("Modification of a read-only value attempted");
        return this;
    }
    public PlObject set(PlScalarImmutable o) {
        return PlCORE.die("Modification of a read-only value attempted");
    }
    public PlObject set(PlLvalue o) {
        return PlCORE.die("Modification of a read-only value attempted");
    }

    public PlObject pre_decr() {
        return PlCORE.die("Modification of a read-only value attempted");
    }
    public PlObject post_decr() {
        return PlCORE.die("Modification of a read-only value attempted");
    }
    public PlObject pre_incr() {
        return PlCORE.die("Modification of a read-only value attempted");
    }
    public PlObject post_incr() {
        return PlCORE.die("Modification of a read-only value attempted");
    }

}
class PlSlice extends PlArray {
    public PlSlice( PlArrayList a ) {
        this.each_iterator = 0;
        this.a = a;
    }

    public boolean is_slice() {
        return true;
    }
}

class PlTieArrayIterator implements Iterator<PlObject> {
    public PlObject tied;
    private int key;

    public PlTieArrayIterator(PlObject tied) {
        this.tied = tied;
    }
    public PlObject next() {
        return PerlOp.call("FETCH", new PlArray(this.tied, new PlInt(this.key)), PlCx.SCALAR);
    }
    public boolean hasNext() {
        return this.key < PerlOp.call("FETCHSIZE", new PlArray(this.tied), PlCx.SCALAR).to_int();
    }
}
class PlTieArrayList extends PlArrayList {
    public PlObject tied;
    public PlArrayList old_var;

    public PlTieArrayList() {
    }
    // add(PlObject)
    // add(pos, PlObject)
    // get(pos)
    // remove(pos)
    // set(pos, PlObject)
    // size()
    // clear()
    // iterator()

    public boolean add(PlObject v) {
        PerlOp.call("PUSH", new PlArray(this.tied, v), PlCx.SCALAR);
        return true;
    }
    public void add(int i, PlObject v) {
        if (i == 0) {
            PerlOp.call("UNSHIFT", new PlArray(tied, v), PlCx.SCALAR);
        }
        else {
            PerlOp.call("PUSH", new PlArray(tied, v), PlCx.SCALAR);
        }
    }
    public PlScalarImmutable get(int i) {
        return PerlOp.call("FETCH", new PlArray(tied, new PlInt(i)), PlCx.SCALAR).scalar();
    }
    public PlObject remove(int i) {
        if (i == 0) {
            return PerlOp.call("SHIFT", new PlArray(tied), PlCx.SCALAR);
        }
        return PerlOp.call("POP", new PlArray(tied), PlCx.SCALAR);
    }
    public PlObject set(int i, PlObject v) {
        return PerlOp.call("STORE", new PlArray(tied, new PlInt(i), v), PlCx.SCALAR);
    }
    public int size() {
        return PerlOp.call("FETCHSIZE", new PlArray(tied), PlCx.SCALAR).to_int();
    }
    public void clear() {
        PerlOp.call("STORESIZE", new PlArray(tied, PlCx.INT0), PlCx.SCALAR);
    }
    public Iterator<PlObject> iterator() {
        return new PlTieArrayIterator(this.tied);
    }

    // Perl API
    // add == PUSH
    // add(0, v) == UNSHIFT

    public PlObject aexists(PlObject i) {
        return PerlOp.call("EXISTS", new PlArray(tied, i), PlCx.SCALAR);
    }
    public PlObject adelete(int want, PlObject i) {
        return PerlOp.call("DELETE", new PlArray(tied, i), want);
    }

    public PlObject set_end_of_array_index(int i) {
        return PerlOp.call("STORESIZE", new PlArray(tied), PlCx.SCALAR);
    }
    public PlObject aset(int i, PlObject v) {
        this.set(i, v);
        return v;
    }
    public PlObject aget(int i) {
        return this.get(i);
    }
    public PlObject shift() {
        return PerlOp.call("SHIFT", new PlArray(tied), PlCx.SCALAR);
    }
    public PlObject pop() {
        return PerlOp.call("POP", new PlArray(tied), PlCx.SCALAR);
    }

    public PlScalarImmutable scalar() {
        return PerlOp.call("SCALAR", new PlArray(this.tied), PlCx.SCALAR).scalar();
    }
    public boolean is_tiedArray() {
        return true;
    }
    public PlObject tied() {
        return this.tied;
    }
} // PlTieArrayList
class PlArrayList extends ArrayList<PlObject> implements Iterable<PlObject> {
    public PlArrayList() {
    }
    // add(PlObject)
    // add(pos, PlObject)
    // get(pos)
    // remove(pos)
    // set(pos, PlObject)
    // size()
    // clear()
    // iterator()

    // Perl API

    public PlObject aexists(PlObject i) {
        int pos  = i.to_int();
        if (pos < 0) {
            pos = this.size() + pos;
        }
        if (pos < 0 || pos >= this.size()) {
            return PlCx.FALSE;
        }
        return PlCx.TRUE;
    }
    public PlObject adelete(int want, PlObject i) {
        int pos  = i.to_int();
        if (pos < 0) {
            pos = this.size() + pos;
        }
        if ((pos+1) == this.size()) {
            return this.pop();
        }
        if (pos < 0 || pos >= this.size()) {
            return PlCx.FALSE;
        }
        PlObject res = this.aget(pos);
        this.aset(pos, PlCx.UNDEF);
        return res;
    }

    public PlObject set_end_of_array_index(int i) {
        int size = i + 1;
        while (this.size() < size) {
            this.add(PlCx.UNDEF);
        }
        if (size < this.size() && this.size() > 0) {
            this.removeRange(size, this.size());
        }
        return new PlInt(this.size());
    }
    public PlObject aset(int i, PlObject v) {
        int size = this.size();
        int pos  = i;
        if (pos < 0) {
            pos = size + pos;
        }
        if (size <= pos) {
            while (size < pos) {
                this.add( PlCx.UNDEF );
                size++;
            }
            this.add(v.scalar());
            return v;
        }
        PlObject old = this.get(pos);
        if (old.is_lvalue()) {
            old.set(v.scalar());
        }
        else {
            this.set(pos, v.scalar());
        }
        return v;
    }
    public PlObject aget(int i) {
        int pos  = i;
        if (pos < 0) {
            pos = this.size() + pos;
        }
        if (pos < 0 || pos >= this.size()) {
            return PlCx.UNDEF;
        }
        return this.get(pos);
    }
    public PlObject shift() {
        int size = this.size();
        if (size > 0) {
            return this.remove(0);
        }
        else {
            return PlCx.UNDEF;
        }
    }
    public PlObject pop() {
        int size = this.size() - 1;
        if (size >= 0) {
            return this.remove(size);
        }
        else {
            return PlCx.UNDEF;
        }
    }

    public PlScalarImmutable scalar() {
        return new PlInt(this.hashCode());
    }
    public boolean is_tiedArray() {
        return false;
    }
    public PlObject tied() {
        return PlCx.UNDEF;
    }
}
class PlArrayLvalueIterator implements Iterator<PlObject> {
    private final PlArray ar;
    private final PlArrayList a;
    private int pos;
    public PlArrayLvalueIterator(PlArray ar) {
        this.ar = ar;
        this.a = ar.a;
        this.pos = 0;
    }
    public PlObject next() {
        PlObject o = this.a.get(pos);
        if (o == null) {
            return new PlLazyIndex(this.ar, pos++);
        }
        if (o.is_lvalue()) {
            pos++;
            return o;
        }
        PlLvalue la = new PlLvalue(o);
        this.a.set(pos++, la);
        return la;
    }
    public boolean hasNext() {
        return pos < this.a.size();
    }
}
class PlArray extends PlObject implements Iterable<PlObject> {
    public PlArrayList a;
    public int each_iterator;

    public Iterator<PlObject> iterator() {
        return new PlArrayLvalueIterator(this); 
    }

    public PlArray( PlArrayList a ) {
        this.each_iterator = 0;
        this.a = a;
    }
    public PlArray() {
        this.each_iterator = 0;
        this.a = new PlArrayList();
    }
    public PlArray(PlObject... args) {
        PlArrayList aa = new PlArrayList();
        for (PlObject s : args) {
            if (s.is_hash()) {
                // @x = %x;
                s = s.to_array();
            }
            if (s.is_array()) {
                // @x = ( @x, @y );
                for (int i = 0; i < s.to_long(); i++) {
                    PlObject v = s.aget(i);
                    if (v.is_lvalue()) {
                        v = v.get();
                    }
                    aa.add(v);
                }
            }
            else if (s.is_lvalue()) {
                aa.add(s.get());
            }
            else {
                aa.add(s);
            }
        }
        this.each_iterator = 0;
        this.a = aa;
    }

    // TODO - this is part of a possible optimization to: split("", $str)
    // public PlArray(char... args) {
    //     PlArrayList aa = new PlArrayList();
    //     for (char s : args) {
    //         aa.add(new PlString(s));
    //     }
    //     this.each_iterator = 0;
    //     this.a = aa;
    // }

    // tie hash
    public PlObject tie(PlArray args) {
        if (this.a.is_tiedArray()) {
            this.untie();
        }
        PlTieArrayList v = new PlTieArrayList();
        PlObject self = PerlOp.call("TIEARRAY", args, PlCx.VOID);
        v.tied = self;
        v.old_var = this.a;
        this.a = v;
        return self;
    }

    public PlObject untie() {
        if (this.a.is_tiedArray()) {
            PlObject tied = this.a.tied();
            PlObject untie = PerlOp.call("can", new PlArray(tied, new PlString("UNTIE")), PlCx.SCALAR);
            if (untie.to_boolean()) {
                untie.apply(PlCx.VOID, new PlArray(tied));
            };
            this.a = ((PlTieArrayList)a).old_var;
            return tied;
        }
        return this;
    }
    public PlObject tied() {
        return a.tied();
    }

    // internal lazy api
    public PlLvalue create_scalar(int i) {
        int size = this.a.size();
        int pos  = i;
        if (pos < 0) {
            return (PlLvalue)PlCORE.die("internal error: negative index on PlArray.create_scalar()");
        }
        if (size <= pos) {
            while (size < pos) {
                this.a.add( PlCx.UNDEF );
                size++;
            }
            PlLvalue v = new PlLvalue();
            this.a.add(v);
            return v;
        }
        PlObject old = this.a.get(pos);
        if (old.is_lvalue()) {
            return (PlLvalue)old;
        }
        if (old.is_undef()) {
            PlLvalue v = new PlLvalue();
            this.a.set(pos, v);
            return v;
        }
        return (PlLvalue)PlCORE.die("Not a SCALAR reference");
    }

    public static PlArray construct_list_of_aliases(PlScalarImmutable s) {
        PlArrayList aa = new PlArrayList();
        aa.add(new PlROvalue(s));  // store lvalue as read-only
        return new PlArray(aa);
    }
    public static PlArray construct_list_of_aliases(PlScalarImmutable s1, PlScalarImmutable s2) {
        PlArrayList aa = new PlArrayList();
        aa.add(new PlROvalue(s1));  // store lvalue as read-only
        aa.add(new PlROvalue(s2));  // store lvalue as read-only
        return new PlArray(aa);
    }
    public static PlArray construct_list_of_aliases(PlScalarImmutable... args) {
        PlArrayList aa = new PlArrayList();
        for (PlObject s : args) {
            aa.add(new PlROvalue(s));  // store "read only"
        }
        return new PlArray(aa);
    }

    public static PlArray construct_list_of_aliases(PlLvalue s) {
        PlArrayList aa = new PlArrayList();
        aa.add(s);  // store lvalue as-is
        return new PlArray(aa);
    }
    public static PlArray construct_list_of_aliases(PlLvalue s1, PlLvalue s2) {
        PlArrayList aa = new PlArrayList();
        aa.add(s1);  // store lvalue as-is
        aa.add(s2);  // store lvalue as-is
        return new PlArray(aa);
    }

    public static PlArray construct_list_of_aliases(PlArray s) {
        PlArrayList aa = new PlArrayList();
        int ll = s.to_int();
        for (int i = 0; i < ll; i++) {
            aa.add(s.aget_lvalue(i));
        }
        return new PlArray(aa);
    }
    public static PlArray construct_list_of_aliases(PlObject s) {
        PlArrayList aa = new PlArrayList();
        if (s.is_lvalue()) {
            aa.add(s);  // store lvalue as-is
        }
        else if (s.is_hash()) {
            // ( %x );
            s = ((PlHash)s).to_list_of_aliases();
            for (int i = 0; i < s.to_long(); i++) {
                aa.add(s.aget_lvalue(i));
            }
        }
        else if (s.is_array()) {
            // ( @x, @y );
            int ll = s.to_int();
            for (int i = 0; i < ll; i++) {
                aa.add(s.aget_lvalue(i));
            }
        }
        else {
            aa.add(new PlROvalue(s));  // store "read only"
        }
        return new PlArray(aa);
    }
    public static PlArray construct_list_of_aliases(PlObject... args) {
        PlArrayList aa = new PlArrayList();
        for (PlObject s : args) {
            if (s.is_lvalue()) {
                aa.add(s);  // store lvalue as-is
            }
            else if (s.is_hash()) {
                // ( %x );
                s = ((PlHash)s).to_list_of_aliases();
                for (int i = 0; i < s.to_long(); i++) {
                    aa.add(s.aget_lvalue(i));
                }
            }
            else if (s.is_array()) {
                // ( @x, @y );
                int ll = s.to_int();
                for (int i = 0; i < ll; i++) {
                    aa.add(s.aget_lvalue(i));
                }
            }
            else {
                aa.add(new PlROvalue(s));  // store "read only"
            }
        }
        return new PlArray(aa);
    }
    public static PlArray construct_list_of_aliases(Object... args) {
        PlArrayList aa = new PlArrayList();
        for (Object s1 : args) {
            PlObject s = PlJavaObject.fromObject(s1);
            if (s.is_lvalue()) {
                aa.add(s);  // store lvalue as-is
            }
            else if (s.is_hash()) {
                // ( %x );
                s = ((PlHash)s).to_list_of_aliases();
                for (int i = 0; i < s.to_long(); i++) {
                    aa.add(s.aget_lvalue(i));
                }
            }
            else if (s.is_array()) {
                // ( @x, @y );
                int ll = s.to_int();
                for (int i = 0; i < ll; i++) {
                    aa.add(s.aget_lvalue(i));
                }
            }
            else {
                aa.add(new PlROvalue(s));  // store "read only"
            }
        }
        return new PlArray(aa);
    }

    public static PlArray construct_list_of_references(PlObject... args) {
        PlArray aa = PlArray.construct_list_of_aliases(args);
        PlArray result = new PlArray();
        for (PlObject s : aa) {
            result.push_void(new PlLvalueRef(s));
        }
        return result;
    }

    public static void static_list_set(PlObject src, PlLvalue... args) {
        int count = 0;
        for (PlLvalue s : args) {
            s.set(src.aget(count++));
        }
    }
    public static void static_list_set(PlObject src_list, PlObject... args) {
        PlArray src = new PlArray(src_list);
        for (PlObject s : args) {
            if (s.is_hash()) {
                // ( %x );
                ((PlHash)s).set(PlCx.VOID, src);
                src = new PlArray();
            }
            else if (s.is_slice()) {
                // ( @x[3,4] ); - "slice" is not "slurpy"
                int s_size = s.to_int();
                for (int i = 0; i < s_size; i++) {
                    s.aset(i, src.shift());
                }
            }
            else if (s.is_array()) {
                // ( @x ); - "array" is "slurpy"
                s.set(src);
                src = new PlArray();
            }
            else if (s.is_lvalue()) {
                PlObject o = src.shift();
                s.set(o);
            }
            else if (s.is_undef()) {
                src.shift();   // skip
            }
            else {
                PlCORE.die("Can't modify constant item in list assignment");
            }
        }
    }

    public static PlObject static_list_set(int want, PlObject src, PlLvalue... args) {
        int count = 0;
        for (PlLvalue s : args) {
            s.set(src.aget(count++));
        }
        if (want == PlCx.VOID) {
            return PlCx.UNDEF;
        }
        if (want == PlCx.LIST) {
            return PlArray.construct_list_of_aliases(args);
        }
        return src.scalar();
    }
    public static PlObject static_list_set(int want, PlObject src_list, PlObject... args) {
        PlArray src = new PlArray(src_list);
        for (PlObject s : args) {
            if (s.is_hash()) {
                // ( %x );
                ((PlHash)s).set(PlCx.VOID, src);
                src = new PlArray();
            }
            else if (s.is_slice()) {
                // ( @x[3,4] ); - "slice" is not "slurpy"
                int s_size = s.to_int();
                for (int i = 0; i < s_size; i++) {
                    s.aset(i, src.shift());
                }
            }
            else if (s.is_array()) {
                // ( @x ); - "array" is "slurpy"
                s.set(src);
                src = new PlArray();
            }
            else if (s.is_lvalue()) {
                PlObject o = src.shift();
                s.set(o);
            }
            else if (s.is_undef()) {
                src.shift();   // skip
            }
            else {
                PlCORE.die("Can't modify constant item in list assignment");
            }
        }
        if (want == PlCx.VOID) {
            return PlCx.UNDEF;
        }
        if (want == PlCx.LIST) {
            return PlArray.construct_list_of_aliases(args);
        }
        return src_list.scalar();
    }
    public PlObject list_set(int want, PlArray s) {
        // @x[3,4] = ( @x, @y );
        for (int i = 0; i < this.to_long(); i++) {
            this.aset(i, s.aget(i));
        }
        this.each_iterator = 0;
        if (want == PlCx.LIST) {
            return this;
        }
        return this.pop();
    }

    public PlObject set(PlObject s) {
        this.a.clear();
        PlObject tmp;
        if (s.is_hash()) {
            // @x = %x;
            s = s.to_array();
        }
        if (s.is_array()) {
            // @x = ( @x, @y );
            for (int i = 0; i < s.to_long(); i++) {
                tmp = s.aget(i);
                if (tmp.is_lvalue()) {
                    this.a.add(tmp.get());
                }
                else {
                    this.a.add(tmp);
                }
            }
        }
        else {
            this.a.add(s);
        }
        this.each_iterator = 0;
        return this;
    }

    public PlObject set(Map<String, String> env) {
        this.a.clear();
        for (String envName : env.keySet()) {
            this.a.add(new PlString(envName));
            this.a.add(new PlString(env.get(envName)));
        }
        this.each_iterator = 0;
        return this;
    }
    public PlArray(Map<String, String> strings) {
        PlArray arr = new PlArray();
        arr.set(strings);
        this.each_iterator = arr.each_iterator;
        this.a = arr.a;
    }

EOT
        # add "box" array-of Java classes
        # that were declared with
        #
        #   package MyJavaClass { Java }
        #
    , ((map {
            my $native = $_;
            my $perl   = $native_to_perl{$native};
            $native && $perl ? 
"    public PlObject set(${native}[] stuffs) {
        this.a.clear();
        // \@x = ${native}[] native;
        for(${native} i : stuffs){
            this.a.add(new ${perl}(i));
        }
        this.each_iterator = 0;
        return this;
    }
    public PlArray(${native}[] stuffs) {
        PlArray aa = new PlArray();
        aa.set(stuffs);
        this.each_iterator = aa.each_iterator;
        this.a = aa.a;
    }
" : ()
            }
            sort keys %native_to_perl ))

    , <<'EOT'
    public PlObject aget(int i) {
        return this.a.aget(i);
    }
    public PlObject aget_lvalue(int pos) {
        int size = this.a.size();
        if (pos < 0) {
            pos = size + pos;
        }
        if (size <= pos) {
            return new PlLazyIndex(this, pos);
        }
        PlObject o = this.a.get(pos);
        if (o == null) {
            return new PlLazyIndex(this, pos);
        }
        if (o.is_lvalue()) {
            return o;
        }
        PlLvalue a = new PlLvalue(o);
        this.a.set(pos, a);
        return a;
    }
    public PlObject aget_lvalue_local(int i) {
        PlObject o = this.a.get(i);
        if (o == null) {
            this.a.set(i, PlCx.UNDEF);
        }
        return PerlOp.push_local(this, i);
    }

    public PlObject aget_list_of_aliases(int want, PlArray a) {
        // @a[LIST]
        PlArrayList aa = new PlArrayList();
        for (PlObject i : a) {
            aa.add( this.aget_lvalue(i.to_int()) );
        }
        PlSlice result = new PlSlice(aa);
        if (want == PlCx.LIST) {
            return result;
        }
        return result.pop();
    }
    public PlObject aget_hash_list_of_aliases(int want, PlArray a) {
        // %a[LIST]
        PlArrayList aa = new PlArrayList();
        for (PlObject i : a) {
            aa.add( i );
            aa.add( this.aget_lvalue(i.to_int()) );
        }
        PlSlice result = new PlSlice(aa);
        if (want == PlCx.LIST) {
            return result;
        }
        return result.pop();
    }

    public PlObject get_scalar(PlObject s) {
        // $$x
        int i = s.to_int();
        PlObject o = this.a.aget(i);
        if (o.is_undef()) {
            PlLvalue a = new PlLvalue();
            this.a.aset(i, new PlLvalueRef(a));
            return a;
        }
        else if (o.is_scalarref()) {
            return o.get();
        }
        // Modification of a read-only value attempted
        // return PlCORE.die("Not an SCALAR reference");
        return o;
    }
    public PlObject aget_scalarref(int i) {
        PlObject o = this.a.aget(i);
        if (o.is_undef()) {
            return new PlLvalueRef(new PlLazyScalarref(new PlLazyIndex(this, i)));
        }
        return o;
    }

    public PlObject aget_arrayref(int i) {
        PlObject o = this.a.aget(i);
        if (o.is_undef()) {
            PlArrayRef ar = new PlArrayRef();
            this.a.aset(i, ar);
            return ar;
        }
        return o;
    }

    public PlObject aget_hashref(int i) {
        PlObject o = this.a.aget(i);
        if (o.is_undef()) {
            PlHashRef hr = new PlHashRef();
            this.a.aset(i, hr);
            return hr;
        }
        return o;
    }

    public PlObject get_hash(int i) {
        PlObject o = this.a.aget(i);
        if (o.is_undef()) {
            PlHashRef hr = new PlHashRef();
            this.a.aset(i, hr);
            return hr;
        }
        else if (o.is_hashref()) {
            return o;
        }
        return PlCORE.die("Not a HASH reference");
    }

    // Note: multiple versions of set()
    public PlObject aset(int i, PlObject v) {
        return this.a.aset(i, v);
    }
    public PlObject aset(int i, PlLvalue v) {
        return this.a.aset(i, v.get());
    }

    public PlObject push(PlObject... args) {
        for (int i = 0; i < args.length; i++) {
            this.push_void(args[i]);
        }
        return new PlInt(this.a.size());
    }
    public void push_void(PlObject... args) {
        for (int i = 0; i < args.length; i++) {
            this.push_void(args[i]);
        }
    }

    public PlObject unshift(PlObject... args) {
        for (int i = args.length-1; i >= 0; i--) {
            this.unshift(args[i]);
        }
        return new PlInt(this.a.size());
    }
    public PlObject aset(int s, Object o) {
        return this.aset(s, PlJavaObject.fromObject(o));
    }
    public PlObject push(Object o) {
        return this.push(PlJavaObject.fromObject(o));
    }
    public void push_void(Object o) {
        this.push_void(PlJavaObject.fromObject(o));
    }
    public PlObject unshift(Object o) {
        return this.unshift(PlJavaObject.fromObject(o));
    }

EOT
    , ((map {
            my $native = $_;
            my $perl   = $native_to_perl{$native};
            $native && $perl ?
"    public PlObject aset(int i, $native s) {
        return this.aset(i, new $perl(s));
    }
    public PlObject push($native s) {
        return this.push(new $perl(s));
    }
    public void push_void($native s) {
        this.push_void(new $perl(s));
    }
    public PlObject unshift($native s) {
        return this.unshift(new $perl(s));
    }
" : ()
            }
            sort keys %native_to_perl ))

    , <<'EOT'
    public PlObject aset_alias(int i, PlLvalue lvalue) {
        return this.a.set(i, lvalue);
    }

    // Note: multiple versions of push()
    public PlObject push(PlObject v) {
        if (v.is_array()) {
            return this.push( (PlArray)v );
        }
        else if (v.is_hash()) {
            return this.push( (PlHash)v );
        }
        this.a.add(v.scalar());
        return new PlInt(this.a.size());
    }
    public void push_void(PlObject v) {
        if (v.is_array()) {
            this.push_void( (PlArray)v );
            return;
        }
        else if (v.is_hash()) {
            this.push_void( (PlHash)v );
            return;
        }
        this.a.add(v.scalar());
    }

    public PlObject push(PlLvalue v) {
        this.a.add(v.get());
        return new PlInt(this.a.size());
    }
    public void push_void(PlLvalue v) {
        this.a.add(v.get());
    }
    public PlObject push(PlHash args) {
        return push(args.to_array());
    }
    public void push_void(PlHash args) {
        push_void(args.to_array());
    }
    public PlObject push(PlArray args) {
        int size = args.a.size();
        for (int i = 0; i < size; i++) {
            PlObject s = args.aget(i);
            if (s.is_hash()) {
                // @x = %x;
                s = s.to_array();
            }
            if (s.is_array()) {
                this.push_void(s);
            }
            else {
                this.a.add(s);
            }
        }
        return new PlInt(this.a.size());
    }
    public void push_void(PlArray args) {
        int size = args.a.size();
        for (int i = 0; i < size; i++) {
            PlObject s = args.aget(i);
            if (s.is_hash()) {
                // @x = %x;
                s = s.to_array();
            }
            if (s.is_array()) {
                this.push_void(s);
            }
            else {
                this.a.add(s);
            }
        }
    }

    // Note: multiple versions of unshift()
    public PlObject unshift(PlObject v) {
        if (v.is_array()) {
            return this.unshift( (PlArray)v );
        }
        else if (v.is_hash()) {
            return this.unshift( (PlHash)v );
        }
        this.a.add(0, v.scalar());
        return new PlInt(this.a.size());
    }
    public PlObject unshift(PlLvalue v) {
        this.a.add(0, v.get());
        return new PlInt(this.a.size());
    }
    public PlObject unshift(PlHash args) {
        return unshift(args.to_array());
    }
    public PlObject unshift(PlArray args) {
        args = new PlArray(args);   // allow "unshift @x, @x" - TODO: optimize
        int size = args.a.size();
        for (int i = size - 1; i >= 0; i--) {
            PlObject s = args.aget(i);
            if (s.is_hash()) {
                // @x = %x;
                s = s.to_array();
            }
            if (s.is_array()) {
                this.unshift(s);
            }
            else {
                this.a.add(0, s);
            }
        }
        return new PlInt(this.a.size());
    }

    public PlObject pop() {
        return this.a.pop();
    }
    public PlObject shift() {
        return this.a.shift();
    }
    public PlObject aexists(PlObject i) {
        return this.a.aexists(i);
    }
    public PlObject adelete(int want, PlObject i) {
        return this.a.adelete(want, i);
    }
    public PlObject values() {
        // return a copy
        return new PlArray(this);
    }
    public PlObject keys() {
        PlArray aa = new PlArray();
        int size = this.to_int();
        for (int i = 0; i < size; i++) {
            aa.push_void(new PlInt(i));
        }
        return aa;
    }
    public PlObject each() {
        PlArray aa = new PlArray();
        int size = this.to_int();
        if (this.each_iterator < size) {
            aa.push_void(new PlInt(this.each_iterator));
            aa.push_void(this.a.aget(this.each_iterator));
            this.each_iterator++;
        }
        else {
            // return empty list
            this.each_iterator = 0;
        }
        return aa;
    }
    public String toString() {
        StringBuilder sb = new StringBuilder();
        int size = this.to_int();
        for (int i = 0; i < size; i++) {
            String item = this.a.aget(i).toString();
            sb.append(item);
        }
        return sb.toString();
    }
    public long to_long() {
        return this.a.size();
    }
    public int to_int() {
        return this.a.size();
    }
    public PlScalarImmutable length_of_array() {
        return new PlInt(this.a.size());
    }
    public boolean length_of_array_boolean() {
        return ( this.a.size() > 0 );
    }
    public int length_of_array_int() {
        return this.a.size();
    }
    public PlObject end_of_array_index() {
        return new PlInt(this.a.size() - 1);
    }
    public PlObject set_end_of_array_index(PlObject o) {
        return this.a.set_end_of_array_index(o.to_int());
    }
    public double to_double() {
        return 0.0 + this.to_long();
    }
    public boolean to_boolean() {
        return (this.a.size() > 0);
    }
    public PlObject to_num() {
        return new PlInt(this.a.size());
    }
    public boolean is_array() {
        return true;
    }
    public PlScalarImmutable scalar() {
        return new PlInt(this.a.size());
    }
}


class PlTieHashIterator implements Iterator<Map.Entry<String, PlObject>> {
    public PlObject tied;
    private PlObject key;

    public PlTieHashIterator(PlObject tied) {
        this.tied = tied;
    }
    public Map.Entry<String, PlObject> next() {
        return new AbstractMap.SimpleEntry<String, PlObject>(
                    this.key.toString(),
                    PerlOp.call("FETCH", new PlArray(this.tied, this.key), PlCx.SCALAR)
               );
    }
    public boolean hasNext() {
        if (this.key == null) {
            this.key = PerlOp.call("FIRSTKEY", new PlArray(this.tied), PlCx.SCALAR);
        }
        else {
            this.key = PerlOp.call("NEXTKEY", new PlArray(this.tied), PlCx.SCALAR);
        }
        return !this.key.is_undef();
    }
}
class PlTieHashMap extends PlHashMap {
    public PlObject tied;
    public PlHashMap old_var;

    public PlTieHashMap() {
    }
    // get(String)
    // put(String, PlObject)
    // containsKey(String)
    // remove(String)
    // clear()
    // entrySet().iterator() == iterator()

    public PlScalarImmutable get(Object i) {
        return PerlOp.call("FETCH", new PlArray(this.tied, new PlString((String)i)), PlCx.SCALAR).scalar();
    }
    public PlObject put(String i, PlObject v) {
        return PerlOp.call("STORE", new PlArray(this.tied, new PlString(i), v), PlCx.SCALAR);
    }
    public boolean containsKey(Object i) {
        return PerlOp.call("EXISTS", new PlArray(this.tied, new PlString((String)i)), PlCx.SCALAR).to_boolean();
    }
    public PlObject remove(Object i) {
        return PerlOp.call("DELETE", new PlArray(this.tied, new PlString((String)i)), PlCx.SCALAR);
    }
    public void clear() {
        PerlOp.call("CLEAR", new PlArray(this.tied), PlCx.SCALAR);
    }
    public Iterator<Map.Entry<String, PlObject>> iterator() {
        return new PlTieHashIterator(this.tied);
    }
    public PlScalarImmutable scalar() {
        return PerlOp.call("SCALAR", new PlArray(this.tied), PlCx.SCALAR).scalar();
    }
    public boolean is_tiedHash() {
        return true;
    }
    public PlObject tied() {
        return this.tied;
    }

} // PlTieHashMap

class PlHashIterator {
    public Iterator<Map.Entry<String, PlObject>> iterator;

    public PlHashIterator() {
    }
    public void reset() {
        iterator = null;
    }
}
class PlHashMap extends HashMap<String, PlObject> implements Iterable<Map.Entry<String, PlObject>> {
    public PlHashMap() {
    }
    // get(String)
    // put(String, PlObject)
    // containsKey(String)
    // remove(String)
    // clear()
    // entrySet().iterator() == iterator()

    public Iterator<Map.Entry<String, PlObject>> iterator() {
        return this.entrySet().iterator();
    }
    public PlScalarImmutable scalar() {
        return new PlInt(this.hashCode());
    }
    public boolean is_tiedHash() {
        return false;
    }
    public PlObject tied() {
        return PlCx.UNDEF;
    }
}
class PlHashLvalueIterator implements Iterator<PlObject> {
    private final PlHash hr;
    private final PlHashMap h;
    private Iterator<Map.Entry<String, PlObject>> each_iterator;
    private boolean is_key;
    private Map.Entry<String, PlObject> entry;
    private String key;

    public PlHashLvalueIterator(PlHash hr) {
        this.hr = hr;
        this.h = hr.h;
        this.each_iterator = this.h.iterator();
        this.is_key = true;
    }
    public PlObject next() {
        if (is_key) {
            is_key = false;
            this.entry = this.each_iterator.next();
            this.key   = entry.getKey();
            return new PlLvalue(new PlString(this.key));
        }
        is_key = true;
        PlObject o = this.entry.getValue();
        if (o == null) {
            return new PlLazyLookup(this.hr, this.key);
        }
        if (o.is_lvalue()) {
            return o;
        }
        PlLvalue lh = new PlLvalue(o);
        this.h.put(this.key, lh);
        return lh;
    }
    public boolean hasNext() {
        if (is_key) {
            return this.each_iterator.hasNext();
        }
        return true;
    }
}
class PlHash extends PlObject implements Iterable<PlObject> {
    public PlHashMap h;
    public PlHashIterator each_iterator;

    public Iterator<PlObject> iterator() {
        return new PlHashLvalueIterator(this); 
    }

    public PlHash() {
        this.each_iterator = new PlHashIterator();
        this.h = new PlHashMap();
        this.each_iterator.reset();
    }
    public PlHash(PlObject... args) {
        this.each_iterator = new PlHashIterator();
        this.h = new PlHashMap();
        int args_size = args.length;
        for (int i = 0; i < args_size; i++) {
            PlObject s = args[i];
            if (s.is_hash()) {
                // @x = %x;
                s = s.to_array();
            }
            if (s.is_array()) {
                // %x = ( @x, @y );
                int array_size = s.to_int();
                for (int j = 0; j < array_size; j++) {
                    String key = s.aget(j).toString();
                    j++;
                    PlObject value;
                    if ( j >= array_size ) {
                        // TODO - emit warning about odd number of arguments
                        value = PlCx.UNDEF;
                    }
                    else {
                        value = s.aget(j);
                    }
                    this.hset(key, value);
                }
            }
            else {
                i++;
                PlObject value;
                if ( i >= args_size ) {
                    // TODO - emit warning about odd number of arguments
                    value = PlCx.UNDEF;
                }
                else {
                    value = args[i];
                }
                this.hset(s.toString(), value);
            }
        }
        this.each_iterator.reset();
    }


    // tie hash
    public PlObject tie(PlArray args) {
        if (this.h.is_tiedHash()) {
            this.untie();
        }
        PlTieHashMap v = new PlTieHashMap();
        PlObject self = PerlOp.call("TIEHASH", args, PlCx.VOID);
        v.tied = self;
        v.old_var = this.h;
        this.h = v;
        return self;
    }

    public PlObject untie() {
        if (this.h.is_tiedHash()) {
            PlObject tied = this.h.tied();
            PlObject untie = PerlOp.call("can", new PlArray(tied, new PlString("UNTIE")), PlCx.SCALAR);
            if (untie.to_boolean()) {
                untie.apply(PlCx.VOID, new PlArray(tied));
            };
            this.h = ((PlTieHashMap)h).old_var;
            return tied;
        }
        return this;
    }
    public PlObject tied() {
        return h.tied();
    }


    // internal lazy api
    public PlLvalue create_scalar(String i) {
        PlObject o = this.h.get(i);
        if (o == null) {
            PlLvalue a = new PlLvalue();
            this.h.put(i, a);
            return a;
        }
        if (o.is_lvalue()) {
            return (PlLvalue)o;
        }
        if (o.is_undef()) {
            PlLvalue a = new PlLvalue();
            this.h.put(i, a);
            return a;
        }
        return (PlLvalue)PlCORE.die("Not a SCALAR reference");
    }

    public PlObject set(int want, PlObject s) {
        this.h.clear();
        if (s.is_hash()) {
            // @x = %x;
            s = s.to_array();
        }
        if (s.is_array()) {
            // %x = ( @x, @y );
            int array_size = s.to_int();
            for (int j = 0; j < array_size; j++) {
                String key = s.aget(j).toString();
                j++;
                PlObject value;
                if ( j >= array_size ) {
                    // odd number of arguments
                    if (array_size == 1 && s.aget(0).is_ref()) {
                        PlCORE.warn(PlCx.VOID, new PlArray(new PlString("Reference found where even-sized list expected")));
                    }
                    else {
                        PlCORE.warn(PlCx.VOID, new PlArray(new PlString("Odd number of elements in hash assignment")));
                    }
                    value = PlCx.UNDEF;
                }
                else {
                    value = s.aget(j);
                }
                this.hset(key, value);
            }
        }
        else {
            // TODO - emit warning about odd number of arguments
            PlCORE.warn(PlCx.VOID, new PlArray(new PlString("Odd number of elements in hash assignment")));
            this.hset(s.toString(), PlCx.UNDEF);
        }
        this.each_iterator.reset();
        if (want == PlCx.LIST) {
            return this.to_list_of_aliases();
        }
        return s.scalar();
    }

    public PlObject to_array() {
        PlArray aa = new PlArray();
        for (Map.Entry<String, PlObject> entry : this.h) {
            String key = entry.getKey();
            PlObject value = entry.getValue();
            aa.push_void(new PlString(key));
            aa.push_void(value);
        }
        return aa;
    }

    public PlArray to_list_of_aliases() {
        PlArrayList aa = new PlArrayList();
        for (Map.Entry<String, PlObject> entry : this.h) {
            String key = entry.getKey();
            aa.add(new PlString(key));
            PlObject value = this.hget_lvalue(key);
            aa.add(value);
        }
        PlSlice result = new PlSlice(aa);
        return result;
    }

    public PlObject hget(String i) {
        PlObject o = this.h.get(i);
        if (o == null) {
            return PlCx.UNDEF;
        }
        return o;
    }
    public PlObject hget_list_of_aliases(int want, PlArray a) {
        // @a{LIST}
        PlArrayList aa = new PlArrayList();
        for (int i = 0; i < a.to_int(); i++) {
            String key = a.aget(i).toString();
            PlObject value = this.hget_lvalue(key);
            aa.add(value);
        }
        PlSlice result = new PlSlice(aa);
        if (want == PlCx.LIST) {
            return result;
        }
        return result.pop();
    }
    public PlObject hget_hash_list_of_aliases(int want, PlArray a) {
        // %a{LIST}
        PlArrayList aa = new PlArrayList();
        for (int i = 0; i < a.to_int(); i++) {
            String key = a.aget(i).toString();
            aa.add(new PlString(key));
            PlObject value = this.hget_lvalue(key);
            aa.add(value);
        }
        PlArray result = new PlArray(aa);
        if (want == PlCx.LIST) {
            return result;
        }
        return result.pop();
    }

    public PlObject hget_lvalue(String i) {
        PlObject o = this.h.get(i);
        if (o == null) {
            return new PlLazyLookup(this, i);
        }
        else if (o.is_lvalue()) {
            return o;
        }

        if (this.h.is_tiedHash()) {
            return new PlLazyTiedLookup(this, i);
        }

        PlLvalue a = new PlLvalue(o);
        this.h.put(i, a);
        return a;
    }
    public PlObject hget_lvalue_local(String i) {
        PlObject o = this.h.get(i);
        if (o == null) {
            this.h.put(i, PlCx.UNDEF);
        }

        if (this.h.is_tiedHash()) {
            PerlOp.push_local(this, i);
            return new PlLazyTiedLookup(this, i);
        }

        return PerlOp.push_local(this, i);
    }

    public PlObject get_scalar(PlObject arg) {
        // $$x
        String s = arg.toString();
        PlObject o = this.h.get(s);
        if (o == null || o.is_undef()) {
            PlLvalue a = new PlLvalue();
            this.hset(s, new PlLvalueRef(a));
            return a;
        }
        else if (o.is_scalarref()) {
            return o.get();
        }
        // Modification of a read-only value attempted
        // return PlCORE.die("Not an SCALAR reference");
        return o;
    }

    public PlObject hget_scalarref(String i) {
        PlObject o = this.h.get(i);
        if (o == null || o.is_undef()) {
            return new PlLvalueRef(new PlLazyScalarref(new PlLazyLookup(this, i)));
        }
        else if (o.is_scalarref()) {
            return o;
        }
        // Modification of a read-only value attempted
        return o;
    }

    public PlObject hget_arrayref(String i) {
        PlObject o = this.h.get(i);
        if (o == null || o.is_undef()) {
            PlArrayRef ar = new PlArrayRef();
            this.hset(i, ar);
            return ar;
        }
        else if (o.is_arrayref()) {
            return o;
        }
        return PlCORE.die("Not an ARRAY reference");
    }

    public PlObject hget_hashref(String i) {
        PlObject o = this.h.get(i);
        if (o == null || o.is_undef()) {
            PlHashRef hr = new PlHashRef();
            this.hset(i, hr);
            return hr;
        }
        else if (o.is_hashref()) {
            return o;
        }
        return PlCORE.die("Not a HASH reference");
    }

    // Note: multiple versions of set()
    public PlObject hset(String key, PlObject v) {
        PlObject value = v.scalar();
        PlObject o = this.h.get(key);
        if (o != null && o.is_lvalue()) {
            o.set(value);
        }
        else {
            this.h.put(key, value);
        }
        return v;
    }
    public PlObject hset(String key, PlLvalue v) {
        PlObject value = v.get();
        PlObject o = this.h.get(key);
        if (o != null && o.is_lvalue()) {
            o.set(value);
        }
        else {
            this.h.put(key, value);
        }
        return v;
    }
    public PlObject hset(int want, PlArray s, PlArray v) {
        PlArray aa = new PlArray();

        for (int i = 0; i < v.to_int(); i++){
            aa.push_void(this.hset(v.aget(i).toString(), s.aget(i)));
        };
        if (want == PlCx.LIST) {
            return aa;
        }
        return aa.pop();
    }
    public PlObject hset_alias(String s, PlObject lvalue) {
        return this.h.put(s, lvalue);
    }
    public PlObject hexists(String i) {
        return this.h.containsKey(i) ? PlCx.TRUE : PlCx.FALSE;
    }
    public PlObject hexists(PlObject i) {
        return this.h.containsKey(i.toString()) ? PlCx.TRUE : PlCx.FALSE;
    }
    public PlObject hdelete(int want, PlObject i) {
        PlObject r = this.h.remove(i.toString());
        if (r == null) {
            return PlCx.UNDEF;
        }
        return r;
    }
    public PlObject hdelete(int want, PlArray a) {
        PlArray aa = new PlArray();

        for (int i = 0; i < a.to_int(); i++) {
            PlObject r = this.hdelete(want, a.aget(i));
            aa.push_void(r);
        }
        if (want == PlCx.LIST) {
            return aa;
        }
        return aa.pop();
    }
    public PlObject hdelete(int want, PlString a) {
        PlArray aa = new PlArray();
        aa.push_void(a);
        return this.hdelete(want, aa);
    }
    public PlObject hdelete(int want, PlLvalue a) {
        PlArray aa = new PlArray();
        aa.push_void(a);
        return this.hdelete(want, aa);
    }
    public PlObject values() {
        PlArray aa = new PlArray();
        for (Map.Entry<String, PlObject> entry : this.h) {
            PlObject value = entry.getValue();
            aa.push_void(value);
        }
        return aa;
    }
    public PlObject keys() {
        PlArray aa = new PlArray();
        for (Map.Entry<String, PlObject> entry : this.h) {
            String key = entry.getKey();
            aa.push_void(new PlString(key));
        }
        return aa;
    }
    public PlObject each() {
        PlArray aa = new PlArray();
        if (this.each_iterator.iterator == null) {
            this.each_iterator.iterator = this.h.iterator();
        }
        if (this.each_iterator.iterator.hasNext()) {
            Map.Entry<String, PlObject> entry = this.each_iterator.iterator.next();
            String key = entry.getKey();
            aa.push_void(new PlString(key));
            PlObject value = entry.getValue();
            aa.push_void(value);
        }
        else {
            // return empty list
            this.each_iterator.reset();
        }
        return aa;
    }
    public PlObject hset(String s, Object o) {
        return this.hset(s, PlJavaObject.fromObject(o));
    }
EOT
    , ((map {
            my $native = $_;
            my $perl   = $native_to_perl{$native};
            $native && $perl ?
"    public PlObject hset(String s, $native v) {
        return this.hset(s, new $perl(v));
    }
" : ()
            }
            sort keys %native_to_perl ))

    , <<'EOT'

    public String toString() {
        // TODO
        return "" + this.hashCode();
    }
    public int to_int() {
        // TODO
        return this.hashCode();
    }
    public long to_long() {
        // TODO
        return this.hashCode();
    }
    public double to_double() {
        return 0.0 + this.to_long();
    }
    public boolean to_boolean() {
        for (Map.Entry<String, PlObject> entry : this.h) {
            return true;
        }
        return false;
    }
    public PlObject to_num() {
        return this.scalar();
    }
    public boolean is_hash() {
        return true;
    }
    public PlScalarImmutable scalar() {
        return this.h.scalar();
    }
}
class PlUndef extends PlScalarImmutable {
    public PlUndef() {
    }
    public PlObject apply(int want, PlArray List__) {
        // $a->()
        PlCORE.die("Can't use an undefined value as a subroutine reference");
        return this;
    }
    public PlScalarImmutable length() {
        return PlCx.UNDEF;
    }
    public int to_int() {
        return 0;
    }
    public long to_long() {
        return 0;
    }
    public double to_double() {
        return 0.0;
    }
    public String toString() {
        return "";
    }
    public boolean to_boolean() {
        return false;
    }
    public PlObject to_num() {
        return PlCx.INT0;
    }
    public boolean is_undef() {
        return true;
    }

    public PlObject scalar_deref_strict() {
        return PlCORE.die("Can't use an undefined value as a SCALAR reference");
    }
    public PlArray array_deref_strict() {
        return (PlArray)PlCORE.die("Can't use an undefined value as an ARRAY reference");
    }
    public PlHash hash_deref_strict() {
        return (PlHash)PlCORE.die("Can't use an undefined value as a HASH reference");
    }

}
class PlBool extends PlScalarImmutable {
    private final boolean i;
    public PlBool(boolean i) {
        this.i = i;
    }

    public PerlArgumentLookupResult castToClass(ArrayList<Class[]> params, int pos) {
        // want boolean
        for (Class[] cl : params) {
            if (cl[pos].equals( java.lang.Boolean.TYPE )) {
                return new PerlArgumentLookupResult( this.to_boolean(), cl[pos] );
            }
        }
        // try other things
        return super.castToClass(params, pos);
    }

    public int to_int() {
        if (this.i) {
            return 1;
        }
        else {
            return 0;
        }
    }
    public long to_long() {
        if (this.i) {
            return 1;
        }
        else {
            return 0;
        }
    }
    public double to_double() {
        if (this.i) {
            return 1.0;
        }
        else {
            return 0.0;
        }
    }
    public String toString() {
        if (this.i) {
            return "1";
        }
        else {
            return "";
        }
    }
    public boolean to_boolean() {
        return this.i;
    }
    public PlObject to_num() {
        if (i) {
            return PlCx.INT1;
        }
        else {
            return PlCx.INT0;
        }
    }
    public boolean is_bool() {
        return true;
    }
    public PlObject _decr() {
        // --$x
        if (i) {
            return PlCx.INT0;
        }
        else {
            return PlCx.MIN1;
        }
    }
    public PlObject _incr() {
        // ++$x
        if (i) {
            return PlCx.INT2;
        }
        else {
            return PlCx.INT1;
        }
    }
    public PlObject neg() {
        if (i) {
            return PlCx.MIN1;
        }
        else {
            return PlCx.INT0;
        }
    }
    public PlObject apply(int want, PlArray List__) {
        if (i) {
            // RT #63790:  calling PL_sv_yes as a sub is special-cased to silently
            // return (so Foo->import() silently fails if import() doesn't exist),
            return PerlOp.context(want);
        }
        else {
            return PlCORE.die("Undefined subroutine");
        }
    }
}
class PlInt extends PlScalarImmutable {
    private final long i;
    public PlInt(long i) {
        this.i = i;
    }
    public PlInt(int i) {
        this.i = (long)i;
    }

    public PerlArgumentLookupResult castToClass(ArrayList<Class[]> params, int pos) {
        // TODO - byte - short - int - long - float - double

        // want long
        for (Class[] cl : params) {
            if (cl[pos].equals( java.lang.Long.TYPE )) {
                return new PerlArgumentLookupResult( this.to_long(), cl[pos] );
            }
        }
        // want int
        for (Class[] cl : params) {
            if (cl[pos].equals( java.lang.Integer.TYPE )) {
                return new PerlArgumentLookupResult( this.to_int(), cl[pos] );
            }
        }
        // want float
        for (Class[] cl : params) {
            if (cl[pos].equals( java.lang.Float.TYPE )) {
                return new PerlArgumentLookupResult( this.to_float(), cl[pos] );
            }
        }
        // want double
        for (Class[] cl : params) {
            if (cl[pos].equals( java.lang.Double.TYPE )) {
                return new PerlArgumentLookupResult( this.to_double(), cl[pos] );
            }
        }
        // try other things
        return super.castToClass(params, pos);
    }

    public int to_int() {
        return (int)this.i;
    }
    public long to_long() {
        return this.i;
    }
    public double to_double() {
        return (double)(this.i);
    }
    public String toString() {
        return "" + this.i;
    }
    public boolean to_boolean() {
        return this.i != 0;
    }
    public PlObject to_num() {
        return this;
    }
    public PlObject mod(PlObject o) {
        return PerlOp.mod(this, o);
    }
    public boolean is_int() {
        return true;
    }
    public boolean is_integer_range() {
        return true;
    }
    public PlObject _decr() {
        // --$x
        return new PlInt(i-1);
    }
    public PlObject _incr() {
        // ++$x
        return new PlInt(i+1);
    }
    public PlObject neg() {
        return new PlInt(-i);
    }
    public PlObject mul2(PlObject s) {
        long v = s.to_long();
        // 3037000000 is sqrt(Long.MAX_VALUE)
        if (i > 3037000000L || i < -3037000000L || v > 3037000000L || v < -3037000000L) {
            return new PlDouble(this.to_double()).mul2(s);
        }
        return new PlInt(v * i);
    }
}
class PlDouble extends PlScalarImmutable {
    private final double i;
    public PlDouble(double i) {
        this.i = i;
    }

    public PerlArgumentLookupResult castToClass(ArrayList<Class[]> params, int pos) {
        // TODO - byte - short - int - long - float - double

        // want double
        for (Class[] cl : params) {
            if (cl[pos].equals( java.lang.Double.TYPE )) {
                return new PerlArgumentLookupResult( this.to_double(), cl[pos] );
            }
        }
        // want float
        for (Class[] cl : params) {
            if (cl[pos].equals( java.lang.Float.TYPE )) {
                return new PerlArgumentLookupResult( this.to_float(), cl[pos] );
            }
        }
        // want long
        for (Class[] cl : params) {
            if (cl[pos].equals( java.lang.Long.TYPE )) {
                return new PerlArgumentLookupResult( this.to_long(), cl[pos] );
            }
        }
        // want int
        for (Class[] cl : params) {
            if (cl[pos].equals( java.lang.Integer.TYPE )) {
                return new PerlArgumentLookupResult( this.to_int(), cl[pos] );
            }
        }
        // try other things
        return super.castToClass(params, pos);
    }

    public int to_int() {
        return (int)(this.i);
    }
    public long to_long() {
        return (long)(this.i);
    }
    public double to_double() {
        return this.i;
    }
    public String toString() {
        if (Double.isNaN(this.i)) {
            return "NaN";
        }
        if (Double.isInfinite(this.i)) {
            return this.i > 0 ? "Inf" : "-Inf";
        }
        double v = this.i;
        String s;
        if (   v < 0.0001 && v > -0.0001
            || v < -1E14
            || v >  1E14 )
        {
            // use scientific notation
            s = String.format("%20.20e", v);
            s = s.replaceAll("\\.?0*e", "e");
            if (s.equals("0e+00") || s.equals("-0e+00")) {
                s = "0";
            }
        }
        else {
            s = String.format("%20.20f", v);
            s = s.replaceAll("\\.?0*$", "");
        }
        return s;
    }
    public boolean to_boolean() {
        return this.i != 0.0;
    }
    public PlObject to_num() {
        return this;
    }
    public PlObject _decr() {
        // --$x
        return new PlDouble(i-1);
    }
    public PlObject _incr() {
        // ++$x
        return new PlDouble(i+1);
    }
    public PlObject neg() {
        return new PlDouble(-i);
    }
    public PlObject abs() {
        return new PlDouble(i < 0.0 ? -i : i);
    }
    public PlObject num_cmp(PlObject b) {
        if (Double.isNaN(this.i)) {
            return PlCx.UNDEF;
        }
        double bb = b.to_double();
        if (Double.isNaN(bb)) {
            return PlCx.UNDEF;
        }
        int c = ((Double)this.i).compareTo(bb);
        return (c == 0 ? PlCx.INT0 : c < 0 ? PlCx.MIN1 : PlCx.INT1);
    }
    public PlObject num_cmp2(PlObject b) {
        if (Double.isNaN(this.i)) {
            return PlCx.UNDEF;
        }
        double bb = b.to_double();
        if (Double.isNaN(bb)) {
            return PlCx.UNDEF;
        }
        int c = ((Double)bb).compareTo(this.i);
        return (c == 0 ? PlCx.INT0 : c < 0 ? PlCx.MIN1 : PlCx.INT1);
    }
EOT
    , ((map {
                my $perl = $_;
                my $native  = $number_binop{$perl}{op};
                my $returns = $number_binop{$perl}{num_returns};
                if ($returns eq 'PlInt') {
"    public PlObject ${perl}(PlObject s) {
        // num - int, num - num
        return new ${returns}( this.to_long() ${native} s.to_long() );
    }
    public PlObject ${perl}2(PlObject s) {
        // int - num
        return new ${returns}( s.to_long() ${native} this.to_long() );
    }
"
                }
                else {
"    public PlObject ${perl}(PlObject s) {
        // num - int, num - num
        return new ${returns}( this.i ${native} s.to_double() );
    }
    public PlObject ${perl}2(PlObject s) {
        // int - num
        return new ${returns}( s.to_double() ${native} this.i );
    }
"
                }
            }
            sort keys %number_binop ))

    , <<'EOT'
    public PlObject mod(PlObject o) {
        return PerlOp.mod(this, o);
    }
    public boolean is_num() {
        return true;
    }
    public boolean is_integer_range() {
        return !Double.isNaN(i) && i <= Long.MAX_VALUE && i >= Long.MIN_VALUE;
    }
}
class PlStringLazyError extends PlString {
    private Exception e;

    public PlStringLazyError(Exception e) {
        this.e = e;
    }
    public String toString() {
        if (this.s == null) {
            this.s = e.getClass().getCanonicalName() + ": " + e.getMessage() + "\n" + java.util.Arrays.toString(e.getStackTrace());
        }
        return this.s;
    }
    public boolean to_boolean() {
        return true;
    }

    public PlObject abs() {
        this.toString();
        return this.parse().abs();
    }
    public PlObject num_cmp(PlObject b) {
        this.toString();
        return this.parse().num_cmp(b);
    }
    public PlObject num_cmp2(PlObject b) {
        this.toString();
        return b.num_cmp(this.parse());
    }
    public boolean is_integer_range() {
        this.toString();
        return this.parse().is_integer_range();
    }
EOT
    , ((map {
            my $perl = $_;
            my $native  = $number_binop{$perl}{op};
            my $returns = $number_binop{$perl}{returns};
            my $num_returns = $number_binop{$perl}{num_returns};
            if ($returns eq 'PlDouble') {
"    public PlObject ${perl}(PlObject b) {
        // 'num' - int, 'num' - num
        this.toString();
        return this.parse().${perl}(b);
    }
    public PlObject ${perl}2(PlObject b) {
        // int - 'num'
        this.toString();
        return b.${perl}(this.parse());
    }
"
            }
            else {
"    public PlObject ${perl}(PlObject b) {
        // 'num' - int, 'num' - num
        this.toString();
        return this.parse().${perl}(b);
    }
    public PlObject ${perl}2(PlObject b) {
        // int - 'num'
        this.toString();
        return b.${perl}(this.parse());
    }
"
            }
            }
            sort keys %number_binop ))

    , <<'EOT'
}
class PlStringConstant extends PlString {
    public static HashMap<String, PlStringConstant> constants = new HashMap<String, PlStringConstant>();

    // inherited: String s
    private PlClass cls;
    public PlLvalue codeRef;   // CODE
    public PlLvalue scalarRef; // SCALAR
    public PlLvalue arrayRef;  // ARRAY
    public PlLvalue hashRef;   // HASH
    public PlLvalue fileRef;   // IO
    // TODO - "FORMAT"

    public String namespace;   // PACKAGE - "main" in "main::x"; maybe null
    public String name;        // NAME    - "x" in "main::x"; maybe null

    public PlStringConstant(String s) {
        super(s);

        int pos = s.lastIndexOf("::");
        if (pos != -1) {
            this.namespace = s.substring(0, pos);
            this.name      = s.substring(pos+2);
        }

        this.codeRef = new PlLvalue();
        this.scalarRef = new PlLvalue();
        this.arrayRef = new PlLvalue(new PlArrayRef());
        this.hashRef = new PlLvalue(new PlHashRef());
        this.fileRef = new PlLvalue(new PlFileHandle(s));
    }

    public static PlStringConstant getConstant(String s) {
        PlStringConstant v = constants.get(s);
        if (v == null) {
            v = new PlStringConstant(s);
            constants.put(s, v);
        }
        return v;
    }

    public PlClass blessed_class() {
        if (cls == null) {
            cls = PlClass.getInstance(s);
        }
        return cls;
    }
    public PlObject cset(PlObject v) {
        PlClass.getInstance(this.namespace).invalidate_method_cache(this.name, 0);
        return this.codeRef.set(v);
    }
    public PlObject cset_alias(PlLvalue v) {
        PlClass.getInstance(this.namespace).invalidate_method_cache(this.name, 0);
        return this.codeRef = v;
    }
    public PlObject apply(int want, PlArray List__) {
        if (this.codeRef.is_undef()) {
            if (this.namespace != null) {
                PlLvalue autoload = PlV.cget_no_autoload(this.namespace + "::AUTOLOAD");
                if ( autoload.is_coderef() ) {
                    PlV.sset(this.namespace + "::AUTOLOAD", new PlString(this.s));
                    return autoload.apply(want, List__);
                }
            }
            return PlCORE.die("Undefined subroutine &" + name + " called");
        }
        return this.codeRef.apply(want, List__);
    }
}
class PlString extends PlScalarImmutable {
    public java.lang.String s;
    private PlObject numericValue;

    public PlString() {
    }
    public PlString(String s) {
        // if (s == null) {
        //     s = "";
        // }
        this.s = s;
    }
    public PlString(char s) {
        this.s = "" + s;
    }
    public PlObject scalar_deref_lvalue(String namespace) {
        return this.scalar_deref(namespace);
    }
    public PlObject scalar_deref(String namespace) {
        if (s.length() == 1) {
            if (this._looks_like_non_negative_integer()) {
                return PerlOp.regex_var(this.to_int());
            }
            if (s.equals("&") || s.equals("`") || s.equals("'")) {
                return PerlOp.regex_var(s);
            }
            if (s.equals("$")) {
                return PerlOp.getPID();
            }

            // special variables like $_ $\
EOT
    , (( map {
                my $java_name = $Perlito5::Java::special_scalar{$_};
                my $perl_name = $_;
                $perl_name = "\\\\" if $perl_name eq "\\";
"
            if (s.equals(\"${perl_name}\")) {
                return PlV.${java_name};
            }
"
            }
            sort keys %Perlito5::Java::special_scalar
      ))
    , <<'EOT'

        }
        if (s.indexOf("::") == -1) {
            return PlV.sget( namespace + "::" + s );
        }

        // special variables like $_ $\
EOT
    , (( map {
                my $java_name = $Perlito5::Java::special_scalar{$_};
                my $perl_name = $_;
                $perl_name = "\\\\" if $perl_name eq "\\";
"
        if (s.equals(\"main::${perl_name}\")) {
            return PlV.${java_name};
        }
"
            }
            sort keys %Perlito5::Java::special_scalar
      ))
    , <<'EOT'

        return PlV.sget(s);
    }
    public PlObject scalar_deref_strict() {
        return PlCORE.die("Can't use string (\"" + this.s + "\") as a SCALAR ref while \"strict refs\" in use");
    }
    public PlObject scalar_deref_set(String namespace, PlObject v) {
        if (s.length() == 1) {

            // special variables like $_ $\
EOT
    , (( map {
                my $java_name = $Perlito5::Java::special_scalar{$_};
                my $perl_name = $_;
                $perl_name = "\\\\" if $perl_name eq "\\";
"
            if (s.equals(\"${perl_name}\")) {
                return PlV.${java_name}.set(v);
            }
"
            }
            sort keys %Perlito5::Java::special_scalar
      ))
    , <<'EOT'

        }
        if (s.indexOf("::") == -1) {
            return PlV.sset( namespace + "::" + s, v );
        }

        // special variables like $_ $\
EOT
    , (( map {
                my $java_name = $Perlito5::Java::special_scalar{$_};
                my $perl_name = $_;
                $perl_name = "\\\\" if $perl_name eq "\\";
"
        if (s.equals(\"main::${perl_name}\")) {
            return PlV.${java_name}.set(v);
        }
"
            }
            sort keys %Perlito5::Java::special_scalar
      ))
    , <<'EOT'

        return PlV.sset(s, v);
    }
    public PlArray array_deref_lvalue() {
        // TODO - concatenate current namespace if needed
        return PlV.array_get(s);
    }
    public PlArray array_deref_strict() {
        PlCORE.die("Can't use string (\"" + this.s + "\") as an ARRAY ref while \"strict refs\" in use");
        return PlV.array_get(s);
    }
    public PlArray array_deref(String namespace) {
        if (s.indexOf("::") == -1) {
            return PlV.array_get( namespace + "::" + s );
        }
        return PlV.array_get(s);
    }
    public PlObject array_deref_set(PlObject v) {
        // TODO - concatenate current namespace if needed
        return PlV.aset(s, v);
    }
    public PlObject hget(String i) {
        return this.hash_deref("").hget(i);
    }
    public PlObject hash_deref(String namespace) {
        int pos = s.lastIndexOf("::");
        if (pos == -1) {
            return PlV.hash_get( namespace + "::" + s );
        }
        else if (pos == s.length() - 2) {
            // %{"Module::"}
            return PerlOp.getSymbolTable(this.s);
        }
        return PlV.hash_get(s);
    }
    public PlHash hash_deref_strict() {
        PlCORE.die("Can't use string (\"" + this.s + "\") as a HASH ref while \"strict refs\" in use");
        return PlV.hash_get(s);
    }
    public PlObject hash_deref_set(PlObject v) {
        // TODO - concatenate current namespace if needed
        return PlV.hash_set(s, v);
    }
    public PlObject hdelete(int want, PlObject a) {
        // TODO - concatenate current namespace if needed
        int pos = s.lastIndexOf("::");
        // if (pos == -1) {
        //     s = namespace + "::" + s;
        // }
        if (pos == s.length() - 2) {
            // %{"Module::"}
            return PerlOp.deleteSymbolTable(this.s, a);
        }
        return PlV.hash_get(s).hdelete(want, a);
    }
    public PlClass blessed_class() {
        return PlClass.getInstance(s);
    }

    public PlObject parse() {
        if (numericValue == null) {
            numericValue = this._parse();
        }
        return numericValue;
    }
    private boolean _looks_like_non_negative_integer() {
        final int length = s.length();
        for (int offset = 0; offset < length; ) {
            final int c = s.codePointAt(offset);
            switch (c) {
                case '0': case '1': case '2': case '3': case '4':
                case '5': case '6': case '7': case '8': case '9':
                    break;
                default:
                    return false;
            }
        }
        return true;
    }
    private PlObject _parse_exp(int length, int signal, int offset, int next) {
        // 123.45E^^^
        int offset_orig = next;
        int offset3 = next;
        if (offset3 >= length) {
            return new PlDouble(Double.parseDouble(this.s.substring(0, offset_orig - 1)));
        }
        final int sig = s.codePointAt(offset3);
        if (sig == '+' || sig == '-') {
            offset3++;
            if (offset3 >= length) {
                return new PlDouble(Double.parseDouble(this.s.substring(0, offset_orig - 1)));
            }
        }
        final int num = s.codePointAt(offset3);
        if (num < '0' || num > '9') {
            // illegal exp
            return new PlDouble(Double.parseDouble(this.s.substring(0, offset_orig - 1)));
        }
        for ( ; offset3 < length; ) {
            final int c3 = s.codePointAt(offset3);
            switch (c3) {
                case '0': case '1': case '2': case '3': case '4':
                case '5': case '6': case '7': case '8': case '9':
                    break;
                default:    // invalid
                    return new PlDouble(Double.parseDouble(this.s.substring(0, offset3)));
            }
            offset3++;
        }
        return new PlDouble(Double.parseDouble(this.s.substring(0, offset3)));
    }
    private PlObject _parse_dot(int length, int signal, int offset, int next) {
        // 123.^^^
        int offset3 = next;
        for ( ; offset3 < length; ) {
            final int c3 = s.codePointAt(offset3);
            switch (c3) {
                case '0': case '1': case '2': case '3': case '4':
                case '5': case '6': case '7': case '8': case '9':
                    break;
                case 'E': case 'e':
                    // start exponential part
                    return _parse_exp(length, signal, offset, offset3+1);
                default:    // invalid
                    try {
                        return new PlDouble(Double.parseDouble(this.s.substring(0, offset3)));
                    }
                    catch (NumberFormatException e) {
                        // string is "."
                        return PlCx.INT0;   // string is "."
                    }
            }
            offset3++;
        }
        if (offset3 == 1) {
            return PlCx.INT0;   // string is "."
        }
        return new PlDouble(Double.parseDouble(this.s.substring(0, offset3)));
    }
    private PlObject _parse() {
        final int length = s.length();
        int signal = 0;
        for (int offset = 0; offset < length; ) {
            final int c = s.codePointAt(offset);
            switch (c) {
                case 'i': case 'I':
                            if (length > 2 && this.s.substring(offset, offset+3).equalsIgnoreCase("inf")) {
                                if (signal < 0) {
                                    return new PlDouble(Double.NEGATIVE_INFINITY);
                                }
                                else {
                                    return new PlDouble(Double.POSITIVE_INFINITY);
                                }
                            }
                            return PlCx.INT0;
                case 'n': case 'N':
                            if (length > 2 && this.s.substring(offset, offset+3).equalsIgnoreCase("nan")) {
                                return new PlDouble(Double.NaN);
                            }
                            return PlCx.INT0;
                case '.':   // starts with dot
                            if (signal != 0) {
                                signal = 1;
                            }
                            return _parse_dot(length, signal, offset, offset+1);
                case '0': case '1': case '2': case '3': case '4':
                case '5': case '6': case '7': case '8': case '9':
                            // starts with number
                            if (signal == 0) {
                                signal = 1;
                            }
                            int offset2 = offset+1;
                            for ( ; offset2 < length; ) {
                                final int c2 = s.codePointAt(offset2);
                                switch (c2) {
                                    case '0': case '1': case '2': case '3': case '4':
                                    case '5': case '6': case '7': case '8': case '9':
                                        // more numbers
                                        break;
                                    case '.':
                                        // start decimal part
                                        return _parse_dot(length, signal, offset, offset2+1);
                                    case 'E': case 'e':
                                        // start exponential part
                                        return _parse_exp(length, signal, offset, offset2+1);
                                    default:
                                        // return integer
                                        try {
                                            if (signal < 0) {
                                                return new PlInt(-Long.parseLong(this.s.substring(offset, offset2)));
                                            }
                                            else {
                                                return new PlInt(Long.parseLong(this.s.substring(offset, offset2)));
                                            }
                                        }
                                        catch (NumberFormatException e) {
                                            return new PlDouble(Double.parseDouble(this.s.substring(offset, offset2)));
                                        }
                                }
                                offset2++;
                            }
                            // integer
                            try {
                                if (signal < 0) {
                                    return new PlInt(-Long.parseLong(this.s.substring(offset, offset2)));
                                }
                                else {
                                    return new PlInt(Long.parseLong(this.s.substring(offset, offset2)));
                                }
                            }
                            catch (NumberFormatException e) {
                                return new PlDouble(Double.parseDouble(this.s.substring(offset, offset2)));
                            }
                case '+':   // starts with +
                            if (signal != 0) {
                                // invalid
                                return PlCx.INT0;
                            }
                            signal = 1;
                            break;
                case '-':   // starts with -
                            if (signal != 0) {
                                // invalid
                                return PlCx.INT0;
                            }
                            signal = -1;
                            break;
                case ' ': case '\t': case '\n': case '\r':
                            // starts with space
                            if (signal != 0) {
                                // invalid
                                return PlCx.INT0;
                            }
                            break;
                default:    // invalid
                            return PlCx.INT0;
            }
            offset++;
        }
        return PlCx.INT0;
    }
    public int to_int() {
        return this.parse().to_int();
    }
    public long to_long() {
        return this.parse().to_long();
    }
    public double to_double() {
        return this.parse().to_double();
    }
    public String toString() {
        return this.s;
    }
    public boolean to_boolean() {
        return !( this.s.equals("") || this.s.equals("0") );
    }
    public PlObject to_num() {
        return this.parse();
    }
    public char to_char() {
        if (this.s.length() == 0) {
            return '\u0000';
        }
        return this.s.charAt(0);
    }
    public boolean is_string() {
        return true;
    }
    public boolean boolean_str_le(String b) {
        return this.s.compareTo(b) <= 0;
    }
    public int int_length() {
        return this.s.length();
    }
    public PlScalarImmutable length() {
        return new PlInt(this.s.length());
    }
    public PlObject _decr() {
        // --$x
        return this.add(PlCx.MIN1);
    }

    // $x++ when $x is PlString
    private static final String _string_increment(String s) {
        if (s.length() < 2) {
            final int c = s.codePointAt(0);
            if ((c >= '0' && c <= '8') || (c >= 'A' && c <= 'Y') || (c >= 'a' && c <= 'y')) {
                return "" + (char)(c + 1);
            }
            if (c == '9') {
                return "10";
            }
            if (c == 'Z') {
                return "AA";
            }
            if (c == 'z') {
                return "aa";
            }
            return "1";
        }
        String c = _string_increment(s.substring(s.length()-1, s.length()));
        if (c.length() == 1) {
            // AAAC => AAAD
            return s.substring(0, s.length()-1) + c;
        }
        // AAAZ => AABA
        return _string_increment(s.substring(0, s.length()-1)) + c.substring(c.length()-1, c.length());
    }
    public PlObject _incr() {
        // ++$x
        final int length = s.length();
        if (length == 0) {
            return PlCx.INT1;
        }
        int c = this.s.codePointAt(0);
        switch (c) {
            case ' ': case '\t': case '\n': case '\r':
            case '+': case '-': case '.':
            case '0': case '1': case '2': case '3': case '4':
            case '5': case '6': case '7': case '8': case '9':
                return this.add(PlCx.INT1);
        }
        c = s.codePointAt(length - 1);
        if ((c >= '0' && c <= '8') || (c >= 'A' && c <= 'Y') || (c >= 'a' && c <= 'y')) {
            return new PlString(s.substring(0, length-1) + (char)(c + 1));
        }
        return new PlString(_string_increment(this.s));
    }
    public PlObject neg() {
        final int length = s.length();
        if (length == 0) {
            return PlCx.INT0;
        }
        final int c = this.s.codePointAt(0);
        switch (c) {
            case '+': case '-':
                if (c == '+') {
                    return new PlString( '-' + s.substring(1) );
                }
                if (c == '-') {
                    return new PlString( '+' + s.substring(1) );
                }
            case '.':
            case ' ': case '\t': case '\n': case '\r':
            case '0': case '1': case '2': case '3': case '4':
            case '5': case '6': case '7': case '8': case '9':
                return this.parse().neg();
        }
        if ((c >= 'A' && c <= 'Z') || (c >= 'a' && c <= 'z')) {
            return new PlString( '-' + s );
        }
        return PlCx.INT0;
    }
    public PlObject abs() {
        return this.parse().abs();
    }
    public PlObject num_cmp(PlObject b) {
        return this.parse().num_cmp(b);
    }
    public PlObject num_cmp2(PlObject b) {
        return b.num_cmp(this.parse());
    }
    public boolean is_integer_range() {
        return this.parse().is_integer_range();
    }
EOT
    , ((map {
            my $perl = $_;
            my $native  = $number_binop{$perl}{op};
            my $returns = $number_binop{$perl}{returns};
            my $num_returns = $number_binop{$perl}{num_returns};
            if ($returns eq 'PlDouble') {
"    public PlObject ${perl}(PlObject b) {
        // 'num' - int, 'num' - num
        return this.parse().${perl}(b);
    }
    public PlObject ${perl}2(PlObject b) {
        // int - 'num'
        return b.${perl}(this.parse());
    }
"
            }
            else {
"    public PlObject ${perl}(PlObject b) {
        // 'num' - int, 'num' - num
        return this.parse().${perl}(b);
    }
    public PlObject ${perl}2(PlObject b) {
        // int - 'num'
        return b.${perl}(this.parse());
    }
"
            }
            }
            sort keys %number_binop ))

    , <<'EOT'
}
EOT

    # Java API
    # work in progress
    # See "Java" and "Packages" object in Nashorn
    # https://docs.oracle.com/javase/8/docs/technotes/guides/scripting/nashorn/api.html

    , <<'EOT'
class PlJavaObject extends PlReference {
    private Object stuff;

    static PlObject fromObject(Object o) {
        // Runtime casting
        if (o == null) {
            return PlCx.UNDEF;
        }
        if (o instanceof PlObject) {
            // this is already a Perl object
            return (PlObject)o;
        }
        if (o instanceof Number) {
            if (o instanceof Byte) {
                return new PlInt((Byte)o);
            }
            if (o instanceof Short) {
                return new PlInt((Short)o);
            }
            if (o instanceof Integer) {
                return new PlInt((Integer)o);
            }
            if (o instanceof Long) {
                return new PlInt((Long)o);
            }
            if (o instanceof Float) {
                return new PlDouble((Float)o);
            }
            if (o instanceof Double) {
                return new PlDouble((Double)o);
            }
            // TODO - there are more Number types
        }
        if (o instanceof Character) {
            return new PlString((Character)o);
        }
        if (o instanceof String) {
            return new PlString((String)o);
        }
        if (o instanceof Boolean) {
            return new PlBool((Boolean)o);
        }
        // TODO - more castings from %java_classes
        return new PlJavaObject(o);
    }

    public PerlArgumentLookupResult castToClass(ArrayList<Class[]> params, int pos) {
        // want same Java class
        // System.out.println("PerlArgumentLookupResult castToClass from " + this.ref_str());
        for (Class[] cl : params) {
            // System.out.println("  compare to " + cl[pos]);
            if (cl[pos].equals( this.stuff.getClass() )) {
                // System.out.println("   match");
                return new PerlArgumentLookupResult( this.stuff, cl[pos] );
            }
            // try again with Class.cast()
            try {
                cl[pos].cast( this.stuff );
                // cast returns ok
                // System.out.println("   can cast()");
                return new PerlArgumentLookupResult( this.stuff, cl[pos] );
            }
            catch (ClassCastException e) {
                // System.out.println("   cannot cast()");
            }
        }
        // try other things
        return super.castToClass(params, pos);
    }

    public PlJavaObject(Object stuff) {
        this.stuff = stuff;
    }
    public Object toJava() {
        return this.stuff;
    }
    public PlString ref() {
        return new PlString(stuff.getClass().getCanonicalName());
    }
    public String ref_str() {
        return stuff.getClass().getCanonicalName();
    }
    public boolean ref_boolean() {
        return true;
    }

    public PlObject reftype() {
        // Scalar::Util::reftype()
        return ref();
    }
    public String toString() {
        if (stuff == null) {
            return "";
        }
        return this.stuff.toString();
    }
    public boolean to_boolean() {
        if (stuff == null) {
            return false;
        }
        return true;
    }
    public boolean is_JavaObject() {
        return true;
    }
    public boolean is_undef() {
        return stuff == null;
    }
    public PlObject clone() throws CloneNotSupportedException {
        // TODO - test if implements 'Cloneable' and call stuff.clone() if possible
        return this;
    }
}
EOT

    , <<'EOT'
// end Perl-Java runtime
EOT
    );
} # end of emit_java()

1;

__END__

=pod

=head1 NAME

Perlito5::Java::Runtime

=head1 DESCRIPTION

Provides runtime routines for the Perlito-in-Java compiled code

=head1 AUTHORS

Flavio Soibelmann Glock

=head1 COPYRIGHT

Copyright 2015 by Flavio Soibelmann Glock.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

See L<http://www.perl.com/perl/misc/Artistic.html>

=cut
