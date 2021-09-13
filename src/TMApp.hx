package;
import haxe.Exception;
import haxe.ui.HaxeUIApp;
import haxe.ui.Toolkit;
import haxe.ui.components.CheckBox;
import haxe.ui.components.Image;
import haxe.ui.components.Stepper;
import haxe.ui.focus.FocusManager;
//import haxe.ui.Toolkit;
//import haxe.ui.ToolkitAssets;
//import haxe.ui.assets.AssetPlugin;
import haxe.ui.components.Button;
import haxe.ui.components.Label;
import haxe.ui.components.OptionBox;
import haxe.ui.components.DropDown;
//import haxe.ui.components.Slider;
import haxe.ui.components.Switch;
import haxe.ui.components.TextArea;
import haxe.ui.components.TextField;
import haxe.ui.containers.Group;
import haxe.ui.containers.dialogs.Dialog;
import haxe.ui.containers.dialogs.MessageBox;
import haxe.ui.core.Component;
import haxe.ui.events.FocusEvent;
import haxe.ui.events.MouseEvent;
import haxe.ui.events.UIEvent;
import xapi.types.StatementRef;
//import haxe.ui.focus.FocusManager;
import haxe.ui.locale.LocaleManager;
import haxe.ui.macros.ComponentMacros;
import haxe.ui.parsers.locale.CSVParser;
import haxe.ui.parsers.locale.LocaleParser;
import js.Browser;
import js.Cookie;
import js.Lib;
import js.Browser;
//import haxe.ui.parsers.locale.TSVParser;
import haxe.ui.tooltips.ToolTipManager;
import MailHelper.Result;
using StringTools;

/**
 * ...
 * @author bb
 */
class TMApp 
{
	var mainApp:Component;
	var loginApp:Component;
	var langSwitcher:Group;
	var formSwitcher: DropDown;
	var content:Component;
	var init:Bool;
	var inbound:Component;
	var outbound:Component;
	var mail:Component;
	var ticket:Component;
	var forms:Map<String, Component>;
	var agreements:Array<Group>;
	var currentForm:Component;

