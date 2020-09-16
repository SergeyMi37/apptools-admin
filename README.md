![](https://github.com/SergeyMi37/isc-apptools-admin/blob/master/doc/favicon.ico)
## isc-apptools-admin
[![Gitter](https://img.shields.io/badge/Available%20on-Intersystems%20Open%20Exchange-00b2a9.svg)](https://openexchange.intersystems.com/package/isc-apptools-admin-1)

Application tools for technical support and DBMS administrator. View arrays, execute queries, including JDBC/ODBC, sending results to email as XLS files. A few simple graphs on the protocols of the system.

## Installation with ZPM

zpm:USER>install isc-apptools-admin

## Installation with Docker

## Prerequisites
Make sure you have [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git) and [Docker desktop](https://www.docker.com/products/docker-desktop) installed.

## Installation 
Clone/git pull the repo into any local directory

```
$ git clone https://github.com/SergeyMi37/isc-apptools-admin.git
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
zpm:USER>install isc-apptools-admin
```

## Panel for admins & developers

 Load http://your-host:your-port/apptools/App.LogInfo.cls
 - view the list of globals by mask with count blocks occupied by them.
 - viewing global and direct and reverse with a possible filter by links and node data. Edit global nodes. Export a selection of nodes and global data to an XLS file and send the archive to an email.
 - execution of queries and SQL statements with the ability to connect via JDBC / ODBC. Export the results to an XLS file and send the archive to an email.
 - code execution by XECUTE command in the interface panel.
 - saving commands and queries in the program history with the ability to run them again.
 - there is a module for implementing the LockedDown mode - ##class(App.security).LockDown(...)
 - multilanguage interface supported (install the global from C:\path\cache-iris-apptools-master\src\glb\appcachemsg.xml).

## REST-API
In this solution, I use REST-API adapted from the [Webterminal](https://github.com/intersystems-community/webterminal) and [metrics ^mgstat](https://habr.com/ru/company/intersystems/blog/318940/)

## Class explorer
 Load http://your-host:your-port/apptools/App.FormExp.cls?panel=AccordionExp
  - Navigation by namespaces, class, and class instance. Create, edit, and delete class instances in the on-screen form interface.

##  Matrix permissions
 Load http://your-host:your-port/apptools/apptools/App.TabsPanelUikitPermissMatrx.cls?autoload=Matrix
  - Group assignment of roles to users by selecting them by filter in the screen panel
  ![Matrix permissions](https://github.com/SergeyMi37/isc-apptools-admin/blob/master/doc/acc-matrix.gif)

## Templates & Samples  
 Load http://your-host:your-port/apptools/App.TabsPanelSample.cls   
 - jQuery-Ui.js based application template.
  
 Load http://your-host:your-port/apptools/App.TabsPanelUikit.cls
 - UiKit.js based application template
   
 Load http://your-host:your-port/apptools/App.TabsPanelUikitAdmin.cls
  - UiKit.js based application template for admin panels

## Charts admins

 Load http://your-host:your-port/apptools/App.Chart.cls?panel=class(App.ChartPanel).ChartAlert
  - output of the DBMS events using the iris.log protocol (cconsole.log)

 Load http://your-host:your-port/apptools/App.Chart.cls?panel=class(App.ChartPanel).ChartAlert
  - output of the growth dynamics of DBMS database files using the messages.log protocol (cconsole.log)

## Save queries to the global for future use in front-end applications
```
IRISAPP>do ##class(App.sys).SaveQuery("%SYSTEM.License:Counts", "^test",123)

IRISAPP>zw ^test
^test("%SYSTEM.License:Counts",123,0,1)="InstanceLicenseUse"
^test("%SYSTEM.License:Counts",123,0,2)="License Units"
^test("%SYSTEM.License:Counts",123,1,1)="Total   Authorized LU"
^test("%SYSTEM.License:Counts",123,1,2)=5
...

IRISAPP>zn "%sys"
 
%SYS>do ##class(App.sys).SaveQuery("SYS.Database:FreeSpace")
 
%SYS>zw ^%App.Task
^%App.Task("SYS.Database:FreeSpace","2020-03-22 09:36:49",0,1)="DatabaseName"
^%App.Task("SYS.Database:FreeSpace","2020-03-22 09:36:49",0,2)="Directory"
^%App.Task("SYS.Database:FreeSpace","2020-03-22 09:36:49",0,3)="MaxSize"
^%App.Task("SYS.Database:FreeSpace","2020-03-22 09:36:49",0,4)="Size"
^%App.Task("SYS.Database:FreeSpace","2020-03-22 09:36:49",0,5)="ExpansionSize"
...
```
%SYS>do ##class(App.sys).SaveSQL("select NameLowerCase,Description,Name FROM Security.Roles where Name['DB'", "^logMSW2")
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
// do ##class(App.sys).SqlToDSN("SELECT * FROM xxmv.xx_t359_pzn","JDBC-DSN","^tmpMSWq"))
```

Function to call from a regular tasks
```
%SYS>do ##class(App.sys).RunCmd("sudo du -sm /usr/irissys/mgr/*| sort -nr",$na(^%App.Cmd("mgr",$zd($h,3))),1,"/tmp/")

%SYS>zw ^%App.Cmd
^%App.Cmd("mgr","2020-03-22","2020-03-22_17:27:03",1)="388"_$c(9)_"/usr/irissys/mgr/irislib"
^%App.Cmd("mgr","2020-03-22","2020-03-22_17:27:03",2)="176"_$c(9)_"/usr/irissys/mgr/enslib"
^%App.Cmd("mgr","2020-03-22","2020-03-22_17:27:03",3)="100"_$c(9)_"/usr/irissys/mgr/IRIS.WIJ"
^%App.Cmd("mgr","2020-03-22","2020-03-22_17:27:03",4)="97"_$c(9)_"/usr/irissys/mgr/journal"
^%App.Cmd("mgr","2020-03-22","2020-03-22_17:27:03",5)="90"_$c(9)_"/usr/irissys/mgr/IRIS.DAT"
...

// do ##class(App.sys).RunTask("snmpwalk -v 1 server.ru -c public 1.3.6.1.4.1.16563.1.1.1.1.10","^%App.TaskLic","%SYSTEM.License:Counts","/tmp/")

```

## To count in journal which globals as modifierade for a specific date
```
%SYS>do ##class(App.files).OneDayJournalCount("/usr/irissys/mgr/journal/"_$tr($zd($h,3),"-"),"^tmpJRN")

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
%SYS>do ##class(App.files).Export2CSV("/tmp/JrnCount*.csv","^tmpJRN")

Written to the file /tmp/JrnCount20200322173446.csv
```

## Group product management in various namespaces
Initialize interoperability and create a new test product ([thanks Dias](https://openexchange.intersystems.com/package/IRIS-Interoperability-Message-Viewer)) in IRISAPP.
```
IRISAPP>do ##class(App.Production).CreateProduction("IRISAPP", "Test.TestProd", "Ens.MonitorService,Ens.Alerting.AlertManager,Ens.Activity.Operation.REST")

IRISAPP>do ##class(Ens.Director).StartProduction("Test.TestProd")
```

Initialize interoperability and create a new test product in USER.
```
zn "user"
USER>do ##class(App.Production).CreateProduction("USER", "Test.TestProd2", "Ens.MonitorService,Ens.Alerting.AlertManager,Ens.Activity.Operation.REST")

IRISAPP>do ##class(Ens.Director).StartProduction("Test.TestProd2")
```
When you administer more than 2 products, the scheduled server restart turns into a monotonous routine operation of manually stopping each product. To automate this, a set of utilities is used.

Preserve statuse and stop products in all namespace.
```
IRISAPP>do ##class(App.Production).SaveAndStop()
```

All products are stopped, you can restart the server.
After starting the DBMS, you can start all the products that were launched before.
```
IRISAPP>do ##class(App.Production).StartAll()
```

Create message cleaning tasks for all products, leaving in the last 30 days
```
IRISAPP>do ##class(App.Production).CreateTasksPurgeMess(30)
```

Get a class description, optionally with a superclass
```
IRISAPP>do ##class(App.LogInfoPane).GetClassDef("Test.TestProd2","",.def,1)

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
IRISAPP>do ##class(App.Production).GenDoc("/usr/irissys/csp/user/gen-doc.html")
```

## Increasing security settings
You can replace the shared password if the password of the predefined system users has been compromised
```
IRISAPP>do ##class(App.security).ChangePassword("NewPass231",##class(App.security).GetPreparedUsers())
```

Application to the LockedDown system, if it was installed with the initial security settings, minimum or normal.
You can get and study the description of the method parameters with such a command, like any other element of any other class.
```
IRISAPP>write ##class(App.msg).man("App.security).LockDown")

Increase system security to LockDown
The method disables services and applications as in LockDown. Deletes the namespaces "DOCBOOK", "ENSDEMO", "SAMPLES"
The method enables auditing and configures registration of all events in the portal, except for switching the log
and modification of system properties
For all predefined users, change the password and change the properties as in LockDown
        newPassword - new single password instead of SYS. For LockDown security level, it has an 8.32ANP pattern
        sBindings = 1 Service% service_bindings enable
        sCachedirect = 1 Service% service_cachedirect enable
        InactiveLimit = 90
        DemoDelete = 0 Demoens, Samples namespaces are being deleted
		
        AuditOn = 1
        sECP = 1 Service% service_ecp enable
        sBindingsIP - list of ip addresses with a semicolon for which to allow CacheStudio connection.

For ECP configurations, you need to add the addresses of all servers and clients to allow connection on% Net.RemoteConnection to remove "abandoned" tasks
        sCachedirectIP - list of ip addresses with a semicolon for which to allow legacy applications connection.
        sECPIP - list of ip addresses with a semicolon for which to allow connection to the ECP server.
        AuthLDAP = 1 In addition to the password, also enable LDAP authentication
...
```

Apply Security settings to "LockDown"
```
IRISAPP>do ##class(App.security).LockDown("NewPassword123",.msg,1,1,0,0)

Applications and services will be authenticated by password
Password is reset to predefined users
Modification of service properties:
%service_cachedirect: Error=ERROR #787: Service %Service_CacheDirect not allowed by license
Passwords are created for all CSP applications.
There is a modification of the basic system settings
Event Setup AUDIT :
%System/%DirectMode/DirectMode changed
%System/%Login/Login changed
%System/%Login/Logout changed
%System/%Login/Terminate changed
%System/%Security/Protect changed
%System/%System/JournalChange changed
%System/%System/RoutineChange changed
%System/%System/SuspendResume changed

```

All other features of the interface part of the software solution can be found in the 
[document](https://github.com/SergeyMi37/isc-apptools-admin/blob/master/doc/Documentation%20AppTools.pdf)
 or in an [article of a Russian resource](https://habr.com/en/post/436042/)
