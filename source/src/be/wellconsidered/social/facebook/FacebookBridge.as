/**
 * @author Pieter Michels
 * pieter@wellconsidered.be
 *
 * Open source under the GNU Lesser General Public License (http://www.opensource.org/licenses/lgpl-license.php)
 * Copyright © 2009 Pieter Michels / wellconsidered
 * 
 * This library is free software; you can redistribute it and/or modify it under the terms of the GNU Lesser General Public License 
 * as published by the Free Software Foundation; either version 2.1 of the License, or (at your option) any later version.
 * This library is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty 
 * of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.
 * You should have received a copy of the GNU Lesser General Public License along with this library; 
 * if not, write to the Free Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA 
 */
package be.wellconsidered.social.facebook
{
	import be.wellconsidered.social.facebook.events.FacebookBridgeEvent;
	
	import flash.events.EventDispatcher;
	import flash.external.ExternalInterface;
	
	[Event(name="result", type="be.wellconsidered.social.facebook.events.FacebookBridgeEvent")]
	
	[Event(name="error", type="be.wellconsidered.social.facebook.events.FacebookBridgeEvent")]
	
	public class FacebookBridge extends EventDispatcher
	{
		private static var _instance:FacebookBridge;
		
		public function FacebookBridge(se:SingletonEnforcer) {
		}
		
		public static function getInstance():FacebookBridge {
			if(!_instance) { 
				_instance = new FacebookBridge(new SingletonEnforcer());
				
				trace("FacebookBridge :: getInstance");
				
				ExternalInterface.addCallback("handleJSCall", _instance.handleJSCall);
			}
		
			return _instance;
		}
		
		public function init():void {
			trace("FacebookBridge :: init");
			
			ExternalInterface.call("_fbFlashBridge.onFlashLoaded");
			ExternalInterface.call("_fbFlashBridge.checkLogin");
		}
		
		public function call(method:String, ... args):void {
			trace("FacebookBridge :: call :: " + method);
			
			// ExternalInterface.call("_fbFlashBridge." + method, args);
			
			(ExternalInterface.call as Function).apply(this, ["_fbFlashBridge." + method].concat(args));
		}
		
		private function handleJSCall(data:Array):void {
			trace("FacebookBridge :: handleJSCall :: " + String(data[0]));
			
			dispatchEvent(new FacebookBridgeEvent(FacebookBridgeEvent.RESULT, false, true, String(data[0]), data[1]));
		}
		
		public function print_r(obj:*, level:int = 0, output:String = ""):* {
		    var tabs:String = "";
		    
		    for(var i:int = 0; i < level; i++, tabs += "\t") {}
		    
		    for(var child:* in obj) {
		        output += tabs +"["+ child +"] => "+ obj[child];
		        
		        var childOutput:String = FacebookBridge.getInstance().print_r(obj[child], level+1);
		        
		        if(childOutput != '') output += ' {\n'+ childOutput + tabs +'}';
		        
		        output += "\n";
		    }
		    
		    return output;
		 }	
	}
}

internal class SingletonEnforcer {}