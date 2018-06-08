"Perlito" release to CPAN
=========================

Perlito5 Release
----------------

Note: distribution tests should be runnable with old versions of dependencies.

* install an old version of Perl (for example: 5.14)

* install an old version of `node.js`

* install an old version of Java `JDK` (version 7 or higher)

* set the minimal Perl version in `cpan-Perlito5/Makefile.PL`

    ```
    MIN_PERL_VERSION => 5.014,
    ```

* run tests

    ```
    make clean
    make
    make test-5to5
    make test-5js
    make test-5jar
    make test
    ```

* increment version number in "src5/lib/Perlito5.pm"

    example: "$VERSION = '9.017';"

* update "Changelog" header

    example: "9.017 cpan:Perlito5  2016-01-19"

* go to "cpan-Perlito5" directory and execute "make-Perlito5.sh"

    ```
    cd cpan-Perlito5
    . make-Perlito5.sh
    ```

* build and test the module inside "cpan-Perlito5" directory

    ```
    perl Makefile.PL
    make
    make test
    ```

* make the distribution file

    ```
    make dist
    ```

* publish to pause.perl.org

* commit and push the changes

    example: "Perlito5 - CPAN - v9.017"

* release perlito5.jar and perlito5.js to GitHub

  See https://github.com/fglock/Perlito/releases

* release perlito5.jar to Maven

  TODO

* release perlito5.js to npm

  TODO


Perlito6 Release
----------------

* run tests

    ```
    make test-6to5
    ```

* increment version number in "cpan-v6/v6.pm"

    example: "$v6::VERSION = '0.045';"

* update "Changelog" header

    example: "0.045 cpan:v6  2016-01-19"

* go to "cpan-v6" directory and execute "make-v6.sh"

    ```
    cd cpan-v6
    . make-v6.sh
    ```

* build and test the module inside "cpan-v6" directory

    ```
    perl Makefile.PL
    make
    make test
    ```

* make dist

* publish to pause.perl.org

TODO for the release process
----------------------------

* BUG - "cpan-v6/ChangeLog" is not updated automatically

* BUG - the README files are not included in the cpan distribution

