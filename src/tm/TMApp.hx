package tm;

import AppBase;
import Utils;
import data.Transaction;
import haxe.Exception;
import haxe.ui.events.FocusEvent;
import haxe.ui.events.MouseEvent;
import ldap.Attributes;
import roles.Actor;
import tm.TMMailer;
import tm.Info;
import tm.Question;
import tm.Tracker;
import tm.queries.TMAgregator;

import ui.AgentListing;
import ui.dialogs.Communicator;
//import ui.metadatas.TransactionUI;
import data.Monitoring;
import haxe.ui.components.CheckBox;
import haxe.ui.components.Image;
import haxe.ui.components.Button;
import haxe.ui.components.Label;
import haxe.ui.components.OptionBox;
import haxe.ui.components.DropDown;
import haxe.ui.components.TextArea;
import haxe.ui.components.TextField;
import haxe.ui.containers.Group;
import haxe.ui.components.NumberStepper;

import haxe.ui.containers.dialogs.MessageBox;
import haxe.ui.core.Component;
//import haxe.ui.events.FocusEvent;
//import haxe.ui.events.MouseEvent;
import haxe.ui.events.UIEvent;
import xapi.types.StatementRef;

import haxe.ui.locale.LocaleManager;
import haxe.ui.macros.ComponentMacros;
//import haxe.ui.parsers.locale.CSVParser;
//import haxe.ui.parsers.locale.LocaleParser;
import js.Browser;

//import haxe.ui.tooltips.ToolTipManager;
import http.MailHelper.Result;
using StringTools;

/**
 * ...
 * @author bb
 */
class TMApp extends AppBase
{
	// forms
	var currentForm:Component;
	var forms:Map<String, Component>;
	var content:Component;
	var inbound:Component;
	var outbound:Component;
	var mail:Component;
	var ticket:Component;
	var telesales:Component;
	// UI

	var versionLabel:Label;
	var tmMetadatas:Map<String, Dynamic>;
	var justifications:Array<TextArea>;
	var communicator:MessageBox;

	//var summaries:Array<TextArea>;
	var failedCriticals:Float;
	var failedOverall:Float;
	var countQuestions:Float;
	var whatToSend:CheckBox;

///////////////////////////////////////////////////////////
	var monitoringReasonValue:String;
	var monitoringTypeValue:String;
	var monitoringSummaryValue:String;
	var transactionSummaryValue:String;
	var agentLabel:Label;
	var agentOK:Image;
	var agentBtn:Label;
	var cctl:CheckBox;
	var cctl_text:Label;
///////////////////////////////////////////////////////////
	var formSwitcher: Group;
	var monitoringType:Group;
	var monitoringReason:Group;
	var transactionUI:Transaction;
	var agentlisting:AgentListing;
	var tracker:tm.Tracker;
	var mailComposer: tm.TMMailer;
	var monitoringGood:TextArea;
	var monitoringBad:TextArea;
	var agregator:TMAgregator;
	var sideBySide:OptionBox;
	var remote:OptionBox;
	var msummaryBAD:Label;
	var msummaryGOOD:Label;
	var msummaryOther:Label;
	var msummary:Label;
	var monitoringsummary:TextArea;

	var transactionSummary:TextArea;
	var monitoringSummary:TextArea;
	var transactionDateComp:DropDown;
	var transcationHourComp:NumberStepper;
	var transcationMinutesComp:NumberStepper;
	var transactionIdTF:TextField;
	public static inline var MONITORING_SUMMARY_GOOD:String = "monitoringsummaryGOOD";
	public static inline var MONITORING_SUMMARY_BAD:String = "monitoringsummaryBAD";

	//var info:Component;
	public function new()
	{
		super(TMMailer, tm.Tracker, "tm", true);

		currentForm = null;
		forms = new Map<String, Component>();
		//trace("start");
		tracker = cast(this.xapitracker, tm.Tracker);
		//trace("end");
		mailComposer = cast(this.mailHelper, TMMailer);
		tracker.signal.add(this.onXapiTracking) ;
		agregator = new TMAgregator();
		//cast(this.onXapiTracking, Tracker).signal.add(this.onXapiTracking) ;

		this.whenAppReady = loadContent;
		//this.loginApp.needsDirectReports = true;

		init();
	}
	function onXapiTracking(stage:Int)
	{
		if (stage == -1)
		{
			//trace("errror with the XAPI");
			debounce = true;
			#if debug
			if (!Main._mainDebug) sendEmailToBoth(tracker.monitoreeRecieved);
			#else
			#end
		}
		else if (stage == 1)
		{
			//var score = Question.GET_SCORE();
			//ENFOIRä corrige mois ça, car le tracking envoi que des agents tracking ! ! !;

			tracker.coachTracking( monitoringData.coach,transactionData.monitoree, transactionData.type, tm.Question.SCORE, tm.Question.FAILED_CRITICAL.length == 0, AppBase.lang, tmMetadatas);

		}
		else if (stage == 2)
		{
			sendEmailToBoth(tracker.monitoreeRecieved);
		}
	}

