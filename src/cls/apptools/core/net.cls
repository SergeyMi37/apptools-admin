Include apptools.core

/// Network Utility %Net.HttpRequest, %Net.SMTP, %Net.FTP
Class apptools.core.net [ Abstract, DependsOn = apptools.core.msg ]
{

/// Zip files and Send to email
/// w ##class(apptools.core.net).SendFilesToEmail()
ClassMethod SendFilesToEmail(subj, text, files, zip = 1, email = "") As %Status
{
	;send files to email
	set f="" for { s f=$o(files(f)) quit:f=""
		set path=$p(f,$$$slash,1,*-1)
		set file=$p(f,$$$slash,*)
		if zip {
			set sc=##class(apptools.core.files).zipFile(path,file,file_".zip",path)
			if sc {s file=file_".zip" 
			}
			if 'sc s $$$AppL("MSW","SendFilesToEmail-ErrZip")=$System.Status.GetErrorText(sc) 
		}
		set filez($i(fil),"path")=path_$$$slash
		set filez(fil)=file
	}	
	set sc=##class(apptools.core.LogInfo).SendEmail(email, subj, text, .filez)
	if 'sc s $$$AppL("MSW","SendFilesToEmail-ErrSend")=$System.Status.GetErrorText(sc) 
	quit sc
}

/// To send email
/// subscrible - a comma separated list whom to send the letter
/// subj - subject
/// text - the text of the letter
/// attach - an array of files the link
/// samples write ##class(apptools.core.net).SendMail(server, port, ssl, UseSTARTTLS, timezone, username, psw, from, subscrible, subj, text, attach)
ClassMethod SendMail(server, port, ssl, UseSTARTTLS, timezone, username, psw, from, subscrible, subj, text, attach) As %Status
{
 #dim smtp As %Net.SMTP
 #; Define SMTP server for sending
 set smtp=##class(%Net.SMTP).%New()
 set smtp.smtpserver=server
 set:port smtp.port=port
 set:ssl||(port=465) smtp.SSLConfiguration=..CheckSSLCertificate("SSL4SMTP")
 set:UseSTARTTLS smtp.UseSTARTTLS=1
 set smtp.timezone=timezone
 if username'="" {
	;set username="mihaylenko_sv@mosvodokanal.ru",psw="S307^asu2rp" w !,username," ",psw
	set auth=##class(%Net.Authenticator).%New()
	set auth.UserName=username
	set auth.Password=psw
	set smtp.authenticator=auth
	
 }
 try {set smtp.IgnoreFailedAuth = 1 } catch e {} //after version 2021.2
 set smtp.timezone=$g(timezone,"0300")  ;Timezone by Grinwitch  +3 russia
 set mail=##class(%Net.MailMessage).%New() 
 set mail.From=$G(from)        ##; From 
 ##; List of emails to send this mail
 for i=1:1 {
	 q:$p(subscrible,",",i,i+1)=""  
	 set to=$p(subscrible,",",i) 
	 if to'="" do mail.To.Insert(to)
 }
 set mail.Subject=$s($g(subj)="":$g(Subj),1:$g(subj))     ; Subject - the subject
 set mail.Charset="windows-1251"
 set mail.IsHTML=$s(text["<html":1,1:0)
 set mail.IsMultiPart=1
 set mail.MultiPartType="related" 
 do mail.TextData.Write(text)
 set sc=$$$OK
 ; If a single file is transmitted in text format $lb
 if $g(attach)'="" {
	 set attach(1)=$lg(attach,2)
	 set attach(1,"path")=$lg(attach,1)
	 set:$lg(attach,3)'="" attach(1,"content-type")=$lg(attach,3) ;image/jpeg
 }
 ; A lot of files
 if $d(attach)>1 {
	set rec="" 
	for { s rec=$o(attach(rec),1,file) quit:rec=""
	 set sc=mail.AttachFile($g(attach(rec,"path")),file) ;  C:\!\","utl.zip")
	 if $$$ISERR(sc) q
	 set part=mail.Parts.GetAt(rec)
	 do part.Headers.SetAt(file,"Content-ID")
	 do part.Headers.SetAt($g(attach(rec,"content-type")),"Content-Type")
	}
 }
 if $$$ISERR(sc) quit sc ;##class(%Library.Status).LogicalToOdbc(sc)
 set sc=smtp.Send(mail) 
 if $$$ISERR(sc) quit sc ;##class(%Library.Status).LogicalToOdbc(sc)
 quit $$$OK
}

