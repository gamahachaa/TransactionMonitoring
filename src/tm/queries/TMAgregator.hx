package tm.queries;

//import haxe.Http;
import haxe.Json;
import lrs.Access;
import lrs.vendors.Connector;
import lrs.vendors.LLAccess;
import lrs.vendors.LearninLocker;
import mongo.queries.Agregator;
//import tm.queries.QueryBase;
import tm.queries.TMBasicsThisMonth;
import tm.queries.TMMentored;
import roles.Actor;
//import xapi.Agent;


/**
 * ...
 * @author bb
 */
class TMAgregator extends Agregator
{
	var tmsDirectReports:TMBasicsThisMonth;
	var tmsMentored:TMMentored;
	
    //public var signal(get, null):signal.Signal1<Array<Dynamic>>;
	public function new()
	{
		#if debug
		        var ll = new LearninLocker("troubleshooting", "https://qast.test.salt.ch", "", "", "Basic NDdlYTQ5M2MyYjk5YTU0NjhmODEzYzliYWY1ODI1NWNmMmNiMThkZDo2MjMyNDFiZDg5MjNhYzAxYzFhMzI4NDcyYzU1YTA0YTBiZmU2ODI1", aggregation_sync);
		#else
        var ll = new LearninLocker("troubleshooting", "https://qast.salt.ch", "", "", "Basic YTM2Y2M3M2RhMmE4YTc5ZjIwYjM2ZTc1MDJjMTBlZDdlZWJlZTk4YjpjMmQzYjc5YzUyZTk0YTk5YzRlMjM5YTNkZTUyOWZmZDZhNjBkMmIw", aggregation_sync);
		#end
		super(new LLAccess(ll));

	}
	public function getBasicTMThisMonth(nt:String, ?previousMonth:Bool=false)
	{
		#if debug
		trace("http.Agregator::getBasicTMThisMonth::nt", nt );
		#end
		//tmsMentored;
		try
		{
			if (tmsMentored == null)
			{
				
				tmsMentored = new TMMentored(nt,previousMonth);
			}
			else
			{
				
				tmsMentored.nt = nt;
			}
			tmsMentored.updateBoundaries(previousMonth);
			fetch(tmsMentored);
		}
		catch(e)
		{
			trace(e);
		}

	}
	public function getDirectReportsTMThisMonth(list:Array<roles.Actor>,?previousMonth:Bool=false)
	{
		#if debug
		//trace("http.Agregator::getBasicTMThisMonth::list", list );
		#end
		tmsDirectReports;
		try
		{
			if (tmsDirectReports == null)
			{
				tmsDirectReports = new tm.queries.TMBasicsThisMonth(list, previousMonth);
				//trace("all good");
				//onData = tmBasics.onData;
			}
			else
			{
				tmsDirectReports.listOfAgents = list;
			}
			#if debug
			//trace("http.Agregator::getDirectReportsTMThisMonth::Json.stringify(tmsDirectReports.pipeline)", Json.stringify(tmsDirectReports.pipeline) );
			#end
			tmsDirectReports.updateBoundaries(previousMonth);
			 fetch(tmsDirectReports);
		}
		catch(e)
		{
			trace(e);
		}

	}
	


}