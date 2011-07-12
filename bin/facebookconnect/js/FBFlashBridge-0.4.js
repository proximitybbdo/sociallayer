/*
 * fbFlashBridge - Facebook Connect Flash Bridge
 * 
 * Open source under the GNU Lesser General Public License (http://www.opensource.org/licenses/lgpl-license.php)
 * Copyright © 2010 Pieter Michels
 * 
 * This library is free software; you can redistribute it and/or modify it under the terms of the GNU Lesser General Public License 
 * as published by the Free Software Foundation; either version 2.1 of the License, or (at your option) any later version.
 * This library is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty 
 * of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.
 * You should have received a copy of the GNU Lesser General Public License along with this library; 
 * if not, write to the Free Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA 
 *
 * @author	Pieter Michels
 *
 */
 
/**
 * @class	Facebook Connect Flash Bridge
 *
 * @author	Pieter Michels
 * @version	0.4
 * @requires	jQuery library (> 1.2.6) 
 *
 * @param	{String}	flashObject	Reference to the Flash object
 *
 * @constructor
 */
function FBFlashBridge(flashObjectFunction, flashObjectName) {
	
	// Constructor Variables
	var _oFlashFunc = flashObjectFunction;
	var _oFlashName = flashObjectName;
	
	// Static (Public) Variables
	this.LOGGED_IN = "LOGGED_IN"; 
	this.LOGGED_IN_CANCELED = "LOGGED_IN_CANCELED";
	this.NOT_LOGGED_IN = "NOT_LOGGED_IN";
	this.LOGGED_OUT = "LOGGED_OUT";
	
	this.STREAM_GET = "STREAM_GET";
	this.STREAM_COMMENTS_GET = "STREAM_COMMENTS_GET";
	
	this.PERMISSIONS_SET = "PERMISSIONS_SET"; 
	this.PERMISSIONS_NOT_SET = "PERMISSIONS_NOT_SET";
	
	this.FRIENDS_GET = "FRIENDS_GET";
	this.APP_USERS = "APP_USERS";
	
	this.USER_INFO = "USER_INFO";
	this.USERS_INFO = "USERS_INFO";
	
	this.EMAIL_SENT = "EMAIL_SENT";
	this.NOTIFICATION_SENT = "NOTIFICATION_SENT";
	this.NOTIFICATIONS_GET = "NOTIFICATIONS_GET";  
	this.PUBLISHED_POST = "PUBLISHED_POST";
	
	// Private Variables
	var _s = this;
	
	var _session;
	var _perms = "";
	
	var _isLoggedIn = false;
	var _isFlashReady = false;
	
	/**
	 * Initialize class
	 */
	function init() {
		trace("Init FBFlashBridge");
		
		FB.getLoginStatus(function(response) {
			if (response.session) {
				inspect(_session);		
						
				_session = response.session;

				try{
					if(response.perms)
						response.perms = JSON.parse(response.perms);
				} catch(err) {
					trace("Respone perms error")
				}
				
				if(response.perms)
					_perms = response.perms.extended ? response.perms.extended : [];
				
				onLoggedIn();
			} else {
				trace("No user session available, someone you dont know");
			}
		});
	}
	
	//*********************************************************//
	
	/**
	 * Log In
	 *
	 * @public
	 */
	function login(perms) {
		trace("Login");
		
		set_ready();

		FB.login(function(response) {
			if (response.session) {
				trace("LOG IN READY");

				_session = response.session;
				
				try{
					if(response.perms)
						response.perms = response.perms.split(",");
				}	catch(err) {
					trace("Respone perms error")
			  }
				
				_perms = response.perms ? response.perms : [];
				
				onLoggedIn();
			} else {
				trace("LOG IN CANCELED");

				dispatchEvent(_s.LOGGED_IN_CANCELED);
			}
		}, {perms: perms});
	}
	
		/**
		 *
		 * @private
		 */
		function onLoggedIn() {
			trace("onLoggedIn");
			
			if(!_isLoggedIn) {
				_isLoggedIn = true;
				
				inspect(_session);
				
				dispatchEvent(_s.LOGGED_IN, {session: _session, perms: _perms});
			}
		}
	
	/**
	 * Log Out
	 *
	 * @public
	 */
	function logout() {
		trace("Log Out");
		
		set_ready();
		
		FB.logout(function(response) {
			trace(_s.LOGGED_OUT);
			
			_isLoggedIn = false;
			
			dispatchEvent(_s.LOGGED_OUT, true);
		});
	}
	
	/**
	 * Is user logged in?
	 *
	 * @public
	 */
	function isLoggedIn() {
		return _isLoggedIn;
	}
	
	/**
	 * Get current sessions
	 *
	 * @public
	 */
	function getSession() {
		return _session;
	}
	
	/**
	 * Get current perms
	 *
	 * @public
	 */
	function getPerms() {
		return _perms;
	}
	
	//*********************************************************//
	
	/**
	 * Ask for permissions.
	 * http://wiki.developers.facebook.com/index.php/Extended_permissions
	 *
	 * @param	{String}	permissions	The permission you want to ask, can be more than one (comma separated)
	 *
	 * @public
	 */
	function askPermissions(permissions) {
		trace("Ask Permissions: " + permissions);
		
		set_ready();
		
		FB.login(function(response) {
			if (response.session) {
				if (response.perms) {
					trace(_s.PERMISSIONS_SET);
	    		
					_perms = response.perms;
	
	    		dispatchEvent(_s.PERMISSIONS_SET, true);
				} else {
					trace(_s.PERMISSIONS_NOT_SET);
				
					dispatchEvent(_s.PERMISSIONS_NOT_SET, true);
				}
			} else {
				// user is not logged in
			}
		}, {perms: permissions});
	}
	
	/**
	 * Get all users of the application
	 *
	 * @public
	 */
	function getAppUsers() {
		trace("Get Users of this application");
		
		set_ready();
		
		FB.api({
				method: 'friends.getAppUsers'
			}, function(result) {
				trace(_s.APP_USERS);

				trace(result);
				inspect(result);

				if(!$.isArray(result))
					result = [];

				dispatchEvent(_s.APP_USERS, result);
		});	
	}
	
	/**
	 * Get friends of the logged in user
	 *
	 * @public
	 */
	function getFriends() {
		trace("Get Friends of logged in user");
		
		set_ready();
		
		FB.api({
				method: 'friends.get'
			}, function(result) {
				trace(_s.FRIENDS_GET);

				//trace(result);
				//inspect(result);

				if(!$.isArray(result))
					result = [];

				dispatchEvent(_s.FRIENDS_GET, result);
		});		
	}
	
	/**
	 * Get info of array of users (can contain 1 element)
	 *
	 * @param	{Array}	uids 	List of uids you want to access
	 * @param	{Array}	fields	List of fields
	 *
	 * @public
	 */
	function getUsersInfo(uids, fields) {
		trace("Get users info for " + uids);
		
		getGenericUsersInfo(uids, fields, function(result){
			trace(_s.USERS_INFO);		
			
			trace(result);			
			inspect(result);

			dispatchEvent(_s.USERS_INFO, result);
		});
	}
	
	/**
	 * Get info of the logged in user
	 *
	 * @param	{Array}	fields	List of fields
	 *
	 * @public
	 */
	function getUserInfo(fields) {
		trace("Get user info for logged in user");
		
		getGenericUsersInfo(_session.uid, fields, function(result){
			trace(_s.USER_INFO);		
			
			trace(result[0]);			
			inspect(result[0]);

			dispatchEvent(_s.USER_INFO, result[0]);
		});
	}
	
		/**
		 *
		 * @private
		 */
		function getGenericUsersInfo(uids, fields, callback) {
			set_ready();
			
			if(!fields)
				fields = ["uid", "pic_square", "first_name", "last_name", "about_me", "sex", "name", "proxied_email", "birthday_date", "is_app_user"]; // Default array of props
			
			FB.api({
					method: 'users.getInfo', 
					uids: uids, 
					fields: fields
				}, function(result) {
					callback(result);
			});
		}
		
	//*********************************************************//
	
	/**
	 * Send e-mail to recipients.
	 *
	 * @param	{String}	recipients	Comma separated list of user ids
	 * @param	{String}	subject	The subject
	 * @param	{String}	text	The e-mail message
	 * @param	{String}	fbml	FBML included in e-mail
	 *
	 * @public
	 */	
	function sendEmail(recipients, subject, text, fbml) {
		trace("Send Email to '" + recipients + "': '" + subject + "', '" + text + "', '" + fbml + "'");
		
		set_ready();
		
		FB.api({
				method: 'notifications.sendEmail', 
				recipients: recipients, 
				subject: subject, 
				text: text, 
				fbml: fbml
			}, function(result) {
				trace(_s.EMAIL_SENT);

				trace(result);
				inspect(result);

				dispatchEvent(_s.EMAIL_SENT, result);
		});
	}
	
	/**
	 * Get all notification messages of current user (includes group invites, event invites, ...)
	 *
	 * @public
	 */
	function getNotifications() {
		trace("Get notifications of logged in user");
		
		set_ready();
		
		FB.api({
				method: 'notifications.get'
			}, function(result) {
				trace(_s.NOTIFICATIONS_GET);

				trace(result);
				inspect(result);

				dispatchEvent(_s.NOTIFICATIONS_GET, result);
		});
	}
	
	//*********************************************************//

	/**
	 * Publish something to the wall of the current logged in user or to the target user (target_id)
	 *
	 * @public
	 */
	function publish(user_message, attachment, action_links, target_id, user_message_prompt) {
		/*var attach = {
				'name':'Go grab your free bundle right now!',
				'href':'http://www.macheist.com/nano/facebook',
				'caption':'Download full copies of six top Mac apps normally costing over $150 totally for free at MacHeist!',
				'description':"There’s something for everyone, whether you’re a gamer, a student, a writer, a twitter addict, or just love Mac apps. Plus as a Facebook user you can also get VirusBarrier X5 ($70) as a bonus. Don’t miss out!",
				'media':[{'type':'image','src':'http://www.macheist.com/static/facebook/facebook_mh.png','href':'http://www.macheist.com/nano/facebook'}]
			}
		*/	
		
		set_ready();
		
		FB.api({
				method: 'stream.publish', 
				message: user_message, 
				attachment: attachment, 
				action_links: action_links, 
				target_id: target_id
			}, function(result) {
				trace(_s.PUBLISHED_POST);

				trace(result);                              

				dispatchEvent(_s.PUBLISHED_POST, result);
		});
	}
	
	/**
	 * Get stream of a user (uid)
	 *
	 * @param	{String}	uid	User id
	 *
	 * @public
	 */
	function getStream(uid) {
		trace("Get Stream of " + uid);
		
		set_ready();
		
		FB.api({
				method: 'stream.get', 
				viewer_id: uid
			}, function(result) {
				trace(_s.STREAM_GET);

				trace(result);
				inspect(result);

				dispatchEvent(_s.STREAM_GET, result);
		});
	}
	
	/**
	 * Get comments of a streal story (post_id)
	 *
	 * @param	{String}	post_id	Post id
	 *
	 * @public
	 */
	function getStreamComments(post_id) {
		trace("Get comments of stream with post_id " + post_id);
		
		set_ready();
		
		FB.api({
				method: 'stream.getComments', 
				post_id: post_id
			}, function(result) {
				trace(_s.STREAM_COMMENTS_GET);

				trace(result);
				inspect(result);

				dispatchEvent(_s.STREAM_COMMENTS_GET, result);
		});
	}
	
	//*********************************************************//
	
	/**
	 * Only called from Flash
	 */
	function onFlashLoaded() {
		trace("onFlashLoaded (from Flash)");
		
		set_ready();
	}	
	
	function set_ready() {
		_isFlashReady = true;
	}
	
	/**
	 * Check logged in status for first call in Flash
	 */
	function checkLogin() {
		trace("checkLogin (from Flash)");
		
		set_ready();
		
		if(_isLoggedIn) { // Notify Flash when FB User is logged in
			trace("FB user logged in.");

			dispatchEvent(_s.LOGGED_IN, {session: this.getSession(), perms: this.getPerms()});
		} else {
			trace("FB user NOT logged in.");
			
			dispatchEvent(_s.NOT_LOGGED_IN, true);
		}
	}
	
	//*********************************************************//
	
	/**
	 * Dispatch Event
	 *
	 * @example	<br />Usage: dispatchEvent("flashFunction", parameter);
	 *
	 * @param	{String}	eventType	Type of event
	 * @param	{String}	data	Data passed as arguments to the functions that are listening
	 *
	 * @public
	 */
	function dispatchEvent(eventType, data) {
		dispatchFlashEvent("handleJSCall", eventType, data);
		
		$(document).trigger(eventType, data);
	}
	
	/**
	 * Listen for event
	 *
	 * @param	{String}	eventType	Type of event you are listening to
	 * @param	{String}	func	Function that will be triggered when the event is fired
	 *
	 * @public
	 */
	function addEventListener(eventType, func) {
		$(document).bind(eventType, function(e, data) { func(data); });
	}
	
	/**
	 * Dispatch Event to Flash Object. 
	 *
	 * @example	<br />Usage: dispatchFlashEvent("flashFunction", parameter1, parameter2, ...);
	 *
	 * @param	{String}	func	Function to call in flash. Arguments can be passed as well as extra parameters
	 *
	 * @public
	 */
	function dispatchFlashEvent(func) {
		var args = Array.prototype.slice.call(arguments).slice(1);
		var oFlash = flashObjectFunction(flashObjectName);

		trace("DFE: " + JSON.stringify(args));
		
		if(oFlash && _isFlashReady) {
			if(arguments.length > 1)
				oFlash[func](args);
			else
				oFlash[func]();
		}
	}
	
	//*********************************************************//
	
	// Init Public Methods
	this.init = init;
	this.login = login;
	this.logout = logout;
	this.isLoggedIn = isLoggedIn;
	
	this.sendEmail = sendEmail;
	this.getNotifications = getNotifications;

	this.publish = publish;
	this.getStream = getStream;
	this.getStreamComments = getStreamComments;
	
	this.askPermissions = askPermissions;
	this.getAppUsers = getAppUsers;
	this.getFriends = getFriends;
	this.getUsersInfo = getUsersInfo;
	this.getUserInfo = getUserInfo;
	
	this.getSession = getSession;
	this.getPerms = getPerms;
	
	this.onFlashLoaded = onFlashLoaded;
	this.checkLogin = checkLogin;
	
	this.dispatchEvent = dispatchEvent;
	this.addEventListener = addEventListener;
	this.dispatchFlashEvent = dispatchFlashEvent;
}

//***********************************************************************************************************//
/*
if(!("console" in window) || !("firebug" in console)) {
    var names = ["log", "debug", "info", "warn", "error", "assert", "dir", "dirxml", "group", "groupEnd", "time", "timeEnd", "count", "trace", "profile", "profileEnd"];

    window.console = {};

    for(var i = 0; i < names.length; ++i) window.console[names[i]] = function() {};
}*/

if(!("console" in window)) {
	var names = ["log", "debug", "info", "warn", "error", "assert", "dir", "dirxml", "group", "groupEnd", "time", "timeEnd", "count", "trace", "profile", "profileEnd"];

  window.console = {};

  for(var i = 0; i < names.length; ++i) window.console[names[i]] = function() {};
}

function trace(msg) {
	// alert(msg);
	
	if(console && console.debug)	
		console.debug(msg);
}

function inspect(obj) {
	if(console && console.dir)	
		console.dir(obj);
}

//***********************************************************************************************************//

