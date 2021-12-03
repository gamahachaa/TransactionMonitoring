package;

import haxe.Exception;
import haxe.Json;
import haxe.ui.components.Image;
import haxe.ui.components.Label;
import haxe.ui.components.OptionBox;
import haxe.ui.components.TextArea;
import haxe.ui.containers.Box;
import haxe.ui.containers.Group;
import haxe.ui.containers.HBox;
import haxe.ui.containers.VBox;
import haxe.ui.core.Component;
import haxe.ui.events.FocusEvent;
import haxe.ui.events.MouseEvent;
import haxe.ui.events.UIEvent;
import haxe.ui.locale.LocaleManager;
import haxe.ui.styles.animation.Animation;
import xapi.types.Score;

/**
 * ...
 * @author bb
 */
/*enum Criticality{
	business;
	compliance;
	user;
	none;
}*/
typedef Userdata = {
	var points: Int;
	var criticality: String;
	var critical: Bool;
}
class Question
{
	public static var ALL:Map<String,Question> = [];
	public static var COUNT:Int = 0;
	public static var MAX_SCORE:Int = 0;
	public static var FAILED_OVERALL:Array<String> = [];
	public static var FAILED_CRITICAL:Array<String> = [];
	public static var FAILED_CRITICAL_CUSTOMER:Array<String> = [];
	public static var FAILED_CRITICAL_COMPLIANCE:Array<String> = [];
	public static var FAILED_CRITICAL_BUSINESS:Array<String> = [];
	public static var RESULT_MAP:Map<String,String> = [];
	public static var CRITICALITY_MAP:Map<String,Int> = ["business"=>0,"compliance"=>0,"customer"=>0];
	public static var INFO:Info;
	public static inline var MIN_PERCENTAGE_BEFORE_FAILLING:Float = .89;
	var label:Label;
	var radioGroup:Group;
	var justification:TextArea;
	var radioBtns:Array<OptionBox>;
	var id:String;
	//var parent:Component;
	var _this:Box;
	//var critical:Bool;
	//var criticality:Criticality;
	//var points:Float;
	public var userData:Userdata;
	var infoIcon:Image;
	static inline var NON_CRITICAL:String = "non critical";
	//var pointerIcon:Image;
	public var agreement(get, null):Agreement;

	public static function GET_ALL(form:Component)
	{
		ALL = [];
		FAILED_OVERALL = [];
		FAILED_CRITICAL = [];
		COUNT = 0;
		MAX_SCORE = 0;
		//var qs:Array<VBox> = form.findComponents("questions", VBox);
		var qs:Array<HBox> = form.findComponents("questions", HBox);
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
        resetPointer();
	}
	function resetPointer()
	{
		//pointerIcon.hidden = true;
		if (this.label.hasClass("h3")) this.label.removeClass("h3");
	}
	public static function RESET()
	{
		 INFO.reset();
		for (i in ALL)
		{
			i.reset();
		}
	}
	public static function GET_SCORE():Score
	{
		var s = new Score();
		if ( FAILED_CRITICAL.length > 0) {
			s.max = 100;
			s.raw = 0;
		}
		else{
			var totalFailed = 0;
			for (i in FAILED_OVERALL){
				totalFailed += ALL.get(i).userData.points;
			}
			s.raw = MAX_SCORE-totalFailed;
			s.max = MAX_SCORE;
		}
		
		return s;
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
	static function RESET_Pointers()
	{
		for (v in ALL)
		{
			v.resetPointer();
		}
	}
	function new(id:String, parent:HBox)
	{
		//this.parent = parent;
        
		this.id = id;
		_this = parent;
		
		//trace(_this.styleNames);
		//trace(_this.cssName);
		//trace(id, _this.userData);
		userData = {points:5, critical:false, criticality:NON_CRITICAL};
		if ( _this.userData != null )
		{
			var ud:Dynamic = Json.parse( _this.userData);
			try{
				ud.critical = ! (ud.criticality == NON_CRITICAL);
				userData = ud;
			}catch (e){
				trace('Wrong format for userdata $ud');
			}
			//userData.points = _this.userData.points;
			//userData.critical = false;
			//userData.criticality = "none";
		}
		//infoIcon = _this.findComponent("iconInfo", Image);
		//infoIcon.resource = "images/info-" + (userData.critical ? "critical.png":"noncritical.png");
		//infoIcon.onClick = updateInfo;
		
		
		label = _this.findComponent("question", Label);
		label.onClick = updateInfo;
		//label.registerEvent(MouseEvent.MOUSE_OVER, function(e)trace(e));
		label.htmlText = "{{" + this.id + "}}";
		//label.htmlText = "123456789123456789";
		radioGroup = _this.findComponent("agreement");
		//critical = radioGroup.hasClass("critical");
		radioBtns = cast(radioGroup.childComponents);
		justification = _this.findComponent("justify", TextArea);
		agreement = new Agreement(getSelected(),"", userData.critical);
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
			MAX_SCORE += userData.points;
		}

	}
	
