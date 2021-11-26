package;
import haxe.Json;
import haxe.ds.StringMap;
//import openfl.utils.Assets;
import xapi.Agent;
//import tstool.utils.Csv;

/**
 * ...
 * @author bbaudry
 */
class Actor extends Agent
{
	public var manager(get, null):Actor;
	public var authorised(get, null):Bool;
	//var adminFile:Csv;

	public var sAMAccountName(get, null):String;
	public var firstName(get, null):String;
	public var sirName(get, null):String;
	public var mobile(get, null):String;
	public var company(get, null):String;
	public var workLocation(get, null):String;
	public var division(get, null):String;
	public var department(get, null):String;
	//public var directReports(get, null):String;
	public var distinguishedName(get, null):String;
	public var accountExpires(get, null):String; //@todo Date

	public var title(get, null):String;
	public var initials(get, null):String;
	public var memberOf(get, null):Array<String>;
	//public var isAdmin(get, null):Bool;
	@:isVar public var canDispach(get, set):Bool;
	@:isVar public var mainLanguage(get, set):String;
	
	//public static inline var WINBACK_GROUP_NAME:String = "WINBACK - TEST";
	@:isVar public var statement(get, set):String;
	public function new(?jsonUser:Dynamic=null, ?authorised:Bool=true)
	{
		this.authorised = authorised;
		canDispach = authorised;
		statement = "";
		
		if (jsonUser != null )
		{
			super(jsonUser.mail, jsonUser.samaccountname);
			manager = jsonUser.boss == null ? null : new Actor(jsonUser.boss, false);
			sAMAccountName = jsonUser.samaccountname ==null?"":jsonUser.samaccountname ;
			firstName = jsonUser.givenname  == null ? "":jsonUser.givenname ;
			sirName = jsonUser.sn == null ? "" :jsonUser.sn;
			mobile = jsonUser.mobile == null ? "": jsonUser.mobile;
			company = jsonUser.company == null ? "" : jsonUser.company;
			workLocation = jsonUser.l == null ? "": jsonUser.l;
			division = jsonUser.division == null ? "": jsonUser.division;
			department = jsonUser.department = null ? "": jsonUser.department;
			//directReports = jsonUser.directreports == null ? "": jsonUser.directreports;
			distinguishedName = jsonUser.distinguishedname == null ? "": jsonUser.distinguishedname;
			accountExpires = jsonUser.accountexpires == null ? "": jsonUser.accountexpires; //@todo Date
			mainLanguage = jsonUser.msexchuserculture  == null ? "en-GB": jsonUser.msexchuserculture;
			title = jsonUser.title == null ? "" : jsonUser.title;
			initials = jsonUser.initials == null ? "": jsonUser.initials;
			memberOf = jsonUser.memberof == null ? []: jsonUser.memberof ;
		}
		else{
			#if debug
				trace("jsonUser is null");
			#end
		}
	}
	public function isMember(groupName:String):Bool
	{
		if (memberOf == []) return false;
		return memberOf.indexOf(groupName)>-1;
	}
	public function twoCharsLang(caps:Bool = true)
	{
		return caps ? mainLanguage.substring(0,2).toUpperCase() : mainLanguage.substring(0,2).toLowerCase();
	}
	public function buildEmailBody()
	{
		var bodyList = '<li>$firstName $sirName ($sAMAccountName) $title</li>';
		bodyList += '<li>$company | $department | $division | $workLocation </li>';
		if(statement !="") bodyList += '<li>Qast.id | $statement </li>';
		return '<ul>$bodyList</ul>';
	}
	function get_sAMAccountName():String
	{
		return sAMAccountName;
	}

	function get_firstName():String
	{
		return firstName;
	}

	function get_sirName():String
	{
		return sirName;
	}

	function get_mobile():String
	{
		return mobile;
	}

	function get_company():String
	{
		return company;
	}

	function get_workLocation():String
	{
		return workLocation;
	}

	function get_division():String
	{
		return division;
	}

	function get_department():String
	{
		return department;
	}

	/*function get_directReports():String
	{
		return directReports;
	}*/

	function get_mainLanguage():String
	{
		return mainLanguage;
	}

	function set_mainLanguage(value:String):String
	{
		return mainLanguage = value;
	}

	function get_title():String
	{
		return title;
	}

	function get_initials():String
	{
		return initials;
	}

	function get_memberOf():Array<String>
	{
		return memberOf;
	}

	function get_accountExpires():String
	{
		return accountExpires;
	}
	
	function get_canDispach():Bool 
	{
		return canDispach;
	}
	
	function set_canDispach(value:Bool):Bool 
	{
		return canDispach = value;
	}
	
	function get_authorised():Bool 
	{
		return authorised;
	}
	function get_statement():String 
	{
		return statement;
	}
	
	function set_statement(value:String):String 
	{
		return statement = value;
	}
	
	function get_manager():Actor 
	{
		return manager;
	}
	
	function get_distinguishedName():String 
	{
		return distinguishedName;
	}
	
	inline public static function CREATE_DUMMY():Actor
	{
		return new Actor({
			mail : "Bruno.Baudry@salt.ch", 
			samaccountname : "bbaudry", 
			givenname : "Bruno", 
			sn : "Baudry", 
			mobile : "+41 78 787 8673", 
			company : "Salt Mobile SA", 
			l : "Biel", 
			division : "Customer Operations", 
			department : "Process & Quality", 
			distinguishedname : "CN=Baudry Bruno,OU=Domain-Generic-Accounts,DC=ad,DC=salt,DC=ch", 
			accountexpires : "0", 
			msexchuserculture : "fr-FR", 
			title : "Manager Knowledge & Learning", 
			initials : "BB", 
			memberof : ["Microsoft - Teams Members - Standard", "Customer Operations - Training", "RA-PulseSecure-Laptops-Salt", "SG-PasswordSync", "RA-EasyConnect-Web-Mobile-Qook", "Customer Operations - Knowledge - Management", "Customer Operations - Direct Reports", "Customer Operations - Fiber Back Office", "DOLPHIN_REC", "Application-GIT_SALT-Operator", "Application-GIT_SALT-Visitor", "SG-OCH-WLAN_Users", "SG-OCH-EnterpriseVault_DefaultProvisioningGroup", "Entrust_SMS", "MIS Mobile Users", "GI-EBU-OR-CH-MobileUsers", "Floor Marshalls Biel", "CO_Knowledge And Translation Mgmt", "co training admin_ud", "Exchange_Customer Operations Management_ud", "Exchange_CustomerCareServiceDesign_ud"],
			boss:{mail : "fabien.reanard@salt.ch", 
			samaccountname : "frenard",distinguishedname : "CN=Renard Fabien,OU=Domain-Generic-Accounts,DC=ad,DC=salt,DC=ch"}
		}, true);
	}
}