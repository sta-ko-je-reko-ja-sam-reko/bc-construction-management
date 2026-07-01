// Startup.js
// Creates the root container the Gantt chart draws into, then signals readiness to AL.
(function () {
    "use strict";

    var existing = document.getElementById("cons-gantt");
    if (!existing) {
        var root = document.createElement("div");
        root.id = "cons-gantt";
        root.className = "cons-gantt";
        document.body.appendChild(root);
    }

    Microsoft.Dynamics.NAV.InvokeExtensibilityMethod("ControlAddInReady", []);
})();
