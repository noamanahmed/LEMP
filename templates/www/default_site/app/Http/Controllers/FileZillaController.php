<?php

namespace App\Http\Controllers;

use App\Http\Requests\FileZilla as RequestsFileZilla;
use App\Services\Filezilla;
use App\Traits\Cache;
use Illuminate\Http\Request;

class FileZillaController extends Controller
{
    use Cache;
    // public function createOneTimeDownloadLink(Filezilla $filezilla,Request $request)
    // {
    //     return $filezilla->createOneTimeDownloadLink($request);
    // }

    public function download(Filezilla $filezilla,RequestsFileZilla $request,$hash)
    {
        
        if(!$this->has_cache($hash)) abort(404);

        $data = $this->get_cache($hash);
        $data = json_decode($data,true);        
        $username = $data['username'];
        $domain = $data['domain'];
        $password = base64_encode($data['password']);
        $port = $data['port'];

        $file = view('filezilla',compact('username','domain','password','port'))->render();

        $headers = [
            'Content-type'        => 'application/xml',
            'Content-Disposition' => 'attachment; filename="'.$username.'.xml"',
        ];

        return response()->make($file,200,$headers);

    }

}
