CREATE TABLE `C2_log_monthly` (
  `year_rowed` year(4) NOT NULL,
  `month_rowed` smallint(6) NOT NULL,
  `distance` int(11) NOT NULL,
  `elapsed` decimal(9,2) NOT NULL,
  `rest_dist` int(11) NOT NULL,
  `rest_time` decimal(9,2) NOT NULL,
  UNIQUE KEY `yr_mth` (`year_rowed`,`month_rowed`)
) ENGINE=Aria DEFAULT CHARSET=utf8 PAGE_CHECKSUM=0 TRANSACTIONAL=0;

CREATE TABLE `C2_log_weekly` (
  `year_rowed` year(4) NOT NULL,
  `week_rowed` smallint(6) NOT NULL,
  `distance` int(11) NOT NULL,
  `elapsed` decimal(9,2) NOT NULL,
  `rest_dist` int(11) NOT NULL,
  `rest_time` decimal(9,2) NOT NULL,
  UNIQUE KEY `yr_wk` (`year_rowed`,`week_rowed`)
) ENGINE=Aria DEFAULT CHARSET=utf8 PAGE_CHECKSUM=0 TRANSACTIONAL=0;

CREATE TABLE `C2_log_rest` (
  `date_time` datetime NOT NULL,
  `workout_name` varchar(20) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL,
  `distance` int(11) NOT NULL,
  `elapsed` decimal(7,2) NOT NULL,
  UNIQUE KEY `date_time` (`date_time`,`workout_name`,`distance`)
) ENGINE=Aria DEFAULT CHARSET=utf8 PAGE_CHECKSUM=0 TRANSACTIONAL=0;

CREATE TABLE `C2_log_row` (
  `date_time` datetime NOT NULL,
  `workout_name` varchar(20) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL,
  `distance` int(11) NOT NULL,
  `elapsed` decimal(7,2) NOT NULL,
  `stroke_rate` int(11) NOT NULL,
  `avg_HR` int(11) NOT NULL,
  `pace` decimal(5,2) NOT NULL,
  `cal_per_hour` int(11) NOT NULL,
  `watts` int(11) NOT NULL,
  UNIQUE KEY `date_time_dist` (`date_time`,`workout_name`,`distance`)
) ENGINE=Aria DEFAULT CHARSET=utf8 PAGE_CHECKSUM=0 TRANSACTIONAL=0;

CREATE TABLE `C2_log_split` (
  `date_time` datetime NOT NULL,
  `workout_name` varchar(20) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL,
  `distance` int(11) NOT NULL,
  `elapsed` decimal(7,2) NOT NULL,
  `stroke_rate` int(11) NOT NULL,
  `avg_HR` int(11) NOT NULL,
  `pace` decimal(5,2) NOT NULL,
  `cal_per_hour` int(11) NOT NULL,
  `watts` int(11) NOT NULL,
  UNIQUE KEY `date_time_dist` (`date_time`,`workout_name`,`distance`)
) ENGINE=Aria DEFAULT CHARSET=utf8 PAGE_CHECKSUM=0 TRANSACTIONAL=0;

