Include apptools.core

Class apptools.lte.adminsample Extends apptools.lte.adminTabs [ ClassType = "", DependsOn = apptools.core.msg, ProcedureBlock ]
{

/// Application title
Parameter HeaderText = "Admin Sample";

/// Global Name Store Referens files
Parameter GNStore = "^apptools.Permissions";

Parameter AppRoles = "ui_Permissions";

/// Replace parameters
ClassMethod MainParameter(ByRef h, path, url = "") As %Status
{
 set par("=Brand-Text=")="Admin Sample Panel"
 set par("=Logo-png=")="ApptoolsLogo.png"
 set par("=titleAppToolsadmin=")=..#HeaderText
 set par("<!--=LinkIcon=-->")=..GetAppIcon(path_"dist/img/ApptoolsLogo","png")
 quit ..RepaceParameter(.h, path, url,.par)
}

/// what are the available modes
ClassMethod GetAllApps(opt) As %Status
{
	;make them zavisimye from the area
	;------------ sidebar
	s key="menu-first"
	s opt(key)="Find users" ;The name of the menu
	s opt(key,"id")="Find" ;use methods: FindFirstHead FindResult
	s opt(key,"TabName")="finding users" ;the name of the tab
	s opt(key,"ClassName")=..%ClassName(1)
	s opt(key,"Method")="ShowTabSample"
	s opt(key,"Disable")=0 ;developed
	s opt(key,"TabMenu","Close")=1
	s opt(key,"Menu")=$lb(1,"Mode",1) ;$lg(,3)=1 - open menu level 1
	s opt(key,"Active")=1 ;active menu item

	s key="menu-first2"
	s opt(key)="Sample gallery" ;The name of the menu
	s opt(key,"id")="Lighbox" ;use methods: LighboxFirstHead LighboxResult
	s opt(key,"TabName")="Gallery" ;the name of the tab
	s opt(key,"ClassName")=..%ClassName(1)
	s opt(key,"Method")="ShowTabSample"
	s opt(key,"Disable")=0 ;developed
	s opt(key,"TabMenu","Close")=1
	s opt(key,"Menu")=$lb(1,"Mode",1) ;$lg(,3)=1 - open menu level 1
	
	s key="menu-second"
	s opt(key)="Help"
	s opt(key,"id")="Help"
	s opt(key,"TabName")="Help"
	s opt(key,"ClassName")=..%ClassName(1)
	s opt(key,"MethodUrl")="http://ShowTabAbout.cls"
	s opt(key,"Disable")=1 ;developed
	s opt(key,"Menu")=$lb(2,"About the program",0)

	s key="menu-second2"
	s opt(key)="Menu 3"
	s opt(key,"id")="About"
	s opt(key,"TabName")="Menu 3"
	s opt(key,"ClassName")=..%ClassName(1)
	s opt(key,"Method")="ShowTabAbout"
	s opt(key,"Disable")=1 ;developed
	s opt(key,"Menu")=$lb(2,"About the program")

	s key="menu-second3"
	s opt(key)="Support"
	s opt(key,"id")="Support"
	s opt(key,"TabName")="Support"
	s opt(key,"ClassName")=..%ClassName(1)
	s opt(key,"MethodUrlNewWin")="http://ShowTabAbout.cls"
	s opt(key,"Disable")=1 ;developed
	s opt(key,"Menu")=$lb(2,"About the program")
	
	;------------ one-level upper menu 
	s key="menu-topLern"
	s opt(key)="Menu 2"
	s opt(key,"id")="Menu2"
	s opt(key,"TabName")="Menu 2"
	s opt(key,"ClassName")=..%ClassName(1)
	s opt(key,"Method")="ShowTabAbout"
	s opt(key,"MenuTop")=$lb(1,"Menu 2") ;has no sub-items

	s key="menu-topOpt"
	s opt(key)="Option"
	s opt(key,"id")="Option"
	s opt(key,"TabName")="Option"
	s opt(key,"ClassName")=..%ClassName(1)
	s opt(key,"Method")="ShowTabAbout"
	s opt(key,"MenuTop")=$lb(2,"Option") ;has no sub-items

	;------------ top menu the top-accoun
	s key="menu-top-accoun"
	s opt(key)=$$$aText("Profile","")
	s opt(key,"id")="AccountProf"
	s opt(key,"TabName")=$$$aText("Profile","")
	s opt(key,"ClassName")=..%ClassName(1)
	s opt(key,"Method")="ShowTabAbout"
	s opt(key,"MenuTop")=$lb(99,"Account") ;only 99-account has sub-items

	s key="menu-top-account3"
	s opt(key)=$$$aText("Exit","")
	s opt(key,"id")="AccountExit"
	s opt(key,"TabName")=$$$aText("Exit","")
	s opt(key,"ClassName")=..%ClassName(1)
	s opt(key,"Method")="Logout"
	s opt(key,"MenuTop")=$lb(99,"Account") ;only 99-account has sub-items
	
	;----- Setup the search in the top menu
	s key="Search"
	s opt(key)=$$$aText("Search","")
	s opt(key,"id")="Search-"
	s opt(key,"TabName")=$$$aText("Search","")_"-"
	s opt(key,"ClassName")=..%ClassName(1)
	s opt(key,"Method")="ShowTabSearch"
	s opt(key,"TabMenu","Close")=1
	s opt(key,"TabMenu","Mode")=0 ;1 - for each new search bar to make new tab, 0-tab is always the same
	
	q $$$OK
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

		set exec="##class(apptools.core.LogInfo).MarkRed(%AppLogInfoVal,"""_Name_","_Desc_""")"
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

