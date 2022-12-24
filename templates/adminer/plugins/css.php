<?php

class AdminerCSS {
	private $css;
	
	function __construct(array $css = [])
	{
		$this->css = $css;
	}

	function css() {
		$return = array();

		foreach($this->css as $css)
		{
			$return[] = $css;
		}
		
		return $return;
	}
}