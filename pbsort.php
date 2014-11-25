<?php
require_once('/usr/local/etc/c2log/config.inc.php');
require_once('c2functions.php');

echo "<pre>";
$start = "0000-00-00 00:00:00";
$end_date = date("Y-m-d");
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
	$sql .= $union."SELECT elapsed, date_time, workout_name, distance FROM C2_log_row WHERE elapsed =(SELECT min(elapsed)FROM C2_log_row WHERE date_time BETWEEN '".$start."' AND '".$end."' AND workout_name = '".$wname[$i]."')";
	$union = " UNION ";
}
for ($i=1;$i<4;$i++) {
	$sql .= $union."SELECT elapsed, date_time, workout_name, distance FROM C2_log_row WHERE distance =(SELECT max(distance)FROM C2_log_row WHERE date_time BETWEEN '".$start."' AND '".$end."' AND workout_name = '".$namew[$i]."')";
}
$rs = mysql_query($sql) or die(mysql_error());
function cmp($a, $b)
{
    $t1 = strtotime($a['date_time']);
    $t2 = strtotime($b['date_time']);
    return $t1 - $t2;
}    
$i=0;
$rs = mysql_query($sql) or die(mysql_error());
while($row = mysql_fetch_array($rs)) {
	$rowx[$i++] = $row;
}
usort($rowx,'cmp');
foreach ($rowx as $row) {
	extract($row);
	$elapsed=$elapsed+0;
	$disp_date = substr($date_time,0,-3);
	echo $result++.":\t".secsToHhmmsst($elapsed)."\tSB: ".$distance."m\ton ".$disp_date."\r\n";
}
echo "</pre>";

?>
