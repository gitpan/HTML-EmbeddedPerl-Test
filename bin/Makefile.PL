use Config;

our $suf = $^O =~ /win/ ? '.exe' : '';

  open MKF,'>Makefile';
  flock MKF,2;

print MKF <<_EOM_;
PERLPV = ppv/perlpv

all: twept$suf

twept$suf: twept.pl
	$Config{perlpath} \$(PERLPV) twept.pl
	strip twept$suf
test:
	$Config{perlpath} t/EmbeddedPerlTest.t
install: all
	cp -f twept$suf $Config{installbin}/twept$suf
uninstall:
	rm -f $Config{installbin}/twept$suf
clean:
	rm -f twept$suf
realclean: clean
	rm -f Makefile
_EOM_

  close MKF;

print "Writing Makefile for EmbeddedPerl BETA.\n";