	override function onMailSucces(r:Result)
	{
		super.onMailSucces(r);
		//debounce = true;
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
			dialogEnd.onDialogClosed = (e)->reset();
			dialogEnd.showDialog(true);

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
		checkVersion();
		tracker.start();
		content.hidden = true;
		agentlisting.reset();
		swapContent(agentlisting);
		resetForm();
		resetTransaction();
		resetMonitoring();
		toggleSummary(false);
	}

	function resetForm()
	{
		tm.Question.RESET();

	}

	override function loadContent()
	{
		try
		{
			if (loginApp != null) app.removeComponent(loginApp);
			this.mainApp = ComponentMacros.buildComponent("assets/ui/main.xml");

			communicator = new Communicator();
			//mainApp = ComponentMacros.buildComponent("assets/ui/main.xml");
			app.addComponent(mainApp);

			//
			prepareVersion();
			prepareForms();
			prepareHeader();
			prepareMetadatas();

			markdownHelper.show();
			//markdownView.show();

			content = mainApp.findComponent("content", null, true);
			agentlisting = new AgentListing(monitoringData.coach);
			agentlisting.signal.add( onAgentListingChanged);
			agentlisting.signalAgent.add( onAgentSelectInList );
			agregator.signal.add( agentlisting.displayList );
			content.addComponent( agentlisting );
			//content.removeComponentAt(0,false);

			//agregator.getBasicTMThisMonth(monitoringData.coach.directReports);
			//agregator.signal.add(onTmFecteched);
		}
		catch (e)
		{
			trace(e);
		}
		//setCurrentForm("inbound");
	}

	function onAgentListingChanged(s:String)
	{
		#if debug
		trace("tm.TMApp::onAgentListingChanged::s", s );
		#end
		switch (s)
		{
			case 'myTmthisMonth' : agregator.getBasicTMThisMonth(monitoringData.coach.sAMAccountName);
			case 'myTmprevMonth' : agregator.getBasicTMThisMonth(monitoringData.coach.sAMAccountName, true);
			case 'myDrthisMonth' : agregator.getDirectReportsTMThisMonth(monitoringData.coach.directReports);
			case 'myDrprevMonth' : agregator.getDirectReportsTMThisMonth(monitoringData.coach.directReports, true);
			case _ : return;

		}
	}
	override function onLoginSuccess(agent:roles.Actor)
	{
		super.onLoginSuccess(agent);

		if (Std.isOfType(agent, roles.Monitoree ))
		{
			transactionData.monitoree = cast(agent, roles.Monitoree);

			resetAgent();
			if (transactionData.monitoree.authorised)
			{

				agentLabel.htmlText = '<strong class="correct">${StringTools.replace(transactionData.monitoree.mbox, "mailto:","")}</strong>\n${transactionData.monitoree.title}';
				agentLabel.addClass("correct");
				agentOK.resource = "images/check-green-icon.png";
				agentOK.hidden = false;

				if (transactionData.monitoree.manager != null)
				{
					cctl_text.text = StringTools.replace(transactionData.monitoree.manager.mbox, "mailto:", "");
					cctl.hidden = false;
					cctl_text.hidden = false;
				}
				else
				{
					cctl.hidden = true;
					cctl_text.hidden = true;
				}

				xapitracker.start();
			}
			else
			{

				agentOK.hidden = false;
				agentOK.resource = "images/check-red-icon.png";
				agentLabel.htmlText = '{{ERROR}} \n<strong class="error">${transactionData.monitoree.name}</strong>';
				agentLabel.addClass("error");
				/*agentLabel.color = 0xFF0000;*/
			}

			agentLabel.updateComponentDisplay();
		}
	}

	function toggleSummary(show:Bool)
	{
		sideBySide.hidden = show;
		msummary.hidden = show;
		msummaryOther.hidden = show;
		msummaryGOOD.hidden = show;
		msummaryBAD.hidden = show;
		monitoringsummary.hidden = show;
		monitoringGood.hidden = show;
		monitoringBad.hidden = show;
	}

