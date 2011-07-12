package {
	import be.proximity.sociallayer.SocialLayer;
	import be.proximity.sociallayer.data.SocialUser;
	import be.proximity.sociallayer.events.SocialLayerEvent;
	import be.proximity.sociallayer.platform.*;
	
	import com.netlog.gameapi.GameEvent;
	
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.utils.setTimeout;

	public class ExampleProject extends Sprite {
		private var sl:SocialLayer;
		private var txt:TextField;

		public function ExampleProject() {
			trace("**** INIT **** 1");

			txt = new TextField();

			txt.text = "hier ";
			txt.multiline = true;
			txt.autoSize = TextFieldAutoSize.LEFT;

			addChild(txt);

			setTimeout(initFB, 2000);
		}

		private function initFB():void {
			trace("Init FB " + stage.loaderInfo.parameters);

			var config:String = stage.loaderInfo.parameters.config;
			var platformParameter:String = "";

			if (config)
				platformParameter = config.substr(config.indexOf("?p=") + 3, 11);

			sl = new SocialLayer(stage.loaderInfo, platformParameter);

			addChild(sl); // IMPORTANT !!!

			sl.addEventListener(SocialLayerEvent.READY, onSocialReady, false, 0, true);
			sl.init("7936555f01bb73002d1a76cc209410cf", "876c40aab2eee21fb3b762e147f2750f");
		}

		private function onSocialReady(e:SocialLayerEvent):void {
			trace("OnSocialReady Type: " + sl.platformType);

			sl.addEventListener(SocialLayerEvent.PROFILE_CURRENTUSER_NOTLOGGEDIN, onProfileOwnerNot);
			sl.addEventListener(SocialLayerEvent.PROFILE_CURRENTUSER, onProfileOwner);
			sl.addEventListener(SocialLayerEvent.FRIENDS_CURRENTUSER, onFriendsOwner);
			sl.addEventListener(SocialLayerEvent.FRIENDSIDS_CURRENTUSER, onFriendsIDsOwner);
			sl.addEventListener(SocialLayerEvent.PROFILE_USER, onProfileUser);
			sl.addEventListener(SocialLayerEvent.FRIENDS_USER, onFriendsUser);
			sl.addEventListener(SocialLayerEvent.MESSAGE_COMPLETE, onMessageOK);
			sl.addEventListener(SocialLayerEvent.PUBLISH_COMPLETE, onPublishOK);
			sl.addEventListener(SocialLayerEvent.PUBLISH_FAILED, onPublishNOK);
			
			sl.addEventListener(SocialLayerEvent.LOGGED_IN, onLoggedIn);
			sl.addEventListener(SocialLayerEvent.LOGGED_IN_CANCELED, onLoggedInCanceled);
			sl.addEventListener(SocialLayerEvent.LOGGED_OUT, onLoggedOut);
			sl.addEventListener(SocialLayerEvent.PERMISSIONS_SET, onPermSet);
			sl.addEventListener(SocialLayerEvent.PERMISSIONS_NOT_SET, onPermNotSet);

			addEventListener(GameEvent.GET_OPENSOCIAL_RESULT, onOSHandler);

			if(sl.platformType == sl.PLATFORM_FB_CONNECT && !(sl.platform as FacebookConnectPlatform).logged_in)
				(sl.platform as FacebookConnectPlatform).login();
			else if(sl.platformType == sl.PLATFORM_FB_CONNECT)
				(sl.platform as FacebookConnectPlatform).askPermissions([	FacebookConnectPlatform.PERM_EMAIL,
																			FacebookConnectPlatform.PERM_STREAM_PUBLISH, 
																			FacebookConnectPlatform.PERM_STREAM_READ, 
																			FacebookConnectPlatform.PERM_OFFLINE_ACCESS]);
			else
				sl.getProfileCurrentUser();
		}
		
		private function onPermSet(e:SocialLayerEvent):void {
			trace("ExampleProject :: onPermSet :: handler");
			
			sl.getProfileCurrentUser();
		}
		
		private function onPermNotSet(e:SocialLayerEvent):void {
			trace("ExampleProject :: onPermNotSet :: handler");
			
			sl.getProfileCurrentUser();
		}
		
		private function onLoggedIn(e:SocialLayerEvent):void {
			trace("ExampleProject :: onLoggedIn :: handler");
			
			(sl.platform as FacebookConnectPlatform).askPermissions([	FacebookConnectPlatform.PERM_EMAIL,
																		FacebookConnectPlatform.PERM_STREAM_PUBLISH, 
																		FacebookConnectPlatform.PERM_STREAM_READ, 
																		FacebookConnectPlatform.PERM_OFFLINE_ACCESS]);
		}
		
		private function onLoggedInCanceled(e:SocialLayerEvent):void {
			trace("ExampleProject :: onLoggedInCanceled :: handler");
			
			txt.appendText("LOGIN CANCELED");
		}
		
		private function onLoggedOut(e:SocialLayerEvent):void {
			trace("ExampleProject :: onLoggedOut :: handler");
		}

		private function onOSHandler(e:GameEvent):void {
			trace("ExampleProject :: getProfileCurrentUser :: handler");

			sl.dispatchEvent(new SocialLayerEvent(SocialLayerEvent.EXTERNAL_RESULT, true, true, e.data));
		}

		private function onProfileOwnerNot(e:SocialLayerEvent):void {
			trace("ExampleProject :: ----------------------------------------------------");
			trace(e.data);
			trace("ExampleProject :: ----------------------------------------------------");

			trace("ExampleProject :: onProfileOwnerNot");
		}

		private function onProfileOwner(e:SocialLayerEvent):void {
			trace("ExampleProject :: ----------------------------------------------------");
			trace(e.data);
			trace("ExampleProject :: ----------------------------------------------------");

			txt.appendText("1");

			trace("ExampleProject :: onProfileOwner");

			sl.getFriendsIDsOfCurrentUser();
		}

		private function onFriendsIDsOwner(e:SocialLayerEvent):void {
			trace("ExampleProject :: ----------------------------------------------------");
			trace(e.data);
			trace("ExampleProject :: ----------------------------------------------------");

			txt.appendText("2");

			trace("ExampleProject :: onFriendsIDsOwner");

			sl.getFriendsOfCurrentUser();
		}

		private function onFriendsOwner(e:SocialLayerEvent):void {
			trace("ExampleProject :: ----------------------------------------------------");
			trace(e.data);
			trace("ExampleProject :: ----------------------------------------------------");

			txt.appendText("2b");

			trace("ExampleProject :: onFriendsOwner");

			if(sl.platformType == sl.PLATFORM_FB || sl.platformType == sl.PLATFORM_FB_CONNECT)
				sl.getProfileOfUser("100000540277423");
			else	
				sl.getProfileOfUser("65148982");
		}

		private function onProfileUser(e:SocialLayerEvent):void {
			trace("ExampleProject :: ----------------------------------------------------");
			trace(e.data);
			trace("ExampleProject :: ----------------------------------------------------");

			txt.appendText("3");

			trace("ExampleProject :: onProfileUser");

			if(sl.platformType == sl.PLATFORM_FB)
				sl.getFriendsOfUser("100000540277423");
			else if(sl.platformType == sl.PLATFORM_FB_CONNECT)
				sl.sendMessage("Facebook Message Title", "Body copy", [627461028]);
			else
				sl.getFriendsOfUser("65148982");
		}

		private function onFriendsUser(e:SocialLayerEvent):void {
			trace("ExampleProject :: ----------------------------------------------------");
			trace(e.data);
			trace("ExampleProject :: ----------------------------------------------------");

			txt.appendText("4");

			trace("ExampleProject :: onFriendsUser");

			if (sl.platformType == sl.PLATFORM_NETLOG)
				sl.sendMessage("Message Title!", "Dit is een message.", [65148982], {params: {testID: "PROXIMITYBBDO"}});
			else if (sl.platformType == sl.PLATFORM_FB || sl.platformType == sl.PLATFORM_FB_CONNECT)
				sl.sendMessage("Facebook Message Title", "Body copy", [627461028]);
		}

		private function onMessageOK(e:SocialLayerEvent):void {
			txt.appendText("5");

			trace("ExampleProject :: onMessageOK");

			// ExternalInterface.call("function() { document.getElementById('chat_invite_container').setInnerFBML(chatInvite); }");

			if (sl.platformType == sl.PLATFORM_NETLOG)
				sl.publishPost("Publish Title!!", "Dit is een notification.", {friends: [], params: {testID: "PROXIMITYBBDO"}});
			else if (sl.platformType == sl.PLATFORM_FB || sl.platformType == sl.PLATFORM_FB_CONNECT)
				sl.publishPost("Facebook Post Title", "FacebookBody", {	
																		href: "http://www.youtube.com/watch?v=FNsrnXLS9b4", 
																		media: [	{	type: "flash", 
																						swfsrc: "http://www.youtube.com/v/fzzjgBAaWZw&hl=en&fs=1", 
																						imgsrc: "http://imstars.aufeminin.com/stars/fan/yannick-noah/yannick-noah-20070301-219360.jpg", 
																						width: "100", 
																						height: "80", 
																						expanded_width: "320", 
																						expanded_height: "240"
																					}
																				]
																		});
				
			// sl.publishPost("Facebook Post Title", "FacebookBody", {href: "http://www.youtube.com/watch?v=FNsrnXLS9b4", media: [{type: "image", src: "http://www.mexicaanse-muziek.nl/mexicaans_feest.jpg", href: "http://www.google.com"}]});
		}

		private function onPublishOK(e:SocialLayerEvent):void {
			txt.appendText("6");

			trace("ExampleProject :: onPublishOK");
			
			sl.removeEventListener(SocialLayerEvent.PUBLISH_COMPLETE, onPublishOK);
			sl.addEventListener(SocialLayerEvent.PUBLISH_COMPLETE, onPublishOK2);
			
			if(sl.platformType == sl.PLATFORM_FB_CONNECT)
				sl.publishPost("Facebook2 Post2 Title2", "FacebookBody2", {target_id: "627461028", href: "http://www.google2.be", media: [{type: "image", src: "http://www.mexicaanse-muziek.nl/mexicaans_feest.jpg", href: "http://www.google.com"}]});
		}

		private function onPublishOK2(e:SocialLayerEvent):void {
			txt.appendText("6bis");

			trace("ExampleProject :: onPublishOK2");
		}

		private function onPublishNOK(e:SocialLayerEvent):void {
			txt.appendText("6bis");

			trace("ExampleProject :: onPublishNOK");
		}
	}
}
