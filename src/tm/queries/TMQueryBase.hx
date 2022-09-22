package tm.queries;
import mongo.queries.QueryBase;

/**
 * ...
 * @author bb
 */
class TMQueryBase extends QueryBase 
{

	public function new(?previousMonth:Bool=false) 
	{
		super(
		{
			_id:0,
			statement_id:"$statement.id",
			agent:"$statement.actor.name",
			tm:"$statement.object.id",
			timestamp:"$statement.timestamp",
			TMpassed:"$statement.result.success"
		}, 
		previousMonth
		);
		
	}
	
}