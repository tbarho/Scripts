<?php


$descriptorspec = array(
	0 => array("pipe","r"),
	1 => array("pipe","w"),
	2 => array("pipe","./error.log","a")
) ;

// define current working directory where files would be stored
$cwd = './' ;
// open process /bin/sh
$process = proc_open('/bin/sh', $descriptorspec, $pipes, $cwd) ;

if (is_resource($process)) {

  // anatomy of $pipes: 0 => stdin, 1 => stdout, 2 => error log
  fwrite($pipes[0], 'cal -3') ;
  fclose($pipes[0]) ;

  // print pipe output
  echo stream_get_contents($pipes[1]) ;

  // close pipe
  fclose($pipes[1]) ;
 
  // all pipes must be closed before calling proc_close. 
  // proc_close() to avoid deadlock
  proc_close($process) ;
}