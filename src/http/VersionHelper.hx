package http;

import js.Browser;
import js.html.HTMLCollection;

/**
 * ...
 * @author bb
 */
class VersionHelper
{
	public function new() 
	{
	}
	public static function getVersion(script:String):String
	{
		var scripts:HTMLCollection = Browser.document.getElementsByTagName("script");
		var version = "";
		for (i in 0...scripts.length)
		{
			if (scripts[i].attributes.getNamedItem('src') != null && scripts[i].attributes.getNamedItem('src').nodeValue.indexOf(script+"_") == 0)
			{
				version = scripts[i].attributes.getNamedItem('src').nodeValue;
				break;
			}
			
		}
		return StringTools.replace(version, ".js", "");
	}
}