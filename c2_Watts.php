<head>
<script language="javascript" src="../calendar/calendar.js"></script>
<link rel="stylesheet" type="text/css" href="../calendar/calendar.css" />
</head>
<?php
require_once ('../calendar/classes/tc_calendar.php');
require_once('/usr/local/etc/c2log/config.inc.php');
require_once('c2functions.php');

if (isset($_POST['submit'])) {
	extract($_POST);
echo "<pre>";
$start = $start_date." 00:00:00";
$end = $end_date." 23:59:59";
$selrow = "SELECT date_time , workout_name , distance , elapsed , stroke_rate , avg_HR , pace , cal_per_hour , watts FROM C2_log_row WHERE date_time BETWEEN '".$start."' AND '".$end."' ORDER BY date_time ASC;";
$line=1;
$dailytot=0;
$rrows = mysql_query($selrow) or die("E001".mysql_error());
while ($row = mysql_fetch_array($rrows)) {
	extract($row);
	$tot_dist = $distance;
	$dailytot += $distance;
	$tot_time = $elapsed;
	$disp_elap = secsToTime($elapsed+0);
	$disp_pace = secsToTime($pace+0);
	$disp_date = substr($date_time,0,-3);
	$date_time_l = $disp_date."%";
	if ($avg_HR==0) {$avg_HR="";}
echo "\r\n$disp_date\t$workout_name\r\n$line] $distance";
echo "m\t$disp_elap\t$stroke_rate";
echo "spm\t$watts";
echo "W\t$disp_pace\t$avg_HR\r\n";
	$splitline=1;
	$selsplits = "SELECT date_time as sp_date_time , workout_name as sp_wn , distance as sp_dist , elapsed as sp_elap , stroke_rate as sp_sr , avg_HR as sp_hr , pace as sp_pace , cal_per_hour as sp_cal , watts as sp_watts FROM C2_log_split WHERE date_time LIKE '".$date_time_l."';";
	$rsplit = mysql_query($selsplits) or die("E002".mysql_error());
	while ($split = mysql_fetch_array($rsplit)) {
		extract($split);
		$sp_disp_elap = secsToTime($sp_elap+0);
		$sp_disp_pace = secsToTime($sp_pace+0);
		if ($sp_hr==0) {$sp_hr="";}
echo "$line.$splitline] $sp_dist";
echo "m\t$sp_disp_elap\t$sp_sr";
echo "spm\t$sp_watts";
echo "W\t$sp_disp_pace\t$sp_hr\r\n";
	$splitline++;
	}
#	$restline=1;
	$rest_dist=0;
	$rest_time=0;
	$selrest = "SELECT date_time as rs_date_time , workout_name as rs_wn , distance as rs_dist , elapsed as rs_elap FROM C2_log_rest WHERE date_time LIKE '".$date_time_l."';";
	$rrest = mysql_query($selrest) or die("E003".mysql_error());
	while ($rest = mysql_fetch_array($rrest)) {
		extract($rest);
		$tot_dist += $rs_dist;
		$tot_time += $rs_elap;
		$rest_dist += $rs_dist;
		$rest_time += $rs_elap;
#echo"Rest: $restline, $rs_date_time , $rs_wn , $rs_dist , $rs_elap\r\n";
#		$restline++;
	}
	$line++;
	if ($rest_dist > 0) {
echo "Resting metres: $rest_dist";
	$dailytot += $rest_dist;
	if ($rest_time>0) {$r="m\tRest time: ".secsToTime($rest_time);} else{$r="m";}
echo "$r\r\nTotal: $tot_dist";
echo "m\tElapsed time: ".secsToTime($tot_time)."\r\n";
	}
}
echo "\r\nSession total: ",$dailytot."m";
echo "</pre>";
} else {			
	$start_cal = new tc_calendar("start_date", true, false);
	$start_cal->setIcon("../calendar/images/iconCalendar.gif");
	$start_cal->setDate(date('d'), date('m'), date('Y'));
	$start_cal->setPath("../calendar/");
	  
	$end_cal = new tc_calendar("end_date", true, false);
	$end_cal->setIcon("../calendar/images/iconCalendar.gif");
	$end_cal->setDate(date('d'), date('m'), date('Y'));
	$end_cal->setPath("../calendar/");
	?>
	<form action=<?php echo $_SERVER['PHP_SELF'];?> method=post name=form1>
	<?php
	$start_cal->writeScript();	  
	$end_cal->writeScript(); ?>
	<input type=submit name=submit value=submit> 
	</form>
<?php } ?>
