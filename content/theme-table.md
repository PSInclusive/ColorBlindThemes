---
title: "Theme table"
lane: "08"
laneName: "Table"
slug: "theme-table"
weight: 14
---

Every theme that has a computed [verification](../verification/) score, in one table. The score is
the **closest pair of signal colors under the worst of the three dichromacies**, in ΔE00 (higher is
better): **STRONG** is 8 or more, **ok** is 3 or more, **WEAK** is under 3. Themes with dark and
light modes get one score per mode. Themes without a published source link are shown unlinked.

| Theme | Type | Verification score | Notes |
|---|---|---|---|
| [GitHub Colorblind (dark)](https://github.com/primer/primitives) | Flagship | 1.1 WEAK | Primer tokens; keyword orange and warning amber collapse under deuteranopia |
| [GitHub Colorblind (light)](https://github.com/primer/primitives) | Flagship | 1.7 WEAK | Primer tokens; keyword orange and warning amber collapse under deuteranopia |
| [Modus (deuteranopia) (dark)](https://protesilaos.com/emacs/modus-themes) | Flagship | 1.1 WEAK | Emacs; weakest pair is a red/green the variant deliberately stops using as a signal |
| [Modus (deuteranopia) (light)](https://protesilaos.com/emacs/modus-themes) | Flagship | 1.5 WEAK | Emacs; weakest pair is a red/green the variant deliberately stops using as a signal |
| [ef-themes (dark)](https://github.com/protesilaos/ef-themes) | Flagship | 1.7 WEAK | Emacs; errors remapped to yellow |
| [ef-themes (light)](https://github.com/protesilaos/ef-themes) | Flagship | 4.0 ok | Emacs; errors remapped to yellow |
| [Pierre (dark)](https://github.com/pierrecomputer/pierre) | Flagship | 1.5 WEAK | Ships a build-time simulation gate |
| [Pierre (light)](https://github.com/pierrecomputer/pierre) | Flagship | 6.5 ok | Ships a build-time simulation gate |
| [datum (dark)](https://datum.w0zro.com) | Flagship | 4.0 ok | Okabe-Ito hues rebuilt in OKLCH |
| [datum (light)](https://datum.w0zro.com) | Flagship | 4.3 ok | Okabe-Ito hues rebuilt in OKLCH |
| [Cindervale Accessible (dark)](https://github.com/erenthedeveloper0/cindervale) | Editor | 9.6 STRONG | CVD-measured dark and light pair |
| [Blinds (dark)](https://github.com/orbulant/blinds-theme) | Editor | 8.7 STRONG | VS Code, deuteranopia |
| [Blinds (light)](https://github.com/orbulant/blinds-theme) | Editor | 5.3 ok | VS Code, deuteranopia |
| [Opo (dark)](https://github.com/IschaGast/opo-theme) | Editor | 5.4 ok | OKLCH-based, heavily engineered |
| [Opo (light)](https://github.com/IschaGast/opo-theme) | Editor | 8.2 STRONG | OKLCH-based, heavily engineered |
| [Color Blind Themes (dark)](https://github.com/goofygoobers/color-blind-vscode-theme) | Editor | 7.3 ok | VS Code; author has CVD |
| [vim-dichromatic (dark)](https://github.com/romainl/vim-dichromatic) | Editor | 4.8 ok | Vim and Neovim |
| [Monokai Deuteranopia (dark)](https://github.com/felipezarco/monokai-deuteranopia-colorblind) | Editor | 4.1 ok | VS Code |
| [Gentle (dark)](https://marketplace.visualstudio.com/items?itemName=carlossalguero.gentle-theme) | Editor | 4.0 ok | VS Code; teal and orange, WCAG AA |
| [Gentle (light)](https://marketplace.visualstudio.com/items?itemName=carlossalguero.gentle-theme) | Editor | 1.6 WEAK | VS Code; teal and orange, WCAG AA |
| [Hakimi Deuteranopia Safe (dark)](https://github.com/zogwosh/hakimi-theme) | Editor | 3.5 ok | Zed, VS Code, Obsidian |
| [Hakimi Deuteranopia Safe (light)](https://github.com/zogwosh/hakimi-theme) | Editor | 0.9 WEAK | Zed, VS Code, Obsidian |
| [One Dark Pro Colorblind (dark)](https://github.com/suhaybu/OneDarkPro-Colorblind) | Editor | 3.4 ok | VS Code, deuteranopia |
| [Shroom Space (dark)](https://github.com/WyattAu/shroom-theme) | Editor | 2.7 WEAK | CI-enforced, yet one pair still collapses under tritanopia |
| [ColorSafe Themes (dark)](https://github.com/clementsehan/color-safe-themes-jetbrains) | Editor | 2.6 WEAK | JetBrains |
| [morimo (dark)](https://github.com/ttak0422/morimo) | Editor | 1.4 WEAK | Neovim |
| [vision.nvim (dark)](https://github.com/shrik3/vision.nvim) | Editor | 0.9 WEAK | Neovim; archived |
| [Dalton (dark)](https://github.com/gerchowl/dalton-colorscheme) | Terminal | 3.8 ok | Ghostty, iTerm2, lazygit |
| [Dalton (light)](https://github.com/gerchowl/dalton-colorscheme) | Terminal | 3.8 ok | Ghostty, iTerm2, lazygit |
| [dracula-colorblind (dark)](https://github.com/hakarune/colorblind-terminal-themes) | Terminal | 3.6 ok | From the hakarune terminal collection |
| [GitButler (dark)](https://github.com/gitbutlerapp/gitbutler/pull/10146) | App | 42.3 STRONG | Strongest palette in the catalog |
| [GitButler (light)](https://github.com/gitbutlerapp/gitbutler/pull/10146) | App | 55.2 STRONG | Strongest palette in the catalog |
| [Cura Colorblind Assist (dark)](https://github.com/Ultimaker/Cura/pull/5928) | App | 15.4 STRONG | Layer-view colors; oldest first-party entry besides Jenkins |
| [Kiro (dark)](https://github.com/kirodotdev/KiroCrew/pull/24480) | App | 14.1 STRONG | Built-in theme pair with a simulation test |
| [Kiro (light)](https://github.com/kirodotdev/KiroCrew/pull/24480) | App | 12.7 STRONG | Built-in theme pair with a simulation test |
| [SimpleCov (dark)](https://github.com/simplecov-ruby/simplecov/pull/1257) | App | 13.4 STRONG | Light mode inherits GitHub's orange/amber weakness |
| [SimpleCov (light)](https://github.com/simplecov-ruby/simplecov/pull/1257) | App | 1.0 WEAK | Light mode inherits GitHub's orange/amber weakness |
| [plannotator (dark)](https://github.com/backnotprop/plannotator/pull/1192) | App | 11.9 STRONG |  |
| [plannotator (light)](https://github.com/backnotprop/plannotator/pull/1192) | App | 2.1 WEAK |  |
| [iamb (dark)](https://github.com/ulyssa/iamb/pull/822) | App | 11.1 STRONG | Okabe-Ito; encrypted indicator is blue, not green |
| [OpenFront.io (dark)](https://github.com/openfrontio/OpenFrontIO/pull/4150) | App | 11.1 STRONG | Okabe-Ito team colors |
| [Jenkins Wall Display (light)](https://github.com/jenkinsci/walldisplay-plugin/pull/3) | App | 9.4 STRONG | Oldest app-level CVD theme found (2012) |
| [deepinv (light)](https://github.com/deepinv/deepinv/pull/1420) | App | 9.0 STRONG | Seaborn colorblind palette |
| [narmi (light)](https://github.com/narmi/design_system/pull/2246) | App | 8.9 STRONG | Design-token CVD modes |
| [Wireshark (dark)](https://github.com/wireshark/wireshark/tree/main/resources/themes) | App | 8.3 STRONG | Gated by a test that checks every token under each deficiency |
| [Wireshark (light)](https://github.com/wireshark/wireshark/tree/main/resources/themes) | App | 12.7 STRONG | Gated by a test that checks every token under each deficiency |
| [Insomnia (dark)](https://github.com/Kong/insomnia/pull/4081) | App | 8.7 STRONG | Blue/orange HTTP method colors |
| [Lx Deep Sea (dark)](https://store.kde.org/p/1711107) | App | 7.2 ok | KDE Plasma color scheme |
| [Pitaya Smoothie (dark)](https://github.com/trallard/pitaya_smoothie) | App | 4.9 ok | JupyterLab |
| [Moira (light)](https://github.com/moira-alert/web2.0/pull/668) | App | 5.7 ok | Icons back up the hue |
| Talishar (deuteranopia palette) | App | 7.2 ok | One palette per dichromacy; each is strongest under its own target |
| Talishar (protanopia palette) | App | 5.0 ok | One palette per dichromacy; each is strongest under its own target |
| Talishar (tritanopia palette) | App | 2.6 WEAK | One palette per dichromacy; each is strongest under its own target |
| [Gitea (dark)](https://github.com/go-gitea/gitea/pull/30625) | App | 2.0 WEAK | Inherits GitHub's orange/amber pair |
| [Gitea (light)](https://github.com/go-gitea/gitea/pull/30625) | App | 2.6 WEAK | Inherits GitHub's orange/amber pair |
| [Gemini CLI (dark)](https://github.com/google-gemini/gemini-cli/pull/15504) | App | 1.1 WEAK | Primer tokens verbatim |
| [Gemini CLI (light)](https://github.com/google-gemini/gemini-cli/pull/15504) | App | 1.7 WEAK | Primer tokens verbatim |
| [Grafana Colorblind (dark)](https://github.com/grafana/grafana/pull/116953) | App | 2.3 WEAK | Four UI themes plus a Wong-palette chart option |
| [Grafana Colorblind (light)](https://github.com/grafana/grafana/pull/116953) | App | 0.4 WEAK | Four UI themes plus a Wong-palette chart option |
| [coder (dark)](https://github.com/coder/coder/pull/24672) | App | 0.4 WEAK | Cites Okabe-Ito; weak pair is under protanopia and deuteranopia |

A WEAK score is not "broken": the metric measures hue and lightness collapse only, not icons, font
weight, or other redundant cues. See [Verification](../verification/) for the caveats.

<style>
.article th[data-sort]{cursor:pointer;user-select:none}
.article th[data-sort]::after{content:" \2195";opacity:.5}
.article th[data-sort="asc"]::after{content:" \25B2";opacity:1}
.article th[data-sort="desc"]::after{content:" \25BC";opacity:1}
</style>
<script>
document.addEventListener("DOMContentLoaded",function(){
  var table=document.querySelector(".article table");
  if(!table)return;
  var body=table.tBodies[0];
  table.tHead.rows[0].querySelectorAll("th").forEach(function(th,col){
    if(col>2)return;
    th.setAttribute("data-sort","none");
    th.tabIndex=0;
    function sort(){
      var dir=th.getAttribute("data-sort")==="asc"?"desc":"asc";
      table.querySelectorAll("th").forEach(function(h){if(h.hasAttribute("data-sort"))h.setAttribute("data-sort","none")});
      th.setAttribute("data-sort",dir);
      var rows=Array.prototype.slice.call(body.rows);
      rows.sort(function(a,b){
        var x=a.cells[col].textContent.trim(),y=b.cells[col].textContent.trim();
        var r=col===2?parseFloat(x)-parseFloat(y):x.localeCompare(y,undefined,{sensitivity:"base"});
        return dir==="asc"?r:-r;
      });
      rows.forEach(function(r){body.appendChild(r)});
    }
    th.addEventListener("click",sort);
    th.addEventListener("keydown",function(e){if(e.key==="Enter"||e.key===" "){e.preventDefault();sort()}});
  });
});
</script>
