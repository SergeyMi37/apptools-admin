Include apptools.core

/// Security utilities
Class apptools.Tabs.security [ Abstract, DependsOn = apptools.core.msg ]
{

/// Save Access Rights
/// d ##class(apptools.Tabs.security).UiSavePermiss(.Par)
ClassMethod UiSavePermiss(Par = "") As %Status
{
	do ##class(apptools.core.Form).BlockUI(0)
	set key=Par("key")
	set divId=Par("divId")
	set mode=Par("mode")

	;Geting elements from form and prepare array Par
	s name=##class(apptools.core.Action).GetElemForm(%request,.Par,divId_"name")	
	;set roles=$g(Par("%request.Data",divId_"roles"))
	
	set i=""
	for { set i=$o(Par("%request.Data",i)) quit:i=""
		if i[(divId_"Matr0") {
			set val=$g(Par("%request.Data",i))
			if val'["unchecked" {
				set chk(i)=val
				set us=$p(i,"0",2)
				set ro=$p(i,"0",3)
				if $e(ro,1)="p" s ro="%"_$e(ro,2,*)
				if ro["_pD" s ro=$replace(ro,"_pD","_%D")
				set users(us,ro)=val
			}
		}
	}

	new $NAMESPACE
  	set $NAMESPACE = "%SYS"
	set us=""
	for { set us=$o(users(us)) quit:us=""
			set tSC=##class(Security.Users).Get(us,.prop)
			if '$$$ISOK(tSC)  write $$$appError(us_": Error="_$SYSTEM.Status.GetErrorText(tSC)) quit
			set roles=","_prop("Roles")_","
			kill prop
			set ro=""
			for { set ro=$o(users(us,ro)) quit:ro=""
				if $g(users(us,ro)) {
					if roles'[(","_ro_",") set roles=roles_ro_","
				}else {
					if roles[(","_ro_",") set roles=$replace(roles,ro_",","") set:$e(roles,*)'="," roles=roles_","
				}
			}
			set:$e(roles,1)="," roles=$e(roles,2,*)
			set:$e(roles,*)="," roles=$e(roles,1,*-1)
			set prop("Roles")=roles
			;zw prop
			;##class(apptools.form).UikitNote($$$aText("Saved",""),"success")
			set tSC=##class(Security.Users).Modify(us,.prop)
			if '$$$ISOK(tSC) write $$$appError(##class(apptools.core.Form).UikitNote(us_": Error="_$SYSTEM.Status.GetErrorText(tSC))) quit
			;Check
			set tSC=##class(Security.Users).Get(us,.pro)
			if '$$$ISOK(tSC) write $$$appError(##class(apptools.core.Form).UikitNote(us_": Error="_$SYSTEM.Status.GetErrorText(tSC))) quit
			write $$$appMsg(##class(apptools.core.Form).UikitNote(us_": "_pro("Roles"),"success"))
	}
	Quit $$$OK
}

/// Get HTML content of access matrix form
/// d ##class(apptools.Tabs.security).UiMatrixPermission("sm","sp","Ui","AnyKey","apptools.Tabs.security","Ui"_"SavePermiss")
ClassMethod UiMatrixPermission(name = "", rolesmask = "", divId = "", key = "", class = "", Method = "", blockui = 1) As %Status
{
		if name="" write $$$appError($$$aText("Select the filter by user option Login blank (Names separated by commas or by the context","")) q 1
		if rolesmask="" write $$$appError($$$aText("Select the filter control","")) q 1
		set msg=$$$aText("Matrix of access rights","")
		set:blockui onclick=$$$blockui($$$aText("Loading...",""))
		;set onclick=$g(onclick)_";ActionJs('"_divId_"FormContentSave','"_divId_"ContentSave','"_class_"','"_Method_"','key="_key_"~divId="_divId_"~mode=Save');"
		
		set onclick=$$$blockui("Load...")_";"_##class(apptools.core.Action).WriteActJs(%request,divId_"FormContentSave",divId_"ContentSave",class,Method,"&key="_key_"&divId="_divId_"&mode=Save")
		;ActionJs('"_divId_"MainForm','"_divId_"MainContent','','"_divId_"Result','key="_key_"~divId="_divId_"~mode=*');"
        ;set %ui=1
		set butt=$$$appButton(divId_"appButtonSavePermiss","onclick="""_onclick_"""",$$$aText("Save access rights",""))
		write butt_"<br><br>"
		write "<form id='"_divId_"FormContentSave' >"
		do ##class(apptools.core.sys).GetRoles(rolesmask,.roles)
		if '$d(roles) write $$$appError($$$aText("This filter was","")) quit 1
		;set roles("%all")=$lb("%All","The Super-User Role")
		do ##class(apptools.core.sys).GetUsers(name,.users)
		if '$d(users) write $$$appError($$$aText("This filter users not found","")) quit 1
		set r="UserName"
  		set gn="matrix"
 	    set @gn@(0,1)=$lb(r)
 		set @gn@(-1,r)=1
  		set col(1)=r
  		set r=""
        for col=2:1 { set r=$o(roles(r)) quit:r=""
        	set NameRole=$lg(roles(r),1)
   		    set @gn@(0,col)=$lb(NameRole)
	  		set @gn@(-1,NameRole)=col
	  		set col(col)=NameRole
        }
        set col=col-1
		set u=""		
		for row=1:1 { set u=$o(users(u)) quit:u=""
			set usroles=$lg(users(u),3)
			;zwrite usroles
			set @gn@(row)=$g(@gn@(row))_$lb(u)
			for c=2:1:col {
				set yes="unchecked"
				if $LISTFIND(usroles,col(c)) set yes="1unchecked"
				set ret=##class(apptools.core.Form).WebCompShowCheckbox(,,,divId_"Matr0"_u_"0"_$tr(col(c),"%","p")_"0",yes)
				set @gn@(row)=$g(@gn@(row))_$lb(ret)
			}
		}
		;write "$('#"_pref_"MainContent').height($('#tabs-"_pref_"').height()-$('#"_pref_"MainHeader').height()-150);"
		;write "<div id='TabViewCont' style='overflow: scroll;   max-width: 1200px;  max-height: 500px;'>"
		set st=##class(apptools.core.LogInfoPane).DrawSQL("result "_gn,100000,$zu(5),$g(msg),$g(exec),,1)
		;write "</div>"
		;TODO do ##class(apptools.core.Form).DrawTable(.matrix) 
		write "</form><div id='"_divId_"ContentSave'></div>"
		quit $$$OK
}

/// Create users and Save Access Rights
/// s Users("Test1","%All")=1,Users("Test1")=$lb("Pass","Description") w ##class(apptools.LockDown).Modify(.Users)
ClassMethod UsersModify(users = "") As %Status
{

	new $NAMESPACE
  	set $NAMESPACE = "%SYS"
  	set tSC=$$$OK
	set us=""
	for { set us=$o(users(us)) quit:us=""
			;if not exist then create TODO
			if '##class(Security.Users).Exist(us) {
				continue
			}
			set tSC=##class(Security.Users).Get(us,.prop)
			if '$$$ISOK(tSC)  write $$$appError(us_": Error="_$SYSTEM.Status.GetErrorText(tSC)) quit
		
			set roles=","_prop("Roles")_","
			kill prop
			set ro=""
			for { set ro=$o(users(us,ro)) quit:ro=""
				if $g(users(us,ro)) {
					if roles'[(","_ro_",") set roles=roles_ro_","
				}else {
					if roles[(","_ro_",") set roles=$replace(roles,ro_",","") set:$e(roles,*)'="," roles=roles_","
				}
			}
			set:$e(roles,1)="," roles=$e(roles,2,*)
			set:$e(roles,*)="," roles=$e(roles,1,*-1)
			set prop("Roles")=roles
			;zw prop
			set tSC=##class(Security.Users).Modify(us,.prop)
			if '$$$ISOK(tSC) quit
			;Check
			set tSC=##class(Security.Users).Get(us,.pro)
			if '$$$ISOK(tSC) quit
	}
	Quit tSC
}

}

