<?php
    /**
     * Copyright 2017 by Florian Steltenkamp
     *
     * Gitdl - Download repository on push updates
     */
    //====================================================================================
    //Config
    //====================================================================================
    $gitlab_token = "XXXXXXXXXX";   //add your private token here. Needs full api access
    $generate_log = true;           //true: generates a logfile false: does not
    $removeolddir = true;           //true: removes the targetdirectory before moving the new files over
    $logfile_name = "gitdl.log";    //Name of the logfile
    //====================================================================================
    //Code  (only edit if you understand what you are doing)
    //====================================================================================
    function addlog($type,$message) {
        global $generate_log,$logfile_name;
        //check if log should be generated
        if(!$generate_log)
            return false;
            
        $time = date("Y-m-d H:i:s");
        $line = "[$time|$type] : $message\n";
        
        $file = fopen($logfile_name,'a');
        fwrite($file,$line);
        fclose($file);
    }
    
    function dlfile($url,$filename) {
        $file = fopen($filename,"w");
        $dl = curl_init();
        curl_setopt($dl,CURLOPT_URL,$url);
        curl_setopt($dl,CURLOPT_FOLLOWLOCATION, true);
        curl_setopt($dl,CURLOPT_FILE,$file);
        $content = curl_exec($dl);
        
        $transfertime = curl_getinfo($dl,CURLINFO_TOTAL_TIME);
        $dlsize = curl_getinfo($dl,CURLINFO_SIZE_DOWNLOAD);
        $dlspeed = curl_getinfo($dl,CURLINFO_SPEED_DOWNLOAD);
        curl_close($dl);
        
        if(!$content){
            addlog("curl","Failed File download! File: $filename from ($url). Error:".curl_error($dl));
        }else{
            addlog("curl","Downloaded file $filename from ($url) in $transfertime Seconds. Size:$dlsize bytes Speed:$dlspeed bps");
        }
    }
    
    function rrmdir($dir) {
        if (is_dir($dir)) {
            $objects = scandir($dir);
            foreach ($objects as $object) {
                if ($object != "." && $object != "..") {
                    if (filetype($dir."/".$object) == "dir") rrmdir($dir."/".$object); else unlink($dir."/".$object);
                }
            }
            reset($objects);
            rmdir($dir);
        }
    }
    
    function extract_zip_subdir($zipfile, $subpath, $destination, $temp_cache, $traverse_first_subdir=true) {
        global $removeolddir;
        
        $zip = new ZipArchive;
        if(substr($temp_cache, -1) !== DIRECTORY_SEPARATOR) {
            $temp_cache .= DIRECTORY_SEPARATOR;
        }
        $res = $zip->open($zipfile);
        if ($res === TRUE) {
            if ($traverse_first_subdir==true){
                $zip_dir = $temp_cache . $zip->getNameIndex(0);
            }
            else {
                $temp_cache = $temp_cache . basename($zipfile, ".zip");
                $zip_dir = $temp_cache;
            }
            $zip->extractTo($temp_cache);
            $zip->close();
            
            if($removeolddir) {
                rrmdir($destination);
            }
            
            if(empty($subpath)) {
                rename($zip_dir.DIRECTORY_SEPARATOR,$destination);
            } else {
                rename($zip_dir . DIRECTORY_SEPARATOR . $subpath, $destination);
            }
            
            //clean tempdir
            rrmdir($zip_dir);
            
        } else {
            addlog("ziperror","Could not extract file! Error: ");
        }
    }
    
    //get the request
    $requestbody = "";
    $body = false;
    
    if(!empty(file_get_contents("php://input"))) {
        $requestbody = file_get_contents("php://input");
        $body = true;
    }
    
    if(!$body and !empty(stream_get_contents(STDIN))) {
        $requestbody = stream_get_contents(STDIN);
        $body = true;
    }
    
    if($body)
    {
        //Request vaild:
        addlog("request",$requestbody);
        //decode request
        $requestobject = json_decode($requestbody);
        //get variables
        $reqtype = $requestobject->object_kind;
        $refs = $requestobject->ref;
        $branch = array_pop(explode("/",$refs));
        $user = $requestobject->user_name;
        $usermail = $requestobject->user_email;
        $archivepath = $requestobject->project->web_url."/repository/".$branch."/archive.zip?private_token=$gitlab_token";
        $reponame = $requestobject->repository->name;
        $visibility = $requestobject->repository->visibility_level;
        //log
        addlog("info","$reqtype by $user($usermail) on $reponame");
        //get file
        $filename = $reponame.".zip";
        dlfile($archivepath,$filename);
        //unzip
        switch($branch) {
            case 'master':
                if(is_dir($reponame)) {
                    extract_zip_subdir($filename, "", $reponame, "temp", true);
                }else {
                    mkdir($reponame);
                    extract_zip_subdir($filename, "", $reponame, "temp", true);
                }
                break;
            case 'dev':
                if(is_dir("dev/$reponame")) {
                    extract_zip_subdir($filename, "", "dev/".$reponame, "temp", true);
                }else {
                    if(!is_dir("dev"))
                        mkdir("dev");
                        
                    mkdir("dev/$reponame");
                    extract_zip_subdir($filename, "", "dev/".$reponame, "temp", true);
                }
                break;
            default:
                addlog('info',"BRANCH WAS NOT MASTER NOR DEV. DID NOT UNPACK!");
                break;
        }
        
        echo "success";
    }else {
        addlog("info","No Request Content found");
        echo "no content found";
    }
?>
