Include apptools.core

/// The template GUI of the application selector and tabs on the basis jQueryUi, Uikit
Class apptools.lte.adminTabs Extends %CSP.Page [ ClassType = "", DependsOn = apptools.core.msg, ProcedureBlock ]
{

/// The application title
Parameter HeaderText = "AdminTabsApplication";

/// Global Name Store Referens files and id sessions
Parameter GNStore = "^%apptools.ui";

/// For Redirect 
Parameter PreLoad;

/// is there a right to work with this form
ClassMethod IsPermiss(role) As %Status
{
	q $roles[role||($roles["%All")
}

/// Icon from png
ClassMethod GetAppIcon(path, ext) As %String
{
	if path'="" {
		quit "<link rel=""icon"" href="""_path_"."_ext_""" type=""image/x-"_ext_"""/><link rel=""shortcut icon"" href="""_path_"."_ext_""" type=""image/x-"_ext_"""/>"
	}
	else {
		;hammer gray
		quit "<link rel=""icon"" type=""image/x-icon"" href="""_##class(apptools.core.rest).getStatic("apptools.Tabs.PanelUikit:IconTools")_"""/>"		
		;grammophon
		;quit "<link rel=""icon"" type=""image/x-icon"" href=""data:image/x-icon;base64,AAABAAEAEBAAAAAAAABoBAAAFgAAACgAAAAQAAAAIAAAAAEAIAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAD///8A////AP///wD///8A////AP///wD///8A////AP///wD///8A////AP///wD///8A////AP///wD///8A////AP///wD///8A////AP///wD///8A////AP///wD///8A////AP///wD///8A////AP///wD///8A////AP///wD///8AJCQk/yQkJP8AAAD/AAAA/wAAAP8AAAD/AAAA/wAAAP8AAAD/AAAA/0ZGRv8XFxf/////AP///wD///8A////AP///////////////+7u7v9OTk7/sbGx/11dXf9KSkr///////////+lpaX/4eHh/////wD///8A////AAAAAP8AAAD///////////+8vLz///////X19f/t7e3/gICA/5eXl////////////wAAAP8AAAD/////AKysrP8AAAD/AAAA/wAAAP+enp7/////////////////////////////////5OTk/wAAAP8AAAD/AAAA/6ysrP////8A////AP///wCurq6PlJSUzP///wD///8A////AP///wD///8A////AJSUlMyQkJDY////AP///wD///8A////AP///wD///8AAAAA/wAAAP////8A////AP///wD///8A////AP///wAAAAD/AAAA/////wD///8A////AP///wD///8AAAAA/wAAAP8AAAD/////AP///wD///8A////AP///wD///8AAAAA/wAAAP8AAAD/////AP///wD///8ACwsL/wAAAP8AAAD/lJSU2AAAAP8AAAD/cnJy/1hYWP8AAAD/AAAA/2FhYdgHBwf/AAAA/wAAAP////8A////AP///wD///8A////AP///wAAAAD/s7Oz/wAAAP8AAAD/x8fH/wAAAP////8A////AP///wD///8A////AP///wD///8A////AP///wAAAAD/AAAA/////wAAAAD/AAAA/////wAAAAD/AAAA/////wD///8A////AP///wD///8A////AP///wD///8AAAAA/wAAAP+qqqqlAAAA/wAAAP9lZWXjAAAA/wAAAP////8A////AP///wD///8A////AP///wD///8A////ALa2tv////8A9vb2UQAAAP8AAAD/////Uf///wDAwMD/////AP///wD///8A////AP///wD///8A////AP///wD///8A////AP///wBcXFz/AAAA/////wD///8A////AP///wD///8A////AP///wD///8A////AP///wD///8A////AP///wD///8A////AP///wD///8A////AP///wD///8A////AP///wD///8A//8AAP//AADAAwAAwAMAAIABAAAAAAAA5+cAAOfnAADH4wAAgAEAAPgfAADyTwAA8A8AAPZvAAD+fwAA//8AAA==""/>"
	}
}

/// Replace parameters
ClassMethod RepaceParameter(ByRef h, path, url = "", ByRef par) As %Status
{
 set p=""
 for { set p=$Order(par(p)) quit:p=""
 	set h=$replace(h,p,par(p))
 }
 ;links 
 set linkjqueyuikit= ##class(apptools.core.LogInfoPane).GetLink()
 set linkjqueyuikit2= ##class(apptools.core.LogInfoPane).AddJsScripts() 
 set js= ..GetStringJs($namespace,..%ClassName(1),0)
 set h=$replace(h,"<!--=Links=-->",
 				linkjqueyuikit_$$$NL_
 				linkjqueyuikit2_$$$NL_
 				js_$$$NL
 	)
 set menu=..DrawMenu() ;sidebar
 set h=$replace(h,"<!-- =Sidebar Menu= -->",menu)
 set menuTop=..DrawMenuTop() ;top think
 set h=$replace(h,"<!-- =Item Dropdown Menu= -->",menuTop)
 if url["autoload=" set autoload=$p($p($p(url,"autoload=",2),"-"),"&")
 set js= ..GetStringJs($namespace,..%ClassName(1),1,$G(autoload))
  set h=$replace(h,"<!--=JS-Autoload=-->",js)
 quit $$$OK
}

ClassMethod GetStringJs(ns, cls, postload = 0, autoload = "") As %String
{
 set io=$i
 OPEN 2:$j USE 2
 if postload {
	 write $$$NL
 $$$jsstart write $$$NL
 	write ##class(apptools.core.Action).WriteActJs(%request,"","account_status",..%ClassName(1),"DrawStatus","")_$$$NL
 	set enter=##class(apptools.core.Action).WriteActJs(%request,"","MainHidden",..%ClassName(1),"ShowTab","&appPar=Search&Searchstr='+document.getElementById('searchstr').value")_$$$NL
 	write "$('#searchstr').keydown(function (e) { if (e.keyCode == 13) { "_enter_" }});"_$$$NL
  	if autoload="" {
	 	do ..GetAllApps(.opt) 
	 	set i="" 
	 	for { set i=$o(opt(i)) q:i=""
	 		if $GET(opt(i,"Active")) write "$('#Menu"_opt(i,"id")_"').trigger('click');"_$$$NL
	 	}
 	} else {
	 	write "$('#Menu"_autoload_"').trigger('click');"_$$$NL
 	}
 	write $$$NL
 $$$jsstop write $$$NL
 }
 else {
 	do ##class(apptools.core.LogInfoPane).AddJS(ns,cls)
 	do ##class(apptools.core.LogInfoPane).AddStyle()
 }
 set i=""
 	,js=""
 for { set i=$o(^SPOOL($j,i),1,s) q:i=""
		set js=js_s_$$$NL
 	}
 	KILL ^SPOOL($j)

 use io
 quit js
}

/// what are the available modes
ClassMethod GetAllApps(opt) As %Status
{
}

/// the rendering top menu 
ClassMethod DrawMenuTop(Par) As %String
{
	do ..GetAllApps(.opt) 
	do ..GetAllMenu(.opt,.menu,1)
	set m="",ret=""
	for { set m=$o(menu(m)) quit:m=""
		set i=""
		  set iditem="id_top_item"_m
		  if m=99 set iditem="account_status" //account - with submenu
		 s ret=ret_"<li class=""nav-item dropdown"">"_
        	"<a class=""nav-link"" data-toggle=""dropdown"" href=""#"">"_
          	 "<span id="""_iditem_""">"_$lg(menu(m),2)_"</span>"_
        	"</a>"_
        	"<div class=""dropdown-menu dropdown-menu-lg dropdown-menu-right"">"
			for { set i=$o(menu(m,i)) quit:i=""
				set onclick=##class(apptools.core.Action).WriteActJs(%request,"","MainHidden",..%ClassName(1),"ShowTab","&appPar="_i)
				set ret=ret_
			     "<div class=""dropdown-divider""></div>"_
          		"<a href=""#"" class=""dropdown-item"" id='Menu"_$g(opt(i,"id"))_"' onclick="""_onclick_""">"_
           		 "<i class=""fas fa-file333 mr-2""></i>"_
            	 "<span class=""float-right text-muted text-sm"">"_$g(opt(i))_"</span>"_
          		"</a>"
			}
 			s ret=ret_ 
    	    	"</div>"_
	      	"</li>"
		}
	
  quit ret
}

/// render side menu 
ClassMethod DrawMenu(Par) As %String
{
	do ..GetAllApps(.opt) 
	do ..GetAllMenu(.opt,.menu)
	set m="",ret=""
	for { set m=$o(menu(m)) quit:m=""
		set i=""
		set active=$s($lg(menu(m),3):"menu-open",1:"")
		set ret=ret_
		"<li class=""nav-item "_active_""">"_
            "<a href=""#"" class=""nav-link"" >"_
              //"<i class=""nav-icon fas fa-chart-pie""></i>"_
              "<i class=""nav-icon fas fa-copy""></i>"_
              "<p>"_$lg(menu(m),2)_
                "<i class=""right fas fa-angle-left""></i>"_
              "</p>"_
            "</a>"
		
		;s ret=ret_
		;	"<li class='has-children overview "_active_"'><a href='#'>"_
		;	$lg(menu(m),2)_
		;	"</a><ul>"
		for { set i=$o(menu(m,i)) quit:i=""
	   		set onclick=##class(apptools.core.Action).WriteActJs(%request,"","MainHidden",..%ClassName(1),"ShowTab","&appPar="_i)
		 	set ret=ret_	
			"<ul class=""nav nav-treeview"">"_
              "<li class=""nav-item"">"_
                "<a id='Menu"_$g(opt(i,"id"))_"' href=""#"" onclick="""_onclick_""" class=""nav-link"">"_
                //"<i class=""far fa-circle nav-icon""></i>"_
                "<i class=""nav-icon fas fa-ellipsis-h""></i>"_
                			
                  "<p>"_$g(opt(i))_"</p>"_
                "</a>"_
              "</li>"_
            "</ul>"
			;set ret=ret_
			;	"<li><a id='Menu"_$g(opt(i,"id"))_
			;	"' href='#' onclick="""_onclick_""">"_
			;	$g(opt(i))_
			;	"</a></li>"
		}
		;s ret=ret_"</ul></li>"
	}
	set ret=ret_"</li>"
  quit ret
}

/// To obtain information on the support
ClassMethod GetSupportInfo() As %String
{
	set msg=$$$aText("Software complex to debug. Try to log in later, or contact tech support:","")
	quit msg_"Support info mailto: sergey.mikhaylenko@gmail.com"
}

/// To add to the form js code if development mode
ClassMethod IsDebugMode(mode = 0) As %Status
{
 if mode,'%request.Get("debug") { 
	$$$jsstart
	  write $$$blockui(..GetSupportInfo())
	$$$jsstop
  quit $$$OK
 }
	quit 0
}

/// rendering status of the user
ClassMethod DrawStatus(Par) As %Status
{
 set fio=##class(apptools.core.sys).GetFullName($username)
 set:fio="" fio=$$$aText("The user","")
 write "<span class='tip' title='"_fio_"-"_$j_"-"_$zu(5)_"'>"_$username_"</span>"
 quit $$$OK
}

/// To menu
ClassMethod GetAllMenu(opt, menu, top = 0) As %Status
{
 set i="" for { s i=$o(opt(i)) q:i=""
	if 'top,$d(opt(i,"Menu")) { 
		set m=$lg(opt(i,"Menu"),1)
		set:'$d(menu(m)) menu(m)=opt(i,"Menu")
		set menu(m,i)=""
	}
	if top,$d(opt(i,"MenuTop")) { 
		set m=$lg(opt(i,"MenuTop"),1)
		set:'$d(menu(m)) menu(m)=opt(i,"MenuTop")
		set menu(m,i)=""
	} else {
		;s:'$d(menu(99)) menu(99)=$lb(0,"---",0)
		;s menu(99,i)=""
	}
  }
}

/// drawing Tabs search
/// Par - code menu item from the GetAllApps ..
ClassMethod ShowTabSearch(key = "") As %Status
{
 ;do ..GetAllApps(.opt) 
 ;if $g(opt(key,"Disable")) write ..GetSupportInfo() quit $$$OK
 ;set NSpace=$zu(5)
 write $$$aText("Context","")_" :"_$g(key)
 ;set pref=$g(opt(key,"id"))
}

/// the render Tab on the menu
/// Par - code menu item from the GetAllApps ..
ClassMethod ShowTab(Par) As %Status
{
	if $g(Par("appPar"))'="" set Par=Par("appPar")
	do ..GetAllApps(.opt) 
	do ..ShowTabApps(.Par,.opt)
}

/// the render Tab on the menu
/// Par - code menu item from the GetAllApps ..
ClassMethod ShowTabApps(Par, opt) As %Status
{
	if Par="Search" {
		set Searchstr=$g(Par("%request.Data","Searchstr"),Par("Searchstr"))
		if Searchstr="" q $$$OK
		;s tr=$tr(##class(apptools.MSW.type).Transliteration(Searchstr)," №`()\/*;'"":%","_N---")
		;s tr=$tr($zts,".,") 
		set tr=$e($tr(Searchstr," №`()\/*;'"":%?$@&.,",""),1,10)_$i(@..#GNStore@("jobs",$j))
		set key=tr ;Searchstr
		MERGE opt(key)=opt(Par)
		set opt(key)=opt(key)_tr ;Searchstr
		if $g(opt(Par,"TabMenu","Mode"))=1 { ;mode add a new tab 
			set opt(key,"id")=opt(key,"id")_tr
		} else { ;mode add a new replace the old 
			set tabId="tab-"_opt(Par,"id")
			set tabIdMenu="tabMenu-"_opt(Par,"id")
			$$$jsstart
		  	 write "$('#"_tabId_"').remove();"
		  	 write "$('#"_tabIdMenu_"').remove();"
		  	$$$jsstop
		}
		s opt(key,"CGIvar")="&Searchstr="_Searchstr ;$zconvert(Searchstr,"O","URI")
		s opt(key,"TabName")=opt(key,"TabName")_tr 
		s Par=key

	}
	set tabId="tab-"_opt(Par,"id")
	set tabIdMenu="tabMenu-"_opt(Par,"id")
	if $g(opt(Par,"TabMenu","Close"))'="" s IconMenu="<span class=""uk-margin-small-left uk-icon uk-close"" uk-icon=""close"" onclick=""$(\'#"_tabIdMenu_",#"_tabId_"\').remove();""></span>"
 	if $DATA(opt(Par,"TabMenu","Close"))>9 { //there are more points
 		;TODO
 	}
 	$$$jsstart
 	 if $g(opt(Par,"MethodUrlNewWin"))'="" {
	 	 if $g(opt(Par,"Disable")) { w "alert('"_$$$aText("Mode debugging","")_"');"}
	 	 else {write "window.open('"_$g(opt(Par,"MethodUrlNewWin"))_"','_blank');"
	 	 }
 	}
	else {
 	 write "if (!$('li').is('#"_tabId_"')) { $('.uk-active').removeClass('uk-active');"_$c(13,10)
 		write " $('#tabList').append('<li id="_tabId_"></li>');"_$c(13,10)
 		write " $('#tabMenu').append('<li id="_tabIdMenu_"><a><font color=Lightsteelblue>"_$g(opt(Par,"TabName"))_"</font>"_$g(IconMenu)_"</a></li>');"_$c(13,10)
 		write " $('#t1,#ta1').hide();"_$c(13,10) //" $('#t1').prop('disabled',true);"
 		if $g(opt(Par,"Disable")) {
	 		;write "$('#"_tabId_"').load('apptools.core.Action.cls','appClass="_..%ClassName(1)_"&appMethod=ShowTabAbout&appNsp="_$zu(5)_"&appPar="_Par_"');"
	 		write ##class(apptools.core.Action).WriteActJs(%request,"",tabId,..%ClassName(1),"ShowTabAbout","&appPar="_Par_$g(opt(Par,"CGIvar")))
 		}
 		elseif $g(opt(Par,"MethodUrl"))'="" {
	 		write "$('#"_tabId_"').load('"_$g(opt(Par,"MethodUrl"))_"');"
 		}
 		else {
	 		;write "$('#"_tabId_"').load('apptools.core.Action.cls','appClass="_$g(opt(Par,"ClassName"))_"&appMethod="_$g(opt(Par,"Method"))_"&appNsp="_$zu(5)_"&appPar="_Par_"');"
	 		write ##class(apptools.core.Action).WriteActJs(%request,"",tabId,$g(opt(Par,"ClassName")),$g(opt(Par,"Method")),"&appPar="_Par_$g(opt(Par,"CGIvar")))
 		}
 	 write "};"
 	 write " UIkit.tab('#tabMenu').show($('#"_tabIdMenu_"'));"
	}
	$$$jsstop
}

/// Return in a single string
ClassMethod Logout(Par) As %Status
{
 if $g(Par("appPar"))'="" set Par=Par("appPar")
 do ##class(apptools.core.sys).logout()
 do ..GetAllApps(.opt) 
 $$$jsstart
 set i=""
 for { set i=$o(opt(i)) q:i=""
 	continue:i=Par
 	set tabId="tab-"_opt(i,"id")
	set tabIdMenu="tabMenu-"_opt(i,"id")
 	write "$('#"_tabIdMenu_",#"_tabId_"').remove();"
 }
 $$$jsstop
 set onclick = "top.document.location.reload();"
 &html<
 <br>
 <div class="uk-align-center uk-width-1-1 uk-margin-left uk-margin-right ">
	<div class="uk-alert-warning" uk-alert>
	<p>#($$$aText("The output of System produced",""))#</p>
	</div>
	<center>
		<button class="uk-button uk-button-primary uk-margin-small-right" type="button" onclick="#(onclick)#" >
		<span class="uk-margin-small-left uk-icon" uk-icon="sign-in">
		</span>#($$$aText("Login",""))#</button>
	</center>
</div>
>
 	quit $$$OK
}

/// The output of the First button
ClassMethod ButtonAgain(divId = "", key = "") As %Status
{
	set mhead=divId_"MainHeader"
	set mcont=divId_"MainContent"
	set onclick="$('#"_mcont_"').empty();"_##class(apptools.core.Action).WriteActJs(%request,divId_"MainForm",mhead,..%ClassName(1),divId_"FirstHead","&key="_key_"&divId="_divId)
	;AppAct('"_divId_"MainForm','"_mhead_"','AppAct="_$zu(5)_":"_..%ClassName(1)_":"_divId_"FirstHead:&divId="_divId_"&key="_key_"');"
	quit $$$appButton("appButtonExit","onclick="""_$g(onclick)_"""",$$$aText("Again",""))
}

/// the render Tab On the program"
/// Par - code menu item from the GetAllApps ..
ClassMethod ShowTabAbout(key = "") As %Status
{
	if $g(key("appPar"))'="" set key=key("appPar")
	do ..GetAllApps(.opt) 
	if $g(opt(key,"Disable")) write ..GetSupportInfo() quit $$$OK
	set divId=$g(opt(key,"id"))
	write "Hello world! Parameter: "_key
	write ..ButtonAgain(divId,key)
}

/// rendering the Tab previously submitted
/// Par - code menu item from the GetAllApps ..
ClassMethod ShowInIFrame(key = "") As %Status
{
 if $g(key("appPar"))'="" set key=key("appPar")
 do ..GetAllApps(.opt) 
 if $g(opt(key,"Disable")) write ..GetSupportInfo() quit $$$OK
 set NSpace=$zu(5)
 set pref=$g(opt(key,"id"))
 set mhead=pref_"MainHeader"
 set mcont=pref_"MainContent"
 &html<
<form id="#(pref_"MainForm")#">
<div class="uk-grid">
    <iframe id="#(mcont)#" width="100%" height="100%" style='overflow: auto;' src='#($g(opt(key,"InFrameUrl")))#' ></iframe>
    </div>
</div>
</form>
>
 quit $$$OK
}

/// rendering the Tab previously submitted
/// Par - code menu item from the GetAllApps ..
ClassMethod ShowTabSample(key = "") As %Status
{
 if $g(key("appPar"))'="" set key=key("appPar")
 do ..GetAllApps(.opt) 
 if $g(opt(key,"Disable")) write ..GetSupportInfo() quit $$$OK
 set NSpace=$zu(5)
 set pref=$g(opt(key,"id"))
 set mhead=pref_"MainHeader"
 set mcont=pref_"MainContent"
 &html<
<form id="#(pref_"MainForm")#">
<div class="uk-grid">
    <div class="uk-width-1-1 "id="#(mhead)#" ></div>
    <div style='overflow: auto;' class="uk-width-1-1 uk-margin-top uk-margin-left" id="#(mcont)#"></div>
</div>
</form>
>
 ;d ##class(apptools.core.LogInfoPane).AddJS(NSpace,..%ClassName(1))
 
 $$$jsstart
  	; to calculate the height of the container as a result of wijetunge victory container-Taba height of the container header
    write ##class(apptools.core.Action).WriteActJs(%request,pref_"MainForm",mhead,..%ClassName(1),pref_"FirstHead","&divId="_pref_"&key="_key)
  	write $$$blockui($$$aText("Loading...",""))
 $$$jsstop
 quit $$$OK
}

/// Lighbox Draw JSON
/// List - files array 
/// subdir - application static
ClassMethod LighboxDrawJson(List, subdir = "", appdynamic, gn = "") As %Status
{
 set i=""
 for { set i=$o(List(i)) q:i=""
 	if $lv($g(List(i))),$lg($g(List(i)),2)="F" {
		 	set fullpath=$lg($g(List(i)),1)
		 	set ItemName=$lg($g(List(i)),4)
 	} else {
 		set ItemName=$g(List(i,"ItemName"))
 		set fullpath=$g(List(i,"Name"))
 	}
 	set ext=$p(ItemName,".",*)
 	set mimetype=##class(apptools.core.filesMimeTypes).GetMimeTypes4ext(ext)
 	set type=$s(mimetype[("video"):"video",(mimetype)[("image"):"image",1:"iframe")
 	if subdir'="" {
 		write "{source: '"_subdir_ItemName_"', caption: '"_ItemName_"', type: '"_type_"'}",$c(13,10)
 	} else {
	 	set fileId=##class(apptools.core.files).GetFileIdView(fullpath,gn) 
		write "{source: '"_appdynamic_fileId_"', caption: '"_ItemName_"', type: '"_type_"'}",$c(13,10)
 	}
	write:$o(List(i))'="" ","
 }
}

/// Encode string to URL
ClassMethod EnCode(s) As %Status
{
	set s=$zconvert(s,"O","URL")
	quit s
}

/// Decode string from URL
ClassMethod DeCode(s) As %Status
{
	quit $zconvert(s,"I","URL")
}

/// Draw Tables UiKit
ClassMethod DrawTableUi(mode = "beg", divId = "tab2", attr = "", ByRef Enum) As %Status
{
	if mode="beg" {
	&html<
 <div #(attr)# id="#(divId)#" >
    <table class="uk-table uk-table-hover uk-table-middle uk-table-divider">
        <thead>
           <tr>
          >
          set i=""  for {  s i=$o(Enum(i)) quit:i=""
            write " <th "_$GET(Enum(i,"attr"))_" >"_$g(Enum(i))_"</th>"
          }
               /* <th class="uk-table-shrink">Preserve</th>
                <th class="uk-table-expand">Expand + Link</th>
                <th class="uk-width-small">Truncate</th>
                <th class="uk-table-shrink uk-text-nowrap">Shrink + Nowrap</th> */
    &html<
            </tr>
        </thead>
        <tbody>
        >
	}
    elseif mode="tr" {
			write "<tr>"
            set i=""  for {  set i=$o(Enum(i)) quit:i=""
				write "<td "_$GET(Enum(i,"attr"))_"><font color=Lightblue>"_$GET(Enum(i))_"</font></td>"
               
               /* <td><input class="uk-checkbox" type="checkbox"></td>
               <td><img class="uk-preserve-width uk-border-circle" src="image/msw.jpg" width="40" alt=""></td>
                <td class="uk-table-link">
                    <a class="uk-link-reset" href="">Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor.</a>
                </td>
                <td class="uk-text-truncate">Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor.</td>
                <td class="uk-text-nowrap">Lorem ipsum dolor</td>*/
            } 			
            w "</tr>"
	}
	elseif mode="end" {
		&html<
		   </tbody>
 	 	 </table>
 		</div>
    	>
	} else {
	}
}

}

