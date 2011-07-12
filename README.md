Social Layer
============

It allows you to integrate a Flash application as Facebook Application.


Example ActionScript code
=========================

var social_layer:SocialLayer = new SocialLayer(stage.loaderInfo, stage.loaderInfo.parameters.p);

social_layer.addEventListener(SocialLayerEvent.READY, onSocialReady, false, 0 ,true);
social_layer.addEventListener(SocialLayerEvent.LOGGED_IN, onSocialLoggedIn, false, 0 ,true);
social_layer.addEventListener(SocialLayerEvent.NO_PLATFORM, onSocialNoPlatform, false, 0, true);
social_layer.addEventListener(SocialLayerEvent.PROFILE_CURRENTUSER, onSocialProfileCurrentUser);

social_layer.init();

addChild(social_layer);

private function onSocialLoggedIn(e:SocialLayerEvent):void {
  trace("ApplicationData: onSocialLoggedIn");			

  social_layer.removeEventListener(SocialLayerEvent.LOGGED_IN, onSocialLoggedIn);
  
  social_layer.getProfileCurrentUser();
}

private function onSocialNoPlatform(e:SocialLayerEvent):void {
  trace("ApplicationData: noSocialPlatformDefined");
}

private function onSocialReady(e:SocialLayerEvent):void {
  trace("ApplicationData: onSocialReady");
  
  social_layer.removeEventListener(SocialLayerEvent.READY, onSocialReady);
}

private function onSocialProfileCurrentUser(e:SocialLayerEvent):void {
  social_layer.removeEventListener(SocialLayerEvent.PROFILE_CURRENTUSER, onSocialProfileCurrentUser);
  
  trace(e.data as SocialUser);
  

}
