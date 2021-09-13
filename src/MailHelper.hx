package;

import haxe.Http;
import haxe.Json;
import signals.Signal1;

/**
 * ...
 * @author bb
 */
enum Parameters
{
	subject;
	from_email;
	from_full_name;
	to_email;
	to_full_name;
	cc_email;
	cc_full_name;
	bcc_email;
	bcc_full_name;
	body;
}
typedef Result =
{
	var status:String;
	var error:String;
	var additional:String;
}
class MailHelper extends Http
{
	
	public var errorSignal:signal.Signal1<Dynamic>;
	public var successSignal:signal.Signal1<Result>;
	public var statusSignal:signal.Signal1<Int>;
	////////////////////////////////////////////////
	var values:Map<Parameters,Dynamic>;
	var nullKeys:Array<String>;
	var canRequest:Bool;
	var _mainDebug:Bool;
	////////////////////////////////////////////////
	public function new(url:String)
	{
		super(url);
		_mainDebug = url.indexOf("salt.ch") >-1;
		this.async = true;
		values = new Map<Parameters,Dynamic>();
		values.set(from_email, "");
		values.set(to_email, "");
		values.set(subject, "");
		canRequest = true;
		this.onData = ondata;
		this.onError = onerror;
		this.onStatus = onstatus;
		successSignal = new Signal1<Result>();
		statusSignal = new Signal1<Int>();
		errorSignal = new Signal1<Dynamic>();
	}
	//////////////////// PUBLIC /////////////////////////
	public function setFrom(reciepient:String,?fullname:String="")
	{
		values.set(from_email, reciepient);
		if(fullname!="")
			values.set(from_full_name, fullname);
		
	}
	/**
	 * @todo allow multiple (now we are passing an array but then passing only recipient[0])
	 * @param	recipient
	 */
	public function setTo(recipient:Array<String>)
	{
		values.set(to_email, recipient[0]);
	}
	/**
		 * @todo allow multiple (now we are passing an array but then passing only recipient[0])
		 * @param	recipient
		 */
	public function setCc(recipient:Array<String>)
	{
		values.set(cc_email, recipient[0]);
	}
	/**
		 * @todo allow multiple (now we are passing an array but then passing only recipient[0])
		 * @param	recipient
		 */
	public function setBcc(recipient:Array<String>)
	{
		values.set(bcc_email, recipient[0]);
	}
	public function setBody(content:String, ?addCommonStyle:Bool=true, ?customeStyle:String="")
	{
		var b = "";
		b += (addCommonStyle || customeStyle != "")? '<style type="text/css">${setCommonStyle()}$customeStyle</style>':"";
		b += content;
		values.set(body, '<body>$b</body>');
	}
	public function setSubject(content:String)
	{
		values.set(subject, content);
	}
	/**
	 * @todo replace by haxe css
	 */
	public function setCommonStyle()
	{
		var b = "";
		//var b = '<style type="text/css">';
		b += 'table {border-collapse: collapse;}';
		b += '@font-face {font-family: "Superior"; src: url("http://intranet.salt.ch/static/fonts/superior/SuperiorTitle-Black.woff") format("woff"); font-weight: normal;}';
		b += '@font-face {font-family: "Univers"; src: url("http://intranet.salt.ch/static/fonts/univers/ecf89914-1896-43f6-a0a0-fe733d1db6e7.woff") format("woff"); font-weight: normal;}';
		b += 'h3,h4,h5,h5 {color: #65a63c;}';
		b += 'body, table, td, li, span, h3,h4,h5,h5  {font-family: "Univers", Arial, Helvetica, sans-serif !important;}';
		b += 'h2{color: #000000; font-family: "Superior" !important;}';
		b += 'li{font-size: 11pt !important; padding-top:8px !important;  margin-top:8px !important;}';
		b += 'li em{font-size: 9pt !important;}';
		b += 'em{color:#D95350;}';
		//b += '</style>';
		//http://intranet.salt.ch/static/fonts/superior/SuperiorTitle-Black.woff
		//params.set(body, b);
		//params.set(body, b);
		return b;
	}
	public function send(?dispatch:Bool=true)
	{
		//#if debug
		//trace("MailHelper::send::dispatch", dispatch );
		//trace(values);
		//#end
		prepareParams();
		if (dispatch){
			
			#if debug
				if (_mainDebug){
					this.request(true);
				}
				else{
					trace(values);
				}
			
			#else
				this.request(true);
			#end
		}
		else{
			#if debug
				trace(values);
			#end
			successSignal.dispatch({status:"success",error:"", additional:"training"});
		}
	}
	////////////////////////////////////////////////////
	function onerror(msg:String)
	{
		//#if debug
		//trace("MailHelper::onerror::msg", msg );
		//#end
		errorSignal.dispatch(msg);
	}
	function ondata(data:String)
	{
		var s:Result = Json.parse(data);
		#if debug
		trace("MailHelper::ondata::s", s );
		#end
		successSignal.dispatch(s);
	}
	function onstatus(status:Int)
	{
		//#if debug
		//trace("MailHelper::onstatus::status", status );
		//#end
		statusSignal.dispatch(status);
	}
	
	function prepareParams()
	{
		nullKeys = [];
		for ( k => v in values)
		{
			if (v == null || v.trim() == "")
			{
				nullKeys.push(Std.string(k));
				canRequest = false;
			}
			else{
				this.setParameter(Std.string(k), v);
			}
		}
	}
}