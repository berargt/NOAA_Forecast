package NOAA_Forecast;
##!/usr/bin/perl

sub GetForecast() {
   my $noaa_url = '\'https://forecast.weather.gov/product.php?site=CRH&issuedby=ILX&product=ZFP&format=txt&version=3&glossary=0\'';
   my @html = qx{/usr/bin/curl --silent $noaa_url};

   my $foundPeoriaFlag = 0;
   my $gotTimeDateFlag = 0;
   my $runningFlag = 0;
   my $DayForecast = "";
   my $TimeDate;
   my @Data;
   my $tmp;

   foreach ( @html ) {

      # skip chomping the empty lines and remove them later
      if (m/^\n/) {
         ; # skip
      }
      else
      {
         chomp;
      }

      # Done with processing
      if (m/\$\$/) {
         $foundPeoriaFlag = 0;
      }

      if (m/Peoria-/) {
         $foundPeoriaFlag = 1;
      } elsif ( $foundPeoriaFlag ) {
         if (m/Including the city of Peoria/) {
            ; # skip
         } elsif ( $gotTimeDateFlag == 0 ) {
            $gotTimeDateFlag = 1;
            $TimeDate = $_;
         } elsif (m/\n/) {
            ; # skip
         }
         else {
            $_ =~ /\.([A-Z ]*)\.\.\.(.*)/;
            if ( $1 ) { # New Day
               if ( $DayForecast eq "" && $runningFlag == 0) { # Starting 
                  $runningFlag = 1;
                  $DayForecast = $2;
               }
               else
               {
                  push (@Data, $DayForecast);
                  $DayForecast = "";
               }
               push (@Data, $1);
               $DayForecast = $2;
            }
            else
            {
               $_ = /(.*)/;
               $DayForecast = $DayForecast . " " . $1;
            }
         }
      }
   }

   push (@Data, $DayForecast); # get the last forecast

   return ($TimeDate, @Data);
}


1;
