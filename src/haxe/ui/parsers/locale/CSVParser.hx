package haxe.ui.parsers.locale;

/**
 * ...
 * @author bb
 */
class CSVParser extends KeyValuesParser 
{
	public function new() 
	{
		super();
		this.SEPARATOR = ";";
		this.COMMENT_STRING = "//";
		this.STRICT = false;
	}
	
}