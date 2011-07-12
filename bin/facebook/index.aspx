<%@ Page Language="C#" Debug="true" %>
<%  
  string absolute_url = "";

  string facebook_url = "";
  string facebook_api = "";
	string facebook_app_id = "";
  
	string lang = "NL";   
	string gid = "";   
	string devmode = "";

	if(Request["lang"] == "FR") {    
		lang = "FR";
		
		absolute_url    = "http://xxx";
		facebook_url 		= "http://apps.facebook.com/xxx";  
		facebook_api 		= "xxx";
		facebook_app_id = "xxx";
	} else {
		lang = "NL";
		
		absolute_url    = "http://xxx";
		facebook_url 		= "http://apps.facebook.com/xxx";          
		facebook_api 		= "xxx";
		facebook_app_id = "xxx";
	}
	
	string redirect_url = facebook_url; // + "%3Flang%3D" + lang;
  
  if(Request["gid"] != null) {
    gid = Request["gid"];  

		redirect_url += "%3Fgid%3D" + gid + "%3Flang%3D" + lang;
  }  
  
  if(Request["devmode"] != null && Request["devmode"] == "true") {
    devmode = "true";  
  }
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
  <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />

  <title></title>

  <link rel="icon" type="image/png" href="../../favico.png" />

	<% if(Request["code"] == null || Request["code"] == "") { %>
	<script type="text/javascript">
		top.location = 'https://www.facebook.com/dialog/oauth?client_id=<%= facebook_app_id %>&redirect_uri=<%= redirect_url %>&scope=email,publish_stream';
	</script>
	<% } %>

  <script type="text/javascript" src="js/jquery-1.6.1.min.js"></script>
  <script type="text/javascript" src="js/json2.js"></script>
  <script type="text/javascript" src="js/FBFlashBridge-0.4.js"></script>
	<script type="text/javascript" src="js/swfobject.js"></script>

  <script type="text/javascript">

    var flashvars = { config: "default", 
                      referrer: document.referrer,  
                      globalURL: "<%= absolute_url %>", 
                      lang: "<%= lang %>", 
                      p: "facebook_connect",
                      socialURL: "<%= facebook_url %>",
                      gid: "<%= gid %>",
                      devmode: "<%= devmode %>" };
    var params = { allowScriptAccess: "always" };
    var attributes = { id: "flash" };

  </script>
</head>
<body>
  
  <div id="flash_alternative"></div>
  <div id="fb-root"></div>

  <script type="text/javascript">
		
		var _fbFlashBridge;
		
		window.fbAsyncInit = function() {
			FB.init({appId: '<%= facebook_app_id %>', status: true, cookie: true, xfbml: true});

			swfobject.embedSWF("../../assets/swf/Main.swf", "flash_alternative", "100%", "100%", "10.0.0", "assets/swf/expressInstall.swf", flashvars, params, attributes);
			
			delayedInit();
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
    _gaq.push(['_setAccount', 'UA-xxx']);
    _gaq.push(['_trackPageview']);

    (function() {
      var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
      ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
      var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
    })();
  </script>

	<pre style="display: none;">
	<%
	foreach (string key in Request.Form.Keys) {
		Response.Write(key + " : " + Request.Form[key] + "\n");
	}
  %>
	-------
	<%
  foreach (string key in Request.QueryString.AllKeys) {
    Response.Write(key + " : " + Request[key] + "\n");
  }
	%>
	</pre>
  
</body>
</html>
