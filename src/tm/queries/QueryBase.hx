package tm.queries;
import mongo.Pipeline;
import mongo.comparaison.GreaterOrEqualThan;
import mongo.comparaison.LowerThan;
import mongo.conditions.And;
import mongo.queries.IQuery;
import mongo.stages.Match;
import mongo.stages.Project;
import mongo.xapiSingleStmtShortcut.StmtTimestamp;
import thx.TimePeriod;
import tm.queries.TMBasicsThisMonth.BasicTM;
import thx.DateTime;
import xapi.types.ISOdate;

/**
 * ...
 * @author bb
 */
class QueryBase implements IQuery 
{
    //public var signal(get, null):signal.Signal1<Array<Dynamic>>;
	public var pipeline(get, null):Pipeline;
	var projetctMapping:BasicTM;
	var _now:DateTime;
	var project:Project;
	var monthFirstDay:thx.DateTime;
	var nextMonthFirstDay:thx.DateTime;
	public var id(get, null):String;
	public function new(?previousMonth:Bool=false) 
	{
		this.id = Type.getClassName(Type.getClass(this));
		//signal = new signal.Signal1<Array<Dynamic>>();
		updateBoundaries(previousMonth);
		
		projetctMapping =  {
			_id:0,
			statement_id:"$statement.id",
			agent:"$statement.actor.name",
			tm:"$statement.object.id",
			timestamp:"$statement.timestamp",
			TMpassed:"$statement.result.success"
		};
		project = new Project( projetctMapping );
	}
	public function updateBoundaries(?prevMonth:Bool = false)
	{
		_now = DateTime.nowUtc();
		if (prevMonth) _now = _now.prevMonth();
		monthFirstDay = _now.snapPrev(TimePeriod.Month);
		#if debug
		trace("tm.queries.QueryBase::QueryBase::monthFirstDay", monthFirstDay );
		#end
		nextMonthFirstDay = _now.snapNext(TimePeriod.Month);
	}
	function getDatesBoundaries():Match
	{
		
		  return new Match(new And([
		new StmtTimestamp(new GreaterOrEqualThan(ISOdate.fromString(monthFirstDay.toString()))),
		new StmtTimestamp(new LowerThan(ISOdate.fromString(nextMonthFirstDay.toString())))
		]
		));
	}
	public function get_pipeline():Pipeline
	{
		throw "get_pipeline need to be overriden by sub class Bro !";
	}
	
	public function get_id():String 
	{
		return id;
	}
	//function get_signal():signal.Signal1<Array<Dynamic>>
	//{
		//return signal;
	//}
}