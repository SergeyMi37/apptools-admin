Include apptools.core

/// Resources utilities for ZPM
Class apptools.lte.resources [ Abstract, DependsOn = apptools.core.msg ]
{

/// Default name new packet
Parameter DefaultNamePacket = "new-packet";

/// Save Resources into GN
/// d ##class(apptools.lte.resources).UiSaveRepo(.Par)
ClassMethod UiSaveRepo(Par = "") As %Status
{
	do ##class(apptools.core.Form).BlockUI(0)
	set key=Par("key")
	set divId=Par("divId")
	set mode=Par("mode")
	;zw Par("%request.Data")
	set i=""
	for { set i=$o(Par("%request.Data",i)) quit:i=""
		if i[(divId_"Matr0") {
			set val=$g(Par("%request.Data",i))
			if val {
				set name=$p(i,divId_"Matr0",2)
				if name["---" set name=$replace(name,"---","$")
				if name'="" {
					set repo(name)=val
				}
			}
		}
	}
	if '$d(repo) write $$$appError("No package selected") quit $$$OK
	set i=""
	for ii=1:1:2 { set i=$o(repo(i)) quit:i=""
		write "<pre>"
		if mode="installnew" {
			set st=##class(%ZAPM.ext.zapp).prompt("newdb "_i)
		}
		elseif mode="install" {
			set st=##class(%ZPM.PackageManager).Shell("install "_i)
		}
		write "</pre>"
		if 'st write $$$appError($System.Status.GetErrorText(st))
		else  write $$$appMsg("Done")
	}
	if i'=""  write $$$appError("In the future, it will be possible to install more than 2 at a time, but in the background. Start a issue if you need it.")
	write "<br>"_##class(apptools.lte.zapm).ButtonAgain(divId,key,"Refresh","NSpace")	
	quit $$$OK
}

/// Get HTML content of Resources matrix form
/// do ##class(apptools.lte.resources).UiMatrixRepo(key, divId, ns, mode, zpmname)
ClassMethod UiMatrixRepo(key, divId, ns, mode, zpmname = "", FindMask = "*") As %Status
{
	set onclick=$$$blockui($$$aText("Loading...",""))
	set onclick=$GET(onclick)_$$$onclick(divId_"FormContentSave",divId_"FormContentSave",ns,..%ClassName(1),"UiSaveRepo","&key="_key_"&divId="_divId_"&mode=*")
	write $$$appButton(divId_"appButtonRR5"_ns,"title='Install zpm into current namespace' onclick="""_$replace(onclick,"*","install&ns="_ns_"&zpmname="_zpmname)_"""","Install")
	write $$$appButton(divId_"appButtonRR6"_ns,"title='Install zpm into the newly created namespace' onclick="""_$replace(onclick,"*","installnew&ns="_ns_"&zpmname="_zpmname)_"""","Install in new namespace")
	do ##class(apptools.lte.resources).GetZPMRepo(.List,FindMask)
	if ##class(apptools.lte.zapm).PrivateRepo(,.currepo)
	if '$d(List) write $$$appError("There are no packages in the current register "_$G(currepo(0))_$S("*"'[FindMask:" for mask "_FindMask,1:"")) quit $$$OK
	
	write "<div id='"_divId_"ContentSave'></div><form id='"_divId_"FormContentSave' >"
	set gn="Registry"
	do ##class(apptools.core.sys).SetTableHeader(gn,"Name","Check","Description","Property")
	set row=0
	set name=""

	set msg="<br> Current Reristry: "_$G(currepo(0))
		
	for  { set name=$o(List(name),1,data) quit:name=""
		set stat="unchecked" 
		set name2=name
		if name["$" set name2=$replace(name,"$","---")
		set checkbox=##class(apptools.core.Form).WebCompShowCheckbox(,,,divId_"Matr0"_name2,stat)
		set urldesc=$lg(data,2)
		if $lg(data,3)'="" {
			set repo=$lg(data,3)
			set click="WinOpen('"_$zu(5)_"','apptools.lte.zapm','RepoWinOpen','~zpmname="_name_"~ns="_ns_"~repo="_repo_"','','"_##class(apptools.core.Action).WriteWinOpenREST(%request)_"');"
			;set urldesc="<a href=""#"" onclick="""_click_""">"_$lg(data,2)_"</a>"
			set urldesc="<a target=repo"_name2_" href="""_repo_""">"_$lg(data,2)_"</a>"
		}
		set row=row+1
		do ##class(apptools.core.sys).SetTableRow(gn,row,name,checkbox,$lg(data,1),urldesc)
	}
	;if "*"'[FindMask,$l(FindMask)>3 set exec="##class(apptools.core.LogInfo).MarkRed(%AppLogInfoVal,"""_$tr(FindMask,"*")_""")"
	set st=##class(apptools.core.LogInfoPane).DrawSQL("result "_gn,100000,$zu(5),$g(msg),$g(exec),,1)
	write "</form>"
	quit $$$OK
}

/// Save Resources into GN
/// d ##class(apptools.lte.resources).UiSaveResources(.Par)
ClassMethod UiSaveResources(Par = "") As %Status
{
	do ##class(apptools.core.Form).BlockUI(0)
	set key=Par("key")
	set divId=Par("divId")
	set mode=Par("mode")
	set ns=Par("ns"),%ui=1
	set ModeSet=##class(apptools.core.Action).GetElemForm(%request,.Par,divId_"ModeSet")
	set WorkDirPacket=##class(apptools.core.Action).GetElemForm(%request,.Par,divId_"WorkDirPacket")
	set ggn="^mtempApptoolsLteCheck($username,$job)"
	;Geting elements from form and prepare array Par
	;zw Par("%request.Data")
	;zw @ggn
	set atype="Application-module"
	set i=""
	for { set i=$o(Par("%request.Data",i)) quit:i=""
		if i[(divId_"Matrx") {
			set val=$g(Par("%request.Data",i))
			set name2=$p(i,"Matrx",2)
			if name2=(+name2) {						//checkbox
				if val'["unchecked",val { 
					set val2=@ggn@(name2)
					set type=$lg(val2,1)
					set name=$lg(val2,2)
					;w "<br>"_name
					set checked(type,name)=val2
				}
			}
			elseif name2'["checkbox" {
				set checked(atype,name2)=val
			}
		}
	}
	set namezpm=$g(checked(atype,"Name"))
	;if "?"[namezpm||(namezpm="new-pack?") write $$$appError("Name is a required attribute and it shouldn't be equal to 'new-pack?'") quit $$$OK
	if WorkDirPacket["*" write $$$appError("The directory name must not contain *") quit $$$OK
	;xml update
	set ListProperty=$lb(WorkDirPacket)
	set checked(atype)=ListProperty
	set GN=##class(apptools.lte.zapm).#GNStore
	set gn=$na(@GN@("prototype",ns))
	KILL @gn@(namezpm)
	MERGE @gn@(namezpm)=checked
	;zw checked
	write $$$appMsg("Saved "_namezpm)
	if mode="generate" { //GENERATE
		set st=..Generate(WorkDirPacket, atype, namezpm, .checked, .out)
		if 'st write $$$appError($System.Status.GetErrorText(st)) quit $$$OK
	}
	if mode="load" { //LOAD
		write "<pre>"
		set st=##class(%ZPM.PackageManager).Shell("load "_WorkDirPacket)
		write "</pre>"
	}
	elseif mode="package" { //PACKAGE
		set cmd="package -p "_WorkDirPacket_" "_namezpm
		write cmd
		write "<pre>"
		set st=##class(%ZPM.PackageManager).Shell(cmd)
		write "</pre>"
		set filetgz=WorkDirPacket_".tgz"
		if ##class(%File).Exists(filetgz) {
			do ##class(apptools.lte.resources).GetZpmNamespaces(.a,"fileserver",.firstnamespace)
			if $g(firstnamespace)'="" zn firstnamespace	do ##class(Fileserver.File).AddFile(filetgz)
		}
	}
	write ##class(apptools.lte.zapm).ButtonAgain(divId,key,"Refresh","NSpace")	
	Quit $$$OK
}

ClassMethod Generate(WorkDirPacket, atype, namezpm, ByRef checked, ByRef out) As %Status
{
	Set tFullPath = ##class(%File).NormalizeFilename(WorkDirPacket_"\"_$g(checked(atype,"SourcesRoot")))
	Set tFullPath = ##class(%File).NormalizeFilenameWithSpaces(tFullPath)
	if tFullPath[$zu(12,"") quit $$$ERROR($$$GeneralError,"The directory name must not contain "_$zu(12,"")) 
	write $$$appMsg("Remove Directory Tree "_tFullPath)
	set st=##class(%File).RemoveDirectoryTree(tFullPath)
	;if 'st set msg="Remove Directory Failed" write $$$appError(msg) quit $$$ERROR($$$GeneralError,msg)
	set modulexml=$g(checked(atype,"XML"))
	write "<pre>"
	;set %write=1
	$$$TOE(st,..ExportResources(WorkDirPacket,tFullPath,,.checked,.modulexml,.out))
	write $$$appMsg($zconvert(modulexml,"O","HTML"))
	write "</pre>"
	quit $$$OK
}

ClassMethod ExportResources(WorkDirPacket, dir, flags = "00000", ByRef pro, ByRef modulexml, ByRef out)
{
	set typ="Application-module"
	do ..Add2ModuleXml(.modulexml,.pro,typ)
	for { set typ=$o(pro(typ)) quit:typ=""
		set item=""
		for { set item=$o(pro(typ,item)) quit:item=""
			;write !,"Export one resource: "_item
			do ##class(apptools.core.code).ExportOneResource(dir,flags,item,.out)			
			if typ="CSPApplication" {
				
			}
			elseif typ="FileCopy" {
				;<FileCopy Name="somefile.jar" Target="${libdir}my-lib/"/>
				;set modulexml=$replace(modulexml,"</SourcesRoot>","</SourcesRoot>"_$$$NL_"<Resource Name="""_item_"""/>")
			}
			else {
				set modulexml=$replace(modulexml,"</SourcesRoot>","</SourcesRoot>"_$$$NL_"<Resource Name="""_item_"""/>")
			}
		}
	}
	#dim FileStream As %FileCharacterStream = ##class(%FileCharacterStream).%New()
	set filename=##class(%File).NormalizeFilename( "module.xml", WorkDirPacket )
	
	set FileStream.Filename=filename
	set FileStream.TranslateTable="UTF8"
	do FileStream.Write(modulexml)
	set sc=FileStream.SaveStream()
	quit $$$OK
}

/// d ##class(apptools.lte.resources).ParseModuleXml()
ClassMethod Add2ModuleXml(xml, pro, typ) As %Status
{
	set name=pro(typ,"Name")
		set xml=$p(xml,"<Document ",1)_"<Document name="""_name_".ZPM"">"_$p($p(xml,"<Document ",2),">",2,*)
		set xml=$p(xml,"<Name>",1)_"<Name>"_name_"</Name>"_$p($p(xml,"<Name>",2),">",2,*)
	set ver=pro(typ,"Version")
		set xml=$p(xml,"<Version>",1)_"<Version>"_ver_"</Version>"_$p($p(xml,"<Version>",2),">",2,*)
	set desc=pro(typ,"Description")
		set xml=$p(xml,"<Description>",1)_"<Description>"_desc_"</Description>"_$p($p(xml,"<Description>",2),">",2,*)
	
	quit $$$OK
}

ClassMethod SampleParseModuleXml(xml, out) As %Status
{
	Set stream=##class(%Stream.FileBinary).%New()
	Set tSC = stream.LinkToFile("/opt2/isc/iris20203/mgr/.modules/APPT/apptools-admin/1.0.24/module.xml")
	Return:$$$ISERR(tSC) tSC 
	Set tSC = ##class(%XML.XPATH.Document).CreateFromStream(stream, .tDocument)
	Return:$$$ISERR(tSC) tSC 	
	Set tSC = tDocument.EvaluateExpression("/Export/Document/Module/Name", "text()", .tRes)
    If $$$ISERR(tSC) Return tSC
	Set name = $$$lcase(tRes.GetAt(1).Value)
	w name
	Set tSC = tDocument.EvaluateExpression("/Export/Document/Module/Resource", ".", .tR)
    If $$$ISERR(tSC) Return tSC
	zw tR
	do tDocument.ExampleDisplayResults(.tR)
	Set tSC = tDocument.EvaluateExpression("/Export/Document/Module/CSPApplication", ".", .tA)
    If $$$ISERR(tSC) Return tSC
	zw tA
	do tDocument.ExampleDisplayResults(.tA)
	q 1
	zw tDocument
	zw tRes
	Return $$$OK
}

/// d ##class(apptools.lte.resources).UiMatrixResources(
ClassMethod UiMatrixResources(key, divId, ns, mode, zpmname, GN, blockui = 1) As %Status
{
	set %ui=1
	set ggn="^mtempApptoolsLteCheck($username,$job)" KILL @ggn
	set:blockui onclick=$$$blockui($$$aText("Loading...",""))
	set onclick=$GET(onclick)_$$$onclick(divId_"FormContentSave",divId_"ContentSave",ns,..%ClassName(1),"UiSaveResources","&key="_key_"&divId="_divId_"&ns="_ns_"&mode=*")
	;set onclick=$GET(onclick)_$$$onclick(divId_"FormContentSave",divId_"FormContentSave",ns,..%ClassName(1),"UiSaveResources","&key="_key_"&divId="_divId_"&mode=*")
	set DefaultNamePacket=$tr($zconvert(ns,"L"),"%","-")_"-"_..#DefaultNamePacket
	set dirrepo="/iris-backup/temp/"
	if $D(@GN@("dir"),data) set dirrepo=data
	set dir=dirrepo_$s(zpmname="":DefaultNamePacket,1:zpmname)
	if zpmname'="",$g(@GN@("prototype",ns,zpmname,"Application-module"))'="" set ListProperty=$g(@GN@("prototype",ns,zpmname,"Application-module")) set dir=$lg(ListProperty,1)
	
	write "<div id='"_divId_"ContentSave'></div><form id='"_divId_"FormContentSave' >"

	write $$$appButton(divId_"appButtonSR","onclick="""_$replace(onclick,"*","save")_""" title=""Saved resources selection in prototype store"" ","Save")
	write $$$appButton(divId_"appButtonSR","onclick="""_$replace(onclick,"*","generate")_""" title=""Pack resources selection in a directory, genarate module"" ","Generate")
	write $$$appButton(divId_"appButtonSR","onclick="""_$replace(onclick,"*","load")_""" title=""Load packet"" ","Load")
	write $$$appButton(divId_"appButtonSP","onclick="""_$replace(onclick,"*","package")_""" title=""Package resources selection in the tgz"" ","Package")
	write $$$appText(divId_"WorkDirPacket","size=50 title='The work directory for generate and load'",dir)

	set gn="Resources"
	set flags=$s(ns="%SYS":"001",1:"")
	do ##class(apptools.core.code).GetResources(ns,.Res,flags)
	;add groups packets--------------
	set name=""
	for  { set name=$o(Res("cls",name),1,data) quit:name=""
		if $l(name,".")>2 {
			for p=1:1:($l(name,".")-2) {
				set pack=$p(name,".",1,p) 
				set pack(pack)=""
			}
		}
	}
	set pack=""
	for  { set pack=$o(pack(pack)) quit:pack=""
			set Res("pkg",pack_".PKG")=$lb("","","","","pkg",pack)
	}
	;TODO add 2 lines for filecopy attributes
	;set Res("filecopy","filecopy1")=$lb("","","","text","filecopy1","")
	;set Res("filecopy","filecopy2")=$lb("","","","text","filecopy2","")
	;set Res("filecopy","filecopy3")=$lb("","","","text","filecopy3","")
	;----------------
	;add default module.xml -------------------
	set attr="01.Name.text,02.Version.text,03.Description.text,04.Keywords.text,05.SourcesRoot.text,06.XML.textarea"
	set type="Application-module"
	set xml = ##class(apptools.core.rest).getStatic("apptools.lte.zapm:module")
	for i=1:1:$l(attr,",") {	set name=$p(attr,",",i)
		if name="" continue
		set comptyp=$p(name,".",3)
		set val="",desc=" "
		if $p(name,".",2)="Name" set val="test"
		if $p(name,".",2)="Version" set val="1.0.0"
		if $p(name,".",2)="Description" set val=""
		if $p(name,".",2)="SourcesRoot" set val="src"
		if $p(name,".",2)="XML" set val=xml,desc="Template" ; desc prop 4    5       6          7
		set Res(type,$p(name,".",1,2))=$lb(desc,"","",comptyp,type,$p(name,".",2),val)
	}
	;-----------------
	set gnpro=$na(@GN@("prototype",ns))
	write $$$appInputHidden(divId_"ModeSet","",mode)
	If mode="edit",##class(%ZPM.PackageManager.Developer.Module).NameExists(zpmname) { ;-------------------
		if '..GetResourcesFromZpm(zpmname,.Module,.Res) quit $$$OK
		do ##class(%ZAPM.ext.zpm).GetListModule(ns,.List,0)
		set dirroot=$lg($G(List(zpmname,"L")),3)
		do ##class(%ZAPM.ext.zpm).GetFileLines(dirroot_"module.xml",.o)
		;w Module.Description
		set Res(type,"01.Name")=##class(apptools.core.code).SetList(Res(type,"01.Name"), 7, Module.Name)
		set Res(type,"02.Version")=##class(apptools.core.code).SetList(Res(type,"02.Version"), 7, Module.VersionString)
		set Res(type,"03.Description")=##class(apptools.core.code).SetList(Res(type,"03.Description"), 7, $zconvert(Module.Description,"O","HTML"))
		set xml=""
		for i=1:1 {	quit:'$d(o(i))
		  	set xml=xml_o(i)_$c(13,10)
		}
		set Res(type,"06.XML")=##class(apptools.core.code).SetList(Res(type,"06.XML"), 7, xml)

	}
	elseIf mode="editpro" { ;-------------------
		merge pro=@gnpro@(zpmname)
		;zw pro
		;zw Res("cls")
		for i=1:1:$l(attr,",") {	set name2=$p($p(attr,",",i),".",1,2)
			set val=$g(pro(type,$p(name2,".",2)))
			if name2["03.Description" set val=$zconvert(val,"O","HTML")
			set Res(type,name2)=##class(apptools.core.code).SetList(Res(type,name2), 7, val)
		}
		set typ=type
		for { set typ=$o(pro(typ)) quit:typ=""
			set item=""
			for { set item=$o(pro(typ,item)) quit:item=""
				set Res(typ,item)=##class(apptools.core.code).SetList($G(Res(typ,item)), 7, 1)
			}
		}
	}
	elseIf mode="new" { ;-------------------
		set Res(type,"01.Name")=##class(apptools.core.code).SetList(Res(type,"01.Name"), 7, DefaultNamePacket)
	}
	
	do ##class(apptools.core.sys).SetTableHeader(gn,"Name","Component","ResoursType","Description","Property")
	set type="",row=0
	
	for  { set type=$o(Res(type)) quit:type=""
		set name=""
		for  { set name=$o(Res(type,name),1,data) quit:name=""
			set comp="checkbox"
			if $lg(data,4)'="" set comp=$lg(data,4)
			set name3=name
			if comp="checkbox" {
				set stat="unchecked" 
				if $lg(data,7) set stat="1" 
				set ch=$i(@ggn)
				set @ggn@(ch)=$lb(type,name)
				set name2=ch
				set webcomp=##class(apptools.core.Form).WebCompShowCheckbox(,,,divId_"Matrx"_name2,stat)
			}
			if comp="text" {
				set val=$lg(data,7)
				set name3=$lg(data,6)
				set webcomp=$$$appText(divId_"Matrx"_name3," size=40 ",val)
			}
			if comp="textarea" {
				set name3=$lg(data,6)
				set val=$lg(data,7)
				set webcomp=$$$appTextarea(divId_"Matrx"_name3," rows=5 cols=42 ",val)
			}
			set row=row+1
			if type="cls"||(type="gbl")||(type="mac") {
				s click="WinOpen('"_$zu(5)_"','"_..%ClassName(1)_"','ResourceWinOpen','~type="_type_"~name="_name3_"~zpmname="_zpmname_"','','"_##class(apptools.core.Action).WriteWinOpenREST(%request)_"');"
				set name3="<a href=""#"" onclick="""_click_""">"_name3_"</a>"
			}
			do ##class(apptools.core.sys).SetTableRow(gn,row,name3,webcomp,type,$lg(data,1),$lg(data,2))
		}
	}
	set st=##class(apptools.core.LogInfoPane).DrawSQL("result "_gn,100000,$zu(5),"IRIS Resources in namespace '"_ns_"'",$g(exec),,1)

	write "</form>"
	quit $$$OK
}

/// Draw Resource in modal window
ClassMethod ResourceWinOpen(Par = "")
{
	;zw Par q 1
	set type=$g(Par("type"))
	set name=$p($g(Par("name")),".",1,*-1)
	set gn="^||tempRes"
	if type="cls" {
		;do ##class(apptools.core.LogInfoPane).GetClassDef(name,,.cls)
		;write "<pre>"
		;zw cls
		;;set i="" for { set i=$o(cls(i)) quit:i=""
		;	;write !,cls(i) 
		;;}
		;write "</pre>"
		set url="/csp/documatic/%25CSP.Documatic.cls?LIBRARY="_$namespace_"&CLASSNAME="_name
		&html<
		<form id="#("ModalMainForm")#">
		<div class="uk-grid">
		    <iframe id="#("ModalMainIFrame")#" width="1500" height="1000" style='overflow: auto;' src='#(url)#' ></iframe>
		    </div>
		</div>
		</form>
		>
	}
	elseif type="mac" {
		write "<pre>"
		merge r=^rMAC(name,0)
		for i=1:1 { quit:'$DATA(r(i),str)
			write !,str 
		}
		 write "</pre>"
	}
	elseif type="gbl" {
		set name="^"_name
		set st=##class(apptools.core.LogInfoPane).DrawArray(name,100000,$zu(5),1," "_name)
	}
	;set st=##class(App.sys).SaveSQL(sql,gn)
	;i 'st w $$$appError($System.Status.GetErrorText(st)) q
	;write "Трансляция дат <pre>" write ..ReplaceHorolog($lg(@gn@(1))) write "</pre>"
}

ClassMethod GetResourcesFromZpm(zpmname, ByRef Module, ByRef Res) As %Status
{
	Set Module = ##class(%ZPM.PackageManager.Developer.Module).NameOpen(zpmname,,.tSC)
	If $$$ISERR(tSC) {	Quit tSC }
	set lo=Module.CalculatedResourcesGet()
	set debug=0 ;
	write:debug "CalculatedResourcesGet="_lo.Size
	for i=1:1:lo.Size {
		set obj=lo.Oref(i)
		set name=obj.Name
		w:debug "<br>----- res-name = "_name
		set typ=$zconvert($p(name,".",*),"L")
		set ProcessorClass=obj.ProcessorClass
		if ProcessorClass="" {
			set itemL=$p(name,".",1,*-1)_"."_typ
			set itemU=$p(name,".",1,*-1)_"."_$zconvert($p(name,".",*),"U")
			if $d(Res(typ,itemL)) {
				set Res(typ,itemL)=##class(apptools.core.code).SetList(Res(typ,itemL), 7, 1)
			}
			elseif $d(Res(typ,itemU)) {
				set Res(typ,itemU)=##class(apptools.core.code).SetList(Res(typ,itemU), 7, 1)
			}
			else {
				set Res(typ,itemU)=##class(apptools.core.code).SetList("", 7, 1)
			}
		}
		else {
			if ProcessorClass="CSPApplication" {
				set att=obj.Attributes
				set key="",cprop=""
				for { set key=att.Next(key) quit:key=""
					w:debug "<br>"_key_"="_att.GetAt(key)
					if key="DispatchClass" set cprop=att.GetAt(key)
					if key="Url" set url=att.GetAt(key)
				}
				set Res(ProcessorClass,url)=##class(apptools.core.code).SetList("", 7, 1)
				set Res(ProcessorClass,url)=##class(apptools.core.code).SetList(Res(ProcessorClass,url), 2, cprop)
			}
			else {	set Res(ProcessorClass,name)=##class(apptools.core.code).SetList("", 7, 1)
			}
		}
	}
 	quit $$$OK
}

/// Get ZPM Modules from Repo
/// do ##class(apptools.lte.resources).GetZPMRepo(.List)
ClassMethod GetZPMRepo(List, FindMask = "") As %Status
{
	
	do ##class(%ZAPM.ext.zpm).GetVerZpm(.IsHspm,.RepoFieldName)	
	set where="(1=1)"
	if "*"'[FindMask set where="name like '"_$replace(FindMask,"*","%")_"'" 
	Set tQuery = "select Name, Version, "_RepoFieldName_", Description from %ZPM_PackageManager_Developer.Utils_GetModuleList('registry') WHERE "_where
	;w !,tQuery
	Set tRes = ##class(%SQL.Statement).%ExecDirect(,tQuery)
	
	If (tRes.%SQLCODE < 0) {
		Throw ##class(%Exception.SQL).CreateFromSQLCODE(tRes.%SQLCODE,tRes.%Message)
	}
	While tRes.%Next(.tSC) {
		$$$ThrowOnError(tSC)
		Set List(tRes.%Get("Name"))=$Listbuild(tRes.%Get("Version"),tRes.%Get("Description"),tRes.%Get("Repository"))
	}
	quit $$$OK
}

/// Get List Modules
/// example d ##class(apptools.lte.resources).GetListModules("zpm",.list)
ClassMethod GetListModules(StartsWith As %String = "", ByRef pList) [ Internal ]
{
	Set tQuery = "select Name,VersionString,Description,ExternalName from %ZPM_PackageManager_Developer.""MODULE"""
	If StartsWith'="" { Set tRes = ##class(%SQL.Statement).%ExecDirect(,tQuery_ " where name %StartsWith ?",StartsWith) }
	Else { Set tRes = ##class(%SQL.Statement).%ExecDirect(,tQuery)}
	If (tRes.%SQLCODE < 0) {
		Throw ##class(%Exception.SQL).CreateFromSQLCODE(tRes.%SQLCODE,tRes.%Message)
	}
	While tRes.%Next(.tSC) {
		$$$ThrowOnError(tSC)
		Set pList(tRes.%Get("Name"))=$lb(tRes.%Get("VersionString"),tRes.%Get("Description"),tRes.%Get("ExternalName"))
		Set:$G(maxlen)<$L(tRes.%Get("Name")) maxlen=$L(tRes.%Get("Name"))
	}
	Set:$D(pList) pList=$G(maxlen)
}

/// Get modules in Namespaces current instance
/// do ##class(apptools.lte.resources).GetZpmNamespaces(.List)
ClassMethod GetZpmNamespaces(ByRef out, text = "", ByRef nspace)
{
	new $Namespace
	Set currentns=$Namespace
	Do ##class(%ZPM.PackageManager).GetListNamespace(.namespace)
	Set ns=""
	For { set ns=$Order(namespace(ns)) Quit:ns=""
		Set $Namespace=ns
		Kill list
		Do ..GetListModules("",.list)
		;w !,ns zw list
		If $D(list) {
			Set module=""
			For { set module=$Order(list(module)) Quit:module=""
				;w !,ns_" - "_module
				if ("@"_module)[("@"_text) merge out(module,ns,module)=list(module) if '$d(nspace) set nspace=ns
			}
		}
	}
	Set $Namespace=currentns
	quit $$$OK
}

}

