![](https://github.com/SergeyMi37/apptools-admin/blob/master/doc/favicon.ico)
## apptools-admin
[![Gitter](https://img.shields.io/badge/Available%20on-Intersystems%20Open%20Exchange-00b2a9.svg)](https://openexchange.intersystems.com/package/apptools-admin-1)

Application tools for technical support and DBMS administrator. View and edit arrays, execute queries, including JDBC/ODBC, sending results to email as XLS files. A few simple graphs on the protocols of the system.

This solution can be installed in earlier versions of Cache and Ensemble (tested 2016.1+). This can be done by importing xml.

## Installation with ZPM

zpm:USER>install apptools-admin

## Installation with Docker

## Prerequisites
Make sure you have [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git) and [Docker desktop](https://www.docker.com/products/docker-desktop) installed.

## Installation 
Clone/git pull the repo into any local directory

```
$ git clone https://github.com/SergeyMi37/apptools-admin.git
```

Open the terminal in this directory and run:

```
$ docker-compose build
```

3. Run the IRIS container with your project:

```
$ docker-compose up -d
```

## How to Test it
Open IRIS terminal:

```
$ docker-compose exec iris iris session iris
USER>
USER>zpm
zpm:USER>install apptools-admin
```

## Panel for admins & developers

 Load http://your-host:your-port/apptools/apptools.core.LogInfo.cls?WHAT=%3F
  
 - view the list of globals by mask with count blocks occupied by them.
  ![EDIT](https://raw.githubusercontent.com/SergeyMi37/apptools-admin/master/doc/Screenshot_7-glb-view.gif)
 - viewing global and direct and reverse with a possible filter by links and node data. Edit global nodes. Export a selection of nodes and global data to an XLS file and send the archive to an email.
  ![EDIT](https://raw.githubusercontent.com/SergeyMi37/apptools-admin/master/doc/Screenshot_6-edit-glb.gif)
 
 - execution of queries and SQL statements with the ability to connect via JDBC / ODBC. Export the results to an XLS file and send the archive to an email.
 ![SQL](https://raw.githubusercontent.com/SergeyMi37/apptools-admin/master/doc/Screenshot_6-jdbc.png)
 
 - code execution by XECUTE command in the interface panel.
  ![XECUTE](https://raw.githubusercontent.com/SergeyMi37/apptools-admin/master/doc/Screenshot_3-zw-sys.png)
 
 - saving commands and queries in the program history with the ability to run them again.
 ![QUERY](https://raw.githubusercontent.com/SergeyMi37/apptools-admin/master/doc/Screenshot_8-glb-save.gif)
 
 - All executed commands are remembered in history for the opportunity to repeat again. Frequently executed commands can be saved as favorites.
 ![HISTORY](https://raw.githubusercontent.com/SergeyMi37/apptools-admin/master/doc/Screenshot_9-history.gif)
 
## REST-API
In this solution, I use REST-API adapted from the [Webterminal](https://github.com/intersystems-community/webterminal) and [metrics ^mgstat](https://habr.com/ru/company/intersystems/blog/318940/)

## Class explorer
 Load http://your-host:your-port/apptools/apptools.Form.FormExp.cls?panel=AccordionExp
  - Navigation by namespaces, class, and class instance. Create, edit, and delete class instances in the on-screen form interface.

##  Matrix permissions
 Load http://your-host:your-port/apptools/apptools.Tabs.TabsPanelUikitPermissMatrx.cls?autoload=Matrix
  - Group assignment of roles to users by selecting them by filter in the screen panel
  ![Matrix permissions](https://github.com/SergeyMi37/isc-apptools-admin/blob/master/doc/acc-matrix.gif)

## Templates & Samples  
 Load http://your-host:your-port/apptools/apptools.Tabs.TabsPanelSample.cls   
 - jQuery-Ui.js based application template.
  
 Load http://your-host:your-port/apptools/apptools.Tabs.TabsPanelUikit.cls
 - UiKit.js based application template
   
 Load http://your-host:your-port/apptools/apptools.Tabs.TabsPanelUikitAdmin.cls
  - UiKit.js based application template for admin panels

## Charts admins

 Load http://your-host:your-port/apptools/apptools.Chart.Chart.cls?panel=class(apptools.Chart.ChartPanel).ChartAlert
  - output of the DBMS events using the iris.log protocol (cconsole.log)

 Load http://your-host:your-port/apptools/apptools.Chart.Chart.cls?panel=class(apptools.Chart.ChartPanel).ChartAlert
  - output of the growth dynamics of DBMS database files using the messages.log protocol (cconsole.log)

## Save queries to the global for future use in front-end applications
```
IRISAPP>do ##class(apptools.core.sys).SaveQuery("%SYSTEM.License:Counts", "^test",123)

IRISAPP>zw ^test
^test("%SYSTEM.License:Counts",123,0,1)="InstanceLicenseUse"
^test("%SYSTEM.License:Counts",123,0,2)="License Units"
^test("%SYSTEM.License:Counts",123,1,1)="Total   Authorized LU"
^test("%SYSTEM.License:Counts",123,1,2)=5
...

IRISAPP>zn "%sys"
 
%SYS>do ##class(apptools.core.sys).SaveQuery("SYS.Database:FreeSpace")
 
%SYS>zw ^%App.Task
^%apptools.Task("SYS.Database:FreeSpace","2020-03-22 09:36:49",0,1)="DatabaseName"
^%apptools.Task("SYS.Database:FreeSpace","2020-03-22 09:36:49",0,2)="Directory"
^%apptools.Task("SYS.Database:FreeSpace","2020-03-22 09:36:49",0,3)="MaxSize"
^%apptools.Task("SYS.Database:FreeSpace","2020-03-22 09:36:49",0,4)="Size"
^%apptools.Task("SYS.Database:FreeSpace","2020-03-22 09:36:49",0,5)="ExpansionSize"
...
```
%SYS>do ##class(apptools.core.sys).SaveSQL("select NameLowerCase,Description,Name FROM Security.Roles where Name['DB'", "^logMSW2")
 ```
%SYS>zw ^logMSW2                                                               
^logMSW2(-3,"sql")=$lb("select NameLowerCase,Description,Name FROM Security.Roles where Name'DB'")
^logMSW2(-3,"timestamp")=$lb("2020-03-22 09:49:50","2020-03-22 09:49:50",0)
^logMSW2(-1,"Description")=2
^logMSW2(-1,"Name")=3
^logMSW2(-1,"NameLowerCase")=1
^logMSW2(0)=$lb("NameLowerCase","Description","Name")
^logMSW2(1)=$lb("%all","Роль Суперпользователя","%All")
^logMSW2(2)=$lb("%db_%default","Доступ на чтение/запись для ресурса","%DB_%DEFAULT")
...
```
If you determine JDBC-DSN, then you can connect to an external database
```
// do ##class(apptools.core.sys).SqlToDSN("SELECT * FROM xxmv.xx_t359_pzn","JDBC-DSN","^tmpMSWq"))
```

Function to call from a regular tasks
```
%SYS>do ##class(apptools.core.sys).RunCmd("sudo du -sm /usr/irissys/mgr/*| sort -nr",$na(^%App.Cmd("mgr",$zd($h,3))),1,"/tmp/")

%SYS>zw ^%App.Cmd
^%App.Cmd("mgr","2020-03-22","2020-03-22_17:27:03",1)="388"_$c(9)_"/usr/irissys/mgr/irislib"
^%App.Cmd("mgr","2020-03-22","2020-03-22_17:27:03",2)="176"_$c(9)_"/usr/irissys/mgr/enslib"
^%App.Cmd("mgr","2020-03-22","2020-03-22_17:27:03",3)="100"_$c(9)_"/usr/irissys/mgr/IRIS.WIJ"
^%App.Cmd("mgr","2020-03-22","2020-03-22_17:27:03",4)="97"_$c(9)_"/usr/irissys/mgr/journal"
^%App.Cmd("mgr","2020-03-22","2020-03-22_17:27:03",5)="90"_$c(9)_"/usr/irissys/mgr/IRIS.DAT"
...

// do ##class(apptools.core.sys).RunTask("snmpwalk -v 1 server.ru -c public 1.3.6.1.4.1.16563.1.1.1.1.10","^%App.TaskLic","%SYSTEM.License:Counts","/tmp/")

```

## To count in journal which globals as modifierade for a specific date
```
%SYS>do ##class(apptools.core.files).OneDayJournalCount("/usr/irissys/mgr/journal/"_$tr($zd($h,3),"-"),"^tmpJRN")

/usr/irissys/mgr/journal/20200322.001
Processed /usr/irissys/mgr/journal/20200322.001% 2 written in ^tmpJRN

/usr/irissys/mgr/journal/20200322.002
Processed /usr/irissys/mgr/journal/20200322.002% 2 written in ^tmpJRN

/usr/irissys/mgr/journal/20200322.003

%SYS>zw ^tmpJRN
^tmpJRN=""
^tmpJRN("IRIS",20200322,16,"/opt/irisapp/data/","KILL","^ROUTINE","Counts")=1
^tmpJRN("IRIS",20200322,16,"/opt/irisapp/data/","KILL","^ROUTINE","NewValue")=0
^tmpJRN("IRIS",20200322,16,"/opt/irisapp/data/","KILL","^ROUTINE","OldValue")=0

```
Export to report CSV file 
```
%SYS>do ##class(apptools.core.files).Export2CSV("/tmp/JrnCount*.csv","^tmpJRN")

Written to the file /tmp/JrnCount20200322173446.csv
```

## Group product management in various namespaces
Initialize interoperability and create a new test product ([thanks Dias](https://openexchange.intersystems.com/package/IRIS-Interoperability-Message-Viewer)) in IRISAPP.
```
IRISAPP>do ##class(apptools.core.Production).CreateProduction("IRISAPP", "Test.TestProd", "Ens.MonitorService,Ens.Alerting.AlertManager,Ens.Activity.Operation.REST")

IRISAPP>do ##class(Ens.Director).StartProduction("Test.TestProd")
```

Initialize interoperability and create a new test product in USER.
```
zn "user"
USER>do ##class(apptools.core.Production).CreateProduction("USER", "Test.TestProd2", "Ens.MonitorService,Ens.Alerting.AlertManager,Ens.Activity.Operation.REST")

IRISAPP>do ##class(Ens.Director).StartProduction("Test.TestProd2")
```
When you administer more than 2 products, the scheduled server restart turns into a monotonous routine operation of manually stopping each product. To automate this, a set of utilities is used.

Preserve statuse and stop products in all namespace.
```
IRISAPP>do ##class(apptools.core.Production).SaveAndStop()
```

All products are stopped, you can restart the server.
After starting the DBMS, you can start all the products that were launched before.
```
IRISAPP>do ##class(apptools.core.Production).StartAll()
```

Get a class description, optionally with a superclass
```
IRISAPP>do ##class(apptools.core.LogInfoPane).GetClassDef("Test.TestProd2","",.def,1)

IRISAPP>zw def
def("ClassName","Ens.Production")=""
def("ClassName","Ens.Production","super") = "%RegisteredObject,Ens.Settings"
def("ClassName","Ens.Settings")=""
def("ClassName","Test.TestProd2") = ""
def("ClassName","Test.TestProd2","super") = "Ens.Production"
def("Methods","ApplySettings","Description") = "Apply multiple settings to a"
...
```

Create html format documentation in the form of tables for all products, including BS. BP BO and all classes that they meet
```
IRISAPP>do ##class(apptools.core.Production).GenDoc("/usr/irissys/csp/user/gen-doc.html")
```

All other features of the interface part of the software solution can be found in the 
[document](https://github.com/SergeyMi37/isc-apptools-admin/blob/master/doc/Documentation%20AppTools.pdf)
 or in an [article of a Russian resource](https://habr.com/en/post/436042/)
