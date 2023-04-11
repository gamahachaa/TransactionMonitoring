package tm;
import http.XapiHelper;
import js.Browser;
import roles.Actor;
import xapi.Activity;
import xapi.Agent;
import xapi.Context;
import xapi.Result;
import xapi.Statement;
import xapi.Verb;
import signals.Signal1;
import xapi.activities.Definition;
import xapi.types.IObject;
import xapi.types.Score;
import xapi.types.StatementRef;
/**
 * ...
 * @author bb
 */
class Tracker extends XapiHelper
{
	//var xapi:http.XapiHelper;

	public var stage:Int;
	public var signal(get, null):signals.Signal1<Int>;
	public var coachRecieved(get, null):StatementRef;
	public var monitoreeRecieved(get, null):StatementRef;

	var statement: Statement;
	var object:IObject;
	var verb:Verb;
	var result:Result;
	var context:Context;
	@:isVar var actor(get, set):Agent;
	var _duration:Float;

	public function new(url:String)
	{
		super(url);
		signal = new Signal1<Int>();
		statement = null;
		actor = null;
		object = null;
		verb = null;
		context = null;
		result = new Result();

		this.dispatcher.add(onStatemeentSent);
		#if debug
		//trace("Tracker::Tracker::url", url );
		#end
		stage = 0;
		start();
	}
	override public function reset(?referenceLast:Bool)
	{
		super.reset(referenceLast);
		statement = null;
		actor = null;
		object = null;
		verb = null;
		context = null;
	}
	
	public function validateBeforeSending()
	{
		if (actor == null || object == null || verb == null) return false;
		return true;
	}
		public function setActor( agent:Agent)
	{
		actor = agent;
	}
	public function setActivityObject(objectID:String, ?name:Map<String,String>=null, ?description:Map<String,String>=null, ?type:String="", ?extensions:Map<String,Dynamic>=null,?moreInfo:String="")
	{
		var def:Definition = null;
		if (type != "" || moreInfo != "" || extensions != null || name != null || description != null)
		{
			def = new Definition();
			if (type != "")
			{
				def.type = type;
			}
			if (moreInfo != "")
			{
				def.type = type;
			}
			if (extensions != null)
			{
				def.extensions = extensions;
			}
			if (description != null)
			{
				def.description = description;
			}
			if (name != null)
			{
				def.name = name;
			}
		}

		object = new Activity(objectID, def);
	}
	public function setAgentObject(agent:Agent)
	{
		object = agent;
	}
	public function setVerb(did:Verb)
	{
		verb = did;
	}
	public function setResult(
		score:Score,
		?extensions:Map<String,Dynamic>,
		?success:Bool,
		?completion:Bool,
		?response:String,
		?duration:Float=0)
	{
		result = new Result(score, success, completion, response, duration==0? Date.now().getTime() - _duration:duration, extensions);
	}
	public function setContext(
		instructor:Agent,
		parentActivity:String,
		platform:String,
		language:String,
		extensions:Map<String,Dynamic>)
	{

		context = new Context(null, instructor, null,null, null, platform, language, statementsRefs.length > 0?statementsRefs[statementsRefs.length - 1]:null, extensions);
		context.addContextActivity(parent, new Activity(parentActivity));
	}
	function onStatemeentSent( success:Bool )
	{
		#if debug
		trace("tm.Tracker::onStatemeentSent success stage ", success, stage);
		#end
		if (success)
		{
			if (stage == 0)
			{
				monitoreeRecieved = this.getLastStatementRef();
				stage = 1;
			}
			else if (stage == 1)
			{
				coachRecieved = this.getLastStatementRef();
				stage = 2;
			}
			signal.dispatch(stage);
		}
		else signal.dispatch( -1 );
	}

	public function agentTracking(
		monitoree:roles.Actor,
		coach:roles.Actor,
		activity:String,
		activityExtensions:Map<String,Dynamic>,
		score:Score,
		success:Bool,
		resultsExtension:Map<String,Dynamic>,
		?lang:String="en")
	{
		this.setActor(new Agent(monitoree.mbox, monitoree.name));
		this.setVerb(Verb.recieved);
		this.setActivityObject( getActivityIRI(activity), null, null, "http://activitystrea.ms/schema/1.0/review", activityExtensions);
		this.setResult(score, resultsExtension, success, true);
		this.setContext(new Agent(coach.mbox, coach.name), getActivityIRI(""), "TM", lang, null);
		
		if (validateBeforeSending())
		{
			var statement:Statement = new Statement(actor, verb, object, result, context);
			#if debug
			//trace(statement.timestamp);
			#else
			#end
			//sendMany([statement]);
			sendSignle(statement);
		}
		else{
			/**
			 * @todo capture
			*
			* */
		}
	}
	public function coachTracking(
		coachAgent:roles.Actor,
		monitoree:roles.Actor,
		activity:String,
		score:Score,
		success:Bool,
		lang:String,
		extensions:Map<String,Dynamic>
	)
	{
		var c = new Agent(coachAgent.mbox, coachAgent.name);
		this.reset(true);
		this.setActor(c);
		this.setVerb(Verb.mentoored);
		this.setAgentObject(new Agent(monitoree.mbox, monitoree.name));
		this.setResult(score, null, success, true);
		this.setContext(null,getActivityIRI(activity), null, lang, extensions );
		
		if (validateBeforeSending())
		{
			var statement:Statement = new Statement(actor, verb, object, result, context);
			#if debug
			//trace(statement.timestamp);
			#else
			#end
			sendSignle(statement);
			//sendSignle(statement);
		}
		else{
			/**
			 * @todo capture
			*
			* */
		}
	}
	public function callibrationTracking(
		coachAgent:roles.Actor,
		activity:String,
		activityExtensions:Map<String,Dynamic>,
		/*monitoree:roles.Actor,*/
		score:Score,
		success:Bool,
		lang:String,
		extensions:Map<String,Dynamic>
	)
	{
		this.reset(true);
		this.setActor(new Agent(coachAgent.mbox, coachAgent.name));
		this.setVerb(Verb.calibrated);
		this.setActivityObject( getActivityIRI(activity), null, null, "http://activitystrea.ms/schema/1.0/review" );
		this.setResult(score, extensions, success, true);
		this.setContext(null, getActivityIRI(""), "TM", lang, activityExtensions);
		stage = 2;
		
		if (validateBeforeSending())
		{
			//sendMany([new Statement(actor, verb, object, result, context)]);
			sendSignle(new Statement(actor, verb, object, result, context));
		}
		else{
			/**
			 * @todo capture
			*
			* */
		}
	}
	
	override public function start()
	{
		#if debug
		trace("tm.Tracker::start");
		#end
		super.start();
		this.stage = 0;
		_duration = Date.now().getTime();
	}
	
	/*function send()
	{
		if (this.validateBeforeSending())
		{
			this.send();
		}
	}*/

	function get_monitoreeRecieved():StatementRef
	{
		return monitoreeRecieved;
	}

	function get_coachRecieved():StatementRef
	{
		return coachRecieved;
	}

	function get_signal():signals.Signal1<Int>
	{
		return signal;
	}
	function get_actor():xapi.Agent
	{
		return actor;
	}

	function set_actor(value:xapi.Agent):xapi.Agent
	{
		return actor = value;
	}
}