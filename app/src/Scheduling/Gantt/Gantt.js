// Gantt.js
// Read-only Gantt renderer. Vanilla JS, no external libraries.
// AL calls the global DrawGantt(DataJson) method declared on the control add-in.

// One day in milliseconds, used for date<->pixel math.
var CONS_GANTT_DAY_MS = 24 * 60 * 60 * 1000;

// Parses an ISO/yyyy-mm-dd date string into a UTC Date, or null when empty/invalid.
function consGanttParseDate(value) {
    if (!value) {
        return null;
    }
    // Accept "yyyy-mm-dd" and full ISO; take the date part only.
    var datePart = String(value).substring(0, 10);
    var bits = datePart.split("-");
    if (bits.length < 3) {
        return null;
    }
    var year = parseInt(bits[0], 10);
    var month = parseInt(bits[1], 10);
    var day = parseInt(bits[2], 10);
    if (isNaN(year) || isNaN(month) || isNaN(day)) {
        return null;
    }
    return new Date(Date.UTC(year, month - 1, day));
}

// Whole-day difference between two UTC dates.
function consGanttDayDiff(from, to) {
    return Math.round((to.getTime() - from.getTime()) / CONS_GANTT_DAY_MS);
}

// Formats a UTC date as "yyyy-mm-dd" for axis tick labels.
function consGanttFormatDate(d) {
    function pad(n) {
        return n < 10 ? "0" + n : "" + n;
    }
    return d.getUTCFullYear() + "-" + pad(d.getUTCMonth() + 1) + "-" + pad(d.getUTCDate());
}

// Clears the root and shows a centered informational message.
function consGanttShowMessage(root, text) {
    root.innerHTML = "";
    var msg = document.createElement("div");
    msg.className = "cons-gantt-empty";
    msg.textContent = text;
    root.appendChild(msg);
}

// Global draw entry point invoked from AL.
function DrawGantt(DataJson) {
    var root = document.getElementById("cons-gantt");
    if (!root) {
        return;
    }

    var data;
    try {
        data = JSON.parse(DataJson);
    } catch (e) {
        consGanttShowMessage(root, "Unable to read schedule data.");
        return;
    }

    var tasks = (data && data.tasks) ? data.tasks : [];
    var rangeStart = consGanttParseDate(data ? data.rangeStart : null);
    var rangeEnd = consGanttParseDate(data ? data.rangeEnd : null);

    if (!tasks.length || !rangeStart || !rangeEnd || rangeEnd.getTime() <= rangeStart.getTime()) {
        consGanttShowMessage(root, "No scheduled tasks to display.");
        return;
    }

    var totalDays = consGanttDayDiff(rangeStart, rangeEnd);
    if (totalDays <= 0) {
        consGanttShowMessage(root, "No scheduled tasks to display.");
        return;
    }

    // Pixels per day; keep a sensible minimum width so short projects stay readable.
    var pxPerDay = 24;
    var chartWidth = totalDays * pxPerDay;
    if (chartWidth < 320) {
        chartWidth = 320;
        pxPerDay = chartWidth / totalDays;
    }

    root.innerHTML = "";

    var container = document.createElement("div");
    container.className = "cons-gantt-container";

    // ---- Header / date axis ----------------------------------------------
    var header = document.createElement("div");
    header.className = "cons-gantt-header";

    var labelSpacer = document.createElement("div");
    labelSpacer.className = "cons-gantt-label-col cons-gantt-header-cell";
    labelSpacer.textContent = "Task";
    header.appendChild(labelSpacer);

    var axis = document.createElement("div");
    axis.className = "cons-gantt-axis";
    axis.style.width = chartWidth + "px";

    // Choose tick spacing: weekly for short spans, monthly otherwise.
    var useMonthly = totalDays > 120;
    consGanttBuildAxisTicks(axis, rangeStart, rangeEnd, totalDays, pxPerDay, useMonthly);
    header.appendChild(axis);
    container.appendChild(header);

    // ---- Body / one row per task -----------------------------------------
    var body = document.createElement("div");
    body.className = "cons-gantt-body";

    // Index task no. -> {start,end} for dependency line computation.
    var posByNo = {};
    var i;
    for (i = 0; i < tasks.length; i++) {
        var t = tasks[i];
        var ts = consGanttParseDate(t.start);
        var te = consGanttParseDate(t.end);
        if (ts && te) {
            posByNo[String(t.no)] = {
                left: consGanttDayDiff(rangeStart, ts) * pxPerDay,
                right: (consGanttDayDiff(rangeStart, te) + 1) * pxPerDay,
                rowIndex: i
            };
        }
    }

    for (i = 0; i < tasks.length; i++) {
        var row = consGanttBuildRow(tasks[i], rangeStart, pxPerDay, chartWidth, posByNo);
        body.appendChild(row);
    }

    container.appendChild(body);
    root.appendChild(container);
}

