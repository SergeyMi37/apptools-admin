/// Parameters Infosys
Class apptools.Infosys.Parameters Extends %Persistent
{

/// The order of the properties in the output in the form
Parameter AppORDERPROPERTY = "Name,Namespace,Description,Value,Types,json,xml,DateStart,DateFinish,File,isEnabled,isEnabledCheck,OfficeFile";

/// Namespace $zu(5) use parameter
Property Namespace As %String(MAXLEN = "") [ InitialExpression = {$zu(5)} ];

/// The name of the parameter
Property Name As %String(MAXLEN = "") [ Required ];

/// Parameter value default
Property Value As %String(MAXLEN = "");

/// The description of the parameter
/// {"displayname":"Description of option","title":"parameter Description","inputpattern":"textarea"}
Property Description As %String(MAXLEN = "");

/// JSON of the parameter
/// {"displayname":"JSON","title":"parameter json","inputpattern":"textarea"}
Property json As %String(MAXLEN = "");

/// XML of the parameter
/// {"displayname":"XML","title":"parameter xml","inputpattern":"textarea"}
Property xml As %String(MAXLEN = "");

/// Date of sampling Protocol
/// {"displayname":"date of sampling Protocol","title":"enter date","inputtype":"date"}
Property DateStart As %String(MAXLEN = "") [ InitialExpression = {##class(apptools.core.type).GetYear($h)_"-01-01"} ];

/// Date of sampling Protocol on
/// {"displayname":"date of sampling Protocol","title":"enter the date and time","inputtype":"datetime-local"}
Property DateFinish As %String(MAXLEN = "") [ InitialExpression = {##class(apptools.core.type).GetYear($h)_"-12-31"} ];

/// Type Boolean in a checkbox
/// {"displayname":"Enabled","inputtype":"checkbox"}
Property isEnabledCheck As %Boolean [ InitialExpression = 1 ];

/// Type Boolean in a list
/// {"displayname":"Included","title":"enter (1 or 0)"}
Property isEnabled As %Boolean [ InitialExpression = 0 ];

/// Select the file to upload to drive TempDir = ##class(%File).GetDirectory(##class(%File).TempFilename())
/// {"displayname":"Select template file","title":"the Choice sablona","inputpattern":"files","filesMethod":"##class(apptools.core.type).UploadFilesJS(%id)","attr":"accept='.xls,.xlsx'","filesStore":"TempDir"}
Property File As %String(MAXLEN = "");

/// The list of parameter types
/// {"displayname":"parameter Types","title":"Select a Type"}
Property Types As %String(DISPLAYLIST = ",Project,Application Parameter,System Parameter", MAXLEN = 1, VALUELIST = ",Projecr,AppOption,SysOption") [ InitialExpression = "AppOption", Required ];

/// Select the file to download to disk TempDir
/// {"displayname":"Select file","title":"Select file","inputpattern":"files"}
Property OfficeFile As %String(MAXLEN = "");

Storage Default
{
<Data name="ParametersDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Namespace</Value>
</Value>
<Value name="3">
<Value>Name</Value>
</Value>
<Value name="4">
<Value>Value</Value>
</Value>
<Value name="5">
<Value>Description</Value>
</Value>
<Value name="6">
<Value>DateStart</Value>
</Value>
<Value name="7">
<Value>DateFinish</Value>
</Value>
<Value name="8">
<Value>isEnabledCheck</Value>
</Value>
<Value name="9">
<Value>isEnabled</Value>
</Value>
<Value name="10">
<Value>File</Value>
</Value>
<Value name="11">
<Value>Types</Value>
</Value>
<Value name="12">
<Value>OfficeFile</Value>
</Value>
<Value name="13">
<Value>json</Value>
</Value>
<Value name="14">
<Value>xml</Value>
</Value>
</Data>
<DataLocation>^apptools.Infosys.ParametersD</DataLocation>
<DefaultData>ParametersDefaultData</DefaultData>
<IdLocation>^apptools.Infosys.ParametersD</IdLocation>
<IndexLocation>^apptools.Infosys.ParametersI</IndexLocation>
<StreamLocation>^apptools.Infosys.ParametersS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}

