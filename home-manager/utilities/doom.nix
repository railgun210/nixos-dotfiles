{pkgs, ...}: {
  home.packages = with pkgs; [
    emacs

    # Icons for doom (nerd-icons looks for "Symbols Nerd Font Mono")
    nerd-fonts.symbols-only

    # :lang markdown (markdown-preview compiler)
    pandoc

    # :lang sh
    shfmt
    shellcheck

    # :lang web
    html-tidy
    stylelint
    js-beautify
  ];
}