	var tmMetadatas:Map<String, Dynamic>;
	var justifications:Array<TextArea>;
	var app:haxe.ui.HaxeUIApp;
	var dialog:MessageBox;
	var criticals:Array<String>;
	//var video:js.html.VideoElement;
	var sendBtn:Button;
	var agentTF:TextField;
	var logger:LoginHelper;
	var loginFeedback:Label;
	var coachPWD:TextField;
	var coachUsername:TextField;
	var loginBtn:Button;
	//var coachAgent:Coach;
	var versionLabel:Label;
	var version:String;
	//var monitoringType:Group;
	//var monitoringReason:Group;
	var coachEmail:Label;
	var summaries:Array<TextArea>;
	//var monitoree:Monitoree;
	var monitoringReasonValue:String;
	var monitoringTypeValue:String;
	var monitoringSummaryValue:String;
	var transactionSummaryValue:String;
	var cookie:CookieHelper;
	var transactionSummary:TextArea;
	var monitoringSummary:TextArea;
	var failedCriticals:Float;
	var mailComposer:TMMailer;
	var failedOverall:Float;
	var countQuestions:Float;
	var whatToSend:Switch;
	var whatToSendLabel:Label;
	var _mainDebug:Bool;
	var comonLibs:String;
	var xapi:XapiHelper;
	//var form_id:String;
	var tracker:Tracker;
	var transaction:Transaction;
	var monitoring:Monitoring;
	var lang:String;
	var transactionDateComp:DropDown;
	var transcationHourComp:Stepper;
	var transcationMinutesComp:Stepper;
	var transactionDate:Date;
	var transactionIdTF:TextField;
	var monitoringType:Group;
	var monitoringReason:Group;
	public function new()
	{
		_mainDebug = Browser.location.origin.indexOf("salt.ch") > -1;
		comonLibs = Browser.location.origin + "/commonlibs/";
		#if debug
		version = "TM_COOKIE";
		#else
		version = VersionHelper.getVersion("TM").replace("TM_", "");
		#end
		LocaleParser.register("csv", CSVParser);
		version = VersionHelper.getVersion("TM").replace("TM_", "");
		//xapi = new XapiHelper(comonLibs + "xapi.php");
		tracker = new Tracker(comonLibs + "xapi/index.php");
		tracker.dispatcher.add(onTracking);

		mailComposer = new TMMailer(comonLibs + "mail/index.php");
		mailComposer.successSignal.add(onMailSucces);
		cookie = new CookieHelper(version);
		app = new HaxeUIApp();
		LocaleManager.instance.language = "en";
		dialog = new MessageBox();
		dialog.type = MessageBoxType.TYPE_WARNING;
		dialog.width = 360;
		dialog.height = 280;
		dialog.draggable = false;
		//dialog.icon = "";
		//dialog.iconImage = null;
		criticals = [];
		agreements = [];
		currentForm = null;
		forms = new Map<String, Component>();
		transaction = new Transaction();
		monitoring = new Monitoring();
		//tmMetadatas = new Map<String, String>();

		init = false;
		logger = new LoginHelper("https://qook.test.salt.ch/commonlibs/login/index.php");
		logger.successSignal.add(onLoginSuccess);
		//logger.statusSignal.add((e)->(trace(e)));
		app.ready(function()
		{
			ToolTipManager.defaultDelay = 100;
		
			mainApp = ComponentMacros.buildComponent("assets/ui/main.xml");
			loginApp = ComponentMacros.buildComponent("assets/ui/login.xml");

			try
			{
				#if debug
				//if (_mainDebug) coachAgent = cookie.retrieve(version);
				if (_mainDebug) monitoring.coach = cookie.retrieve(version);
				else monitoring.coach = Coach.CREATE_DUMMY();
				//else coachAgent = Coach.CREATE_DUMMY();
				//Toolkit.screen.actualHeight;
				
				#else
				//coachAgent = cookie.retrieve(version);
				monitoring.coach = cookie.retrieve(version);
				#end
				loadContent();
			}
			catch (e:Exception)
			{
				#if debug
				trace("Main::Main::e", e );
				#end
                prepareLogin( monitoring.coach );
				app.addComponent(loginApp);
			}
			//prepareLogin(coachAgent);
			
			app.start();
			//Toolkit.autoScale = false;
            //trace(Toolkit.screen.actualHeight);
				//trace(Toolkit.screen.actualWidth);
				//trace(Toolkit.autoScale);
				//trace(Toolkit.autoScaleDPIThreshold);
				//trace(Toolkit.scaleX);
				//trace(Toolkit.scaleY);
		});
	}

	function onTracking(stage:Int)
	{
		if (stage == -1)
		{
			trace("errror with the XAPI");
		}
		else if (stage == 1)
		{
			var score = Question.GET_SCORE();
			tracker.coachTracking( monitoring.coach,transaction.monitoree, transaction.type, score, Question.FAILED_CRITICAL.length == 0, lang, tmMetadatas);

		}
		else if (stage == 2)
		{
			sendEmailToBoth(tracker.coachRecieved);
		}
	}

	function onMailSucces(r:Result)
	{
		/**
		 * @todo add tracking here
		 */

		if (r.status == "success")
		{
			dialog.type = MessageBoxType.TYPE_INFO;
			dialog.message = "Successfully";
			dialog.title = "Monitoring SENT !";
		}
		else
		{
			dialog.type = MessageBoxType.TYPE_ERROR;
			dialog.message = "dispatched NOT Successfully";
			dialog.title = "Monitoring email";
		}
		try
		{
			#if debug
			trace("Main::onMailSucces::s", r, dialog.message );
			#end
			dialog.showDialog(true);
			reset();
		}
		catch (e:Exception)
		{
			trace(e);
		}
	}
	
	function reset() 
	{
		#if debug
		trace("TMApp::reset::reset", reset );
		#end
		resetForm();
		resetTransaction();
		resetMonitoring();
	}
	
	
	
	function resetForm() 
	{
		  Question.RESET();
	}

	function prepareLogin( coach:Coach )
	{
		versionLabel = loginApp.findComponent("version", Label);
		versionLabel.text = "v " + version;
		loginBtn = loginApp.findComponent("login", Button);
		coachUsername = loginApp.findComponent("username", TextField);
		coachUsername.text = coach == null ? "" : coach.sAMAccountName;
		coachPWD = loginApp.findComponent("pwd", TextField);
		coachPWD.password = true;
		coachPWD.text = "";
		var showPWD:Image = loginApp.findComponent("showPwd", Image);
		showPWD.onClick = onShowChange;
		loginFeedback = loginApp.findComponent("feedback", Label);
		#if debug
		if (_mainDebug) loginBtn.onClick = onLoginClicked;
		else loginBtn.onClick = (e)->(onLoginSuccess(monitoring.coach));
		//else loginBtn.onClick = (e)->(onLoginSuccess(coachAgent));
		#else
		loginBtn.onClick = onLoginClicked;
		#end
	}
	
