/// Include Ensemble
/// Ensemble-specific version of context search methods.
Class apptools.core.ContextSearch Extends %ZEN.Portal.ContextSearch [ System = 4 ]
{

/// Sample list
ClassMethod GetActualTables(method = "") As %Status
{
	if method="mode" { quit "Normativ,SpecCharacteristicEnum,SpecCharacteritics"
	}
	elseif method="mode2" { quit "Normativ2,SpecCharacteristicEnum2,SpecCharacteritics2"
	}
	quit ""
}

/// Sample method get list 
/// Parameter SETTINGS = "SampleList:Basic:selector?context={apptools.core.ContextSearch/GetActualTablesEnum?method=mode}, 
ClassMethod GetActualTablesEnum(Output pCaption As %String, Output pTopResults, Output pResults, ByRef pParms As %String, pSearchKey As %String = "") As %Status
{
	Set tStatus = $$$OK
	Kill pResults, pTopResults
	Set pCaption = ""
	Set tCount = 0, tNS = ""
	s tabs=..GetActualTables(($get(pParms("method"))))
	s (oebstab,taball,tab,tabcount)=""
	f i=1:1:$l(tabs,",") { continue:$p(tabs,",",i)=""
		Set tCount = tCount + 1
		Set pResults(tCount) = $p(tabs,",",i)
	}
	Quit $$$OK
}

/// Get list JDBC for adapter 
/// Parameter SETTINGS = "JDBC:Basic:selector?context={apptools.core.ContextSearch/GetJDBC?jdbcName=Context}, 
/// samples
///    myListEnsembleUsers:Basic:selector?context={Ens.ContextSearch/ListEnsembleUsers}, 
///    NSpace:Basic:selector?context={Ens.ContextSearch/GetEnsembleNamespaces}, 
///    MessageSchemaCategory:Basic:selector?context={Ens.ContextSearch/SchemaCategories?host=EnsLib.HL7.Service.Standard}, 
///    myLI:Basic:selector?context={Ens.ContextSearch/TCPLocalInterfaces}, 
///    myCharacterSets:Basic:selector?context={Ens.ContextSearch/CharacterSets}, 
///    BiBO:Basic:selector?multiSelect=1&context={Ens.ContextSearch/ProductionItems?targets=1&productionName=@productionId}";
ClassMethod GetJDBC(Output pCaption As %String, Output pTopResults, Output pResults, ByRef pParms As %String, pSearchKey As %String = "") As %Status
{
	Set tStatus = $$$OK
	Kill pResults, pTopResults
	Set pCaption = ""
	Set tCount = 0, tNS = ""
	set listDSN=##class(apptools.core.sys).getSQLConnection(.listDSN)
	Set jdbcName = $get(pParms("jdbcName"))
	for ns=1:1:$l(listDSN,",") { 
		continue:$p(listDSN,",",ns)=""
		if jdbcName'="", ($zconvert($p(listDSN,",",ns),"U") '[ $zconvert(jdbcName,"U")) continue
		Set tCount = tCount + 1
		Set pResults(tCount) = $p(listDSN,",",ns)
	}
	Quit $$$OK
}

}

