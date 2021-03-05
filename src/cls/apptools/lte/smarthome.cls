Include apptools.core

/// http://hp-msw:52773/apptoolsrest/a/smarthome
Class apptools.lte.smarthome Extends apptools.lte.adminTabs [ ClassType = "", DependsOn = apptools.core.msg, ProcedureBlock ]
{

/// Application title
Parameter HeaderText = "Home, smart home";

/// Global Name Store Referens files
Parameter GNStore = "^appmsw.smarthome.ui";

Parameter AppRoles = "%All";

/// Replace parameters
ClassMethod MainParameter(ByRef h, path, url = "") As %Status
{
 set par("=Brand-Text=")="Smart Home"
 set par("=Logo-png=")="smarthome.png"
 set par("=titleAppToolsadmin=")=..#HeaderText
 set par("<!--=LinkIcon=-->")=..GetAppIcon(path_"dist/img/smarthome","png")
 quit ..RepaceParameter(.h, path, url,.par)
 quit $$$OK
}

/// what modes are available
ClassMethod GetAllApps(opt) As %Status
{
	if ..IsPermiss("%All") {	
	;make them zavisimye from the area
	;------------ sidebar
	s key="menu-first"
	set Level1=$lb(1,"Home",1) ;$lg(,3)=1 - open menu level 1
	s opt(key)="Sensor values" ;The name of the menu
	s opt(key,"id")="Find" ;use methods: FindFirstHead FindResult
	s opt(key,"TabName")="Sensors" ;the name of the tab
	s opt(key,"ClassName")=..%ClassName(1)
	s opt(key,"Method")="ShowTabSample"
	s opt(key,"Disable")=0 ;developed
	s opt(key,"TabMenu","Close")=1
	s opt(key,"Menu")=Level1
	s opt(key,"Active")=1 ;active menu item

	s key="menu-first2"
	s opt(key)="Snapshots" ;Pictures from cameras
	s opt(key,"id")="Lighbox" ;use methods: LighboxFirstHead LighboxResult
	s opt(key,"TabName")="Snapshots" ;the name of the tab
	s opt(key,"ClassName")=..%ClassName(1)
	s opt(key,"Method")="ShowTabSample"
	s opt(key,"Disable")=0 ;developed
	s opt(key,"TabMenu","Close")=1
	s opt(key,"Menu")=Level1

	;----------
	s key="menu-second"
	set Level2=$lb(2,"Tablo",0)
	s opt(key)="Tenis"
	s opt(key,"id")="Tenis"
	s opt(key,"TabName")="Ping pong scores"
	s opt(key,"ClassName")=..%ClassName(1)
	s opt(key,"MethodUrl")="http://ShowTabAbout.cls"
	s opt(key,"Disable")=1 ;developed
	s opt(key,"TabMenu","Close")=1
	s opt(key,"Menu")=Level2

	s key="menu-second2"
	s opt(key)="About"
	s opt(key,"id")="About"
	s opt(key,"TabName")="About"
	s opt(key,"ClassName")=..%ClassName(1)
	s opt(key,"Method")="ShowTabAbout"
	s opt(key,"Disable")=1 ;developed
	s opt(key,"TabMenu","Close")=1
	s opt(key,"Menu")=Level2

	
	;------------ one-level upper menu 
		s key="menu-topOpt"
	s opt(key)="Option"
	s opt(key,"id")="Option"
	s opt(key,"TabName")="Option"
	s opt(key,"ClassName")=..%ClassName(1)
	s opt(key,"Method")="ShowTabAbout"
	s opt(key,"TabMenu","Close")=1
	s opt(key,"MenuTop")=$lb(2,"Option") ;has no sub-items

	;------------ top menu the top-accoun
	s key="menu-top-accoun"
	set Level99=$lb(99,"Account") ;only 99-account has sub-items
	s opt(key)="Profile"
	s opt(key,"id")="AccountProf"
	s opt(key,"TabName")="Profile"
	s opt(key,"ClassName")=..%ClassName(1)
	s opt(key,"Method")="ShowTabAbout"
	s opt(key,"TabMenu","Close")=1
	s opt(key,"MenuTop")=Level99

	s key="menu-top-account3"
	s opt(key)="Exit"
	s opt(key,"id")="AccountExit"
	s opt(key,"TabName")="Exit"
	s opt(key,"ClassName")=..%ClassName(1)
	s opt(key,"Method")="Logout"
	s opt(key,"TabMenu","Close")=1
	s opt(key,"MenuTop")=Level99
	
	;----- Setup the search in the top menu
	s key="Search"
	s opt(key)="Search"
	s opt(key,"id")="Search-"
	s opt(key,"TabName")="Search"_"-"
	s opt(key,"ClassName")=..%ClassName(1)
	s opt(key,"Method")="ShowTabSearch"
	s opt(key,"TabMenu","Close")=1
	s opt(key,"TabMenu","Mode")=0 ;1 - for each new search bar to make new tab, 0-tab is always the same
	
	}
	q $$$OK
}

/// download form template search users and roles
ClassMethod MatrixFirstHead(Par = "") As %Status
{
	do ##class(apptools.core.Form).BlockUI(0)
	s key=Par("key")
	s divId=Par("divId")
	s %ui=1
	;set onclick=$$$blockui($$$aText("Loading...",""))_";AppAct('"_divId_"MainForm','"_divId_"MainContent','AppAct="_$zu(5)_":"_..%ClassName(1)_":"_divId_"Result:&key="_key_"&divId="_divId_"&mode=*');"
	set onclick=$$$blockui("Load...")_";"_##class(apptools.core.Action).WriteActJs(%request,divId_"MainForm",divId_"MainContent",..%ClassName(1),divId_"Result","&key="_key_"&divId="_divId_"&mode=*")
	;ActionJs('"_divId_"MainForm','"_divId_"MainContent','','"_divId_"Result','key="_key_"~divId="_divId_"~mode=*');"

	&html<
		<table>
		<tr>
			<td>
 	Login <br>#($$$appText(divId_"name","title='"_$$$aText("Names separated by a comma or by context","")_"'","s"))#
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
	q $$$OK
}

/// Search result 
ClassMethod MatrixResult(Par = "") As %Status
{
	s %ui=1
	do ##class(apptools.core.Form).BlockUI(0)
	set key=Par("key")
	set divId=Par("divId")
	set mode=Par("mode")

	;Geting elements from form and prepare array Par
	s name=##class(apptools.core.Action).GetElemForm(%request,.Par,divId_"name")	
	set roles=$g(Par("%request.Data",divId_"roles"))


	write ..ButtonAgain(divId,key)
	d ##class(apptools.Tabs.security).UiMatrixPermission(name,roles,divId,key,"apptools.Tabs.security","UiSavePermiss")
	q $$$OK
}

}

