Include apptools.core

/// http://hp-msw:52773/apptoolsrest/a/adminsample
Class apptools.lte.adminsample Extends apptools.lte.adminTabs [ ClassType = "", DependsOn = apptools.core.msg, ProcedureBlock ]
{

/// Application title
Parameter HeaderText = "Admin Sample";

/// Global Name Store Referens files
Parameter GNStore = "^apptools.Permissions";

Parameter AppRoles = "ui_Permissions";

/// do ##class(apptools.lte.adminsample).Init()
ClassMethod Init() As %Status
{
	set ServerPort=##class(apptools.core.net).GetURI(.prop)
	write !,"Open in browser "
    do ##class(apptools.core.Installer).AddAndWriteFavorite(##class(apptools.core.Installer).#AppName_" SampleAdminPanel","/"_##class(apptools.core.Installer).#AppCSP_"rest/a/adminsample",ServerPort)
    do ##class(apptools.core.Installer).AddAndWriteFavorite(##class(apptools.core.Installer).#AppName_" SampleMatrixPermiss","/"_##class(apptools.core.Installer).#AppCSP_"rest/a/permiss",ServerPort)
}

/// Replace parameters
ClassMethod MainParameter(ByRef h, ByRef par) As %Status
{
 set path=par("=path=")
 set par("=Brand-Text=")="Admin Sample Panel"
 set par("=path=")=path
 set par("=Brand-Text=")="AppTools-admin"
 set par("=Logo-image=")=path_"adminlte/dist/img/ApptoolsLogo.png"
 set par("=titleAppToolsadmin=")=..#HeaderText
 set par("<!--=LinkIcon=-->")=..GetAppIcon(path_"adminlte/dist/img/ApptoolsLogo","png")
 
 quit ..RepaceParameter(.h, .par)
}

/// what are the available modes
ClassMethod GetAllApps(opt) As %Status
{
	;make them zavisimye from the area
	;------------ sidebar
	set key="menu-first"
	set opt(key)="Find users" ;The name of the menu
	set opt(key,"id")="Find" ;use methods: FindFirstHead FindResult
	set opt(key,"TabName")="finding users" ;the name of the tab
	set opt(key,"ClassName")=..%ClassName(1)
	set opt(key,"Method")="ShowTabSample"
	set opt(key,"Disable")=0 ;developed
	set opt(key,"TabMenu","Close")=0 ;the tab cannot be deleted
	set opt(key,"Menu")=$lb(1,"Mode",1,"fa-cog") ;$lg(,3)=1 - open menu level 1
	set opt(key,"Active")=1 ;active menu item
	set opt(key,"aw-icon")="fa-list-alt" ;fa-table"

	set key="menu-first2"
	set opt(key)="Sample gallery" ;The name of the menu
	set opt(key,"id")="Lighbox" ;use methods: LighboxFirstHead LighboxResult
	set opt(key,"TabName")="Gallery" ;the name of the tab
	set opt(key,"ClassName")=..%ClassName(1)
	set opt(key,"Method")="ShowTabSample"
	set opt(key,"Disable")=0 ;developed
	set opt(key,"Menu")=$lb(1,"Mode",1) ;$lg(,3)=1 - open menu level 1
	
	set key="menu-second"
	set opt(key)="Help"
	set opt(key,"id")="Help"
	set opt(key,"TabName")="Help"
	set opt(key,"ClassName")=..%ClassName(1)
	set opt(key,"MethodUrl")="http://ShowTabAbout.cls"
	set opt(key,"Disable")=1 ;developed
	set opt(key,"Menu")=$lb(2,"About the program",0)

	set key="menu-second2"
	set opt(key)="Menu 3"
	set opt(key,"id")="About"
	set opt(key,"TabName")="Menu 3"
	set opt(key,"ClassName")=..%ClassName(1)
	set opt(key,"Method")="ShowTabAbout"
	set opt(key,"Disable")=1 ;developed
	set opt(key,"Menu")=$lb(2,"About the program")

	set key="menu-second3"
	set opt(key)="Support"
	set opt(key,"id")="Support"
	set opt(key,"TabName")="Support"
	set opt(key,"ClassName")=..%ClassName(1)
	set opt(key,"MethodUrlNewWin")="http://ShowTabAbout.cls"
	set opt(key,"Disable")=1 ;developed
	set opt(key,"Menu")=$lb(2,"About the program")
	
	;------------ one-level upper menu 
	set key="menu-topLern"
	set opt(key)="Menu 2"
	set opt(key,"id")="Menu2"
	set opt(key,"TabName")="Menu 2"
	set opt(key,"ClassName")=..%ClassName(1)
	set opt(key,"Method")="ShowTabAbout"
	set opt(key,"MenuTop")=$lb(1,"Menu 2") ;has no sub-items

	set key="menu-topOpt"
	set opt(key)="Option"
	set opt(key,"id")="Option"
	set opt(key,"TabName")="Option"
	set opt(key,"ClassName")=..%ClassName(1)
	set opt(key,"Method")="ShowTabAbout"
	set opt(key,"MenuTop")=$lb(2,"Option") ;has no sub-items

	;------------ top menu the top-accoun
	set key="menu-top-accoun"
	set opt(key)=$$$aText("Profile","")
	set opt(key,"id")="AccountProf"
	set opt(key,"TabName")=$$$aText("Profile","")
	set opt(key,"ClassName")=..%ClassName(1)
	set opt(key,"Method")="ShowTabAbout"
	set opt(key,"MenuTop")=$lb(99,"Account") ;only 99-account has sub-items

	set key="menu-top-account3"
	set opt(key)=$$$aText("Exit","")
	set opt(key,"id")="AccountExit"
	set opt(key,"TabName")=$$$aText("Exit","")
	set opt(key,"ClassName")=..%ClassName(1)
	set opt(key,"Method")="Logout"
	set opt(key,"MenuTop")=$lb(99,"Account") ;only 99-account has sub-items
	
	;----- Setup the search in the top menu
	set key="Search"
	set opt(key)=$$$aText("Search","")
	set opt(key,"id")="Search-"
	set opt(key,"TabName")=$$$aText("Search","")_"-"
	set opt(key,"ClassName")=..%ClassName(1)
	set opt(key,"Method")="ShowTabSearch"
	set opt(key,"TabMenu","Close")=1
	set opt(key,"TabMenu","Mode")=0 ;1 - for each new search bar to make new tab, 0-tab is always the same
	
	quit $$$OK
}

/// download template forms search
ClassMethod FindFirstHead(Par = "") As %Status
{
	do ##class(apptools.core.Form).BlockUI(0)
	set key=Par("key")
	set divId=Par("divId")
	set onclick=$$$blockui("Load...")_";"_##class(apptools.core.Action).WriteActJs(%request,divId_"MainForm",divId_"MainContent",..%ClassName(1),divId_"Result","~key="_key_"~divId="_divId_"~mode=*")
	;ActionJs('"_divId_"MainForm','"_divId_"MainContent','','"_divId_"Result','key="_key_"~divId="_divId_"~mode=*');"
		&html<
		<table width="90%" style="border-radius: 10px; border: 1px solid #72a7cf" cellpadding="2" cellspacing="0" class="DetailTable" bgcolor="#c4d6d6" >
		<tr>
			<td>
		Context name users
			</td>
			<td>
				#($$$appText(divId_"textName","title='context in Name'","s"))#
			</td>		
			<td>
				#($$$appText(divId_"textDesc","title='context in FullName'","m"))#
			</td>
			<td>
			</td>
			<td>
		
			</td>
			<td>

			</td>
		</tr>
		<tr>
			<td>
			
			</td>
			<td>
			#($$$appButton(divId_"appButtonResult1","onclick="""_$tr(onclick,"*",1)_"""","Find USERS"))#
			</td>
			<td>
			</td>
			<td>
			</td>
			<td>
			
			</td>
			<td>

			</td>
		</tr>
		</table>
	>
 $$$jsstart
 	//for all identifiers starting with "_divId_"text by pressing Enter, click on the button (ending with $("[id$='txtTitle']"))
 	write "$('[id^="""_divId_"text""]').keydown(function (e) { if (e.keyCode == 13) { $('#"_divId_"appButtonResult1').click(); }});"_$c(13,10)
 $$$jsstop
	
	quit $$$OK
}

/// Search result
ClassMethod FindResult(Par = "") As %Status
{
	do ##class(apptools.core.Form).BlockUI(0)
	set key=Par("key")
	set divId=Par("divId")
	set mode=Par("mode")
	;Geting elements from form and prepare array Par
	set Name=##class(apptools.core.Action).GetElemForm(%request,.Par,divId_"textName")	
	set Desc=$g(Par("%request.Data",divId_"textDesc"))
	set st=$$$OK
	if mode=1 {
		write ..ButtonAgain(divId,key)
		if Name="" w $$$appError($$$aText("Context is empty","")) quit $$$OK
		zn "%sys"
		set sql="select ID,name,EmailAddress,fullName from Security.Users where Enabled [ '1' "
		if Name'="" s sql=sql_" and (name like '%"_Name_"%') "
		if Desc'="" s sql=sql_" and (fullName like '%"_Desc_"%') "
		set msg="Query: "_sql

		set exec="##class(apptools.core.LogInfo).MarkRed(%AppLogInfoVal,"""_$GET(Name)_","_$GET(Desc)_""")"
		set st=##class(apptools.core.LogInfoPane).DrawSQL(sql,100000,$zu(5),msg,exec)
		if 'st  w $$$appError($System.Status.GetErrorText(st))
		quit $$$OK

	} 
	write "<br>"
	quit $$$OK
}

/// download template forms search
ClassMethod LighboxFirstHead(Par = "") As %Status
{
	do ##class(apptools.core.Form).BlockUI(0)
	set key=Par("key")
	set divId=Par("divId")
	set onclick=$$$blockui("Load...")_";"_##class(apptools.core.Action).WriteActJs(%request,divId_"MainForm",divId_"MainContent",..%ClassName(1),divId_"Result","~key="_key_"~divId="_divId_"~mode=*")
	Set path=$p($p($zu(86),"*",1),$$$slash,1,*-1)
	Set path1=path_$tr("\csp\broker\images\","\",$$$slash)
	Set path2=path_$tr("\docs\","\",$$$slash)
		&html<
		<table width="90%" style="border-radius: 10px; border: 1px solid #72a7cf" cellpadding="2" cellspacing="0" class="DetailTable" bgcolor="#c4d6d6" >
		<tr>
			<td>
				#($$$appText(divId_"path1","size=50 title='path to images'",path1))#
			</td>
			<td>
				#($$$appText(divId_"path2","size=50 title='path to images docs'",path2))#
			</td>
		</tr>
		<tr>
			<td>
			#($$$appButton(divId_"appButtonResult1"," onclick="""_$tr(onclick,"*",1)_"""","Generate gallery via App /csp/broker"))#			
			</td>
			<td>
			#($$$appButton(divId_"appButtonResult2"," onclick="""_$tr(onclick,"*",2)_"""","Generate gallery dinamic rest"))#			
			</td>
		</tr>
		</table>
	>
 $$$jsstart
 	;for all identifiers starting with "_divId_"text by pressing Enter, click on the button (ending with $("[id$='txtTitle']"))
 	write "$('[id^="""_divId_"path""]').keydown(function (e) { if (e.keyCode == 13) { $('#"_divId_"appButtonResult2').click(); }});"_$c(13,10)
 $$$jsstop
	
	quit $$$OK
}

/// Its result
ClassMethod LighboxResult(Par = "") As %Status
{
	do ##class(apptools.core.Form).BlockUI(0)
	set key=Par("key")
	set divId=Par("divId")
	set mode=Par("mode")
	;Geting elements from form and prepare array Par
	set path1=##class(apptools.core.Action).GetElemForm(%request,.Par,divId_"path1")	
	set path2=$g(Par("%request.Data",divId_"path2"))
	set st=$$$OK
	set wc=##class(apptools.core.filesMimeTypes).GetTypesWildcards("image")_##class(apptools.core.filesMimeTypes).GetTypesWildcards("video")
	if mode=1 {
	 do ##class(apptools.core.files).GetList(path1,wc,.List)
	 set cspappstatic="/csp/broker/images/"
	 ;zw List
	 $$$jsstart
 		write "UIkit.lightboxPanel({"
   		write "items: [ "
		  do ..LighboxDrawJson(.List,cspappstatic)
  		write " ] }).show();"
	 $$$jsstop
	} 
	elseIF mode=2 {
	;	w path2
	 do ##class(apptools.core.files).GetList(path2,wc,.List)
	 ;zw List
	 set appdinamic=%request.Application_"get-files/"
	 $$$jsstart
 		write "UIkit.lightboxPanel({"
   		write "items: [ "
		  do ..LighboxDrawJson(.List,,appdinamic,..#GNStore)
  		write " ] }).show();"
	 $$$jsstop
	}
	write "<br>"
	quit $$$OK
}

}

