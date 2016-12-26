{ stdenv, fetchurl, luaPackages, cairo, cmake, imagemagick, pkgconfig, gdk_pixbuf
, xorg, libstartup_notification, libxdg_basedir, libpthreadstubs
, xcb-util-cursor, makeWrapper, pango, gobjectIntrospection, unclutter
, compton, procps, iproute, coreutils, curl, alsaUtils, findutils, xterm
, which, dbus, nettools, git, asciidoc, doxygen
, xmlto, docbook_xml_dtd_45, docbook_xsl, findXMLCatalogs
, libxkbcommon, xcbutilxrm
}:

let
  version = "4.0";
in with luaPackages;

stdenv.mkDerivation rec {
  name = "awesome-${version}";

  src = fetchurl {
    url    = "http://github.com/awesomeWM/awesome-releases/raw/master/${name}.tar.xz";
    sha256 = "0czkcz67sab63gf5m2p2pgg05yinjx60hfb9rfyzdkkg28q9f02w";
  };

  meta = with stdenv.lib; {
    description = "Highly configurable, dynamic window manager for X";
    homepage    = https://awesomewm.org/;
    license     = licenses.gpl2Plus;
    maintainers = with maintainers; [ lovek323 rasendubi ];
    platforms   = platforms.linux;
  };

  nativeBuildInputs = [
    asciidoc
    cmake
    doxygen
    imagemagick
    makeWrapper
    pkgconfig
    xmlto docbook_xml_dtd_45 docbook_xsl findXMLCatalogs
  ];

  buildInputs = [
    cairo
    dbus
    gdk_pixbuf
    gobjectIntrospection
    git
    lgi
    libpthreadstubs
    libstartup_notification
    libxdg_basedir
    lua
    nettools
    pango
    xcb-util-cursor
    xorg.libXau
    xorg.libXdmcp
    xorg.libxcb
    xorg.libxshmfence
    xorg.xcbutil
    xorg.xcbutilimage
    xorg.xcbutilkeysyms
    xorg.xcbutilrenderutil
    xorg.xcbutilwm
    libxkbcommon
    xcbutilxrm
  ];

  #cmakeFlags = "-DGENERATE_MANPAGES=ON";

  LD_LIBRARY_PATH = "${stdenv.lib.makeLibraryPath [ cairo pango gobjectIntrospection ]}";
  GI_TYPELIB_PATH = "${pango.out}/lib/girepository-1.0";
  LUA_CPATH = "${lgi}/lib/lua/${lua.luaversion}/?.so";
  LUA_PATH  = "${lgi}/share/lua/${lua.luaversion}/?.lua;${lgi}/share/lua/${lua.luaversion}/lgi/?.lua";

  postInstall = ''
    wrapProgram $out/bin/awesome \
      --prefix LUA_CPATH ";" '"${lgi}/lib/lua/${lua.luaversion}/?.so"' \
      --prefix LUA_PATH ";" '"${lgi}/share/lua/${lua.luaversion}/?.lua;${lgi}/share/lua/${lua.luaversion}/lgi/?.lua"' \
      --prefix GI_TYPELIB_PATH : "$GI_TYPELIB_PATH" \
      --prefix LD_LIBRARY_PATH : "$LD_LIBRARY_PATH" \
      --prefix PATH : "${stdenv.lib.makeBinPath [ compton unclutter procps iproute coreutils curl alsaUtils findutils xterm ]}"

    wrapProgram $out/bin/awesome-client \
      --prefix PATH : "${which}/bin"
  '';

  passthru = {
    inherit lua;
  };
}
