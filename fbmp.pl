#!/usr/bin/perl
use strict;
use warnings;
use Win32::Console;

my $OUT = Win32::Console->new(STD_OUTPUT_HANDLE);
   $OUT->Cls;
#=============================================================================================================================
#MAIN ROUTINE

my $input = &readstr("goettertrutz (intime) (input).htm");
my $chan  = "goettertrutz (intime)";
my @messages;
my $num_msg = &parse($input);
print "Messages parsed: ".$num_msg."\n";
&export_html_tab("output.htm");
&export_csv("output.csv");
#&export_JSON("output.txt");

#=============================================================================================================================
sub readstr
{
  my $string = "";
  open(DATEI, "<", $_[0]) or die("File not found $!");
  while(<DATEI>) {$string = $string.$_;}
  close(DATEI);
  return($string);
}
#=============================================================================================================================
sub parse
{
  my $item = 0;
  while($_[0] =~ /<div class="rfloat _ohf">.*?data-utime="(.*?)\..*?<strong class="_36">.*?">(.*?)<\/a>.*?<div class="_53">(.*?)<\/li>/gis){
    $item++;
    $messages[$item][1] = $1;            # timestamp
    $messages[$item][2] = &cleanup($2);  # user
    $messages[$item][3] = &cleanup($3);  # message content

    $messages[$item][4] = $messages[$item][1];               # timestamp
    $messages[$item][5] = &JSON_clean($messages[$item][2]);  # user für JSON export
    $messages[$item][6] = &JSON_clean($messages[$item][3]);  # message content für JSON export
    
    $messages[$item][7] = $messages[$item][1];               # timestamp
    $messages[$item][8] = &CSV_clean($messages[$item][2]);   # user für CSV export
    $messages[$item][9] = &CSV_clean($messages[$item][3]);   # message content für CSV export
  }
  return $item;
}
#=============================================================================================================================
sub cleanup
{
  my $html = $_[0];
# überflüssige Leerzeichen & Absätze entfernen
     $html =~ s/\r//gis;
     $html =~ s/\t//gis;
     $html =~ s/ {1,}/ /gis;
     $html =~ s/> </></gis;
     $html =~ s/ </</gis;

# Umlaute, Sonderzeichen
#     $html =~ s/Ã„/#a_#/gis;
#     $html =~ s/Ã¤/#a#/gis;
#     $html =~ s/Ã–/#o_#/gis;
#     $html =~ s/Ã¶/#o#/gis;
#     $html =~ s/Ãœ/#u_#/gis;
#     $html =~ s/Ã¼/#u#/gis;
#     $html =~ s/ÃŸ/#sz#/gis;
#     $html =~ s/[^[:ascii:]]+//gis;
#     $html =~ s/#a_#/Ä/gis;
#     $html =~ s/#a#/ä/gis;
#     $html =~ s/#o_#/Ö/gis;
#     $html =~ s/#o#/ö/gis;
#     $html =~ s/#u_#/Ü/gis;
#     $html =~ s/#u#/ü/gis;
#     $html =~ s/#sz#/ß/gis;

# überflüssige html-tags entfernen
     $html =~ s/<div style="background\-image: url\(&quot;/<img src="http:\/\/www\.facebook\.com/gis;
     $html =~ s/&amp;image_type=BestEffortImage.*?sticker">/">/gis;
     $html =~ s/<div.*?>//gis;
     $html =~ s/<\/div>//gis;
#     $html =~ s/<div class="_3hi clearfix">//gis;
#     $html =~ s/<div class="_38 direction_ltr">//gis;
#     $html =~ s/<div class="_1yr">//gis;

     $html =~ s/span class="_1gwo"/img/gis;
     $html =~ s/<span.*?>//gis;
     $html =~ s/<\/span>//gis;
     #$html =~ s/<span aria-hidden.*?>//gis;
     #$html =~ s/<span class="null">//gis;
     #$html =~ s/<span class="_2oy">//gis;

     $html =~ s/<ul.*?>//gis;
     $html =~ s/<\/ul>//gis;

     $html =~ s/<i style="background-image: url\(&quot;/<img src="/gis;
     $html =~ s/&quot;\);" class="_3kkw//gis;
     $html =~ s/<i .*?>//gis;
     $html =~ s/<\/i>//gis;
     #$html =~ s/<i class="_2fs1">//gis;
     #$html =~ s/<i class="_4ay8">//gis;

     $html =~ s/<a href="file:.*?data-reactroot=""><\/a>//gis;
     $html =~ s/rel="nofollow"//gis;
     $html =~ s/class="_553k"/class="exturl"/gis;

