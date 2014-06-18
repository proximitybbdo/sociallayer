<%@ Page Language="C#" AutoEventWireup="true"%><?xml version="1.0" encoding="UTF-8"?>
<% string absoluteURL = "http://stream.microsite.be/dev/sociallayer/"; %>
<Module>
	<ModulePrefs 	title="NLFlashBridge" 
					      title_url="http://www.proximity.bbdo.be" 
                width="720" height="600" 
                author="Proximity BBDO" author_email="pieterm@dmc.be">
					
		<Require feature="opensocial-0.8" />
		<Require feature="flash" />
		<Require feature="views" />
		<Require feature="netlog" />
		<Require feature="dynamic-height"/>
		<Require feature="settitle" />
		
		<!--<Locale messages="http://messages.xml"/>-->
	</ModulePrefs>
	
	<Content type="html" view="canvas">
		<![CDATA[
		
		<script type="text/javascript" src="<%=absoluteURL%>/netlog/js/jquery-1.6.1.min.js"></script>
		<script type="text/javascript" src="<%=absoluteURL%>/netlog/js/swfobject.js"></script>
		
		<script type="text/javascript" src="<%=absoluteURL%>/netlog/js/osFlashBridge/osFlashBridge.utils.js"></script>
		<script type="text/javascript" src="<%=absoluteURL%>/netlog/js/osFlashBridge/osFlashBridge.js"></script>
		
		<script type="text/javascript">
		
			var flashvars = { p: "netlog", globalURL: "<%=absoluteURL%>"  };
			var params = { allowFullScreen : true, allowScriptAccess: "always" };
			var attributes = { id: "flash_flash" };
			
			swfobject.embedSWF("<%=absoluteURL%>/ExampleProject.swf", "flash_alternative", "720", "600", "9.0.0", "<%=absoluteURL%>assets/swf/expressInstall.swf", flashvars, params, attributes);
			
			gadgets.window.adjustHeight(600);
			
		</script>
		
		<div id="flash_alternative">
			Alternative
		</div>
					
		]]>
	</Content>
	
	<Content type="html" view="profile">
		<![CDATA[
		
		<h1>OSFlashBridge</h1>
							
		]]>
	</Content>
</Module>
