package;

/**
 * ...
 * @author bb
 */
class Coach extends Actor 
{
	

	public function new(?jsonUser:Dynamic=null, ?authorised:Bool=true) 
	{
		#if debug
		//trace("Coach::Coach");
		#end
		super(jsonUser, authorised);
	}
	inline public static function CREATE_DUMMY():Coach
	{
		#if debug
		//trace("Coach::CREATE_DUMMY created");
		#end
		return new Coach({
			directReports:[{samaccountname:"apeter",mail:"Aron.Peter@salt.ch",distinguishedname:"CN=Péter Áron,OU=Users,OU=Domain-Users,DC=ad,DC=salt,DC=ch",description:"25840 / Internal employee / Translator and Communication Specialist"},{samaccountname:"awarmers",mail:"Alexandra.Warmers@salt.ch",distinguishedname:"CN=Warmers Alexandra,OU=Users,OU=Domain-Users,DC=ad,DC=salt,DC=ch",description:"30680 / Internal employee / Translator and Communication Specialist"},{samaccountname:"grappaz1",mail:"Giovanna.Rappazzo@salt.ch",distinguishedname:"CN=Rappazzo Giovanna,OU=Users,OU=Domain-Users,DC=ad,DC=salt,DC=ch",description:"30850 / Internal employee / Translator and Communication Specialist"}],
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
			boss:{mail : "fabien.renard@salt.ch", 
			samaccountname : "frenard",distinguishedname : "CN=Renard Fabien,OU=Domain-Generic-Accounts,DC=ad,DC=salt,DC=ch"}
		}, true);
		
	}
	
	inline public static function CREATE_ERROR(error:String):Coach
	{
		return new Coach({
			mail : "error@salt.ch", 
			samaccountname : error,
			title : "User not found or incorrect password", 
		}, false);
	}
}