	function onShowChange(e) 
	{
		coachPWD.password = !coachPWD.password; 
	}

	function onLoginSuccess(agent:Actor)
	{
		if (Std.isOfType(agent, Coach))
		{
			if (agent.authorised)
			{
				monitoring.coach  = cast(agent, Coach);
				cookie.flush(version, monitoring.coach );
				loadContent();
			}
			else
			{
				loginFeedback.addClass("error");
				loginFeedback.text = agent.title;
			}
		}
		else if (Std.isOfType(agent, Monitoree ))
		{
			transaction.monitoree = cast(agent, Monitoree);
			var agentLabel:Label = mainApp.findComponent("agentlabel", Label);
			agentLabel.removeClass("error");
			agentLabel.removeClass("correct");
			if (transaction.monitoree.authorised)
			{
				agentLabel.htmlText = '<strong class="correct">${StringTools.replace(transaction.monitoree.mbox, "mailto:","")}</strong>\n${transaction.monitoree.title}';
				/*agentLabel.color = 0x65a63c;*/
				agentLabel.addClass("correct");
				tracker.start();
			}
			else
			{
				agentLabel.htmlText = '{{ERROR}} \n<strong class="error">${transaction.monitoree.name}</strong>';
				agentLabel.addClass("error");
				/*agentLabel.color = 0xFF0000;*/
			}

		}
	}

	function loadContent()
	{
		app.removeComponent(loginApp);
		app.addComponent(mainApp);
		
		//
		prepareVersion();
		prepareForms();
		prepareHeader();
		prepareMetadatas();

		content = mainApp.findComponent("content", null, true);
		setCurrentForm("inbound");
	}

	function prepareMetadatas()
	{
		
		formSwitcher = mainApp.findComponent("formSwitcher", null, true);
		formSwitcher.onChange = onFormChanged;
		transactionIdTF = mainApp.findComponent("transactionID", TextField);
		
		transactionDateComp = mainApp.findComponent("TRANSACTION_WHEN", DropDown);
		transactionDateComp.onChange = (e)->(prepareTransactionDate());
		transcationHourComp = mainApp.findComponent("TRANSACTION_WHEN_HOURS", Stepper);
		transcationHourComp.onChange = (e)->(prepareTransactionDate());
		transcationMinutesComp = mainApp.findComponent("TRANSACTION_WHEN_MINUTES", Stepper);
		transcationMinutesComp.onChange = (e)->(prepareTransactionDate());
		
		agentTF = mainApp.findComponent("agentNt");
		agentTF.registerEvent(FocusEvent.FOCUS_OUT, onAgentFilledIn);

		coachEmail = mainApp.findComponent("coachemail", Label);
		coachEmail.htmlText = '<strong>${StringTools.replace(monitoring.coach.mbox, "mailto:","")}</strong>\n${monitoring.coach.title}';
		coachEmail.onClick = onCoachClicked;
		transactionSummary =  mainApp.findComponent("transactionsummary", TextArea);
		monitoringSummary =  mainApp.findComponent("monitoringsummary", TextArea);
		monitoringType = mainApp.findComponent("type", Group);
		monitoringReason = mainApp.findComponent("reason", Group);
		//monitoringType.onChange = (e)->(monitoringTypeValue = (e.target.id));
		monitoringType.onChange = (e)->(monitoring.data.set( Monitoring.MONITORING_TYPE, e.target.id));
		//monitoringReason.onChange = (e)->(monitoringReasonValue = (e.target.id));
		monitoringReason.onChange = (e)->(monitoring.data.set(Monitoring.MONITORING_REASON,e.target.id));
	}
	function resetMonitoring() 
	{
		
		cast(monitoringReason.getComponentAt(0), OptionBox).resetGroup();
		cast(monitoringType.getComponentAt(0), OptionBox).resetGroup();
		monitoringSummary.text = "";
		monitoring.reset();
	}
	
