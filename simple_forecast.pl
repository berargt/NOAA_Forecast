#!/usr/bin/perl -w
#

#use lib "$ENV{HOME}/FORECAST_VANTAGE_PRO/NEW_FORECAST/NOAA_Forecast";
use lib "/home/greg/FORECAST_VANTAGE_PRO/NEW_FORECAST/NOAA_Forecast";
#use lib "/usr/share/perl5";
use NOAA_Forecast;

print "Content-type: text/html\n\n";

my @Day; 
my $TimeDate;
my %forecast;
my $snow = 0;

( $Day, %forecast )  = NOAA_Forecast::GetForecast();

print "<b><h3>" . $forecast{TimeDate} . "</h1></b><br>\n";
#print @Day;

foreach ( @$Day ) {
   my $day_forecast = $forecast{$_};

   if ($day_forecast=~/[S|s]now/) {
      $snow = 1;
   }
   if ($snow == 1) {
      print "<b style=\"color:blue;\">****\n";
   }
   else {
      print "<b>";
   }

   # get the temp (s)
   if ($day_forecast =~/(\d+s)/) {
      print "<b> " . $1 . " </b><br>";
   }
   elsif ($day_forecast =~/(Highs around \d+)/) {
      print "<b> " . $1 . " </b><br>";
   }
   elsif ($day_forecast =~/around (\d+)/) {
      print "<b> " . $1 . " </b><br>";
   }


   # get the Wind (mph)
   if ($day_forecast =~/winds (\d+ to \d+ mph)/) {
      print "<b> Winds " . $1 . " </b><br>";
   }
   elsif ($day_forecast =~/winds (around \d+ mph)/) {
      print "<b> Winds " . $1 . " </b><br>";
   }

   print $_ . " <===> " . "</b>" . $day_forecast . "<br>" . "\n";
   print "<br>\n";

   $snow = 0;
}

