package data;
import tstool.utils.DateToolsBB;

/**
 * ...
 * @author bb
 */
class Transaction 
{
	public static inline var TRANSACTION_SUMMARY:String = "transactionSummary";
	public static inline var TRANSACTION_INDENTIFICATOR:String = "transactionIdentificator";
	public static inline var TRANSACTION_DATE:String = "transactionDate";
	@:isVar public var monitoree(get, set):Monitoree;
	
	@:isVar public var type(get, set):String;
	public var data:Map<String, String>;
	@:isVar public var id(get, set):String;
	@:isVar public var date(get, set):Date;
	@:isVar public var summary(get, set):String;
	//public function new(?monitoree:Monitoree, ?type:String, ?id:String, ?date:Date ) 
	public function new() 
	{
		//data = [];
		reset();
		//this.monitoree = monitoree;
		//this.date = date;
		//this.id = id;
		//this.summary = "";
	}
	public function reset()
	{
		data = [];
		date = new Date(2000, 0, 1, 0, 0, 0);
		id = "";
		type = "";
		summary = "";
		monitoree = null;
		//#if debug
		//trace("Transaction::reset::reset" );
		//trace("Transaction::reset::reset DATE",date  );
		//#end
	}
	public function prepareData()
	{
		data = [TRANSACTION_DATE=>getDateISO(), TRANSACTION_INDENTIFICATOR=> id, TRANSACTION_SUMMARY => summary];
	}

	public function getDateISO():String
	{
		return DateToolsBB.TO_ISO_DATE(date);
	}
	function get_type():String 
	{
		return type;
	}
	
	function set_type(value:String):String 
	{
		return type = value;
	}
	
	function get_monitoree():Monitoree 
	{
		return monitoree;
	}
	
	function set_monitoree(value:Monitoree):Monitoree 
	{
		return monitoree = value;
	}
	
	function get_id():String 
	{
		return id;
	}
	
	function set_id(value:String):String 
	{
		return id = value;
	}
	
	function get_date():Date 
	{
		return date;
	}
	
	function set_date(value:Date):Date 
	{
		return date = value;
	}
	
	function set_summary(value:String):String 
	{
		return summary = value;
	}
	 function get_summary():String 
	{
		return summary;
	}
}