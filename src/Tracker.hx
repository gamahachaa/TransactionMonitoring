package;
import js.Browser;
import xapi.Agent;
import xapi.Verb;
import signals.Signal1;
import xapi.types.Score;
import xapi.types.StatementRef;
/**
 * ...
 * @author bb
 */
class Tracker
{
	var xapi:XapiHelper;
	var duration:Float;
	var stage:Int;
	public var dispatcher(get, null):signals.Signal1<Int>;
	public var coachRecieved(get, null):StatementRef;
	public var monitoreeRecieved(get, null):StatementRef;
	public function new(url:String)
	{
		dispatcher = new Signal1<Int>();
		xapi = new XapiHelper(url);
		xapi.dispatcher.add(onStatemeentSent);
		#if debug
		trace("Tracker::Tracker::url", url );
		#end
		start();
	}

	function onStatemeentSent( success:Bool )
	{
		if (success)
		{
			if (stage == 0)
			{
				monitoreeRecieved = xapi.getLastStatementRef();
				stage = 1;
			}
			else if (stage == 1)
			{
				coachRecieved = xapi.getLastStatementRef();
				stage = 2;
			}
			dispatcher.dispatch(stage);
		}
		else dispatcher.dispatch( -1 );
	}
	public function start()
	{
		stage = 0;
		duration = Date.now().getTime();
		xapi.reset(false);
	}
	public function agentTracking(
		monitoree:Actor,
		coach:Actor,
		activity:String,
		activityExtensions:Map<String,Dynamic>,
		score:Score,
		success:Bool,
		resultsExtension:Map<String,Dynamic>,
		?lang:String="en")
	{
		xapi.setActor(new Agent(monitoree.mbox, monitoree.name));
		xapi.setVerb(Verb.recieved);
		xapi.setActivityObject( getActivityIRI(activity), null, null, "http://activitystrea.ms/schema/1.0/review", activityExtensions);
		xapi.setResult(score, resultsExtension, success, true, null);
		xapi.setContext(new Agent(coach.mbox,coach.name), getActivityIRI(""), "TM", lang, null);
		send();
	}
	public function coachTracking(
		coachAgent:Actor,
		monitoree:Actor,
		activity:String,
		score:Score,
		success:Bool,
		lang:String,
		extensions:Map<String,Dynamic>
	)
	{
		var c = new Agent(coachAgent.mbox, coachAgent.name);
		xapi.reset(true);
		xapi.setActor(c);
		xapi.setVerb(Verb.mentoored);
		xapi.setAgentObject(new Agent(monitoree.mbox, monitoree.name));
		xapi.setResult(score, null, success, true, null, Date.now().getTime() - duration);
		xapi.setContext(null,getActivityIRI(activity), null, lang, extensions );
		send();
	}
	public function callibrationTracking(
		coachAgent:Actor,
		activity:String,
		activityExtensions:Map<String,Dynamic>,
		monitoree:Actor,
		score:Score,
		success:Bool,
		lang:String,
		extensions:Map<String,Dynamic>
	)
	{
		xapi.reset(true);
		xapi.setActor(new Agent(coachAgent.mbox, coachAgent.name));
		xapi.setVerb(Verb.calibrated);
		//xapi.setAgentObject(new Agent(monitoree.mbox, monitoree.name));
		xapi.setActivityObject( getActivityIRI(activity), null, null, "http://activitystrea.ms/schema/1.0/review" );
		xapi.setResult(score, extensions, success, true, null, Date.now().getTime() - duration);
		xapi.setContext(null, getActivityIRI(""), "TM", lang, activityExtensions);
		stage = 2;
		send();
	}
	inline function getActivityIRI(a:String)
	{
		return Browser.location.origin + Browser.location.pathname + a;
	}
	function send()
	{
		if (xapi.validateBeforeSending())
		{
			xapi.send();
		}
	}

	function get_monitoreeRecieved():StatementRef
	{
		return monitoreeRecieved;
	}

	function get_coachRecieved():StatementRef
	{
		return coachRecieved;
	}

	function get_dispatcher():signals.Signal1<Int>
	{
		return dispatcher;
	}
}