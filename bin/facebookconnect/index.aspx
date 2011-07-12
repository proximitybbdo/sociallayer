<%@ Page Language="C#" Debug="true" %>
<%  
  string absolute_url = "http://mmspuissance.microsite.be/";
  string facebook_url = "";
  string facebook_api = "";
  string lang = "FR";   
  string gid = "";   
  string gid_red = "";    
  string devmode = "";
  
  facebook_url = "http://apps.facebook.com/puissancemmsfrance/";  
  facebook_api = "377fa8a86019a424e55ed10b94c0de74";
    
  if(Request["gid"] != null) {
    gid = "&gid=" + Request["gid"];  
    gid_red = "?gid=" + Request["gid"];
  }  
  
  if(Request["devmode"] != null && Request["devmode"] == "true") {
    devmode = "&devmode=true";  
  }
  
    foreach (string key in Request.QueryString.AllKeys) {
    // Response.Write(key);
  }
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html>
<head>
  <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />

  <title>Puissance MM's</title>

  <link rel="icon" type="image/png" href="favico.png">
  <link href="assets/css/style.css" rel="stylesheet" type="text/css" media="screen" />

  <script type="text/javascript" src="assets/js/jquery-1.3.2.min.js"></script>
  <script type="text/javascript" src="assets/js/swfobject.js"></script>
  <script type="text/javascript" src="assets/js/FBFlashBridge-0.4.js" ></script>
  <script type="text/javascript" src="assets/js/json2.js" ></script>

  <script type="text/javascript">
    var flashvars = { config: "default", 
                      referrer: document.referrer,  
                      globalURL: "<%= absolute_url %>", 
                      lang: "FR", 
                      p: "facebook_connect",
                      socialURL: "<%= facebook_url %>",
                      gid: "<%= gid %>",
                      devmode: "<%= devmode %>"};
    var params = { allowFullScreen : true , allowScriptAccess: "always"};
    var attributes = { id: "flash" };
  </script>
</head>
<body>
  
  <div id="flash_alternative"></div>

  <div id="fb-root"></div>
  
  <script type="text/javascript">
    var _fbFlashBridge;

		window.fbAsyncInit = function() {
			FB.init({appId: '180627541947905', status: true, cookie: true, xfbml: true});

			swfobject.embedSWF("../../assets/swf/Main.swf", "flash_alternative", "100%", "100%", "10.0.0", "assets/swf/expressInstall.swf", flashvars, params, attributes);

			setTimeout(delayedInit, 500);
		};

		function delayedInit() {
			_fbFlashBridge = new FBFlashBridge(swfobject.getObjectById, "flash");
			_fbFlashBridge.init();
		}

		(function() {
			var e = document.createElement('script'); 
			e.async = true; e.src = document.location.protocol + '//connect.facebook.net/en_US/all.js';
			document.getElementById('fb-root').appendChild(e);
		}());
  </script>

  <script type="text/javascript">

    var _gaq = _gaq || [];
    _gaq.push(['_setAccount', 'UA-5863962-6']);
    _gaq.push(['_trackPageview']);

    (function() {
      var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
      ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
      var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
    })();

  </script>
  
</body>
</html>