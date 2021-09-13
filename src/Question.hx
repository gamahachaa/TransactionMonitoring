package;

import haxe.Exception;
import haxe.ui.components.Label;
import haxe.ui.components.OptionBox;
import haxe.ui.components.TextArea;
import haxe.ui.containers.Group;
import haxe.ui.containers.VBox;
import haxe.ui.core.Component;
import haxe.ui.events.FocusEvent;
import haxe.ui.events.UIEvent;

/**
 * ...
 * @author bb
 */
class Question
{
	public static var ALL:Map<String,Question> = [];
	public static var COUNT:Int = 0;
	public static var FAILED_OVERALL:Array<String> = [];
	public static var FAILED_CRITICAL:Array<String> = [];
	public static var RESULT_MAP:Map<String,String> = [];
	var label:Label;
	var radioGroup:Group;
	var justification:TextArea;
	var radioBtns:Array<OptionBox>;
	var id:String;
	//var parent:Component;
	var _this:VBox;
	var critical:Bool;
	public var agreement(get, null):Agreement;

	public static function GET_ALL(form:Component)
	{
		ALL = [];
		FAILED_OVERALL = [];
		FAILED_CRITICAL = [];
		COUNT = 0;
		var qs:Array<VBox> = form.findComponents("questions", VBox);
		var id = "";
		for (q in qs)
		{

			id = Utils.GET_PARENT_PATH(q, q.id);
			if (id == "") continue;
			//#if debug
			//trace("Question::GET_ALL::id", id );
			#if debug
			//trace("Question::GET_ALL::id", id );
			#end
			//trace("Question::GET_ALL::id", id );
			//#end
			ALL.set(id, new Question(id, q ));
			//trace(ALL);
			COUNT++;
		}
		//#if debug
		//trace("Question::GET_ALL::ALL", ALL );
		//#end

	}
	public function reset()
	{
		FAILED_OVERALL.remove(id);
		FAILED_CRITICAL.remove(id);

		resetRadios();
		resetJustification();
	
	}
	public static function RESET()
	{
		for (i in ALL)
		{
			i.reset();
		}
	}
	public static function GET_SCORE()
	{
		return FAILED_CRITICAL.length> 0 ? 0 : Math.round(((COUNT - FAILED_OVERALL.length) / COUNT)*100)/100 ;
	}
	/*public static MAP_ALL(extPrefix:String)
	{
		var m = [];
		for (k => v in ALL)
		{
			m.set('$extPrefix/$k', v);
		}
		return m;
	}*/
	public static function PREPARE_RESULTS():Utils.Status
	{
		var canSubmit = true;
		var m:Array<String> = [""];
		var mustJustify = false;
		//var completed = true;
		RESULT_MAP = [];
		for (k => v in ALL)
		{
			if (v.agreement.choice == "TODO")
			{
				canSubmit = false;
				m.push("{{ALERT_UNANSWERED_QUESTIONS}}");
				break;
			}
			else if (v.agreement.choice == "n")
			{
				if (v.justification.text == null || v.justification.text == "" )
				{
					mustJustify = true;
					v.justification.addClass("wrong");	
				}
			}
			v.agreement.justification = v.justification.text;
			RESULT_MAP.set(k, v.agreement.choice);
			RESULT_MAP.set(k + ".justification", v.agreement.justification);

		}
		if (mustJustify)
		{
			m.push( "{{ALERT_ADD_ARGUEMENT_WHEN_DISAGREE}}");
			canSubmit = false;
		}
		return {canSubmit:canSubmit, message: m};
	}
	function new(id:String, parent:VBox)
	{
		//this.parent = parent;
		this.id = id;
		_this = parent;
		label = _this.findComponent("question", Label);
		radioGroup = _this.findComponent("agreement");
		critical = radioGroup.hasClass("critical");
		radioBtns = cast(radioGroup.childComponents);
		justification = _this.findComponent("justify", TextArea);
		agreement = new Agreement(getSelected(),"", critical);
		radioGroup.onChange = onchange;
		justification.registerEvent(FocusEvent.FOCUS_OUT, onJustifyOut);
		justification.registerEvent(FocusEvent.FOCUS_IN, onJustifyIn);
		reset();
		if (ALL.exists(this.id))
		{
			throw new Exception("Duplicate Question");
		}
		else
		{
			ALL.set(this.id, this);
		}
	}

	function onJustifyIn(e:FocusEvent):Void
	{
		justification.removeClass("wrong");
		#if debug
		trace("Question::onJustifyIn:: onJustifyIn", justification.className );
		#end
		
	}

	function onJustifyOut(e:FocusEvent):Void
	{
		this.agreement.justification = justification.text;
		justification.removeClass("wrong");
		#if debug
		trace("Question::onJustifyOut:: onJustifyIn", justification.className );
		#end
	}

	function onchange(e:UIEvent)
	{
		var o:OptionBox = cast(e.target);
		this.agreement.choice = o.id;
		this.justification.hidden = false;
		if (this.agreement.choice == "n")
		{
			//this.justification.hidden = false;
			if (!FAILED_OVERALL.contains(id))
			{
				FAILED_OVERALL.push(id);
			}
			if (critical && !FAILED_CRITICAL.contains(id))
			{
				FAILED_CRITICAL.push(id);
			}
		}
		else
		{
			FAILED_CRITICAL.remove(id);
			FAILED_OVERALL.remove(id);
			//this.justification.hidden = true;
			//this.agreement.justification = "";
		}
		//this.justification.hidden = o.id == "n";
		//this.agreement.choice = o.id;

	}
	

	function resetJustification()
	{
		justification.text = "";
		justification.hidden = true;
	}

	function getSelected()
	{
		var o:OptionBox;
		for (i in radioBtns)
		{
			o = cast(i);
			if (o.selected) return o.id;

		}
		return "TODO";
	}

	function resetRadios()
	{
		radioGroup.resetGroup();
		agreement = new Agreement(getSelected(),"", critical);
	}
	function get_agreement():Agreement
	{
		return agreement;
	}

}