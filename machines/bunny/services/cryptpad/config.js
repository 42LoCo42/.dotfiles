module.exports = {
	httpUnsafeOrigin: `https://pad.${process.env.DOMAIN}`,
	httpSafeOrigin: `https://internal.pad.${process.env.DOMAIN}`,

	httpAddress: "0.0.0.0",
	httpPort: 8080,

	filePath: "./datastore/",
	archivePath: "./data/archive",
	pinPath: "./data/pins",
	taskPath: "./data/tasks",
	blockPath: "./block",
	blobPath: "./blob",
	blobStagingPath: "./data/blobstage",
	decreePath: "./data/decrees",

	logToStdout: true,
	logLevel: "info",

	removeDonateButton: true,
};
