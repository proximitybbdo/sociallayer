package be.proximity.sociallayer {
	import be.proximity.sociallayer.events.SocialLayerEvent;
	import be.proximity.sociallayer.platform.*;
	
	import flash.display.*;
	import flash.events.Event;
	import flash.system.Security;

	public class SocialLayer extends Sprite implements IPlatform {
		private var _loaderInfo:LoaderInfo;

		private var _platform:AbstractPlatform;
		private var _platformType:String = "";
		private var _platformReady:Boolean = false;

		public const PLATFORM_NETLOG:String = "netlog";
		public const PLATFORM_NETLOG_GAME:String = "netlog_game";
		public const PLATFORM_FB:String = "facebook";
		public const PLATFORM_FB_CONNECT:String = "facebook_connect";
		
		[Event(name="NoPlatform", type="be.proximity.sociallayer.events.SocialLayerEvent")]
		[Event(name="PlatformReady", type="be.proximity.sociallayer.events.SocialLayerEvent")]
		[Event(name="Ready", type="be.proximity.sociallayer.events.SocialLayerEvent")]
		[Event(name="LoggedIn", type="be.proximity.sociallayer.events.SocialLayerEvent")]
		[Event(name="LoggedOut", type="be.proximity.sociallayer.events.SocialLayerEvent")]
		[Event(name="PermissionsSet", type="be.proximity.sociallayer.events.SocialLayerEvent")]
		[Event(name="ProfileCurrentFetched", type="be.proximity.sociallayer.events.SocialLayerEvent")]
		[Event(name="ProfileCurrentFetchedNotLoggedIn", type="be.proximity.sociallayer.events.SocialLayerEvent")]
		[Event(name="ProfileUserFetched", type="be.proximity.sociallayer.events.SocialLayerEvent")]
		[Event(name="FriendsUserFetched", type="be.proximity.sociallayer.events.SocialLayerEvent")]
		[Event(name="FriendsIDsUserFetched", type="be.proximity.sociallayer.events.SocialLayerEvent")]
		[Event(name="FriendsCurrentFetched", type="be.proximity.sociallayer.events.SocialLayerEvent")]
		[Event(name="FriendsIDsCurrentFetched", type="be.proximity.sociallayer.events.SocialLayerEvent")]
		[Event(name="PublishComplete", type="be.proximity.sociallayer.events.SocialLayerEvent")]
		[Event(name="PublishFailed", type="be.proximity.sociallayer.events.SocialLayerEvent")]
		[Event(name="InviteComplete", type="be.proximity.sociallayer.events.SocialLayerEvent")]
		[Event(name="ExternalResult", type="be.proximity.sociallayer.events.SocialLayerEvent")]
		[Event(name="Error", type="be.proximity.sociallayer.events.SocialLayerEvent")]

		/**
		 * Constructor
		 *
		 * @param 	loaderInfo 	Stage LoaderInfo
		 * @param 	p_parameter String for platformtype
		 */
		public function SocialLayer(loaderInfo:LoaderInfo, p_parameter:String = "") {
			_loaderInfo = loaderInfo;
			_platformType = p_parameter.length > 0 ? p_parameter : _loaderInfo.parameters.p;

			Security.allowDomain("*");
		}

		/**
		 * Initialise SocialLayer
		 *
		 * @param 	arguments 	Arguments for a specific platform. Only FacebookPlatform requires arguments. (API key and Secret key)
		 */
		public function init(... arguments):void {
			trace("SocialLayer :: init :: " + _platformType);

			switch (_platformType) {
				case PLATFORM_FB:

					_platform = new FacebookPlatform(_loaderInfo);

					break;

				case PLATFORM_FB_CONNECT:

					_platform = new FacebookConnectPlatform(_loaderInfo);

					break;

				case PLATFORM_NETLOG:

					_platform = new NetlogPlatform();

					break;

				case PLATFORM_NETLOG_GAME:

					_platform = new NetlogGamePlatform();

					addEventListener(SocialLayerEvent.EXTERNAL_RESULT, (_platform as NetlogGamePlatform).onExternalResult);

					break;

				default:

					_platformType = "";

					dispatchEvent(new SocialLayerEvent(SocialLayerEvent.NO_PLATFORM));

					break;

			}

			if (_platform) {
				addChild(_platform);

				trace("SocialLayer :: " + (_platformType.length > 0 ? _platformType : "No Social") + " Platform detected");

				_platform.addEventListener(SocialLayerEvent.PLATFORM_READY, onPlatformInit);
				_platform.init(arguments);
			}
		}

		private function onPlatformInit(e:Event):void {
			trace("SocialLayer :: PlatformInit");

			_platform.removeEventListener(SocialLayerEvent.PLATFORM_READY, onPlatformInit)

			_platformReady = true;

			dispatchEvent(new SocialLayerEvent(SocialLayerEvent.READY));
		}

		/**
		 * Get all friends of given user.
		 *
		 * @param 	userid 	ID of user on platform
		 */
		public function getFriendsOfUser(userid:String):void {
			_platform.getFriendsOfUser(userid);
		}

		/**
		 * Get all friends of current user
		 */
		public function getFriendsOfCurrentUser():void {
			_platform.getFriendsOfCurrentUser();
		}

		/**
		 * Get ID's of all friends of given user
		 *
		 * @param 	userid 	ID of user on platform
		 */
		public function getFriendsIDsOfUser(userid:String):void {
			_platform.getFriendsIDsOfUser(userid);
		}

		/**
		 * Get ID's of all friends of current user
		 */
		public function getFriendsIDsOfCurrentUser():void {
			_platform.getFriendsIDsOfCurrentUser();
		}

		/**
		 * Get profile of current user.
		 */
		public function getProfileCurrentUser():void {
			_platform.getProfileCurrentUser();
		}

		/**
		 * Get profile of hiven user
		 *
		 * @param 	userid 	ID of user on platform
		 */
		public function getProfileOfUser(userid:String):void {
			_platform.getProfileOfUser(userid);
		}

		/**
		 * Publish a post on platform. Either wall post (Facebook) or notification (Netlog)
		 *
		 * @param	title	Published post title
		 * @param	body	Published post content
		 * @param	params	Object with extra parameters (Netlog: {friends: [], params: {testParam: "GUID"}]} or Facebook: {href: "http://www.google.be", media: [{type: "image", src: "http://www.google.be/image.jpg", href: "http://www.google.com"}]}; Object can contain 'target_id': this publishes the stream post to a users wall stream
		 */
		public function publishPost(title:String, body:String, params:Object = null):void {
			_platform.publishPost(title, body, params);
		}

		/**
		 * Send message on platform 
		 *
		 * @param	title	Message title
		 * @param	body	Published post content
		 * @param	friends	Array of friends
		 * @param	params	Object with extra parameters (Netlog: {params: {testParam: "GUID"}]} or Facebook: {href: "http://www.google.be", media: [{type: "image", src: "http://www.google.be/image.jpg", href: "http://www.google.com"}]};
		 */
		public function sendMessage(title:String, body:String, friends:Array, params:Object = null):void {
			_platform.sendMessage(title, body, friends, params);
		}

		/**
		 * Get platform Class for specific calls
		 */
		public function get platform():IPlatform {
			return _platform;
		}

		/**
		 * Get platform type
		 */
		public function get platformType():String {
			return _platformType;
		}

		/**
		 * Is platform initialised
		 */
		public function get platformReady():Boolean {
			return _platformReady;
		}
	}
}