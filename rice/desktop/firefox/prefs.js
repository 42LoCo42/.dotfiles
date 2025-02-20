// don't warn when opening about:config
lockPref("browser.aboutConfig.showWarning", false);

// Open previous windows and tabs
lockPref("browser.startup.page", 3);

// Use recommended performance settings
lockPref("browser.preferences.defaultPerformanceSettings.enabled", true);
lockPref("layers.acceleration.disabled", false);

// Enhanced Tracking Protection -> Suspected fingerprinters: In all windows
lockPref("privacy.fingerprintingProtection", true);
lockPref("privacy.fingerprintingProtection.pbmode", true);

// DO NOT Allow Firefox to send backlogged crash reports on your behalf
lockPref("browser.crashReports.unsubmittedCheck.autoSubmit2", false);

// Block dangerous and deceptive content
lockPref("browser.safebrowsing.downloads.enabled", true);
lockPref("browser.safebrowsing.downloads.remote.block_potentially_unwanted", true);
lockPref("browser.safebrowsing.downloads.remote.block_uncommon", true);
lockPref("browser.safebrowsing.malware.enabled", true);
lockPref("browser.safebrowsing.phishing.enabled", true);

// Query OCSP responder servers...
lockPref("security.OCSP.enabled", 1);
