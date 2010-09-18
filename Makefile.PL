use ExtUtils::MakeMaker;
WriteMakefile(
  NAME         => 'HTML::EmbeddedPerl::Test',
  AUTHOR       => 'Twinkle Computing <twinkle@cpan.org>',
  VERSION_FROM => 'lib/HTML/EmbeddedPerl/Test.pm',
  EXE_FILES    => ['bin/twept'],
  MAN1PODS     => {'pod/en/twept.pod'=>'blib/man1/twept.1'},
);
