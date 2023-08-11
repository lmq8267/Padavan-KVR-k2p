<!DOCTYPE html>
<html>
<head>
<title><#Web_Title#> - Alist文件列表</title>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<meta http-equiv="Pragma" content="no-cache">
<meta http-equiv="Expires" content="-1">

<link rel="shortcut icon" href="images/favicon.ico">
<link rel="icon" href="images/favicon.png">
<link rel="stylesheet" type="text/css" href="/bootstrap/css/bootstrap.min.css">
<link rel="stylesheet" type="text/css" href="/bootstrap/css/main.css">
<link rel="stylesheet" type="text/css" href="/bootstrap/css/engage.itoggle.css">

<script type="text/javascript" src="/jquery.js"></script>
<script type="text/javascript" src="/bootstrap/js/bootstrap.min.js"></script>
<script type="text/javascript" src="/bootstrap/js/engage.itoggle.min.js"></script>
<script type="text/javascript" src="/state.js"></script>
<script type="text/javascript" src="/general.js"></script>
<script type="text/javascript" src="/itoggle.js"></script>
<script type="text/javascript" src="/client_function.js"></script>
<script type="text/javascript" src="/popup.js"></script>
<script type="text/javascript" src="/help.js"></script>
<script type="text/javascript" src="/help_b.js"></script>
<script>
var $j = jQuery.noConflict();

$j(document).ready(function() {
	
	init_itoggle('aliyundrive_enable');
	init_itoggle('ald_no_trash');
	init_itoggle('ald_read_only');
	init_itoggle('ald_domain_id');

});

</script>
<script>
<% aliyundrive_status(); %>
<% login_state_hook(); %>


function initial(){
	show_banner(2);
	show_menu(5,22,0);
	fill_status(aliyundrive_status());
	show_footer();
}
function button_ald_port(){
		var port = '5244';
		var porturl ='http://' + window.location.hostname + ":" + port;
		//alert(porturl);
		window.open(porturl,'ald_port');
}
function fill_status(status_code){
	var stext = "Unknown";
	if (status_code == 0)
		stext = "<#Stopped#>";
	else if (status_code == 1)
		stext = "<#Running#>";
	$("aliyundrive_status").innerHTML = '<span class="label label-' + (status_code != 0 ? 'success' : 'warning') + '">' + stext + '</span>';
}
function applyRule(){
	showLoading();
	
	document.form.action_mode.value = " Restart ";
	document.form.current_page.value = "/Advanced_aliyundrive.asp";
	document.form.next_page.value = "";
	
	document.form.submit();
}

function done_validating(action){
	refreshpage();
}



</script>
</head>

<body onload="initial();" onunLoad="return unload_body();">

<div id="Loading" class="popup_bg"></div>

<div class="wrapper">
	<div class="container-fluid" style="padding-right: 0px">
		<div class="row-fluid">
			<div class="span3"><center><div id="logo"></div></center></div>
			<div class="span9" >
				<div id="TopBanner"></div>
			</div>
		</div>
	</div>

	<iframe name="hidden_frame" id="hidden_frame" src="" width="0" height="0" frameborder="0"></iframe>

	<form method="post" name="form" id="ruleForm" action="/start_apply.htm" target="hidden_frame">

	<input type="hidden" name="current_page" value="Advanced_aliyundrive.asp">
	<input type="hidden" name="next_page" value="">
	<input type="hidden" name="next_host" value="">
	<input type="hidden" name="sid_list" value="ALDRIVER;">
	<input type="hidden" name="group_id" value="">
	<input type="hidden" name="action_mode" value="">
	<input type="hidden" name="action_script" value="">


	<div class="container-fluid">
		<div class="row-fluid">
			<div class="span3">
				<!--Sidebar content-->
				<!--=====Beginning of Main Menu=====-->
				<div class="well sidebar-nav side_nav" style="padding: 0px;">
					<ul id="mainMenu" class="clearfix"></ul>
					<ul class="clearfix">
						<li>
							<div id="subMenu" class="accordion"></div>
						</li>
					</ul>
				</div>
			</div>

			<div class="span9">
				<!--Body content-->
				<div class="row-fluid">
					<div class="span12">
						<div class="box well grad_colour_dark_blue">
							<h2 class="box_head round_top">Alist文件列表</h2>
							<div class="round_bottom">
								<div class="row-fluid">
									<div id="tabMenu" class="submenuBlock"></div>
									<div class="alert alert-info" style="margin: 10px;">
									<p>Alist 一个支持多种存储的文件列表程序，由 Gin 和 Solidjs 提供支持。
									<p>项目地址：<a href="https://github.com/alist-org/alist" target="blank">https://github.com/alist-org/alist</a><p>
                    注意：没有插USB存储设备的，在主页进行修改alist的设置过后，请手动在系统管理-控制台输入 aliyundrive-webdav.sh save  来保存配置文件，防止断电数据未保存。<p>
