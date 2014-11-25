<?php session_start(); ?>
<head>
<script language="javascript" src="../calendar/calendar.js"></script>
<link rel="stylesheet" type="text/css" href="../calendar/calendar.css" />
</head>
<?php
require_once ('../calendar/classes/tc_calendar.php');
require_once('/usr/local/etc/c2log/config.inc.php');
require_once('c2functions.php');
require_once('whichYear.php');
require_once('timefunc.php');

if (isset($_POST['submit'])) {
	$_SESSION['hit']++;
	sleep(2^(intval($_SESSION['hit'])-1));
	extract($_POST);
echo "<pre>";
$start = $start_date." 00:00:00";
$end = $end_date." 23:59:59";
$wname[1] = "500m";
$wname[2] = "1000m";
$wname[3] = "2000m";
$wname[4] = "5000m";
$wname[5] = "6000m";
$wname[6] = "10000m";
$wname[7] = "21097m";
$wname[8] = "42195m";
$namew[1] = "0:04:00";
$namew[2] = "0:30:00";
$namew[3] = "1:00:00";
$result=1;
$sql = "";
$union = "";
for ($i=1;$i<9;$i++) {
	$sql .= $union."SELECT elapsed, date_time, workout_name, distance FROM C2_log_row WHERE date_time >= '".$start."' AND workout_name = '".$wname[$i]."' AND elapsed =(SELECT min(elapsed) FROM C2_log_row WHERE workout_name = '".$wname[$i]."' AND date_time BETWEEN '".$start."' AND '".$end."') ";
$union = " UNION ";
	}
for ($i=1;$i<4;$i++) {
	$sql .= $union."SELECT elapsed, date_time, workout_name, distance FROM C2_log_row WHERE date_time >= '".$start."' AND workout_name = '".$namew[$i]."' AND distance =(SELECT max(distance) FROM C2_log_row WHERE workout_name = '".$namew[$i]."' AND date_time BETWEEN '".$start."' AND '".$end."') ";
}
$rs = mysql_query($sql) or die(mysql_error());
while ($row = mysql_fetch_array($rs)) {
	extract($row);
	$elapsed=$elapsed+0;
	if ($elapsed > 3599) $SBtext = "\tSB: ";
	else $SBtext = "\t\tSB: ";
	$disp_date = substr($date_time,0,-3);
	//echo $result++.":\t".secsToHhmmsst($elapsed)."\tSB: ".$distance."m\ton ".$disp_date."\r\n";
	echo $result++.":\t".secsToTime($elapsed).$SBtext.$distance."m\ton ".$disp_date."\r\n";
}

echo "</pre>";
} else {		
	$calyr = whichYear(date('Y-m-d'));
	$_SESSION['hit']++;
	sleep(2^(intval($_SESSION['hit'])-1));
	$start_cal = new tc_calendar("start_date", true, false);
	$start_cal->setIcon("../calendar/images/iconCalendar.gif");
	$start_cal->setDate(1,5, $calyr['thisYear'] );
	$start_cal->setPath("../calendar/");
	  
	$end_cal = new tc_calendar("end_date", true, false);
	$end_cal->setIcon("../calendar/images/iconCalendar.gif");
	$end_cal->setDate(30, 4, $calyr['nextYear']);
	$end_cal->setPath("../calendar/");
	?>
	<form action=<?php echo $_SERVER['PHP_SELF'];?> method=post name=form1>
	<?php
	$start_cal->writeScript();	  
	$end_cal->writeScript(); ?>
	<input type=submit name=submit value=submit> 
	</form>
<?php } ?>
