package;
import haxe.ui.locale.LocaleManager;
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
class TMMailer extends MailHelper
{
	static inline var CUSTOM_RULES:String = ".critical{color:#F0AD50;} .AGREE{color:#65A63C;} .DISAGREE{color:#D95350;}";
	//public var reason:String;
	//public var transactionType:String;
	//public var sender:Actor;
	//public var reciepient:Actor;
	public var transaction:Transaction;
	public var monitoring:Monitoring;
	//public var type:String;
	//public var transactionSummary:String;
	//public var monitoringSummary:String;
	//public var criticalFailed:Float;
	//public var score:Float;
	//public var failed:Float;
	//public var answers:Map<String,Question>;

	public function new(url:String, ?transaction:Transaction, ?monitoring:Monitoring)
	{
		super(url);
		this.transaction = transaction;
		this.monitoring = monitoring;
	}
	public function build(all:Bool, ?previousStatement:StatementRef)
	{
		//var transactionType = transaction.type;
		var type = monitoring.data.get(Monitoring.MONITORING_TYPE);
		var reason = monitoring.data.get(Monitoring.MONITORING_REASON);
		var sender = monitoring.coach;
		this.setSubject('[${LocaleManager.instance.lookupString(transaction.type.toUpperCase())} Transaction Monitoring] $type $reason ${LocaleManager.instance.lookupString("FROM")} ${sender.firstName} ${sender.sirName}');
		if (reason == "calibration"){
			this.setTo([this.monitoring.coach.mbox.substr(7)]);
		}else{
			this.setTo([this.transaction.monitoree.mbox.substr(7)]);
			this.setCc([this.monitoring.coach.mbox.substr(7)]);
		}
	
		
		//prepareBody();
		//var customRules = CUSTOM_RULES;
		setBody(prepareBody(all, previousStatement), true, CUSTOM_RULES);
	}

	function prepareBody(all:Bool, ?agentReviewRef:StatementRef)
	{
		var reciepient = transaction.monitoree;
		var transactionSummary = transaction.data.get(Transaction.TRANSACTION_SUMMARY);
		var monitoringSummary = monitoring.data.get(Monitoring.MONITORING_SUMMARY);
		var criticalFailed = Question.FAILED_CRITICAL.length;
		var score = Question.GET_SCORE();
		var b = '<h1>${LocaleManager.instance.lookupString("HELLO")} ${reciepient.firstName}</h1>';
		var formatedTransactionDate = DateTools.format(transaction.date, "%d.%m.%Y %H:%M");
		b += '<h2>${LocaleManager.instance.lookupString("TRANSACTION_SUMMARY")}</h2>';
		b += '<p>${LocaleManager.instance.lookupString("TRANSACTION_ID")} : ${transaction.id}, ${LocaleManager.instance.lookupString("TRANSACTION_WHEN_DATE")} : $formatedTransactionDate</p>';
		b += '<p>$transactionSummary</p>';
		b += '<h2>${LocaleManager.instance.lookupString("MONITORING_SUMMARY")}</h2>';
		b += '<p>$monitoringSummary</p>';
		b += '<h3>$criticalFailed ${LocaleManager.instance.lookupString("CRITICAL_MISTAKES")}, ';
		b += 'Score: $score</h3>';
		b += '<br/><i>${LocaleManager.instance.lookupString("LEGEND")}</i>';
		b += "<ul>";
		for (k => v in Question.ALL)
		{
			if(!all && v.agreement.choice == "n" || all)
				b += prepareAnswers(k, v.agreement);
		}
		b += "</ul>";
		b += '<h3>${LocaleManager.instance.lookupString("MONITORED_BY")}</h3>';
		b += monitoring.coach.buildEmailBody();
		
		if (agentReviewRef != null) b += "QAST Tracking ID : " + agentReviewRef.id;
		
		return b;
	}
	function prepareAnswers(id:String, answer:Agreement)
	{
		//var critical = answer.critical ? "<span class='critical'>&copy;</span>":"";

		var choice = switch (answer.choice)
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

		r += '<p>$q &rarr; ';
		//r += '<h4>{{$id}} :</h4>';
		r += '<strong class="$choice">${LocaleManager.instance.lookupString(choice)}</strong>';
		if(answer.justification.length>0) r += ' (${answer.justification})';
		//if (answer.choice == "n") r += ' (${answer.justification})';
		r += "</p>";
		
		return r;
	}

}