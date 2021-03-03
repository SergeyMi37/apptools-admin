Include apptools.core

Class apptools.lte.infochest Extends apptools.lte.adminTabs [ ClassType = "", DependsOn = apptools.core.msg, ProcedureBlock ]
{

/// Application title
Parameter HeaderText = "Info Chest";

/// Global Name Store Referens files
Parameter GNStore = "^apptools.infochest";

Parameter AppRoles;

/// Replace parameters
ClassMethod MainParameter(ByRef h, path, url = "") As %Status
{
 set par("=Brand-Text=")="Info Chest"
 set par("=Logo-png=")="infochest.png"
 set par("=titleAppToolsadmin=")=..#HeaderText
 set par("<!--=LinkIcon=-->")=..GetAppIcon(path_"dist/img/infochest","png")
 quit ..RepaceParameter(.h, path, url,.par)
 quit $$$OK
}

/// write ##class(apptools.lte.infochest).GetAppRootdir()
ClassMethod GetAppRootdir() As %String
{
	set rootdir="d:\files\"
	if $zversion(1)=3 s rootdir="/home/project/shared/photo/"
	set rootdir= ##class(%File).GetDirectory($zu(86))_"/mgr/.modules/"_$namespace_"/apptools-admin/1.1.4/files/"
	quit ##class(%File).GetDirectory(rootdir)
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
	s opt(key,"TabName")="Parameter"
	s opt(key,"ClassName")=..%ClassName(1)
	s opt(key,"Method")="ShowTabSamples"
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

 if '$d(List) { write "No files and directories"
	 quit $$$OK }
 ;If there are no directories, then we will immediately show the files
 if '$d(sort("n","D")) {
	 do ..FilesShow(.Par,dir,.sort)
	 quit $$$OK
 }
 
 set on=$$$blockui("Ждите...")_";"_##class(apptools.core.Action).WriteActJs(%request,"",mcont,..%ClassName(1),"NexLevelTree","&key="_key_"&divId="_divId_"&count=*&dir=***")

 s IdTab=$tr($p($zts,",",2),".")
 s fields(1)="<img class='uk-preserve-width uk-border-circle' src='"_$g(sort("icon"))_"' width='40' alt=''>" ;,fields(1,"attr")="class='uk-table-shrink'"
 s fields(2)="Name",fields(2,"attr")="class='uk-table-expand'"
 d ..DrawTableUi("beg","Table"_IdTab,"style='overflow: auto; height: 300px;'",.fields)
 
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
  $$$jsstart
	w "$('#Table"_IdTab_"').height($(window).height()-($('#t1').height()+$('#MainNavbar').height()+200));"_$c(13,10)
  $$$jsstop
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
    d ##class(apptools.core.files).GetList(dir,"*.*",.List)
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
	 s fields(1)="<img class='uk-preserve-width uk-border-circle' src='"_$g(sort("icon"))_"' width='40' alt=''>"
 	 s fields(2)=$p(dir,$$$slash,*),fields(2,"attr")="class='uk-table-expand'"
 	d ..DrawTableUi("beg","TableAudio"_IdTab,"style='overflow: auto; height: 300px;'",.fields)
	 s i="" for num=1:1 { s i=$o(sort("n","F",i)) q:i=""
	  	s row(2)=$p($p($lg(sort("n","F",i),1),$$$slash,*),".",1,*-1)
 		s row(2,"attr")="class='uk-table-expand' "
 		set fileId=##class(apptools.core.files).GetFileIdView($lg(sort("n","F",i),1)) 
 		s nextrack="Track"_IdTab_"-"_$S($o(sort("n","F",i))="":1,1:num+1)
 		s row(1)="<audio id='Track"_IdTab_"-"_num_"'  src="""_dynamic_fileId_""" onended=""document.getElementById('"_nextrack_"').play();"" controls preload=""metadata""></audio>"
 		d ..DrawTableUi("tr",,,.row)
 		}
 	d ..DrawTableUi("end")
	$$$jsstart
	w "$('#TableAudio"_IdTab_"').height($(window).height()-($('#t1').height()+$('#MainNavbar').height()+200));"_$c(13,10)

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
	 s fields(1)="<img class='uk-preserve-width uk-border-circle' src='"_$g(sort("icon"))_"' width='40' alt=''>"
 	 s fields(2)=$p(dir,$$$slash,*),fields(2,"attr")="class='uk-table-expand'"
 	d ..DrawTableUi("beg","TableBooks"_IdTab,"style='overflow: auto; height: 300px;'",.fields)
	 s i="" for { s i=$o(sort("n","F",i)) q:i=""
	  	s row(2)=$p($p($lg(sort("n","F",i),1),$$$slash,*),".",1,*-1)
 		s row(2,"attr")="class='uk-table-expand' "
 		set fileId=##class(apptools.core.files).GetFileIdView($lg(sort("n","F",i),1),,"application/force-download") 
 		s row(1)="<a href="""_dynamic_fileId_""">Download</a>"
 		d ..DrawTableUi("tr",,,.row)
 		}
 	d ..DrawTableUi("end")
	$$$jsstart
	w "$('#TableBooks"_IdTab_"').height($(window).height()-($('#t1').height()+$('#MainNavbar').height()+200));"_$c(13,10)
	$$$jsstop
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

}

