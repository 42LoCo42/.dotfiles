async function wait(delay) {
	await new Promise(r => setTimeout(r, delay))
}

async function typewriter(element, delay) {
	const cloned = element.cloneNode(true)
	element.innerHTML = ""

	const cursor = document.createElement("cursor")
	cursor.textContent = "|"

	await run(cloned, element)

	async function run(source, target) {
		for (let c of source.childNodes) {
			if (c instanceof Text) {
				const el = document.createTextNode("")
				target.appendChild(el)

				for (c of c.textContent) {
					await wait(delay)
					el.textContent += c
				}
			} else {
				target.appendChild(cursor)

				if (c.tagName === "TYPW-CTRL") {
					for (let a of c.attributes) {
						switch (a.name) {
							case "pause":
								await wait(Number(a.value))
								break;
							case "delay":
								delay = Number(a.value)
								break
							case "hidec":
								cursor.hidden = true
								break;
						}
					}
				} else if (c.tagName === "IMG") {
					c.style.animation = "blink 3s"
				}

				const el = c.cloneNode(false)
				target.insertBefore(el, cursor)
				document.scrollingElement.scrollTop = document.scrollingElement.scrollHeight

				if (el.offsetParent !== null) {
					await run(c, el, delay)
				}
			}
		}
	}
}

const SKIP_KEY = "skipAnimation" + location.pathname
if (sessionStorage.getItem(SKIP_KEY) === null) {
	(async () => {
		await typewriter(
			document.getElementById("terminal"),
			5,
		)
		sessionStorage.setItem(SKIP_KEY, 1)
	})()
}
