use Config;
use ExtUtils::MakeMaker;
WriteMakefile(
  NAME          => 'HTML::EmbeddedPerl::Test',
  ABSTRACT_FROM => 'lib/HTML/EmbeddedPerl/Test.pm',
  AUTHOR        => 'Twinkle Computing <twinkle@cpan.org>',
  LICENSE       => 'perl',
  VERSION_FROM  => 'lib/HTML/EmbeddedPerl/Test.pm',
  INST_SCRIPT   => 'blib/bin',
  EXE_FILES     => ["bin/twept$Config{_exe}"],
  MAN1PODS      => {'pod/en/twept.pod'=>'blib/man1/twept.1'},
);
