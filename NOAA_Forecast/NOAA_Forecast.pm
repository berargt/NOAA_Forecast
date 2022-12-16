package NOAA_Forecast;

sub GetForecast() {
   my $noaa_url = '\'https://forecast.weather.gov/product.php?site=CRH&issuedby=ILX&product=ZFP&format=txt&version=3&glossary=0\'';
   my @html = qx{/usr/bin/curl --silent $noaa_url};

   my $foundPeoriaFlag = 0;
   my $gotTimeDateFlag = 0;
   my $runningFlag = 0;
   my $DayForecast = "";
   my $Day; #ordered list of the days that is used to index the hash
   my %forecast;
   my $key;

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
            $forecast{'TimeDate'} = $_;
         } elsif (m/\n/) {
            ; # skip
         }
         else {
            $_ =~ /\.([A-Z ]*)\.\.\.(.*)/;
            if ( $1 ) { # New Day
               if ( $DayForecast eq "" && $runningFlag == 0) { # Starting 
                  $runningFlag = 1;
               }
               else
               {
                  $forecast{$key} = $DayForecast; 
               }
               push (@Day, $1);
               $key = $1;
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

   $forecast{$key} = $DayForecast; 

   return \@Day, %forecast;
}

1;
