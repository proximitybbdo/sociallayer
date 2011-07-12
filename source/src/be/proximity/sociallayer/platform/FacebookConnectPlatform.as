/**
 * TODO
 * 		Permissions checken (1 voor 1) http://wiki.developers.facebook.com/index.php/Users.hasAppPermission
 */
package be.proximity.sociallayer.platform {
	import be.proximity.framework.logging.Logr;
	import be.proximity.sociallayer.data.SocialUser;
	import be.proximity.sociallayer.events.SocialLayerEvent;
	import be.wellconsidered.social.facebook.FacebookBridge;
	import be.wellconsidered.social.facebook.events.FacebookBridgeEvent;
	
	import flash.display.LoaderInfo;
	import flash.events.Event;


	public class FacebookConnectPlatform extends AbstractPlatform implements IPlatform {
		private var _loaderInfo:LoaderInfo;
		
		private var _fieldsProfile:Array = ["uid", "pic", "pic_square", "first_name", "last_name", "sex", "name", "locale", "hometown_location", "birthday_date", "contact_email", "email", "timezone", "username", "website", "proxied_email", "is_app_user"];
		private var _platform:FacebookBridge;
		
		private var _session_data:* = null;
		private var _perms:Array = [];
		private var _isLoggedIn:Boolean = false;
		
		private var _currentCall:String = "";
		
		public static var PERM_EMAIL:String = "email";
		public static var PERM_STREAM_READ:String = "read_stream";
		public static var PERM_STREAM_PUBLISH:String = "publish_stream";
		public static var PERM_OFFLINE_ACCESS:String = "offline_access";
		public static var PERM_PHOTO_UPLOAD:String = "photo_upload";
		public static var PERM_EVENT_CREATE:String = "create_event";
		public static var PERM_EVENT_RSVP:String = "rsvp_event";
		public static var PERM_VIDEO_UPLOAD:String = "video_upload";
		public static var PERM_SHARE_ITEM:String = "share_item";
		
		public function FacebookConnectPlatform(loaderInfo:LoaderInfo) {
			super();

			_loaderInfo = loaderInfo;
		}

		public override function init(... arguments):void {
			_platform = FacebookBridge.getInstance(); 
			
			_platform.addEventListener(FacebookBridgeEvent.RESULT, onFBResult, false, 0, true);
			_platform.init();
		
			dispatchEvent(new SocialLayerEvent(SocialLayerEvent.PLATFORM_READY));
		}
		
		private function onFBResult(e:FacebookBridgeEvent):void {
			trace("FacebookConnectPlatform :: " + e.func + " :: " + _currentCall);
			
			// trace("FacebookConnectPlatform :: " + FacebookBridge.getInstance().print_r(arrUsers));
			
			var i:int;
			
			switch(e.func) {
				case "PERMISSIONS_SET":
				
					dispatchEvent(new SocialLayerEvent(SocialLayerEvent.PERMISSIONS_SET, true, false));
				
					break;
					
				case "PERMISSIONS_NOT_SET":
				
					dispatchEvent(new SocialLayerEvent(SocialLayerEvent.PERMISSIONS_NOT_SET, true, false));
				
					break;
				
				case "NOTIFICATION_SENT":
				
					dispatchEvent(new SocialLayerEvent(SocialLayerEvent.MESSAGE_COMPLETE, true, false));
				
					break;
					
				case "PUBLISHED_POST":
				
					dispatchEvent(new SocialLayerEvent(SocialLayerEvent.PUBLISH_COMPLETE, true, false));
				
					break;
				
				case "LOGGED_IN_CANCELED":
				
					dispatchEvent(new SocialLayerEvent(SocialLayerEvent.LOGGED_IN_CANCELED, true, false));
					
					break;
				
				case "LOGGED_IN":
					
					_session_data = e.data.session;
					_perms = e.data.perms;
					
					_isLoggedIn = true;
				
					dispatchEvent(new SocialLayerEvent(SocialLayerEvent.LOGGED_IN, true, false));
					
					break;
					
				case "LOGGED_OUT":
					
					_isLoggedIn = true;
				
					dispatchEvent(new SocialLayerEvent(SocialLayerEvent.LOGGED_OUT, true, false));
					
					break;
					
				case "USER_INFO":
					
					_currentUserProfile = new SocialUser({	id: e.data.uid, 
															gender: e.data.sex, 
															thumbnailUrl: e.data.pic_square, 
															profilePicture: e.data.pic, 
															familyName: e.data.last_name, 
															firstName: e.data.first_name, 
															locale: e.data.locale, 
															isAppUser: e.data.is_app_user,
															timezone: e.data.timezone, 
															nickName: e.data.username, 
															birthday_date: e.data.birthday_date, 
															website: e.data.website, 
															proxied_email: e.data.proxied_email, 
															email: e.data.contact_email == null ? (e.data.email == null ? "" : e.data.email) : e.data.contact_email});
					
					if(e.data.hometown_location != null)
						_currentUserProfile.currentLocationCountry = e.data.hometown_location.country;

					dispatchEvent(new SocialLayerEvent(SocialLayerEvent.PROFILE_CURRENTUSER, true, false, _currentUserProfile));
					
					break;
					
				case "USERS_INFO":
				
					var arrUsers:Array = e.data as Array;
					
					switch(_currentCall) {
						case "getFriendsOfCurrentUser":
						
							_currentUserFriends = [];
						
							for(i = 0; i < arrUsers.length; i++)
								_currentUserFriends.push(new SocialUser({	id: arrUsers[i].uid, 
																			gender: arrUsers[i].sex, 
																			thumbnailUrl: arrUsers[i].pic_square ? arrUsers[i].pic_square : "", 
																			profilePicture: arrUsers[i].pic ? arrUsers[i].pic : "", 
																			familyName: arrUsers[i].last_name, 
																			firstName: arrUsers[i].first_name, 
																			isAppUser: arrUsers[i].is_app_user,
																			timezone: arrUsers[i].timezone, 
																			nickName: arrUsers[i].username, 
																			birthday_date: arrUsers[i].birthday_date, 
																			website: arrUsers[i].website, 
																			proxied_email: arrUsers[i].proxied_email, 
																			email: arrUsers[i].contact_email == null ? (arrUsers[i].email == null ? "" : arrUsers[i].email) : arrUsers[i].contact_email}));
							
							dispatchEvent(new SocialLayerEvent(SocialLayerEvent.FRIENDS_CURRENTUSER, true, false, _currentUserFriends));
						
							break;
							
						case "getFriendsOfUser":
						
							var arrFriends:Array = [];
						
							for(i = 0; i < arrUsers.length; i++)
								arrFriends.push(new SocialUser({	id: arrUsers[i].uid, 
																	gender: arrUsers[i].sex, 
																	thumbnailUrl: arrUsers[i].pic_square, 
																	profilePicture: arrUsers[i].pic,
																	familyName: arrUsers[i].last_name, 
																	firstName: arrUsers[i].first_name, 
																	isAppUser: arrUsers[i].is_app_user, 
																	timezone: arrUsers[i].timezone, 
																	nickName: arrUsers[i].username, 
																	birthday_date: arrUsers[i].birthday_date, 
																	website: arrUsers[i].website, 
																	proxied_email: arrUsers[i].proxied_email, 
																	email: arrUsers[i].contact_email == null ? (arrUsers[i].email == null ? "" : arrUsers[i].email) : arrUsers[i].contact_email}));
							
							dispatchEvent(new SocialLayerEvent(SocialLayerEvent.FRIENDS_USER, true, false, arrFriends));
						
							break;
							
						case "getProfileOfUser":
						
							dispatchEvent(new SocialLayerEvent(SocialLayerEvent.PROFILE_USER, true, false, new SocialUser({	id: arrUsers[0].uid, 
																															gender: arrUsers[0].sex, 
																															thumbnailUrl: arrUsers[0].pic_square, 
																															profilePicture: arrUsers[0].pic,
																															familyName: arrUsers[0].last_name, 
																															firstName: arrUsers[0].first_name, 
																															locale: arrUsers[0].locale, 
																															isAppUser: arrUsers[0].is_app_user, 
																															timezone: arrUsers[0].timezone, 
																															nickName: arrUsers[0].username, 
																															birthday_date: arrUsers[0].birthday_date, 
																															website: arrUsers[0].website, 
																															proxied_email: arrUsers[0].proxied_email, 
																															email: arrUsers[0].contact_email == null ? (arrUsers[0].email == null ? "" : arrUsers[0].email) : arrUsers[0].contact_email})));
						
							break;
					}	
				
					break;
				
				case "FRIENDS_GET":
				
					switch(_currentCall) {
						case "getFriendsIDsOfUser":
						
							dispatchEvent(new SocialLayerEvent(SocialLayerEvent.FRIENDSIDS_USER, true, false, []));
						
							break; 
							
						case "getFriendsOfUser":
						
							_currentCall = "getFriendsOfUser";
						
							_platform.call("getUsersInfo", e.data as Array, _fieldsProfile);
						
							break; 
							
						case "getFriendsOfCurrentUser":
						
							_currentUserFriendsIDs = e.data as Array;
						
							_currentCall = "getFriendsOfCurrentUser";
						
							_platform.call("getUsersInfo", _currentUserFriendsIDs, _fieldsProfile);
						
							break; 
							
						case "getFriendsIDsOfCurrentUser":
						
							_currentUserFriendsIDs = e.data as Array;
						
							dispatchEvent(new SocialLayerEvent(SocialLayerEvent.FRIENDSIDS_CURRENTUSER, true, false, _currentUserFriendsIDs));
						
							break; 
					}
				
					break;
			}
		}
		
		public function askPermissions(permissions:Array):void {
			trace("FacebookConnectPlatform :: askPermissions");
			
			_platform.call("askPermissions", permissions.toString());
		}

		public function login(permissions:Array = null):void {
			trace("FacebookConnectPlatform :: login");
			
			_platform.call("login", permissions ? permissions.toString() : "");
		}
		
		public function logout():void {
			trace("FacebookConnectPlatform :: logout");
			
			_platform.call("logout");
		}
		
		public override function getFriendsOfUser(userid:String):void {
			trace("FacebookConnectPlatform :: getFriendsOfUser");
		}

		public override function getFriendsIDsOfUser(userid:String):void {
			trace("FacebookConnectPlatform :: getFriendsIDsOfUser");
		}
		
		public override function getFriendsOfCurrentUser():void {
			trace("FacebookConnectPlatform :: getFriendsOfCurrentUser");
			
			if(_currentUserFriends && _currentUserFriends.length > 0)
				dispatchEvent(new SocialLayerEvent(SocialLayerEvent.FRIENDS_CURRENTUSER, true, false, _currentUserFriends));
			else {
				_currentCall = "getFriendsOfCurrentUser";
				
				_platform.call("getFriends");
			}
		}

		public override function getFriendsIDsOfCurrentUser():void {
			trace("FacebookConnectPlatform :: getFriendsIDsOfCurrentUser");
			
			if(_currentUserFriendsIDs && _currentUserFriendsIDs.length > 0)
				dispatchEvent(new SocialLayerEvent(SocialLayerEvent.FRIENDSIDS_CURRENTUSER, true, false, _currentUserFriendsIDs));
			else {
				_currentCall = "getFriendsIDsOfCurrentUser";
				
				_platform.call("getFriends");
			}
		}

		public override function getProfileCurrentUser():void {
			trace("FacebookConnectPlatform :: getProfileCurrentUser");
			
			if(_currentUserProfile)
				dispatchEvent(new SocialLayerEvent(SocialLayerEvent.PROFILE_CURRENTUSER, true, false, _currentUserProfile));
			else
				_platform.call("getUserInfo", _fieldsProfile);
		}

		public override function getProfileOfUser(userid:String):void {
			trace("FacebookConnectPlatform :: getProfileOfUser :: " + userid);
			
			_currentCall = "getProfileOfUser";
			
			_platform.call("getUsersInfo", [userid], _fieldsProfile);
		}

		public override function sendMessage(title:String, body:String, friends:Array, params:Object = null):void {
			trace("FacebookConnectPlatform :: sendMessage :: DOES NOT WORK ANYMORE");
			
			// _platform.call("sendNotification", friends, title);
			
			dispatchEvent(new SocialLayerEvent(SocialLayerEvent.MESSAGE_COMPLETE, true, false));
		}

		public override function publishPost(title:String, body:String, params:Object = null):void {
			trace("FacebookConnectPlatform :: publishPost");
			
			_platform.call("publish", body, {name: title, href: params.href, caption: title, description: body, media: params.media}, null, params.target_id, "Share this ...");
		}
		
		public function get session_data():* {
			return _session_data;
		}
		
		public function get permissions():Array {
			return _perms;
		}
		
		public function get logged_in():Boolean {
			return _isLoggedIn;
		}
		
		override public function dispatchEvent(event:Event):Boolean {
			_currentCall = "";
			
			return super.dispatchEvent(event);
		}
	}
}