Include apptools.core

/// https://adminlte.io
Class apptools.lte.adminStatic Extends apptools.lte.adminTabs [ ClassType = "", DependsOn = apptools.core.msg, ProcedureBlock ]
{

/// http://localhost:52773/apptoolsrest/a/permiss&autoload=snapshot
/// http://localhost:52773/apptoolsrest/a/infochest
/// http://localhost:52773/apptoolsrest/a/smarthome&autoload=snapshot&namespace=USER
ClassMethod GetMain(parameter, class = "") As %Status
{
	set app=$p(parameter,"&")
	if (app["apptools.core.UploadCSP") quit ..GetAppCSP(app)
	if (app["apptools.core.DownloadCSP") quit ..DownLoadFile(app)
	if parameter["&class=" set class=$p($p(parameter,"&class=",2),"&")		
	set:class="" class="apptools.lte."_app
	set par("input-class=")=class
	;if '##class(apptools.core.sys).ClassExist(class) set class="apptools.lte.page404"
	set cgivar="&"_$p(parameter,"&",2,*)
	set ns=##class(apptools.core.Action).GetParam(,"namespace",cgivar)
	if ns'="" set $namespace=ns
	set par("input-cgivar")=cgivar
    set par("=path=")="/apptools/"
    set par("=Message-default=")=""
	set par("<!--FooterLeft-->")="Applications Tools for Admin."
	set h=##class(apptools.core.rest).getStatic("apptools.lte.adminStatic:html")
    set st=$classmethod(class,"MainParameter",.h,.par) 

	d ##class(apptools.core.rest).WriteStatic("html",,,,,h)
	q $$$OK
}

ClassMethod DownLoadFile(app) As %Status
{
	do $classmethod("apptools.core.DownloadCSP","OnPreHTTP",app)
	do $classmethod("apptools.core.DownloadCSP","OnPage",app)
	q $$$OK
}

ClassMethod GetAppCSP(app) As %Status
{
	d ##class(apptools.core.rest).WriteStatic("html",,,$p(app,".",1,*-1))
	q $$$OK
}

/// s h=##class(apptools.core.rest).getStatic("apptools.lte.adminStatic:AddStyle") w !,h,!
XData AddStyle [ MimeType = application/yaml ]
{
<style type="text/css">
 
 	/* https://habr.com/ru/post/453744/
table {
  overflow: hidden;
}

tr:hover {
  background-color: #ffa;
}

td, th {
  position: relative;
}
td:hover::after,
th:hover::after {
  content: "";
  position: absolute;
  background-color: #ffa;
  left: 0;
  top: -5000px;
  height: 10000px;
  width: 100%;
  z-index: -1;
}
*/

 
 /*
	div {
  max-width: 400px;
  max-height: 150px;
  overflow: scroll;
}
*/

/* Use position: sticky to have it stick to the edge
 * and top, right, or left to choose which edge to stick to: */

thead th {
  position: -webkit-sticky; /* for Safari */
  position: sticky;
  top: 0;
}

tbody th {
  position: -webkit-sticky; /* for Safari */
  position: sticky;
  left: 0;
}

/* To have the header in the first column stick to the left: */

thead th:first-child {
  left: 0;
  z-index: 1;
}


/* Just to display it nicely: */

thead th {
  background: #E7EBF9;
  color: blue;

}

tbody th {
  background: #E7EBF9;
  color: blue;

}

table {
  border-radius: 10px; 
  border: 1px solid #72a7cf
}

td,
th {
  padding: 0.5em;
}

.bigbox { 
height: 20px; width: 20px 
}
 
</style>
}

/// s h=##class(apptools.core.rest).getStatic("apptools.lte.adminStatic:AddJS") w !,h,!
XData AddJS [ MimeType = application/yaml ]
{
<script language='javascript'>
$('#tWHAT').keydown(function (e) {
  	if (e.ctrlKey && e.keyCode == 13) {
    // Ctrl-Enter pressed
    document.getElementById('WHAT').value=document.getElementById('tWHAT').value;
    document.forms['loginfo'].submit();
   }
});
// 
function ActionJs(FormId,ResultId,appClass,appMethod,appPar,appNsp){
	var $data =[];
	//;var appNspace ='#(ns)#';
	//;if (!appNsp) {appNsp =appNspace;}
	//var classname ='#(class)#';
	//if (!appClass) var appClass =classname;
	if (FormId) {
		$data = $('#'+FormId).serializeArray(); 
		//alert(FormId);
	}
	//Add to array
	$data.push({name:"appClass",value:appClass});
	$data.push({name:"appMethod",value:appMethod});
	$data.push({name:"appNsp",value:appNsp});
	$data.push({name:"appPar",value:appPar});
	$.ajax({
	  url: 'apptools.core.Action.cls',
	  type: 'post',
	  data: $data,
	  crossDomain: true,
	  success: function(result) {
	  if (ResultId) {$('#'+ResultId).html(result);}
	  }
	});
}
// Collect data from the form, serialize, send to the server, execute and paste the result into the container
// FormId - source form identifier <form id='FormInpur'>...</form>
// ResultId -  identifier of the target container <div id='ResultDiv'>...</div>
// appAct -  parameters for executing code on the server
//     namespace:classname:methodname:par1=val1&par2=val2...&parX-valX
function AppAct(FormId,ResultId,appAct){
	var $data =[]; //json array initialization
	$data.push({name:"params",value:{}});
	if (FormId) { //if the form id is specified, then we collect all input elements from it
		// elements must have an id attribute matching the name.
		// For example <input type='text' id='elem2' name='elem2'>
		$data = $('#'+FormId).serializeArray();
	}
	$data.push({name:"appAct",value:appAct}); //add execution parameters that will be parsed in apptools.core.Action.cls
	//if (jsonExt) {
	//  if there is additional json, then add it
	//	$data.push({"jsonExt":jsonExt});
	//	}
	//var url1='apptools.core.Action.cls';	if (url2) { url1=url2;}
	//execute an asynchronous request to the apptools.core.Action.cls
	$.ajax({  
	  url: 'apptools.core.Action.cls',
	  type: 'post',
	  data: $data,
	  success: function(result) {  // if successful
	  	// if the resulting container is specified, put everything sent from the server into it
	  	if (ResultId) {$('#'+ResultId).html(result);}
	  }
	});
}
// Collect data from the form, serialize, send to the server, execute and paste the result into the container
// FormId - source form identifier <form id='FormInpur'>...</form>
// ResultId -  identifier of the target container <div id='ResultDiv'>...</div>
// appAct -  parameters for executing code on the server
//     namespace:classname:methodname:par1=val1&par2=val2...&parX-valX
//     namespace:routine:label:par1=val1&par2=val2...&parX-valX
function AppRpc(FormId,ResultId,appAct,url,json){
	var data ={"jsonrpc":"2.0",params:{}};
	
	if (FormId) {
		data.params.formId=FormId;
		data.params.form=JSON.stringify($('#'+FormId).serializeArray());
	}
	if (json) {
		data.params.json = json;
	}

	data.method=appAct;
	$.ajax({
	  url: url,
	  type: 'post',
	  contentType:'application/json; charset=UTF-8',
	  dataType:'html', 
	  crossDomain: true,
	  data: JSON.stringify(data),
	  success: function(result) {
	  if (ResultId) {
		  $('#'+ResultId).html(result);
	  }
	  else {
		  return result;
	  	}
	  }
	});
}

// The function of opening the dialog box
function WinOpen(ns,classname,met,el,title,rest) {
	
	var titlename="Method "+met+" parameter "+decodeURIComponent(el);
	if (title) {titlename=title;}

	//$("#dialogContent").load("apptools.core.Action.cls","appClass="+classname+"&appMethod="+met+"&appNsp="+ns+"&appPar="+el);
	
	if (rest) {AppRpc('anyForm','dialogContent',ns+':'+classname+':'+met+':'+decodeURIComponent(el),rest);}
	else { ActionJs('anyForm',"dialogContent",classname,met,el,ns);}
	$( "#dialog" ).dialog({
		modal: true, 
        title: titlename, 
        autoOpen: true, 
        width:window.innerWidth-200, 
        height:window.innerHeight-300,
		position: { my: 'top', at: 'top+150' },
		buttons: [
		{
			text: "Cancel",
			click: function() {
				$( this ).dialog( "close" );
			}
		}
		]
		});
	try { event.preventDefault();
	} catch (e){};
}
</script>
}

/// s h=##class(apptools.core.rest).getStatic("apptools.Uikit.AdminLTE:html") w !,h,!
XData html [ MimeType = application/yaml ]
{
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>=titleAppToolsadmin=</title>

  <!-- Google Font: Source Sans Pro -->
  <!--<link rel="stylesheet" href="https://fonts.googleapis.com/css?family=Source+Sans+Pro:300,400,400i,700&display=fallback">-->
  <!-- Font Awesome Icons -->
  <link rel="stylesheet" href="=path=adminlte/plugins/fontawesome-free/css/all.min.css">
  <!-- overlayScrollbars -->
  <link rel="stylesheet" href="=path=adminlte/plugins/overlayScrollbars/css/OverlayScrollbars.min.css">
  <!-- Theme style -->
  <link rel="stylesheet" href="=path=adminlte/dist/css/adminlte.min.css">
  <link rel="stylesheet" href="=path=jqueryui/jquery-ui.css">
  <!--=LinkIcon=-->
  <!--=Links=-->
</head>
<body class="hold-transition dark-mode sidebar-mini layout-fixed layout-navbar-fixed layout-footer-fixed">
<div class="wrapper">

  <!-- Preloader -->
  <div class="preloader flex-column justify-content-center align-items-center">
    <img class="animation__wobble" src="=path=adminlte/dist/img/ApptoolsLogo.png" alt="ApptoolLogo" height="60" width="60">
  </div>

  <!-- Navbar -->
  <nav class="main-header navbar navbar-expand navbar-dark">
    <!-- Left navbar links -->
	
    <ul class="navbar-nav">
      <li class="nav-item">
        <a class="nav-link" id="HideSideMenu" data-widget="pushmenu" href="#" role="button"><i class="fas fa-bars"></i></a>
      </li>
      <!--<li class="nav-item d-none d-sm-inline-block">
        <a href="#" onclick="document.location.reload();" class="nav-link">Home</a>
      </li>-->
    </ul>

    <!-- Right navbar links -->
	<ul class="navbar-nav ml-auto">
      <!-- =Navbar Search= -->
      <li class="nav-item">
        <div class="navbar-search-block">
         
            <div class="input-group input-group-sm">
              <input class="form-control" placeholder="Search" id="MainSearch" aria-label="Search" >
              <div class="input-group-append">
                <button class="btn btn-navbar" type="button" id="MainSearchRun" onclick="AppRpc('','MainHidden','%SYS:apptools.lte.adminTabs:ShowTab:&appPar=Search&Searchstr='+$('#MainSearch').val(),'/apptoolsrest/post-json');" >
                  <i class="fas fa-search"></i>
                </button>
                <button class="btn btn-navbar" type="button" data-widget="navbar-search" onclick="$('#MainSearch').val('');">
                  <i class="fas fa-times"></i>
                </button>
              </div>
            </div>
         
        </div>
      </li>

      <!-- Notifications Dropdown Menu -->
	  <!-- =Item Dropdown Menu= -->

      <li class="nav-item">
        <a class="nav-link" data-widget="fullscreen" href="#" role="button">
          <i class="fas fa-expand-arrows-alt"></i>
        </a>
      </li>
    </ul>
  </nav>
  <!-- /.navbar -->

  <!-- Main Sidebar Container -->
  <aside class="main-sidebar sidebar-dark-primary elevation-4">
    <!-- Brand Logo -->
    <a href="#" onclick="document.location.reload();" class="brand-link">
      <img src="=Logo-image=" alt="ApptoolsLogo" class="brand-image img-circle elevation-3" style="opacity: .8">
      <span class="brand-text font-weight-light">=Brand-Text=</span>
    </a>

    <!-- Sidebar -->
    <div class="sidebar">
      
	  <!-- Sidebar user panel (optional) -->
	  <!--
      <div class="user-panel mt-3 pb-3 mb-3 d-flex">
        <div class="image">
          <img src="dist/img/user2-160x160.jpg" class="img-circle elevation-2" alt="User Image">
        </div>
        <div class="info">
          <a href="#" class="d-block">Alexander Pierce</a>
        </div>
      </div>
		-->

      <!-- SidebarSearch Form -->
	  <div class="form-inline">
        <div class="input-group" data-widget="sidebar-search">
          <input class="form-control form-control-sidebar" type="search" placeholder="Search" aria-label="Search">
          <div class="input-group-append">
            <button class="btn btn-sidebar">
              <i class="fas fa-search fa-fw"></i>
            </button>
          </div>
        </div>
      </div>

      <!-- Sidebar Menu -->
      <nav class="mt-2">
        <ul class="nav nav-pills nav-sidebar flex-column" data-widget="treeview" role="menu" data-accordion="false">
          <!-- Add icons to the links using the .nav-icon class
               with font-awesome or any other icon font library -->
          <!-- =Sidebar Menu= -->
        </ul>
      </nav>
      <!-- /.sidebar-menu -->
    </div>
    <!-- /.sidebar -->
  </aside>

  <!-- Content Wrapper. Contains page content -->
  <div class="content-wrapper">

    <!-- Main content -->
    <section class="content">
      <div class="container-fluid">
        <!-- Info boxes -->
       <div class="row">
       
       <!-- Uikit Tab start -->
	    <div class="uk-width-1-1 uk-margin-left uk-margin-right " style='overflow: auto;' id="mainApp" >
			<ul id='tabMenu' class="uk-tab uk-tab-grid uk-tab-top" data-uk-tab="{connect:'#tabList', animation: 'fade'}">
				<li id='t1' class="uk-active"><a href="#"><font color=Lightsteelblue>=Tab=</font></a></li>
			</ul>
			<ul id="tabList" class="uk-switcher uk-margin uk-tab-content">
				<li id='ta1' >
			 	<div class="uk-alert-warning" uk-alert>
					<p>=Message-default=</p>
			 	</div>
				</li>
			</ul>
		</div>
		<!-- Uikit Tab start -->
	
   
      </div>
       <!-- /.row -->
		</div><!--/. container-fluid -->
    </section>
    <!-- /.content -->
  </div>
  <!-- /.content-wrapper -->

  <!-- Control Sidebar -->
  <aside class="control-sidebar control-sidebar-dark">
    <!-- Control sidebar content goes here -->
  </aside>
  <!-- /.control-sidebar -->

  <!-- Main Footer -->
  <footer class="main-footer">
    <strong><!--FooterLeft--></strong>
   
    <div class="float-right d-none d-sm-inline-block">
      <!--FooterRight-->
      <!--<b>Copyright &copy; 2014-2021 <a href="https://adminlte.io">AdminLTE.io</a> All rights reserved. Version</b> 3.1.0-rc-->
    </div>
  </footer>
</div>
<!-- ./wrapper -->

<!-- REQUIRED SCRIPTS -->
<!-- jQuery -->
<script src="=path=adminlte/plugins/jquery/jquery.min.js"></script>
<!-- Bootstrap -->
<script src="=path=adminlte/plugins/bootstrap/js/bootstrap.bundle.min.js"></script>
<!-- overlayScrollbars -->
<script src="=path=adminlte/plugins/overlayScrollbars/js/jquery.overlayScrollbars.min.js"></script>
<!-- AdminLTE App -->
<script src="=path=adminlte/dist/js/adminlte.js"></script>

<!-- PAGE PLUGINS -->
<!-- jQuery Mapael -->
<script src="=path=adminlte/plugins/jquery-mousewheel/jquery.mousewheel.js"></script>
<script src="=path=adminlte/plugins/raphael/raphael.min.js"></script>
<script src="=path=adminlte/plugins/jquery-mapael/jquery.mapael.min.js"></script>
<script src="=path=adminlte/plugins/jquery-mapael/maps/usa_states.min.js"></script>
<!-- jQuery UI -->
<script src="=path=jqueryui/jquery-ui.js"></script>
<script src="=path=jqueryui/jquery.blockui.js"></script>
<!-- ChartJS -->
<script src="=path=adminlte/plugins/chart.js/Chart.min.js"></script>

<!-- AdminLTE for demo purposes -->
<!--<script src="dist/js/demo.js"></script>-->
<!-- AdminLTE dashboard demo (This is only for demo purposes) -->
<!--<script src="dist/js/pages/dashboard2.js"></script>-->
 <div id='MainHidden' style='display:none;'></div>
 <div id="dialog" title="Dialog Title">
	<div id=dialogContent></div>
 </div>
<!--=JS-Autoload=-->
<script language='javascript'>
$('#MainSearch').keydown(function (e) {
  	if (e.keyCode == 13) {
    // e.ctrlKey ...  Ctrl-Enter pressed
   	$('#MainSearchRun').click();
   }
});
</script>

</body>
</html>
}

}

