user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);

// linux
// builtin cd ~/.config/mozilla/firefox/*.default-release
// micro user.js

// windows
// cd "$HOME\AppData\Roaming\Mozilla\Firefox\Profiles\*.default-release"
// notepad.exe user.js

// https://github.com/yokoffing/Betterfox/blob/main/Smoothfox.js
// https://raw.githubusercontent.com/yokoffing/Betterfox/refs/heads/main/Smoothfox.js
user_pref("apz.overscroll.enabled", true);
user_pref("general.smoothScroll", true);
user_pref("general.smoothScroll.msdPhysics.continuousMotionMaxDeltaMS", 12);
user_pref("general.smoothScroll.msdPhysics.enabled", true);
user_pref("general.smoothScroll.msdPhysics.motionBeginSpringConstant", 600);
user_pref("general.smoothScroll.msdPhysics.regularSpringConstant", 650);
user_pref("general.smoothScroll.msdPhysics.slowdownMinDeltaMS", 25);
user_pref("general.smoothScroll.msdPhysics.slowdownMinDeltaRatio", "2");
user_pref("general.smoothScroll.msdPhysics.slowdownSpringConstant", 250);
user_pref("general.smoothScroll.currentVelocityWeighting", "1");
user_pref("general.smoothScroll.stopDecelerationWeighting", "1");
user_pref("mousewheel.default.delta_multiplier_y", 300);

// tweaks
user_pref("browser.search.openintab", true);
user_pref("browser.tabs.loadBookmarksInTabs", true);
user_pref("browser.tabs.closeWindowWithLastTab", false)
user_pref("browser.warnOnQuitShortcut", true);
user_pref("browser.bookmarks.openInTabClosesMenu", false);
user_pref("browser.ctrlTab.sortByRecentlyUsed", true);
user_pref("findbar.highlightAll", true);
user_pref("browser.urlbar.doubleClickSelectsAll", false);
user_pref("browser.urlbar.decodeURLsOnCopy", true);
