Include apptools.core

/// https://adminlte.io
Class apptools.lte.adminStatic [ Abstract ]
{

/// http://localhost:52773/apptoolsrest/a/permiss-autoload=snapshot
/// http://localhost:52773/apptoolsrest/a/infochest
/// http://localhost:52773/apptoolsrest/a/smarthome-autoload-snapshot
ClassMethod GetMain(parameter) As %Status
{
	if 0,parameter="apptools.core.Action.cls" {
		;set $$$AppL("MSW","req")=$$$AppObJs(%request)
	 	;merge $$$AppL("MSW","%request.Data")=%request.Data
		;set $$$AppL("MSW","%request.AppData")=%request.AppData
		w  quit $$$OK ;$classmethod("apptools.core.Action","OnPage",.parameter)
	}
	set h=##class(apptools.core.rest).getStatic("apptools.lte.adminStatic:html")
	set app=$p(parameter,"-")
	set class="apptools.lte."_app
	if '##class(apptools.core.sys).ClassExist(class) quit $$$ERROR($$$GeneralError,"class does not exist "_class)
	;s appdinamic=%request.Application_"get-files/"
	
	set path="/apptools/adminlte/"
	set h=$replace(h,"=path=",path)
	
	set st=$classmethod(class,"MainParameter",.h,path,$p(parameter,"-",2,*)) 

	d ##class(apptools.core.rest).WriteStatic("html",,,,,h)
	q $$$OK
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
  <link rel="stylesheet" href="=path=plugins/fontawesome-free/css/all.min.css">
  <!-- overlayScrollbars -->
  <link rel="stylesheet" href="=path=plugins/overlayScrollbars/css/OverlayScrollbars.min.css">
  <!-- Theme style -->
  <link rel="stylesheet" href="=path=dist/css/adminlte.min.css">
  <!--=LinkIcon=-->
  <!--=Links=-->
</head>
<body class="hold-transition dark-mode sidebar-mini layout-fixed layout-navbar-fixed layout-footer-fixed">
<div class="wrapper">

  <!-- Preloader -->
  <div class="preloader flex-column justify-content-center align-items-center">
    <img class="animation__wobble" src="=path=dist/img/ApptoolsLogo.png" alt="ApptoolLogo" height="60" width="60">
  </div>

  <!-- Navbar -->
  <nav class="main-header navbar navbar-expand navbar-dark">
    <!-- Left navbar links -->
	
    <ul class="navbar-nav">
      <li class="nav-item">
        <a class="nav-link" data-widget="pushmenu" href="#" role="button"><i class="fas fa-bars"></i></a>
      </li>
      <li class="nav-item d-none d-sm-inline-block">
        <a href="#" onclick="document.location.reload();" class="nav-link">Home</a>
      </li>
    </ul>

    <!-- Right navbar links -->
	<ul class="navbar-nav ml-auto">
      <!-- =Navbar Search= -->
      <!--<li class="nav-item">
        <div class="navbar-search-block">
          <form class="form-inline">
            <div class="input-group input-group-sm">
              <input class="form-control form-control-navbar" type="search" placeholder="Search" aria-label="Search">
              <div class="input-group-append">
                <button class="btn btn-navbar" type="submit">
                  <i class="fas fa-search"></i>
                </button>
                <button class="btn btn-navbar" type="button" data-widget="navbar-search">
                  <i class="fas fa-times"></i>
                </button>
              </div>
            </div>
          </form>
        </div>
      </li>-->

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
      <img src="=path=dist/img/=Logo-png=" alt="ApptoolsLogo" class="brand-image img-circle elevation-3" style="opacity: .8">
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
				<li id='t1' class="uk-active"><a href="#"><font color=Lightsteelblue>Welcom</font></a></li>
			</ul>
			<ul id="tabList" class="uk-switcher uk-margin uk-tab-content">
				<li id='ta1' >
			 	<div class="uk-alert-success" uk-alert>
					<p> Sample of simple application</p>
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
    <strong>Applications Tools for Admin.</strong>
   
    <div class="float-right d-none d-sm-inline-block">
      <!--<b>Copyright &copy; 2014-2021 <a href="https://adminlte.io">AdminLTE.io</a> All rights reserved. Version</b> 3.1.0-rc-->
    </div>
  </footer>
</div>
<!-- ./wrapper -->

<!-- REQUIRED SCRIPTS -->
<!-- jQuery -->
<script src="=path=plugins/jquery/jquery.min.js"></script>
<!-- Bootstrap -->
<script src="=path=plugins/bootstrap/js/bootstrap.bundle.min.js"></script>
<!-- overlayScrollbars -->
<script src="=path=plugins/overlayScrollbars/js/jquery.overlayScrollbars.min.js"></script>
<!-- AdminLTE App -->
<script src="=path=dist/js/adminlte.js"></script>

<!-- PAGE PLUGINS -->
<!-- jQuery Mapael -->
<script src="=path=plugins/jquery-mousewheel/jquery.mousewheel.js"></script>
<script src="=path=plugins/raphael/raphael.min.js"></script>
<script src="=path=plugins/jquery-mapael/jquery.mapael.min.js"></script>
<script src="=path=plugins/jquery-mapael/maps/usa_states.min.js"></script>
<script src="=path=plugins/jquery/jquery.blockui.js"></script>
<!-- ChartJS -->
<script src="=path=plugins/chart.js/Chart.min.js"></script>

<!-- AdminLTE for demo purposes -->
<!--<script src="dist/js/demo.js"></script>-->
<!-- AdminLTE dashboard demo (This is only for demo purposes) -->
<!--<script src="dist/js/pages/dashboard2.js"></script>-->
 <div id='MainHidden' style='display:none;'></div>
 <div id="dialog" title="Dialog Title">
	<div id=dialogContent></div>
 </div>
<!--=JS-Autoload=-->
</body>
</html>
}

}