	function resetTransaction() 
	{
		transaction.reset();
		transactionDateComp.value = null;
		transcationHourComp.value = null;
		transcationMinutesComp.value = null;
		transactionIdTF.text = "";
		transactionSummary.text = "";
		 cast(monitoringReason.getComponentAt(0), OptionBox).resetGroup();
		 
	}
	
	function onCoachClicked(e:MouseEvent) 
	{
		cookie.clearCockie( version );
		Browser.location.reload(true);
	}

	function prepareHeader()
	{
		sendBtn = mainApp.findComponent("send");
			
		langSwitcher = mainApp.findComponent("langSwitcher", null, true);
		langSwitcher.onChange = onLangChanged;
		langSwitcher.disabled = true;

		sendBtn.onClick = onSend;
		whatToSend = mainApp.findComponent("sendAll", Switch);
		whatToSendLabel = mainApp.findComponent("slider2", Label);
		whatToSend.onChange = (e)->(whatToSendLabel.text = whatToSend.selected? "{{ALL}}" : "{{FAILED_ONLY}}");
	}

	function prepareForms()
	{
		forms = [];
		inbound = ComponentMacros.buildComponent("assets/ui/content/inbound.xml");
		mail = ComponentMacros.buildComponent("assets/ui/content/mail.xml");
		forms.set("inbound", inbound);
		forms.set("mail", mail);
	}

	function prepareVersion()
	{
		versionLabel = mainApp.findComponent("version", Label);
		versionLabel.text = "v " + version;
	}

	function onAgentFilledIn(e:FocusEvent):Void
	{
		#if debug
		if (_mainDebug)
		{
			if ( agentTF.text != null && agentTF.text != "")
				logger.search(agentTF.text);
		}
		else
		{
			var dummyMonotoree = Monitoree.CREATE_DUMMY();
			agentTF.text = dummyMonotoree.sAMAccountName;
			onLoginSuccess(dummyMonotoree);
		}
		#else
		if ( agentTF.text != null && agentTF.text !="" )
			logger.search(agentTF.text);
		#end
	}

	function onLoginClicked(e:MouseEvent)
	{
		loginFeedback.removeClass("error");
		try
		{
			logger.prepareCredentials(coachUsername.text, coachPWD.text);
			logger.send();
		}
		catch (e:Exception)
		{
			loginFeedback.addClass("error");
			loginFeedback.text = e.message;
		}
		catch (e:Dynamic)
		{
			loginFeedback.addClass("error");
			loginFeedback.text = e.message;
		}
	}

