package haxe.ui.parsers.locale;

using StringTools;

class KeyValuesParser extends LocaleParser {
	var SEPARATOR:String = "";
	var COMMENT_STRING:String = "";
	var STRICT:Bool = true; // do not allow parser to continue if a line is incorrect
    public function new() {
        super();
    }
    public override function parse(data:String):Map<String, String> {
		if (SEPARATOR == "" ||  COMMENT_STRING == "")
		{
			throw "separator and comment needs implementation";
		}
        var result:Map<String, String> = new Map<String, String>();
        var lines = data.split("\n");
        for (line in lines) {
            line = line.trim();
            if (line.length == 0 || line.startsWith(COMMENT_STRING)) {
                continue;
            }

            var separator:Int = line.indexOf(SEPARATOR);
            if (separator == -1) {
				if(STRICT)
					throw 'Locale parser: Invalid line ${line}';
				else continue;
            }

            var key = line.substr(0, separator).trim();
            var content = line.substr(separator + 1);
            result.set(key, content);
        }

        return result;
    }
}