/// Download the file and put on the server by adding the name of the mark date and time
ClassMethod LoadFileHttp(aURL = "", aDATA, TempDir = "", fileName) As %Status
{
	s st=##class(apptools.core.net).GetHttp(aURL,.aDATA)
	i 'st q st
	i $g(aDATA("status"))'=200 q $$$ERROR($$$GeneralError,"Status HTTP "_$g(aDATA("status")))
	s sc=1
	i TempDir'="" s sc=##class(apptools.core.files).Stream2Log(aDATA("content"), TempDir, fileName,.path) s aDATA("pathfileName")=$g(path)
	q sc
}

/// if ##class(apptools.core.net).GetResult("http://localhost/apptoolsrest/productslist/-","user","pass",.json) do json.%ToJSON()
ClassMethod GetResult(url As %String, user = "", pass = "", ByRef result As %ZEN.proxyObject)
{
	$$$TOE(sc, ..GetHttp(url, .aData,,,user,pass))  
	set stream =  aData("content")
	quit ##class(Ens.Util.JSON).JSONStreamToObject(stream,.result)
}

/// To receive from the data server at the URL
/// If TempDir is specified, then the file will be written there 
/// w ##class(apptools.core.net).GetHttp("https://codeload.github.com/SergeyMi37/cache-iris-app-tools/zip/master",.out2,"D:\temp\")
ClassMethod GetHttp(aURL = "", aDATA, TempDir = "", tmpGN = "", user = "", pass = "", ByRef HttpRequest = "") As %Status
{
	set part1=$p(aURL,"/",3),part2=$p(aURL,"/",4,$l(aURL,"/")),params=$p(aURL,"?",2)
	#; Server
	set server=$p(part1,":",1) quit:(server="") $$$ERROR($$$GeneralError,"0:"_$$$aText("no server",""))
	#; Port
	set port=$p(part1,":",2)
	#; Address
	set location=$p(part2,"?",1) quit:(location="") $$$ERROR($$$GeneralError,"0:"_$$$aText("missing address","")_" - "_location)
	#; Create HTTP request to download the file
	if '$iso(HttpRequest) set HttpRequest=##class(%Net.HttpRequest).%New()
	set HttpRequest.Server=server
	if $f($zcvt(aURL,"L"),"https://") {
		set:(port="") port=443
		set HttpRequest.Https=1
		;set HttpRequest.FollowRedirect = 1
		set HttpRequest.SSLConfiguration=..CheckSSLCertificate("DefaultSSL")
	
	#; Request HTTP
	} else {
		s:(port="") port=80
	}
	 do ..SetProxy(.HttpRequest)
	;w !,server,!,location,!,port,!,params
	set HttpRequest.Port=port

	if user'="" {
		set HttpRequest.Username=user
		set HttpRequest.Password=pass
	}

	#; Fill in the parameters
	for i=1:1:$l(params,"&") { s pair=$p(params,"&",i),name=$p(pair,"=",1),value=$p(pair,"=",2)
		continue:(name="")	
		;Conversion, to prevent double conversion
		s value=$zcvt(value,"I","URL") 
		d HttpRequest.SetParam(name,value)
	} ; /for i
	
	#; Execute the query
	Try { d HttpRequest.Get(location) } Catch Error { s err=Error.AsSystemError() }
	quit:($g(err)'="") $$$ERROR($$$GeneralError,err)
	#; The processed response is received
	set HttpResponse=HttpRequest.HttpResponse 
	quit:('$isobject(HttpResponse)) $$$ERROR($$$GeneralError,$$$aText("the server does not return a response",""))
	quit:(HttpResponse.StatusCode'=200) $$$ERROR($$$GeneralError,HttpResponse.ReasonPhrase)
	set aDATA("status")=HttpResponse.StatusCode
	#; Parse the response from the server, keeping the structure of the aDATA
	set aDATA("contentType")=HttpResponse.ContentType
	#; The name of the file received via the "content-disposition" as "attachment;filename="name.ext";"
	set fileName=HttpResponse.GetHeader("content-disposition")
	set aDATA("content-disposition")=fileName
	if ($l(fileName,"*=utf-8''")>1) {
		set fileName=$p(fileName,"*=utf-8''",2)
		set fileName=##CLASS(%CSP.Page).UnescapeURL(fileName)
		set fileName=$zcvt(fileName,"I","UTF8")
	} else { s fileName=$p(fileName,"filename=",2),fileName=$tr($p(fileName,";",1),"""'","") }
	
	#; If the file name is not specified, use as the name of the piece of the link
	set:(fileName="") fileName=$p(location,"/",$l(location,"/"))
	set aDATA("content")=HttpResponse.Data
	set aDATA("fileName")=$zcvt(fileName,"I","URL")
	if tmpGN'="" M @tmpGN=aDATA
	set sc=1
	if TempDir'="" s sc=##class(apptools.core.files).Stream2Log(HttpResponse.Data, TempDir, fileName,.path) s aDATA("pathfileName")=$g(path)
	quit sc
}

/// The method checks for the existence of the configured SSL configuration
/// and creates an empty configuration with that name if this yet
/// to connect to a https server, that's enough
ClassMethod CheckSSLCertificate(name) As %String
{
  NEW $NAMESPACE
  SET $NAMESPACE = "%SYS"
  
  IF '##class(Security.SSLConfigs).Exists(name) {
    DO ##class(Security.SSLConfigs).Create(name)
  }
  QUIT name
}

/// To response to Http Post request
ClassMethod PostHttp(ServerPort, method, user, pass, ByRef body, ByRef out) As %String
{
    set ht = ##class(%Net.HttpRequest).%New()
	set ht.Server = $p(ServerPort,":")
	if user'="" {
		set ht.Username=user
		set ht.Password=pass
	}
	s ht.ContentType="text/html;  charset=UTF-8"
	if $g(body)["{" s ht.ContentType="application/json; charset=UTF-8"
	set port=$p(ServerPort,":",2)
	i $p(ServerPort,":",2)'="" set ht.Port = port
	
	if port=443 {
		set ht.Https=1
		;set ht.Port = 443
		set ht.SSLConfiguration=..CheckSSLCertificate("DefaultSSL")
	}
	do ..SetProxy(.ht)
	if $g(body)["{" {
		set json=##class(%Library.DynamicAbstractObject).%FromJSON($g(body))
		Do ht.EntityBody.Write(json)
	}
	elseif $g(body)'="" {
		Do ht.EntityBody.Write($g(body))
	}
	if $d(body)>1 s i="" f  s i=$o(body(i)) q:i=""  Do ht.EntityBody.Write(body(i))
	
	s st=ht.Post(method)
	if 'st w !,$System.Status.GetErrorText(st)  q ""

	;Do ht.HttpResponse.OutputToDevice()
	S out=ht.HttpResponse.StatusLine
	;s ^z1=ht.HttpResponse.ContentLength
    set i="" for  S i=ht.HttpResponse.GetNextHeader(i) Q:i=""  S out("Header",i)=ht.HttpResponse.GetHeader(i)
    if ht.HttpResponse.Data.Size>0 {
	    set sc=##class(apptools.core.files).Stream2String(ht.HttpResponse.Data,.json)
	    m out("Data")=json
	}
 	do ht.%Close()
 	q $g(out)
}

/// d ##class(apptools.core.net).RunPage()
ClassMethod RunPage(Url As %String = "http://intersystems.ru")
{
    #Include %occOptions
    Set Browser = $s($$$isWINDOWS:"start", $$$isUNIX:"x-www-browser", 1:"x-www-browser")
    Set Command = Browser _ " " _ Url
    Do $ZF(-1, Command)
}

/// Import CSP-file from GitHub repository for 7z utility 
/// s repo="cache-iris-app-tools" d ##class(apptools.core.net).ImportCSPFromGitHub("https://codeload.github.com/SergeyMi37/"_repo_"/zip/master",repo,"d:\!\csptest")
ClassMethod ImportCSPFromGitHub(url, repo, target)
{
	s tempdir=$zu(12)_"Temp"_$$$slash_$p(##class(%File).TempFilename("zip"),$$$slash,*)
	w !,tempdir
	s st=##class(%File).CreateDirectory(tempdir)
	i 'st q st
 	s st=##class(apptools.core.net).GetHttp(url,.out,tempdir)
	s unzip=$zu(12)_"Temp"_$$$slash_$p(##class(%File).TempFilename("unzip"),$$$slash,*)
	s st=##class(%File).CreateDirectory(unzip)
	i 'st q st
	d ##class(apptools.core.files).UnzipToDirectory(tempdir_$$$slash_repo_"-master.zip",unzip)
	s source=unzip_$$$slash_repo_"-master"_$$$slash_"src"_$$$slash_"csp"
	w !,source_" copy to "_target,!
	s st=##class(%File).CopyDir(source,target,1,1,1)
	i 'st w !,st
	s source=unzip_$$$slash_repo_"-master"_$$$slash_"src"_$$$slash_"glb"_$$$slash_"appcachemsg.xml"
	do $system.OBJ.Load(source,"ck")
	d ##class(%File).RemoveDirectoryTree(tempdir)
	d ##class(%File).RemoveDirectoryTree(unzip)
	q $$$OK
}

///  d ##class(apptools.core.net).GetMailPOP3()
ClassMethod GetMailPOP3(MDEAM, BSmName, BSmPass, MASS, dir) As %String
{
 ;MDEAM - MAIL SERVER NAME OR ITS IP
 ;,BSmName - USER NAME = "NAME_user@"_MDEAM
 ;,BSmPass - USER PASSWORD
 ;,MASS - THE ARRAY FROM WHICH TO CREATE THE PROGRAM, WHICH WILL BE BASED ON A LIST OF EMAILS
 ;dir - the PATH TO the DIRECTORY WHERE you DOWNLOADED the attached FILES
 ;new mailserver,status,from,to,date,subject,messagesize,m,hdrs,key,mailMsg,lined
 ;N mssg
 set mailserver=##class(%Net.POP3).%New()
 I $D(dir) set mailserver.AttachDir=dir
 set mailserver.Debug=0
 set mailserver.port=25
 set mailserver.StoreAttachToFile=1
 set status=mailserver.Connect(MDEAM,BSmName,BSmPass)
 if ('status) w !,$System.Status.GetErrorText(status) g clo
 f mssg=1:1 d  if ('status) Q
 .set status=mailserver.FetchMessage(mssg,.from,.to,.date,.subject,.messagesize,.hdrs,.mailMsg,0)
 .if ('status) Q
 .S MASS(mssg,"subject")=subject
 .S MASS(mssg,"date")=date
 .S MASS(mssg,"from")=from
 .S MASS(mssg,"messagesize")=messagesize
 .S MASS(mssg,"to")=to
 .K MAS
 .d Dump(mailMsg,.MAS)
 .M MASS(mssg,"z")=MAS
 .s status=mailMsg.%Close()
clo s status=mailserver.%Close()
	i 'status w !,$System.Status.GetErrorText(status)
 q $G(mssg)-1
 
Dump(msg,MASS) 
 ;new i,index,value
 if msg.IsMultiPart do  quit
 . for i=1:1:msg.Parts.Count() do Dump(msg.Parts.GetAt(i),.MASS)
 s index=""  f  s value=msg.Headers.GetNext(.index) q:index=""  S MASS(msg,"head",index)=value
 if msg.IsBinary do
 . S MASS(msg,"msg")="binary"
 . S MASS(msg,"msgFN")=msg.FileName
 . S MASS(msg,"msgGA")=msg.GetAttribute("content-disposition","filename")
 else  do
 . ;w !,"Dumping text msg Filename="_msg.FileName_" filename="_msg.GetAttribute("content-disposition","filename"),!
 . S MASS(msg,"msg")="text"
 . S MASS(msg,"msgFN")=msg.FileName
 . S MASS(msg,"msgGA")=msg.GetAttribute("content-disposition","filename")
 . set stream=msg.TextData
 . do stream.Rewind()
 . k len,line
 . for l=1:1 set len=32763,line=stream.Read(.len) do  quit:stream.AtEnd
 ..S MASS(msg,"msg",l)=line         ;write line
 quit
}

ClassMethod KILLMAIL(MDEAM, BSmName, BSmPass, MSGK, Kill) As %String
{
 S OK=1,Kill=0
 set mailserver=##class(%Net.POP3).%New()
 set mailserver.port=$G(^%BScSMTP(MDEAM,"POP"),"110")
 set mailserver.Debug=0
 set mailserver.StoreAttachToFile=1
 set status=mailserver.Connect(MDEAM,BSmName,BSmPass)
 if ('status) S OK=status g Kclo
 S I="" F  S I=$O(MSGK(I)) Q:I=""  set OK=mailserver.DeleteMessage(I) S:OK Kill=Kill+1 I 'OK Q
 s status=mailserver.QuitAndCommit()
Kclo s status=mailserver.%Close()
 q $G(OK)
}

/// write $System.Status.GetErrorText(##class(apptools.core.net).GetJsonURL("https://pm.community.intersystems.com/",.o)) 
ClassMethod GetJsonURL(url As %String, ByRef object) As %Status
{
	New $Namespace
	#dim re As %Net.HttpRequest
	
 	Set req=##class(%Net.HttpRequest).%New()
	
	if $zconvert(url,"L")["https:" {
	 	Set SSLConfig = "ZPM"
	 	Zn "%SYS"
	 	Do:'##class(Security.SSLConfigs).Exists(SSLConfig) ##class(Security.SSLConfigs).Create(SSLConfig)
	 	Set req.Https=1
		Set req.SSLConfiguration=SSLConfig
	}
  	do ..SetProxy(.req)
	set server=$p(url,"/",3)
	if server[":" {
		Set req.Port=$p(server,":",2)
		set server=$p(server,":")
	}
	Set req.Server=server
	Set req.Location = $p(url,"/",4,*)
	;Do req.SetHeader("Accept","application/vnd.github.v3+json")

	Set st = req.Get()
	Return:$$$ISERR(st) st
	Return:(req.HttpResponse.StatusCode = 404) $$$ERROR($$$GeneralError,"Repository doesn't exist OR you don't have access")
	Return:((req.HttpResponse.StatusCode = 403) && (req.HttpResponse.GetHeader("X-RATELIMIT-REMAINING")=0)) $$$ERROR($$$GeneralError,"API rate limit exceeded. Try logging in.")
 	Return:(req.HttpResponse.StatusCode '= 200) $$$ERROR($$$GeneralError,"Received " _ req.HttpResponse.StatusCode _ " status, expected 200")

 	#dim object As %ZEN.proxyObject
	Set st = ##class(%ZEN.Auxiliary.jsonProvider).%ConvertJSONToObject(req.HttpResponse.Data,,.object,1)
	Return:$$$ISERR(st) st

 	Return $$$OK
}

/// To obtain the server's IP address
/// w ##class(apptools.core.net).GetIP()
/// $G(%request.CgiEnvs("REMOTE_ADDR")) - agrees client
ClassMethod GetListIP() As %String
{
 set lsIface=##class(%SYSTEM.INetInfo).GetListOfConfiguredInterfaces()
 for iface=1:1:$ll(lsIface) { 
   s IPv4=$lg($lg(lsIface,iface),2)
   if $l(IPv4,":")>2 {set IPv4=$lg($lg(lsIface,iface),3) if $l(IPv4,":")>2 {set IPv4=""}}
   write IPv4,!
 }
}

/// Get IP address
/// w ##class(apptools.core.net).GetIP("google.com")
/// w $P($ZU(54,13,$zu(54,0)),",",1)
ClassMethod GetIP(host = "") As %String
{
	if host="" set host=$zu(54,0) ;current host
	q $P($ZU(54,13,host),",",1)
}

/// Get IP address external
/// do ##class(apptools.core.net).GetIPext(,.ip) zw ip
ClassMethod GetIPext(url = {"https://pr-cy.ru/browser-details/"}, ByRef ip) As %Status
{
	If url="" Quit $$$ERROR($$$GeneralError,"Invalid - URL - not supplied")
	set st=$$$OK 
	set st=##class(apptools.core.net).GetHttp(url,.out)
	if st {
		do ##class(apptools.core.files).Stream2String(out("content"),.str)
		;s out("stream")=str
		set ip=$p($p($p(str,"<input type=""text"" name=""host"" ",2),"value=""",2),$c(34),1)
	}
    quit st
}

/// Get current URI
/// write ##class(apptools.core.net).GetURI(.prop)
ClassMethod GetURI(Properties, suff = "") As %String
{
	New $Namespace
	set $Namespace="%SYS"
	set Status=##Class(Config.Startup).Get(.Properties)
	if Status s ServerPort="http://"_$zu(110)_suff_":"_$g(Properties("WebServerPort"),57772)
	quit $G(ServerPort)
}

/// /* Install ZPM, ZAPM */ set $namespace="%SYS", name="DefaultSSL" do:'##class(Security.SSLConfigs).Exists(name) ##class(Security.SSLConfigs).Create(name) set url="https://pm.community.intersystems.com/packages/zpm/latest/installer" Do ##class(%Net.URLParser).Parse(url,.comp) set ht = ##class(%Net.HttpRequest).%New(), ht.Server = comp("host"), ht.Port = 443, ht.Https=1, ht.SSLConfiguration=name, st=ht.Get(comp("path")) quit:'st $System.Status.GetErrorText(st) set xml=##class(%File).TempFilename("xml"), tFile = ##class(%Stream.FileBinary).%New(), tFile.Filename = xml do tFile.CopyFromAndSave(ht.HttpResponse.Data) do ht.%Close(), $system.OBJ.Load(xml,"ck") do ##class(%File).Delete(xml) zpm "install zapm"
/// w ##class(apptools.core.net).loadzpm()
ClassMethod loadzpm() As %Status
{
  SET $NAMESPACE="%SYS"
  set name="DefaultSSL" DO:'##class(Security.SSLConfigs).Exists(name) ##class(Security.SSLConfigs).Create(name)
  set url="https://pm.community.intersystems.com/packages/zpm/latest/installer" write !,url
  Do ##class(%Net.URLParser).Parse(url,.comp)
  set ht = ##class(%Net.HttpRequest).%New()
  set ht.Server = comp("host")
  set ht.Port = 443
  set ht.Https=1
  set ht.SSLConfiguration=name
  do ..UseProxy(.ht)
  set st=ht.Get(comp("path"))
  quit:'st $System.Status.GetErrorText(st) 
  set xml=##class(%File).TempFilename("xml")
  Set tFileBinStream = ##class(%Stream.FileBinary).%New()
  Set tFileBinStream.Filename = xml
  do tFileBinStream.CopyFromAndSave(ht.HttpResponse.Data)      
  do ht.%Close()
  do $system.OBJ.Load(xml,"ck")
  do ##class(%File).Delete(xml)
  quit $$$OK
}

/// do ##class(apptools.core.net).SetProxy(.r)
ClassMethod SetProxy(tRequest) As %Status
{
    set proxy=$System.Util.GetEnviron("https_proxy")
    if proxy'="" {
      Do ##class(%Net.URLParser).Parse(proxy,.pr)
      if (tRequest.Https) {
        set tRequest.ProxyHTTPS=1
        set tRequest.ProxyTunnel=1
      }
      set tRequest.ProxyPort=pr("port")
      set tRequest.ProxyServer=pr("host")
      if pr("username")'="",pr("password")'="" {
        set tRequest.ProxyAuthorization="Basic "_$system.Encryption.Base64Encode(pr("username")_":"_pr("password"))
      }
    }
    quit $$$OK
}

