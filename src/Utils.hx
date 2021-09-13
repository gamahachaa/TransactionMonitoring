package;
import haxe.ui.core.Component;

/**
 * ...
 * @author bb
 */
typedef Ids =
{
	var single:String;
	var full:String;
}
typedef Status = {
	var canSubmit:Bool;
	var message:Array<String>;
}
class Utils 
{
	public static function GET_PARENT_PATH(c:Component, ?path="")
	{
		var parent = c.parentComponent;
		var t = "";
		if (parent == null)
		{
			var t = path.split(".");
			t.reverse();
			return t.join(".");
		}
		else
		{
			if (parent.id != null && parent.id != "")
			{
				//if(parent.id !="main" && parent.id!="tabview-content")
				if (parent.id != "main")
				{
					if (path!="")
						path = path + "." + parent.id;
					else
						path = parent.id;
				}
			}
			return GET_PARENT_PATH(parent, path);
		}

	}
	public static function GET_ID_FOM_FULL_ID(id:String):String
	{
		var t = id.split(".");
		t.reverse();
		return t[0];
	}
	public static function GET_GRANPA_ID(comp:Component):Ids
	{
		var id = GET_PARENT_PATH(comp, comp.id);
		var idTab = id.split(".");
		idTab.pop();
		idTab.pop();
		
		return { single: idTab[idTab.length - 1], full: idTab.join(".") };
	}
	public static function mergeMaps<A,B>(a:Map<A,B>, b:Map<A,B>):Map<A,B>
	{
		for ( k => v in b)
		{
			a.set(k, v);
		}
		return a;
	}
	public static function addPrefixKey<T>(prefix:String, map:Map<String,T>):Map<String,T>
	{
		var m:Map<String,T> = [];
		for (k => v in map)
		{
			m.set('$prefix$k', v);
		}
		return m;
	}
	
}