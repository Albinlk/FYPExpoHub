/*
 * FYP Expo Hub Handbook: interactive pieces.
 *
 *   <div data-hb-finder></div>            task finder (index.md)
 *   <div data-hb-checklist="key">…</div>   tick-off checklist with progress
 *   <div data-hb-explorer="flow"></div>    clickable workflow / status explorer
 *
 * Data lives in handbook-data.js (window.HB_DATA). Nothing leaves the
 * browser; ticked boxes are kept in localStorage when it is available.
 * Material's document$ re-runs this on every page, including instant loads.
 */
(function () {
  "use strict";

  var store = {
    get: function (k) {
      try { return window.localStorage.getItem(k); } catch (e) { return null; }
    },
    set: function (k, v) {
      try { window.localStorage.setItem(k, v); } catch (e) { /* storage blocked */ }
    },
    remove: function (k) {
      try { window.localStorage.removeItem(k); } catch (e) { /* storage blocked */ }
    },
  };

  function el(tag, attrs, children) {
    var node = document.createElement(tag);
    Object.keys(attrs || {}).forEach(function (k) {
      if (k === "text") node.textContent = attrs[k];
      else if (k === "class") node.className = attrs[k];
      else node.setAttribute(k, attrs[k]);
    });
    (children || []).forEach(function (c) { if (c) node.appendChild(c); });
    return node;
  }

  // Links in the data are relative to the site root (e.g. "guides/student/#reports").
  // Material's header logo always links to the site root, on every page.
  function siteUrl(path) {
    var logo = document.querySelector("a.md-header__button.md-logo");
    var base = logo && logo.href ? logo.href : document.baseURI;
    return new URL(path, base).href;
  }

  // ---------------------------------------------------------------- finder
  function initFinder(host) {
    var data = (window.HB_DATA || {}).tasks || [];
    if (!data.length || host.dataset.hbReady) return;
    host.dataset.hbReady = "1";
    var roles = [];
    data.forEach(function (t) { if (roles.indexOf(t.role) < 0) roles.push(t.role); });

    var roleSel = el("select", { id: "hb-role", class: "hb-select" });
    roleSel.appendChild(el("option", { value: "", text: "Choose…" }));
    roles.forEach(function (r) { roleSel.appendChild(el("option", { value: r, text: r })); });
    var taskSel = el("select", { id: "hb-task", class: "hb-select", disabled: "" });
    var go = el("a", { class: "md-button md-button--primary hb-go", "aria-disabled": "true", text: "Open guide section" });
    var hint = el("p", { class: "hb-finder__hint", "aria-live": "polite" });

    function fillTasks() {
      taskSel.innerHTML = "";
      var list = data.filter(function (t) { return t.role === roleSel.value; });
      taskSel.appendChild(el("option", { value: "", text: list.length ? "Choose a task…" : "Pick who you are first" }));
      list.forEach(function (t, i) { taskSel.appendChild(el("option", { value: String(data.indexOf(t)), text: t.task })); });
      if (list.length) taskSel.removeAttribute("disabled"); else taskSel.setAttribute("disabled", "");
      update();
      store.set("hb:finder:role", roleSel.value);
    }
    function update() {
      var t = data[Number(taskSel.value)];
      if (taskSel.value !== "" && t) {
        go.setAttribute("href", siteUrl(t.href));
        go.removeAttribute("aria-disabled");
        hint.textContent = t.hint || "";
      } else {
        go.removeAttribute("href");
        go.setAttribute("aria-disabled", "true");
        hint.textContent = "";
      }
    }
    roleSel.addEventListener("change", fillTasks);
    taskSel.addEventListener("change", update);
    taskSel.addEventListener("keydown", function (e) {
      if (e.key === "Enter" && go.getAttribute("href")) window.location.href = go.href;
    });

    host.appendChild(el("div", { class: "hb-finder__row" }, [
      el("label", { class: "hb-field", for: "hb-role" }, [el("span", { text: "I am a" }), roleSel]),
      el("label", { class: "hb-field", for: "hb-task" }, [el("span", { text: "I want to" }), taskSel]),
      go,
    ]));
    host.appendChild(hint);

    var saved = store.get("hb:finder:role");
    if (saved && roles.indexOf(saved) >= 0) { roleSel.value = saved; fillTasks(); }
  }

  // ------------------------------------------------------------ checklists
  function initChecklist(host) {
    if (host.dataset.hbReady) return;
    var key = host.getAttribute("data-hb-checklist");
    var boxes = Array.prototype.slice.call(host.querySelectorAll('input[type="checkbox"]'));
    if (!key || !boxes.length) return;
    host.dataset.hbReady = "1";

    var bar = el("div", { class: "hb-progress__bar", role: "progressbar", "aria-valuemin": "0", "aria-valuemax": String(boxes.length) });
    var fill = el("div", { class: "hb-progress__fill" });
    bar.appendChild(fill);
    var label = el("span", { class: "hb-progress__label" });
    var reset = el("button", { type: "button", class: "hb-progress__reset", text: "Reset" });
    var head = el("div", { class: "hb-progress" }, [label, bar, reset]);
    host.insertBefore(head, host.firstChild);

    function refresh() {
      var done = boxes.filter(function (b) { return b.checked; }).length;
      label.textContent = done === boxes.length ? "All " + done + " done" : done + " of " + boxes.length + " done";
      bar.setAttribute("aria-valuenow", String(done));
      fill.style.width = (100 * done / boxes.length) + "%";
      host.classList.toggle("hb-checklist--done", done === boxes.length);
    }
    boxes.forEach(function (b, i) {
      b.removeAttribute("disabled");
      var k = "hb:" + key + ":" + i;
      b.checked = store.get(k) === "1";
      b.addEventListener("change", function () {
        if (b.checked) store.set(k, "1"); else store.remove(k);
        refresh();
      });
    });
    reset.addEventListener("click", function () {
      boxes.forEach(function (b, i) { b.checked = false; store.remove("hb:" + key + ":" + i); });
      refresh();
    });
    refresh();
  }

  // -------------------------------------------------------------- explorer
  function initExplorer(host) {
    if (host.dataset.hbReady) return;
    var name = host.getAttribute("data-hb-explorer");
    var flow = ((window.HB_DATA || {}).flows || {})[name];
    if (!flow || !flow.steps || !flow.steps.length) return;
    host.dataset.hbReady = "1";
    host.classList.add("hb-explorer");

    var title = el("p", { class: "hb-explorer__title", text: flow.title || "Click a step to see what it means" });
    var chips = el("div", { class: "hb-explorer__chips", role: "toolbar", "aria-label": flow.title || name });
    var panel = el("div", { class: "hb-explorer__panel", "aria-live": "polite" });
    var buttons = [];

    function row(labelText, value) {
      if (!value) return null;
      return el("div", { class: "hb-explorer__row" }, [
        el("dt", { text: labelText }), el("dd", { text: value }),
      ]);
    }
    function show(i, fromUser) {
      var s = flow.steps[i];
      if (fromUser && buttons[i] && buttons[i].scrollIntoView) {
        buttons[i].scrollIntoView({ block: "nearest", inline: "center" });
      }
      buttons.forEach(function (b, j) {
        b.setAttribute("aria-pressed", j === i ? "true" : "false");
        b.tabIndex = j === i ? 0 : -1;
      });
      panel.innerHTML = "";
      var heading = el("p", { class: "hb-explorer__step" }, [
        el("span", { class: "hb-explorer__num", text: String(i + 1) + "/" + flow.steps.length }),
        el("strong", { text: s.label }),
      ]);
      if (s.code) heading.appendChild(el("code", { text: s.code }));
      panel.appendChild(heading);
      panel.appendChild(el("dl", {}, [
        row("What it means", s.meaning),
        row("Who acts next", s.who),
        row("What to do", s.todo),
      ]));
      var links = el("p", { class: "hb-explorer__links" });
      if (s.href) links.appendChild(el("a", { href: siteUrl(s.href), class: "md-button", text: "How to" }));
      if (s.app) links.appendChild(el("a", { href: s.app, target: "_blank", rel: "noopener", class: "md-button md-button--primary", text: "Open in app" }));
      if (links.childNodes.length) panel.appendChild(links);
    }

    flow.steps.forEach(function (s, i) {
      var b = el("button", { type: "button", class: "hb-chip" + (s.kind ? " hb-chip--" + s.kind : ""), "aria-pressed": "false", text: s.label });
      b.addEventListener("click", function () { show(i, true); });
      b.addEventListener("keydown", function (e) {
        var n = null;
        if (e.key === "ArrowRight" || e.key === "ArrowDown") n = Math.min(i + 1, buttons.length - 1);
        if (e.key === "ArrowLeft" || e.key === "ArrowUp") n = Math.max(i - 1, 0);
        if (e.key === "Home") n = 0;
        if (e.key === "End") n = buttons.length - 1;
        if (n !== null) { e.preventDefault(); show(n, true); buttons[n].focus(); }
      });
      buttons.push(b);
      chips.appendChild(b);
    });
    host.appendChild(title);
    host.appendChild(chips);
    host.appendChild(panel);
    show(0);
  }

  function initAll() {
    document.querySelectorAll("[data-hb-finder]").forEach(initFinder);
    document.querySelectorAll("[data-hb-checklist]").forEach(initChecklist);
    document.querySelectorAll("[data-hb-explorer]").forEach(initExplorer);
  }

  if (window.document$ && typeof window.document$.subscribe === "function") {
    window.document$.subscribe(initAll);
  } else if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", initAll);
  } else {
    initAll();
  }
})();
