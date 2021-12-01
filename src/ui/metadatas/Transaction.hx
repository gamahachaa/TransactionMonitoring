package ui.metadatas;

import haxe.ui.containers.VBox;
import signals.Signal1;

/**
 * ...
 * @author bb
 */
@:build(haxe.ui.macros.ComponentMacros.build("assets/ui/metadatas/Transaction.xml"))
class Transaction extends VBox
{
	public var dateSignal(get, null):signals.Signal1<Date>;
	public var searchAgentSignal(get, null):Signal1<String>;

	public function new()
	{
		super();
		searchAgentSignal = new Signal1<String>();
		dateSignal = new Signal1<Date>();
		agentBtn.onClick = (e)->(searchAgentSignal.dispatch(agentNt.text));
		TRANSACTION_WHEN.onChange = (e)(prepareTransactionDate());
		TRANSACTIONWHENHOURS.onChange = (e)(prepareTransactionDate());
		TRANSACTION_WHEN_MINUTES.onChange = (e)(prepareTransactionDate());
	}
	function prepareTransactionDate()
	{
		var tmp = cast(TRANSACTION_WHEN.value, Date);
		if (tmp != null)
		{
			tmp = Date.fromTime(tmp.getTime() + (TRANSACTIONWHENHOURS.value * 3600000) + (TRANSACTION_WHEN_MINUTES.value * 60000));
		}
		//trace(tmp);
		//trace(transactionDate);
		dateSignal.dispatch(tmp);
	}
	/*********************************************/
	function get_dateSignal():signals.Signal1<Date> 
	{
		return dateSignal;
	}
	
	function get_searchAgentSignal():Signal1<String>
	{
		return searchAgentSignal;
	}
}