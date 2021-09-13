package;

import haxe.Exception;
import haxe.Http;
import haxe.Json;
import haxe.Serializer;
import js.Browser;
import signals.Signal1;
import xapi.Activity;
import xapi.Agent;
import xapi.Context;
import xapi.Statement;
import xapi.Verb;
import xapi.activities.Definition;
import xapi.types.IObject;
import xapi.types.Score;
import xapi.Result;
import xapi.types.StatementRef;
using StringTools;

/**
 * ...
 * @author bb
 */
class XapiHelper extends Http
{
	public static inline var VERB_RECIEVED:String = "http://activitystrea.ms/schema/1.0/receive";
	public static inline var VERB_MENTORED:String = "http://id.tincanapi.com/verb/mentored";
	var map:Map<String, String>;
	var nullKeys:Array<String>;
	var canRequest:Bool;
	var statementsRefs:Array<StatementRef>;
	var statement: xapi.Statement;
	var object:IObject;
	var verb:Verb;
	var result:xapi.Result;
	var context:Context;
	var _mainDebug:Bool;
	//var serializer:haxe.Serializer;
	@:isVar var actor(get, set):Agent;
	public var dispatcher:Signal1<Bool>;
	public function new(url:String)
	{
		super(url);
		_mainDebug = Browser.location.origin.indexOf("salt.ch") > -1;
		this.async = true;
		Serializer.USE_CACHE = true;
		Serializer.USE_ENUM_INDEX = true;
		//serializer = new Serializer();
		statementsRefs = [];
		statement = null;
		actor = null;
		object = null;
		verb = null;
		context = null;
		result = new Result();
		dispatcher = new Signal1<Bool>();
		//map = new Map<String,String>();
		// minimal statement needs
		//map.set("mbox", "");
		//map.set("activity", "");
		//map.set("verb", "");
		canRequest = true;
		this.onData = onMyData;
	}
	public function reset(referenceLast:Bool)
	{
		if (!referenceLast) statementsRefs = [];
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

		//map.set("activity", object.indexOf("http")==0? object: Browser.location.origin + Browser.location.pathname + object);
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
		scoreScaled:Float,
		?extensions:Map<String,Dynamic>,
		?success:Bool,
		?completion:Bool,
		?response:String,
		?duration:Float)
	{
		result = new Result(new Score(scoreScaled * 100), success, true, null, duration, extensions);
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
	public function setStatementRefs(statementRef:StatementRef)
	{
		statementsRefs = [statementRef];
	}
	public function addStatementRef(id:StatementRef)
	{
		statementsRefs.push(id);
	}
	public function getStatementRef():Array<StatementRef>
	{
		return statementsRefs;
	}
	public function getLastStatementRef():StatementRef
	{
		return statementsRefs[statementsRefs.length -1];
	}
	public function send()
	{
		//prepareParams();
		try
		{
			statement = new Statement(actor, verb, object, result, context);
			var serialized = Serializer.run(statement);
				#if debug
				if (_mainDebug){
						//statement = new Statement(actor, verb, object, result, context);
					//var serialized = Serializer.run(statement);
					trace(serialized);
					this.setParameter("statement", serialized);
					this.request(true);
				}
				else{
					trace(serialized);
					onMyData(Json.stringify({status:"success", statementsIds:["24b31561-6138-4dbc-995e-d725b8b39dda"]}));
				}
			
			#else
				statement = new Statement(actor, verb, object, result, context);
				//var serialized = Serializer.run(cast statement);
				this.setParameter("statement", Serializer.run(statement));
				this.request(true);
			#end
		}
		catch (e:Exception)
		{
			#if debug
			trace(e.message);
			trace(e.stack);
			trace(e.details());
			#end
		}
		
	}
	
	function onMyData(data:String)
	{
		//trace(data);
		try
		{
			var d = Json.parse(data);
			#if debug
			trace(d);
			#end
			if (d.status == "success")
			{
				//data.indexOf("success")>-1)
				statementsRefs.push(new StatementRef(d.statementsIds[0]));
				//setStatementRef(statementsRef[0]);
				dispatcher.dispatch(true);
			}
			else
			{
				dispatcher.dispatch(false);
			}
		}
		catch (e:Exception)
		{
			//trace(e);
			//trace(data);
			dispatcher.dispatch(false);
		}
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