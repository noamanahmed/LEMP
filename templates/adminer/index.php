<?php
function adminer_object() {
    // required to run any plugin
    include_once "./plugins/plugin.php";
    
    // autoloader
    foreach (glob("plugins/*.php") as $filename) {
        include_once "./$filename";
    }
    
    // enable extra drivers just by including them
    //~ include "./plugins/drivers/simpledb.php";
    
    $plugins = array(
        new AdminerLoginServers([
            "MySQL" => array( "server" =>"127.0.0.1", "driver"=> "server" ),
            "PostgreSQL" => array( "server" =>"127.0.0.1", "driver"=> "pgsql" )
        ]),
    );
   
    
    return new AdminerPlugin($plugins);
}

// include original Adminer or Adminer Editor
include "./adminer.php";
?>
