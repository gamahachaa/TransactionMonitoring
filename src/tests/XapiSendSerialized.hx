package tests;
import haxe.Http;
import haxe.Json;
using StringTools;

/**
 * ...
 * @author bb
 */
class XapiSendSerialized 
{

	public function new() 
	{
		var http = new Http(  "https://qook.test.salt.ch/commonlibs/xapi/index.php" );
		
		http.addParameter("statement","cy14:xapi.Statementy11:attachmentsny9:timestampy32:2021-04-01T08%3A15%3A29.4680000Zy7:contextcy12:xapi.Contexty8:languagey2:eny10:extensionsby52:https%3A%2F%2Fqook.test.salt.ch%2FtransactionSummaryy6:sdfsdfy50:https%3A%2F%2Fqook.test.salt.ch%2FmonitoringReasony5:basicy48:https%3A%2F%2Fqook.test.salt.ch%2FmonitoringTypey6:remotey51:https%3A%2F%2Fqook.test.salt.ch%2FmonitoringSummaryR10hy9:statementcy23:xapi.types.StatementRefy2:idy36:381855ec-7ed1-479b-b715-b87483ac7d68y10:objectTypey12:StatementRefgy8:platformy4:qooky8:revisionny17:contextActivitiesby6:parentahy8:groupingahy5:otherahy8:categoryahhy10:instructorny12:registrationngy6:resultcy11:xapi.Resulty8:durationy11:P0DT0H0M19Sy8:responseny10:completionty7:successty5:scorecy16:xapi.types.Scorey3:maxi100y3:minzy3:rawi100y6:scaledi1gR8by39:https%3A%2F%2Fqast.salt.ch%2Fstatementsr3hgy6:objectcy10:xapi.AgentR20y5:Agenty4:mboxy31:mailto%3Abruno.baudry%40salt.chy4:namey7:bbaudrygy4:verbcy9:xapi.VerbR18y47:http%3A%2F%2Fid.tincanapi.com%2Fverb%2Fmentoredy7:displaybR7y8:mentoredhgy5:actorcR47R20R48R49R50R51R52gg" );
		http.onData =(ondata);
		http.onError =(onerror);
		http.onStatus= (onstatus);
		http.request(true);
	}
	
	function onstatus(status:Int)
	{
		trace(status);
	}
	
	function onerror(e:String)
	{
		trace(e);
	}
	
	function ondata(data:String) 
	{
		trace(Json.parse(data));
	}
}
/**
"cy14:xapi.Statementy11:attachmentsny9:timestampy32:2021-03-31T12%3A49%3A43.1480000Zy7:contextcy12:xapi.Contexty8:languagey2:eny10:extensionsny9:statementny8:platformy4:qooky8:revisionny17:contextActivitiesby6:parentahy8:groupingahy5:otherahy8:categoryahhy10:instructorcy10:xapi.Agenty10:objectTypey5:Agenty4:mboxy31:mailto%3Abruno.baudry%40salt.chy4:namey7:bbaudrygy12:registrationngy6:resultcy11:xapi.Resulty8:durationy10:P0DT0H0M0Sy8:responseny10:completionty7:successty5:scorecy16:xapi.types.Scorey3:maxi100y3:minzy3:rawi100y6:scaledi1ggy6:objectcy13:xapi.ActivityR20y8:Activityy2:idy46:https%3A%2F%2Fqook.test.salt.ch%2Ftm%2Finboundy10:definitioncy26:xapi.activities.DefinitionR24bhy11:descriptionbhR8by52:https%3A%2F%2Fqook.test.salt.ch%2FtransactionSummaryy3:srty50:https%3A%2F%2Fqook.test.salt.ch%2FmonitoringReasony5:basicy48:https%3A%2F%2Fqook.test.salt.ch%2FmonitoringTypey6:remotey51:https%3A%2F%2Fqook.test.salt.ch%2FmonitoringSummaryy5:ertethy4:typey53:http%3A%2F%2Factivitystrea.ms%2Fschema%2F1.0%2Freviewy8:moreInfonggy4:verbcy9:xapi.VerbR43y54:http%3A%2F%2Factivitystrea.ms%2Fschema%2F1.0%2Freceivey7:displaybR7y7:receivehgy5:actorcR19R20R21R22R23R24R25gg"
*/