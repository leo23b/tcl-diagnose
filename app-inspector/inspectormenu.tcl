#
# menu.tcl
#
set gd(mainMenu) {    
    "&Datei" {} {} 0 {
         {command "Neu" {} "neue Instanz starten" {} -command NewInspector}
         {separator}
         {command "Update All" {} "alle Listen aktualisieren" {} -command  "UpdateListe alle"}
         {separator}
         {command "ps Info" {} "ps Protokoll" {} -command PSInfo}
         {separator}
         {command "List Packages" {} "alle Packages listen" {} -command ListPackages}
         {command "List auto_path" {} "auto_path listen" {} -command ListAutoPath}
         {command "List tm::path"  {} "tcl::tm::path listen" {} -command ListTMPath}
         {command "List Info loaded" {} "List info loaded" {} -command ListLoaded}
         {separator}
         {command "E&xit" {} "Programm beenden" {} -command CleanExit}
   }
   "&Widgets"   {} {}  0 {
      {checkbutton  "Filter Pack -in Options"  {} "Filter Pack -in Options"   {}
         -variable ::inspector::Filter_Pack_Options}
      {checkbutton  "Filter Window -class Options"  {} "Filter Window Class-Options"   {}
         -variable ::inspector::Filter_Window_Class_Options}
      {checkbutton  "Filter Empty Window Options"  {} "Filter Empty Window Options"   {}
         -variable ::inspector::Filter_Empty_Window_Options}
   }
      "&Help"   {} {}  0 {
         {command "Hilfe"  {} "Online-Hilfe anzeigen"   {} -command OnlineDoku}
         {command "Chronik" {} "Änderungschronik anzeigen"  {} \
                  -command ShowChronik}
         {command "Version" {} "Programmversion anzeigen"  {} \
                  -command ShowVersion}
      }
}

# Muster
    set descmenu {
        "&File" {} {} 0 {
            {command "&New"     {} "Create a new document"     {Ctrl n} -command Menu::new}
            {command "&Open..." {} "Open an existing document" {Ctrl o} -command Menu::open}
            {command "&Save"    open "Save the document" {Ctrl s} -command Menu::save}
            {cascade  "&Export"  {} export 0 {
                {command "Format &1" open "Export document to format 1" {} -command {Menu::export 1}}
                {command "Format &2" open "Export document to format 2" {} -command {Menu::export 2}}
            }}
            {separator}
            {cascade "&Recent files" {} recent 0 {}}
            {separator}
            {command "E&xit" {} "Exit the application" {} -command Menu::exit}
        }
        "&Options" {} {} 0 {
            {checkbutton "Toolbar" {} "Show/hide toolbar" {} 
                -variable Menu::_drawtoolbar
                -command  {$Menu::_mainframe showtoolbar toolbar $Menu::_drawtoolbar}
            }
        }
    }
# -*- coding: ISO8859-15 -*-