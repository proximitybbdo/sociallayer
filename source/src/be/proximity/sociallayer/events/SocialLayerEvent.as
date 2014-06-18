package be.proximity.sociallayer.events {
	import flash.events.Event;

	public class SocialLayerEvent extends Event {
		public static const NO_PLATFORM:String = "NoPlatform";
		public static const PLATFORM_READY:String = "PlatformReady";
		public static const READY:String = "Ready";
		
		public static const LOGGED_IN:String = "LoggedIn";
		public static const LOGGED_IN_CANCELED:String = "LoggedInCanceled";
		public static const LOGGED_OUT:String = "LoggedOut";
		
		public static const PERMISSIONS_SET:String = "PermissionsSet";
		public static const PERMISSIONS_NOT_SET:String = "PermissionsNotSet";

		public static const PROFILE_CURRENTUSER:String = "ProfileCurrentFetched";
		public static const PROFILE_CURRENTUSER_NOTLOGGEDIN:String = "ProfileCurrentFetchedNotLoggedIn";
		public static const PROFILE_USER:String = "ProfileUserFetched";

		public static const FRIENDS_USER:String = "FriendsUserFetched";
		public static const FRIENDSIDS_USER:String = "FriendsIDsUserFetched";
		public static const FRIENDS_CURRENTUSER:String = "FriendsCurrentFetched";
		public static const FRIENDSIDS_CURRENTUSER:String = "FriendsIDsCurrentFetched";

		public static const PUBLISH_COMPLETE:String = "PublishComplete";
		public static const PUBLISH_FAILED:String = "PublishFailed";
		public static const MESSAGE_COMPLETE:String = "InviteComplete";

		public static const EXTERNAL_RESULT:String = "ExternalResult";

		public static const ERROR:String = "Error";

		private var _data:*;

		public function SocialLayerEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false, data:* = null) {
			super(type, bubbles, cancelable);

			_data = data;
		}
		
		override public function clone():Event{
			return new SocialLayerEvent(type, bubbles, cancelable, data);
		}

		public function get data():* {
			return _data;
		}
	}
}