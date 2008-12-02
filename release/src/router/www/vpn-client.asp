<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.0//EN'>
<!--
	Tomato GUI
	Copyright (C) 2006-2008 Jonathan Zarate
	http://www.polarcloud.com/tomato/

	Portions Copyright (C) 2008 Keith Moyer, tomato@keithmoyer.com

	For use with Tomato Firmware only.
	No part of this file may be used without permission.
-->
<html>
<head>
<meta http-equiv='content-type' content='text/html;charset=utf-8'>
<meta name='robots' content='noindex,nofollow'>
<title>[<% ident(); %>] VPN: Client</title>
<link rel='stylesheet' type='text/css' href='tomato.css'>
<link rel='stylesheet' type='text/css' href='color.css'>
<script type='text/javascript' src='tomato.js'></script>
<script type='text/javascript'>

//	<% nvram("vpn_client1_if,vpn_client1_bridge,vpn_client1_nat,vpn_client1_proto,vpn_client1_addr,vpn_client1_port,vpn_client1_retry,vpn_client1_crypt,vpn_client1_comp,vpn_client1_cipher,vpn_client1_local,vpn_client1_remote,vpn_client1_nm,vpn_client1_hmac,vpn_client1_custom,vpn_client1_static,vpn_client1_ca,vpn_client1_crt,vpn_client1_key,vpn_client2_if,vpn_client2_bridge,vpn_client2_nat,vpn_client2_proto,vpn_client2_addr,vpn_client2_port,vpn_client2_retry,vpn_client2_crypt,vpn_client2_comp,vpn_client2_cipher,vpn_client2_local,vpn_client2_remote,vpn_client2_nm,vpn_client2_hmac,vpn_client2_custom,vpn_client2_static,vpn_client2_ca,vpn_client2_crt,vpn_client2_key"); %>

tabs = [['client1', 'Client 1'],['client2', 'Client 2']];
ciphers = [['default','Use Default'],['none','None']<% vpnciphers(); %>];

changed = 0;
vpn1up = parseInt('<% psup("vpnclient1"); %>');
vpn2up = parseInt('<% psup("vpnclient2"); %>');

function tabSelect(name)
{
	tabHigh(name);

	for (var i = 0; i < tabs.length; ++i)
	{
		var on = (name == tabs[i][0]);
		elem.display(tabs[i][0] + '-tab', on);
	}

	cookie.set('vpn_client_tab', name);
}

function toggle(service, isup)
{
	if (changed && !confirm("Unsaved changes will be lost. Continue anyway?")) return;

	E('_' + service + '_button').disabled = true;
	form.submitHidden('service.cgi', {
		_redirect: 'vpn-client.asp',
		_sleep: '3',
		_service: service + (isup ? '-stop' : '-start')
	});
}

