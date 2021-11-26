package ui;

import haxe.ui.containers.dialogs.MessageBox;

/**
 * ...
 * @author bb
 */
class Communicator extends MessageBox 
{

	public function new() 
	{
		super();
		this.type = MessageBoxType.TYPE_WARNING;
			this.width = 560;
			this.height = 560;
			this.draggable = false;
			this.destroyOnClose = false;
	}
	
}