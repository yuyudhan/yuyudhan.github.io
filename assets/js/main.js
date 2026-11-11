// main.js: the site's only script. Adds a "Copy" button to every code block.
// The page works without it; the buttons appear only where the Clipboard API exists.

function initCodeCopy() {
    if (!navigator.clipboard) {
        return;
    }

    const blocks = document.querySelectorAll("pre");
    blocks.forEach(function (pre) {
        const code = pre.querySelector("code") || pre;
        const wrapper = document.createElement("div");
        wrapper.className = "code-block";
        pre.parentNode.insertBefore(wrapper, pre);
        wrapper.appendChild(pre);

        const button = document.createElement("button");
        button.type = "button";
        button.className = "copy-button";
        button.textContent = "Copy";
        button.setAttribute("aria-live", "polite");
        wrapper.appendChild(button);

        let resetTimer = 0;
        button.addEventListener("click", async function () {
            try {
                await navigator.clipboard.writeText(code.textContent.replace(/\n$/, ""));
                button.textContent = "Copied";
                button.dataset.copied = "";
            } catch (error) {
                button.textContent = "Copy failed";
                console.warn("Copy failed:", error);
            }
            window.clearTimeout(resetTimer);
            resetTimer = window.setTimeout(function () {
                button.textContent = "Copy";
                delete button.dataset.copied;
            }, 2000);
        });
    });
}

initCodeCopy();
