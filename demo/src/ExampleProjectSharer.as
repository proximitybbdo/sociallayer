package {
	import be.proximity.socialtools.SocialTools;
	
	import flash.display.Sprite;

	public class ExampleProjectSharer extends Sprite
	{
		public function ExampleProjectSharer()
		{
			SocialTools.getInstance().share(SocialTools.DELICIOUS, "http://www.google.be", "Google", "Google is Great!");
			SocialTools.getInstance().share(SocialTools.FACEBOOK, "http://www.google.be", "Google", "Google is Great!");
			SocialTools.getInstance().share(SocialTools.FRIENDFEED, "http://www.google.be", "Google", "Google is Great!");
			SocialTools.getInstance().share(SocialTools.NETLOG, "http://www.google.be", "Google", "Google is Great!");
			SocialTools.getInstance().share(SocialTools.TWITTER, "http://www.google.be", "Google", "Google is Great!");
		}
	}
}
