package be.proximity.socialtools
{
	import flash.events.EventDispatcher;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;

	public class SocialTools extends EventDispatcher
	{
		private var _isInited:Boolean = false;
		
		public function SocialTools(param:SingletonEnforcer)
		{
			if(!param)
				throw new Error("It's a singleton"); 
		}
		
		private static var _instance:SocialTools;
		
		/**
		 * Singleton pattern: globale instance van het SocialTools object.
		 *  
		 * @return 
		 * 
		 */		
		public static function getInstance():SocialTools {
			if(!_instance)
				_instance = new SocialTools(new SingletonEnforcer());
			return _instance;
		} 
		
		public static const NETLOG:String = "Netlog";
		public static const FACEBOOK:String = "Facebook";
		public static const TWITTER:String = "Twitter";
		public static const DELICIOUS:String = "Delicious";
		public static const FRIENDFEED:String = "Friendfeed";
		public static const LINKEDIN:String = "LinkedIn";
		
		/**
		 * Share on ...
		 * 
		 */
		public function share(socialsite:String, url:String, title:String, info:String = ""):String {
			var share_url:String = fetchShareURL(socialsite);    
			
			info = encodeURIComponent(info);
			title = encodeURIComponent(title)
			
			if(url.length > 0)
				share_url = share_url.replace(new RegExp("\{([url\}\s]+)\}", "gs"), url);
			
			if(title.length > 0)
				share_url = share_url.replace(new RegExp("\{([title\}\s]+)\}", "gs"), title);
			
			if(info.length > 0)
				share_url = share_url.replace(new RegExp("\{([info\}\s]+)\}", "gs"), info);
			
			navigateToURL(new URLRequest(share_url), "_blank");
			
			return share_url;
		}
		
		private function fetchShareURL(socialsite:String):String {
			switch(socialsite) {
				case SocialTools.DELICIOUS:
				
					return "http://delicious.com/save?url={url}&title={title}&notes={info}";
					
					break;
					
				case SocialTools.FACEBOOK:
				
					return "http://www.facebook.com/share.php?u={url}&t={title}&v=3";
					
					break;
					
				case SocialTools.FRIENDFEED:
				
					return "http://friendfeed.com/?url={url}&title={title}";
					
					break;
					
				case SocialTools.NETLOG:
				
					return "http://nl.netlog.com/go/manage/links/view=save&origin=external&url={url}&title={title}&description={info}";
					
					break;
					
				case SocialTools.TWITTER:
				
					return "http://twitter.com/home?status={title}";
					
					break;
					
				case SocialTools.LINKEDIN:
				
					return "http://www.linkedin.com/shareArticle?mini=true&url={url}&title={title}&summary={info}";
					
					break;
			}
			
			return "";
		}
	}
}

internal class SingletonEnforcer{};  