/// Code from Robert Cemper https://github.com/rcemper/Zpipe
/// write ##class(apptools.core.net).cpipe("ping -c 3 openexchange.intersystems.com")
ClassMethod cpipe(command = "", test = 0) As %Status
{
 //Zpipe  quit ; CPIPE example to run host console command
 //cmd(command="",test=0) ;
 if command="" set command="dir"
 set dev="|CPIPE|1"
 set $zt="cls"
 set empty=0
 open dev:command:0 
 write:test $test,! 
 else  write "pipe failed",! quit 0 
 while empty<3 {
    use dev read line 
    set empty=$s($l(line):0,1:$i(empty))
    use 0 write line,!  ;;; or do any kind of analysis of the line 
    }

cls ;
 set $zt="" use 0 
 close dev 
 if $ze'["<ENDOFFILE>" w $ze,!
 quit $t
}

/// install ZPM with proxy. You can call this, or copy the line
/// modified Sergey Mikhaylenko
ClassMethod InstallZPMproxy()
{
    s r=##class(%Net.HttpRequest).%New(),proxy=$System.Util.GetEnviron("https_proxy") Do ##class(%Net.URLParser).Parse(proxy,.pr) s:$d(pr) r.ProxyHTTPS=1,r.ProxyTunnel=1,r.ProxyPort=pr("port"),r.ProxyServer=pr("host") s:pr("username")'=""&&(pr("password")'="") r.ProxyAuthorization="Basic "_$system.Encryption.Base64Encode(pr("username")_":"_pr("password")) set r.Server="pm.community.intersystems.com",r.SSLConfiguration="ISC.FeatureTracker.SSL.Config" d r.Get("/packages/zpm/latest/installer"),$system.OBJ.LoadStream(r.HttpResponse.Data,"c")
}

}

