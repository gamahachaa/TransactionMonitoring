package tm.queries;
import mongo.Pipeline;
import mongo.queries.IQuery;
import mongo.stages.Project;
import tm.queries.TMBasicsThisMonth.BasicTM;
import thx.DateTime;

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
	public var id(get, null):String;
	public function new() 
	{
		this.id = Type.getClassName(Type.getClass(this));
		//signal = new signal.Signal1<Array<Dynamic>>();
		_now = DateTime.nowUtc();
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