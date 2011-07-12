package be.proximity.sociallayer.platform {
	import be.proximity.sociallayer.data.SocialUser;
	import be.proximity.sociallayer.events.SocialLayerEvent;

	import com.netlog.gameapi.GameEvent;

	public class NetlogGamePlatform extends AbstractPlatform implements IPlatform {
		private var _currentCall:String = "";

		public function NetlogGamePlatform() {
			super();
		}

		public override function init(... arguments):void {
			trace("NetlogGamePlatform :: init");

			dispatchEvent(new SocialLayerEvent(SocialLayerEvent.PLATFORM_READY));
		}

		public function onExternalResult(e:SocialLayerEvent):void {
			trace("NetlogGamePlatform :: onExternalResult :: " + _currentCall);

			trace(e.data);

			var currCall:String = _currentCall;

			_currentCall = "";

			switch (currCall) {
				case "getFriendsOfCurrentUser":

					var ress:Array = e.data as Array;

					_currentUserFriendsIDs = [];
					_currentUserFriends = [];

					for (var k:int = 0; k < ress.length; i++) {
						var oRess:Object = ress[k] as Object;

						_currentUserFriendsIDs.push(oRess.id);
						_currentUserFriends.push(new SocialUser({id: oRess.id, gender: oRess.gender.toLowerCase(), thumbnailUrl: oRess.thumbnailUrl, nickName: oRess.nickname, familyName: oRess.name.familyName, firstName: oRess.name.givenName, profileUrl: oRess.profileUrl, isViewer: oRess.isViewer, isOwner: oRess.isOwner}));
					}

					dispatchEvent(new SocialLayerEvent(SocialLayerEvent.FRIENDS_CURRENTUSER, true, false, _currentUserFriends));

					break;

				case "getProfileCurrentUser":

					_currentUserProfile = new SocialUser({id: e.data.id, gender: e.data.gender.toLowerCase(), thumbnailUrl: e.data.thumbnailUrl, nickName: e.data.nickname, familyName: e.data.name.familyName, firstName: e.data.name.givenName, profileUrl: e.data.profileUrl, isViewer: e.data.isViewer, isOwner: e.data.isOwner});

					dispatchEvent(new SocialLayerEvent(SocialLayerEvent.PROFILE_CURRENTUSER, true, false, _currentUserProfile));

					break;

				case "getFriendsIDsOfCurrentUser":

					var res:Array = e.data as Array;

					_currentUserFriendsIDs = [];
					_currentUserFriends = [];

					/*
					   for (var j:*in res[0]) {
					   trace(j + " - " + res[0][j]);

					   for (var l:*in res[0][j]) {
					   trace("\t" + l + " - " + res[0][j][l]);
					   }
					   }
					 */

					for (var i:int = 0; i < res.length; i++) {
						var oRes:Object = res[i] as Object;

						_currentUserFriendsIDs.push(oRes.id);
						_currentUserFriends.push(new SocialUser({id: oRes.id, gender: oRes.gender.toLowerCase(), thumbnailUrl: oRes.thumbnailUrl, nickName: oRes.nickname, familyName: oRes.name.familyName, firstName: oRes.name.givenName, profileUrl: oRes.profileUrl, isViewer: oRes.isViewer, isOwner: oRes.isOwner}));
					}

					dispatchEvent(new SocialLayerEvent(SocialLayerEvent.FRIENDSIDS_CURRENTUSER, true, false, _currentUserFriendsIDs));

					break;
			}
		}

		public override function getFriendsOfUser(userid:String):void {
			trace("NetlogGamePlatform :: getFriendsOfUser");

			dispatchEvent(new SocialLayerEvent(SocialLayerEvent.FRIENDS_USER, false, false, []));
		}

		public override function getFriendsIDsOfUser(userid:String):void {
			trace("NetlogGamePlatform :: getFriendsIDsOfUser");

			dispatchEvent(new SocialLayerEvent(SocialLayerEvent.FRIENDSIDS_USER, false, false, []));
		}

		public override function getFriendsOfCurrentUser():void {
			trace("NetlogGamePlatform :: getFriendsOfCurrentUser");

			if (_currentUserFriends && _currentUserFriends.length > 0)
				dispatchEvent(new SocialLayerEvent(SocialLayerEvent.FRIENDS_CURRENTUSER, true, false, _currentUserFriends));
			else {
				_currentCall = "getFriendsOfCurrentUser";

				dispatchEvent(new GameEvent(GameEvent.GET_OPENSOCIAL, {"guid": "@me", "selector": "@friends", "requestor": "@me", "params": {"fields": "gender,id,name,thumbnailUrl,displayName,nickname,profileUrl"}}));
			}
		}

		public override function getFriendsIDsOfCurrentUser():void {
			trace("NetlogGamePlatform :: getFriendsIDsOfCurrentUser");

			if (_currentUserFriendsIDs && _currentUserFriendsIDs.length > 0)
				dispatchEvent(new SocialLayerEvent(SocialLayerEvent.FRIENDSIDS_CURRENTUSER, true, false, _currentUserFriendsIDs));
			else {
				_currentCall = "getFriendsIDsOfCurrentUser";

				dispatchEvent(new GameEvent(GameEvent.GET_OPENSOCIAL, {"guid": "@me", "selector": "@friends", "requestor": "@me", "params": {"fields": "gender,id,name,thumbnailUrl,displayName,nickname,profileUrl"}}));
			}
		}

		public override function getProfileCurrentUser():void {
			trace("NetlogGamePlatform :: getProfileCurrentUser");

			if (_currentUserProfile)
				dispatchEvent(new SocialLayerEvent(SocialLayerEvent.PROFILE_CURRENTUSER, true, false, _currentUserProfile));
			else {
				_currentCall = "getProfileCurrentUser";

				dispatchEvent(new GameEvent(GameEvent.GET_OPENSOCIAL, {"guid": "@me", "requestor": "@self", "params": {"fields": "gender,id,name,thumbnailUrl,displayName,nickname,profileUrl"}}));
			}
		}

		public override function getProfileOfUser(userid:String):void {
			trace("NetlogGamePlatform :: getProfileOfUser");

			dispatchEvent(new SocialLayerEvent(SocialLayerEvent.PROFILE_USER, false, false, new SocialUser()));
		}

		public override function sendMessage(title:String, body:String, friends:Array, params:Object = null):void {
			trace("NetlogGamePlatform :: sendMessage");

			dispatchEvent(new SocialLayerEvent(SocialLayerEvent.MESSAGE_COMPLETE, false, false, true));
		}

		public override function publishPost(title:String, body:String, params:Object = null):void {
			trace("NetlogGamePlatform :: publishPost");

			dispatchEvent(new SocialLayerEvent(SocialLayerEvent.PUBLISH_COMPLETE, false, false, true));
		}

	}
}