	function onSend(e)
	{
		//var resultCheck = prepareResults();
		var resultCheck = Question.PREPARE_RESULTS();
		var metaCheck = validateMetadatas();
		var message:Array<String> = metaCheck.message.concat(resultCheck.message);
		if (resultCheck.canSubmit && metaCheck.canSubmit)
		{
			//prepareTransactionDate();
			transaction.prepareData();
			tmMetadatas = Utils.addPrefixKey(Browser.location.origin +Browser.location.pathname, Utils.mergeMaps(transaction.data, monitoring.data));
			var score:Float = Question.GET_SCORE();
			var questionExtensions:Map<String,String> = Utils.addPrefixKey(Browser.location.origin, Question.RESULT_MAP);
			if (monitoring.data.get(Monitoring.MONITORING_REASON) == "calibration")
			{
				tracker.callibrationTracking(monitoring.coach, transaction.type, tmMetadatas, transaction.monitoree, score, Question.FAILED_CRITICAL.length == 0, lang, questionExtensions);
				
			}else{
				tracker.agentTracking(
				transaction.monitoree, 
				monitoring.coach,
				transaction.type, 
				tmMetadatas,
				score,
				Question.FAILED_CRITICAL.length == 0,
				questionExtensions, 
				lang);
			}
			
		}
		else
		{
			//if (message.length > 3 ) message.unshift('Come on ${coachAgent.firstName} apply yourself !');
			if (message.length > 3 ) message.unshift(LocaleManager.instance.lookupString("APPLY_YOURSELF",  monitoring.coach.firstName));
			dialog.message = message.join("\n");
			dialog.showDialog(true);
		}
	}
	function prepareTransactionDate()
	{
		var tmp = cast(transactionDateComp.value, Date);
		if (tmp != null)
		{
			transactionDate = Date.fromTime(tmp.getTime() + (transcationHourComp.value * 3600000) + (transcationMinutesComp.value * 60000));
			transaction.date = transactionDate;
		}
		//trace(tmp);
		//trace(transactionDate);
	}
	function validateMetadatas():Dynamic
	{
		var canSubmit = true;
		var message = [""];
		
		if (transactionIdTF.text == null || transactionIdTF.text.trim() == "")
		{
			canSubmit = false;
			message.push("{{ALERT_TRANSACTION_ID_NOT_SET}}");
		}
		else{
			#if debug
			trace("TMApp::validateMetadatas::transactionIdTF.text", transactionIdTF.text );
			#end
			transaction.id = transactionIdTF.text;
		}
		if (transaction.date == null || transaction.date.getFullYear() == 2000){
			canSubmit = false;
			message.push("{{ALERT_TRANSACTION_DATE_NOT_SET}}");
		}
		else{
			#if debug
			trace("TMApp::validateMetadatas::transactionDateComp.value", transaction.date );
			#end
			//transaction.data.set(Transaction.TRANSACTION_DATE, transaction.getDateISO());
		}
		if (agentTF.text == null || agentTF.text.trim() =="")
		{
            
			canSubmit = false;
			message.push("{{ALERT_AGENT_NOT_SEARCHED}}");
		}
		else if (transaction.monitoree == null || transaction.monitoree.mbox.indexOf("Unknown") > -1)
		{
			canSubmit = false;
			message.push("{{ALERT_AGENT_NOT_FOUND}}");
		}
		else{
			#if debug
			trace("TMApp::validateMetadatas::agentTF.text", agentTF.text );
			#end
		}
		if (transactionSummary.text == null || transactionSummary.text.trim() == "")
		{
			canSubmit = false;
			message.push("{{ALERT_TRANSACTION_SUMMARY}}");
		}
		else{
			this.transaction.summary = transactionSummary.text.trim();
		}
		
         if (transactionSummary.text == null || transactionSummary.text.trim() == "")
		{
			canSubmit = false;
			message.push("{{ALERT_TRANSACTION_SUMMARY}}");
		}
		else{
			this.transaction.summary = transactionSummary.text.trim();
		}
		 if (monitoringSummary.text == null || monitoringSummary.text.trim() == "")
		{
			canSubmit = false;
			message.push("{{ALERT_MONITORING_SUMMARY}}");
		}
		else{
			monitoring.data.set(Monitoring.MONITORING_SUMMARY,monitoringSummary.text.trim());
		}

		if (!monitoring.data.exists(Monitoring.MONITORING_REASON))
		{
			canSubmit = false;
			message.push("{{ALERT_MONITORING_REASON}}");
		}
		else{
			#if debug
			trace("TMApp::validateMetadatas::monitoring.data.exists(Monitoring.MONITORING_REASON)", monitoring.data.exists(Monitoring.MONITORING_REASON) );
			#end
		}
		if (!monitoring.data.exists(Monitoring.MONITORING_TYPE))
		{
			canSubmit = false;
			message.push("{{ALERT_MONITORING_TYPE}}");
		}
		else{
			#if debug
			trace("TMApp::validateMetadatas::monitoring.data.exists(Monitoring.MONITORING_TYPE)", monitoring.data.exists(Monitoring.MONITORING_TYPE) );
			#end
		}
		return {canSubmit:canSubmit, message: message};
	}
	function onFormChanged(e:UIEvent)
	{
		
		//var sw:Switch = cast(e.target, Switch);
		//var sl:Label = mainApp.findComponent("slider1");
		//var form = sw.selected ? "mail" :"inbound";
		var form = e.target.id;
		//sl.value = Std.string(form);
		content.removeComponentAt(1);

		setCurrentForm(form);
	}
	function setCurrentForm(id:String)
	{
		transaction.type = id;
		currentForm = forms.get(id);
		content.addComponentAt(currentForm, 1 );
		Question.GET_ALL(currentForm);
	}

	function onLangChanged(e:UIEvent)
	{
		var _box:OptionBox = cast(e.target, OptionBox);
		lang = _box.id;
	}

	function sendEmailToBoth(?previousStatement:StatementRef):Void
	{
		#if debug
		trace("TMApp::sendEmailToBoth");
		#end
		mailComposer.transaction = transaction;
		mailComposer.monitoring = monitoring;
		mailComposer.build(whatToSend.selected, previousStatement);
		mailComposer.send( Browser.location.origin.indexOf("salt.ch") > -1 );
	}
	
}