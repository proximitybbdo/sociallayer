package be.proximity.sociallayer.platform {

	public interface IPlatform {
		function init(... arguments):void

		function getFriendsOfUser(userid:String):void;

		function getFriendsIDsOfUser(userid:String):void;

		function getFriendsOfCurrentUser():void;

		function getFriendsIDsOfCurrentUser():void;

		function getProfileCurrentUser():void;

		function getProfileOfUser(userid:String):void;

		function sendMessage(title:String, body:String, friends:Array, params:Object = null):void;

		function publishPost(title:String, body:String, params:Object = null):void;
	}
}