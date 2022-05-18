<?php

namespace App\Console\Commands;

use App\Traits\Cache;
use Illuminate\Console\Command;
use Illuminate\Support\Str;

class FilezillaDownloadLinkGenerator extends Command
{
    use Cache;

    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'filezilla:generate-config {username} {password} {domain} {port=6000}';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'A command to generate filezill configurations';

    /**
     * Create a new command instance.
     *
     * @return void
     */
    public function __construct()
    {
        parent::__construct();
    }

    /**
     * Execute the console command.
     *
     * @return int
     */
    public function handle()
    {
        $cache_key = Str::random(32);

        $data = [];
        $data['username'] = $this->argument('username');
        $data['password'] = $this->argument('password');
        $data['domain'] = $this->argument('domain');
        $data['port'] = $this->argument('port');
        $data = json_encode($data);

        $this->set_cache($cache_key,$data,12000);

        $this->info(route('filezilla.download',$cache_key));        

    }
}
