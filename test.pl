#!/usr/bin/perl -w
#

#use lib "$ENV{HOME}/FORECAST_VANTAGE_PRO/NEW_FORECAST/NOAA_Forecast";
use lib "/home/greg/FORECAST_VANTAGE_PRO/NEW_FORECAST/NOAA_Forecast";
use NOAA_Forecast;

my @Day; 
my $TimeDate;
my %forecast;

( $Day, %forecast )  = NOAA_Forecast::GetForecast();

print $forecast{TimeDate} . "\n";
#print @Day;

foreach ( @$Day ) {
   print $_ . " <---> " . $forecast{$_} . "\n";
}

