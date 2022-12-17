#!/usr/bin/perl

use lib "/home/greg/perl5/lib/perl5";
use Geo::WeatherNOAA;
use Time::Local;
use GD;
use DBI;

use strict;

use constant TRUE => 1;
use constant FALSE => 0;

# forecast variables
my $date;
my $warnings;
my $forecast;
my $coverage;
my $night;
my $data;
my $image;
my $temperature;
my $scratchfile = "/tmp/forecast.txt";


# print the html header
&print_header();

#($date,$warnings,$forecast,$coverage) = process_city_zone('iowa city','ia','','get');
($date,$warnings,$forecast,$coverage) = process_city_zone('peoria','il','','get');


print "<center>\n";

print "<table width=%75 border=1>\n";
print "<tr>\n";
print "<td valign=top>\n";
# show the current conditions
&current_conditions();
print "</td>\n";


print "<td valign=top>\n";

print "<center>\n";
print "<table border=1>\n";
#print "<tr align=center><th colspan=4 bgcolor=darkblue><font color=white>7-Day Forecast Iowa City, IA</font></th></tr>";
print "<tr align=center><th colspan=4 bgcolor=darkblue><font color=white>7-Day Forecast Peoria, IL</font></th></tr>";

#($date,$warnings,$forecast,$coverage) = process_city_zone('iowa city','ia','','get');

# check to see if there is a forecast @ NOAA
if ((keys %$forecast) == 0) {
    if (! open SCRATCHIN, "<$scratchfile") {
        die "Cannot open scratchfile <$scratchfile>: $!";
    }

    #if there is no forecast then use the text file copy
    while (<SCRATCHIN>) {

    # Do the forecast
        if (/(.*)\|(.*)/) {
            &process_forecast($1, $2);
        }
    }

}
else {        

    # there is a forecast so save the current forecast for future use
    if (! open SCRATCHOUT, ">$scratchfile") {
        die "Cannot create scratchfile <$scratchfile>: $!";
    }

    foreach my $key (keys %$forecast) {
    # write the scratchfile so it can be used when NOAAs forecast is unavailable
        print (SCRATCHOUT "$key| $forecast->{$key}\n");
    # Do the forecast
        print "<pre>";
        &process_forecast($key, $forecast->{$key});
        print "</pre>";
    }
}

# get the scratchfile information to show when last updated
my ($dev, $ino, $mode, $nlink, $uid, $gid, $rdev,
        $size, $atime, $mtime, $ctime, $blksize, $blocks) = stat($scratchfile);
print "<tr>\n";
print "<td align=center colspan=4>\n";
print  "Last Updated - " . localtime($mtime) . "\n";
print "</td>\n";
print "</tr>\n";

# The warnings
foreach my $warn (@$warnings) {
    print "<tr>\n";
    print "<a
    href=\"http://www.crh.noaa.gov/showsigwx.php?warnzone=ILZ029&warncounty=ILC143&local_place1=Peoria+IL&product1=Short+Term+Forecast\"><font color=red><b>$warn</b></font></a>\n";
    print "</br>\n";
    print "</tr>\n";
}

print "</table>\n";
print "</center>\n";

print "</td>\n";
print "</tr>\n";
print "</table>\n";

print "</center>\n";
&print_close_html();

#  print process_city_hourly('newport news', 'va', '', 'get');
exit;


sub print_header {
    print "Content-Type: text/html; charset=iso-8859-1\n";
    print "\n";
    print "<!DOCTYPE HTML PUBLIC \"-//IETF//DTD HTML 2.0//EN\">";
    print "<html>\n";
    print "<head>\n";
    print "<title>\n";
#    print "7-Day Forecast Iowa City, IA\n";
    print "7-Day Forecast Peoria, IL\n";
    print "</title>\n";
    print "<meta http-equiv=\"refresh\" content=\"300\">\n";
    print "</head>\n";
    print "<body>\n";
}

sub process_forecast {

    my $key = shift @_;
    $data = shift @_;

    if ($key =~ m/(N|n)ight/) {
        if ($key !~ m/(A|a)nd/){
            if ($key !~ m/(T|t)hrough/){
                $night = *TRUE;
            }
        }
    }


    my $temperature;

    if ($data =~ m/(upper|lower|mid) (\d{2}|\d{1})/) {
        $temperature = ucfirst($1) . "<br>" . ucfirst($2) . "s";
    }
    elsif ($data =~ m/Heat index readings to (\d{3}|\d{2}|\d{1})/) {
        $temperature = "Heat index" . "<br>" . $1 . "&#0176;F";
    }
    elsif ($data =~ m/(around) (\d{2}|\d{1}) (below)/) {
        $temperature = ucfirst($1) . "<br>" . "-" . ucfirst($2) . "&#0176;F";
    }
    elsif ($data =~ m/(near|around) (\d{2}|\d{1})/) {
        $temperature = ucfirst($1) . "<br>" . ucfirst($2) . "&#0176;F";
    }
    elsif ($data =~ m/zero/) {
        $temperature = "0" . "&#0176;F";
    }


    &select_img();

    print "<tr><td><img src=\"/images/WEATHER/$image\" width=50 height=50 border=0></a></td><td align=center><b>$temperature</b></td><td align=right><font color=blue><b>$key:</td></b></font><td>$data</td></tr>\n";
    $night = *FALSE;
}


