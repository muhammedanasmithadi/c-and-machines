"use strict";

(function initMemmap() {
  const steps = document.querySelectorAll("[data-memmap-step]");
  if (!steps.length) return;

  steps.forEach(function (step) {
    const map = step.querySelector(".memmap");
    if (!map) return;
    const rows = map.querySelectorAll(".memmap-row");
    const btn = step.querySelector(".push-btn");
    if (!btn || !rows.length) return;

    const states = rows[0].dataset.states ? rows[0].dataset.states.split(",") : [];
    const last = Math.max(states.length - 1, 0);
    let cur = 0;

    map.setAttribute("aria-live", "polite");

    function render(idx) {
      rows.forEach(function (row) {
        const seq = row.dataset.states ? row.dataset.states.split(",") : [];
        const cls = seq[idx] || row.dataset.base;
        row.className = "memmap-row " + (cls === "alloc" ? "memmap-alloc" : cls === "free" ? "memmap-free" : cls || "");
        const note = row.querySelector(".memmap-note");
        if (note) note.textContent = row.dataset.notes ? row.dataset.notes.split("|")[idx] || "" : "";
      });
      if (idx >= last) {
        btn.textContent = btn.dataset.resetLabel || "Start over";
      } else if (btn.dataset.labels) {
        const labels = btn.dataset.labels.split("|");
        btn.textContent = labels[idx] || btn.textContent;
      }
      if (btn.dataset.disabledAt && cur >= Number(btn.dataset.disabledAt)) {
        btn.setAttribute("disabled", "disabled");
      } else {
        btn.removeAttribute("disabled");
      }
    }

    btn.addEventListener("click", function () {
      if (cur >= last) cur = 0;
      else cur++;
      render(cur);
    });

    render(0);
  });
})();
