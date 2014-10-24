#!/usr/bin/perl
package twept;
use strict;
use warnings;
our $VERSION = '0.07';
our $TIMEOUT = 2;
local $SIG{ALRM} = sub{ die 'Force exiting, detected loop'; };
my $STDBAK = *STDOUT;
sub header_out{
  my $f = 0; for(my $i=0;$i<@{$_[0]->{h}};$i++){
    my($k,$v) = split /\: /,@{$_[0]->{h}}[$i],2;
    if($k eq $_[1]){
      @{$_[0]->{h}}[$i] = "$k: $_[2]" if($v ne $_[2]);
      $f++; last;
    }
  }
  push(@{$_[0]->{h}},"$_[1]: $_[2]") if(!$f);
}
sub content_type{ $_[0]->{t} = $_[1]; }
sub flush{ print $STDBAK (@{$_[0]->{h}} ? join("\r\n",@{$_[0]->{h}})."\r\n":'')."Content-Type: $_[0]->{t}\r\n\r\n"; } }
sub print{ shift; CORE::print @_; }
sub run{ my($epl,$var) = (shift,shift); return eval shift; }
my $var = bless {},__PACKAGE__.'::Vars';
my $ref = bless {};
$ref->{t} = 'text/html';
$ref->{h} = [];
my $src = '';
exit unless open S,@ARGV ? shift @ARGV : exit;
sysread S,$src,(-s S);
close S;
my($pos,$now,$tmp) = (-1,0,'');
$src =~ s/^\#[^\r\n]+//;
$pos += $src  =~ s/^\r\n|^[\r\n]//gs;
open TMP,'>>',\$tmp;
*STDOUT = *TMP;
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
$tmp .= "<blockquote style=\"color:#009900;\">$esc</blockquote>";
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
}; close TMP; *STDOUT = $STDBAK; flush $ref; print $tmp;
