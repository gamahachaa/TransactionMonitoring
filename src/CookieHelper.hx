package;
import haxe.Exception;
import haxe.Serializer;
import haxe.Unserializer;
import js.Browser;
//import js.Cookie;
import tstool.utils.CookieBB;
import js.html.Location;

/**
 * ...
 * @author bb
 */
class CookieHelper 
{
	var name:String;
	var s:haxe.Serializer;
	//var d:haxe.Unserializer;
	var loc:Location;
	var expire:Int;

	public function new(name:String, ?expire:Int = 86400 * 7) 
	{
		this.name = name;
		this.expire = expire;
		s = new Serializer();
		
		loc = Browser.location;
	}
	public function flush(name:String, o:Dynamic)
	{
		s.serialize(o);
		CookieBB.set(name, s.toString(), expire, loc.pathname, loc.hostname);
	}
	public function clearCockie(name:String)
	{
		CookieBB.remove(name, loc.pathname, loc.hostname);
	}
	public function retrieve(?name:String="")
	{
		var _name = name == "" ?this.name: name;
		if (CookieBB.exists(_name))
		{
			var d = new Unserializer(CookieBB.get(_name));
			return d.unserialize();
		}
		else{
			throw new Exception('Cookie $name not found');
		}
	}
}