#!/usr/bin/perl -w
#

#use lib "$ENV{HOME}/FORECAST_VANTAGE_PRO/NEW_FORECAST/NOAA_Forecast";
use lib "/home/greg/FORECAST_VANTAGE_PRO/NEW_FORECAST/NOAA_Forecast";
use NOAA_Forecast;

(my $TimeDate, my @Data) = NOAA_Forecast::GetForecast();

print $TimeDate . "\n";

foreach ( @Data ) {
   my ($a) = $_;
   print $a . "\n";
}
