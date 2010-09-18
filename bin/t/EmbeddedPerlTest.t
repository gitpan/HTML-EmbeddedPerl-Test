our $suf = $^O =~ /win/ ? '.exe' : '';
print "1..1\n";
print `./twept$suf TESTS` =~ /ok\.\s*$/ ? 'ok' : 'not ok'; print " 1 run twept\n";
