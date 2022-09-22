package tm.queries;
import haxe.Json;
import mongo.Pipeline;
import mongo.comparaison.GreaterOrEqualThan;
import mongo.conditions.And;
import mongo.conditions.Or;
import mongo.stages.Match;
import mongo.stages.Project;
import mongo.xapiSingleStmtShortcut.ActorName;
import mongo.xapiSingleStmtShortcut.StmtTimestamp;
import mongo.xapiSingleStmtShortcut.VerbId;
import roles.Actor;
import thx.DateTime;
import thx.DateTimeUtc;
import xapi.Agent;
import xapi.Verb;
import xapi.types.ISOdate;

/**
 * ...
 * @author bb
 */

class TMBasicsThisMonth extends TMQueryBase
{

	public var listOfAgents(default, set):Array<roles.Actor>;

	
	public function new(listOfAgents:Array<roles.Actor>, previousMonth:Bool)
	{
		super(previousMonth);
		this.listOfAgents = listOfAgents;

	}
	

	

	function set_listOfAgents(value:Array<roles.Actor>):Array<roles.Actor>
	{
		return listOfAgents = value;
	}
	override public function get_pipeline():Pipeline
	{
		//_now = DateTime.nowUtc();
		
		//var firstOfTheMonth = new ISOdate('${_now.year}-${ StringTools.lpad(Std.string(_now.month),"0" ,2 )}-01T00:00:00.00Z');
	    //trace("1");
		var m:Match = new Match(new Or([for (i in listOfAgents) new ActorName(i.name)]));
		var mv:Match = new Match(new VerbId(Verb.recieved.id));
		//var mDate:Match = new Match(new StmtTimestamp({"$gte": firstOfTheMonth}));
		//var mDate:Match = new Match(new StmtTimestamp(new GreaterOrEqualThan(firstOfTheMonth)));
		//#if debug
		//trace(Json.stringify(this.getDatesBoundaries()));
		//#end
		//var pipeline = new Pipeline([m, mv, mDate, project]);
		var pipeline = new Pipeline([m, mv, this.getDatesBoundaries(), project]);
		return pipeline;
	}
	//public function test()
	//{
		//trace("yo");
	//}
}