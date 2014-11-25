#!/usr/bin/perl

 package c2;
 use strict;
 use DateTime;
 use Date::Calc qw(Week_of_Year Date_to_Days Add_Delta_Days); 
 use Text::CSV; 
 use DBI;
 use DBD::mysql; 
 use Switch;
# use SGI::FAM;
 use Sys::Gamin;
 use HTTP::Date;

   $c2::sqlsrow = "SELECT date_time, workout_name, distance, elapsed, stroke_rate, avg_HR, pace, cal_per_hour, watts from C2_log_row where date_time = ? and workout_name like ? and distance =?;"; 
   $c2::sqlirow = "INSERT into C2_log_row (date_time, workout_name, distance, elapsed, stroke_rate, avg_HR, pace, cal_per_hour, watts) VALUES(?,?,?,?,?,?,?,?,?);";
   $c2::sqlurow = "UPDATE C2_log_row SET elapsed=?, stroke_rate=?, avg_HR=?, pace=?, cal_per_hour=?, watts=? WHERE date_time =? AND workout_name =? AND distance =? ;";
   $c2::sqlsrest = "SELECT date_time, workout_name, distance, elapsed from C2_log_rest where date_time = ? and workout_name like ? and distance = ?;";
   $c2::sqlirest = "INSERT into C2_log_rest (date_time, workout_name, distance, elapsed) VALUES(?,?,?,?);";
  $c2::sqlurest = "UPDATE C2_log_rest SET elapsed =? WHERE date_time =? AND workout_name =? AND distance =?;";
  $c2::sqlssplit = "SELECT date_time, workout_name, distance, elapsed, stroke_rate, avg_HR, pace, cal_per_hour, watts from C2_log_split where date_time = ? and workout_name like ? and distance = ?;";
  $c2::sqlisplit = "INSERT into C2_log_split (date_time, workout_name, distance, elapsed, stroke_rate, avg_HR, pace, cal_per_hour, watts) VALUES(?,?,?,?,?,?,?,?,?);";
  $c2::sqlusplit = "UPDATE C2_log_split SET elapsed=?, stroke_rate=?, avg_HR=?, pace=?, cal_per_hour=?, watts=? WHERE date_time =? AND workout_name =? AND distance =?;";
  $c2::sqlsweek = "SELECT year_rowed, week_rowed FROM C2_log_weekly WHERE week_rowed = ? and year_rowed = ?;";
  $c2::sqlsmonth = "SELECT year_rowed, month_rowed FROM C2_log_monthly WHERE month_rowed=? and year_rowed=?;";
  $c2::sqliweek = "INSERT into C2_log_weekly (year_rowed, week_rowed, distance, elapsed, rest_dist, rest_time) VALUES(?, ?, ?, ?, ?, ?);";
  $c2::sqlimonth = "INSERT into C2_log_monthly (year_rowed, month_rowed, distance, elapsed, rest_dist, rest_time) VALUES(?, ?, ?, ?, ?, ?);";
  $c2::sqluweek = "UPDATE C2_log_weekly set distance = distance + ?, elapsed = elapsed + ?, rest_dist = rest_dist + ?, rest_time = rest_time + ? WHERE week_rowed = ? and year_rowed = ?;";
  $c2::sqlumonth = "UPDATE C2_log_monthly set distance = distance + ?, elapsed = elapsed + ?, rest_dist = rest_dist + ?, rest_time = rest_time + ? WHERE month_rowed=? and year_rowed=?;";


 my ($fm,$fy) = (localtime)[4,5];
 $fy += 1900;
 $fm++;
 if ($fm < 10) {$fm = "0".$fm;}
 my $file = "/home/dougie/Documents/Concept2/LogCard Data/".$fy."-".$fm.".csv";