	function onMonitoringReasonChanged(e)
	{
		var id = cast(e.target, Component).id;
		var isCallibration =   id == "calibration";
		cctl.hidden = cctl_text.hidden = ( isCallibration|| transactionData.monitoree == null || transactionData.monitoree.manager == null );

		if (isCallibration)
		{
			sideBySide.hidden = true;
			remote.selected = true;
		}
		toggleSummary(isCallibration);
		monitoringData.data.set(data.Monitoring.MONITORING_REASON, id);
	}
	/*override function resetMonitoring()
	{
		super.resetMonitoring();
		this.monitoringBad.text = "";
		this.monitoringGood.text = "";
		cast(monitoringReason.getComponentAt(0), OptionBox).resetGroup();
		cast(monitoringType.getComponentAt(0), OptionBox).resetGroup();
	}

	override function resetTransaction()
	{
		super.resetTransaction();
		cast(formSwitcher.getComponentAt(0), OptionBox).resetGroup();
	} */

	/**
	* @todo TEST refactor to sub class (TM)
	* @return
	*/
	function resetMonitoring()
	{
		this.monitoringBad.text = "";
		this.monitoringGood.text = "";
		cast(monitoringReason.getComponentAt(0), OptionBox).resetGroup();
		cast(monitoringType.getComponentAt(0), OptionBox).resetGroup();
		//
		monitoringSummary.text = "";
		monitoringData.reset();
	}
	/**
	* @todo refactor to sub class (TM)
	* @return
	*/
	function resetTransaction()
	{
		transactionData.reset();
		transactionDateComp.value = null;
		transactionDateComp.selectedIndex = -1;
		transactionDateComp.selectedItem= null;

		transcationHourComp.value = null;
		transcationMinutesComp.value = null;
		transactionIdTF.text = "";
		transactionSummary.text = "";

		resetAgent(true);

		cast(formSwitcher.getComponentAt(0), OptionBox).resetGroup();

	}

