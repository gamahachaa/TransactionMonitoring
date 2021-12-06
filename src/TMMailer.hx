package;
import data.Monitoring;
import data.Transaction;
import haxe.ui.locale.LocaleManager;
import http.MailHelper;
import xapi.types.StatementRef;

/**
 * ...
 * @author bb
 */
/*typedef Agreement =
{
	var choice:String;
	var justification:String;
	var critical:Bool;
}*/
class TMMailer extends http.MailHelper
{
	static inline var CUSTOM_RULES:String = ".critical{color:#EC9A29;} .AGREE{color:#81c14b;} .DISAGREE{color:#f05365;}";
	var reason:String;
	var isCalibration:Bool;
	var currentTopic:String;
	public var cctl(default, set):Bool;
	public var transaction:data.Transaction;
	public var monitoring:data.Monitoring;

	

	public function new(url:String, ?transaction:data.Transaction, ?monitoring:data.Monitoring)
	{
		super(url);
		this.transaction = transaction;
		this.monitoring = monitoring;
		
	}
	public function build(all:Bool, ?previousStatement:StatementRef, ?version:String="")
	{
		reason = monitoring.data.get(data.Monitoring.MONITORING_REASON);
		isCalibration = reason == "calibration" ;
		prepareHeader();
		setBody(prepareBody(all, previousStatement,version), true, CUSTOM_RULES);
	}
    function prepareHeader()
	{
		
		//var sender = monitoring.coach;
		var end = "";
		var ccs = [];
		if (isCalibration){
			this.setTo([this.monitoring.coach.mbox.substr(7)]);
			//end = '$reason ${LocaleManager.instance.lookupString("OF")} ${transaction.id}';
			end = '${reason.toUpperCase()} of id: ${transaction.id}';
		}else{
			this.setTo([this.transaction.monitoree.mbox.substr(7)]);
			ccs.push(this.monitoring.coach.mbox.substr(7));
			this.setCc([this.monitoring.coach.mbox.substr(7)]);
			if (this.transaction.monitoree.manager != null && cctl)
			{
				ccs.push(this.transaction.monitoree.manager.mbox.substr(7));
				//this.setCc([this.transaction.monitoree.manager.mbox.substr(7)]);
				#if debug
				
				trace("TMMailer::prepareHeader::this.transaction.monitoree.manager.mbox.substr(7)", this.transaction.monitoree.manager.mbox.substr(7) );
				#end
			}
			else{
				#if debug
				trace("TMMailer::prepareHeader::this.transaction.monitoree.manager != null", this.transaction.monitoree.manager != null );
				#end
			}
			
			end = '${reason.toUpperCase()} ${monitoring.data.get(Monitoring.MONITORING_TYPE)} ${LocaleManager.instance.lookupString("FROM")} ${monitoring.coach.sAMAccountName} ${LocaleManager.instance.lookupString("TO")} ${transaction.monitoree.sAMAccountName}';
		}
		#if debug
		trace("TMMailer::prepareHeader::ccs", ccs );
		#end
		this.setCc(ccs);
		this.setBcc(["bruno.baudry@salt.ch"]);
	    this.setSubject('[${LocaleManager.instance.lookupString(transaction.type.toUpperCase())} Transaction Monitoring]  ' + end);
	}
	function prepareBody(all:Bool, ?agentReviewRef:StatementRef, ?version:String="")
	{
		var reciepient = isCalibration ? monitoring.coach : transaction.monitoree;
		var transactionSummary = transaction.data.get(data.Transaction.TRANSACTION_SUMMARY);
		var monitoringSummary = monitoring.data.get(data.Monitoring.MONITORING_SUMMARY);
		var criticalFailed = Question.FAILED_CRITICAL.length;
		var score = Question.GET_SCORE();
		var success = (Question.FAILED_CRITICAL.length == 0 && score.scaled > Question.MIN_PERCENTAGE_BEFORE_FAILLING);
		#if debug
		trace("TMMailer::prepareBody::success", success );
		trace("TMMailer::prepareBody::score.scaled",  score.scaled );
		#end
		var descaled = Math.round(score.scaled * 100);
		var formatedTransactionDate = DateTools.format(transaction.date, "%d.%m.%Y %H:%M");
		var b = "";
		b += "<em>"+ LocaleManager.instance.lookupString("DISCLAIMER") + "<em/>";
		if (isCalibration)
		{
			b = '<h1>${LocaleManager.instance.lookupString("CALLIBRATION")} ${LocaleManager.instance.lookupString("BY")},</h1>';
			b += monitoring.coach.buildEmailBody();
		}else{
			b = "<em>"+ LocaleManager.instance.lookupString("DISCLAIMER") + "</em>";
			b += '<h1>${LocaleManager.instance.lookupString("HELLO")} ${reciepient.firstName},</h1>';
			b += '${LocaleManager.instance.lookupString(transaction.type.toUpperCase())} Transaction Monitoring ${monitoring.data.get(Monitoring.MONITORING_TYPE)} <strong>${monitoring.data.get(Monitoring.MONITORING_REASON)}</strong> ${LocaleManager.instance.lookupString("FROM")} ${monitoring.coach.firstName} ${monitoring.coach.sirName}';
		}
		
		//${LocaleManager.instance.lookupString("BY")} ${monitoring.coach.sAMAccountName}
		
		
		b += '<h2>${LocaleManager.instance.lookupString("TRANSACTION_SUMMARY")}</h2>';
		b += '<p>${LocaleManager.instance.lookupString("TRANSACTION_ID")} : ${transaction.id}, ${LocaleManager.instance.lookupString("TRANSACTION_WHEN_DATE")} : $formatedTransactionDate</p>';
		b += '<p>$transactionSummary</p>';
		b += '<h2>${LocaleManager.instance.lookupString("MONITORING_SUMMARY")}</h2>';
		b += '<p>$monitoringSummary</p>';
		if (success) {
			b += '<h3 class="AGREE">$criticalFailed ${LocaleManager.instance.lookupString("CRITICAL_MISTAKES")}, ';
			b += '${LocaleManager.instance.lookupString("OVERALL_SCORE")}: $descaled /100 &rarr; ${LocaleManager.instance.lookupString("AGREE")}</h3>';
		}
		else {
			b += '<h3 class="DISAGREE">$criticalFailed ${LocaleManager.instance.lookupString("CRITICAL_MISTAKES")}, ';
			b += '${LocaleManager.instance.lookupString("OVERALL_SCORE")}: $descaled /100 &rarr; ${LocaleManager.instance.lookupString("DISAGREE")}</h3>';
		}
			
		
		
		b += "<ul>";
		currentTopic = "";
		var topic = "";
		var topicTab = [];
		LocaleManager.instance.language = "en-GB";
		LocaleManager.instance.language = TMApp.lang;
		for (k => v in Question.ALL)
		{
			topicTab = k.split(".");
			topic = "common." + topicTab[2];
			if (topic != currentTopic){
				if (currentTopic != "") b += "</ul></li>";
				b += '<li><h4>${LocaleManager.instance.lookupString(topic)}</h4><ul>';
				 currentTopic = topic;
			}
			if(!all && v.agreement.choice == "n" || all)
				b += prepareAnswers(k, v);
		}
		b += "</ul></li></ul>";
		
		b += isCalibration ? "" :  '<h3>${LocaleManager.instance.lookupString("MONITORED_BY")}</h3>'+ monitoring.coach.buildEmailBody();
		
		if (agentReviewRef != null) b += "QAST Tracking ID : " + agentReviewRef.id;
		if (version != "") b += "<br/>App version : " + version;
		b += '<br/><br/><i>${LocaleManager.instance.lookupString("LEGEND")}</i>';
		#if debug
		trace("TMMailer::prepareBody::b", b );
		#end
		return b;
	}
	function prepareAnswers(id:String, answer:Question)
	{
		#if debug
		trace("TMMailer::prepareAnswers::id", id );
		trace(LocaleManager.instance.language);
		#end
		var criticalIcon = LocaleManager.instance.lookupString("CRITICAL_ICON");
		var critical = answer.userData.critical ? "<span class='critical'>" + criticalIcon + " " + answer.userData.criticality +"</span> ":"";
		
		
        #if debug
		//trace("TMMailer::prepareAnswers::answer", answer );
		#end
		var choice = switch (answer.agreement.choice)
		{
			case "y":"AGREE";
			case "n":"DISAGREE";
			case _:"NA";
		};
		var r = "";
		var q = LocaleManager.instance.lookupString(id);
		
		
		var reg:EReg = ~/{{([a-z.]*)}}/ig;
		if (reg.match(q))
		{
			q = LocaleManager.instance.lookupString(reg.matched(1));
		}
        #if debug
		trace("TMMailer::prepareAnswers::q", q );
		#end
		r += '<p>$q $critical &rarr; ';
		//r += '<p>${LocaleManager.instance.lookupString(id)} $critical &rarr; ';
		//r += '<h4>{{$id}} :</h4>';
		r += '<strong class="$choice">${LocaleManager.instance.lookupString(choice)}</strong>';
		if(answer.agreement.justification.length>0) r += ' (${answer.agreement.justification})';
		//if (answer.choice == "n") r += ' (${answer.justification})';
		r += "</p>";
		
		return r;
	}
	
	function set_cctl(value:Bool):Bool 
	{
		return cctl = value;
	}

}