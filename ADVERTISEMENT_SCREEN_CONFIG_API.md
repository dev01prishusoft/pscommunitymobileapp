# Dynamic Advertisement Screen Configuration API Specification

## 1. Overview
This API allows the mobile application to dynamically enable, disable, and configure advertisements across any screen in the application.

It supports two distinct display layers:
1. **Layer 1 (Zero-Code Banners / Popups)**: Injects top or bottom banners automatically based on the current screen route, even if the mobile developer forgot to add ad code on that screen.
2. **Layer 2 (In-List / Feed Ads)**: Configures ad injection frequency (e.g., show an ad after every 4th or 5th item) for list-based screens.

---

## 2. API Endpoint Specification

### `GET /api/v1/member/advertisements/screen-config`

- **HTTP Method**: `GET`
- **Authentication**: Required (`Bearer <JWT Token>`)
- **Headers**:
  ```http
  Authorization: Bearer <jwt_access_token>
  Accept: application/json
  Content-Type: application/json
  ```
- **Query Parameters**: None (returns all active screen configurations for the authenticated member/samaj)

---

## 3. Response Structure

### Success Response (`200 OK`)

```json
{
  "succeeded": true,
  "message": "Screen advertisement configurations fetched successfully",
  "errors": null,
  "data": {
    "isGloballyEnabled": true,
    "defaultInListInterval": 4,
    "screens": [
      {
        "route": "/home",
        "screenName": "Home Page",
        "topBanner": {
          "enabled": true,
          "placementCode": "home-top"
        },
        "bottomBanner": {
          "enabled": true,
          "placementCode": "home-bottom"
        },
        "inList": {
          "enabled": false,
          "interval": 0,
          "placementCode": null
        }
      },
      {
        "route": "/library-categories",
        "screenName": "Library Categories",
        "topBanner": {
          "enabled": false,
          "placementCode": null
        },
        "bottomBanner": {
          "enabled": true,
          "placementCode": "library-categories-bottom"
        },
        "inList": {
          "enabled": true,
          "interval": 4,
          "placementCode": "library-list"
        }
      },
      {
        "route": "/library-items",
        "screenName": "Library Items Page",
        "topBanner": {
          "enabled": false,
          "placementCode": null
        },
        "bottomBanner": {
          "enabled": false,
          "placementCode": null
        },
        "inList": {
          "enabled": true,
          "interval": 5,
          "placementCode": "library-detail"
        }
      },
      {
        "route": "/events",
        "screenName": "Events List",
        "topBanner": {
          "enabled": false,
          "placementCode": null
        },
        "bottomBanner": {
          "enabled": true,
          "placementCode": "event-list-bottom"
        },
        "inList": {
          "enabled": true,
          "interval": 4,
          "placementCode": "event-list"
        }
      },
      {
        "route": "/member-directory",
        "screenName": "Member Directory",
        "topBanner": {
          "enabled": false,
          "placementCode": null
        },
        "bottomBanner": {
          "enabled": true,
          "placementCode": "member-directory-bottom"
        },
        "inList": {
          "enabled": true,
          "interval": 6,
          "placementCode": "member-directory"
        }
      },
      {
        "route": "/new-module",
        "screenName": "Any Future New Module",
        "topBanner": {
          "enabled": false,
          "placementCode": null
        },
        "bottomBanner": {
          "enabled": true,
          "placementCode": "new-module-bottom"
        },
        "inList": {
          "enabled": false,
          "interval": 0,
          "placementCode": null
        }
      }
    ]
  }
}
```

---

## 4. Field Dictionary

### Root Object (`data`)
| Field | Type | Description |
|---|---|---|
| `isGloballyEnabled` | `boolean` | Master kill-switch. If `false`, no ads will be shown anywhere in the mobile app. |
| `defaultInListInterval` | `integer` | Default fallback frequency for in-list ads (e.g., `4` means after every 4th list card). |
| `screens` | `array` | List of screen-specific ad configuration rules. |

### Screen Configuration Object (`screens[]`)
| Field | Type | Description |
|---|---|---|
| `route` | `string` | The exact mobile navigation route string (e.g., `"/home"`, `"/library-categories"`, `"/new-module"`). |
| `screenName` | `string` | Human-readable name for display in the Admin Panel. |
| `topBanner` | `object` | Settings for a banner docked at the top of the screen. |
| `topBanner.enabled` | `boolean` | `true` to display a top banner on this screen. |
| `topBanner.placementCode` | `string?` | Placement key passed to `/api/v1/member/advertisements?placement={code}` to fetch actual ad content. |
| `bottomBanner` | `object` | Settings for a banner docked at the bottom of the screen. |
| `bottomBanner.enabled` | `boolean` | `true` to display a bottom banner on this screen. |
| `bottomBanner.placementCode` | `string?` | Placement key passed to the ad fetch API. |
| `inList` | `object` | Settings for in-feed / between-items ad injection. |
| `inList.enabled` | `boolean` | `true` if list items should have ads injected between cards. |
| `inList.interval` | `integer` | Show an ad after every `N` items (e.g., `4` = ad after items #4, #8, #12...). |
| `inList.placementCode` | `string?` | Placement key passed to the ad fetch API for feed cards. |

---

## 5. Suggested Database Schema (For Backend Developer)

### Table Name: `AdvertisementScreenConfigs`

```sql
CREATE TABLE [dbo].[AdvertisementScreenConfigs] (
    [Id] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [SamajId] INT NULL,
    [Route] NVARCHAR(150) NOT NULL,
    [ScreenName] NVARCHAR(200) NOT NULL,
    
    -- Layer 1: Top Banner
    [IsTopBannerEnabled] BIT NOT NULL DEFAULT 0,
    [TopPlacementCode] NVARCHAR(100) NULL,
    
    -- Layer 1: Bottom Banner
    [IsBottomBannerEnabled] BIT NOT NULL DEFAULT 0,
    [BottomPlacementCode] NVARCHAR(100) NULL,
    
    -- Layer 2: In-List Feed
    [IsInListEnabled] BIT NOT NULL DEFAULT 0,
    [InListInterval] INT NOT NULL DEFAULT 4,
    [InListPlacementCode] NVARCHAR(100) NULL,
    
    -- Audit & Status
    [IsActive] BIT NOT NULL DEFAULT 1,
    [CreatedAt] DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    [UpdatedAt] DATETIME2 NULL
);
```

---

## 6. How the Mobile App Consumes this API

1. **On App Start / Login**:
   - The app calls `GET /api/v1/member/advertisements/screen-config`.
   - The response is cached in memory and local storage (`GetStorage` / `SharedPreferences`).
2. **When Any Screen Opens (e.g. `/new-module`)**:
   - The app's Global Router Listener checks: Does `/new-module` exist in `screens`?
   - If `bottomBanner.enabled == true`, it automatically displays the bottom banner ad using `bottomPlacementCode`.
   - **Zero code required inside the new module screen!**
3. **When a List Screen Renders (e.g. `/library-categories`)**:
   - The list widget checks `inList.enabled`.
   - If enabled, it automatically injects an ad card every `inList.interval` items.
4. **Existing Ad Content API**:
   - The actual ad media, titles, and click URLs continue to be fetched from the existing endpoint:
     `GET /api/v1/member/advertisements?placement={placementCode}&limit=5`

