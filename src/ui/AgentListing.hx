package ui;

import haxe.ui.components.Button;
import haxe.ui.components.Column;
import haxe.ui.components.Image;
import haxe.ui.components.Label;
import haxe.ui.components.OptionBox;
import haxe.ui.components.OptionBox.OptionBoxBuilder;
import haxe.ui.containers.Group;
import haxe.ui.containers.MyTableView;
import haxe.ui.containers.TableView;
import haxe.ui.containers.VBox;
import haxe.ui.core.ItemRenderer;
import haxe.ui.data.ArrayDataSource;
import haxe.ui.events.MouseEvent;
import haxe.ui.events.UIEvent;
import haxe.ui.locale.LocaleManager;
import haxe.ui.macros.ComponentMacros;
import js.Browser;
import js.html.DivElement;
import js.html.Window;
import queries.TMBasicsThisMonth.BasicTM;

/**
 * ...
 * @author bb
 */
class AgentListing extends VBox
{
	var table:haxe.ui.containers.TableView;
	var coach:Coach;
	var ds:haxe.ui.data.ArrayDataSource<Dynamic>;
	var withDirectReports:Bool;
	var currentList:Array<Dynamic>;
	var sendReport:Button;
	var gReportChoose:Group;
	var myDr:OptionBox;
	var myTm:OptionBox;
	public var signal(get, null):signal.Signal1<String>;

	public function new(coach:Coach, ?list:Array<Dynamic>)
	{
		super();
		this.id = "AgentListing";
		
		withDirectReports = false;
		this.coach = coach;
		#if debug
		trace("ui.AgentListing::AgentListing");
		#end
		signal = new signal.Signal1<String>();
		ds = new ArrayDataSource<Dynamic>();
		
		//table =ComponentMacros.buildComponent("assets/ui/components/agentListingTable.xml");
		table = new TableView();
		table.id = "table";
		createHeader();
		
		if (list!= null) displayList( list );

		table.onClick = onclick;
        sendReport = new Button();
		sendReport.horizontalAlign = "right";
		
		//sendReport.text = LocaleManager.instance.lookupString("SEND_REPORT_TO_TL");
		sendReport.icon = "images/download_csv.png";
		//"send the report to my manager ";
		sendReport.onClick = sendReportFunc;
		sendReport.hidden = true;
		//(e:MouseEvent)->( sendReportFunc );
		var title:Label = new Label();
		gReportChoose = new Group();
		gReportChoose.id = "myGroup";
		gReportChoose.onChange = onChoiceChanged;
		myDr = new OptionBox();
		myTm = new OptionBox();
		myTm.id="myTm";
		myDr.id="myDr";
		myTm.text = "that I did";
		myDr.text = "that my direct reports recieved";
		//r2.componentGroup = "myGroup";
		//r2.onChange = (e)->(trace(e));

		//r3.componentGroup = "myGroup";
		//r3.onChange = (e)->(trace(e));
		//var r1:OptionBoxBuilder = new OptionBoxBuilder();
		//r1.
		title.text = "Show this month's TM";
		title.styleNames = "h2";
	
		addComponent( title );
		gReportChoose.addComponent( myTm );
		gReportChoose.addComponent( myDr );
		//g.addComponent( r3 );
		addComponent( gReportChoose );
		addComponent( table );
		addComponent( sendReport );
		//content.invalidateComponent();
		//content.addComponent(al );
		//trace(table.itemCount);
	}
	public function reset()
	{
		table.dataSource.clear();
		LocaleManager.instance.language = "en";
		LocaleManager.instance.language = TMApp.lang;
		sendReport.hidden = true;
		gReportChoose.resetGroup();
		
	}
	function sendReportFunc(e) 
	{
		#if debug
		trace("ui.AgentListing::sendReportFunc");
		#end
		var encodedUri = "data:text/csv;charset=utf-8,"+ StringTools.urlEncode(Utils.arrayToCsv(Utils.arrayDynamicToArrayArrayString(currentList),";"));
		#if debug
		trace('ui.AgentListing::sendReportFunc::encodedUri ${encodedUri}');
		#end
		//window.open(encodedUri)
		Browser.window.open(encodedUri,"MyName");
		//Browser.location.assign(encodedUri);
	}

	function onChoiceChanged(e:UIEvent)
	{
		table.dataSource.clear();
		withDirectReports = e.target.id == "myDr";
		signal.dispatch(e.target.id);
		//LocaleManager.instance.language = "en";
		//LocaleManager.instance.language = TMApp.lang;
	}
	public function displayList(list:Array<Dynamic>)
	{
		activityNameOnly(list);
		currentList = withDirectReports ? directReportList(list) :list;
		//trace(Utils.arrayToCsv(Utils.arrayDynamicToArrayArrayString(currentList)));
		table.dataSource.clear();
		for (i in currentList)
		{
			ds.add(i);
		}

		table.dataSource = ds;
		sendReport.hidden = false;
	}
	function activityNameOnly(l:Array<Dynamic>)
	{
		 Lambda.iter(l, lastProp);
	}
	
	function lastProp(item) 
	{
		var t = item.tm;
		//var l = t.split("/").pop();
		item.tm = t.split("/").pop();
	}
	function createHeader()
	{
		var c:Column = new Column();
		c.sortable = true;
		c.text = c.id = "agent";
		c.width = 100;
		//table.addComponent(c);
		table.addColumn("agent").width = 100;
		table.addColumn("tm").width = 80;
		table.addColumn("timestamp").width = 200;
		table.addColumn("success").width = 80;
		
		/*table.height = 100%;*/
	}

	function get_signal():signal.Signal1<String>
	{
		return signal;
	}

	function onclick(e:MouseEvent)
	{
		var t:TableView = cast(e.target, TableView);
		//trace(t.col);
		//trace(t.selectedItem.id);
		if (t.selectedItem != null)
		{

			signal.dispatch(t.selectedItem.agent);
		}
		//trace(t.innerHTML);
	}
	function directReportList(list:Array<Dynamic> )
	{
		//var tmp = monitoringData.coach.getDirectReportsAMAccountNames();
		var l = list;
		for (i in coach.getDirectReportsAMAccountNames())
		{
			if (Lambda.find(list, (j)->(j.agent == i)) == null) l.push(
			{
				statement_id : "-",
				agent : i,
				tm : "none",
				timestamp : "-",
				success : "-"
			});
		}
		return l;
	}

}