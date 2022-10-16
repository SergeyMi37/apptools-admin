Include apptools.core

/// JSON utility
Class apptools.core.jdbc [ Abstract ]
{

/// module for viewing objects
ClassMethod ExportView(%appTmp) As %Status
{
	write:$g(%appClassSave) !
	write !,$g(%appClass)_". "_$g(%appClassProp)_" = "_$g(%appClassPropVal) ;_" type:"_$g(%appClassPropType) ;_" "_$g(%appClassSave)_" "_$g(%appTmp)_" "_$g(%appClassPropSet)
	set %appClassPropSet=0 ;don't assign a property with that name
	set %appClassSave=0 ;don't save an instance of the class
	quit $$$OK
}

/// Field filtering module for export to private repositories. Accounts and password do not change.
ClassMethod SQLForPrivateRegistry(%appTmp) As %Status
{
	quit $$$OK
}

/// Field filtering module for export to public repositories. Settings, names and accounts are changed to default and the password is changed to empty.
ClassMethod SQLForPublicRegistry(%appTmp) As %Status
{
	if %appClassProp="classpath",%appClassPropVal'="" {
		if $d(%appTemp(%appClassPropVal)) set %appClassSave=0 quit $$$OK ;Already exported, skip
		set %appTemp(%appClassPropVal)=""
	}
	if %appClassProp="URL" {
		if %appClassPropVal["jdbc:sqlserver://" set %appClassPropVal="jdbc:sqlserver://ip address:port;databaseName=default_db"
		if %appClassPropVal["jdbc:oracle:" set %appClassPropVal="jdbc:oracle:thin:@(DESCRIPTION_...)"
		if %appClassPropVal["jdbc:mysql://" set %appClassPropVal="jdbc:mysql://ip address:port/databaseName?serverTimezone=UTC"
		if %appClassPropVal["jdbc:postgresql://" set %appClassPropVal="jdbc:postgresql://postgres:5432/"
	}
	if %appClassProp="Name" set %appClassPropVal="NameConnection"_$$GetDbName()_$i(%appInc)
	if %appClassProp="pwd" set %appClassPropVal=""
	if %appClassProp="Usr" set %appClassPropVal="UserName"_$$GetDbName()
GetDbName()
	if %appObj.URL["jdbc:sqlserver" quit "MsSQL"
	if %appObj.URL["jdbc:oracle:" quit "Oracle"
	if %appObj.URL["jdbc:mysql://" quit "MySQL"
	if %appObj.URL["jdbc:postgresql://" quit "Postgresql"
	quit ""
}

/// Sample Import
ClassMethod ImportSQLConnection(zpmname = "", sourcedir = "", ByRef json) As %Status
{
	set st=$$$OK
	if $namespace'="%SYS" set msg="This project needs to be installed in the %SYS namespace" write !,msg quit $$$ERROR($$$GeneralError,msg)
	if sourcedir="" { 
		set sourcedir=##class(%File).NormalizeDirectory("lib\jdbc\", ##class(%File).GetDirectory($zu(86)))
		//found directory for zpmname
		;if zpmname="" set zpmname = "appmsw-gateway-sql"
		;find a path named zpm 
		;Set tTargetDirectory = ##class(%File).ManagerDirectory()_".modules\"_$Namespace_"\"_zpmname_"\1.0.0\"
		;Set tTargetDirectory = ##class(%File).NormalizeDirectory(tTargetDirectory)
		;if '##class(%File).DirectoryExists(tTargetDirectory) set msg="The directory '"_tTargetDirectory_"' does not exist. Specify the full path of the projectas as the second parameter. %SYS>do ##class(appmsw.gateway.jdbc).ImportSQLConnection(,""path of the project"")" write !,msg quit $$$ERROR($$$GeneralError,msg)
	}
	if sourcedir="" set msg="installation path not found" write !,msg quit $$$ERROR($$$GeneralError,msg)
	
	set jsonfile=sourcedir_"gateways.json"
	set exec="##class(appmsw.gateway.jdbc).ImportChange($lb("""_sourcedir_"""))"
	;set exec="##class(appmsw.gateway.jdbc).ImportView()"
	set st=..ImportSelect(jsonfile,.json,exec)
	quit st
}

/// ;export
/// set exec="##class(apptools.core.jdbc).SQLForPublicRegistry()"  do ##class(apptools.core.jdbc).ExportSQLConnection("/tmp/zpm-gateway-publ-oracle/",.js,$Get(exec)) write ##class(apptools.core.json).Pretty($g(js))
/// set exec="##class(apptools.core.jdbc).SQLForPublicRegistry()"  do ##class(apptools.core.jdbc).ExportSQLConnection("/tmp/zpm-gateway-publ-sql/",.js,$Get(exec)) write ##class(apptools.core.json).Pretty($g(js))
/// set exec="##class(apptools.core.jdbc).SQLForPublicRegistry()"  do ##class(apptools.core.jdbc).ExportSQLConnection("/tmp/zpm-gateway-publ-mysql/",.js,$Get(exec)) write ##class(apptools.core.json).Pretty($g(js))
/// set exec="##class(apptools.core.jdbc).SQLForPublicRegistry()"  do ##class(apptools.core.jdbc).ExportSQLConnection("/tmp/zpm-gateway-publ/",.js,$Get(exec)) write ##class(apptools.core.json).Pretty($g(js))
/// set exec="##class(apptools.core.jdbc).SQLForPrivateRegistry()"  do ##class(apptools.core.jdbc).ExportSQLConnection("/tmp/zpm-gateway=private/",.js,$Get(exec)) write ##class(apptools.core.json).Pretty($g(js))
/// ;show only
/// set exec="##class(apptools.core.jdbc).ExportView()" do ##class(apptools.core.jdbc).ExportSQLConnection("/tmp/zpm-gateway/",.js,$Get(exec)) write ##class(apptools.core.json).Pretty($g(js))
ClassMethod ExportSQLConnection(targetdir = "", ByRef json, exec = "") As %Status
{
	set st=$$$OK
	set sql="select * FROM %Library.sys_SQLConnection WHERE (1=1)"
	Set jsonarray=##class(%DynamicArray).%New()
	set numb=""
	if sql'="" {
		set myQuery = ##CLASS(%ResultSet).%New("%DynamicQuery:SQL")
		set st=myQuery.Prepare(sql)
		if 'st quit st
		set st=myQuery.Execute()
		if 'st quit st
		set ColCount=myQuery.GetColumnCount()
		set menu=0
		while (myQuery.Next()) {
			set id=myQuery.Get("ID")
			set Name=myQuery.Get("Connection_Name")
			set classpath=myQuery.Get("classpath")
			set menu=menu+1
			write !,menu,". ",$j("",2-$l(menu)),Name,$j("",30-$l(Name)),classpath
			set menu(menu)=$lb(Name,classpath,myQuery.Get("DSN"),myQuery.Get("driver"),myQuery.Get("URL"))
			set numb=numb_menu_","
		}
	}
	write !!,"Select numbers separated by commas or * all >" read numbers
	if numbers="" write "Nothing selected" quit $$$OK
	if numbers="*" set numbers=numb
	Set tTargetDir = ##class(%Library.File).SubDirectoryName(targetdir,"jdbc",1)
	Kill %objlasterror
	Set tSC = ##class(%ZPM.PackageManager.Developer.File).CreateDirectoryChain(tTargetDir)
	Set tTargetSrc = ##class(%Library.File).SubDirectoryName(targetdir,"src",1)
	Kill %objlasterror
	Set tSC = ##class(%ZPM.PackageManager.Developer.File).CreateDirectoryChain(tTargetSrc)
	$$$ThrowOnError(tSC)
	do ##class(apptools.core.code).exp(tTargetSrc,"appmsw.gateway.jdbc")
	write !,tTargetDir
	set in="",desc=""
	for i=1:1:$l(numbers,",") { set num=$p(numbers,",",i)
		continue:num=""
		if '$d(menu(num),data),num'="*" continue
		set in=in_"'"_$lg(data,1)_"',"
		set filesjar=$lg(data,2)
		if filesjar'="" {
			set filename=$p(filesjar,"/",*)
			Set tCopied = ##class(%Library.File).CopyFile(filesjar,tTargetDir_filename,1,.tOSError)
			set:'$d(filename(filename)) desc=desc_filename_", " ;$lg(data,3)_", " ;_$lg(data,4)_" "_$lg(data,5)_", " 
			set filename(filename)=""
			set count=$g(count)+1
		}
	}
	set sql=$replace(sql,"(1=1)","Connection_Name in ("_$e(in,1,*-1)_")")
	KILL %appInc
	set st=##class(apptools.core.json).ExportClassInstances("%Library.SQLConnection",sql,tTargetDir_"gateways.json",.json,$g(exec),1)
	
	set xml = ##class(apptools.core.rest).getStatic("apptools.core.jdbc:module")
	set namezpm="appmsw-gateway-"_$s(numbers=numb:"sql",1:$tr(filename,".","-"))
	set xml = $replace(xml,"*name",namezpm)
	set xml = $replace(xml,"*proj",namezpm)
	set xml = $replace(xml,"*desc","Installation SQL Gateway Connections. Class path: "_$e(desc,1,*-2))
	set xml = $replace(xml,"*after","&#13; %SYS>do ##class(appmsw.gateway.jdbc).ImportSQLConnection()")
	set xml = $replace(xml,"*aftview","&#13; %SYS>do ##class(appmsw.gateway.jdbc).ImportSQLConnection(""view"")")

	set stream = ##class(%Stream.TmpCharacter).%New()
	do stream.Write(xml)
	s File = ##class(%Stream.FileCharacter).%New()
	s File.TranslateTable="UTF8"
	s File.Filename=targetdir_"module.xml"
	s st=File.CopyFromAndSave(stream)
	quit st
}

/// set xml = ##class(apptools.core.rest).getStatic("apptools.core.json:module")
XData module [ MimeType = application/yaml ]
{
<?xml version="1.0" encoding="UTF-8"?>
<Export generator="Cache" version="25">
  <Document name="*name.ZPM">
    <Module>
      <Name>*name</Name>
      <Version>1.0.0</Version>
      <Description>*desc</Description>
      <Keywords>jdbc</Keywords>
      <Author>
		<Person>Mikhaylenko Sergey</Person>
		<CopyrightDate>2022</CopyrightDate>
		<License>MIT</License>
		<Notes>
		repository:
		https://github.com/SergeyMi37/*proj
		description:
		*desc.
		</Notes>
	  </Author>
      <Packaging>module</Packaging>
      <Resource Directory="cls" Name="appmsw.gateway.jdbc.CLS"/>
	  <FileCopy Name="jdbc" Target="${libdir}jdbc/"/>
      <FileCopy Name="gateways.json" Target="${libdir}jdbc/gateways.json"/>
      <SourcesRoot>src</SourcesRoot>
      <AfterInstallMessage>
&#13; You can see what instances of the %Library.SQLConnection class are in the module by running a command in the %SYS namespace:
*aftview

&#13; You can import a class %Library.SQLConnection instance in the %SYS namespace with the command:
*after
	 </AfterInstallMessage>
    </Module>
  </Document>
</Export>
}

}

