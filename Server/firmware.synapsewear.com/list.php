<?php
  
$firmware = array();
$firmware = firmware_add($firmware, 1.3, 1.3, "synapseWear20180714.hex", "20180714");
$firmware = firmware_add($firmware, 1.3, 1.3, "synapseWear20180711.hex", "20180711");

echo json_encode(array(
  "firmware" => $firmware,
));

exit(0);




function firmware_add($firmware, $ios_version, $device_version, $hex_file, $date)
{
  array_push($firmware, array(
    "ios_version" => (float)$ios_version,
    "device_version" => (float)$device_version,
    "hex_file" => (string)$hex_file,
    "date" => (string)$date
  ));
  
  return $firmware;
}
