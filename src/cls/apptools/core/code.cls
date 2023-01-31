Include apptools.core

/// Fork from https://github.com/intersystems-ru/cache-udl
/// Export different types of modules in different subfolders in UDL (plain) format
/// test.dfi -> /dfi/test.dfi
/// testpkg.test.cls -> /cls/testpkg/test.cls
Class apptools.core.code [ Abstract ]
{

/// Export from docker
/// d ##class(apptools.core.code).exp("/irisrun/repo/chmod777-R/apptools-admin/src/","apptools.","apptools.M")
/// d ##class(apptools.core.code).exp("/irisrun/repo/chmod777-R/zapm/src/","%ZAPM")
ClassMethod exp(dir = "", mask = "", ignoremask = "", ByRef list)
{
 new $namespace
 d ..workdir(dir)
 if $e(mask,1,8)="apptools" set $namespace=$g(^%apptools.Setting("HomeNamespace"))
 if $e(mask,1)="%" set $namespace="%SYS"
 d ..export(,,$e(mask,1)="%",,mask,ignoremask,1,.list)
}

/// import 
/// d ##class(apptools.core.code).imp("/backup/iris/distr/apptools-all/src/xml/")
ClassMethod imp(dir = "", mask = "")
{
 d ..workdir(dir)
 d ..import(mask)
}

/// get or set working directory for export/import source
/// d ##class(apptools.core.code).workdir("/backup/source")
ClassMethod workdir(workdir)
{
	s gln = ..gln() s:$d(workdir) @gln = workdir
	///zu(12) namespace directory by default
	#define nsdir $zu(12,"")
	Q $g(@gln, $$$nsdir)
}

/// export all available code
/// d ##class(apptools.core.code).export(,,,,"apptools.","apptools.M")
/// d ##class(apptools.core.code).export(,,,,"apptools.","apptools.M",1,"/csp/aaa")
ClassMethod export(generated = 0, system = 0, percent = 0, mapped = 0, mask = "", ignoremask = "", ignoredfi = 0, ByRef item)
{

	#define export(%code, %file) try {s sc = $system.OBJ.ExportUDL(%code, %file,"/diffexport")} catch e {s sc=$$$ERROR($$$GeneralError,"Old version")} ##continue
								 w:sc "Ok" d:'sc $system.OBJ.DisplayError(sc)

	#define log w !, code, " -> ", $piece(filename,..workdir(),2), " "
	
	#define mkdir(%filename) ##continue
			s path = ##class(%File).GetDirectory( %filename ) ##continue
			if '##class(%File).DirectoryExists( path ) { ##continue
				s sc = ##class(%File).CreateDirectoryChain( path ) ##continue
				w !, "mkdir ", path, " ", sc ##continue
			}
						
	w "#; Exporting to ", ..workdir(),!
	#; classes
	s rs = ##class(%ResultSet).%New("%Dictionary.ClassDefinition:Summary")
	if rs.Execute() {

		while rs.%Next(){

			s code = rs.Name _ ".cls", isSystem = rs.System
			;w !,code
			if ( 'system && isSystem ) continue
			if ( 'generated && $$$isGenerated( code ) ) continue
			if ( 'percent && $$$isPercented( code ) ) continue
			if ( 'mapped && $$$isMapped( code ) ) continue
			if mask'="",(("@"_code)'[("@"_mask )) continue
			if ignoremask'="",(("@"_code)[("@"_ignoremask )) continue
			
			s filename = ..filename( code )
			$$$mkdir( filename )
			$$$log
			$$$export( code, filename )
			s item(code)=""
		} s rs=""
	}

	#; routines
	s rs = ##class(%ResultSet).%New("%Routine:RoutineList")
	if rs.Execute() {

    	while rs.%Next() {

	 		s code = rs.Name
	 		if ( 'generated && $$$isGenerated( code ) ) continue
	 		if ( 'percent && $$$isPercented( code ) ) continue
			if ( 'mapped && $$$isMapped( code ) ) continue
			if ( '$find( code, mask ) ) continue
			
			s filename = ..filename( code )
			$$$mkdir( filename )
			$$$log
			$$$export( code, filename )
			s item(code)=""
	    } s rs=""
	}


	#; dfi
	#define export(%code,%file) s sc = ##class(%DeepSee.UserLibrary.Utils).%Export( %code, %file, 0 ) 
	if 'ignoredfi {
		s sql = "Select fullName as Name From %DeepSee_UserLibrary.FolderItem"
	    s rs = ##class(%SQL.Statement).%ExecDirect( .stm, sql )
	    while rs.%Next() {
			s code = rs.Name, filename = ..filename( code_".dfi" )
			if ( '$find( code, mask ) ) continue
			if ($L(code,"$TRASH")>1) continue
			$$$mkdir( filename )
			$$$log
			$$$export(code,filename)
			s item(code)=""
		} s rs=""
	}
	w !!, "#; Exported to ", ..workdir()
    Q $$$OK
}

/// import all from workdir
/// d ##class(apptools.core.code).import()
ClassMethod import(filemask = "*.xml;*.cls;*.mac;*.int;*.inc;*.dfi", qspec = "cku-d", ByRef err = "", recurse = 1, ByRef loaded = "", verbose = 1) As %Status
{
	#define push(%dir) s dirs( $i( dirs ) ) = %dir
	#define next(%i,%dir) s %i=$o( dirs( "" ), 1, %dir )  k:%i'="" dirs(%i)
	#define isDirectory(%type) ( %type = "D" )
	#define log w !,filename_" " w:sc "Ok" d:'sc $system.OBJ.DisplayError(sc)
	
	s sc = 1, dirs = "", dir = ..workdir() $$$push(dir)
	if verbose w "#; Importing from ", dir,!
	d ..setIgnore(.fm)
	for { $$$next(i,dir) Q:i=""  Q:dir=""

		s rs = ##class(%File).FileSetFunc( dir, filemask, , 1 )

		while rs.%Next() {
			s filename = rs.Name

			if $$$isDirectory(rs.Type) {
				if recurse $$$push(filename)
				continue
			}
			// check file filter
			if ..inFilter(.fm,filename) continue

			s ext = $p( filename, ".", * )

			if $zcvt( ext, "l" ) = "dfi" {
				s sc = ##class(%DeepSee.UserLibrary.Utils).%Import( filename, 1, 0, 0, "", .dsloaded )
			} else {
				// load classes only
				s sc = $system.OBJ.Load( filename, "k-d", .err, .loaded)
			}

			if verbose $$$log
			
	    }
		// compile all the loaded classes to obey dependencies
		s sc=$system.OBJ.CompileList( .loaded, "cukbr-d/multicompile",.err )
		
	}
	
	if verbose {
	
		if $D(err) {
			s i=$Order(err("")) 
			while i'="" {
			w !,err(i)
			s i=$O(err(i))
			}
		}
		
		w !,!,"#; Imported from ", ..workdir()
		}
	Q sc
}

ClassMethod inFilter(ByRef filtermask, filename) As %Boolean
{
	s result=0
	for 
	{
		if '$d(filtermask($I(i))) quit
		set filter=$piece(filtermask(i),"*")
		if $length(filename,filter)>1 set result=1
	}

	quit result
}

/// get the filtermask for the repository.
/// looks for .gitignore file and applies all the lines to filters
ClassMethod setIgnore(ByRef filtermask)
{
	
	// working with .gitignore file
	// gitignore consists of masks of filtering files
	s filename=..workdir()_"/.gitignore"
	if '##class(%File).Exists(filename) quit
	s file=##class(%File).%New(filename)
	s sc=file.Open("R")
	if 'sc {
		write $System.Status.GetErrorText(sc) return
	}
	While 'file.AtEnd	{
		s filtermask($I(filtermask))=file.ReadLine()
	}
 quit
}

/// gl[obal] n[ame] - storage for settings
ClassMethod gln() [ CodeMode = expression, Private ]
{
"%apptools"
}

ClassMethod init()
{
	#define confile "/cos.json"
	set stream=##class(%Stream.FileCharacter).%New()
	set sc=stream.LinkToFile(..workdir()_$$$confile)
	s conf={}.%FromJSON(stream.Read($$$MaxCacheInt))
	s gln=..gln()
	s @gln@("compileList")=conf.compileList
	s @gln@("projectName")=conf.projectName
	w "compileList="_conf.compileList,!
	w "projectName="_conf.projectName
}

/// export release file for list and project settings
ClassMethod release()
{
	s gln=..gln()
	s list=$G(@gln@("compileList"))
	if list="" w "Nothing to release. Run init method first" quit

	s release=$G(@gln@("projectName"),"release")
	s release=release_$p($zdt($h,8)," ")_$tr($p($p($zdt($h)," ",2),":",1,2),":")_".xml"
	D $System.OBJ.Export(list,release)
	w "All objects with mask "_list_" has been exported to "_release
}

ClassMethod compile()
{
	s gln=..gln()
	s list=$G(@gln@("compileList"))
	if list="" w "Nothing to compile. Run init method first" quit
	d $System.OBJ.compile(list)
}

/// test.dfi -> /dfi/test.dfi
/// test.cls -> /cls/test.cls
/// testpkg.test.cls -> /cls/testpkg/test.cls
/// etc
ClassMethod filename(code)
{
	#define log(%dir,%sc) w:$G(%write) !, "mkdir ", %dir, " ", sc

	s wd = ..workdir()

	if '##class(%File).DirectoryExists( wd ) {
		s sc = ##class(%File).CreateDirectoryChain( wd )
		$$$log(wd,sc)
	}

	set ext = $p( code, ".", * ), ext = $zcvt( ext, "l" )
	#; for each type - different directory
	
	set:ext'="" wd = ##class(%File).NormalizeDirectory( ext, wd )

	#; directory must exist before any call (%File).NormalizeFilename( , wd)
	if '##class(%File).DirectoryExists( wd ) {
		s sc = ##class(%File).CreateDirectoryChain( wd )
		$$$log(wd,sc)
	}

	set filename = ##class(%File).NormalizeFilename( code, wd )
	#; lowercase file extension
	if ext="gbl" set ext="xml"
	set $p(filename,".",*)=ext
	if ext ="cls"||(ext ="inc") {
		set dirs = $piece( code, ".",1, *-2 )
		if dirs'="" {
			set dirs = $translate( dirs, ".", "/" )
			set relpath = dirs _ "/" _ $piece( code, ".", *-1, * ) ;
			;if $p(relpath,".",*)="GBL" set $p(relpath,".",*)="xml"
			set filename = ##class(%File).NormalizeFilename( relpath, wd )
		}
	}
	if $p(filename,".",*)="INC" set filename=$p(filename,".",1,*-1)_".inc"
	Quit filename
}

/// import from workdir all files with ts newer than code ts in db
ClassMethod importUpdated(filemask = "*.*", qspec = "cku-d", ByRef err = "", recurse = 1, ByRef loaded = "", verbose = 1) As %Status
{
	#define push(%dir) s dirs( $i( dirs ) ) = %dir
	#define next(%i,%dir) s %i=$o( dirs( "" ), 1, %dir )  k:%i'="" dirs(%i)
	#define isDirectory(%type) ( %type = "D" )
	#define log w !, $piece(filename,..workdir(),2)," " w:sc "Ok" d:'sc $system.OBJ.DisplayError( sc )

	s sc = 1, dirs = "", dir = ..workdir() $$$push(dir)
	if verbose w "#; Importing updated from ", dir,!
	d ..setIgnore(.fm)
	for { $$$next(i,dir) Q:i=""  Q:dir=""

		s rs = ##class(%File).FileSetFunc( dir, filemask, , 1 )

		while rs.%Next() {
		   s filename = rs.Name

		   if $$$isDirectory( rs.Type ) {
			 if ( recurse ) $$$push(filename) ;push directory
			 continue
		   }

			// check file filter
			if ..inFilter(.fm,filename) continue

		   s filets = rs.DateModified
		   s codename = ..codename( filename, .ext )
		   s codets = ..codets( codename, ext )
		   
		   #; w !, filename, $c(9), "(", filets, ")"
		   #; w !, codename, $c(9), "(", codets, ")"
		   
		   if ( filets '] codets ) continue
			 
		   if ext = "dfi" {

			   s sc = ##class(%DeepSee.UserLibrary.Utils).%Import( filename, 1, 0, 0, "", .loaded )

		   } else {

			   #; drop existing code before import ( purge DateModified )
			   #; s:codets'="" sc = ##class(%RoutineMgr).Delete( codename )
			   k err s sc = $system.OBJ.Load( filename, qspec, .err, .loaded)

		   }

		   if verbose $$$log
	    }
	}
	w:verbose !,"#; Imported updated from ", ..workdir()
	Q sc
}

/// presumable codename
ClassMethod codename(filename, ByRef ext = "")
{
	s ext = $p( filename, ".", * ), ext = $zcvt( ext, "l" )
	s path = ##class(%File).NormalizeDirectory( ext, ..workdir() )
	s codename = $p( filename, path, 2 )
	if ext = "dfi" {
		s fullname  = $tr( codename, "\", "/" ) ; return fullname for dfi in $$$IsWINDOWS
		Q $p( fullname, ".", 1, *-1 ) ;remove extension
	}
	if (ext ="cls")!(ext="int")!(ext="inc")!(ext="mac") s codename=$tr(codename,"\/","..")
	Q codename
}

ClassMethod codets(codename, ext)
{
	s ts = ""
	if ext'="dfi" {
		s ts = ##class(%RoutineMgr).TS( codename )
	} else {
		s sql="Select timeModified From %DeepSee_UserLibrary.FolderItem Where fullname = ?"
		s rs = ##class(%SQL.Statement).%ExecDirect( , sql, codename )
		if rs.%Next() {
			s utcts = rs.timeModified
			s utch = $zdth( utcts, 3, , 3 ) ;utc internal format
			s loch = $zdth( utch, -3 ) ; utc to local timezone
			s ts = $zdt( loch, 3, ,0 ) ; local timestamp*/
		}
	}
	Q $p( ts, "." ) ;remove ms
}

/// Get All Resources
/// do ##class(apptools.core.code).GetResources(,.GN)
ClassMethod GetResources(ns = {$namespace}, ByRef item, flags = "000000") As %Status
{
	new $namespace
	set $namespace=ns
	/*
The items to export.
Each of the items must have a type determined by an extension selected from the following list of basic types, additional types are supported under the abstract routine interface so this list is not exhaustive.

CLS - Classes
CSP - Cache Server Pages
CSR - Cache Rule files
MAC - Macro routines
INT - Non-macro routines
BAS - Basic routines
INC - Include files
GBL - Globals
PRJ - Studio projects
OBJ - Compiled object code
PKG - Package definitions
If exporting multiple items, separate them with commas, pass the items("item")="" as an array. 
You can also use ? or * wild cards and if you wish to exclude items pass ' before the item name which also supports wild card, e.g. "User.*.cls,'User.T*.cls".
set st=$SYSTEM.OBJ.Export(.items, FileName)
	*/
	#; CLS classes
	Set rs = ##class(%ResultSet).%New("%Dictionary.ClassDefinition:Summary")
	set ext= "cls"
	If rs.Execute() {
		While rs.%Next(){
			Set code = rs.Name _ ".cls", isSystem = rs.System
			If ( '$Extract(flags,2) && isSystem ) Continue
			If ( '$Extract(flags,1) && $$$isGenerated( code ) ) Continue
			If ( '$Extract(flags,3) && $$$isPercented( code ) ) Continue
			If ( '$Extract(flags,4) && $$$isMapped( code ) ) Continue
			Set item(ext,code)=""
		} 
	}
	#; routines MAC, INC  ; INT ?
	set rs = ##class(%ResultSet).%New("%Routine:RoutineList")
	if rs.Execute() {
    	while rs.%Next() {
	 		set code = rs.Name
	 		If ( '$e(flags,1) && $$$isGenerated( code ) ) Continue
	 		If ( '$e(flags,3) && $$$isPercented( code ) ) Continue
			If ( '$e(flags,4) && $$$isMapped( code ) ) Continue
			set ext = $p( code, ".", * ),ext = $zcvt( ext, "l" )
			if ext="int" continue
			set item(ext,code)=""
	    } 
	}
	
	#; dfi
	If $Extract(flags,5) {
		set ext= "dfi"
		Set sql = "Select fullName as Name From %DeepSee_UserLibrary.FolderItem"
	    Set rs = ##class(%SQL.Statement).%ExecDirect( .stm, sql )
	    While rs.%Next() {
			Set code = rs.Name
			If ($Length(code,"$TRASH")>1) Continue
			Set item(ext,code)=""
		} 
	}
	#; web application
	set ext="CSPApplication"
	do ..GetListApps(ns,.list)
	set app=""
	for { set app=$o(list(app)) quit:app=""
		Set item(ext,app)=$lb($G(list(app,"Description")),$G(list(app,"DispatchClass")))
	}
	#; GBL
	set ext= "gbl"
	do ##class(apptools.core.sys).GlobalList(ns,.glo,$Extract(flags,3),$Extract(flags,4))
	set i=""
	for { set i=$o(glo(i)) quit:i=""
		if $p(i,".")="ZPM" continue
		if $e(i,1,3)="Ens" continue
		Set item(ext,i_".GBL")=""
	}
}

/// do ##class(apptools.core.code).GetListApps("aaa",.list)
ClassMethod GetListApps(sourcedb, ByRef list) As %Status
{
	new $namespace
	set $namespace="%SYS"
	set result=##CLASS(%ResultSet).%New("%DynamicQuery:SQL")
	set tSC=result.Prepare("select NameLowerCase FROM Security.Applications where NameSpace=?")
	set:tSC tSC=result.Execute($zconvert(sourcedb,"U"))
	if '$$$ISOK(tSC) {
		set text="Application setup error :"_$SYSTEM.Status.GetErrorText(tSC)  write !,text QUIT $$$ERROR(text)
	}
	else {
		while result.Next() {
			set name=result.Data("NameLowerCase")
			set tSC=##class(Security.Applications).Get(name,.prop)
			merge list(name)=prop
		}
	}
}

/// zw ##class(apptools.core.code).SetList($lb(2,3,4), 2, "val")
ClassMethod SetList(list, pos, val) As %Status
{
	set str=$lts(list,$c(0,1,2))
	set $p(str,$c(0,1,2),pos)=val
	quit $lfs(str,$c(0,1,2))
}

/// do ##class(apptools.core.code).ExportOneResource("/backup/repo-iris-test-iris20203/new-pack",,"community.PKG",.app)
/// byte=1 isGenerated
/// byte=2 isSystem
/// byte=3 isPercented
/// byte=4 isMapped
/// byte=5 isDFI
ClassMethod ExportOneResource(dir, flags = "00000", code = "", ByRef item)
{
	#define export(%code, %file) try {s sc = $system.OBJ.ExportUDL(%code, %file,"/diffexport")} catch e {s sc=$$$ERROR($$$GeneralError,"Old version")} ##continue
								 w:sc&($G(%write)) "Ok" d:'sc $system.OBJ.DisplayError(sc)
	#define log w:$G(%write) !, code, " -> ", $piece(filename,..workdir(),2), " "
	
	#define mkdir(%filename) ##continue
			s path = ##class(%File).GetDirectory( %filename ) ##continue
			if '##class(%File).DirectoryExists( path ) { ##continue
				s sc = ##class(%File).CreateDirectoryChain( path ) ##continue
				w:$G(%write) !, "mkdir ", path, " ", sc ##continue
			}
	do ..workdir(dir)
	write:$G(%write) "#; Exporting to ", dir,!
	set EXT=$zconvert($p(code,".",*),"U")
	set mask=$p(code,".",1,*-1)
	if EXT="PKG"||(EXT="") {
		#; classes
		set rs = ##class(%ResultSet).%New("%Dictionary.ClassDefinition:Summary")
		if rs.Execute() {
			while rs.%Next(){
				set code = rs.Name _ ".cls", isSystem = rs.System
				;w !,code
				If ( '$Extract(flags,2) && isSystem ) Continue
				If ( '$Extract(flags,1) && $$$isGenerated( code ) ) Continue
				If ( '$Extract(flags,3) && $$$isPercented( code ) ) Continue
				If ( '$Extract(flags,4) && $$$isMapped( code ) ) Continue
				if mask'="",(("@"_code)'[("@"_mask )) continue
				set filename = ..filename( code )
				$$$mkdir( filename )
				$$$log
				$$$export( code, filename )
				set item(code)=""
			}
		}
	}
	elseif EXT="CLS" {
		set filename = ..filename(code)
		$$$mkdir( filename )
		$$$log
		$$$export( code, filename )
		set item(code)=""
	}
	elseif EXT="INC" {
		set filename = ..filename(code)
		$$$mkdir( filename )
		$$$log
		$$$export( code, filename )
		set item(code)=""
	}
	elseif EXT="GBL" {
		set filename = ..filename(code)
		$$$mkdir( filename )
		$$$log
		set arr(code)=""
		Write $SYSTEM.OBJ.Export(.arr, filename)
	}
	quit $$$OK
}

/// do ##class(apptools.core.code).DrawNS4vc()
ClassMethod DrawNS4vc(name = {$zu(110)})
{
	set listns= ##class(apptools.core.sys).ListNS(.info)
    set ns=""
    	write !," {"
      	write !,"   ""name"": """_name_""","
      	write !,"   ""path"": ""."","
      	write !," },"
    for { set ns=$o(info(ns)) quit:ns=""  
    	write !,"    {"
      	write !,"      ""uri"": ""isfs://"_name_"?ns="_ns_""","
      	write !,"      ""name"": """_ns_""","
      	write !,"    },"
     }
     quit $$$OK
}

}