sub print_close_html {
    print "</body>\n";
    print "</html>\n";
}

sub select_img {

    if ($night eq *TRUE) {
        if ($data =~ m/(T|t)hunderstorms/) {
            $image = "thunder_night.gif";
        }
        elsif ($data =~ m/(F|f)lurries/) {
            $image = "light_snow_night.gif";
        }
        elsif ($data =~ m/(S|s)now/) {
            if ($data =~ m/(H|h)eavy/) {
                $image = "heavy_snow_night.gif";
            }
            elsif ($data =~ m/(L|l)ight/) {
                $image = "light_snow_night.gif";
            }
            elsif ($data =~ m/(F|f)lurries/) {
                $image = "light_snow_night.gif";
            }
            else {
                $image = "snow_night.gif";
            }
        }
        elsif ($data =~ m/(I|i)cy/){
            $image = "icy_night.gif";
        }
        elsif ($data =~ m/(S|s)hower/){
            if ($data =~ m/(H|h)eavy/) {
                $image = "heavy_rain_night.gif";
            }
            else {
                $image = "light_rain_night.gif";
            }
        }
        elsif ($data =~ m/(R|r)ain/){
            if ($data =~ m/(H|h)eavy/) {
                $image = "heavy_rain_night.gif";
            }
            else {
                $image = "light_rain_night.gif";
            }
        }
        elsif ($data =~ m/(D|d)rizzle/){
            $image = "light_rain_night.gif";
        }
        elsif ($data =~ m/(W|w)indy/) {
            $image = "windy_night.gif";
        }
        elsif ($data =~ m/(C|c)loudy/) {
            if ($data =~ m/(M|m)ostly/) {
                $image = "mostly_cloudy_night.gif";
            }
            else {
                $image = "cloudy_night.gif";
            }
        }
        elsif ($data =~ m/(C|c)lear/) {
            if ($data =~ m/(M|m)ostly/) {
                $image = "mostly_clear_night.gif";
            }
            elsif ($data =~ m/(P|p)artly/) {
                $image = "partly_clear_night.gif";
            }
            else {
                $image = "clear_night.gif";
            }
        }
        else {
            $image = "clear_night.gif";
        }
    } # end NIGHT
    else {
        if ($data =~ m/(T|t)hunderstorms/) {
            $image = "thunder_day.gif";
        }
        elsif ($data =~ m/(F|f)lurries/) {
            $image = "light_snow_day.gif";
        }
        elsif ($data =~ m/(S|s)now/) {
            if ($data =~ m/(H|h)eavy/) {
                $image = "heavy_snow_day.gif";
            }
            elsif ($data =~ m/(L|l)ight/) {
                $image = "light_snow_day.gif";
            }
            else {
                $image = "snow_day.gif";
            }
        }
        elsif ($data =~ m/(I|i)cy/){
            $image = "icy_day.gif";
        }
        elsif ($data =~ m/(S|s)hower/){
            if ($data =~ m/(H|h)eavy/) {
                $image = "heavy_rain_day.gif";
            }
            else {
                $image = "light_rain_day.gif";
            }
        }
        elsif ($data =~ m/(R|r)ain/){
            if ($data =~ m/(H|h)eavy/) {
                $image = "heavy_rain_day.gif";
            }
            else {
                $image = "light_rain_day.gif";
            }
        }
        elsif ($data =~ m/(D|d)rizzle/){
            $image = "light_rain_day.gif";
        }
        elsif ($data =~ m/(W|w)indy/) {
            $image = "windy_day.gif";
        }
        elsif ($data =~ m/(C|c)loudy/) {
            if ($data =~ m/(M|m)ostly/) {
                $image = "mostly_cloudy_day.gif";
            }
            elsif ($data =~ m/(P|p)artly/) {
                $image = "partly_clear_day.gif";
            }
            else {
                $image = "cloudy_day.gif";
            }
        }
        elsif ($data =~ m/(C|c)lear/) {
            if ($data =~ m/(M|m)ostly/) {
                $image = "mostly_clear_day.gif";
            }
            elsif ($data =~ m/(P|p)artly/) {
                $image = "partly_clear_day.gif";
            }
            else {
                $image = "clear_pr.gif";
            }
        }
        else {
            $image = "clear_pr.gif";
        }
    }
}

