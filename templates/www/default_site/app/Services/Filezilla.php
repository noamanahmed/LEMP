<?php

namespace App\Services;
use Illuminate\Http\Request;

class Filezilla extends BaseService
{
    public function createOneTimeDownloadLink(Request $request)
    {
        $this->generateConfigFile($request);
    }

    public function generateConfigFile(Request $request)
    {
        
    }


}