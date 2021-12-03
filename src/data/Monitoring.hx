package data;

/**
 * ...
 * @author bb
 */
class Monitoring 
{
	public static inline var MONITORING_TYPE:String = "monitoringType";
	public static inline var MONITORING_REASON:String = "monitoringReason";
	public static inline var MONITORING_SUMMARY:String = "monitoringSummary";
	@:isVar public var coach(get, set):Coach;
	public var data:Map<String, String>;
	public function new(?coach:Coach) 
	{
		//data = [];
		reset();
		this.coach = coach;
	}
	public function reset()
	{
		data = [];
	}
	function get_coach():Coach 
	{
		return coach;
	}
	
	function set_coach(value:Coach):Coach 
	{
		return coach = value;
	}
	
}