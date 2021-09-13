package;
import haxe.Exception;
import haxe.Serializer;
import haxe.Unserializer;
import js.Browser;
import js.Cookie;
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

	public function new(name:String, ?expire:Int = 86400 * 15) 
	{
		this.name = name;
		this.expire = expire;
		s = new Serializer();
		
		loc = Browser.location;
	}
	public function flush(name:String, o:Dynamic)
	{
		s.serialize(o);
		Cookie.set(name, s.toString(), expire, loc.pathname, loc.hostname);
	}
	public function clearCockie(name:String)
	{
		Cookie.remove(name, loc.pathname, loc.hostname);
	}
	public function retrieve(name:String)
	{
		if (Cookie.exists(name))
		{
			var d = new Unserializer(Cookie.get(name));
			return d.unserialize();
		}
		else{
			throw new Exception('Cookie $name not found');
		}
	}
}