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
typedef Status =
{
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
	public static function stringyfyMap(map:Map<String,Dynamic>):Map<String,String>
	{
		var m:Map<String,String> = [];
		for ( k => v in map)
		{
			m.set(k, Std.string(v));
		}
		return m;
	}
	
	public static function arrayToCsv(values:Array<Array<String>>, ?sep:String = ",", ?endOfLine:String="\n"):String
	{
		var seperator:String = sep;
		var buffer:StringBuf= new StringBuf();
		var eol = endOfLine;   //default line breaker is \n
		if (values.length < 1) throw "Invalid value.";
		for (v in values)
		{
			var vindex = 0;
			for (jDyn in v)
			{
				var j = Std.string(jDyn);
				var jindex = 0;
				//trace(j);
				//trace(j.indexOf("t"));
				var addQuote = j.indexOf(seperator.charAt(0)+"") > -1 || j.indexOf('"') > -1 || j.indexOf(eol) > -1? true:false;  //add quote if part of the seperator exists in the current string
				if (addQuote) buffer.addChar('"'.code);
				for (k in 0...j.length)
				{
					var code = j.charCodeAt(k);
					if (code == '"'.code && addQuote)
					{
						buffer.addChar(code);
					}
					buffer.addChar(code);
				}
				if (addQuote) buffer.addChar('"'.code);
				if (jindex < v.length - 1) buffer.add(seperator);
				jindex++;
			}
			if (vindex < values.length - 1) buffer.add(eol);
			vindex++;
		}
		var tmp = buffer.toString();
		buffer = new StringBuf();
		return tmp;
	}
	public static function arrayDynamicToArrayArrayString(a:Array<Dynamic>):Array<Array<String>>
	{
		var head = Reflect.fields(a[0]);
		var t = [];
		var t0 = [];
		for (j in head)
		{
			t0.push(j);
		}
		t.push(t0);
		for ( i in a )
		{
			var t1 = [];
			for (h in head)
			{
				t1.push(Reflect.getProperty(i, h));
			}
			t.push(t1);
		}
		return t;
	}

}