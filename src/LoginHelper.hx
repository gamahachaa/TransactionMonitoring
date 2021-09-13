package;

import haxe.Exception;
import haxe.Http;
import haxe.Json;
import haxe.crypto.Base64;
import haxe.io.Bytes;
import js.Browser;
import signals.Signal1;
import Actor;
using StringTools;

/**
 * ...
 * @author bb
 */
class LoginHelper extends Http 
{
	public var successSignal:Signal1<Actor>;
	public var statusSignal:Signal1<Int>;
	public var errorSignal:Signal1<Dynamic>;
	var _mainDebug:Bool;
	var canRequest:Bool;

	public function new(url:String) 
	{
		super(url);
		_mainDebug = Browser.location.origin.indexOf("salt.ch") > -1;
		this.async = true;
		canRequest = false;
		successSignal = new Signal1<Actor>();
		statusSignal = new Signal1<Int>();
		errorSignal = new Signal1<Dynamic>();
		
		this.onError = onMyError;
		this.onStatus = onMyStatus;
	}
	function onMyStatus(status:Int) 
	{
		statusSignal.dispatch(status);
	}
	
	function onMyError(error:Dynamic) 
	{
		errorSignal.dispatch(error);
	}
	function onMySearch(data:String) 
	{
		var d = Json.parse(data);
		var searched = d.search;
		
		if (searched.error != null)
		{
			successSignal.dispatch( Monitoree.CREATE_ERROR(searched.error));
		}
		else{
			successSignal.dispatch( new Monitoree(searched));
		}
	}
	function onMyData(data:String) 
	{
		var d:Dynamic = Json.parse(data);
	
		if (d.authorized)
		{
			successSignal.dispatch( new Coach(d.attributes));
		}
		else
		{
			d.mail = "";
			d.samaccountname = d.username;
			d.title = d.status;
			successSignal.dispatch(Coach.CREATE_ERROR(d.username));
		}
	}

	function parseJsonAgent(data:String)
	{
		#if debug
			if(_mainDebug) return Json.parse(data);
			return cretaDummyAgent();	
		#else
			return Json.parse(data);
		#end
	}
	public function prepareCredentials(username:String, pwd:String)
	{
		if (username == null || username.trim() == "" || pwd == null || pwd.trim() == ""){
			throw "null credentials";
		}
		this.setParameter("username", username);
		this.setParameter("pwd", Base64.encode(Bytes.ofString(pwd)));
		canRequest = true;
	}
	public function search(nt:String)
	{
		if (nt != null && nt != "")
		{
			this.setParameter("search", nt);
			this.onData = onMySearch;
			this.request( true );
		}
		else{
			throw "search is null";
		}
		
	}
	public function send()
	{
		
		if (canRequest) {
			//#if debug
			//trace("LoginHelper::send::send", canRequest);
			//#end
			this.onData = onMyData;
			this.request(true);
		}
		else {
			//#if debug
			//trace("LoginHelper::send::canRequest", canRequest );
			//#end
			throw new Exception("cannot request. Missing credetnitals I guess");
		}
	}
	inline function cretaDummyAgent() 
	{
		return {
		status : "ldap could bind", 
		authorized : true, 
		username : "bbaudry", 
		attributes : {
			mail : "Bruno.Baudry@salt.ch", 
			samaccountname : "bbaudry", 
			givenname : "Bruno", 
			sn : "Baudry", 
			mobile : "+41 78 787 8673", 
			company : "Salt Mobile SA", 
			l : "Biel", 
			division : "Customer Operations", 
			department : "Process & Quality", 
			directreports : "CN=qook,OU=Domain-Generic-Accounts,DC=ad,DC=salt,DC=ch", 
			accountexpires : "0", 
			msexchuserculture : "fr-FR", 
			title : "Manager Knowledge & Learning", 
			initials : "BB", 
			memberof : ["Microsoft - Teams Members - Standard","Customer Operations - Training","RA-PulseSecure-Laptops-Salt","SG-PasswordSync","RA-EasyConnect-Web-Mobile-Qook","Customer Operations - Knowledge - Management","Customer Operations - Direct Reports","Customer Operations - Fiber Back Office","DOLPHIN_REC","Application-GIT_SALT-Operator","Application-GIT_SALT-Visitor","SG-OCH-WLAN_Users","SG-OCH-EnterpriseVault_DefaultProvisioningGroup","Entrust_SMS","MIS Mobile Users","GI-EBU-OR-CH-MobileUsers","Floor Marshalls Biel","CO_Knowledge And Translation Mgmt","co training admin_ud","Exchange_Customer Operations Management_ud","Exchange_CustomerCareServiceDesign_ud"]
		}};
	}
}