// Builds the date axis tick marks into the axis element.
function consGanttBuildAxisTicks(axis, rangeStart, rangeEnd, totalDays, pxPerDay, useMonthly) {
    if (useMonthly) {
        // Walk month boundaries.
        var cursor = new Date(Date.UTC(rangeStart.getUTCFullYear(), rangeStart.getUTCMonth(), 1));
        while (cursor.getTime() <= rangeEnd.getTime()) {
            var offsetDays = consGanttDayDiff(rangeStart, cursor);
            if (offsetDays >= 0 && offsetDays <= totalDays) {
                consGanttAddTick(axis, offsetDays * pxPerDay, consGanttFormatDate(cursor));
            }
            cursor = new Date(Date.UTC(cursor.getUTCFullYear(), cursor.getUTCMonth() + 1, 1));
        }
    } else {
        // Weekly ticks every 7 days from range start.
        for (var d = 0; d <= totalDays; d += 7) {
            var tick = new Date(rangeStart.getTime() + d * CONS_GANTT_DAY_MS);
            consGanttAddTick(axis, d * pxPerDay, consGanttFormatDate(tick));
        }
    }
}

// Adds a single axis tick at the given pixel offset.
function consGanttAddTick(axis, leftPx, label) {
    var tick = document.createElement("div");
    tick.className = "cons-gantt-tick";
    tick.style.left = leftPx + "px";
    var lbl = document.createElement("span");
    lbl.className = "cons-gantt-tick-label";
    lbl.textContent = label;
    tick.appendChild(lbl);
    axis.appendChild(tick);
}

// Builds a single task row: indented label + timeline cell with bar, fill and dependencies.
function consGanttBuildRow(task, rangeStart, pxPerDay, chartWidth, posByNo) {
    var isSummary = task.type && task.type !== "Posting";

    var row = document.createElement("div");
    row.className = "cons-gantt-row" + (isSummary ? " cons-gantt-row-summary" : "");
    row.setAttribute("data-task-no", task.no);

    // Label column (indented).
    var label = document.createElement("div");
    label.className = "cons-gantt-label-col";
    var indent = (task.indentation ? task.indentation : 0) * 14;
    label.style.paddingLeft = (6 + indent) + "px";

    var labelText = (task.no ? task.no + "  " : "") + (task.description ? task.description : "");
    label.textContent = labelText;
    label.title = labelText;
    row.appendChild(label);

    // Timeline cell.
    var cell = document.createElement("div");
    cell.className = "cons-gantt-cell";
    cell.style.width = chartWidth + "px";

    var ts = consGanttParseDate(task.start);
    var te = consGanttParseDate(task.end);

    if (ts && te && te.getTime() >= ts.getTime()) {
        var leftPx = consGanttDayDiff(rangeStart, ts) * pxPerDay;
        var widthPx = (consGanttDayDiff(ts, te) + 1) * pxPerDay;
        if (widthPx < 4) {
            widthPx = 4;
        }

        var bar = document.createElement("div");
        bar.className = "cons-gantt-bar" + (isSummary ? " cons-gantt-bar-summary" : "");
        bar.style.left = leftPx + "px";
        bar.style.width = widthPx + "px";

        // Percent complete fill overlay.
        var pct = task.pct ? Number(task.pct) : 0;
        if (pct < 0) {
            pct = 0;
        }
        if (pct > 100) {
            pct = 100;
        }
        var fill = document.createElement("div");
        fill.className = "cons-gantt-fill";
        fill.style.width = pct + "%";
        bar.appendChild(fill);

        var pctLabel = document.createElement("span");
        pctLabel.className = "cons-gantt-pct-label";
        pctLabel.textContent = Math.round(pct) + "%";
        bar.appendChild(pctLabel);

        cell.appendChild(bar);

        // Dependency indicators: thin connector from each predecessor's bar end to this bar start.
        consGanttBuildDependencies(cell, task, posByNo, leftPx);
    }

    row.appendChild(cell);

    // Click anywhere on the row notifies AL.
    row.addEventListener("click", function () {
        Microsoft.Dynamics.NAV.InvokeExtensibilityMethod("TaskClicked", [String(task.no)]);
    });

    return row;
}

// Draws horizontal connector stubs from each predecessor's end to this task's start.
// Same-row finish->start is rendered as a simple horizontal connector; cross-row links
// are simplified to a short stub plus a predecessor marker (full SVG routing omitted by design).
function consGanttBuildDependencies(cell, task, posByNo, taskLeftPx) {
    var preds = task.predecessors;
    if (!preds || !preds.length) {
        return;
    }
    for (var p = 0; p < preds.length; p++) {
        var predPos = posByNo[String(preds[p])];
        if (!predPos) {
            continue;
        }
        var fromX = predPos.right;
        var toX = taskLeftPx;
        if (toX <= fromX) {
            // Predecessor ends after this task starts; skip drawing a backward line.
            continue;
        }
        var line = document.createElement("div");
        line.className = "cons-gantt-dep";
        line.style.left = fromX + "px";
        line.style.width = (toX - fromX) + "px";
        line.title = "Depends on " + preds[p];
        cell.appendChild(line);

        var arrow = document.createElement("div");
        arrow.className = "cons-gantt-dep-arrow";
        arrow.style.left = (toX - 4) + "px";
        cell.appendChild(arrow);
    }
}
