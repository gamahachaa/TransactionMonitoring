package;

import haxe.ui.Toolkit;
import haxe.ui.components.Button;
import haxe.ui.components.DropDown;
import haxe.ui.components.Label;
import haxe.ui.components.OptionBox;
import haxe.ui.components.TextArea;
import haxe.ui.containers.Group;
import haxe.ui.containers.dialogs.Dialog.DialogButton;
import haxe.ui.containers.dialogs.MessageBox.MessageBoxType;
import haxe.ui.core.Component;
import haxe.ui.core.Screen;
import haxe.ui.data.DataSource;
import haxe.ui.events.UIEvent;
import haxe.ui.macros.ComponentMacros;
import firetongue.FireTongue;
import lrs.vendors.LearninLocker;
import haxe.ui.events.MouseEvent;

class Main {
	var tongue:FireTongue;
	var labels:Array<Label>;
	var lang:String;
	var langSwitcher:DropDown;
	var send:Button;
	var com:Component;
	var bus:Component;
	var gen:Component;
	var monitoringReasons:Group;
	var comWelcomeGroup:Group;
	var agreements:Array<Group>;
	var mainApp:Component;
	var monitoringType:Group;
	var helps:Array<Button>;
	var help:Label;
	public static function main() {
       var m:Main = new Main();
    }
	public function new()
	{
		 // Uncomment this line to use native components where possible (ie, a hybrid user interface)
         //Toolkit.theme = "native";
        Toolkit.init();

		tongue = new FireTongue();
		lang = "fr";
		
		tongue.init(lang);
        mainApp = ComponentMacros.buildComponent("assets/ui/main.xml");
        var login = ComponentMacros.buildComponent("assets/ui/login.xml");
		
        /*
         * We are using 'Screen.instance.addComponent' as its more cross framework,
         * however, would could have also used 'js.Browser.document.body.appendChild'
         * to append the components .element attribute. eg:
         *
         * js.Browser.document.body.appendChild(main.element);
         */
		if (true)
		{
			Screen.instance.addComponent(mainApp);
			//Screen.instance.addComponent(login);
			send = mainApp.findComponent("send", null, true);
			//send.registerEvent(MouseEvent.MOUSE_MOVE, onRoll);
			send.onClick = onSend;
			langSwitcher = mainApp.findComponent("langSwitcher", null, true);
			langSwitcher.onChange = onLangChanged;
			prepareMainLanguage();
			prepareComponents();
			
			prepareLanguage();
		}
		else
			Screen.instance.addComponent(login);
		//Screen.instance.dialog(	login, "DIALOGUE",DialogButton.OK, true, function(e)trace(login.findComponent("username", null, true)) );
	//Screen.instance.messageBox("YO", "Title", MessageBoxType.TYPE_QUESTION, true, function(e) trace(e));
		//var ll:LearninLocker = new LearninLocker("qast", "https://qast.test.salt.ch/data/xAPI", "", "", "Basic " +"M2I1ZDlkMWYyZmM3NmU5Y2RiNjYzZjMxMTYxM2Q1NjYzZmM2OTRkMTpmYTRhNjY4OWMwMDE1M2IzOTM5MDVlMDk1ZjQ0NTEwZDM0MTM4MTk1");
		
		//ll.httpData.add(onLRSTest);
		//ll.testConnection();
		
	}
	
	function onSend(e) 
	{
		var agreementsResult = checkAgreements();
		trace(agreementsResult);
		if (agreementsResult.allCleared)
		{
			Screen.instance.messageBox("Send to tracker?", "All good", MessageBoxType.TYPE_QUESTION);
		}
		else{
			Screen.instance.messageBox("Not complete", "Wraning", MessageBoxType.TYPE_WARNING);
		}
	}
	function checkAgreements()
	{
		var all = [];
		var allCleared = true;
		if (agreements.length > 0)
		{
			for ( i in agreements)
			{
				var question:Group = cast(i, Group);
				var parent:Component = question.parentComponent;
				//trace();
				
				var num = question.numChildren;
				var fisrtChild:OptionBox = cast(question.getChildAt(0));
				var selected = fisrtChild.selectedOption;
				var questionID = GET_PARENT_PATH(question) + "question";
				var trad = tongue.get("$" + GET_PARENT_PATH(question) + "question", "data");
				var jsutifyString = selected != null && selected.id == "disagreed"?cast(parent.findComponent("justify", TextArea, false, "id"), TextArea).text:"";
				var result = {
					trad:trad ,
					uri:questionID ,
					result : (selected == null ? "waived":selected.id),
					justification: jsutifyString
				};
				if (allCleared )
				{
					if(selected == null || (selected.id == "disagreed" && (jsutifyString==null|| StringTools.trim(jsutifyString)=="")))
						allCleared = false;
				}
				
				all.push(result);
			}
		}
		return {allCleared : allCleared, items: all};
	}
	function onLRSTest(s)
	{
		trace(s);
	}
	
