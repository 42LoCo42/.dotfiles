function waitForLoad() {
	return new Promise((resolve) => {
		if (document.readyState === "complete") {
			resolve();
		} else {
			window.addEventListener("load", resolve);
		}
	});
}

async function wait(delay) {
	return new Promise((r) => setTimeout(r, delay));
}

async function typewriter(target, delay, initialPause) {
	const source = target.cloneNode(true);
	target.innerHTML = "";
	target.style.removeProperty("display");

	await waitForLoad();

	const cursor = document.createElement("cursor");
	cursor.textContent = "|";
	target.appendChild(cursor);

	await wait(initialPause);
	await run(source, target);

	async function run(source, target) {
		for (let c of source.childNodes) {
			if (c instanceof Text) {
				const el = document.createTextNode("");
				target.appendChild(el);

				for (c of c.textContent) {
					await wait(delay);
					el.textContent += c;
				}
			} else {
				target.appendChild(cursor);

				if (c.tagName === "X-TYPW") {
					for (let a of c.attributes) {
						switch (a.name) {
							case "pause":
								await wait(Number(a.value));
								break;
							case "delay":
								delay = Number(a.value);
								break;
							case "hidec":
								cursor.hidden = true;
								break;
						}
					}
				} else if (c.tagName === "IMG") {
					c.style.animation = "blink 3s";
				}

				const el = c.cloneNode(false);
				target.insertBefore(el, cursor);
				document.scrollingElement.scrollTop =
					document.scrollingElement.scrollHeight;

				if (el.offsetParent !== null) {
					await run(c, el, delay);
				}
			}
		}
	}
}

(async () => {
	const SKIP_KEY = "skipAnimation" + location.pathname;
	const terminal = document.getElementById("terminal");

	if (sessionStorage.getItem(SKIP_KEY) === null) {
		await typewriter(terminal, 5, 500);
		sessionStorage.setItem(SKIP_KEY, 1);
	} else {
		await waitForLoad();
		terminal.style.removeProperty("display");
	}
})();
