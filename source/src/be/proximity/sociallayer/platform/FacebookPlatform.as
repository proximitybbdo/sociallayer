package be.proximity.sociallayer.platform {
	import be.proximity.framework.logging.Logr;
	import be.proximity.sociallayer.data.SocialUser;
	import be.proximity.sociallayer.events.SocialLayerEvent;
	
	import com.facebook.Facebook;
	import com.facebook.commands.friends.GetFriends;
	import com.facebook.commands.stream.PublishPost;
	import com.facebook.commands.users.GetInfo;
	import com.facebook.commands.users.HasAppPermission;
	import com.facebook.data.BooleanResultData;
	import com.facebook.data.friends.GetFriendsData;
	import com.facebook.data.users.FacebookUser;
	import com.facebook.data.users.GetInfoData;
	import com.facebook.data.users.HasAppPermissionValues;
	import com.facebook.events.FacebookEvent;
	import com.facebook.net.FacebookCall;
	import com.facebook.utils.FacebookSessionUtil;
	
	import flash.display.LoaderInfo;
	import flash.utils.setTimeout;


	public class FacebookPlatform extends AbstractPlatform implements IPlatform {
		private var _platformFBSession:FacebookSessionUtil;
		private var _platform:Facebook;
		private var _loaderInfo:LoaderInfo;

		private var _fieldsProfile:Array = ["uid", "pic", "pic_square", "first_name", "last_name", "sex", "name", "locale", "hometown_location", "birthday_date", "contact_email", "email", "timezone", "username", "website", "proxied_email", "is_app_user"];

		private var _permissionAsked:Boolean = false;
		private var _permissionAskedTimes:int = 0;

		private var _PERMISSION_ASKED_MAX:int = 7;
		private var _MAX_FRIENDS_REQUESTED:int = 300;

		public function FacebookPlatform(loaderInfo:LoaderInfo) {
			_loaderInfo = loaderInfo;
		}

		public override function init(... arguments):void {
			
			trace("--------------- LI");
			trace(_loaderInfo.parameters);
			trace("---------------");
			trace(_loaderInfo.parameters.session);
			trace("---------------");
			if(_loaderInfo.parameters.session)
				trace(getSessionKey(_loaderInfo.parameters.session));			
			trace("---------------");
			if(_loaderInfo.parameters.session)
				_loaderInfo.parameters.fb_sig_session_key = getSessionKey(_loaderInfo.parameters.session);
			
			_platformFBSession = new FacebookSessionUtil(String(arguments[0]).split(",")[0], String(arguments[0]).split(",")[1], _loaderInfo);
			_platform = _platformFBSession.facebook;

			_platformFBSession.addEventListener(FacebookEvent.CONNECT, onFacebookInit, false, 0);
			_platformFBSession.verifySession();
		}

		private function getSessionKey(session:String):String{
			var session_vars:Array = session.split(",");
			var session_key:String = "";
			
			for each(var s:String in session_vars){
				if(s.indexOf("session_key") > -1)
					session_key = s;
			}
			
			if(session_key != ""){
				var session_key_vars:Array = session_key.split(":");
				if(session_key_vars.length == 2)
					session_key = session_key_vars[1];
				else
					trace("No session key");
			}
			
			var pattern:RegExp = /["]/g;
			session_key = session_key.replace(pattern, "");
			
			return session_key;
		}
		
		private function onFacebookInit(e:FacebookEvent):void {
			_platformFBSession.removeEventListener(FacebookEvent.CONNECT, onFacebookInit);

			dispatchEvent(new SocialLayerEvent(SocialLayerEvent.PLATFORM_READY));
		}

		public override function getFriendsOfUser(userid:String):void {
			trace("FacebookPlatform :: getFriendsOfUser");

			dispatchEvent(new SocialLayerEvent(SocialLayerEvent.FRIENDS_USER, true, false, []));
		}

		public override function getFriendsIDsOfUser(userid:String):void {
			trace("FacebookPlatform :: getFriendsIDsOfUser");

			var request:GetFriends = new GetFriends(null, userid);
			var call:FacebookCall = _platform.post(request);

			call.addEventListener(FacebookEvent.COMPLETE, onFBGetFriends);
			call.addEventListener(FacebookEvent.ERROR, onFBGetFriendsError);

			function onFBGetFriendsError(e:FacebookEvent):void {
				trace("FacebookPlatform :: getFriendsIDsOfUser Error");

				dispatchEvent(new SocialLayerEvent(SocialLayerEvent.FRIENDSIDS_USER, true, false, []));
			}

			function onFBGetFriends(e:FacebookEvent):void {
				trace("FacebookPlatform :: getFriendsIDsOfUser Result");

				var result:Array = [];

				if (e.data) {
					var response:GetFriendsData = e.data as GetFriendsData;

					for (var i:int = 0; i < response.friends.length; i++) {
						var fbuser:FacebookUser = response.friends.getUserById(response.friends.getItemAt(i).uid) as FacebookUser;

						if (fbuser) {
							var su:SocialUser = new SocialUser({	id: fbuser.uid, 
																	gender: fbuser.sex, 
																	thumbnailUrl: fbuser.pic_square,
																	profilePicture: getProfilePic(fbuser.pic),
																	familyName: fbuser.last_name, 
																	firstName: fbuser.first_name, 
																	locale: fbuser.locale, 
																	isAppUser: fbuser.is_app_user, 
																	timezone: fbuser.timezone, 
																	nickName: "", 
																	birthday_date: fbuser.birthdayDate != null ? (leadingZero("" + fbuser.birthdayDate.getDate()) + "/" + leadingZero("" + fbuser.birthdayDate.getMonth()) + "/" + fbuser.birthdayDate.fullYearUTC) : "", 
																	website: "", 
																	proxied_email: fbuser.proxied_email, 
																	email: ""});
																	
							if(fbuser.hometown_location != null)
								su.currentLocationCountry = fbuser.hometown_location.country;
								
							result.push(su);
						}
					}
				}

				result.sortOn(["firstName", "familyName"]);

				call.removeEventListener(FacebookEvent.COMPLETE, onFBGetFriends);
				call.removeEventListener(FacebookEvent.ERROR, onFBGetFriendsError);

				dispatchEvent(new SocialLayerEvent(SocialLayerEvent.FRIENDS_USER, true, false, result));
			}
		}

		public override function getFriendsIDsOfCurrentUser():void {
			trace("FacebookPlatform :: getFriendsIDsOfCurrentUser (" + _MAX_FRIENDS_REQUESTED + ", " + (_currentUserFriendsIDs ? _currentUserFriendsIDs.length : "") + ")");

			if (_currentUserFriendsIDs && _currentUserFriendsIDs.length > 0)
				dispatchEvent(new SocialLayerEvent(SocialLayerEvent.FRIENDSIDS_CURRENTUSER, true, false, _currentUserFriendsIDs));
			else {
				var request:GetFriends = new GetFriends(null, _platform.uid);
				var call:FacebookCall = _platform.post(request);

				call.addEventListener(FacebookEvent.COMPLETE, onFBGetFriends);

				function onFBGetFriends(e:FacebookEvent):void {
					trace("FacebookPlatform :: getFriendsIDsOfCurrentUser Result (" + _MAX_FRIENDS_REQUESTED + ")");

					call.removeEventListener(FacebookEvent.COMPLETE, onFBGetFriends);

					var response:GetFriendsData = e.data as GetFriendsData;

					_currentUserFriendsIDs = [];

					if (response.friends) {
						for (var i:int = 0; i < response.friends.length; i++) {
							try {
								_currentUserFriendsIDs.push(response.friends.getItemAt(i).uid);
							}
							catch (e:Error) {
								// continue;
								trace(response)
								trace(response.friends)
							}
						}
					} else {
						trace("FacebookPlatform :: getFriendsIDsOfCurrentUser :: ERROR :: iets met null data ofzo ..");
					}

					dispatchEvent(new SocialLayerEvent(SocialLayerEvent.FRIENDSIDS_CURRENTUSER, true, false, _currentUserFriendsIDs));
				}
			}
		}

		public override function getFriendsOfCurrentUser():void {
			trace("FacebookPlatform :: getFriendsOfCurrentUser (" + _MAX_FRIENDS_REQUESTED + (_currentUserFriends ? ", " + _currentUserFriends.length : "") + ")");

			if (_currentUserFriends && _currentUserFriends.length > 0)
				dispatchEvent(new SocialLayerEvent(SocialLayerEvent.FRIENDS_CURRENTUSER, true, false, _currentUserFriends));
			else if (_currentUserFriendsIDs && _currentUserFriendsIDs.length > 0)
				getProfilesOfFriendsOfCurrentUser();
			else {
				var request:GetFriends = new GetFriends(null, _platform.uid);
				var call:FacebookCall = _platform.post(request);

				call.addEventListener(FacebookEvent.COMPLETE, onFBGetFriends);

				function onFBGetFriends(e:FacebookEvent):void {
					trace("FacebookPlatform :: getFriendsOfCurrentUser Result (" + _MAX_FRIENDS_REQUESTED + ")");

					call.removeEventListener(FacebookEvent.COMPLETE, onFBGetFriends);

					var response:GetFriendsData = e.data as GetFriendsData;

					_currentUserFriendsIDs = [];

					for (var i:int = 0; i < response.friends.length; i++)
						_currentUserFriendsIDs.push(response.friends.getItemAt(i).uid);

					getProfilesOfFriendsOfCurrentUser();
				}
			}
		}

		private function getProfilesOfFriendsOfCurrentUser():void {
			trace("FacebookPlatform :: getProfilesOfFriendsOfCurrentUser");

			var infoRequest:GetInfo = new GetInfo(_currentUserFriendsIDs, _fieldsProfile); // [GetInfoFieldValues.ALL_VALUES]);
			var infoCall:FacebookCall = _platform.post(infoRequest);

			infoCall.addEventListener(FacebookEvent.COMPLETE, onFBGetInfoFriends);

			function onFBGetInfoFriends(e:FacebookEvent):void {
				trace("FacebookPlatform :: getProfilesOfFriendsOfCurrentUser onFBGetInfoFriends Result (" + _MAX_FRIENDS_REQUESTED + ")");
				trace("FacebookPlatform :: getProfilesOfFriendsOfCurrentUser onFBGetInfoFriends Result (" + e.data + ")");

				infoCall.removeEventListener(FacebookEvent.COMPLETE, onFBGetInfoFriends);

				_currentUserFriends = [];

				if (e.data) {
					var responseInfo:GetInfoData = e.data as GetInfoData;

					for (var i:int = 0; i < responseInfo.userCollection.length; i++) {
						var fbuser:FacebookUser = responseInfo.userCollection.getUserById(responseInfo.userCollection.getItemAt(i).uid) as FacebookUser;

						if (fbuser) {
							var su:SocialUser = new SocialUser({	id: fbuser.uid, 
																		gender: fbuser.sex, 
																		thumbnailUrl: fbuser.pic_square, 
																		profilePicture: getProfilePic(fbuser.pic), 
																		familyName: fbuser.last_name, 
																		firstName: fbuser.first_name,
																		locale: fbuser.locale,  
																		isAppUser: fbuser.is_app_user, 
																		timezone: fbuser.timezone, 
																		nickName: "", 
																		birthday_date: fbuser.birthdayDate != null ? (leadingZero("" + fbuser.birthdayDate.getDate()) + "/" + leadingZero("" + fbuser.birthdayDate.getMonth()) + "/" + fbuser.birthdayDate.fullYearUTC) : "", 
																		website: "", 
																		proxied_email: fbuser.proxied_email, 
																		email: ""});
																		
							if(fbuser.hometown_location != null)
								su.currentLocationCountry = fbuser.hometown_location.country;
							
							_currentUserFriends.push(su);
						}
					}

					_currentUserFriends.sortOn(["firstName", "familyName"]);
				} else
					trace("FacebookPlatform :: getProfilesOfFriendsOfCurrentUser onFBGetInfoFriends Result ::: NO RESULTS");

				dispatchEvent(new SocialLayerEvent(SocialLayerEvent.FRIENDS_CURRENTUSER, true, false, _currentUserFriends));
			}
		}

		public override function getProfileCurrentUser():void {
			trace("FacebookPlatform :: getProfileCurrentUser");

			if (_currentUserProfile)
				dispatchEvent(new SocialLayerEvent(SocialLayerEvent.PROFILE_CURRENTUSER, true, false, _currentUserProfile));
			else {
				var request:GetInfo = new GetInfo([_platform.uid], _fieldsProfile);
				var call:FacebookCall = _platform.post(request);

				call.addEventListener(FacebookEvent.COMPLETE, onFBGetInfo);

				function onFBGetInfo(e:FacebookEvent):void {
					trace("FacebookPlatform :: getProfileCurrentUser Result");
					trace("FacebookPlatform :: getProfileCurrentUser :: " + e.data);

					if(e.data == null){
						trace("error");
						
						dispatchEvent(new SocialLayerEvent(SocialLayerEvent.ERROR, true, false, "Could not fetch user!"));
						return;
					}
					
					call.removeEventListener(FacebookEvent.COMPLETE, onFBGetInfo);

					var response:GetInfoData = e.data as GetInfoData;

					//trace("FacebookPlatform :: getProfileCurrentUser :: " + response);
					//trace("FacebookPlatform :: getProfileCurrentUser :: " + response.userCollection);
					//trace("FacebookPlatform :: getProfileCurrentUser :: " + response.userCollection.getItemAt(0));
									
					var fbuser:FacebookUser = response.userCollection.getItemAt(0) as FacebookUser;

					_currentUserProfile = new SocialUser({	id: fbuser.uid, 
															gender: fbuser.sex, 
															thumbnailUrl: fbuser.pic_square, 
															profilePicture: getProfilePic(fbuser.pic), 
															familyName: fbuser.last_name, 
															firstName: fbuser.first_name, 
															locale: fbuser.locale, 
															isAppUser: fbuser.is_app_user, 
															timezone: fbuser.timezone, 
															nickName: "", 
															birthday_date: fbuser.birthdayDate != null ? (leadingZero("" + fbuser.birthdayDate.getDate()) + "/" + leadingZero("" + fbuser.birthdayDate.getMonth()) + "/" + fbuser.birthdayDate.fullYearUTC) : "", 
															website: "", 
															proxied_email: fbuser.proxied_email, 
															email: ""});
					
					if(fbuser.hometown_location != null)
						_currentUserProfile.currentLocationCountry = fbuser.hometown_location.country;
					
					trace(fbuser.first_name);
					trace(fbuser.last_name);

					dispatchEvent(new SocialLayerEvent(SocialLayerEvent.PROFILE_CURRENTUSER, true, false, _currentUserProfile));
				}
			}
		}

		public override function getProfileOfUser(userid:String):void {
			trace("FacebookPlatform :: getProfileOfUser");

			var request:GetInfo = new GetInfo([userid], _fieldsProfile);
			var call:FacebookCall = _platform.post(request);

			call.addEventListener(FacebookEvent.COMPLETE, onFBGetInfo);

			function onFBGetInfo(e:FacebookEvent):void {
				trace("FacebookPlatform :: getProfileOfUser Result");

				call.removeEventListener(FacebookEvent.COMPLETE, onFBGetInfo);

				var response:GetInfoData = e.data as GetInfoData;
				var fbuser:FacebookUser = response.userCollection.getItemAt(0) as FacebookUser;
				var su:SocialUser = new SocialUser({	id: fbuser.uid, 
														gender: fbuser.sex, 
														thumbnailUrl: fbuser.pic_square, 
														profilePicture: getProfilePic(fbuser.pic), 
														familyName: fbuser.last_name, 
														firstName: fbuser.first_name, 
														locale: fbuser.locale,
														isAppUser: fbuser.is_app_user, 
														timezone: fbuser.timezone, 
														nickName: "", 
														birthday_date: fbuser.birthdayDate != null ? (leadingZero("" + fbuser.birthdayDate.getDate()) + "/" + leadingZero("" + fbuser.birthdayDate.getMonth()) + "/" + fbuser.birthdayDate.fullYearUTC) : "", 
														website: "", 
														proxied_email: fbuser.proxied_email, 
														email: ""});

				if(fbuser.hometown_location != null)
						su.currentLocationCountry = fbuser.hometown_location.country;														
														
				dispatchEvent(new SocialLayerEvent(SocialLayerEvent.PROFILE_USER, true, false, su));
			}
		}

		public override function publishPost(title:String, body:String, params:Object = null):void {
			trace("FacebookPlatform :: publishPost");

			var reqPerm:HasAppPermission = new HasAppPermission(HasAppPermissionValues.PUBLISH_STREAM, _platform.uid);
			var callPerm:FacebookCall = _platform.post(reqPerm);

			callPerm.addEventListener(FacebookEvent.COMPLETE, onFBStreamPerm);

			function onFBStreamPerm(e:FacebookEvent):void {
				trace("FacebookPlatform :: publishPost :: Permission Result");

				callPerm.removeEventListener(FacebookEvent.COMPLETE, onFBStreamPerm);

				if (e.success && ((e.data as BooleanResultData).value)) {
					var request:PublishPost = new PublishPost(body, {name: title, href: params.href, caption: title, description: body, media: params.media}, [{text: "Click here to read more...", href: ""}], null);
					var call:FacebookCall = _platform.post(request);

					call.addEventListener(FacebookEvent.COMPLETE, onFBStreamPublish);

					function onFBStreamPublish(e:FacebookEvent):void {
						trace("FacebookPlatform :: publishPost :: Result");

						call.removeEventListener(FacebookEvent.COMPLETE, onFBStreamPublish);

						dispatchEvent(new SocialLayerEvent(SocialLayerEvent.PUBLISH_COMPLETE, true, false));
					}
				} else {
					trace("FacebookPlatform :: We have no permissions to post!");

					if (!_permissionAsked)
						_platform.grantExtendedPermission("publish_stream");

					if (_permissionAskedTimes < _PERMISSION_ASKED_MAX)
						setTimeout(publishPost, 1000, title, body, params);
					else
						dispatchEvent(new SocialLayerEvent(SocialLayerEvent.PUBLISH_FAILED, true, false));

					_permissionAskedTimes++;
					_permissionAsked = true;
				}
			}
		}

		public override function sendMessage(title:String, body:String, friends:Array, params:Object = null):void {
			trace("FacebookPlatform :: sendMessage :: DOES NOT WORK ANYMORE!");
			
			/*
			var request:DashboardMultiAddNews = new DashboardMultiAddNews(friends, [{message: title}]);
			var call:FacebookCall = _platform.post(request);

			call.addEventListener(FacebookEvent.COMPLETE, onFBStreamPublish);

			function onFBStreamPublish(e:FacebookEvent):void {
				trace("FacebookPlatform :: sendMessage Result");

				call.removeEventListener(FacebookEvent.COMPLETE, onFBStreamPublish);

				dispatchEvent(new SocialLayerEvent(SocialLayerEvent.MESSAGE_COMPLETE, true, false));
			}
			*/
			
			dispatchEvent(new SocialLayerEvent(SocialLayerEvent.MESSAGE_COMPLETE, true, false));
		}
		
		private function getProfilePic(path:String):String{
			if(path){
				var pattern:RegExp = /\*?_q.|_s./; // replaces the path _s or _q for the _n, which should bring us a big picture
				
				if(path.search(pattern) != -1)
					return String(path.replace(pattern, "_n."));
				else
					return path;
			}
			
			return "";
		}
	}
}