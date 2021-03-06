Include apptools.core

/// Export different types of modules in different subfolders in UDL (plain) format
/// test.dfi -> /dfi/test.dfi
/// testpkg.test.cls -> /cls/testpkg/test.cls
/// Fork from https://github.com/intersystems-ru/cache-udl
Class apptools.core.code [ Abstract ]
{

/// d ##class(apptools.core.code).exp("/backup/source/apptools/","apptools.core")
ClassMethod exp(dir = "", mask = "", ignoremask = "", ByRef list)
{
 d ..workdir(dir)
 d ..export(,,,,mask,ignoremask,1,.list)
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

	#define isGenerated(%code) ##class(%RoutineMgr).IsGenerated( %code )
	#define isPercented(%code) ("%" = $e(%code))
	#define isMapped(%code) ##class(%RoutineMgr).IsMapped( %code )
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
	if 'sc 
	{
		if verbose d $System.OBJ.DisplayError(sc) return
	}

	While 'file.AtEnd
	{
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
	#define log(%dir,%sc) w !, "mkdir ", %dir, " ", sc

	s wd = ..workdir()

	if '##class(%File).DirectoryExists( wd ) {
		s sc = ##class(%File).CreateDirectoryChain( wd )
		$$$log(wd,sc)
	}

	s ext = $p( code, ".", * ), ext = $zcvt( ext, "l" )
	#; for each type - different directory

	s:ext'="" wd = ##class(%File).NormalizeDirectory( ext, wd )

	#; directory must exist before any call (%File).NormalizeFilename( , wd)
	if '##class(%File).DirectoryExists( wd ) {
		s sc = ##class(%File).CreateDirectoryChain( wd )
		$$$log(wd,sc)
	}

	s filename = ##class(%File).NormalizeFilename( code, wd )
	#; lowercase file extension
	s $p(filename,".",*)=ext
	//B:code="DPRep.Rest.JSON.cls" "L"
	#; for *.cls Package.Subpackage.ClassName.cls -> Folder/Subfolder/ClassName.cls
	if ext ="cls" {
		s dirs = $piece( code, ".",1, *-2 ), dirs = $translate( dirs, ".", "/" )
		s relpath = dirs _ "/" _ $piece( code, ".", *-1, * ) ;
		s filename = ##class(%File).NormalizeFilename( relpath, wd )
	}
	Q filename
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

}

