package ui;

import haxe.Exception;
import haxe.ui.containers.VBox;
import haxe.ui.events.MouseEvent;
import http.LoginHelper;

/**
 * ...
 * @author bb
 * @todo revome logger ?
 */
@:build(haxe.ui.macros.ComponentMacros.build("assets/ui/login.xml"))
class Login extends VBox 
{
	var _logger:LoginHelper;
	public function new(logger:LoginHelper) 
	{
		super();
		_logger = logger;
		login.onClick = onLoginClicked;
		showPwd.onClick = onShowChange;
	}
	public function feedErrorBack(txt:String)
	{
		feedback.addClass("error");
		feedback.text = txt;
	}
	function onLoginClicked(e:MouseEvent) 
	{
		#if debug
		trace("ui.Login::onLoginClicked");
		#end
		feedback.removeClass("error");
		
		try
		{
			#if !debug
			_logger.prepareCredentials(username.text, pwd.text);
			#else
			if(TMApp._mainDebug) _logger.prepareCredentials(username.text, pwd.text);
			#end
			_logger.send();
		}
		catch (e:Exception)
		{
			feedback.addClass("error");
			feedback.text = e.message;
		}
		catch (e:Dynamic)
		{
			feedback.addClass("error");
			feedback.text = e.message;
		}
		
	}
	function onShowChange(e:MouseEvent)
	{
		pwd.password = !pwd.password;
	}
	
}