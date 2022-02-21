package ui.dialogs;

import haxe.ui.containers.dialogs.MessageBox;

/**
 * ...
 * @author bb
 */
class MarkdownHelp extends MessageBox 
{

	public function new() 
	{
		super();
		this.title = "INFO !! Markdown syntax";
		this.type = MessageBoxType.TYPE_INFO;
		this.messageLabel.htmlText = "Use this following simple markdown syntax in the summaries (Transaction and Monitoring Summary).<br>It will be formated in the e-mail report (not in the app here)";
		//this.messageLabel.htmlText +="<br><br><strong>**Bold**</strong><br><br><em>_italic_</em><br><br ><h1># Title 1 </h1><br><br><h2>## Title 2</h2><br><br><h3>### Title 3 </h3><br><br>- list item 1<br>- list item 2<br><br>1. ordered list item 1<br>2. ordered list item 2";
		this.messageLabel.htmlText += "<br><br><table>";
		this.messageLabel.htmlText += "<tr><td>Markdown</td><td>&rarr;</td><td> Formated</td></tr>";
		this.messageLabel.htmlText += "<tr><td></td><td></td><td></td></tr>";
		this.messageLabel.htmlText += "<tr><td>**Bold**</td><td>&rarr;</td><td>&rarr; <strong>Bold</strong></td></tr>";
		this.messageLabel.htmlText += "<tr><td>_italic_</td><td>&rarr;</td><td> <em>italic</em ></td></tr>";
		this.messageLabel.htmlText += "<tr><td></td><td>&rarr;</td><td><td></td></tr>";
		//this.messageLabel.htmlText += "<tr><td># Title 1</td><td><h1>&rarr; Title 1</h1></td></tr>";
		//this.messageLabel.htmlText += "<tr><td>## Title 2</td><td><h2>&rarr; Title 2</h2></td></tr>";<td>&rarr; >Unordered list<br/></td></tr>";
		this.messageLabel.htmlText += "<tr><td></td><td>Unordered list</td><td> </td></tr>";
		this.messageLabel.htmlText += "<tr><td>- item1<br>- item2</td><td>&rarr;</td><td> <ul><li>item1</li><li>item2</li></ul></td></tr>";
		this.messageLabel.htmlText += "<tr><td></td><td>Oredered list</td><td></td></tr>";
		this.messageLabel.htmlText += "<tr><td>1. item1<br>1. item2</td><td>&rarr;</td><td> <ol><li>item1</li><li>item2</li></ol></td></tr></table>";
		this.messageLabel.htmlText += "(The space after '-' or '1.' is needed and you must do a line break after each list item)";
		
		this.width = 600;
		this.showDialog(true);
	}
	
}