function verifyFields(focused, quiet)
{
	var ret = 1;

	// When settings change, make sure we restart the right client
	if (focused)
	{
		changed = 1;

		var clientindex = focused.name.indexOf("client");
		if (clientindex >= 0)
		{
			var clientnumber = focused.name.substring(clientindex+6,clientindex+7);
			var stripped = focused.name.substring(0,clientindex+6)+focused.name.substring(clientindex+7);

			if (stripped == 'vpn_client_local')
				E('_f_vpn_client'+clientnumber+'_local').value = focused.value;
			else if (stripped == 'f_vpn_client_local')
				E('_vpn_client'+clientnumber+'_local').value = focused.value;

			if (eval('vpn'+clientnumber+'up') && fom._service.value.indexOf('client'+clientnumber) < 0)
			{
				var fom = E('_fom');
				if ( fom._service.value != "" ) fom._service.value += ",";
				fom._service.value += 'vpnclient'+clientnumber+'-restart';
			}
		}
	}

	// Element varification
	for (i = 0; i < tabs.length; ++i)
	{
		t = tabs[i][0];

		if (!v_ip('_vpn_'+t+'_addr', true) && !v_domain('_vpn_'+t+'_addr', true)) { ferror.set(E('_vpn_'+t+'_addr'), "Invalid server address.", quiet); ret = 0; }
		if (!v_port('_vpn_'+t+'_port', quiet)) ret = 0;
		if (!v_ip('_vpn_'+t+'_local', quiet, 1)) ret = 0;
		if (!v_ip('_f_vpn_'+t+'_local', true, 1)) ret = 0;
		if (!v_ip('_vpn_'+t+'_remote', quiet, 1)) ret = 0;
		if (!v_netmask('_vpn_'+t+'_nm', quiet)) ret = 0;
		if (!v_range('_vpn_'+t+'_retry', quiet, -1, 32767)) ret = 0;
		if (!v_length('_vpn_'+t+'_custom', quiet, 0, 1024)) ret = 0;
		if (!v_length('_vpn_'+t+'_static', quiet, 0, 1024)) ret = 0;
		if (!v_length('_vpn_'+t+'_ca', quiet, 0, 1648)) ret = 0;
		if (!v_length('_vpn_'+t+'_crt', quiet, 0, 1392)) ret = 0;
		if (!v_length('_vpn_'+t+'_key', quiet, 0, 1024)) ret = 0;
	}

	// Visability changes
	for (i = 0; i < tabs.length; ++i)
	{
		t = tabs[i][0];

		auth = E('_vpn_'+t+'_crypt');
		iface = E('_vpn_'+t+'_if');
		bridge = E('_f_vpn_'+t+'_bridge');
		nat = E('_f_vpn_'+t+'_nat');
		hmac = E('_vpn_'+t+'_hmac');

		elem.display(PR('_vpn_'+t+'_ca'), PR('_vpn_'+t+'_crt'), PR('_vpn_'+t+'_key'), PR('_vpn_'+t+'_hmac'), auth.value == "tls");
		elem.display(PR('_vpn_'+t+'_static'), auth.value == "secret" || (auth.value == "tls" && hmac.value >= 0));
		elem.display(E(t+'_custom_crypto_text'), auth.value == "custom");
		elem.display(PR('_f_vpn_'+t+'_bridge'), iface.value == "tap");
		elem.display(E(t+'_bridge_warn_text'), !bridge.checked);
		elem.display(PR('_f_vpn_'+t+'_nat'), iface.value == "tun" || !bridge.checked);
		elem.display(E(t+'_nat_warn_text'), !nat.checked || (auth.value == "secret" && iface.value == "tun"));
		elem.display(PR('_vpn_'+t+'_local'), auth.value == "secret" && iface.value == "tun");
		elem.display(PR('_f_vpn_'+t+'_local'), auth.value == "secret" && (iface.value == "tap" && !bridge.checked));
	}

	return ret;
}

function save()
{
	if (!verifyFields(null, false)) return;

	var fom = E('_fom');

	for (i = 0; i < tabs.length; ++i)
	{
		t = tabs[i][0];

		E('vpn_'+t+'_bridge').value = E('_f_vpn_'+t+'_bridge').checked ? 1 : 0;
		E('vpn_'+t+'_nat').value = E('_f_vpn_'+t+'_nat').checked ? 1 : 0;
	}

	form.submit(fom, 1);

	changed = 0;
}
</script>

<style type='text/css'>
textarea {
	width: 98%;
	height: 10em;
}
</style>

</head>
<body>
<form id='_fom' method='post' action='tomato.cgi'>
<table id='container' cellspacing=0>
<tr><td colspan=2 id='header'>
	<div class='title'>Tomato</div>
	<div class='version'>Version <% version(); %></div>
</td></tr>
<tr id='body'><td id='navi'><script type='text/javascript'>navi()</script></td>
<td id='content'>
<div id='ident'><% ident(); %></div>

<input type='hidden' name='_nextpage' value='vpn-client.asp'>
<input type='hidden' name='_nextwait' value='5'>
<input type='hidden' name='_service' value=''>

<div class='section-title'>VPN Client Configuration</div>
<div class='section'>
<script type='text/javascript'>
tabCreate.apply(this, tabs);

