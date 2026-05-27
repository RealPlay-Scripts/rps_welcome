/* ── CFRP Welcome NUI Script ──────────────────────────────── */

let autoCloseTimer = null;
let discordUrl     = "https://discord.gg/P3pBmHtgYP";
let websiteUrl     = "https://your-website.com/signup";

window.addEventListener("message", function (event) {
    const data = event.data;
    if (!data || !data.action) return;
    if (data.action === "showWelcome") showWelcome(data);
    else if (data.action === "hide") hidePanel();
});

function showWelcome(data) {
    if (data.playerName)
        document.getElementById("player-name").textContent = data.playerName;
    if (data.discord) {
        discordUrl = data.discord;
        document.getElementById("discord-url").textContent =
            data.discord.replace("https://", "");
    }
    if (data.website) websiteUrl = data.website;

    const overlay = document.getElementById("overlay");
    overlay.classList.remove("hidden");
    overlay.classList.add("visible");
    spawnParticles(30);

    const autoClose = data.autoClose || 0;
    if (autoClose > 0) {
        startProgressBar(autoClose);
        autoCloseTimer = setTimeout(closePanel, autoClose);
    }
}

function hidePanel() {
    clearTimeout(autoCloseTimer);
    document.getElementById("overlay").classList.replace("visible", "hidden");
}

function closePanel() {
    hidePanel();
    fetch("https://cfrp_welcome/closeWelcome", {
        method: "POST", headers: { "Content-Type": "application/json" }, body: "{}"
    });
}

// ── Copy Discord link to clipboard ────────────────────────────
function copyDiscord() {
    const box       = document.getElementById("discord-box");
    const iconCopy  = document.getElementById("icon-copy");
    const iconCheck = document.getElementById("icon-check");
    const label     = document.getElementById("copy-label");

    // Use the FiveM-compatible clipboard write
    const input = document.createElement("textarea");
    input.value = discordUrl;
    input.style.position = "fixed";
    input.style.opacity  = "0";
    document.body.appendChild(input);
    input.focus();
    input.select();
    document.execCommand("copy");
    document.body.removeChild(input);

    // Visual feedback
    box.classList.add("copied");
    iconCopy.style.display  = "none";
    iconCheck.style.display = "block";
    label.textContent = "COPIED!";

    setTimeout(function () {
        box.classList.remove("copied");
        iconCopy.style.display  = "block";
        iconCheck.style.display = "none";
        label.textContent = "COPY";
    }, 2000);
}

// ── Website button ────────────────────────────────────────────
async function openWebsite() {
    try {
        await fetch("https://cfrp_welcome/openWebsite", {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({ url: websiteUrl })
        });
    } catch(e) {}
    hidePanel();
}

function startProgressBar(duration) {
    const fill = document.getElementById("progress-fill");
    fill.style.transition = "none";
    fill.style.width = "0%";
    requestAnimationFrame(() => requestAnimationFrame(() => {
        fill.style.transition = "width " + duration + "ms linear";
        fill.style.width = "100%";
    }));
}

function spawnParticles(count) {
    const container = document.getElementById("bg-particles");
    container.innerHTML = "";
    for (let i = 0; i < count; i++) {
        const p = document.createElement("div");
        p.className = "particle";
        const size = Math.random() * 3 + 1;
        p.style.cssText = [
            "width:" + size + "px", "height:" + size + "px",
            "left:" + (Math.random() * 100) + "%", "bottom:0",
            "animation-delay:" + (Math.random() * 8) + "s",
            "animation-duration:" + (Math.random() * 10 + 8) + "s"
        ].join(";");
        container.appendChild(p);
    }
}

document.addEventListener("keydown", e => { if (e.key === "Escape") closePanel(); });