sub current_conditions {

    # current conditions
    my @Current;

    (my $sec,my $min,my $hour,my $mday,my $mon,my $year,my $wday,my $yday,my $isdst) = localtime();

    #get current conditions in variables

    # connect to the wviewDB database
    my $dbh = DBI->connect("dbi:SQLite:dbname=/opt/vpro/realtime.db","","");

    # forecast variables
    my $OutTemp;
    my $InTemp;
#    my $Dewpoint;
    my $OutHumid;
    my $WindSpeed;
    my $Barometer;
    my $HeatIndex;
#    my $WindChill;
    my $Rain;
    my $HiRainRate;


    # prepare and execute the query
    my $sth = $dbh->prepare(qq{select it, ot, oh, was, bc, rr, dr from rt order by dt desc limit 1});
    $sth->execute();

    #get current conditions in variables
    ($InTemp, $OutTemp, $OutHumid, $WindSpeed, $Barometer, $HiRainRate, $Rain) = $sth->fetchrow_array;

#    $sth = $dbh->prepare(qq{select sum(rain) from archive where date('now','-1 day') <= date(dateTime,'unixepoch')});
#    $sth->execute();

#    ($Rain) = $sth->fetchrow_array;

#    $sth = $dbh->prepare(qq{select max(rainRate) from archive where date('now', '-1 day') <= date(dateTime,'unixepoch')});
#    $sth->execute();

#    ($HiRainRate) = $sth->fetchrow_array;


    # format the values
    $InTemp = sprintf("%.1f", $InTemp);
    $OutTemp = sprintf("%.1f", $OutTemp);
#    $Dewpoint = sprintf("%.1f", $Dewpoint);
    $OutHumid = sprintf("%.1f", $OutHumid);
    $WindSpeed = sprintf("%i mph", $WindSpeed);
    $Barometer = sprintf("%0.1f inHg", $Barometer);
#    $HeatIndex = sprintf("%.1f", $HeatIndex);
#    $WindChill = sprintf("%.1f", $WindChill);
    $Rain = sprintf("%.2f", $Rain);
    $HiRainRate = sprintf("%.2f", $HiRainRate);



    # store the data in an array
    push @Current, "Time" . "\t" . sprintf("%02d/%02d/%02d %02d:%02d:%02d", $mon+1, $mday, $year+1900, $hour, $min, $sec);
    push @Current, "In Temp" . "\t" . "$InTemp&#0176;F";
    push @Current, "Out Temp" . "\t" . "$OutTemp&#0176;F";
#    push @Current, "Dewpoint" . "\t" . "$Dewpoint&#0176;F";
    push @Current, "Humid" . "\t" . "$OutHumid%";
    push @Current, "Wind Speed" . "\t" . "$WindSpeed";
    push @Current, "Baro" . "\t" . "$Barometer";

#    if ($HeatIndex != $OutTemp) {
#        push @Current, "Heat Index" . "\t" . "$HeatIndex&#0176;F";
#    }

#    if ($WindChill != $OutTemp) {
#        push @Current, "Wind Chill" . "\t" . "$WindChill&#0176;F";
#    }

    push @Current, "Rain (24hrs)" . "\t" . "$Rain\"";
    push @Current, "Hi Rain Rate (24hrs)" . "\t" . "$HiRainRate in/hr";
#    push @Current, "<a href=\"http://www.srh.noaa.gov/ridge/lite/N0R/DVN_loop.gif\">Radar Loop</a>" . "\t" . "<a href=\"http://www.srh.noaa.gov/ridge/lite/N0R/DVN_loop.gif\"><img width=100 height=100 src=\"http://www.srh.noaa.gov/ridge/lite/N0R/DVN_loop.gif\" border=0></a>";
#    push @Current, "<a href=\"/WVIEW/\">More Data Than You Want</a>" . "\t" . "<a href=\"/WVIEW\"><img width=120 height=72 src=\"/WVIEW/tempdaycomp.png\" border=0></a>";
    push @Current, "<a href=\"http://spaceweather.com/\">Space<br>Weather</a>" . "\t" . "<a href=\"http://spaceweather.com/\"><img src=\"/images/WEATHER/space.com.gif\" border=0></a>";
    push @Current, "<a href=\"https://s.w-x.co/staticmaps/wu/wxtype/county_loc/spi/animate.png\">Intelicast Animated Radar Map</a>" . "\t" . "<a href=\"https://s.w-x.co/staticmaps/wu/wxtype/county_loc/spi/animate.png\"><img width=100 height=75 src=\"https://s.w-x.co/staticmaps/wu/wxtype/county_loc/spi/animate.png\" border=0></a>";
    push @Current, "<a href=\"https://s.w-x.co/staticmaps/wu/wxtype/none/usa/animate.png\">Intelicast Animated Radar Map</a>" . "\t" . "<a href=\"https://s.w-x.co/staticmaps/wu/wxtype/none/usa/animate.png\"><img width=100 height=75 src=\"https://s.w-x.co/staticmaps/wu/wxtype/none/usa/animate.png\" border=0></a>";
    push @Current, "<a href=\"http://www.rap.ucar.edu/weather/\">Real Time Weather Data</a>" . "\t" . "<a href=\"http://www.rap.ucar.edu/weather/\"><img src=\"/images/ucar.gif\" width=100 height=75 border=0></a>";
   push @Current, "<a href=\"http://hint.fm/wind/\">Wind Map</a>" . "\t" . "<a href=\"http://hint.fm/wind/\"><img src=\"/images/WEATHER/WindMap.png\" width=100 border=0></a>";
   push @Current, "<a href=\"http://earth.nullschool.net/#current/wind/surface/level/orthographic=-94.38,35.07,765\">NullSchool WindMap</a>" . "\t" . "<a href=\"http://earth.nullschool.net/#current/wind/surface/level/orthographic=-94.38,35.07,765\"><img src=\"/images/WEATHER/nullschool.png\" width=100 border=0></a>";
    push @Current, "<a href=\"http://berardi.us\">berardi.us</a>" . "\t" . "<a
    href=\"http://berardi.us\"><img src=\"/images/1264Lindemann(lot25).JPG\" width=100 height=75 border=0></a>";
    push @Current, "<a href=\"http://weatherbase.com/\">Weatherbase</a>" . "\t" . "<a href=\"http://www.weatherbase.com/weather/weather.php3?s=23527&cityname=Peoria-Illinois-United-States-of-America\">Peoria IL</a>";
##   push @Current, "<a href=\"\"></a>" . "\t" . "<a href=\"\"><img src=\"\" border=0></a>";
#   push @Current, "<a href=\"\"></a>" . "\t" . "<a href=\"\"><img src=\"\" border=0></a>";

    # print table
    print "<center>\n";
    print "<table border=1>\n";
    print "<tr align=center><th colspan=2 bgcolor=darkblue><font color=white>Current Conditions</font></th></tr>\n";
    foreach my $var(@Current) {
        if ($var =~ m/(.*)\t(.*)/) {
            print "<tr><td>$1</td><td align=center>$2</td></tr>\n";
        }
    }
    print "</table>\n";
    print "</center>\n";

    # close the database connection nicely
    $sth->finish;
#    $dbh->commit;
    $dbh->disconnect;


}

