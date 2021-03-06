namespace eval hv3 { set {version($Id: hv3_home.tcl,v 1.31 2007/10/03 10:06:38 danielk1977 Exp $)} 1 }

# Register the home: scheme handler with ::hv3::protocol $protocol.
#
proc ::hv3::home_scheme_init {hv3 protocol} {
  set dir $::hv3::maindir
  $protocol schemehandler home [list ::hv3::home_request $protocol $hv3 $dir]
}

proc ::hv3::create_domref {} {

  append doctop {
    <H1 class=title>Hv3 DOM Object Reference</H1><DIV class="toc">
  }
  foreach c [lsort [::hv3::dom2::classlist]] {
    append docmain [::hv3::dom2::document $c]
    append doctop [subst {
      <DIV class="tocentry"><A href="#${c}">$c</A></DIV>
    }]
  }
  append doctop {
    </DIV>
    <STYLE>
      H1 {
        clear:both;
      }
      H2 {
        margin-left: 1cm;
      }
      TABLE {
        width: 90%;
        margin-left: 2cm;
      }
      TD {
        vertical-align: top;
        padding: 0 5px;
        width: 100%;
      }
      .mode {
        width: auto;
      }
      TH {
        vertical-align: top;
        text-align: left;
        padding: 0 5px;
        background-color: #d9d9d9;
        white-space: nowrap;
      }
      UL {
        list-style-type: none;
      }
      .tocentry {
        float: left;
        width: 32ex;
      }
      .toc {
        margin-left: 2cm;
        overflow: auto;
      }
      .title {
        text-align: center;
      }
      .uri {
        margin-left: 1cm;
      }
      .nodocs {
        color: silver;
      }
    </STYLE>

    <P>
      This document is a reference to Hv3's version of the Document Object
      Model (DOM). It is generated by the DOM implementation
      itself and augmented by comments in the DOM source code. It is always
      available from within Hv3 itself by selecting the 
      "Debug->DOM Reference..." menu option. The intended audience for
      this document already has a strong grasp of cross-browser DOM
      principles.
    </P>

    <P>
      Any hyperlinked documents (except for internal references to other
      parts of this document) are for informational purposes only. They
      are not part of Hv3 documentation.
    </P>
  }
  set ::hv3::dom::Documentation $doctop
  append ::hv3::dom::Documentation $docmain
}

# When a URI with the scheme "home:" is requested, this proc is invoked.
#
proc ::hv3::home_request {http hv3 dir downloadHandle} {

  set obj [::tkhtml::uri [$downloadHandle cget -uri]]
  set authority [$obj authority]
  set path      [$obj path]
  $obj destroy

  switch -exact -- $authority {

    blank { }

    about {
      set tkhtml_version [::tkhtml::version]
      set hv3_version ""
      foreach version [lsort [array names ::hv3::version]] {
        set t [string trim [string range $version 4 end-1]]
        append hv3_version "$t\n"
      }
    
      set html [subst {
        <html> <head> </head> <body>
        <h1>Tkhtml Source Code Versions</h1>
        <pre>$tkhtml_version</pre>
        <h1>Hv3 Source Code Versions</h1>
        <pre>$hv3_version</pre>
        </body> </html>
      }]
    
      $downloadHandle append $html
    }

    domref {
      $downloadHandle append $::hv3::dom::Documentation
    }

    bug {
      set uri [::tkhtml::decode [string range $path 1 end]]
      after idle [list \
          ::hv3::bugreport::init [$downloadHandle cget -hv3] $uri
      ]
    }

    bookmarks_left { }
    bookmarks_right { }

    bookmarks {
      if {$path eq "" || $path eq "/"} {
        $downloadHandle append {
          <FRAMESET cols="33%,*">
            <FRAME src="home://bookmarks_left">
            <FRAME src="home://bookmarks/folder/0">
        }
        after idle [list ::hv3::bookmarks::init [$downloadHandle cget -hv3]]
      } else {
        $downloadHandle append [::hv3::bookmarks::requestpage $path]
      }
    }
  }

  $downloadHandle finish
}

proc ::hv3::hv3_version {} {
  set src [split [::tkhtml::version] "\n"]
  foreach version [lsort [array names ::hv3::version]] {
    set t [string trim [string range $version 5 end-1]]
    lappend src $t
  }
  foreach s $src {
    lappend datelist [lrange $s 2 3]
  }
  return [lindex [lsort -decreasing $datelist] 0]
}

