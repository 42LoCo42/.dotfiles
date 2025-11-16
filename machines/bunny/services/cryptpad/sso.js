module.exports = {
	enabled: true,
	enforced: true,
	forceRedirect: true,
	cpPassword: true,
	forceCpPassword: true,

	list: [
		{
			name: "PocketID",
			type: "oidc",
			url: `https://id.${process.env.DOMAIN}`,
			client_id: "75cd3219-c0b0-4e51-b42e-3defcf20abc8",
			client_secret: process.env.CRYPTPAD_SSO_CLIENT_SECRET,
			use_pkce: true,
		},
	],
};
