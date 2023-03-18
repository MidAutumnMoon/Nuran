#
# Policies Yes!
#

{

  DisableFirefoxStudies = true;
  DisablePocket    = true;
  DisableTelemetry = true;


  HardwareAcceleration    = true;
  DontCheckDefaultBrowser = true;
  RequestedLocales        = [ "en-US" ];


  Homepage =
    { StartPage = "previous-session"; };

  FirefoxHome =
    { Locked = true;

      TopSites          = false;
      SponsoredTopSites = false;
      Highlights        = false;
      Pocket            = false;
      SponsoredPocket   = false;
      Snippets          = false;
    };


  SearchBar               = "unified";
  ShowHomeButton          = false;
  DisplayBookmarksToolbar = false;

  UserMessaging =
    { WhatsNew                 = false;
      FeatureRecommendations   = false;
      ExtensionRecommendations = false;
      UrlbarInterventions      = false;
      SkipOnboarding           = true;
    };


  Proxy =
    { Mode           = "manual";
      SOCKSProxy     = "127.0.0.1:1081";
      SOCKSVersion   = 5;
      UseProxyForDNS = true;
    };

  Cookies =
    { Behavior                = "reject-foreign";
      BehaviorPrivateBrowsing = "reject-foreign";
    };

  EnableTrackingProtection =
    { Value          = true;
      Cryptomining   = true;
      Fingerprinting = true;
    };

  Permissions =
    { Camera =
        { BlockNewRequests = true;
          Locked = true;
        };
      Microphone =
        { BlockNewRequests = true;
          Locked = true;
        };
      Location =
        { BlockNewRequests = true;
          Locked = true;
        };
      Notifications =
        { BlockNewRequests = true;
          Locked = true;
        };
    };

  NoDefaultBookmarks = true;

}