	function prepareComponents() 
	{
		com = mainApp.findComponent("communication", null, true); 
		bus = mainApp.findComponent("business", null, true);
		gen = mainApp.findComponent("general", null, true);
		
		help = mainApp.findComponent("help", null, true);
		//help.color = 0x7d7454;
		//help.borderSize = 2;
		//help.borderRadius = 4;
		//help.backgroundColor = 0xf0dfa2;
		monitoringReasons = mainApp.findComponent("reason", null, true);
		monitoringReasons.onChange = onMonitoringChanged;		
		monitoringType = mainApp.findComponent("type", null, true);
		monitoringType.onChange = onTypeChanged;
		
		agreements = com.findComponents("agreement", Group, 10);
		agreements = agreements.concat(bus.findComponents("agreement", Group, 10));
		labels = com.findComponents(null, Label, 10);
		labels = labels.concat(bus.findComponents(null, Label, 10));
		labels = labels.concat(gen.findComponents(null, Label, 10));
		
		//helps = [];
		helps = com.findComponents("help", Button, 10);
		//helps = helps.concat(bus.findComponents("help", Button, 10));
		//helps = helps.concat(gen.findComponents("help", Button, 10));
		for (a in agreements)
		{
			a.onChange = onAgreementChanged;
		}
		//for ( b in helps)
		//{
			//b.borderRadius = 24;
			////b.registerEvent(MouseEvent.MOUSE_OVER, onHelp);
		//}
		trace(labels.length);
		for (l in labels)
		{
			trace(l.text);
			l.registerEvent(MouseEvent.MOUSE_OVER, onHelp);
		}

        
	}
	
	function onHelp(e) 
	{
		trace(GET_PARENT_PATH(e.target));
		//help.value = tongue.get("$" + GET_PARENT_PATH(e.target) + "help", "data");
	}
	
	function onTypeChanged(e)
	{
		//trace("type Changed " + e.target);
	}
	
	function onMonitoringChanged(e) 
	{
		//trace("monitoring Changed " + e.target);
	}
	function prepareLanguage()
	{
		trace( "prepareLanguage");
		trace(labels.length);
		for (l in labels)
		{
			//trace(GET_PARENT_PATH(l) + l.id + "\t" + l.text);
			l.text = tongue.get("$" + GET_PARENT_PATH(l) + l.id, "data");
		}
		
	}
	
	function onRoll(e:MouseEvent):Void 
	{
		trace(e.target.id);
		trace("YO");
	}
	function prepareMainLanguage() 
	{
		var ds:Array<OptionBox> = langSwitcher.findComponents(null, OptionBox, 1);
		
		trace(ds.length);
		var s = ds.length;
		var langIndex = -1;
		while (s >0)
		{
			langIndex = --s;
			
			ds[langIndex].selected = ds[langIndex].text == lang;
		}
	}
	
	function onLangChanged(e:UIEvent) 
	{
		//trace(cast(e.target, DropDown).selectedItem);
		//tongue.init(cast(e.target, DropDown).selectedItem.value);
		var _box:OptionBox = cast(e.target, OptionBox);
		trace(_box.selectedOption.text);
		tongue.init(_box.selectedOption.text);
		help.text = "";
		prepareLanguage();
		//for (l in labels)
		//{
			////trace(GET_PARENT_PATH(l) + l.id + "\t" + l.text);
			//l.text = tongue.get("$" + GET_PARENT_PATH(l) + l.id, "data");
		//}
	}
	function onAgreementChanged(e:UIEvent)
	{
		trace("Changed " + e.target.id); 
		var parent = cast(e.target.parentComponent, Component).parentComponent;
		var justification:Component = parent.findComponent("justify",null,true);
		justification.hidden = e.target.id != "disagreed";
		justification.width = justification.parentComponent.width;
		trace(GET_PARENT_PATH(justification, e.target.id));
	}
	public static function GET_PARENT_PATH(c:Component, ?path="")
	{
		var parent = c.parentComponent;
		if (parent == null) {
			var t = path.split(".");
			t.reverse();
			return t.join(".");
		}
		else{
			if (parent.id != null && parent.id != "")
			{
				if(parent.id !="main" && parent.id!="tabview-content")
					path = path + "." + parent.id;
			}
			return GET_PARENT_PATH(parent, path);
		}
		
	}
}
