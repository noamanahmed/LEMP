<?php

namespace App\Traits;

use Carbon\Carbon;

trait Cache
{
    /**
     * Settings Cache Key
     *
     * @var string
     */
    public $cache_key = '_default_site';

    /**
     * Settings Cache Driver Name
     *
     * @var string
     */
    public $cache_driver_name = 'file';

    /**
     * Settings Cache Timeout
     *
     * @var integer
     */
    public $cache_timeout = 3600;

    /**
     * Check if cache exists
     *
     * @param string $key
     * @return boolean
     */
    public function has_cache($key)
    {
        return $this->getDriver()->has($this->getCacheKey($key));
    }
    /**
     * Set Cache Value
     *
     * @param string $key
     * @param mixed $value
     * @param string $time
     * @return boolean
     */
    public function set_cache($key, $value, $time)
    {
        return $this->getDriver()->set($this->getCacheKey($key), $value, $this->getCacheTimeinTTL($time));
    }
    /**
     * Put Cache Value
     *
     * @param string $key
     * @param mixed $value
     * @param string $time
     * @return boolean
     */
    public function put_cache($key, $value, $time)
    {
        return $this->getDriver()->put($this->getCacheKey($key), $value, $this->getCacheTimeinTTL($time));
    }

    /**
     * Get Cache Value
     *
     * @param string $key
     * @return mixed
     */
    public function get_cache($key)
    {
        return $this->getDriver()->get($this->getCacheKey($key));
    }
    /**
     * Set cache indefinitely
     *
     * @param string $key
     * @param string $value
     * @return void
     */
    public function forever_cache($key, $value)
    {
        return $this->getDriver()->forever($this->getCacheKey($key), $value);
    }
    /**
     * Remove Cache
     *
     * @param [type] $key
     * @return void
     */
    public function forget_cache($key)
    {
        return $this->getDriver()->forget($this->getCacheKey($key));
    }
    /**
     * Get cache with driver
     *
     * @return object
     */
    public function getDriver()
    {
        $this->cache_driver=cache()->driver($this->cache_driver_name);

        return $this->cache_driver;
    }

    /**
     * Set cache driver
     *
     * @return object
     */
    public function setDriver($driver)
    {
        $this->cache_driver=cache()->driver($driver);
        
        return $this->cache_driver;
    }

    /**
     * Get cache key
     *
     * @return void
     */
    public function getCacheKey($suffix)
    {
        return $this->cache_key . $suffix;
    }

    /**
     * Get cache expiration time from Carbon
     *
     * @param mixed $time
     * @return void
     */
    public function getCacheTimeinTTL($time)
    {
        if ($time instanceof Carbon) {
            return now()->diffInSeconds($time);
        }
        return $time;
    }
}