#emoticons
     $html =~ s/ :D/ :grinning:/gis;           #grin emoticon
     $html =~ s/ XD/ :grinning:/gis;           #grin emoticon
     $html =~ s/ :-\)/ :smile:/gis;            #smile emoticon
     $html =~ s/ :\)/ :smile:/gis;             #smile emoticon
     $html =~ s/ ;\)/ :wink:/gis;              #wink emoticon
     $html =~ s/ ;D/ :wink:/gis;               #wink emoticon
     $html =~ s/ :\(/ :frowning:/gis;          #frown emoticon
     $html =~ s/ :P/ :stuck_out_tongue:/gis;   #tongue emoticon
     $html =~ s/&gt;_&lt;/:worried:/gis;     #upset emoticon
     $html =~ s/\^_\^/:smile_cat:/gis;       #kiki emoticon
     $html =~ s/\(y\)/:thumbsup:/gis;        #like emoticon
     $html =~ s/\(Y\)/:thumbsup:/gis;        #like emoticon
     $html =~ s/ :\/ / :thinking_face:/gis;     #unsure emoticon
     $html =~ s/ :\*/ :kissing:/gis;           #kiss emoticon

  return $html;
}
#=============================================================================================================================
sub JSON_clean
{
  my $html = $_[0];
#Users
     $html =~ s/Sven Sommerfeld/U24FCJWTC/gis;
     $html =~ s/Oliver Madlener/Oliver Madlener/gis;
     $html =~ s/Ben Köhnobi/Ben Köhnobi/gis;
     $html =~ s/Agate Bauer/Agate Bauer/gis;
     $html =~ s/Roman Förster/U25DDC8Q1/gis;
     $html =~ s/Svenja Wiertz/Svenja Wiertz/gis;

# Absätze umformatieren
     $html =~ s/<p>//gis;
     $html =~ s/<\/p>/\\n/gis;

# Umlaute, Sonderzeichen
     $html =~ s/Ä/\\u00c4/gis;
     $html =~ s/ä/\\u00e4/gis;
     $html =~ s/Ö/\\u00d6/gis;
     $html =~ s/ö/\\u00f6/gis;
     $html =~ s/Ü/\\u00dc/gis;
     $html =~ s/ü/\\u00fc/gis;
     $html =~ s/ß/\\u00df/gis;

  return $html;
}
#=============================================================================================================================
sub CSV_clean
{
  my $html = $_[0];

     $html =~ s/"/'/gis;
     $html =~ s/<\/p>/\n/gis;
#     $html =~ s/<img src=//gis;
     $html =~ s/<.*?>/ /gis;
     $html =~ s/>//gis;

# Umlaute, Sonderzeichen
#     $html =~ s/Ä/\\u00c4/gis;
#     $html =~ s/ä/\\u00e4/gis;
#     $html =~ s/Ö/\\u00d6/gis;
#     $html =~ s/ö/\\u00f6/gis;
#     $html =~ s/Ü/\\u00dc/gis;
#     $html =~ s/ü/\\u00fc/gis;
#     $html =~ s/ß/\\u00df/gis;

  return $html;
}
#=============================================================================================================================
sub export_html_tab
{
  open(DATEI, ">", $_[0]) or die("File not found $!");
  print DATEI "<html>\n<head></head>\n<body>\n<table border=1>\n";
  for (my $i=1; $i<=$num_msg; $i++) {
    print DATEI "<tr>";
    print DATEI "<td>".$messages[$i][1]."</td>";
    print DATEI "<td>".$messages[$i][2]."</td>";
    print DATEI "<td>".$messages[$i][3]."</td>";
    print DATEI "</tr>";
    print DATEI "\n";
  }
  close(DATEI);
}
#=============================================================================================================================
sub export_csv
{
  open(DATEI, ">", $_[0]) or die("File not found $!");
  for (my $i=1; $i<=$num_msg; $i++) {
    print DATEI '"'.$messages[$i][7].'","'.$chan.'","'.$messages[$i][8].'","'.$messages[$i][9].'"';
    print DATEI "\n";
  }
  close(DATEI);
}
#=============================================================================================================================
sub export_JSON
{
  open(DATEI, ">", $_[0]) or die("File not found $!");
  print DATEI "[\n";
  for (my $i=1; $i<=$num_msg; $i++) {
    print DATEI '    {'."\n";
    print DATEI '        "type": "message",'."\n";
    print DATEI '        "user": "'.$messages[$i][5].'",'."\n";
    print DATEI '        "text": "'.$messages[$i][6].'",'."\n";
    print DATEI '        "ts": "'.$messages[$i][1].'.000001"'."\n";
    print DATEI '    }';
    if ($i != $num_msg) {print DATEI ',';}
    print DATEI "\n";
  }
  print DATEI "]\n";
  close(DATEI);
}