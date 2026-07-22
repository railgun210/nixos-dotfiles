{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: let
  stylixColors = config.lib.stylix.colors;
  theme-name = "greybird-stylix-${stylixColors.base00}";

  greybird-stylix = pkgs.stdenvNoCC.mkDerivation {
    pname = "greybird-stylix";
    version = "stylix";
    src = inputs.greybird;
    inherit theme-name;

    nativeBuildInputs = with pkgs; [meson ninja pkg-config sassc];
    buildInputs = with pkgs; [gdk-pixbuf librsvg];
    propagatedUserEnvPkgs = with pkgs; [gtk-engine-murrine];

    preConfigure = ''
      # Rename Greybird to theme-name to prevent conflicts
      sed -i -e 's\Greybird\${theme-name}\g' \
             ./light/index.theme
      sed -i -e 's\Greybird\${theme-name}\g' \
             ./dark/index.theme
      mv light/Greybird.emerald light/${theme-name}.emerald 2>/dev/null || true
      mv dark/Greybird.emerald dark/${theme-name}.emerald 2>/dev/null || true
      find . -type f -name 'meson.build' \
             | xargs sed -i -e 's\Greybird\${theme-name}\g'

      # Replace GTK3 colors in light theme _colors.scss
      sed -i -e 's\#fcfcfc\lighten(#${stylixColors.base01}, 3%)\g' \
             -e 's\#2d2e30\lighten(#${stylixColors.base01}, 3%)\g' \
             -e 's\white\#${stylixColors.base06}\g' \
             -e 's\#212121\#${stylixColors.base06}\g' \
             -e 's\#cecece\lighten(#${stylixColors.base01}, 8%)\g' \
             -e 's\#3b3e3f\lighten(#${stylixColors.base01}, 8%)\g' \
             -e 's\#3c3c3c\#${stylixColors.base05}\g' \
             -e 's\#eeeeec\#${stylixColors.base05}\g' \
             -e 's\#398ee7\#${stylixColors.base0E}\g' \
             -e 's\#eeeeee\#${stylixColors.base05}\g' \
             -e 's\#686868\#${stylixColors.base02}\g' \
             -e 's\#dae0e6\lighten(#${stylixColors.base01}, 5%)\g' \
             -e 's\#222\lighten(#${stylixColors.base01}, 5%)\g' \
             ./light/gtk-3.0/_colors.scss

      # Replace GTK3 colors in dark theme _colors.scss
      sed -i -e 's\#fcfcfc\lighten(#${stylixColors.base01}, 3%)\g' \
             -e 's\#2d2e30\lighten(#${stylixColors.base01}, 3%)\g' \
             -e 's\white\#${stylixColors.base06}\g' \
             -e 's\#212121\#${stylixColors.base06}\g' \
             -e 's\#cecece\lighten(#${stylixColors.base01}, 8%)\g' \
             -e 's\#3b3e3f\lighten(#${stylixColors.base01}, 8%)\g' \
             -e 's\#3c3c3c\#${stylixColors.base05}\g' \
             -e 's\#eeeeec\#${stylixColors.base05}\g' \
             -e 's\#398ee7\#${stylixColors.base0E}\g' \
             -e 's\#eeeeee\#${stylixColors.base05}\g' \
             -e 's\#686868\#${stylixColors.base02}\g' \
             -e 's\#dae0e6\lighten(#${stylixColors.base01}, 5%)\g' \
             -e 's\#222\lighten(#${stylixColors.base01}, 5%)\g' \
             ./dark/gtk-3.0/_colors.scss

      # Replace GTK2 colors in dark theme gtkrc
      sed -i -e 's\#3b3e3f\#${stylixColors.base01}\g' \
             -e 's\#398ee7\#${stylixColors.base0E}\g' \
             -e 's\#2d2e30\#${stylixColors.base01}\g' \
             -e 's\#eeeeec\#${stylixColors.base05}\g' \
             -e 's\#ffffff\#${stylixColors.base06}\g' \
             -e 's\#686868\#${stylixColors.base02}\g' \
             ./dark/gtk-2.0/gtkrc

      # Replace GTK2 colors in light theme gtkrc
      sed -i -e 's\#cecece\#${stylixColors.base01}\g' \
             -e 's\#398ee7\#${stylixColors.base0E}\g' \
             -e 's\#fcfcfc\#${stylixColors.base01}\g' \
             -e 's\#3c3c3c\#${stylixColors.base05}\g' \
             -e 's\#212121\#${stylixColors.base06}\g' \
             -e 's\#686868\#${stylixColors.base02}\g' \
             ./light/gtk-2.0/gtkrc
    '';

    passthru.updateScript = pkgs.gitUpdater {rev-prefix = "v";};
  };
in {
  options = {
    theming.greybird = {
      package = lib.mkOption {
        type = lib.types.package;
        default = greybird-stylix;
        description = "The Greybird GTK theme package built with Stylix colors";
      };
      themeName = lib.mkOption {
        type = lib.types.str;
        default = theme-name;
        description = "The name of the installed Greybird theme";
      };
    };
  };

  config = {
    stylix.targets.gtk.enable = false;

    gtk = {
      theme = {
        package = lib.mkDefault greybird-stylix;
        name = lib.mkDefault theme-name;
      };
    };
  };
}