for (i = 0; i < tabs.length; ++i)
{
	t = tabs[i][0];
	W('<div id=\''+t+'-tab\'>');
	W('<input type=\'hidden\' id=\'vpn_'+t+'_bridge\' name=\'vpn_'+t+'_bridge\'>');
	W('<input type=\'hidden\' id=\'vpn_'+t+'_nat\' name=\'vpn_'+t+'_nat\'>');
	createFieldTable('', [
		{ title: 'Interface Type', name: 'vpn_'+t+'_if', type: 'select', options: [ ['tap','TAP'], ['tun','TUN'] ], value: eval( 'nvram.vpn_'+t+'_if' ) },
		{ title: 'Protocol', name: 'vpn_'+t+'_proto', type: 'select', options: [ ['udp','UDP'], ['tcp-client','TCP'] ], value: eval( 'nvram.vpn_'+t+'_proto' ) },
		{ title: 'Server Address/Port', multi: [
			{ name: 'vpn_'+t+'_addr', type: 'text', maxlen: 32, size: 17, value: eval( 'nvram.vpn_'+t+'_addr' ) },
			{ name: 'vpn_'+t+'_port', type: 'text', maxlen: 5, size: 7, value: eval( 'nvram.vpn_'+t+'_port' ) } ] },
		{ title: 'Authorization Mode', name: 'vpn_'+t+'_crypt', type: 'select', options: [ ['tls', 'TLS'], ['secret', 'Static Key'], ['custom', 'Custom'] ], value: eval( 'nvram.vpn_'+t+'_crypt' ),
			suffix: '<span id=\''+t+'_custom_crypto_text\'>&nbsp;<small>(configured below...)</small></span>' },
		{ title: 'Extra HMAC authorization (tls-auth)', name: 'vpn_'+t+'_hmac', type: 'select', options: [ [-1, 'Disabled'], [2, 'Bi-directional'], [0, 'Incoming (0)'], [1, 'Outgoing (1)'] ], value: eval( 'nvram.vpn_'+t+'_hmac' ) },
		{ title: 'Server is on the same subnet', name: 'f_vpn_'+t+'_bridge', type: 'checkbox', value: eval( 'nvram.vpn_'+t+'_bridge' ) != 0,
			suffix: '<span style="color: red" id=\''+t+'_bridge_warn_text\'>&nbsp<small>Warning: Cannot bridge distinct subnets. Defaulting to routed mode.<small></span>' },
		{ title: 'Create NAT on tunnel', name: 'f_vpn_'+t+'_nat', type: 'checkbox', value: eval( 'nvram.vpn_'+t+'_nat' ) != 0,
			suffix: '<span style="font-style: italic" id=\''+t+'_nat_warn_text\'>&nbsp<small>Routes must be configured manually.<small></span>' },
		{ title: 'Local/remote endpoint addresses', multi: [
			{ name: 'vpn_'+t+'_local', type: 'text', maxlen: 15, size: 17, value: eval( 'nvram.vpn_'+t+'_local' ) },
			{ name: 'vpn_'+t+'_remote', type: 'text', maxlen: 15, size: 17, value: eval( 'nvram.vpn_'+t+'_remote' ) } ] },
		{ title: 'Tunnel address/netmask', multi: [
			{ name: 'f_vpn_'+t+'_local', type: 'text', maxlen: 15, size: 17, value: eval( 'nvram.vpn_'+t+'_local' ) },
			{ name: 'vpn_'+t+'_nm', type: 'text', maxlen: 15, size: 17, value: eval( 'nvram.vpn_'+t+'_nm' ) } ] },
		{ title: 'Encryption cipher', name: 'vpn_'+t+'_cipher', type: 'select', options: ciphers, value: eval( 'nvram.vpn_'+t+'_cipher' ) },
		{ title: 'Compression', name: 'vpn_'+t+'_comp', type: 'select', options: [ ['yes', 'Enabled'], ['no', 'Disabled'], ['adaptive', 'Adaptive'] ], value: eval( 'nvram.vpn_'+t+'_comp' ) },
		{ title: 'Connection retry', name: 'vpn_'+t+'_retry', type: 'text', maxlen: 5, size: 7, value: eval( 'nvram.vpn_'+t+'_retry' ),
			suffix: '&nbsp;<small>(in seconds; -1 for infinite)</small>' },
		{ title: 'Custom Configuration', name: 'vpn_'+t+'_custom', type: 'textarea', value: eval( 'nvram.vpn_'+t+'_custom' ) },
		{ title: 'Static Key', name: 'vpn_'+t+'_static', type: 'textarea', value: eval( 'nvram.vpn_'+t+'_static' ) },
		{ title: 'Certificate Authority', name: 'vpn_'+t+'_ca', type: 'textarea', value: eval( 'nvram.vpn_'+t+'_ca' ) },
		{ title: 'Client Certificate', name: 'vpn_'+t+'_crt', type: 'textarea', value: eval( 'nvram.vpn_'+t+'_crt' ) },
		{ title: 'Client Key', name: 'vpn_'+t+'_key', type: 'textarea', value: eval( 'nvram.vpn_'+t+'_key' ) }
	]);
	W('<input type="button" value="' + (eval('vpn'+(i+1)+'up') ? 'Stop' : 'Start') + ' Now" onclick="toggle(\'vpn'+t+'\', vpn'+(i+1)+'up)" id="_vpn'+t+'_button">');
	W('</div>');
}

</script>
</div>

</td></tr>
	<tr><td id='footer' colspan=2>
	<span id='footer-msg'></span>
	<input type='button' value='Save' id='save-button' onclick='save()'>
	<input type='button' value='Cancel' id='cancel-button' onclick='javascript:reloadPage();'>
</td></tr>
</table>
</form>
<script type='text/javascript'>tabSelect(cookie.get('vpn_client_tab') || tabs[0][0]); verifyFields(null, 1);</script>
</body>
</html>