# SQLite
# http://www.sqlite.org/lang_datefunc.html


#sqlite> .schema archive
#CREATE TABLE archive (
#	dateTime                INTEGER NOT NULL UNIQUE PRIMARY KEY,
#	usUnits                 INTEGER NOT NULL,
#	interval                INTEGER NOT NULL,
#	barometer               REAL,
#	pressure                REAL,
#	altimeter               REAL,
#	inTemp                  REAL,
#	outTemp                 REAL,
#	inHumidity              REAL,
#	outHumidity             REAL,
#	windSpeed               REAL,
#	windDir                 REAL,
#	windGust                REAL,
#	windGustDir             REAL,
#	rainRate                REAL,
#	rain                    REAL,
#	dewpoint                REAL,
#	windchill               REAL,
#	heatindex               REAL,
#	ET                      REAL,
#	radiation               REAL,
#	UV                      REAL,
#	extraTemp1              REAL,
#	extraTemp2              REAL,
#	extraTemp3              REAL,
#	soilTemp1               REAL,
#	soilTemp2               REAL,
#	soilTemp3               REAL,
#	soilTemp4               REAL,
#	leafTemp1               REAL,
#	leafTemp2               REAL,
#	extraHumid1             REAL,
#	extraHumid2             REAL,
#	soilMoist1              REAL,
#	soilMoist2              REAL,
#	soilMoist3              REAL,
#	soilMoist4              REAL,
#	leafWet1                REAL,
#	leafWet2                REAL,
#	rxCheckPercent          REAL,
#	txBatteryStatus         REAL,
#	consBatteryVoltage      REAL,
#	hail                    REAL,
#	hailRate                REAL,
#	heatingTemp             REAL,
#	heatingVoltage          REAL,
#	supplyVoltage           REAL,
#	referenceVoltage        REAL,
#	windBatteryStatus       REAL,
#	rainBatteryStatus       REAL,
#	outTempBatteryStatus    REAL,
#	inTempBatteryStatus     REAL
