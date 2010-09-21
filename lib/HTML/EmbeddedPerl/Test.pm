package HTML::EmbeddedPerl::Test;

use strict;
use warnings;

use Exporter;

our @ISA       = qw(Exporter);
our @EXPORT    = qw(ep);
our @EXPORT_OK = qw($VERSION $TIMEOUT);

our $VERSION = '0.05';
our $TIMEOUT = 2;

my $STDBAK = *STDOUT;

sub header_out{
  $_[0]->{head} .= "$_[1]: $_[2]\r\n";
}
sub content_type{
  $_[0]->{type} = $_[1];
}
sub flush{
  print $STDBAK "$_[0]->{head}Content-Type: $_[0]->{type}\r\n\r\n";
}
sub print{
  shift; CORE::print @_;
}
sub run{
  my($epl,$var) = (shift,shift);
  return eval shift;
}

sub ep{
  my $pkg = __PACKAGE__;
  my $ref = ref $_[0] ? shift : $pkg->new();
  my $src = ref $_[0] ? ${$_[0]} : $_[0];
  my $var = bless {},$pkg.'::Vars';
  my($pos,$now,$tmp) = (1,0,'');
  open TMP,'>>',\$tmp;
  *STDOUT = *TMP;
  local $SIG{ALRM} = sub{ die 'Forced exiting, detected loop'; };
  alarm $TIMEOUT;
  foreach my $tag(split(/(\<\$.+?)\$\>/s,$src)){
    $now = $pos;
    $pos += $tag =~ s/\r\n|[\r\n]/\n/gs;
    if($tag =~ s/^\<\$//){
      my $esc = $tag;
      $esc =~ s/^\s*//g;
      $esc =~ s/\s*$//g;
      $esc =~ s/\&/\&amp;/g;
      $esc =~ s/\</\&lt;/g;
      $esc =~ s/\>/\&gt;/g;
      $esc =~ s/\"/\&quot;/g;
      $esc =~ s/\n/\<br\x20\/\>/g;
      $tmp .= qq!<blockquote style="color:#009900;">$esc</blockquote>!;
      if(!run($ref,$var,$tag) && $@){
        $@ =~ /^Force/ ? $@ =~ s/at\x20.+$/at\x20line\x20$now\x20or\x20after\x20that\./ : $@ =~ s/at\x20\(eval\x20[0-9]+\)\x20line\x20([0-9]+)/'at line '.($now+($1-1))/eg;
        $@ =~ s/\x22/\&quot\;/g; chop $@;
        $tmp .= qq[\n<blockquote style="padding:4px;color:#c00;background-color:#fdd;border:solid 1px #f99;font-size:80%;"><span style="font-weight:bold;">ERROR:</span> $@</blockquote>\n];
        last if $@ =~ /^Force/;
      }
    } else{
      $tag =~ s/(?<![\\\$])(\$((::)?\w+|\[[\x22\x27]?\w+[\x22\x27]?\]|(->)?\{[\x22\x27]?\w+[\x22\x27]?\})+)/eval($1).$@/eg;
      $tmp .= $tag;
    }
  }
  close TMP;
  *STDOUT = $STDBAK;
  return $tmp if defined wantarray;
  flush $ref if ref $ref eq $pkg;
  $ref->print($tmp);
}

sub handler{
  my($r,$c) = (shift,'');
  $r->content_type('text/html');
  return 1 unless open HTM, $r->filename;
  sysread HTM,$c,(-s HTM);
  close HTM;
  ep $r,\$c;
  0;
}

sub new{
  my $s = bless {},shift;
  $s->{type} = 'text/html';
  $s->{head} = '';
  $s;
}

1;

=head1 NAME

HTML::EmbeddedPerl::Test - The Perl embeddings for HTML. I<(for test and debug)>

=head1 DESCRIPTION

visible your code in the output HTML.
not force exiting on found errors.
(forced exiting E<quot>detected loopE<quot> only)

=head1 SEE ALSO

L<HTML::EmbeddedPerl>

=head1 AUTHOR

Twinkle Computing <twinkle@cpan.org>

=head1 LISENCE

Copyright (c) 2010 Twinkle Computing All rights reserved.

This library is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

=cut