	function updateInfo(e:MouseEvent) 
	{
		//trace(id);
		//var animOpt:AnimationOptions = {};
		//animOpt.duration = 100;
		//animOpt.delay = 1;
		//var anim:Animation = new Animation(INFO.container, animOpt);
		
		if (INFO.container.hidden || this.id != INFO.id)
		{
			RESET_Pointers();
			this.label.addClass("h3");
			//pointerIcon.hidden = false;
			INFO.show(this.id);
			
			INFO.title.htmlText = "{{" + id + "}}";
			INFO.setCriticality(userData.critical);
			//var criticalString = userData.critical ? this.userData.criticality.toUpperCase() : "NON CRITICAL";
			INFO.criticality.htmlText = "{{" + this.userData.criticality.toUpperCase() + "}}";
			INFO.points.htmlText = "(pts: {{" + this.userData.points + "}})";
			INFO.questionDesc.htmlText = "{{" + id + ".desc}}";
			INFO.passedDesc.htmlText = "{{" + id + ".passed}}";
			INFO.failedDesc.htmlText = "{{" + id + ".failed}}";
			LocaleManager.instance.language = "en";
			LocaleManager.instance.language = TMApp.lang;
		}
		//anim.run(()->trace("finished"));
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
		#if debug
		//trace("Question::onchange::this.id", this.id );
		//trace(LocaleManager.instance.lookupString(this.id));
		#end
		var o:OptionBox = cast(e.target);
		this.agreement.choice = o.id;
		//this.justification.hidden = false;
		updateInfo(null);
		if (this.agreement.choice == "n")
		{
			//this.justification.hidden = false;
			//this.justification.placeholder = "You must tell us why !";
			this.justification.placeholder = "{{failed_placeholder}}";
			if (!FAILED_OVERALL.contains(id))
			{
				FAILED_OVERALL.push(id);
			}
			if (userData.critical && !FAILED_CRITICAL.contains(id))
			{
				FAILED_CRITICAL.push(id);
				var count = CRITICALITY_MAP.exists(userData.criticality)?CRITICALITY_MAP.get(userData.criticality):0;
				
				CRITICALITY_MAP.set(userData.criticality, ++count);
				/*switch (userData.criticality)
				{
					case "business" : FAILED_CRITICAL_BUSINESS.push(id);
					case "customer" : FAILED_CRITICAL_CUSTOMER.push(id);
					case "compliance" : FAILED_CRITICAL_COMPLIANCE.push(id);
				}*/
			}
		}

		else
		{
			if (this.agreement.choice == "na")
			{
				resetJustification();
			}
			else if (this.agreement.choice == "y")
			{
				//this.justification.placeholder = "Comment if you wish.";
				this.justification.placeholder = "{{passed_placeholder}}";
			}
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
		justification.placeholder = "";
		/*justification.hidden = true;*/
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
		agreement = new Agreement(getSelected(),"", userData.critical);
	}
	function get_agreement():Agreement
	{
		return agreement;
	}

}