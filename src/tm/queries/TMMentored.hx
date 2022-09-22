package tm.queries;
import mongo.Pipeline;
import xapi.Verb;
//import mongo.comparaison.GreaterOrEqualThan;
import mongo.conditions.And;
import mongo.stages.Match;
//import mongo.xapiSingleStmtShortcut.ActorName;
import mongo.xapiSingleStmtShortcut.InstructorName;
//import mongo.xapiSingleStmtShortcut.StmtTimestamp;
import mongo.xapiSingleStmtShortcut.VerbId;

//import thx.DateTime;
//import thx.DateTimeUtc;
//import thx.TimePeriod;
//import xapi.Verb;
//import xapi.types.ISOdate;

/**
 * ...
 * @author bb
 */
class TMMentored extends TMQueryBase 
{
	public var nt(default, set):String;

	public function new(nt:String, previousMonth:Bool) 
	{
		super(previousMonth);
		this.nt = nt;
		
	}
	override public function get_pipeline():Pipeline
	{
		
		//var firstOfTheMonth = new ISOdate('${_now.year}-${ StringTools.lpad(Std.string(_now.month),"0" ,2 )}-01T00:00:00.00Z');	

		var m:Match = new Match(new And([new VerbId(Verb.recieved.id), new InstructorName(nt)]));
		
		//var mDate:Match = new Match(new StmtTimestamp(new GreaterOrEqualThan(firstOfTheMonth)));
		//pipeline = new Pipeline([m, mDate, project]);
		pipeline = new Pipeline([m, getDatesBoundaries(), project]);
		//trace(pipeline);
		return pipeline;
		
	}
	
	function set_nt(value:String):String 
	{
		return nt = value;
	}
}