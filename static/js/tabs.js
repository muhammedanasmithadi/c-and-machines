"use strict";

(function initTabs() {
  const groups = document.querySelectorAll(".tabs");
  groups.forEach(function (group) {
    const buttons = group.querySelectorAll(".tab-list button");
    const panels = group.querySelectorAll(".tab-panel");
    buttons.forEach(function (button, i) {
      button.setAttribute("aria-selected", button.dataset.active === "true");
      if (!panels[i].hasAttribute("hidden")) {
        panels[i].hidden = true;
      }
      if (button.dataset.active === "true") {
        button.setAttribute("aria-selected", "true");
        panels[i].hidden = false;
      }
      button.addEventListener("click", function () {
        buttons.forEach(function (b) { b.setAttribute("aria-selected", "false"); });
        panels.forEach(function (p) { p.hidden = true; });
        button.setAttribute("aria-selected", "true");
        panels[i].hidden = false;
      });
    });
  });
})();