package ;
//import haxe.ui.Toolkit;
import haxe.ui.components.DropDown.CalendarDropDownHandler;
import haxe.ui.locale.Formats;
import thx.DateTime;
import thx.TimePeriod;
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
	public static function main()
	{
		//CalendarDropDownHandler.DATE_FORMAT = "%d.%m.%Y";
		Formats.dateFormatShort = "%d.%m.%Y"; 
		//
		//trace("wtf");
		var main = new tm.TMApp();
		//var n = DateTime.now();
		//var snapPrev = n.snapPrev(TimePeriod.Month);
		//var snapNext = n.snapNext(TimePeriod.Month);
		//trace(n);
		//trace(snapPrev);
		//trace(snapNext);
		//var main = new XapiSendSerialized();
	}	
}