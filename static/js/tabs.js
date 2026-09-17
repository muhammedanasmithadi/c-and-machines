"use strict";

(function initTabs() {
  const groups = document.querySelectorAll(".tabs");
  groups.forEach(function (group, gi) {
    const list = group.querySelector(".tab-list");
    const buttons = group.querySelectorAll(".tab-list button");
    const panels = group.querySelectorAll(".tab-panel");
    if (!buttons.length || !panels.length) return;

    if (list) list.setAttribute("role", "tablist");

    function select(idx) {
      buttons.forEach(function (b, i) {
        b.setAttribute("aria-selected", i === idx ? "true" : "false");
        b.tabIndex = i === idx ? 0 : -1;
      });
      panels.forEach(function (p, i) { p.hidden = i !== idx; });
    }

    let active = 0;
    buttons.forEach(function (button, i) {
      const tabId = "tab-g" + gi + "-" + i;
      const panelId = "panel-g" + gi + "-" + i;
      button.setAttribute("role", "tab");
      button.id = tabId;
      button.setAttribute("aria-controls", panelId);
      if (panels[i]) {
        panels[i].setAttribute("role", "tabpanel");
        panels[i].id = panelId;
        panels[i].setAttribute("aria-labelledby", tabId);
        panels[i].tabIndex = 0;
      }
      if (button.dataset.active === "true") active = i;
      button.addEventListener("click", function () {
        active = i;
        select(i);
      });
      button.addEventListener("keydown", function (ev) {
        let next = null;
        if (ev.key === "ArrowRight") next = (i + 1) % buttons.length;
        else if (ev.key === "ArrowLeft") next = (i - 1 + buttons.length) % buttons.length;
        else if (ev.key === "Home") next = 0;
        else if (ev.key === "End") next = buttons.length - 1;
        if (next === null) return;
        ev.preventDefault();
        active = next;
        select(next);
        buttons[next].focus();
      });
    });

    select(active);
  });
})();
