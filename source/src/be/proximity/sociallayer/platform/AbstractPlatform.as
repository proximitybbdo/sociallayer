package be.proximity.sociallayer.platform {
	import be.proximity.framework.logging.Logr;
	import be.proximity.sociallayer.data.SocialUser;
	
	import flash.display.Sprite;
	import flash.events.Event;

	public class AbstractPlatform extends Sprite implements IPlatform {
		protected var _currentUserFriends:Array;
		protected var _currentUserFriendsIDs:Array;
		protected var _currentUserProfile:SocialUser;

		public function AbstractPlatform() {

		}

		public function init(... arguments):void {

		}

		public function getFriendsOfUser(userid:String):void {

		}

		public function getFriendsOfCurrentUser():void {

		}

		public function getFriendsIDsOfUser(userid:String):void {

		}

		public function getFriendsIDsOfCurrentUser():void {

		}

		public function getProfileCurrentUser():void {

		}

		public function getProfileOfUser(userid:String):void {

		}

		public function sendMessage(title:String, body:String, friends:Array, params:Object = null):void {

		}

		public function publishPost(title:String, body:String, params:Object = null):void {

		}

		protected function onFetchingError(e:Event):void {
			trace("onFetchingError");
		}
		
		protected function leadingZero(value:String):String {
			return (value.length == 1) ? "0" + value : value;
		}
	}
}