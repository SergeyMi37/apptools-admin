Class apptools.Chart.Chart Extends apptools.core.AutoPage
{

Parameter CSPURL = "apptools.Chart.Chart.cls";

Parameter PAGENAME = "Chart";

Parameter PARENTPAGE = "apptools.core.AutoPage.cls";

/// Get the detail pane info object
ClassMethod GetDetailPane(pInstance As %CSP.Util.PageInstance) As %CSP.Util.Pane
{
	quit ##class(apptools.Chart.ChartPanel).%New()
}

}

