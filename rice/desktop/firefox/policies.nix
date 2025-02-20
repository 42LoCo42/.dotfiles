{
  AutofillAddressEnabled = true;
  AutofillCreditCardEnabled = false; # use vaultwarden

  Cookies = {
    Behavior = "reject-foreign";
    Locked = true;
  };

  DisableFeedbackCommands = true;
  DisableFirefoxAccounts = true;
  DisableFirefoxStudies = true;
  DisableMasterPasswordCreation = true;
  DisablePocket = true;
  DisableProfileRefresh = true;
  DisableSetDesktopBackground = true;
  DisableTelemetry = true;

  DisplayBookmarksToolbar = "never";
  DisplayMenuBar = "never";

  DNSOverHTTPS = {
    Enabled = false; # use local dnscrypt-proxy
    Locked = true;
  };

  DontCheckDefaultBrowser = true;

  EnableTrackingProtection = {
    Value = true;
    Locked = true;

    Cryptomining = true;
    EmailTracking = true;
    Fingerprinting = true;
  };

  EncryptedMediaExtensions = {
    Enabled = false;
    Locked = true;
  };

  ExtensionSettings = (builtins.mapAttrs (id: bar: {
    installation_mode = "force_installed";
    install_url = "https://addons.mozilla.org/firefox/downloads/latest/${id}/latest.xpi";
    default_area = if bar then "navbar" else "menupanel";
  })) {
    "CanvasBlocker@kkapsner.de" = false; # https://addons.mozilla.org/en-US/firefox/addon/canvasblocker
    "addon@darkreader.org" = true; # https://addons.mozilla.org/en-US/firefox/addon/darkreader
    "hide-tabs@afnankhan" = true; # https://addons.mozilla.org/en-US/firefox/addon/hide-tab
    "idcac-pub@guus.ninja" = false; # https://addons.mozilla.org/en-US/firefox/addon/istilldontcareaboutcookies
    "sponsorBlocker@ajay.app" = false; # https://addons.mozilla.org/en-US/firefox/addon/sponsorblock
    "uBlock0@raymondhill.net" = true; # https://addons.mozilla.org/en-US/firefox/addon/ublock-origin
    "{0d7cafdd-501c-49ca-8ebb-e3341caaa55e}" = false; # https://addons.mozilla.org/en-US/firefox/addon/youtube-nonstop
    "{446900e4-71c2-419f-a6a7-df9c091e268b}" = true; # https://addons.mozilla.org/en-US/firefox/addon/bitwarden-password-manager
    "{4c421bb7-c1de-4dc6-80c7-ce8625e34d24}" = false; # https://addons.mozilla.org/en-US/firefox/addon/load-reddit-images-directly
    "{b86e4813-687a-43e6-ab65-0bde4ab75758}" = false; # https://addons.mozilla.org/en-US/firefox/addon/localcdn-fork-of-decentraleyes
  };

  ExtensionUpdate = true;

  FirefoxHome = {
    Locked = true;

    Search = true;

    Highlights = false;
    Pocket = false;
    Snippets = false;
    SponsoredPocket = false;
    SponsoredTopSites = false;
    TopSites = false;
  };

  FirefoxSuggest = {
    Locked = true;

    ImproveSuggest = false;
    SponsoredSuggestions = false;
    WebSuggestions = false;
  };

  HardwareAcceleration = true;

  Homepage = {
    StartPage = "previous-session";
    Locked = true;
  };

  HttpsOnlyMode = "force_enabled";

  NoDefaultBookmarks = true;

  OfferToSaveLogins = false; # use vaultwarden

  OverrideFirstRunPage = "";

  PasswordManagerEnabled = false; # use vaultwarden

  PictureInPicture = {
    Enabled = false;
    Locked = true;
  };

  PopupBlocking = {
    Allow = [ ];
    Default = true;
    Locked = true;
  };

  PostQuantumKeyAgreementEnabled = true;

  Preferences = {
    # Tell websites not to sell or share my data
    "privacy.globalprivacycontrol.enabled" = {
      Type = "boolean";
      Value = true;
      Status = "locked";
    };

    # Show alerts about passwords for breached websites
    "signon.management.page.breach-alerts.enabled" = {
      Type = "boolean";
      Value = false;
      Status = "locked";
    };

    # Warn you when websites try to install add-ons
    "xpinstall.whitelist.required" = {
      Type = "boolean";
      Value = true;
      Status = "locked";
    };
  };

  SearchBar = "unified";

  SearchSuggestEnabled = true;

  ShowHomeButton = false;

  TranslateEnabled = false;

  UserMessaging = {
    Locked = true;

    ExtensionRecommendations = false;
    FeatureRecommendations = false;
    FirefoxLabs = false;
    MoreFromMozilla = false;
    SkipOnboarding = false;
    UrlbarInterventions = false;
  };
}