	override function prepareHeader()
	{
		super.prepareHeader();
		cctl = mainApp.findComponent("cctl", CheckBox);
		cctl_text = mainApp.findComponent("cctl_text", Label);
		whatToSend = mainApp.findComponent("sendAll", CheckBox);
		whatToSend.onChange = (e)->(whatToSend.text = whatToSend.selected? "{{ALL}}" : "{{FAILED_ONLY}}");
	}
	/*override function prepareMetadatas()
	{
		super.prepareMetadatas();
		formSwitcher = mainApp.findComponent("formSwitcher", null, true);
		formSwitcher.onChange = (e:UIEvent)->setCurrentForm(e.target.id);
		monitoringType = mainApp.findComponent("type", Group);
		monitoringReason = mainApp.findComponent("reason", Group);
		sideBySide = mainApp.findComponent("sideBySide", OptionBox);
		remote = mainApp.findComponent("remote", OptionBox);

		msummary = mainApp.findComponent("msummary", Label);
		msummaryOther = mainApp.findComponent("msummaryOther", Label);
		msummaryGOOD = mainApp.findComponent("msummaryGOOD", Label);
		msummaryBAD = mainApp.findComponent("msummaryBAD", Label);
		monitoringsummary = mainApp.findComponent("monitoringsummary", TextArea);
		monitoringGood = mainApp.findComponent(MONITORING_SUMMARY_GOOD, TextArea);
		monitoringBad = mainApp.findComponent(MONITORING_SUMMARY_BAD, TextArea);

		monitoringType.onChange = (e)->(monitoringData.data.set( data.Monitoring.MONITORING_TYPE, e.target.id));

		monitoringReason.onChange = onMonitoringReasonChanged;

	}*/
	/**
	* @todo TEST refactoring
	* @return
	*/
	function prepareMetadatas()
	{
		agentLabel = mainApp.findComponent("agentlabel", Label);
		agentOK = mainApp.findComponent("agewntOK", Image);

		transactionIdTF = mainApp.findComponent("transactionID", TextField);

		transactionDateComp = mainApp.findComponent("TRANSACTION_WHEN", DropDown);

		transactionDateComp.onChange = (e)->(prepareTransactionDate());
		transcationHourComp = mainApp.findComponent("TRANSACTIONWHENHOURS", NumberStepper, true, "id");

		transcationHourComp.onChange = (e)->(prepareTransactionDate());
		transcationMinutesComp = mainApp.findComponent("TRANSACTION_WHEN_MINUTES", NumberStepper);

		transcationMinutesComp.onChange = (e)->(prepareTransactionDate());

		agentBtn = mainApp.findComponent("agentBtn");
		agentTF = mainApp.findComponent("agentNt");
		agentTF.registerEvent(FocusEvent.FOCUS_OUT, onAgentFilledIn);
		agentBtn.onClick = onAgentClicked;

		coachEmail = mainApp.findComponent("coachemail", Label);
		coachEmail.htmlText = '<strong>${StringTools.replace(monitoringData.coach.mbox, "mailto:","")}</strong>\n${monitoringData.coach.title}';
		coachEmail.onClick = onCoachClicked;
		transactionSummary = mainApp.findComponent(Transaction.TRANSACTION_SUMMARY, TextArea);
		var transactionSummaryLabel = mainApp.findComponent("tsummary", Label);
		transactionSummaryLabel.onClick = (e)->(markdownHelper.show());
		var monitoringSummaryLabel = mainApp.findComponent("msummary", Label);
		monitoringSummaryLabel.onClick = (e)->(markdownHelper.show() );

		monitoringSummary =  mainApp.findComponent(Monitoring.MONITORING_SUMMARY, TextArea);
		//----------------------------------------------------------//	
		formSwitcher = mainApp.findComponent("formSwitcher", null, true);
		formSwitcher.onChange = (e:UIEvent)->setCurrentForm(e.target.id);
		monitoringType = mainApp.findComponent("type", Group);
		monitoringReason = mainApp.findComponent("reason", Group);
		sideBySide = mainApp.findComponent("sideBySide", OptionBox);
		remote = mainApp.findComponent("remote", OptionBox);

		msummary = mainApp.findComponent("msummary", Label);
		msummaryOther = mainApp.findComponent("msummaryOther", Label);
		msummaryGOOD = mainApp.findComponent("msummaryGOOD", Label);
		msummaryBAD = mainApp.findComponent("msummaryBAD", Label);
		monitoringsummary = mainApp.findComponent("monitoringsummary", TextArea);
		monitoringGood = mainApp.findComponent(MONITORING_SUMMARY_GOOD, TextArea);
		monitoringBad = mainApp.findComponent(MONITORING_SUMMARY_BAD, TextArea);

		monitoringType.onChange = (e)->(monitoringData.data.set( data.Monitoring.MONITORING_TYPE, e.target.id));

		monitoringReason.onChange = onMonitoringReasonChanged;

	}
	function prepareForms()
	{
		forms = [];
		tm.Question.INFO = new tm.Info(mainApp.findComponent("info"));
		inbound = ComponentMacros.buildComponent("assets/ui/content/inbound.xml");
		mail = ComponentMacros.buildComponent("assets/ui/content/mail.xml");
		telesales = ComponentMacros.buildComponent("assets/ui/content/telesales.xml");
		ticket = ComponentMacros.buildComponent("assets/ui/content/ticket.xml");
		telesales = ComponentMacros.buildComponent("assets/ui/content/telesales.xml");
		forms.set("inbound", inbound);
		forms.set("mail", mail);
		forms.set("ticket", ticket);
		forms.set("telesales", telesales);
	}

	function prepareVersion()
	{
		versionLabel = mainApp.findComponent("version", Label);
		versionLabel.text = "v" + versionHelper.cachedVersion;
	}

