package be.proximity.sociallayer.platform {
	import be.proximity.framework.logging.Logr;
	import be.proximity.sociallayer.data.SocialUser;
	import be.proximity.sociallayer.events.SocialLayerEvent;
	import be.wellconsidered.apis.osbridge.OSBridge;
	import be.wellconsidered.apis.osbridge.constants.OSMessageTypes;
	import be.wellconsidered.apis.osbridge.data.*;
	import be.wellconsidered.apis.osbridge.events.OSBridgeEvents;
	
	import flash.system.Security;

	public class NetlogPlatform extends AbstractPlatform implements IPlatform {
		private var _platform:OSBridge;

		public function NetlogPlatform() {
			Security.allowDomain("*.netlog.com");
		}

		public override function init(... arguments):void {
			_platform = new OSBridge();
			_platform.addEventListener(OSBridgeEvents.INIT, onNetlogInit);
			_platform.init();
		}

		private function onNetlogInit(e:OSBridgeEvents):void {
			_platform.removeEventListener(OSBridgeEvents.INIT, onNetlogInit);

			dispatchEvent(new SocialLayerEvent(SocialLayerEvent.PLATFORM_READY));
		}

		public override function getFriendsIDsOfUser(userid:String):void {
			trace("NetlogPlatform :: getFriendsIDsOfUser");

			function onOSFetched(e:OSBridgeEvents):void {
				trace("NetlogPlatform :: getFriendsIDsOfUser Result");

				_platform.removeEventListener(OSBridgeEvents.FRIENDS, onOSFetched);

				var result:Array = [];

				for (var i:String in e.data) {
					var ou:OSUser = new OSUser(e.data[i]);
					result.push(new SocialUser({id: ou.id, gender: ou.gender.toLowerCase(), profilePicture: getProfilePic(ou.thumbnailUrl), thumbnailUrl: ou.thumbnailUrl, nickName: ou.nickname, familyName: ou.familyName, firstName: ou.givenName, profileUrl: ou.profileUrl, isViewer: ou.isViewer, isOwner: ou.isOwner}));
				}

				result.sortOn(["firstName", "familyName"]);

				dispatchEvent(new SocialLayerEvent(SocialLayerEvent.FRIENDSIDS_USER, true, false, result));
			}

			_platform.addEventListener(OSBridgeEvents.FRIENDS, onOSFetched);
			_platform.getFriends(userid);
		}

		public override function getFriendsOfUser(userid:String):void {
			trace("NetlogPlatform :: getFriendsOfUser");

			function onOSFetched(e:OSBridgeEvents):void {
				trace("NetlogPlatform :: getFriendsOfUser Result");

				_platform.removeEventListener(OSBridgeEvents.FRIENDS, onOSFetched);

				var result:Array = [];

				for (var i:String in e.data) {
					var ou:OSUser = new OSUser(e.data[i]);
					
					result.push(new SocialUser({id: ou.id, gender: ou.gender.toLowerCase(), profilePicture: getProfilePic(ou.thumbnailUrl), thumbnailUrl: ou.thumbnailUrl, nickName: ou.nickname, familyName: ou.familyName, firstName: ou.givenName, profileUrl: ou.profileUrl, isViewer: ou.isViewer, isOwner: ou.isOwner}));
				}

				result.sortOn(["firstName", "familyName"]);

				dispatchEvent(new SocialLayerEvent(SocialLayerEvent.FRIENDS_USER, true, false, result));
			}

			_platform.addEventListener(OSBridgeEvents.FRIENDS, onOSFetched);
			_platform.getFriends(userid);
		}

		public override function getFriendsIDsOfCurrentUser():void {
			trace("NetlogPlatform :: getFriendsIDsOfCurrentUser " + (_currentUserFriendsIDs ? _currentUserFriendsIDs.length : ""));

			if (_currentUserFriendsIDs && _currentUserFriendsIDs.length > 0)
				dispatchEvent(new SocialLayerEvent(SocialLayerEvent.FRIENDSIDS_CURRENTUSER, true, false, _currentUserFriendsIDs));
			else {
				function onOSFetched(e:OSBridgeEvents):void {
					trace("NetlogPlatform :: getFriendsIDsOfCurrentUser Result");

					_platform.removeEventListener(OSBridgeEvents.FRIENDS, onOSFetched);

					_currentUserFriends = [];
					_currentUserFriendsIDs = [];

					for (var i:String in e.data) {
						var ou:OSUser = new OSUser(e.data[i]);
						
						_currentUserFriendsIDs.push(ou.id);
						_currentUserFriends.push(new SocialUser({id: ou.id, gender: ou.gender.toLowerCase(), profilePicture: getProfilePic(ou.thumbnailUrl), thumbnailUrl: ou.thumbnailUrl, nickName: ou.nickname, familyName: ou.familyName, firstName: ou.givenName, profileUrl: ou.profileUrl, isViewer: ou.isViewer, isOwner: ou.isOwner}));
					}

					_currentUserFriends.sortOn(["firstName", "familyName"]);

					dispatchEvent(new SocialLayerEvent(SocialLayerEvent.FRIENDSIDS_CURRENTUSER, true, false, _currentUserFriendsIDs));
				}

				_platform.addEventListener(OSBridgeEvents.FRIENDS, onOSFetched);
				_platform.getFriends((_platform as OSBridge).viewer.id);
			}
		}

		public override function getFriendsOfCurrentUser():void {
			trace("NetlogPlatform :: getFriendsOfCurrentUser " + (_currentUserFriends ? _currentUserFriends.length : ""));

			if (_currentUserFriends && _currentUserFriends.length > 0)
				dispatchEvent(new SocialLayerEvent(SocialLayerEvent.FRIENDS_CURRENTUSER, true, false, _currentUserFriends));
			else {
				function onOSFetched(e:OSBridgeEvents):void {
					trace("NetlogPlatform :: getFriendsOfCurrentUser Result");

					_platform.removeEventListener(OSBridgeEvents.FRIENDS, onOSFetched);

					_currentUserFriends = [];
					_currentUserFriendsIDs = [];

					for (var i:String in e.data) {
						var ou:OSUser = new OSUser(e.data[i]);
						
						_currentUserFriendsIDs.push(ou.id);
						_currentUserFriends.push(new SocialUser({id: ou.id, gender: ou.gender.toLowerCase(), profilePicture: getProfilePic(ou.thumbnailUrl), thumbnailUrl: ou.thumbnailUrl, nickName: ou.nickname, familyName: ou.familyName, firstName: ou.givenName, profileUrl: ou.profileUrl, isViewer: ou.isViewer, isOwner: ou.isOwner}));
					}

					_currentUserFriends.sortOn(["firstName", "familyName"]);

					dispatchEvent(new SocialLayerEvent(SocialLayerEvent.FRIENDS_CURRENTUSER, true, false, _currentUserFriends));
				}

				_platform.addEventListener(OSBridgeEvents.FRIENDS, onOSFetched);
				_platform.getFriends((_platform as OSBridge).viewer.id);
			}
		}

		public override function getProfileCurrentUser():void {
			trace("NetlogPlatform :: getProfileCurrentUser (" + (_currentUserProfile ? true : false) + ")");

			if (_currentUserProfile)
				dispatchEvent(new SocialLayerEvent(SocialLayerEvent.PROFILE_CURRENTUSER, true, false, _currentUserProfile));
			else {
				function onOSFetched(e:OSBridgeEvents):void {
					trace("NetlogPlatform :: getProfileCurrentUser Result");

					_platform.removeEventListener(OSBridgeEvents.CURRENT_USER, onOSFetched);
					_platform.removeEventListener(OSBridgeEvents.CURRENT_USER_NOT_LOGGED_IN, onOSFetchedNOT);

					_currentUserProfile = new SocialUser({id: _platform.viewer.id, gender: _platform.viewer.gender.toLowerCase(), profilePicture: getProfilePic(_platform.viewer.thumbnailUrl), thumbnailUrl: _platform.viewer.thumbnailUrl, nickName: _platform.viewer.nickname, familyName: _platform.viewer.familyName, firstName: _platform.viewer.givenName, profileUrl: _platform.viewer.profileUrl, isViewer: _platform.viewer.isViewer, isOwner: _platform.viewer.isOwner});

					dispatchEvent(new SocialLayerEvent(SocialLayerEvent.PROFILE_CURRENTUSER, true, false, _currentUserProfile));
				}

				function onOSFetchedNOT(e:OSBridgeEvents):void {
					trace("NetlogPlatform :: getProfileCurrentUser NOT LOGGED IN");

					_platform.removeEventListener(OSBridgeEvents.CURRENT_USER, onOSFetched);
					_platform.removeEventListener(OSBridgeEvents.CURRENT_USER_NOT_LOGGED_IN, onOSFetchedNOT);

					_currentUserProfile = null;

					dispatchEvent(new SocialLayerEvent(SocialLayerEvent.PROFILE_CURRENTUSER_NOTLOGGEDIN, true, false, _currentUserProfile));
				}

				_platform.addEventListener(OSBridgeEvents.CURRENT_USER, onOSFetched);
				_platform.addEventListener(OSBridgeEvents.CURRENT_USER_NOT_LOGGED_IN, onOSFetchedNOT);
				_platform.getCurrentUser();
			}
		}

		public override function getProfileOfUser(userid:String):void {
			trace("NetlogPlatform :: getProfileOfUser");

			function onOSFetched(e:OSBridgeEvents):void {
				trace("NetlogPlatform :: getProfileOfUser Result");

				_platform.removeEventListener(OSBridgeEvents.USER_PROFILE, onOSFetched);

				var ou:OSUser = e.data as OSUser;

				dispatchEvent(new SocialLayerEvent(SocialLayerEvent.PROFILE_USER, true, false, new SocialUser({id: ou.id, gender: ou.gender.toLowerCase(), profilePicture: getProfilePic(_platform.viewer.thumbnailUrl), thumbnailUrl: ou.thumbnailUrl, nickName: ou.nickname, familyName: ou.familyName, firstName: ou.givenName, profileUrl: ou.profileUrl, isViewer: ou.isViewer, isOwner: ou.isOwner})));
			}

			_platform.addEventListener(OSBridgeEvents.USER_PROFILE, onOSFetched);
			_platform.getUserProfile(userid);
		}

		public override function publishPost(title:String, body:String, params:Object = null):void {
			trace("NetlogPlatform :: publishPost");
			
			_platform.addEventListener(OSBridgeEvents.ACTIVITY_POSTED, onOsBridgePublishSent);
			_platform.postActivity("", null, title, body);
		}
		
		private function onOsBridgePublishSent(e:OSBridgeEvents):void {
			trace("NetlogPlatform :: publishPost Result");
			
			_platform.removeEventListener(OSBridgeEvents.ACTIVITY_POSTED, onOsBridgePublishSent);
			
			dispatchEvent(new SocialLayerEvent(SocialLayerEvent.PUBLISH_COMPLETE, true, false));
		}

		public override function sendMessage(title:String, body:String, friends:Array, params:Object = null):void {
			trace("NetlogPlatform :: sendMessage");

			_platform.addEventListener(OSBridgeEvents.MESSAGE_SENT, onOsBridgeMessageSent);
			_platform.addEventListener(OSBridgeEvents.MESSAGE_SENT_FAILED, onFetchingError);

			_platform.sendMessage(new OSMessage(title, body, OSMessageTypes.NOTIFICATION, params), friends);
		}
		
		private function onOsBridgeMessageSent(e:OSBridgeEvents):void {
			trace("NetlogPlatform :: sendMessage Result");
			
			_platform.removeEventListener(OSBridgeEvents.MESSAGE_SENT, onOsBridgeMessageSent);
			
			dispatchEvent(new SocialLayerEvent(SocialLayerEvent.MESSAGE_COMPLETE, true, false));
		}
		
		private function getProfilePic(path:String):String{
			if(path){
				var pattern:RegExp = /\*?\/tt\//; // replaces the path _s or _q for the _n, which should bring us a big picture
				
				if(path.search(pattern) != -1)
					return String(path.replace(pattern, "/oo/"));
				else
					return path;
			}
			
			return "";
		}
	}
}