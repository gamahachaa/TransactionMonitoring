package;

/**
 * ...
 * @author bb
 */
class Monitoree extends Actor 
{

	public function new(?jsonUser:Dynamic=null, ?authorised:Bool=true) 
	{
		super(jsonUser, authorised);
	}
	inline public static function CREATE_DUMMY(samaccountname:String):Monitoree
	{
		return new Monitoree({
			mail : "Bruno.Baudry@salt.ch", 
			samaccountname : samaccountname, 
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
			memberof : ["Microsoft - Teams Members - Standard", "Customer Operations - Training", "RA-PulseSecure-Laptops-Salt", "SG-PasswordSync", "RA-EasyConnect-Web-Mobile-Qook", "Customer Operations - Knowledge - Management", "Customer Operations - Direct Reports", "Customer Operations - Fiber Back Office", "DOLPHIN_REC", "Application-GIT_SALT-Operator", "Application-GIT_SALT-Visitor", "SG-OCH-WLAN_Users", "SG-OCH-EnterpriseVault_DefaultProvisioningGroup", "Entrust_SMS", "MIS Mobile Users", "GI-EBU-OR-CH-MobileUsers", "Floor Marshalls Biel", "CO_Knowledge And Translation Mgmt", "co training admin_ud", "Exchange_Customer Operations Management_ud", "Exchange_CustomerCareServiceDesign_ud"],
			boss:{mail : "fabien.reanard@salt.ch", 
			samaccountname : "frenard",distinguishedname : "CN=Renard Fabien,OU=Domain-Generic-Accounts,DC=ad,DC=salt,DC=ch"}
		}, true);
	}
	inline public static function CREATE_ERROR(error:String):Monitoree
	{
		return new Monitoree({
			mail : "error@salt.ch", 
			samaccountname : error
		}, false);
	}
}