如忘记密码可在控制台或ssh输入 aliyundrive-webdav.sh admin 重置密码 或 aliyundrive-webdav.sh set 新密码 修改为新密码
									</div>



									<table width="100%" align="center" cellpadding="4" cellspacing="0" class="table">

										<tr>
											<th>Alist WEB界面</th>
											<td>
				<input type="button" class="btn btn-success" value="Alist主页" onclick="button_ald_port()" size="0">
											</td>
										</tr>
										<tr> <th><#running_status#></th>
                                            <td id="aliyundrive_status" colspan="3"></td>
                                        </tr>
										<tr>
										<th width="30%" style="border-top: 0 none;">启用Alist</th>
											<td style="border-top: 0 none;">
													<div class="main_itoggle">
													<div id="aliyundrive_enable_on_of">
														<input type="checkbox" id="aliyundrive_enable_fake" <% nvram_match_x("", "aliyundrive_enable", "1", "value=1 checked"); %><% nvram_match_x("", "aliyundrive_enable", "0", "value=0"); %>  />
													</div>
												</div>
												<div style="position: absolute; margin-left: -10000px;">
													<input type="radio" value="1" name="aliyundrive_enable" id="aliyundrive_enable_1" class="input" value="1" <% nvram_match_x("", "aliyundrive_enable", "1", "checked"); %> /><#checkbox_Yes#>
													<input type="radio" value="0" name="aliyundrive_enable" id="aliyundrive_enable_0" class="input" value="0" <% nvram_match_x("", "aliyundrive_enable", "0", "checked"); %> /><#checkbox_No#>
												</div>
											</td>

										</tr>
<tr>
										<th width="30%">自动更新版本</th>
											<td>
													<div class="main_itoggle">
													<div id="ald_read_only_on_of">
														<input type="checkbox" id="ald_read_only_fake" <% nvram_match_x("", "ald_read_only", "1", "value=1 checked"); %><% nvram_match_x("", "ald_read_only", "0", "value=0"); %>  />
													</div>
												</div>
												<div style="position: absolute; margin-left: -10000px;">
													<input type="radio" value="1" name="ald_read_only" id="ald_read_only_1" class="input" value="1" <% nvram_match_x("", "ald_read_only", "1", "checked"); %> /><#checkbox_Yes#>
													<input type="radio" value="0" name="ald_read_only" id="ald_read_only_0" class="input" value="0" <% nvram_match_x("", "ald_read_only", "0", "checked"); %> /><#checkbox_No#>
												</div>
											</td>
										</tr>
										<tr>
										<th>CDN服务器</th>
				<td>
					<input type="text" class="input" name="ald_refresh_token" id="ald_refresh_token" style="width: 200px" value="<% nvram_get_x("","ald_refresh_token"); %>" />
				</td>

										</tr>
										<tr>
										<th>用户登录过期时间</th>
				<td>
					<input type="text" class="input" name="ald_root" id="ald_root" style="width: 200px" value="<% nvram_get_x("","ald_root"); %>" />单位/小时
				</td>

										</tr>
										<tr>
										<th>https访问端口</th>
				<td>
					<input type="text" class="input" name="ald_host" id="ald_host" style="width: 200px" value="<% nvram_get_x("","ald_host"); %>" />
				</td>

										</tr>
										<tr>
										<th>http主页访问端口</th>
				<td>
					<input type="text" class="input" name="ald_port" id="ald_port" style="width: 200px" value="<% nvram_get_x("","ald_port"); %>" />
				</td>

										</tr>
										<tr>
										<th>数据库存放路径</th>
				<td>
					<input type="text" class="input" name="ald_auth_user" id="ald_auth_user" style="width: 200px" value="<% nvram_get_x("","ald_auth_user"); %>" />
				</td>

										</tr>
										<tr>
										<th>临时文件存放路径</th>
				<td>
					<input type="text" class="input" name="ald_auth_password" id="ald_auth_password" style="width: 200px" value="<% nvram_get_x("","ald_auth_password"); %>" />
				</td>

										</tr>
										<tr>
										<th>bleve 索引数据路径</th>
				<td>
					<input type="text" class="input" name="ald_read_buffer_size" id="ald_read_buffer_size" style="width: 200px" value="<% nvram_get_x("","ald_read_buffer_size"); %>" />
				</td>

										</tr>
										<tr>
										<th>程序日志开关</th>
				<td>
					<input type="text" class="input" name="ald_cache_size" id="ald_cache_size" style="width: 200px" value="<% nvram_get_x("","ald_cache_size"); %>" />关闭: false 开启: true
				</td>

										</tr>
										<tr>
										<th>程序日志路径</th>
				<td>
					<input type="text" class="input" name="ald_cache_ttl" id="ald_cache_ttl" style="width: 200px" value="<% nvram_get_x("","ald_cache_ttl"); %>" />
				</td>
				<tr>
										<th >访问地址</th>
<td>
<input type="text" class="input" name="ald_domain_id" id="ald_domain_id" style="width: 200px" value="<% nvram_get_x("","ald_domain_id"); %>" />
				</td>
				<tr>

										<tr>
											<td colspan="4" style="border-top: 0 none;">
												<br />
												<center><input class="btn btn-primary" style="width: 219px" type="button" value="<#CTL_apply#>" onclick="applyRule()" /></center>
											</td>
										</tr>
</table>

										
								</div>
							</div>
						</div>
					</div>
				</div>
			</div>
		</div>
	</div>

	</form>

	<div id="footer"></div>
</div>
</body>
</html>

