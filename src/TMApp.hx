package;
import haxe.Exception;
import haxe.ui.HaxeUIApp;
import haxe.ui.components.NumberStepper;
//import haxe.ui.Toolkit;
import haxe.ui.components.CheckBox;
import haxe.ui.components.Image;
//import haxe.ui.components.Stepper;
//import haxe.ui.focus.FocusManager;
//import haxe.ui.Toolkit;
//import haxe.ui.ToolkitAssets;
//import haxe.ui.assets.AssetPlugin;
import haxe.ui.components.Button;
import haxe.ui.components.Label;
import haxe.ui.components.OptionBox;
import haxe.ui.components.DropDown;
//import haxe.ui.components.Slider;
//import haxe.ui.components.Switch;
import haxe.ui.components.TextArea;
import haxe.ui.components.TextField;
import haxe.ui.containers.Group;
//import haxe.ui.containers.dialogs.Dialog;
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
//import js.Browser;
//import js.Cookie;
//import js.Lib;
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
	//var agreements:Array<Group>;
	var currentForm:Component;

	var tmMetadatas:Map<String, Dynamic>;
	var justifications:Array<TextArea>;
	var app:haxe.ui.HaxeUIApp;
	var dialog:MessageBox;
	//var criticals:Array<String>;
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
	var whatToSend:CheckBox;
	//var whatToSendLabel:Label;
	var _mainDebug:Bool;
	var comonLibs:String;
	var xapi:XapiHelper;
	//var form_id:String;
	var tracker:Tracker;
	var transaction:Transaction;
	var monitoring:Monitoring;
	public static var lang:String;
	var transactionDateComp:DropDown;
	var transcationHourComp:NumberStepper;
	var transcationMinutesComp:NumberStepper;
	//var transactionDate:Date;
	var transactionIdTF:TextField;
	var monitoringType:Group;
	var monitoringReason:Group;
	var agentLabel:Label;
	//var agentLabel:Label;
	var agentOK:Image;
	var agentBtn:Label;
	var cctl:CheckBox;
	var preloader:haxe.ui.components.Image;
	var cctl_text:Label;
	var debounce:Bool;
	
	//var info:Component;
	public function new()
	{
		/*********************
		 * INIT BASIC APP VARS
		 * ********************/
		debounce = true;
		currentForm = null;
		forms = new Map<String, Component>();
		_mainDebug = Browser.location.origin.indexOf("salt.ch") > -1;
		init = false;
		comonLibs = Browser.location.origin + "/commonlibs/";		
		/******************************************************
		 * INIT AJX HElpers
		 * ****************************************************/
		
		logger = new LoginHelper(comonLibs+"login/index.php");
		logger.successSignal.add(onLoginSuccess);
		//
		tracker = new Tracker(comonLibs + "xapi/index.php");
		tracker.dispatcher.add(onTracking);
		//
		mailComposer = new TMMailer(comonLibs + "mail/index.php");
		mailComposer.successSignal.add(onMailSucces);
		#if debug
		version = "TM_COOKIE";
		#else
		version = VersionHelper.getVersion("TM").replace("TM_", "");
		#end
		cookie = new CookieHelper(version);
		/***********************************************************
		 * INIT LOCALIZATION
		 * *********************************************************/
		LocaleParser.register("csv", CSVParser);
		LocaleManager.instance.language = "en";		
		
		app = new HaxeUIApp();
		
		app.ready(function()
		{
			ToolTipManager.defaultDelay = 100;
			transaction = new Transaction();
			monitoring = new Monitoring();
			
			dialog = new MessageBox();
			dialog.type = MessageBoxType.TYPE_WARNING;
			dialog.width = 560;
			dialog.height = 560;
			dialog.draggable = false;
			dialog.destroyOnClose = false;
			mainApp = ComponentMacros.buildComponent("assets/ui/main.xml");
			loginApp = ComponentMacros.buildComponent("assets/ui/login.xml");
            preloader = new Image();
		preloader.resource = "images/loader3.gif";
			try
			{
				monitoring.coach = cookie.retrieve();
				loadContent();
			}
			catch (e:Exception)
			{

				#if debug
				//trace("Main::Main::e", e );
                // get coach from cookie or create a dummy
				if (!_mainDebug) monitoring.coach = Coach.CREATE_DUMMY();

				#else
				//coachAgent = cookie.retrieve(version);
				
				#end
				prepareLogin( monitoring.coach );
				
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
			debounce = true;
		}
		else if (stage == 1)
		{
			//var score = Question.GET_SCORE();
			tracker.coachTracking( monitoring.coach,transaction.monitoree, transaction.type, Question.GET_SCORE(), Question.FAILED_CRITICAL.length == 0, lang, tmMetadatas);

		}
		else if (stage == 2)
		{
			sendEmailToBoth(tracker.coachRecieved);
			
		}
	}

	function onMailSucces(r:Result)
	{

		debounce = true;
		mainApp.removeComponent(preloader,false);
        var dialogEnd = new MessageBox();
		
		if (r.status == "success")
		{
			
			dialogEnd.width = 560;
			dialogEnd.height = 560;
			dialogEnd.draggable = false;
			dialogEnd.type = MessageBoxType.TYPE_INFO;
			dialogEnd.message = "{{DIALOG_MSG_SUCCESS_TRUE}}";
			dialogEnd.title = "{{DIALOG_TITLE_SUCCESS_TRUE}}";
		}
		else
		{
			//var dialogError = new MessageBox();
			dialogEnd.width = 560;
			dialogEnd.height = 560;
			dialogEnd.draggable = false;
			dialogEnd.type = MessageBoxType.TYPE_ERROR;
			dialogEnd.message = "{{DIALOG_MSG_SUCCESS_FALSE}}";
			dialogEnd.title = "{{DIALOG_TITLE_SUCCESS_FALSE}}";
		}
		try
		{
			#if debug
			trace("Main::onMailSucces::s", r, dialogEnd.message );
			#end
			dialogEnd.showDialog(true);
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
		content.hidden = true;
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
		#if debug
		//trace("TMApp::prepareLogin", loginApp.disabled, loginApp.isComponentInvalid(), loginApp.numComponents, loginApp.depth);
		#end
		
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
		loginBtn.onClick = onLoginClicked;
		#if debug
		if (!_mainDebug) loginBtn.onClick = (e)->(onLoginSuccess(monitoring.coach));
		#end
		// SHOW the LOGIN PAGE
		app.addComponent(loginApp);
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

			resetAgent();
			if (transaction.monitoree.authorised)
			{
				
				agentLabel.htmlText = '<strong class="correct">${StringTools.replace(transaction.monitoree.mbox, "mailto:","")}</strong>\n${transaction.monitoree.title}';
				/*agentLabel.color = 0x65a63c;*/
				agentLabel.addClass("correct");
				agentOK.resource = "images/check-green-icon.png";
				agentOK.hidden = false;
				
				if (transaction.monitoree.manager != null)
				{
					cctl_text.text = StringTools.replace(transaction.monitoree.manager.mbox, "mailto:", "");
					cctl.hidden = false;
					cctl_text.hidden = false;
				}else{
					cctl.hidden = true;
					cctl_text.hidden = true;
				}
				
				tracker.start();
			}
			else
			{
				
				agentOK.hidden = false;
				agentOK.resource = "images/check-red-icon.png";
				agentLabel.htmlText = '{{ERROR}} \n<strong class="error">${transaction.monitoree.name}</strong>';
				agentLabel.addClass("error");
				/*agentLabel.color = 0xFF0000;*/
			}
             #if debug
			//trace("TMApp::onLoginSuccess::agentLabel.hidden", agentLabel.hidden );
			//trace("TMApp::onLoginSuccess::agentLabel.text", agentLabel.htmlText);
			#end
			agentLabel.updateComponentDisplay();
		}
	}
    function resetAgent(?fromscratch:Bool=false)
	{
		cctl.hidden = true;
		cctl_text.hidden = true;
		cctl.selected = false;
		agentLabel.removeClass("error");
		agentLabel.removeClass("correct");
		agentOK.hidden = true;
		if (fromscratch) {
			agentTF.text = "";
			agentLabel.htmlText = "";
		}
	}
	function loadContent()
	{
		app.removeComponent(loginApp,false);
		app.addComponent(mainApp);

		//
		prepareVersion();
		prepareForms();
		prepareHeader();
		prepareMetadatas();

		content = mainApp.findComponent("content", null, true);
		//setCurrentForm("inbound");
	}

	function prepareMetadatas()
	{
		#if debug
		trace("TMApp::prepareMetadatas");
		#end
        agentLabel = mainApp.findComponent("agentlabel", Label);
		agentOK = mainApp.findComponent("agewntOK", Image);
		formSwitcher = mainApp.findComponent("formSwitcher", null, true);
		formSwitcher.onChange = (e:UIEvent)->setCurrentForm(e.target.id);
		transactionIdTF = mainApp.findComponent("transactionID", TextField);

		transactionDateComp = mainApp.findComponent("TRANSACTION_WHEN", DropDown);
		#if debug
		var testTDate  = transactionDateComp == null;
		trace("TMApp::prepareMetadatas::transactionDateComp", testTDate );
		#end
		#if debug
		//trace("TMApp::prepareMetadatas::transactionDateComp selectedIndex", transactionDateComp.selectedIndex  );
		//trace("TMApp::prepareMetadatas::transactionDateComp selectedItem", transactionDateComp.selectedItem);
		#end
		transactionDateComp.onChange = (e)->(prepareTransactionDate());
		transcationHourComp = mainApp.findComponent("TRANSACTIONWHENHOURS", NumberStepper, true, "id");
		#if debug
		var testTHour  = transcationHourComp == null;
		trace("TMApp::prepareMetadatas::transcationHourComp", testTHour );
		#end
		transcationHourComp.onChange = (e)->(prepareTransactionDate());
		transcationMinutesComp = mainApp.findComponent("TRANSACTION_WHEN_MINUTES", NumberStepper);
		#if debug
		//trace("TMApp::prepareMetadatas::transcationMinutesComp", transcationMinutesComp, transcationMinutesComp == null );
		#end
		transcationMinutesComp.onChange = (e)->(prepareTransactionDate());

		agentBtn = mainApp.findComponent("agentBtn");
		agentTF = mainApp.findComponent("agentNt");
		agentTF.registerEvent(FocusEvent.FOCUS_OUT, onAgentFilledIn);
		agentBtn.onClick = onAgentClicked;

		coachEmail = mainApp.findComponent("coachemail", Label);
		coachEmail.htmlText = '<strong>${StringTools.replace(monitoring.coach.mbox, "mailto:","")}</strong>\n${monitoring.coach.title}';
		coachEmail.onClick = onCoachClicked;
		transactionSummary =  mainApp.findComponent("transactionsummary", TextArea);
		
		monitoringSummary =  mainApp.findComponent("monitoringsummary", TextArea);
		monitoringType = mainApp.findComponent("type", Group);
		monitoringReason = mainApp.findComponent("reason", Group);
		//monitoringType.onChange = (e)->(monitoringTypeValue = (e.target.id));
		monitoringType.onChange = (e)->(monitoring.data.set( Monitoring.MONITORING_TYPE, e.target.id));
		//monitoringReason.onChange = (e)->(monitoring.data.set(Monitoring.MONITORING_REASON,e.target.id));
		monitoringReason.onChange = onMonitoringReasonChanged;
	}
    function onMonitoringReasonChanged(e)
	{
		var id = cast(e.target, Component).id;
		cctl.hidden = cctl_text.hidden = (id == "calibration" || transaction.monitoree == null || transaction.monitoree.manager ==null );
		monitoring.data.set(Monitoring.MONITORING_REASON, id);
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
		transactionDateComp.selectedIndex = -1;
		transactionDateComp.selectedItem= null;
		
		transcationHourComp.value = null;
		transcationMinutesComp.value = null;
		transactionIdTF.text = "";
		transactionSummary.text = "";
		//transactionSummary.au
		
		resetAgent(true);
		
		cast(formSwitcher.getComponentAt(0), OptionBox).resetGroup();

	}

	function onCoachClicked(e:MouseEvent)
	{
		cookie.clearCockie( version );
		Browser.location.reload(true);
	}

	function prepareHeader()
	{
		sendBtn = mainApp.findComponent("send",Button);

		langSwitcher = mainApp.findComponent("langSwitcher", null, true);
		langSwitcher.onChange = onLangChanged;
		//langSwitcher.disabled = true;

		sendBtn.onClick = onSend;
		whatToSend = mainApp.findComponent("sendAll", CheckBox);
		cctl = mainApp.findComponent("cctl", CheckBox);
		cctl_text = mainApp.findComponent("cctl_text", Label);
		//whatToSendLabel = mainApp.findComponent("slider2", Label);
		whatToSend.onChange = (e)->(whatToSend.text = whatToSend.selected? "{{ALL}}" : "{{FAILED_ONLY}}");
	}

	function prepareForms()
	{
		forms = [];
		Question.INFO = new Info(mainApp.findComponent("info"));
		inbound = ComponentMacros.buildComponent("assets/ui/content/inbound.xml");
		mail = ComponentMacros.buildComponent("assets/ui/content/mail.xml");
		ticket = ComponentMacros.buildComponent("assets/ui/content/case.xml");
		forms.set("inbound", inbound);
		forms.set("mail", mail);
		forms.set("case", ticket);
	}

	function prepareVersion()
	{
		versionLabel = mainApp.findComponent("version", Label);
		versionLabel.text = "v " + version;
	}

	function onAgentClicked(e:MouseEvent):Void
	{
		checkAgent();
	}
	function onAgentFilledIn(e:FocusEvent):Void
	{
		checkAgent();
	}
	 function checkAgent():Void
	{
		#if debug
		if (_mainDebug)
		{
			if ( agentTF.text != null && agentTF.text != "")
			{
				transaction.monitoree = null;
				logger.search(agentTF.text);
			}
		}
		else
		{
			var dummyMonotoree = Monitoree.CREATE_DUMMY();
			agentTF.text = dummyMonotoree.sAMAccountName;
			onLoginSuccess(dummyMonotoree);
		}
		#else
		if ( agentTF.text != null && agentTF.text != "" )
		{
			transaction.monitoree = null;
			logger.search(agentTF.text);
		}
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
		if (!debounce) return;
		var resultCheck = Question.PREPARE_RESULTS();
		var metaCheck = validateMetadatas();
		var message:Array<String> = metaCheck.message.concat(resultCheck.message);
		if (resultCheck.canSubmit && metaCheck.canSubmit)
		{
			//prepareTransactionDate();
			debounce = false;
			transaction.prepareData();
			var criticalMap = Utils.stringyfyMap(Question.CRITICALITY_MAP);
			var metadataMap = Utils.mergeMaps(transaction.data, monitoring.data);
			metadataMap =  Utils.mergeMaps( metadataMap , criticalMap);
			tmMetadatas = Utils.addPrefixKey(Browser.location.origin +Browser.location.pathname, metadataMap );
			var score = Question.GET_SCORE();
			var questionExtensions:Map<String,String> = Utils.addPrefixKey(Browser.location.origin+Browser.location.pathname, Question.RESULT_MAP);
			if (monitoring.data.get(Monitoring.MONITORING_REASON) == "calibration")
			{
				tracker.callibrationTracking(monitoring.coach, transaction.type, tmMetadatas, transaction.monitoree, score, Question.FAILED_CRITICAL.length == 0, lang, questionExtensions);

			}
			else
			{
				tracker.agentTracking(
					transaction.monitoree,
					monitoring.coach,
					transaction.type,
					tmMetadatas,
					score,
					(Question.FAILED_CRITICAL.length == 0 || Question.GET_SCORE().scaled>Question.MIN_PERCENTAGE_BEFORE_FAILLING),
					questionExtensions,
					lang);
			}

		}
		else
		{
			if (message.length > 3 ) message.unshift(LocaleManager.instance.lookupString("DIALOG_APPLY_YOURSELF",  monitoring.coach.firstName));
			dialog.message = message.join("\n\n");
			dialog.showDialog(true);
		}
	}
	function prepareTransactionDate()
	{
		var tmp = cast(transactionDateComp.value, Date);
		if (tmp != null)
		{
			//transactionDate = Date.fromTime(tmp.getTime() + (transcationHourComp.value * 3600000) + (transcationMinutesComp.value * 60000));
			transaction.date = Date.fromTime(tmp.getTime() + (transcationHourComp.value * 3600000) + (transcationMinutesComp.value * 60000));
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
			//trace("TMApp::validateMetadatas::transactionIdTF.text", transactionIdTF.text );
			#end
			transaction.id = transactionIdTF.text;
		}
		if (agentTF.text == null || agentTF.text.trim() =="")
		{

			canSubmit = false;
			message.push("{{ALERT_AGENT_NOT_SEARCHED}}");
		}
		else if (transaction.monitoree == null || transaction.monitoree.mbox.indexOf("error@salt.ch") > -1)
		{
			canSubmit = false;
			message.push("{{ALERT_AGENT_NOT_FOUND}} ("+agentTF.text+")");
		}
		else{
			#if debug
			//trace("TMApp::validateMetadatas::agentTF.text", agentTF.text );
			//trace("TMApp::validateMetadatas::agentTF.text",transaction.monitoree );
			#end
		}
		if (transaction.date == null || transaction.date.getFullYear() == 2000)
		{
			canSubmit = false;
			message.push("{{ALERT_TRANSACTION_DATE_NOT_SET}}");
		}
		else{
			#if debug
			//trace("TMApp::validateMetadatas::transactionDateComp.value", transaction.date );
			#end
			//transaction.data.set(Transaction.TRANSACTION_DATE, transaction.getDateISO());
		}
		
		if (transactionSummary.text == null || transactionSummary.text.trim() == "")
		{
			canSubmit = false;
			message.push("{{ALERT_TRANSACTION_SUMMARY}}");
		}
		else{
			this.transaction.summary = transactionSummary.text.trim();
		}

		/*if (transactionSummary.text == null || transactionSummary.text.trim() == "")
		{
			canSubmit = false;
			message.push("{{ALERT_TRANSACTION_SUMMARY}}");
		}
		else{
			this.transaction.summary = transactionSummary.text.trim();
		}*/
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
			//trace("TMApp::validateMetadatas::monitoring.data.exists(Monitoring.MONITORING_REASON)", monitoring.data.exists(Monitoring.MONITORING_REASON) );
			#end
		}
		if (!monitoring.data.exists(Monitoring.MONITORING_TYPE))
		{
			canSubmit = false;
			message.push("{{ALERT_MONITORING_TYPE}}");
		}
		else{
			#if debug
			//trace("TMApp::validateMetadatas::monitoring.data.exists(Monitoring.MONITORING_TYPE)", monitoring.data.exists(Monitoring.MONITORING_TYPE) );
			#end
		}
		return {canSubmit:canSubmit, message: message};
	}
	/*function onFormChanged(e:UIEvent)
	{
		setCurrentForm(e.target.id);
	}*/
	function setCurrentForm(id:String)
	{
		Question.INFO.reset();
		
		transaction.type = id;
		currentForm = forms.get(id);
		content.removeComponentAt(0,false);
		content.addComponentAt(currentForm, 0 );
		content.hidden = false;
		Question.GET_ALL(currentForm);
		LocaleManager.instance.language = "en";
		LocaleManager.instance.language = lang;
	}

	function onLangChanged(e:UIEvent)
	{
		var _box:OptionBox = cast(e.target, OptionBox);
		lang = _box.id;
		LocaleManager.instance.language = lang;
		//LocaleManager.instance.language = "en";
	}

	function sendEmailToBoth(?previousStatement:StatementRef):Void
	{
		#if debug
		//trace("TMApp::sendEmailToBoth");
		#end
		//dialog.message = "Wait...";
		//dialog.showDialog(true);
		Question.INFO.reset();
		preloader.width = 250;
		preloader.height = 140;
		preloader.verticalAlign ="center";
		
		mainApp.addComponent(preloader);
		
		mailComposer.cctl = cctl.selected;
		mailComposer.transaction = transaction;
		mailComposer.monitoring = monitoring;
		mailComposer.build(whatToSend.selected, previousStatement, version);
		mailComposer.send( Browser.location.origin.indexOf("salt.ch") > -1 );
	}

}