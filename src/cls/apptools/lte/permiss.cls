Include apptools.core

/// http://hp-msw:52773/apptoolsrest/a/permiss
Class apptools.lte.permiss Extends apptools.lte.adminTabs [ ClassType = "", DependsOn = apptools.core.msg, ProcedureBlock ]
{

/// Application title
Parameter HeaderText = "Permissions";

/// Global Name Store Referens files
Parameter GNStore = "^apptools.Permissions";

Parameter AppRoles = "ui_Permissions";

/// Replace parameters
ClassMethod MainParameter(ByRef h, ByRef par) As %Status
{
 set path=par("=path=")
 set par("=Brand-Text=")="Admin v.1"
 set par("=Logo-image=")=path_"adminlte/dist/img/ApptoolsLogo.png"
 set par("=titleAppToolsadmin=")=..#HeaderText
 set par("<!--=LinkIcon=-->")=..GetAppIcon(path_"adminlte/dist/img/ApptoolsLogo","png")
 quit ..RepaceParameter(.h,.par)
}

/// what modes are available
ClassMethod GetAllApps(opt) As %Status
{
	;side menu
	set sideMenuName="Permission",
		sideMenuNumer=1,
		sideMenuOpen=1,        //3 =1 open menu
		sideMenuIcon="fa-cog"  //4  icon   https://fontawesome.com/icons?d=gallery&p=2&m=free
		set sideMenu=$lb(sideMenuNumer,sideMenuName,sideMenuOpen,sideMenuIcon) 
			set key="MenuMatrix"
			set opt(key,"Menu")=sideMenu
			set opt(key)=$$$aText("The matrix","") ;The name of the menu
			set opt(key,"id")="Matrix"
			set opt(key,"TabName")=$$$aText("The matrix","") ;the name of the tab
			set opt(key,"ClassName")=..%ClassName(1)
			set opt(key,"Role")="%All"
			set opt(key,"Namespace")="%SYS"
			set opt(key,"Method")="ShowTabSample"
			set opt(key,"TabMenu","Close")=0 ;the tab cannot be deleted
			set opt(key,"Active")=1 ;active menu item
			set opt(key,"aw-icon")="fa-list-alt" ;fa-table"   https://fontawesome.com/icons?d=gallery&p=2&m=free

	;top menu
	set topMenuName="Account",
		topMenuNumer=99
	set key="menu-top-account3"
		set opt(key,"MenuTop")=$lb(topMenuNumer,topMenuName) ; 99-account has nested items
		set opt(key)="Exit"
		set opt(key,"id")="AccountExit"
		set opt(key,"TabName")="Logoit" 
		set opt(key,"ClassName")=..%ClassName(1)
		set opt(key,"Method")="Logout"
	
	do ..CheckRoleMenu(.opt)
	quit $$$OK
}

/// download form template search users and roles
ClassMethod MatrixFirstHead(Par = "") As %Status
{
	do ##class(apptools.core.Form).BlockUI(0)
	set key=Par("key")
	set divId=Par("divId")
	set %ui=1
	//##class(apptools.core.Action).WriteActJs(%request,divId_"MainForm",divId_"MainContent",..%ClassName(1),divId_"Result","&key="_key_"&divId="_divId_"&mode=*")
	set onclick=$$$blockui("Load...")_
		$$$onclick(divId_"MainForm",divId_"MainContent",$namespace,..%ClassName(1),divId_"Result","&key="_key_"&divId="_divId_"&mode=*")
	&html<
		<table>
		<tr>
			<td>
 			Login <br>#($$$appText(divId_"name","title='"_$$$aText("Names separated by a comma or by context","")_"'","ms"))#
			</td>
			<td>
			Roles <br>#($$$appText(divId_"roles","title='"_$$$aText("Roles separated by a comma or by context","")_"'","d"))#
			</td>
			<td> <br>
			#($$$appButton(divId_"appButtonResult1","onclick="""_$tr(onclick,"*",1)_"""",""_$$$aText("User roles","")))#
			</td>
		</tr>
		</table>
	>
	$$$SetHeightContent(divId,250)
	q $$$OK
}

/// Search result 
ClassMethod MatrixResult(Par = "") As %Status
{
	set %ui=1
	do ##class(apptools.core.Form).BlockUI(0)
	set key=Par("key")
	set divId=Par("divId")
	set mode=Par("mode")
	;Geting elements from form and prepare array Par
	set name=##class(apptools.core.Action).GetElemForm(%request,.Par,divId_"name")	
	set roles=$g(Par("%request.Data",divId_"roles"))
	write ..ButtonAgain(divId,key)
	do ##class(apptools.Tabs.security).UiMatrixPermission(name,roles,divId,key,"apptools.Tabs.security","UiSavePermiss")
	quit $$$OK
}

}

