package queries;
import mongo.Pipeline;
import mongo.comparaison.GreaterOrEqualThan;
import mongo.conditions.And;
import mongo.stages.Match;
import mongo.xapiSingleStmtShortcut.ActorName;
import mongo.xapiSingleStmtShortcut.InstructorName;
import mongo.xapiSingleStmtShortcut.StmtTimestamp;
import mongo.xapiSingleStmtShortcut.VerbId;
import thx.DateTime;
import thx.DateTimeUtc;
import xapi.Verb;
import xapi.types.ISOdate;

/**
 * ...
 * @author bb
 */
class TMMentored extends QueryBase 
{
	public var nt(default, set):String;

	public function new(nt:String) 
	{
		super();
		this.nt = nt;
		
	}
	override public function get_pipeline():Pipeline
	{
		//_now = DateTime.nowUtc();
		//var lastMonth = DateTime.now().prevMonth().prevMonth().prevMonth().prevMonth();
		//_now = lastMonth;
		var firstOfTheMonth = new ISOdate('${_now.year}-${ StringTools.lpad(Std.string(_now.month),"0" ,2 )}-01T00:00:00.00Z');
		
	    trace("1");
		var m:Match = new Match(new And([new VerbId(Verb.recieved.id), new InstructorName(nt)]));
		//var mv:Match = new Match(new VerbId(Verb.recieved.id));
		//var mDate:Match = new Match(new StmtTimestamp({"$gte": firstOfTheMonth}));
		var mDate:Match = new Match(new StmtTimestamp(new GreaterOrEqualThan(firstOfTheMonth)));
		pipeline = new Pipeline([m, mDate, project]);
		//trace(pipeline);
		return pipeline;
		
	}
	
	function set_nt(value:String):String 
	{
		return nt = value;
	}
}