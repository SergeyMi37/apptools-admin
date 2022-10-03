Include apptools.core

/// http://localhost:52773/apptoolsrest/a/infochest
Class apptools.lte.infochest Extends apptools.lte.adminTabs [ ClassType = "", DependsOn = apptools.core.msg, ProcedureBlock ]
{

/// Application title
Parameter HeaderText = "Info Chest";

/// Global Name Store Referens files
Parameter GNStore = "^apptools.infochest";

Parameter AppRoles;

/// do ##class(apptools.lte.adminsample).Init()
ClassMethod Init() As %Status
{
	set ServerPort=##class(apptools.core.net).GetURI(.prop)
	write !,"Open in browser "
    do ##class(apptools.core.Installer).AddAndWriteFavorite(##class(apptools.core.Installer).#AppName_" SampleAdminPanel","/"_##class(apptools.core.Installer).#AppCSP_"rest/a/infochest",ServerPort)
}

/// Replace parameters
ClassMethod MainParameter(ByRef h, ByRef par) As %Status
{
 set base64=##class(apptools.core.rest).getStatic(..%ClassName(1)_":image")
 set par("=Brand-Text=")="Info Chest"
 set par("=titleAppToolsadmin=")=..#HeaderText
 set par("=Logo-image=")=base64
 set par("<!--=LinkIcon=-->")=..GetAppIcon(,"png",base64)
 quit ..RepaceParameter(.h, .par)
 quit $$$OK
}

/// write ##class(apptools.lte.infochest).GetAppRootdir()
ClassMethod GetAppRootdir() As %String
{
	set rootdir="d:\files\"
	if $zversion(1)=3 s rootdir="/home/project/shared/photo/"
	if $data(@..#GNStore@("rootdir"),data) {
		set rootdir=data
	}
	else {
		set rootdir= ##class(%File).GetDirectory($zu(86))_"/mgr/.modules/"_$namespace_"/apptools-admin/1.1.5/web/files/"
	}
	quit ##class(%File).GetDirectory(rootdir)
}

/// do ##class(apptools.lte.infochest).SetAppRootdir("d:\!\")
ClassMethod SetAppRootdir(path) As %String
{
	set @..#GNStore@("rootdir")=path
	quit $$$OK
}

ClassMethod GetAllApps(opt) As %Status
{
	if ..IsPermiss(..#AppRoles) {
	;------------ side menu
	s LeftMenuName="Treasure Сhest" i $i(LeftMenuNumer)
	s rootdir=..GetAppRootdir()

	s key="camera"
	s List(key,"ItemName")="Photo & Video"
	s key="audio"
	s List(key,"ItemName")="Music"
	s key="books"
	s List(key,"ItemName")="Books"
 	
 	s i="" for { s i=$o(List(i)) q:i=""  
 	s ItemName=$g(List(i,"ItemName"))
 	i $i(count)
 	s key="find-"_i
	s opt(key)=ItemName 
	s opt(key,"id")="GDiv"_i
	s opt(key,"TabName")=ItemName_"-"
	s opt(key,"ClassName")=..%ClassName(1)
	s opt(key,"Method")="ShowTabS"
	s opt(key,"TabMenu","Close")=1
	s opt(key,"Menu")=$lb(LeftMenuNumer,LeftMenuName,1)
	s:count=1 opt(key,"Active")=1
	s opt(key,"Dir")=rootdir_i
 }
 if ..IsPermiss("%All") {	
 	i $i(LeftMenuNumer)
	s key="menu-topOpt"
	s opt(key)="Parameter"
	s opt(key,"id")="Option"
	s opt(key,"TabMenu","Close")=1
	s opt(key,"TabName")="Parameter"
	s opt(key,"ClassName")=..%ClassName(1)
	s opt(key,"Method")="ShowTabSample"
	s opt(key,"Menu")=$lb(LeftMenuNumer,"Option") ;has no sub-items
 }
	;------------ top-accoun
	s LeftMenuName="Account",LeftMenuNumer=99

	s key="menu-top-account3"
	s opt(key)="Exit"
	s opt(key,"id")="AccountExit"
	s opt(key,"TabName")="Exit" 
	s opt(key,"ClassName")=..%ClassName(1)
	s opt(key,"Method")="Logout"
	s opt(key,"MenuTop")=$lb(LeftMenuNumer,LeftMenuName)
	
	s key="Search"
	s opt(key)="Искать"
	s opt(key,"id")="Search-"
	s opt(key,"TabName")="Search-"
	s opt(key,"ClassName")=..%ClassName(1)
	s opt(key,"Method")="ShowTabSearch"
	s opt(key,"TabMenu","Close")=1
	s opt(key,"TabMenu","Mode")=0
	}
	q $$$OK
}

ClassMethod ShowTabSearch(key = "") As %Status
{
 ;do ..GetAllApps(.opt) 
 ;if $g(opt(key,"Disable")) write ..GetSupportInfo() quit $$$OK
 ;set NSpace=$zu(5)
 w $$$aText("Context","")_" :"_$g(key)
 q $$$OK
}

ClassMethod ShowTabS(Par = "") As %Status
{
 if $g(Par("appPar"))'="" set key=Par("appPar")
 do ..GetAllApps(.opt) 
 set divId=$g(opt(key,"id"))
 set mcont=divId_"MainContent"
 set mhead=divId_"MainHeader"
 if $g(Par("dir"))'="" set opt(key,"Dir")=..DeCode(Par("dir"))
 &html<
<form id="#(divId_"MainForm")#">
<div class="uk-grid">
    <div class="uk-width-1-1 "id="#(mhead)#" >
    >   
 ;Folders icon
 set srcFolder="data:image/gif;base64,R0lGODlhEAAOALMAAOazToeHh0tLS/7LZv/0jvb29t/f3//Ub//ge8WSLf/rhf/3kdbW1mxsbP//mf///yH5BAAAAAAALAAAAAAQAA4AAARe8L1Ekyky67QZ1hLnjM5UUde0ECwLJoExKcppV0aCcGCmTIHEIUEqjgaORCMxIC6e0CcguWw6aFjsVMkkIr7g77ZKPJjPZqIyd7sJAgVGoEGv2xsBxqNgYPj/gAwXEQA7"
 set dir=$g(opt(key,"Dir"),"!")

 do ..GetSortedList(key,dir,.List,.sort)

 if '$d(List) { write "No files and directories "_dir
	 quit $$$OK }
 ;If there are no directories, then we will immediately show the files
 if '$d(sort("n","D")) {
	 do ..FilesShow(.Par,dir,.sort)
	 quit $$$OK
 }
 
 set on=$$$blockui("Ждите...")_";"_##class(apptools.core.Action).WriteActJs(%request,"",mcont,..%ClassName(1),"NexLevelTree","&key="_key_"&divId="_divId_"&count=*&dir=***")

 set IdTab=$tr($p($zts,",",2),".")
 set fields(1)="<img class='uk-preserve-width uk-border-circle' src='"_$g(sort("icon"))_"' width='40' alt=''>" ;,fields(1,"attr")="class='uk-table-shrink'"
 set fields(2)="Name",fields(2,"attr")="class='uk-table-expand'"
 do ..DrawTableUi("beg","Table"_IdTab,"style='overflow: auto;'",.fields)
 
 ;If there are files then show them
 if $d(sort("n","F")) {
	s on2=$replace(on,"***",..EnCode(dir))
 	s on2=$replace(on2,"*",(IdTab))
 	if key["camera" { s on2=$replace(on2,"NexLevelTree","FilesShow") ;we will replace it with the show program
 	} else { s on2=$replace(on2,"NexLevelTree","NextLevelInDir")
 	}
 	s row(2)=$G(sort("n"))_" в '"_$p(dir,$$$slash,*)_"' - "_$G(sort("n","F"))
 	s row(2,"attr")="class='uk-table-expand' onclick="""_on2_""""
 	s row(1)="<img class='uk-preserve-width uk-border-circle' src='"_$g(sort("icon"))_"' width='40' alt=''>"
 	d ..DrawTableUi("tr",,,.row)
 }
 s i=""
  for { s i=$o(List(i)) q:i=""  
 	s ItemName=$g(List(i,"ItemName"))
 	continue:$g(List(i,"Type"))="F"
 	k sort2
	d ..GetSortedList(key,dir_$$$slash_ItemName,,.sort2)
	;w "<li>"_ItemName_" "_key zw sort2
	i '$d(sort2("n","F"))&&('$d(sort2("n","D"))) continue
	s on2=on
	i '$d(sort2("n","D")) {
 		s:key["camera" on2=$replace(on2,"NexLevelTree","FilesShow") ;we will replace it with the show program
	}
 	i $i(count)
  	s on2=$replace(on2,"***",..EnCode(dir_$$$slash_ItemName))
 	s on2=$replace(on2,"*",(IdTab+count))
 	s row(2)=ItemName_" - "_$tr($G(sort2("n","F")),"'")
 	s row(2,"attr")="class='uk-table-expand' onclick="""_on2_""""
 	s row(1)="<img class='uk-preserve-width uk-border-circle' src='"_srcFolder_"' width='40' alt=''>"
 	d ..DrawTableUi("tr",,,.row)
 }
 d ..DrawTableUi("end")
 &html<
  </div>
  <div id="#(mcont)#"></div>
 </div>
</form>
>
 quit $$$OK
}

/// Show files in the root of the directory
ClassMethod NextLevelInDir(Par = "") As %Status
{
	s Par("InDir")=1
	d ..NexLevelTree(.Par)
}

/// Create a tab with the next level
ClassMethod NexLevelTree(Par = "") As %Status
{
	do ##class(apptools.core.Form).BlockUI(0)
	set key=Par("key")
	set divId=Par("divId")
	set dir=..DeCode(Par("dir"))
	set count=$g(Par("count"))
 	do ..GetAllApps(.opt)
 	if '$d(opt(key)) {
	 	i key["audio" s key="find-audio"
	 	i key["camera" s key="find-camera"
	 	i key["books" s key="find-books"
	 	s count=count+10  ;костыль
 	}
 	s key2=key_count
 	m opt(key2)=opt(key)
 	s opt(key2,"id")=$s(divId'="":divId,1:opt(key,"id"))_count
 	if $g(Par("InDir")) {
	 	s addtab="--"
	 	s opt(key2,"Method")="FilesShow"
 	}
	s opt(key2,"TabName")=opt(key,"TabName")_$p($p(dir,$$$slash,*),".")_$g(addtab)
	
 	s opt(key2,"Dir")=dir
 	s opt(key2,"CGIvar")="&dir="_..EnCode(dir)
 	s Par=key2
 	;w dir
    d ..ShowTabApps(.Par,.opt)
    q $$$OK
}

/// Get a sorted list of files and directories
ClassMethod GetSortedList(key, dir, List, sort) As %Status
{
	set wildcard=$s($zversion(1)=3:"*",1:"*.*")
    d ##class(apptools.core.files).GetList(dir,wildcard,.List)
	if key["audio" {
		s wc=##class(apptools.core.filesMimeTypes).GetTypesWildcards("audio")
		s sort("n")="Listen"
		;Gramophone icon (G)
		s sort("icon")="data:image/ico;base64,AAABAAEAICAQAAAAAADoAgAAFgAAACgAAAAgAAAAQAAAAAEABAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACAAACAAAAAgIAAgAAAAIAAgACAgAAAwMDAAICAgAAAAP8AAP8AAAD//wD/AAAA/wD/AP//AAD///8AEREREREREREREAAAAAAAABk5OTk5OTk5MREAAAARERETk5OTk5OTk5EREQAAERERGTk5OTk5OTkxEREQABEREROTk5OTk5OTkRG7sAAAAAAZOTk5OTk5OTERERAAAAAAEREREREREREREREQAPAAAAF3d3d3dwd3d3EREADwCAAAEXd3dwAAd3d3cRAAALAAAAAQERAAAAEREREQAICwgAAAC/AAAAAAAA//AAcIuwAAD7sAAAAAAAAA/wB3C7sAAPu7AAAAAAAADw8HeAu7DAC/sAAAAAAAAA8Ad3CLu4gA+7AAAAAAAAAAB3ewi7uwAL+wAAAA8AAAAHd7cIu7sAALuwAAAAd4B3e3t7C7u7AAD7u3u7e3t3t7e3twu7vwAAALu7v7+/v39/f38Lu7uAAAAA+7u7u7u7u7u7C7u7gAAAAAAPv797u7u7uw+7uwAAAAAAAAALu7u7u7sLu7sAAAAAAAAAAAD7+/v7C7u7AAAAAAAAAAAIAA+/vwu7uwAAAAAAAAAAAAAA+/sIu7sAAAAAAAAAAAAAAA+/CLu4gAAAAAAAAAAAAAAA+3C7sAAAAAAAAAAAAAAAAA+wu7AAAAAAAAAAAAAAAAAA8IuwAAAAAAAAAAAAAAAAAAcLCAAAAAAAAAAAAAAAAAAACwAAAAAAAAAAAAAAAAAAAACAAAAB//AAAPwAAAAwAAAAFAAAAAfwAAAf8AAAHfAAABw8AAAcPwAAGB4AHjAcCB8gGBw+gAg//oAIP/8ACD8AAAwAAAAMAAAADAAAAA+AAAAP4AAAD/wAAA//wAAP//AAD///AA///4AP///AH///4B////Af///4H////D////4w=="
	}
	elseif key["camera" {
		s wc=##class(apptools.core.filesMimeTypes).GetTypesWildcards("image")_";"_##class(apptools.core.filesMimeTypes).GetTypesWildcards("video")
		s sort("n")="Watch"
		;Camera icon
		s sort("icon")="data:image/gif;base64,R0lGODlhEAAQAKIAAAAAAHt7AL29vXt7e/8AAP///wAAAAAAACH5BAkIAAEALAAAAAAQABAAAANJGBrT7iuOQmsRI6ppqSiZ1FFACYijB4RMqjbY01DwWn4CIGDroJcBk27nu/w2uyTPltsQdr/i7RQUCivNBSeV3biMEqW4W7VaEwA7"
	} else {
		s wc="*.fb2;*.zip;*.doc*"
		s sort("n")="To read"
		;Reader icon
		s sort("icon")="data:image/ico;base64,AAABAAIAICAQAAAAAADoAgAAJgAAABAQEAAAAAAAKAEAAA4DAAAoAAAAIAAAAEAAAAABAAQAAAAAAIACAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAgAAAgAAAAICAAIAAAACAAIAAgIAAAICAgADAwMAAAAD/AAD/AAAA//8A/wAAAP8A/wD//wAA////AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACIAAAAAAAAAAAAAAAAAACQd4gAAAAAAAAAAAAAAAAJkHd3iAAAAAAAAAAAAAAAmZgAd3eIAAAAAAAAAAAACZmAmQB3d4gAAAAAAAAAAJmYCZmZAHd3AAAAAAAAAAmZgJmZmZkAdwAAAAAAAACZmAmZmZmZmQAAAAAAAAAJmYCZmZmZmZmZAAAAAAAAmZgJmZmZmZmZmQAAAAAAAJmAmZmZmZmZmZAAAAAAAACYCZmZmZmZmZkAAAAAAAAAgJmZmZmZmZmQAAAAAAAAAACZmZmZmZmZAAAAAAAAAAAAAJmZmZmZkAAAAAAAAAAAAAAAmZmZmQAAAAAAAAAAAAAAAACZmZAAAAAAAAAAAAAAAAAAAJkAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA////////////////////////////////////////x////4H///8Af//+AB///AAH//gAAf/wAAP/4AAD/8AAA/+AAAH/AAAD/wAAB/8AAA//AAAf/4AAP//gAH//+AD///4B////g////+f///////////////////////////8oAAAAEAAAACAAAAABAAQAAAAAAMAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAgAAAgAAAAICAAIAAAACAAIAAgIAAAICAgADAwMAAAAD/AAD/AAAA//8A/wAAAP8A/wD//wAA////AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAkHAAAAAAAAmAeIAAAAAAmAAHeAAAAAmAmZAHAAAAmAmZmZAAAACAmZmZkAAAAAmZmZkAAAAAAJmZkAAAAAAAAJkAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA//8AAP//AAD//wAA/48AAP8DAAD+AAAA/AEAAPgBAADwAAAA8AEAAPADAAD4BwAA/g8AAP+fAAD//wAA//8AAA=="
	}
    s i="" 	s sort("d")=wc
	 for { s i=$o(List(i)) q:i=""  
 		s ItemName=$g(List(i,"ItemName"))
 		s DateModified=$tr($g(List(i,"DateModified")),"- :")
 		s type=$g(List(i,"Type"))
	 	if type="F" {
		 	s ext=$p(ItemName,".",*)
		 	continue:wc'[("*."_ext)
	 	}
	 	s sort("d",type,DateModified,$i(sort(type,DateModified)))=$lb(i,ItemName) ;sort by date
	 	s sort("n",type,ItemName)=$lb(i) ;sort by name
	 	i $i(sort("n",type))
	 }
	 q $$$OK
}

/// Show pictures
ClassMethod FilesShow(Par = "", dir = "", sort) As %Status
{
	do ##class(apptools.core.Form).BlockUI(0)
	s key=$g(Par)
	set divId=$g(Par("divId"))
	s:key="" key=$g(Par("appPar"))
	s:key="" key=$g(Par("key"))
	s:dir="" dir=..DeCode($g(Par("dir")))
	set dynamic=%request.Application_"get-files/" ;dynamic path
	if '$d(sort) {
		d ..GetSortedList(Par, dir, .List, .sort)
	}
	s IdTab=$tr($p($zts,",",2),".")
	
	if key["-audio" { ;Show playlist
	 ;Header
	 set fields(1)="<img class='uk-preserve-width uk-border-circle' src='"_$g(sort("icon"))_"' width='40' alt=''>"
 	 set fields(2)=$p(dir,$$$slash,*),fields(2,"attr")="class='uk-table-expand'"
 	 do ..DrawTableUi("beg","TableAudio"_IdTab,"style='overflow: auto;'",.fields)
	 set i="" for num=1:1 { s i=$o(sort("n","F",i)) q:i=""
	  	s row(2)=$p($p($lg(sort("n","F",i),1),$$$slash,*),".",1,*-1)
 		s row(2,"attr")="class='uk-table-expand' "
 		set fileId=##class(apptools.core.files).GetFileIdView($lg(sort("n","F",i),1)) 
 		s nextrack="Track"_IdTab_"-"_$S($o(sort("n","F",i))="":1,1:num+1)
 		s row(1)="<audio id='Track"_IdTab_"-"_num_"'  src="""_dynamic_fileId_""" onended=""document.getElementById('"_nextrack_"').play();"" controls preload=""metadata""></audio>"
 		d ..DrawTableUi("tr",,,.row)
 		}
 	d ..DrawTableUi("end")
	$$$jsstart
	w "$('audio').on(""play"", function (me) {"_$C(13,10)
    w " $('audio').each(function (i,e) {"_$C(13,10)
    w "  if (e !== me.currentTarget) {"_$C(13,10)
    w "   this.pause(); "_$C(13,10)
	w "      }"_$C(13,10)
    w " });"_$C(13,10)
    w "});"_$C(13,10)
	 $$$jsstop
	q $$$OK
	} 
	elseif key["-books" { ;Show books
	 ;Header
	 set fields(1)="<img class='uk-preserve-width uk-border-circle' src='"_$g(sort("icon"))_"' width='40' alt=''>"
 	 set fields(2)=$p(dir,$$$slash,*),fields(2,"attr")="class='uk-table-expand'"
 	 do ..DrawTableUi("beg","TableBooks"_IdTab,"style='overflow: auto;'",.fields)
	 set i="" for { s i=$o(sort("n","F",i)) q:i=""
	  	s row(2)=$p($p($lg(sort("n","F",i),1),$$$slash,*),".",1,*-1)
 		s row(2,"attr")="class='uk-table-expand' "
 		set fileId=##class(apptools.core.files).GetFileIdView($lg(sort("n","F",i),1),,"application/force-download") 
 		s row(1)="<a href="""_dynamic_fileId_""">Download</a>"
 		d ..DrawTableUi("tr",,,.row)
 		}
 	d ..DrawTableUi("end")
	}
	else {
		;Show pictures sorted by modification date
		k List
		s i="" for { s i=$o(sort("d","F",i)) q:i=""
			s ii="" for { s ii=$o(sort("d","F",i,ii)) q:ii=""
				s List($i(List),"ItemName")=$lg(sort("d","F",i,ii),2)
				s List(List,"Name")=$lg(sort("d","F",i,ii),1)
			}
		}
		;zw List
		 $$$jsstart
	 	 write "UIkit.lightboxPanel({"
	   		write "items: [ "
			  do ..LighboxDrawJson(.List,,dynamic)
	  		write " ] }).show();"
		$$$jsstop
	}
	quit $$$OK
}

/// download template forms search
ClassMethod OptionFirstHead(Par = "") As %Status
{
	do ##class(apptools.core.Form).BlockUI(0)
	set key=Par("key")
	set divId=Par("divId")
	s path= ##class(apptools.lte.infochest).GetAppRootdir()
	set onclick=$$$blockui("Load...")_";"_##class(apptools.core.Action).WriteActJs(%request,divId_"MainForm",divId_"MainContent",..%ClassName(1),divId_"Result","~key="_key_"~divId="_divId_"~mode=*")
		&html<
		<table width="90%" style="border-radius: 10px; border: 1px solid #72a7cf" cellpadding="2" cellspacing="0" class="DetailTable" bgcolor="#c4d6d6" >
		<tr>
			<td>
		Path to files
			</td>
			<td>
				#($$$appText(divId_"Path_to_files","title='path to files' size=80 ",path))#
			</td>		
		</tr>
		<tr>
			<td>
			
			</td>
			<td>
			#($$$appButton(divId_"appButtonResult1","onclick="""_$tr(onclick,"*",1)_"""","Save"))#
			</td>
		</tr>
		</table>
	>
	quit $$$OK
}

/// Search result
ClassMethod OptionResult(Par = "") As %Status
{
	do ##class(apptools.core.Form).BlockUI(0)
	set key=Par("key")
	set divId=Par("divId")
	set mode=Par("mode")
	;Geting elements from form and prepare array Par
	set Name=##class(apptools.core.Action).GetElemForm(%request,.Par,divId_"Path_to_files")	
	set st=$$$OK
	if mode=1 {
		write ..ButtonAgain(divId,key)
		if Name="" w $$$appError($$$aText("Context is empty","")) quit $$$OK
		do ##class(apptools.lte.infochest).SetAppRootdir(Name)
		write $$$appMsg(Name_" saved")
	} 
	write "<br>"
	quit $$$OK
}

/// set base64 = ##class(apptools.core.rest).getStatic("apptools.lte.infochest:image") w !,base64,!
XData image [ MimeType = application/yaml ]
{
data:image/x-png;base64,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
}

}

