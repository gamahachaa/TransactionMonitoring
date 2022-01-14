package http;

import haxe.Http;
import haxe.Json;
import queries.QueryBase;
import queries.TMBasicsThisMonth;
import queries.TMMentored;
import xapi.Agent;

/**
 * ...
 * @author bb
 */
class Agregator extends Http
{
	var tmsDirectReports:TMBasicsThisMonth;
	var tmsMentored:TMMentored;
	
    public var signal(get, null):signal.Signal1<Array<Dynamic>>;
	public function new()
	{

		super("https://qast.test.salt.ch/api/statements/aggregate");
		signal = new signal.Signal1<Array<Dynamic>>();
		addHeader("Authorization", "Basic YTM2Y2M3M2RhMmE4YTc5ZjIwYjM2ZTc1MDJjMTBlZDdlZWJlZTk4YjpjMmQzYjc5YzUyZTk0YTk5YzRlMjM5YTNkZTUyOWZmZDZhNjBkMmIw");
		addHeader("X-Experience-API-Version", "1.0.3");
		addParameter("cache", "false");
		onData = ondata;
		onError = onMyError;
		onStatus = onBytesMyStatus;
		async = true;
		//h.request(false);
	}

	function onBytesMyStatus(int:Int)
	{
		trace(int);
	}

	function onMyError(string:String)
	{
		trace(string);
	}

	function onMyData(s:String)
	{
		var j = cast(Json.parse(s), Array<Dynamic>);
		trace(j);
	}
	/*function onData(s:String)
	{
		var j = cast(Json.parse(s),Array<Dynamic>);
		trace(j);
		for (i in 0...j.length)
		{
			var o = j[i];
			trace( o.success);
			trace( o );
		}
	} */
	public function ondata(s:String)
	{
		var j:Array<Dynamic> = cast(Json.parse(s), Array<Dynamic>);
		signal.dispatch(j);
		//trace(j);
		for (i in 0...j.length)
		{
			var o = j[i];
			//trace( o.success);
			//trace( o );
		}
	}
	public function getBasicTMThisMonth(nt:String)
	{
		#if debug
		trace("http.Agregator::getBasicTMThisMonth::nt", nt );
		#end
		tmsMentored;
		try
		{
			if (tmsMentored == null)
			{
				
				tmsMentored = new TMMentored(nt);
			}
			else
			{
				
				tmsMentored.nt = nt;
			}
			setParameter("pipeline", Json.stringify(tmsMentored.pipeline));
			#if debug
			trace("http.Agregator::getBasicTMThisMonth::Json.stringify(tmsMentored.pipeline)", Json.stringify(tmsMentored.pipeline) );
			#end
			//addParameter("pipeline", "{}");
			
			request(false);
		}
		catch(e)
		{
			trace(e);
		}

	}
	public function getDirectReportsTMThisMonth(list:Array<Actor>)
	{
		#if debug
		trace("http.Agregator::getBasicTMThisMonth::list", list );
		#end
		tmsDirectReports;
		try
		{
			if (tmsDirectReports == null)
			{
				tmsDirectReports = new queries.TMBasicsThisMonth(list);
				trace("all good");
				//onData = tmBasics.onData;
			}
			else
			{
				tmsDirectReports.listOfAgents = list;
			}
			#if debug
			trace("http.Agregator::getDirectReportsTMThisMonth::Json.stringify(tmsDirectReports.pipeline)", Json.stringify(tmsDirectReports.pipeline) );
			#end
			
			setParameter("pipeline", Json.stringify(tmsDirectReports.pipeline));
			//addParameter("pipeline", "{}");
			
			request(false);
		}
		catch(e)
		{
			trace(e);
		}

	}
	
	function get_signal():signal.Signal1<Array<Dynamic>> 
	{
		return signal;
	}
	
	/*public function getSignal()
	{
		
		return tmBasics.signal;
	} */

}