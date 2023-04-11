package ;
//import haxe.ui.Toolkit;
//import haxe.ui.components.DropDown.CalendarDropDownHandler;
import haxe.ui.locale.Formats;
import js.Browser;
import js.html.URLSearchParams;
//import thx.DateTime;
//import thx.TimePeriod;
//import tests.XapiSendSerialized;
import tm.TMApp;

/**
 * --resource assets/ui/inbound.xml@inbound
--resource assets/ui/outbound.xml@outbound
--resource assets/ui/mail.xml@mail
--resource assets/ui/case.xml@case
 */


class Main
{
	
	public static var _mainDebug:Bool;
	public static var PARAMS:URLSearchParams;
	public static function main()
	{
		PARAMS = new URLSearchParams(Browser.location.search);
		Formats.dateFormatShort = "%d.%m.%Y"; 
		var main = new tm.TMApp();
	}	
}