#my $fam = new SGI::FAM;
 my $fam = new Sys::Gamin;
 $fam->monitor($file);
 while(1) {
   my $event = $fam->next_event;
   print $event->filename, " ", $event->type, "\r\n";
# print $file."\r\n";
   if (($event->type eq "create") or ($event->type eq "change")) {

# MySQL c2::connection info
    my $user = "test_crud";
    my $pw = "gobswave";
    my $database = "c2_log";
    my $host = "localhost";

    my $mysql = "dbi:mysql:$database:$host:3306";
    $c2::connect = DBI->connect($mysql, $user, $pw);
    $c2::connect->{'AutoCommit'} = 0;

    $c2::query_1 = $c2::connect->prepare($c2::sqlsrow);
    $c2::query_2 = $c2::connect->prepare($c2::sqlirow);
    $c2::query_3 = $c2::connect->prepare($c2::sqlurow);
    $c2::query_4 = $c2::connect->prepare($c2::sqlsrest);
    $c2::query_5 = $c2::connect->prepare($c2::sqlirest);
    $c2::query_6 = $c2::connect->prepare($c2::sqlurest);
    $c2::query_7 = $c2::connect->prepare($c2::sqlssplit);
    $c2::query_8 = $c2::connect->prepare($c2::sqlisplit);
    $c2::query_9 = $c2::connect->prepare($c2::sqlusplit);
    $c2::query3s = $c2::connect->prepare($c2::sqlsweek);
    $c2::query4s = $c2::connect->prepare($c2::sqlsmonth);
    $c2::insert1 = $c2::connect->prepare($c2::sqliweek);
    $c2::insert2 = $c2::connect->prepare($c2::sqlimonth);
    $c2::update1 = $c2::connect->prepare($c2::sqluweek);
    $c2::update2 = $c2::connect->prepare($c2::sqlumonth);

   my @col;

   my $csv = Text::CSV->new();
   open (CSV, "<", $file) or die $!;

   my $format = "Unknown"; 
   my $fsecs=0;
   my $year;
   my $day;
   my $mon;
   $c2::zero=0;

   while (<CSV>) {
     $csv->parse($_);
     @col = $csv->fields();
     switch ($col[0]) {
       case "PM3 LogCard Utility - Version 3.02" {$format ="American";}
       case "PM3 LogCard Utility - Version 3.0.2" {$format ="American";} 
       case "PM3 LogCard Utility - Version 4.04" {$format ="American";}
       case "LogCard Utility - Version 5.01" {$format ="American";} 
       case "LogCard Utility - Version 5.06" {$format ="Euro";} 
       case "LogCard Utility - Version 5.09" {$format ="Euro";} 
       case "LogCard Utility - Version 6.00" {$format ="Euro";} 
       case "LogCard Utility - Version 6.1" {$format ="Euro";} 
       case "LogCard Utility - Version 6.21" {$format ="Euro";} 
       case "LogCard Utility - Version 6.22" {$format ="Euro";} 
       case "LogCard Utility - Version 6.2" {$format ="Euro";} 
       case "Concept2 Utility - Version 6.26" {$format ="Euro";} 
       case "Concept2 Utility - Version 6.3" {$format ="Euro";} 
       case "Concept2 Utility - Version 6.4" {$format ="Euro";} 
       case "Concept2 Utility - Version 6.41" {$format ="Euro";} 
       case "Concept2 Utility - Version 6.49" {$format ="Euro";} 
       case "Concept2 Utility - Version 6.5" {$format ="Euro";} 
       case "Concept2 Utility - Version 6.53" {$format ="Euro";} 
       case "Concept2 Utility - Version 6.54" {$format ="Euro";} 
       case "Concept2 Utility - Version 6.55" {$format ="Euro";} 
       case "Concept2 Utility - Version 6.77" {$format ="Euro";} 
       else {$format=$format;}
     }
     if ($format eq "Euro") { ($day,$mon,$year) = split('/',$col[2]);}
     elsif ($format eq "American") { ($mon,$day,$year) = split('/',$col[2]);}
     else { die "Unknown file header";} 
     $col[2] = $year."-".$mon."-".$day;
     if ($col[1] ne "Dougie" or $col[4] eq "") {
       $col[0] .= "NOTWKOUT";
#     PrintCol(@col);
     } elsif ($col[17] ne "") { 
       $col[0] .= "REST";
       $fsecs++;
       if ($fsecs == 60) {$fsecs = 0;}
       if ($fsecs < 10) {$col[18] = "0".$fsecs;}
       else {$col[18] = $fsecs;}
       my ($h, $m, $s, $t, $secs) = timeToSecs($col[16]);
       $col[16] = $secs;
       ProcRest(@col);
     } elsif ($col[9] eq "") { 
       $c2::connect->commit();
       $col[0] .= "ROW";
       $fsecs = 0;
       if ($fsecs == 60) {$fsecs = 0;}
       if ($fsecs < 10) {$col[18] = "0".$fsecs;}
       else {$col[18] = $fsecs;}
       my ($h, $m, $s, $t, $secs) = timeToSecs($col[5]);
       $col[5] = $secs;
       my ($h, $m, $s, $t, $secs) = timeToSecs($col[13]);
       $col[13] = $secs;
       ProcRow(@col);
     } elsif ($col[5] eq "") { 
       $col[0] .= "SPLIT";
       $fsecs++;
       if ($fsecs == 60) {$fsecs = 0;}
       if ($fsecs < 10) {$col[18] = "0".$fsecs;}
       else {$col[18] = $fsecs;}
       my ($h, $m, $s, $t, $secs) = timeToSecs($col[9]);
       $col[9] = $secs;
       my ($h, $m, $s, $t, $secs) = timeToSecs($col[13]);
       $col[13] = $secs;
       ProcSplit(@col);
     }
#  PrintCol(@col);
   }

   close CSV;
   print "Done at ", time2str(), "\r\n";

   $c2::query_1 ->finish;
   $c2::query_2 ->finish;
   $c2::query_3 ->finish;
   $c2::query_4 ->finish;
   $c2::query_5 ->finish;
   $c2::query_6 ->finish;
   $c2::query_7 ->finish;
   $c2::query_8 ->finish;
   $c2::query_9 ->finish;
   $c2::query3s ->finish;
   $c2::query4s ->finish;
   $c2::insert1 ->finish;
   $c2::insert2 ->finish;
   $c2::update1 ->finish;
   $c2::update2 ->finish;

   $c2::connect->disconnect;
  }
}

 sub ProcRow {
   my (@col) = @_;

#   print $col[0]," Date: ",$col[2]," Time: ",$col[3]," ",$col[4];
#   print " Time:",$col[5]," Metres:",$col[6]," Avg SPM:",$col[7]," Avg HR:",$col[8]," Pace:",$col[13]," Cal/HR:",$col[14]," Watt:",$col[15],"\r\n";

   my $date_time = $col[2]." ".$col[3].":".$col[18];
   my ($date, $time) = split(' ',$date_time);
   my ($year, $month, $day) = split('-',$date);
   my ($week, $year) = Week_of_Year($year, $month, $day);
   my $workout = $col[4];
   my $workout_l = $workout."%";
   my $elapsed = $col[5];
   my $distance = $col[6];
   my $stroke_rate = $col[7];
   my $avg_HR = $col[8];
   my $pace = $col[13];
   my $cal_per_hour = $col[14];
   my $watts = $col[15];

#print "Row: SQL: $date_time,  $workout_l, $distance, ";

   my $result_1 = $c2::query_1->execute($date_time,$workout_l,$distance);

#print "c2::query_1 result:,$result_1,",$c2::query_1->errstr(),", ";

   if ($result_1 eq '0E0') {

#print "$date_time, $workout, $distance, c2::query_2, ";

   my $result_2 = $c2::query_2->execute($date_time,$workout,$distance,$elapsed,$stroke_rate,$avg_HR,$pace,$cal_per_hour,$watts);

#print "c2::query_2 result:, $result_2,",$c2::query_2->errstr(),"\r\n";

   } else {

#print "$date_time, $workout, $distance, c2::query_3, ";

   my $result_3 =  $c2::query_3->execute($elapsed,$stroke_rate,$avg_HR,$pace,$cal_per_hour,$watts,$date_time,$workout,$distance);

#print "c2::query_3 result: $result_3,",$c2::query_3->errstr(),"\r\n";

   }
   #select * from weekly
   my $result3w = $c2::query3s->execute($week,$year);
   if ($result3w eq '0E0') {
     #if not exists insert weekly
     $c2::insert1->execute($year,$week,$distance,$elapsed,$c2::zero,$c2::zero);
   } else {
     #update weekly
     $c2::update1->execute($distance,$elapsed,$c2::zero,$c2::zero,$week,$year);
   }

   #select * from monthly
   my $result4w = $c2::query4s->execute($month,$year);
   if ($result4w eq '0E0') {
     #if not exists insert monthly
     $c2::insert2->execute($year,$month,$distance,$elapsed,$c2::zero,$c2::zero);
   } else {
     #update monthly
     $c2::update2->execute($distance,$elapsed,$c2::zero,$c2::zero,$month,$year);
   }

 }
 
 sub ProcRest {
   my (@col) = @_;

#   print $col[0]," ",$col[2]," ",$col[3]," ",$col[4];
#   print " Time:",$col[16]," Metres:",$col[17],"\r\n";

   my $date_time = $col[2]." ".$col[3].":".$col[18];
   my ($date, $time) = split(' ',$date_time);
   my ($year, $month, $day) = split('-',$date);
   my ($week, $year) = Week_of_Year($year, $month, $day);
   my $workout = $col[4];
   my $workout_l = $workout."%";
   my $elapsed = $col[16];
   my $distance = $col[17];

#print "Rest SQL: $date_time,  $workout_l, $distance, ";

   my $result_4 = $c2::query_4->execute($date_time,$workout_l,$distance);

#print "c2::query_4 result:, $result_4,",$c2::query_4->errstr(),", ";

   if ($result_4 eq '0E0') {

#print "$date_time, $workout, $distance, c2::query_5, ";

   my $result_5 =  $c2::query_5->execute($date_time,$workout,$distance,$elapsed);

#print "c2::query_5 result:, $result_5, ",$c2::query_5->errstr(),"\r\n";

   } else {

#     print "$date_time, $workout, $distance, c2::query_6, ";

   my $result_6 =  $c2::query_6->execute($elapsed,$date_time,$workout,$distance);

#print "c2::query_6 result:,$result_6, ",$c2::query_6->errstr(),"\r\n";

   }
   #select * from weekly
   my $result3w = $c2::query3s->execute($month,$year);
   if ($result3w eq '0E0') {
     #if not exists insert weekly
     $c2::insert1->execute($year,$week,$c2::zero,$c2::zero,$distance,$elapsed);
   } else {
     #update weekly
     $c2::update1->execute($c2::zero,$c2::zero,$distance,$elapsed,$week,$year);
   }

   my $result4w = $c2::query4s->execute($month,$year);
   if ($result4w eq '0E0') {
     #if not exists insert monthly
     $c2::insert2->execute($year,$month,$c2::zero,$c2::zero,$distance,$elapsed);
   } else {
     #update monthly
     $c2::update2->execute($c2::zero,$c2::zero,$distance,$elapsed,$month,$year);
   }

 }

 sub ProcSplit {
   my (@col) = @_;

#   print $col[0]," ",$col[2]," ",$col[3]," ",$col[4];
#   print " Time:",$col[9]," Metres:",$col[10]," SPM:",$col[11]," HR:",$col[12]," Pace:",$col[13]," Cal/HR:",$col[14]," Watt:",$col[15],"\r\n";

   my $date_time = $col[2]." ".$col[3].":".$col[18];
   my $workout = $col[4];
   my $workout_l = $workout."%";
   my $elapsed = $col[9];
   my $distance = $col[10];
   my $stroke_rate = $col[11];
   my $avg_HR = $col[12];
   my $pace = $col[13];
   my $cal_per_hour = $col[14];
   my $watts = $col[15];

#print "Split SQL: $date_time,  $workout_l, $distance, ";

   my $result_7 = $c2::query_7->execute($date_time,$workout_l,$distance);

#print "c2::query_7 result:, $result_7, ",$c2::query_7->errstr(),", ";

   if ($result_7 eq '0E0') {

#print "$date_time, $workout, $distance, c2::query_8, ";

   my $result_8 =  $c2::query_8->execute($date_time,$workout,$distance,$elapsed,$stroke_rate,$avg_HR,$pace,$cal_per_hour,$watts);

#print "c2::query_8 result:, $result_8, ",$c2::query_8->errstr(),"\r\n";

   } else {

#print "$date_time, $workout, $distance, c2::query_9, ";

   my $result_9 =  $c2::query_9->execute($elapsed,$stroke_rate,$avg_HR,$pace,$cal_per_hour,$watts,$date_time,$workout,$distance);

#print "c2::query_9 result:, $result_9, ",$c2::query_9->errstr(),"\r\n";

   }
 }

 sub PrintCol {
   my (@col) = @_;

   print $col[0]," 1: ",$col[1]," 2: ",$col[2]," 3:  ",$col[3]," ";
   print "4: ",$col[4]," 5: Time: ",$col[5]," 6: Metres: ",$col[6]," ";
   print "7: SPM: ",$col[7]," 8: HR: ",$col[8]," 9: Time: ",$col[9]," ";
   print "10: Metres: ",$col[10]," 11: SPM: ",$col[11]," 12: HR: ",$col[12]," 13: Pace: ",$col[13]," ";
   print "14: Cal/hr: ",$col[14]," 15: Watt: ",$col[15]," 16: Time: ",$col[16]," 17: Metres: ",$col[17], " 18: Secs:", $col[18], "\r\n";

 }

 sub timeToSecs {
   my ($t) = @_;
   my ($h,$m,$s,$f) = (0,0,0,0);
   $t =~ /([\d]{0,2})(:{0,1})([\d]{0,2}):([\d]{0,2})(\.)([\d]{0,2})/;
   $s = $4;
   $f = $6;
   if ($2 eq ":") { 
     $h = $1;
     $m = $3;
   } else {
     $h = 0;
     $m = $1;
   }	
   my $secs = $h * 3600 + $m * 60 + $s + $f/10;
   return $h,$m,$s,$f,$secs;
 }

