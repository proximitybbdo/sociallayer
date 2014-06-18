package be.proximity.sociallayer.data
{
	import be.proximity.utilities.data.AbstractData;
	
	public class SocialUser extends AbstractData
	{
		public var id:String = "";
		public var gender:String = "";
		
		public var thumbnailUrl:String = "";
		public var profilePicture:String = "";
		
		public var nickName:String;
		public var familyName:String = "";
		public var firstName:String = "";
		
		// NETLOG SPECIFIC
		public var profileUrl:String = "";
		public var isViewer:Boolean = false;
		public var isOwner:Boolean = false;
				
		// FB SPECIFIC
		public var isAppUser:Boolean = false;
		public var isLoggedInUser:Boolean = false;
		
		public var timezone:int = -1;
		public var birthday_date:String = "";
		public var website:String = "";
		
		public var proxied_email:String = "";
		public var email:String = "";
		
		public var locale:String = "";
		public var currentLocationCountry:String = "";
		
 	 	public function SocialUser(o:Object = null)
		{
			super(o);
		}
	}
}