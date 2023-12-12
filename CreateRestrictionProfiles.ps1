
Install-Module microsoft.graph
import-module microsoft.graph

$appid = '8138dfa1-aa83-4c58-b65c-7cd1f27d7174'
$tenantid = 'de55da9f-7c4c-44c6-8cbe-af4d0a0bfec0'
$secret = 'yoursecretstoredsomewhere'


$body =  @{
    Grant_Type    = "client_credentials"
    Scope         = "https://graph.microsoft.com/.default"
    Client_Id     = $appid
    Client_Secret = $secret
}

$connection = Invoke-RestMethod -Uri https://login.microsoftonline.com/$tenantid/oauth2/v2.0/token -Method POST -Body $body
$token = $connection.access_token
Connect-MgGraph -AccessToken $token

[String[]]$countries = "FR", "DE", "ES", "BR"

foreach ($COUNTRY in $countries) {

    $JSON = @"
        {
                "@odata.type": "#microsoft.graph.windows10GeneralConfiguration",            
                "description": null,
                "displayName": "$COUNTRY - DisableBluetoothandGaming",
                "version": 1,
                "roleScopeTagIds": [
                    "1"],            
                "enterpriseCloudPrintDiscoveryEndPoint": null,
                "enterpriseCloudPrintOAuthAuthority": null,
                "enterpriseCloudPrintOAuthClientIdentifier": null,
                "enterpriseCloudPrintResourceIdentifier": null,
                "enterpriseCloudPrintDiscoveryMaxLimit": null,
                "enterpriseCloudPrintMopriaDiscoveryResourceIdentifier": null,
                "searchBlockDiacritics": false,
                "searchDisableAutoLanguageDetection": false,
                "searchDisableIndexingEncryptedItems": false,
                "searchEnableRemoteQueries": false,
                "searchDisableIndexerBackoff": false,
                "searchDisableIndexingRemovableDrive": false,
                "searchEnableAutomaticIndexSizeManangement": false,
                "diagnosticsDataSubmissionMode": "userDefined",
                "oneDriveDisableFileSync": false,
                "smartScreenEnableAppInstallControl": false,
                "personalizationDesktopImageUrl": null,
                "personalizationLockScreenImageUrl": null,
                "bluetoothAllowedServices": [],
                "bluetoothBlockAdvertising": true,
                "bluetoothBlockDiscoverableMode": true,
                "bluetoothBlockPrePairing": true,
                "edgeBlockAutofill": false,
                "edgeBlocked": false,
                "edgeCookiePolicy": "userDefined",
                "edgeBlockDeveloperTools": false,
                "edgeBlockSendingDoNotTrackHeader": false,
                "edgeBlockExtensions": false,
                "edgeBlockInPrivateBrowsing": false,
                "edgeBlockJavaScript": false,
                "edgeBlockPasswordManager": false,
                "edgeBlockAddressBarDropdown": false,
                "edgeBlockCompatibilityList": false,
                "edgeClearBrowsingDataOnExit": false,
                "edgeAllowStartPagesModification": false,
                "edgeDisableFirstRunPage": false,
                "edgeBlockLiveTileDataCollection": false,
                "edgeSyncFavoritesWithInternetExplorer": false,
                "cellularBlockDataWhenRoaming": false,
                "cellularBlockVpn": false,
                "cellularBlockVpnWhenRoaming": false,
                "defenderRequireRealTimeMonitoring": false,
                "defenderRequireBehaviorMonitoring": false,
                "defenderRequireNetworkInspectionSystem": false,
                "defenderScanDownloads": false,
                "defenderScanScriptsLoadedInInternetExplorer": false,
                "defenderBlockEndUserAccess": false,
                "defenderSignatureUpdateIntervalInHours": null,
                "defenderMonitorFileActivity": "userDefined",
                "defenderDaysBeforeDeletingQuarantinedMalware": null,
                "defenderScanMaxCpu": null,
                "defenderScanArchiveFiles": false,
                "defenderScanIncomingMail": false,
                "defenderScanRemovableDrivesDuringFullScan": false,
                "defenderScanMappedNetworkDrivesDuringFullScan": false,
                "defenderScanNetworkFiles": false,
                "defenderRequireCloudProtection": false,
                "defenderCloudBlockLevel": "notConfigured",
                "defenderPromptForSampleSubmission": "userDefined",
                "defenderScheduledQuickScanTime": null,
                "defenderScanType": "userDefined",
                "defenderSystemScanSchedule": "userDefined",
                "defenderScheduledScanTime": null,
                "defenderDetectedMalwareActions": null,
                "defenderFileExtensionsToExclude": [],
                "defenderFilesAndFoldersToExclude": [],
                "defenderProcessesToExclude": [],
                "lockScreenAllowTimeoutConfiguration": false,
                "lockScreenBlockActionCenterNotifications": false,
                "lockScreenBlockCortana": false,
                "lockScreenBlockToastNotifications": false,
                "lockScreenTimeoutInSeconds": null,
                "passwordBlockSimple": false,
                "passwordExpirationDays": null,
                "passwordMinimumLength": null,
                "passwordMinutesOfInactivityBeforeScreenTimeout": null,
                "passwordMinimumCharacterSetCount": null,
                "passwordPreviousPasswordBlockCount": null,
                "passwordRequired": false,
                "passwordRequireWhenResumeFromIdleState": false,
                "passwordRequiredType": "deviceDefault",
                "passwordSignInFailureCountBeforeFactoryReset": null,
                "privacyAdvertisingId": "notConfigured",
                "privacyAutoAcceptPairingAndConsentPrompts": false,
                "privacyBlockInputPersonalization": false,
                "startBlockUnpinningAppsFromTaskbar": false,
                "startMenuAppListVisibility": "userDefined",
                "startMenuHideChangeAccountSettings": false,
                "startMenuHideFrequentlyUsedApps": false,
                "startMenuHideHibernate": false,
                "startMenuHideLock": false,
                "startMenuHidePowerButton": false,
                "startMenuHideRecentJumpLists": false,
                "startMenuHideRecentlyAddedApps": false,
                "startMenuHideRestartOptions": false,
                "startMenuHideShutDown": false,
                "startMenuHideSignOut": false,
                "startMenuHideSleep": false,
                "startMenuHideSwitchAccount": false,
                "startMenuHideUserTile": false,
                "startMenuLayoutEdgeAssetsXml": null,
                "startMenuLayoutXml": null,
                "startMenuMode": "userDefined",
                "startMenuPinnedFolderDocuments": "notConfigured",
                "startMenuPinnedFolderDownloads": "notConfigured",
                "startMenuPinnedFolderFileExplorer": "notConfigured",
                "startMenuPinnedFolderHomeGroup": "notConfigured",
                "startMenuPinnedFolderMusic": "notConfigured",
                "startMenuPinnedFolderNetwork": "notConfigured",
                "startMenuPinnedFolderPersonalFolder": "notConfigured",
                "startMenuPinnedFolderPictures": "notConfigured",
                "startMenuPinnedFolderSettings": "notConfigured",
                "startMenuPinnedFolderVideos": "notConfigured",
                "settingsBlockSettingsApp": false,
                "settingsBlockSystemPage": false,
                "settingsBlockDevicesPage": false,
                "settingsBlockNetworkInternetPage": false,
                "settingsBlockPersonalizationPage": false,
                "settingsBlockAccountsPage": false,
                "settingsBlockTimeLanguagePage": false,
                "settingsBlockEaseOfAccessPage": false,
                "settingsBlockPrivacyPage": false,
                "settingsBlockUpdateSecurityPage": false,
                "settingsBlockAppsPage": false,
                "settingsBlockGamingPage": true,
                "windowsSpotlightBlockConsumerSpecificFeatures": false,
                "windowsSpotlightBlocked": false,
                "windowsSpotlightBlockOnActionCenter": false,
                "windowsSpotlightBlockTailoredExperiences": false,
                "windowsSpotlightBlockThirdPartyNotifications": false,
                "windowsSpotlightBlockWelcomeExperience": false,
                "windowsSpotlightBlockWindowsTips": false,
                "windowsSpotlightConfigureOnLockScreen": "notConfigured",
                "networkProxyApplySettingsDeviceWide": false,
                "networkProxyDisableAutoDetect": false,
                "networkProxyAutomaticConfigurationUrl": null,
                "networkProxyServer": null,
                "accountsBlockAddingNonMicrosoftAccountEmail": false,
                "antiTheftModeBlocked": false,
                "bluetoothBlocked": true,
                "cameraBlocked": false,
                "connectedDevicesServiceBlocked": false,
                "certificatesBlockManualRootCertificateInstallation": false,
                "copyPasteBlocked": false,
                "cortanaBlocked": false,
                "deviceManagementBlockFactoryResetOnMobile": false,
                "deviceManagementBlockManualUnenroll": false,
                "safeSearchFilter": "userDefined",
                "edgeBlockPopups": false,
                "edgeBlockSearchSuggestions": false,
                "edgeBlockSendingIntranetTrafficToInternetExplorer": false,
                "edgeSendIntranetTrafficToInternetExplorer": false,
                "edgeRequireSmartScreen": false,
                "edgeEnterpriseModeSiteListLocation": null,
                "edgeFirstRunUrl": null,
                "edgeSearchEngine": null,
                "edgeHomepageUrls": [],
                "edgeBlockAccessToAboutFlags": false,
                "smartScreenBlockPromptOverride": false,
                "smartScreenBlockPromptOverrideForFiles": false,
                "webRtcBlockLocalhostIpAddress": false,
                "internetSharingBlocked": false,
                "settingsBlockAddProvisioningPackage": false,
                "settingsBlockRemoveProvisioningPackage": false,
                "settingsBlockChangeSystemTime": false,
                "settingsBlockEditDeviceName": false,
                "settingsBlockChangeRegion": false,
                "settingsBlockChangeLanguage": false,
                "settingsBlockChangePowerSleep": false,
                "locationServicesBlocked": false,
                "microsoftAccountBlocked": false,
                "microsoftAccountBlockSettingsSync": false,
                "nfcBlocked": false,
                "resetProtectionModeBlocked": false,
                "screenCaptureBlocked": false,
                "storageBlockRemovableStorage": false,
                "storageRequireMobileDeviceEncryption": false,
                "usbBlocked": false,
                "voiceRecordingBlocked": false,
                "wiFiBlockAutomaticConnectHotspots": false,
                "wiFiBlocked": false,
                "wiFiBlockManualConfiguration": false,
                "wiFiScanInterval": null,
                "wirelessDisplayBlockProjectionToThisDevice": false,
                "wirelessDisplayBlockUserInputFromReceiver": false,
                "wirelessDisplayRequirePinForPairing": false,
                "windowsStoreBlocked": false,
                "appsAllowTrustedAppsSideloading": "notConfigured",
                "windowsStoreBlockAutoUpdate": false,
                "developerUnlockSetting": "notConfigured",
                "sharedUserAppDataAllowed": false,
                "appsBlockWindowsStoreOriginatedApps": false,
                "windowsStoreEnablePrivateStoreOnly": false,
                "storageRestrictAppDataToSystemVolume": false,
                "storageRestrictAppInstallToSystemVolume": false,
                "gameDvrBlocked": false,
                "experienceBlockDeviceDiscovery": false,
                "experienceBlockErrorDialogWhenNoSIM": false,
                "experienceBlockTaskSwitcher": false,
                "logonBlockFastUserSwitching": false,
                "tenantLockdownRequireNetworkDuringOutOfBoxExperience": false,
    }
"@

$uri = 'https://graph.microsoft.com/beta/deviceManagement/deviceConfigurations'

Invoke-MgGraphRequest -Uri $uri -Body $json -Method POST -ContentType "application/json"

####

### Obtenez l'id de la configuration précédemment crée en filtrant sur le nom de celle-ci
$uri = 'https://graph.microsoft.com/beta/deviceManagement/deviceConfigurations?$filter='
$filter = "displayname eq '$COUNTRY - DisableBluetoothandGaming'"
$confid = Invoke-MgGraphRequest -Uri $uri$filter -Method get | select -ExpandProperty value | select -ExpandProperty id
$uriassign = "https://graph.microsoft.com/beta/deviceManagement/deviceConfigurations/$confid/assign"

### Obtenez l'id du groupe en filtrant sur le nom de celui-ci
$urigroup = 'https://graph.microsoft.com/beta/groups?$filter='
$filtergroup = "displayname eq 'AZ-GRP-DEVICE-W10-$COUNTRY'"
$groupid = Invoke-MgGraphRequest -Uri $urigroup$filtergroup -Method get | select -ExpandProperty value | select -ExpandProperty id

### Construction du JSON
$json = @"      
{ 
    "deviceConfigurationGroupAssignments": [ 
        {
        "@odata.type": "#microsoft.graph.deviceConfigurationGroupAssignment",
        "targetGroupId": "$groupid",
        }
    ] 
} 
"@

#Assign action
Invoke-MgGraphRequest -Uri $uriassign -Body $json -Method POST -ContentType "application/json"

}
