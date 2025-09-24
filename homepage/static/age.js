const today = new Date();
const birth = new Date("2002-11-04");

const monthDiff = today.getMonth() - birth.getMonth();
const age =
	today.getFullYear() -
	birth.getFullYear() -
	(monthDiff < 0 || (monthDiff == 0 && today.getDate() < birth.getDate())
		? 1
		: 0);

document.getElementById("age").innerText = `${age}`;
