#
#  README
#

Verbindung Testling - Inspector

Die Verbindung wird vom Testling eingeleitet. Dazu gibt es zwei Möglichkeiten:

Variante 1 (siehe testling1.tcl)
--------------------------------

In der Quelle des Testlings wird ein tcp-Port eingerichtet (proc getPort). Die Portnummer wird auf 'stdout'  angezeigt. Diese Portnummer wird im Verbindungsdialog im 'inspector' eingegeben.

Variante 2 (siehe testling2.tcl)
--------------------------------

Etwas komplizierter aber komfortabel. Per dragNDrop wird das Label 'titel' über den 'inspector' gezogen und in 'Drop here' fallen gelassen.

Dazu muss im Testling das Label 'titel' mit der Proc 'dragLabel' angelegt  werden. Die Proc 'getPort2' richtet "beim Ziehen" den Port ein

Diese Variante funktioniert auch, wenn der Testling bereits gestartet ist.


Hinweis zum 'send'-Kommando
---------------------------

'send' ist per Default aktiv. Damit könnte vom 'inspector' die Verbindung zum Testling aufgenommen werden. Eine Anpassung im Testling wäre nicht notwendig.

Das 'send'-Kommando ist allerdings aus Sicherheitsgründen äußerst problematisch, deshalb wurde die 'send'-Variante nicht implementiert.


packages:
---------

Testling1 benötigt das package ::comm::comm, Testling2 braucht zusätzlich tkdnd. In den Quellen im Lib-Verzeichnis sind die packages für Linux und Solaris enthalten.
