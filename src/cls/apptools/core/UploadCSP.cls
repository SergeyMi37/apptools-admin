Include apptools.core

Class apptools.core.UploadCSP Extends %CSP.Page [ CompileAfter = apptools.core.msg ]
{

/// The path to the directory on the server for storing files
Parameter pathfiles = {##class(%File).GetDirectory(##class(%File).TempFilename())};

ClassMethod OnPage(Par = "") As %Status
{
    set FieldName="loadFile"
    if $g(%loadFileSuccess)'="" {
	    if $lv(%loadFileSuccess) {
	        if $lg(%loadFileSuccess,1) {
		        if $lg(%loadFileSuccess,5)'=1 d WriteError q 1
	    		set orig=$lg(%loadFileSuccess,6)
	    		set orig=$p(orig,$$$slash,*)
	    		set orig=$tr(orig," №`()\/*;'"":","_N---")
	    		write "<script>"
	    		write "try{"
	    		write "window.opener.document.getElementById('"_$g(%request.Data("FieldName",1))_"').value='"_$lg(%loadFileSuccess,2)_"*"_orig_"';"
	    		write "}catch(e){}"
	    		write "window.close();"
	    		write "</script>"
	    		quit $$$OK
	        } else {
	            do WriteError
	            quit $$$OK
	        }
	        quit $$$OK
	    }
    }
    &html<<!DOCTYPE HTML>
<html>
<head>
<title>Upload</title>
>
 write ##class(apptools.core.LogInfoPane).GetLink()
 set Upload=$$$aText("Upload","")
 set Cancel=$$$aText("Cancel","")
 set pathcsp=""
  if $d(%request) {
	   ;zw %request TODO
	   ;%request.AppData %request.Application
	   if %request.Application["apptoolsrest" set pathcsp="/csp/spgz/"
  }
 &html<
    <script>
        $(document).ready(function(){
            $(this).keydown(function(eventObject){
                if (eventObject.which == 27)
                    window.close();
            });
        });
    </script>  
</head>
<body bgcolor="#f0f8ff" >
<form action="#(pathcsp_..%ClassName(1)_".cls")#" enctype="multipart/form-data" method="post">
    <br><center>
     #($$$aText("Select a file",""))#: <input class='ui-button ui-corner-all ui-widget' name='loadFile' id='loadFile' size=30 type='file' accept=".doc,.docx,.odt,.pdf,.xls,.xlsx" >
    <br><br>
    <input class='ui-button ui-corner-all ui-widget' type="submit" value="#(Upload)#"> 
    <input class='ui-button ui-corner-all ui-widget' type="button" value="#(Cancel)#" onclick='window.close();'>
    <input class='ui-button ui-corner-all ui-widget' type="hidden" name=FieldName id=FieldName value='#($g(%request.Data("idreturn",1)))#'>
    <input class='ui-button ui-corner-all ui-widget' type="hidden" name=idOrigNameReturn id=idOrigNameReturn value='#($g(%request.Data("idOrigNameReturn",1)))#'>
    <input class='ui-button ui-corner-all ui-widget' type="hidden" name=ServerDirPath id=ServerDirPath value='#($g(%request.Data("ServerDirPath",1)))#'>
    </center>
</form></body>
</html>
>
   Quit $$$OK
WriteError w "<H3>"_$$$aText("An error has occurred","")_"</h3>"_$System.Status.DisplayError($lg(%loadFileSuccess,5))_"<p><p>"_$$$aText("Try again, otherwise contact your administrator","")
 q
}

///  [ ServerOnly = 1 ]
ClassMethod OnPreHTTP(Par = "") As %Boolean
{
	set ServerDirPath=$zconvert($g(%request.Data("ServerDirPath",1)),"I","URL")
	if ServerDirPath="" set ServerDirPath=..#pathfiles
        s %loadFileSuccess=0
        s FieldName="loadFile"
        i %request.IsDefinedMimeData(FieldName,1) {
            s ContentType=%request.MimeData(FieldName,1).ContentType
            s Content=%request.MimeData(FieldName,1)
        } else {
            s ContentType=%request.ContentType
            s Content=%request.Content
        }
        i $isobject(Content),Content.Size>0 {
	        s fileName=Content.FileName
	        s name=$tr(##class(apptools.core.type).GetDateTime($h),"T: ","_")_"_"_$zcrc($p(fileName,$$$slash,*),7) //TODO tranlit
	        if fileName["." s name=name_"."_$p(fileName,".",*)
	        s %loadFileSuccess=$lb(1,$g(name),Content.Size)
	        s sc=##class(apptools.core.files).Stream2Log(Content, ServerDirPath,$zconvert( name,"O","UTF8"),.path) 
	        if sc s %loadFileSuccess=%loadFileSuccess_$lb($g(path),1,fileName)
	        else  s %loadFileSuccess=%loadFileSuccess_$lb($g(path),sc)
        }
        q 1
    q 1
}

}