	/**
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
	 **/
	override function onSend(e)
	{
		//super.onSend(e);
		if (!debounce) return;

		submitor = validateMetadatas();
		var resultCheck = tm.Question.PREPARE_RESULTS();
		this.submitor.messages = this.submitor.messages.concat(resultCheck.messages);
		this.submitor.canSubmit =  this.submitor.canSubmit && resultCheck.canSubmit;
		if (this.submitor.canSubmit)
		{
			debounce = false;
			transactionData.prepareData();

			// PREPARE XAPI METADATA EXTENSIONS
			tmMetadatas = Utils.addPrefixKey(
							  Browser.location.origin +Browser.location.pathname,
							  Utils.mergeMaps(
								  Utils.mergeMaps( transactionData.data, monitoringData.data ),
								  Utils.stringyfyMap(tm.Question.CRITICALITY_MAP)
							  )
						  );

			// PREPARE QUESTION EXTENSIONS
			var questionExtensions:Map<String,String> = Utils.addPrefixKey(Browser.location.origin + Browser.location.pathname, tm.Question.RESULT_MAP);

			if (monitoringData.data.get(data.Monitoring.MONITORING_REASON) == "calibration")
			{
				// CALIBRATION
				tracker.callibrationTracking(
					monitoringData.coach,
					transactionData.type,
					tmMetadatas,
					transactionData.monitoree,
					tm.Question.SCORE,
					tm.Question.TM_PASSED,
					AppBase.lang,
					questionExtensions);

			}
			else
			{
				// TM AGENT TRACK
				tracker.agentTracking(
					transactionData.monitoree,
					monitoringData.coach,
					transactionData.type,
					tmMetadatas,
					tm.Question.SCORE,
					tm.Question.TM_PASSED,
					questionExtensions,
					AppBase.lang);
			}

		}
		else
		{
			this.submitor.messages.unshift(LocaleManager.instance.lookupString("DIALOG_APPLY_YOURSELF",  monitoringData.coach.firstName));
			communicator.message = this.submitor.messages.join("\n\n");
			communicator.showDialog(true);
		}
	}
	/**
	* @todo TEST refactor to sub class (TM)
	* @return
	*/
	function resetAgent(?fromscratch:Bool=false)
	{
		cctl.hidden = true;
		cctl_text.hidden = true;
		cctl.selected = false;
		agentLabel.removeClass("error");
		agentLabel.removeClass("correct");
		agentOK.hidden = true;
		if (fromscratch)
		{
			agentTF.text = "";
			agentLabel.htmlText = "";
		}
	}
	/**
	* @todo TEST refactor to sub class (TM)
	* @return
	*/
	function onCoachClicked(e:MouseEvent)
	{
		cookie.clearCockie( versionHelper.getFullVersion() );
		Browser.location.reload(true);
	}
	/**
	* @todo TEST refactor to sub class (TM)
	* @return
	*/
	function onAgentClicked(e:MouseEvent):Void
	{
		checkAgent();
	}
	/**
	* @todo TEST refactor to sub class (TM)
	* @return
	*/
	function onAgentFilledIn(e:FocusEvent):Void
	{
		checkAgent();
	}
	/**
	* @todo TEST refactor to sub class (TM)
	* @return
	*/
	function onAgentSelectInList(s:String)
	{
		agentTF.text = s;
		#if debug
		trace('TMApp::onAgentSelectInList::s ${s}');
		#end
		checkAgent();
	}
	/**
	* @todo TEST refactor to sub class (TM)
	* @return
	*/
	function checkAgent():Void
	{
		#if debug
		trace("AppBase::checkAgent");
		#end
		#if debug
		if (Main._mainDebug)
		{
			if ( agentTF.text != null && agentTF.text != "")
			{
				transactionData.monitoree = null;
				logger.searchAgent(agentTF.text, false);
			}
		}
		else
		{
			var dummyMonotoree = roles.Monitoree.CREATE_DUMMY(agentTF.text);
			onLoginSuccess(dummyMonotoree);
		}
		#else
		if ( agentTF.text != null && agentTF.text != "" )
		{
			transactionData.monitoree = null;
			logger.searchAgent(agentTF.text, false);
		}
		#end

	}

	/**
	* @todo TEST refactor to sub class (TM)
	* @return
	*/
	function prepareTransactionDate()
	{
		var tmp = cast(transactionDateComp.value, Date);
		if (tmp != null)
		{
			transactionData.date = Date.fromTime(tmp.getTime() + (transcationHourComp.value * 3600000) + (transcationMinutesComp.value * 60000));
		}

	}

	function validateMetadatas():Utils.Status
	{
		var s = {canSubmit:true, messages: []};
		var monitoringReasonExists = monitoringData.data.exists(data.Monitoring.MONITORING_REASON);
		var monitoringReasonIsCall = false;
		var canSubmit = true;
		var message = [];
		if (transactionIdTF.text == null || transactionIdTF.text.trim() == "")
		{
			s.canSubmit = false;
			s.messages.push("{{ALERT_TRANSACTION_ID_NOT_SET}}");
		}
		else{
			#if debug
			//trace("TMApp::validateMetadatas::transactionIdTF.text", transactionIdTF.text );
			#end
			transactionData.id = transactionIdTF.text;
		}

		if (agentTF.text == null || agentTF.text.trim() =="")
		{

			s.canSubmit = false;
			s.messages.push("{{ALERT_AGENT_NOT_SEARCHED}}");
		}
		else if (transactionData.monitoree == null || transactionData.monitoree.mbox.indexOf("error@salt.ch") > -1)
		{
			s.canSubmit = false;
			s.messages.push("{{ALERT_AGENT_NOT_FOUND}} ("+agentTF.text+")");
		}
		else{
			#if debug
			//trace("TMApp::validateMetadatas::agentTF.text", agentTF.text );
			//trace("TMApp::validateMetadatas::agentTF.text",transaction.monitoree );
			#end
		}
		if (transactionData.date.getFullYear() == 2000)
		{
			s.canSubmit = false;
			s.messages.push("{{ALERT_TRANSACTION_DATE_NOT_SET}}");
		}
		else if (transactionData.date.getTime() > Date.now().getTime())
		{
			s.canSubmit = false;
			s.messages.push("{{ALERT_TRANSACTION_FUTURR_DATE}}");
		}
		if (transactionSummary.text == null || transactionSummary.text.trim() == "")
		{
			s.canSubmit = false;
			s.messages.push("{{ALERT_TRANSACTION_SUMMARY}}");
		}
		else{
			this.transactionData.summary = transactionSummary.text.trim();
		}

		//return {canSubmit:canSubmit, messages: message};
		if (transactionData.type == "")
		{
			s.canSubmit = false;
			s.messages.push("{{ALERT_TRANSACTION_TYPE}}");
		}

		if (!monitoringReasonExists)
		{
			s.canSubmit = false;
			s.messages.push("{{ALERT_MONITORING_REASON}}");
		}
		else{
			monitoringReasonIsCall = monitoringData.data.get(data.Monitoring.MONITORING_REASON) == "calibration";
			#if debug
			//trace("TMApp::validateMetadatas::monitoring.data.exists(Monitoring.MONITORING_REASON)", monitoring.data.exists(Monitoring.MONITORING_REASON) );
			#end
		}
		if (!monitoringData.data.exists(data.Monitoring.MONITORING_TYPE))
		{
			s.canSubmit = false;
			s.messages.push("{{ALERT_MONITORING_TYPE}}");
		}
		else{
			#if debug
			//trace("TMApp::validateMetadatas::monitoring.data.exists(Monitoring.MONITORING_TYPE)", monitoring.data.exists(Monitoring.MONITORING_TYPE) );
			#end
		}
		if (monitoringSummary.text == null || monitoringSummary.text.trim() == "")
		{
			if (!monitoringReasonIsCall)
			{
				canSubmit = false;
				message.push("{{ALERT_MONITORING_SUMMARY}}");
			}
		}
		else{
			monitoringData.data.set(data.Monitoring.MONITORING_SUMMARY,monitoringSummary.text.trim());
		}
		if (monitoringGood.text == null || monitoringGood.text.trim() == "")
		{
			if (!monitoringReasonIsCall)
			{
				s.canSubmit = false;
				s.messages.push( "{{ALERT_MONITORING_SUMMARY_GOOD}}");
			}
		}
		else{
			monitoringData.data.set(MONITORING_SUMMARY_GOOD, monitoringGood.text.trim());
		}
		if (monitoringBad.text == null || monitoringBad.text.trim() == "" )
		{
			if (!monitoringReasonIsCall)
			{
				s.canSubmit = false;
				s.messages.push( "{{ALERT_MONITORING_SUMMARY_BAD}}");
			}
		}
		else{
			monitoringData.data.set(MONITORING_SUMMARY_BAD, monitoringBad.text.trim());
		}
		return s;
	}
	/*function onFormChanged(e:UIEvent)
	{
		setCurrentForm(e.target.id);
	}*/
	function setCurrentForm(id:String)
	{
		#if debug
		//trace('TMApp::setCurrentForm::id ${id}');
		#end
		tm.Question.INFO.reset();

		transactionData.type = id;
		currentForm = forms.get(id);
		swapContent(currentForm);
		tm.Question.GET_ALL(currentForm);
		//LocaleManager.instance.language = "en";
		LocaleManager.instance.language = AppBase.lang;
	}
	function swapContent(c:Component, ?hide:Bool=false )
	{
		content.removeComponentAt(0,false);
		content.addComponentAt(c, 0 );
		c.fadeIn();
		content.hidden = hide;
	}

	function sendEmailToBoth(?previousStatement:StatementRef):Void
	{
		#if debug
		trace("tm.TMApp::sendEmailToBoth");
		#end
		tm.Question.INFO.reset();

		mailComposer.cctl = cctl.selected;
		mailComposer.transaction = transactionData;
		mailComposer.monitoring = monitoringData;

		mailComposer.build(whatToSend.selected, previousStatement, versionHelper.getFullVersion());
		super.sendEmail();

	}

}