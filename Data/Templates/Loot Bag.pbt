﻿Assets {
  Id: 2548122637615085510
  Name: "Loot Bag"
  PlatformAssetType: 5
  TemplateAsset {
    ObjectBlock {
      RootId: 419777977596350189
      Objects {
        Id: 419777977596350189
        Name: "Loot Bag"
        Transform {
          Scale {
            X: 0.99999994
            Y: 0.99999994
            Z: 0.99999994
          }
        }
        ParentId: 4781671109827199097
        ChildIds: 14210764623626310408
        ChildIds: 5397262704155259510
        ChildIds: 14382925636785548216
        UnregisteredParameters {
          Overrides {
            Name: "cs:ResourceName"
            String: "Coins"
          }
          Overrides {
            Name: "cs:ResourceMin"
            Int: 10
          }
          Overrides {
            Name: "cs:ResourceMax"
            Int: 10
          }
          Overrides {
            Name: "cs:Trigger"
            ObjectReference {
              SubObjectId: 5397262704155259510
            }
          }
          Overrides {
            Name: "cs:AbilityPickupLoot"
            AssetReference {
              Id: 13053008494495394347
            }
          }
          Overrides {
            Name: "cs:AbilityPickupLootHigh"
            AssetReference {
              Id: 12343836295963297871
            }
          }
          Overrides {
            Name: "cs:DestroyDelay"
            Float: 0.2
          }
          Overrides {
            Name: "cs:PickupFX"
            AssetReference {
              Id: 5816033782698853515
            }
          }
        }
        WantsNetworking: true
        Collidable_v2 {
          Value: "mc:ecollisionsetting:inheritfromparent"
        }
        Visible_v2 {
          Value: "mc:evisibilitysetting:inheritfromparent"
        }
        Folder {
          IsGroup: true
        }
      }
      Objects {
        Id: 14210764623626310408
        Name: "LootPickup"
        Transform {
          Location {
            Z: 28.5500526
          }
          Rotation {
            Yaw: 1.02452832e-05
          }
          Scale {
            X: 1.00000012
            Y: 1.00000012
            Z: 1.00000012
          }
        }
        ParentId: 419777977596350189
        UnregisteredParameters {
        }
        WantsNetworking: true
        Collidable_v2 {
          Value: "mc:ecollisionsetting:inheritfromparent"
        }
        Visible_v2 {
          Value: "mc:evisibilitysetting:inheritfromparent"
        }
        Script {
          ScriptAsset {
            Id: 4646432397669595989
          }
        }
      }
      Objects {
        Id: 5397262704155259510
        Name: "Trigger"
        Transform {
          Location {
            Z: 28.5500526
          }
          Rotation {
          }
          Scale {
            X: 0.582240462
            Y: 0.582240462
            Z: 0.582240462
          }
        }
        ParentId: 419777977596350189
        UnregisteredParameters {
        }
        WantsNetworking: true
        Collidable_v2 {
          Value: "mc:ecollisionsetting:inheritfromparent"
        }
        Visible_v2 {
          Value: "mc:evisibilitysetting:inheritfromparent"
        }
        Trigger {
          Interactable: true
          InteractionLabel: "Get Loot Bag"
          TeamSettings {
            IsTeamCollisionEnabled: true
            IsEnemyCollisionEnabled: true
          }
          TriggerShape_v2 {
            Value: "mc:etriggershape:sphere"
          }
        }
      }
      Objects {
        Id: 14382925636785548216
        Name: "ClientContext"
        Transform {
          Location {
            Z: -64.1594315
          }
          Rotation {
            Yaw: 90.8424
          }
          Scale {
            X: 0.417002946
            Y: 0.417002946
            Z: 0.417002946
          }
        }
        ParentId: 419777977596350189
        ChildIds: 925571488236501906
        ChildIds: 3002167623471514226
        ChildIds: 10393677131346206180
        ChildIds: 11195010155753868206
        ChildIds: 14011053830191137704
        ChildIds: 2069222498426768254
        ChildIds: 11666313932214334928
        ChildIds: 4703451765142517639
        ChildIds: 15836581975501381171
        UnregisteredParameters {
        }
        WantsNetworking: true
        Collidable_v2 {
          Value: "mc:ecollisionsetting:inheritfromparent"
        }
        Visible_v2 {
          Value: "mc:evisibilitysetting:inheritfromparent"
        }
        NetworkContext {
        }
      }
      Objects {
        Id: 925571488236501906
        Name: "Point Light"
        Transform {
          Location {
            X: -0.1396579
            Y: 0.54129833
            Z: 252.784164
          }
          Rotation {
            Yaw: 8.69683552
          }
          Scale {
            X: 2.39806461
            Y: 2.39806461
            Z: 2.39806461
          }
        }
        ParentId: 14382925636785548216
        UnregisteredParameters {
        }
        Collidable_v2 {
          Value: "mc:ecollisionsetting:inheritfromparent"
        }
        Visible_v2 {
          Value: "mc:evisibilitysetting:inheritfromparent"
        }
        Light {
          Intensity: 3.99872875
          Color {
            R: 0.940000057
            G: 0.63496691
            A: 1
          }
          VolumetricIntensity: 5
          TeamSettings {
          }
          Light {
            Temperature: 6500
            LocalLight {
              AttenuationRadius: 1000
              PointLight {
                SourceRadius: 20
                SoftSourceRadius: 20
                FallOffExponent: 8
                UseFallOffExponent: true
              }
            }
            MaxDrawDistance: 5000
            MaxDistanceFadeRange: 1000
          }
        }
      }
      Objects {
        Id: 3002167623471514226
        Name: "Manticore Logo"
        Transform {
          Location {
            X: -1.6603924
            Y: -28.7400284
            Z: 220.739624
          }
          Rotation {
            Pitch: -2.0307312
            Yaw: 174.02002
            Roll: 51.5842056
          }
          Scale {
            X: 0.0930958
            Y: 0.0930958
            Z: 0.0930958
          }
        }
        ParentId: 14382925636785548216
        UnregisteredParameters {
        }
        Collidable_v2 {
          Value: "mc:ecollisionsetting:inheritfromparent"
        }
        Visible_v2 {
          Value: "mc:evisibilitysetting:inheritfromparent"
        }
        CoreMesh {
          MeshAsset {
            Id: 12667524768957844711
          }
          Teams {
            IsTeamCollisionEnabled: true
            IsEnemyCollisionEnabled: true
          }
          EnableCameraCollision: true
          StaticMesh {
            Physics {
            }
          }
        }
      }
      Objects {
        Id: 10393677131346206180
        Name: "Rope"
        Transform {
          Location {
            Z: 244.758347
          }
          Rotation {
          }
          Scale {
            X: 0.284355223
            Y: 0.284355223
            Z: 0.284355223
          }
        }
        ParentId: 14382925636785548216
        ChildIds: 13018746697192755146
        ChildIds: 15823947927668122928
        ChildIds: 6143593107704587304
        ChildIds: 1153091856683656921
        ChildIds: 4319585809882453334
        ChildIds: 6974676777560561329
        UnregisteredParameters {
        }
        Collidable_v2 {
          Value: "mc:ecollisionsetting:inheritfromparent"
        }
        Visible_v2 {
          Value: "mc:evisibilitysetting:inheritfromparent"
        }
        Folder {
          IsGroup: true
        }
      }
      Objects {
        Id: 13018746697192755146
        Name: "Rope Beam"
        Transform {
          Location {
            Z: -7.31534863
          }
          Rotation {
            Yaw: 89.9999542
          }
          Scale {
            X: 1.03208923
            Y: 1.03208923
            Z: 1.03208923
          }
        }
        ParentId: 10393677131346206180
        UnregisteredParameters {
          Overrides {
            Name: "ma:Shared_BaseMaterial:id"
            AssetReference {
              Id: 15076015910339775634
            }
          }
          Overrides {
            Name: "ma:Shared_BaseMaterial:smart"
            Bool: false
          }
          Overrides {
            Name: "ma:Shared_BaseMaterial:utile"
            Float: 4.36769915
          }
          Overrides {
            Name: "ma:Shared_BaseMaterial:vtile"
            Float: 5.06681442
          }
          Overrides {
            Name: "ma:Shared_BaseMaterial:color"
            Color {
              R: 3
              G: 2.28345013
              B: 0.470999837
              A: 1
            }
          }
        }
        Collidable_v2 {
          Value: "mc:ecollisionsetting:inheritfromparent"
        }
        Visible_v2 {
          Value: "mc:evisibilitysetting:inheritfromparent"
        }
        CoreMesh {
          MeshAsset {
            Id: 7364460640411375594
          }
          Teams {
            IsTeamCollisionEnabled: true
            IsEnemyCollisionEnabled: true
          }
          EnableCameraCollision: true
          StaticMesh {
            Physics {
            }
          }
        }
      }
      Objects {
        Id: 15823947927668122928
        Name: "Rope Beam"
        Transform {
          Location {
            Z: 10.6827145
          }
          Rotation {
            Yaw: 89.9999542
          }
          Scale {
            X: 1.03208911
            Y: 1.03208911
            Z: 1.03208911
          }
        }
        ParentId: 10393677131346206180
        UnregisteredParameters {
          Overrides {
            Name: "ma:Shared_BaseMaterial:id"
            AssetReference {
              Id: 15076015910339775634
            }
          }
          Overrides {
            Name: "ma:Shared_BaseMaterial:smart"
            Bool: false
          }
          Overrides {
            Name: "ma:Shared_BaseMaterial:utile"
            Float: 4.36769915
          }
          Overrides {
            Name: "ma:Shared_BaseMaterial:vtile"
            Float: 5.06681442
          }
          Overrides {
            Name: "ma:Shared_BaseMaterial:color"
            Color {
              R: 3
              G: 2.28345013
              B: 0.470999837
              A: 1
            }
          }
        }
        Collidable_v2 {
          Value: "mc:ecollisionsetting:inheritfromparent"
        }
        Visible_v2 {
          Value: "mc:evisibilitysetting:inheritfromparent"
        }
        CoreMesh {
          MeshAsset {
            Id: 7364460640411375594
          }
          Teams {
            IsTeamCollisionEnabled: true
            IsEnemyCollisionEnabled: true
          }
          EnableCameraCollision: true
          StaticMesh {
            Physics {
            }
          }
        }
      }
      Objects {
        Id: 6143593107704587304
        Name: "Sphere"
        Transform {
          Location {
            Y: -32.9839249
          }
          Rotation {
            Pitch: -44.5351563
            Yaw: -3.05175781e-05
            Roll: 3.67557295e-05
          }
          Scale {
            X: 0.6163553
            Y: 0.502013624
            Z: 0.233985871
          }
        }
        ParentId: 10393677131346206180
        UnregisteredParameters {
          Overrides {
            Name: "ma:Shared_BaseMaterial:id"
            AssetReference {
              Id: 16825087841517416169
            }
          }
          Overrides {
            Name: "ma:Shared_BaseMaterial:smart"
            Bool: false
          }
          Overrides {
            Name: "ma:Shared_BaseMaterial:color"
            Color {
              R: 3
              G: 2.28345013
              B: 0.470999837
              A: 1
            }
          }
          Overrides {
            Name: "ma:Shared_BaseMaterial:utile"
            Float: 14.0484686
          }
          Overrides {
            Name: "ma:Shared_BaseMaterial:vtile"
            Float: 0.952991605
          }
        }
        Collidable_v2 {
          Value: "mc:ecollisionsetting:inheritfromparent"
        }
        Visible_v2 {
          Value: "mc:evisibilitysetting:inheritfromparent"
        }
        CoreMesh {
          MeshAsset {
            Id: 6585207450897081622
          }
          Teams {
            IsTeamCollisionEnabled: true
            IsEnemyCollisionEnabled: true
          }
          EnableCameraCollision: true
          StaticMesh {
            Physics {
            }
          }
        }
      }
      Objects {
        Id: 1153091856683656921
        Name: "Sphere"
        Transform {
          Location {
            Y: -32.9839249
          }
          Rotation {
            Pitch: -43.1928711
            Yaw: -177.561447
            Roll: 159.227219
          }
          Scale {
            X: 0.716920257
            Y: 0.502006233
            Z: 0.233996719
          }
        }
        ParentId: 10393677131346206180
        UnregisteredParameters {
          Overrides {
            Name: "ma:Shared_BaseMaterial:id"
            AssetReference {
              Id: 16825087841517416169
            }
          }
          Overrides {
            Name: "ma:Shared_BaseMaterial:smart"
            Bool: false
          }
          Overrides {
            Name: "ma:Shared_BaseMaterial:color"
            Color {
              R: 3
              G: 2.28345013
              B: 0.470999837
              A: 1
            }
          }
          Overrides {
            Name: "ma:Shared_BaseMaterial:utile"
            Float: 14.0484686
          }
          Overrides {
            Name: "ma:Shared_BaseMaterial:vtile"
            Float: 0.952991605
          }
        }
        Collidable_v2 {
          Value: "mc:ecollisionsetting:inheritfromparent"
        }
        Visible_v2 {
          Value: "mc:evisibilitysetting:inheritfromparent"
        }
        CoreMesh {
          MeshAsset {
            Id: 6585207450897081622
          }
          Teams {
            IsTeamCollisionEnabled: true
            IsEnemyCollisionEnabled: true
          }
          EnableCameraCollision: true
          StaticMesh {
            Physics {
            }
          }
        }
      }
      Objects {
        Id: 4319585809882453334
        Name: "Rope Hanging"
        Transform {
          Location {
            X: 0.61355865
            Y: -48.4834862
            Z: -7.98964548
          }
          Rotation {
            Pitch: -49.198761
            Yaw: -50.2008972
            Roll: 179.884674
          }
          Scale {
            X: 1.87496161
            Y: 1.87496161
            Z: 1.87496161
          }
        }
        ParentId: 10393677131346206180
        ChildIds: 8977612768242027257
        UnregisteredParameters {
        }
        Collidable_v2 {
          Value: "mc:ecollisionsetting:inheritfromparent"
        }
        Visible_v2 {
          Value: "mc:evisibilitysetting:inheritfromparent"
        }
        Folder {
          IsGroup: true
        }
      }
      Objects {
        Id: 8977612768242027257
        Name: "Ring - Quarter"
        Transform {
          Location {
            X: 5.13703918
            Y: -44.7223282
            Z: 0.487283498
          }
          Rotation {
            Pitch: 0.000642037718
            Yaw: 100.198875
            Roll: 0.000418045733
          }
          Scale {
            X: 1
            Y: 1
            Z: 1
          }
        }
        ParentId: 4319585809882453334
        ChildIds: 11870002548417729624
        UnregisteredParameters {
          Overrides {
            Name: "ma:Shared_BaseMaterial:id"
            AssetReference {
              Id: 16825087841517416169
            }
          }
          Overrides {
            Name: "ma:Shared_BaseMaterial:smart"
            Bool: false
          }
          Overrides {
            Name: "ma:Shared_BaseMaterial:color"
            Color {
              R: 3
              G: 2.28345013
              B: 0.470999837
              A: 1
            }
          }
          Overrides {
            Name: "ma:Shared_BaseMaterial:utile"
            Float: 17.22118
          }
          Overrides {
            Name: "ma:Shared_BaseMaterial:vtile"
            Float: 5.06681442
          }
        }
        Collidable_v2 {
          Value: "mc:ecollisionsetting:inheritfromparent"
        }
        Visible_v2 {
          Value: "mc:evisibilitysetting:inheritfromparent"
        }
        CoreMesh {
          MeshAsset {
            Id: 7511473365680159662
          }
          Teams {
            IsTeamCollisionEnabled: true
            IsEnemyCollisionEnabled: true
          }
          EnableCameraCollision: true
          StaticMesh {
            Physics {
            }
          }
        }
      }
      Objects {
        Id: 11870002548417729624
        Name: "End of Rope"
        Transform {
          Location {
            X: -3.77061749
            Y: -44.7984505
            Z: 0.244406238
          }
          Rotation {
            Pitch: -46.1278381
            Yaw: -84.8497314
            Roll: -95.2980957
          }
          Scale {
            X: 0.116391383
            Y: 0.116391383
            Z: 0.116391383
          }
        }
        ParentId: 8977612768242027257
        ChildIds: 18339364751025464526
        ChildIds: 8788020937273404913
        ChildIds: 9887665817657720679
        UnregisteredParameters {
        }
        Collidable_v2 {
          Value: "mc:ecollisionsetting:inheritfromparent"
        }
        Visible_v2 {
          Value: "mc:evisibilitysetting:inheritfromparent"
        }
        Folder {
          IsGroup: true
        }
      }
      Objects {
        Id: 18339364751025464526
        Name: "Sphere"
        Transform {
          Location {
            X: 0.00212608231
            Y: -0.000177688082
            Z: -2.83509707
          }
          Rotation {
            Pitch: -0.000427246094
            Yaw: 93.3217316
            Roll: -0.000152587891
          }
          Scale {
            X: 1.01843894
            Y: 1.01843894
            Z: 0.956760466
          }
        }
        ParentId: 11870002548417729624
        UnregisteredParameters {
          Overrides {
            Name: "ma:Shared_BaseMaterial:id"
            AssetReference {
              Id: 16825087841517416169
            }
          }
          Overrides {
            Name: "ma:Shared_BaseMaterial:smart"
            Bool: false
          }
          Overrides {
            Name: "ma:Shared_BaseMaterial:color"
            Color {
              R: 3
              G: 2.28345013
              B: 0.470999837
              A: 1
            }
          }
          Overrides {
            Name: "ma:Shared_BaseMaterial:utile"
            Float: 3.00440884
          }
          Overrides {
            Name: "ma:Shared_BaseMaterial:vtile"
            Float: 0.125
          }
        }
        Collidable_v2 {
          Value: "mc:ecollisionsetting:inheritfromparent"
        }
        Visible_v2 {
          Value: "mc:evisibilitysetting:inheritfromparent"
        }
        CoreMesh {
          MeshAsset {
            Id: 6585207450897081622
          }
          Teams {
            IsTeamCollisionEnabled: true
            IsEnemyCollisionEnabled: true
          }
          EnableCameraCollision: true
          StaticMesh {
            Physics {
            }
          }
        }
      }
      Objects {
        Id: 8788020937273404913
        Name: "Horn"
        Transform {
          Location {
            Z: 8.58203125
          }
          Rotation {
          }
          Scale {
            X: 0.986250758
            Y: 0.986250758
            Z: 0.986250758
          }
        }
        ParentId: 11870002548417729624
        UnregisteredParameters {
          Overrides {
            Name: "ma:Shared_BaseMaterial:id"
            AssetReference {
              Id: 16825087841517416169
            }
          }
          Overrides {
            Name: "ma:Shared_BaseMaterial:smart"
            Bool: false
          }
          Overrides {
            Name: "ma:Shared_BaseMaterial:color"
            Color {
              R: 3
              G: 2.28345013
              B: 0.470999837
              A: 1
            }
          }
          Overrides {
            Name: "ma:Shared_BaseMaterial:utile"
            Float: 1.4
          }
          Overrides {
            Name: "ma:Shared_BaseMaterial:vtile"
            Float: 0.125
          }
        }
        Collidable_v2 {
          Value: "mc:ecollisionsetting:inheritfromparent"
        }
        Visible_v2 {
          Value: "mc:evisibilitysetting:inheritfromparent"
        }
        CoreMesh {
          MeshAsset {
            Id: 17204133586249156534
          }
          Teams {
            IsTeamCollisionEnabled: true
            IsEnemyCollisionEnabled: true
          }
          EnableCameraCollision: true
          StaticMesh {
            Physics {
            }
          }
        }
      }
      Objects {
        Id: 9887665817657720679
        Name: "Cylinder - Rounded"
        Transform {
          Location {
            X: 3.08842826
            Y: -2.6065104
            Z: -41.7085152
          }
          Rotation {
            Pitch: -3.82147217
            Yaw: 93.4387817
            Roll: -175.999924
          }
          Scale {
            X: 0.91481334
            Y: 0.914801538
            Z: 0.341985583
          }
        }
        ParentId: 11870002548417729624
        UnregisteredParameters {
          Overrides {
            Name: "ma:Shared_BaseMaterial:id"
            AssetReference {
              Id: 643713811288060970
            }
          }
          Overrides {
            Name: "ma:Shared_BaseMaterial:color"
            Color {
              R: 2
              A: 1
            }
          }
        }
        Collidable_v2 {
          Value: "mc:ecollisionsetting:inheritfromparent"
        }
        Visible_v2 {
          Value: "mc:evisibilitysetting:inheritfromparent"
        }
        CoreMesh {
          MeshAsset {
            Id: 13828127444655325311
          }
          Teams {
            IsTeamCollisionEnabled: true
            IsEnemyCollisionEnabled: true
          }
          EnableCameraCollision: true
          StaticMesh {
            Physics {
            }
          }
        }
      }
      Objects {
        Id: 6974676777560561329
        Name: "Rope Hanging"
        Transform {
          Location {
            X: -9.90753078
            Y: -48.3764229
            Z: -11.0636148
          }
          Rotation {
            Pitch: -43.8501587
            Yaw: -127.819244
            Roll: 173.504562
          }
          Scale {
            X: 1.87494433
            Y: 1.87494433
            Z: 1.87494433
          }
        }
        ParentId: 10393677131346206180
        ChildIds: 5562364169775775006
        UnregisteredParameters {
        }
        Collidable_v2 {
          Value: "mc:ecollisionsetting:inheritfromparent"
        }
        Visible_v2 {
          Value: "mc:evisibilitysetting:inheritfromparent"
        }
        Folder {
          IsGroup: true
        }
      }
      Objects {
        Id: 5562364169775775006
        Name: "Ring - Quarter"
        Transform {
          Location {
            X: 1.11063027
            Y: 42.9790764
            Z: 9.1097393
          }
          Rotation {
            Pitch: -9.55212116
            Yaw: -95.455864
            Roll: -174.70929
          }
          Scale {
            X: 1
            Y: 1
            Z: 1
          }
        }
        ParentId: 6974676777560561329
        ChildIds: 4043117053934879958
        UnregisteredParameters {
          Overrides {
            Name: "ma:Shared_BaseMaterial:id"
            AssetReference {
              Id: 16825087841517416169
            }
          }
          Overrides {
            Name: "ma:Shared_BaseMaterial:smart"
            Bool: false
          }
          Overrides {
            Name: "ma:Shared_BaseMaterial:color"
            Color {
              R: 3
              G: 2.28345013
              B: 0.470999837
              A: 1
            }
          }
          Overrides {
            Name: "ma:Shared_BaseMaterial:utile"
            Float: 17.22118
          }
          Overrides {
            Name: "ma:Shared_BaseMaterial:vtile"
            Float: 5.06681442
          }
        }
        Collidable_v2 {
          Value: "mc:ecollisionsetting:inheritfromparent"
        }
        Visible_v2 {
          Value: "mc:evisibilitysetting:inheritfromparent"
        }
        CoreMesh {
          MeshAsset {
            Id: 7511473365680159662
          }
          Teams {
            IsTeamCollisionEnabled: true
            IsEnemyCollisionEnabled: true
          }
          EnableCameraCollision: true
          StaticMesh {
            Physics {
            }
          }
        }
      }
      Objects {
        Id: 4043117053934879958
        Name: "End of Rope"
        Transform {
          Location {
            X: -2.95949984
            Y: -45.5875626
            Z: 0.244429424
          }
          Rotation {
            Pitch: -43.1372681
            Yaw: 94.6238632
            Roll: 86.9625
          }
          Scale {
            X: 0.116391383
            Y: 0.116391383
            Z: 0.116391383
          }
        }
        ParentId: 5562364169775775006
        ChildIds: 16075264709006768999
        ChildIds: 15656772842054725628
        ChildIds: 8598763607449445486
        UnregisteredParameters {
        }
        Collidable_v2 {
          Value: "mc:ecollisionsetting:inheritfromparent"
        }
        Visible_v2 {
          Value: "mc:evisibilitysetting:inheritfromparent"
        }
        Folder {
          IsGroup: true
        }
      }
      Objects {
        Id: 16075264709006768999
        Name: "Sphere"
        Transform {
          Location {
            X: 0.00212608231
            Y: -0.000177688082
            Z: -2.83509707
          }
          Rotation {
            Pitch: -0.000427246094
            Yaw: 93.3217316
            Roll: -0.000152587891
          }
          Scale {
            X: 1.01843894
            Y: 1.01843894
            Z: 0.956760466
          }
        }
        ParentId: 4043117053934879958
        UnregisteredParameters {
          Overrides {
            Name: "ma:Shared_BaseMaterial:id"
            AssetReference {
              Id: 16825087841517416169
            }
          }
          Overrides {
            Name: "ma:Shared_BaseMaterial:smart"
            Bool: false
          }
          Overrides {
            Name: "ma:Shared_BaseMaterial:color"
            Color {
              R: 3
              G: 2.28345013
              B: 0.470999837
              A: 1
            }
          }
          Overrides {
            Name: "ma:Shared_BaseMaterial:utile"
            Float: 3.00440884
          }
          Overrides {
            Name: "ma:Shared_BaseMaterial:vtile"
            Float: 0.125
          }
        }
        Collidable_v2 {
          Value: "mc:ecollisionsetting:inheritfromparent"
        }
        Visible_v2 {
          Value: "mc:evisibilitysetting:inheritfromparent"
        }
        CoreMesh {
          MeshAsset {
            Id: 6585207450897081622
          }
          Teams {
            IsTeamCollisionEnabled: true
            IsEnemyCollisionEnabled: true
          }
          EnableCameraCollision: true
          StaticMesh {
            Physics {
            }
          }
        }
      }
      Objects {
        Id: 15656772842054725628
        Name: "Horn"
        Transform {
          Location {
            Z: 8.58203125
          }
          Rotation {
          }
          Scale {
            X: 0.986250758
            Y: 0.986250758
            Z: 0.986250758
          }
        }
        ParentId: 4043117053934879958
        UnregisteredParameters {
          Overrides {
            Name: "ma:Shared_BaseMaterial:id"
            AssetReference {
              Id: 16825087841517416169
            }
          }
          Overrides {
            Name: "ma:Shared_BaseMaterial:smart"
            Bool: false
          }
          Overrides {
            Name: "ma:Shared_BaseMaterial:color"
            Color {
              R: 3
              G: 2.28345013
              B: 0.470999837
              A: 1
            }
          }
          Overrides {
            Name: "ma:Shared_BaseMaterial:utile"
            Float: 1.4
          }
          Overrides {
            Name: "ma:Shared_BaseMaterial:vtile"
            Float: 0.125
          }
        }
        Collidable_v2 {
          Value: "mc:ecollisionsetting:inheritfromparent"
        }
        Visible_v2 {
          Value: "mc:evisibilitysetting:inheritfromparent"
        }
        CoreMesh {
          MeshAsset {
            Id: 17204133586249156534
          }
          Teams {
            IsTeamCollisionEnabled: true
            IsEnemyCollisionEnabled: true
          }
          EnableCameraCollision: true
          StaticMesh {
            Physics {
            }
          }
        }
      }
      Objects {
        Id: 8598763607449445486
        Name: "Cylinder - Rounded"
        Transform {
          Location {
            X: 2.85794258
            Y: -2.41274095
            Z: -38.6203346
          }
          Rotation {
            Pitch: -3.82147217
            Yaw: 93.4388123
            Roll: -175.999924
          }
          Scale {
            X: 0.91481334
            Y: 0.914801538
            Z: 0.341985583
          }
        }
        ParentId: 4043117053934879958
        UnregisteredParameters {
          Overrides {
            Name: "ma:Shared_BaseMaterial:id"
            AssetReference {
              Id: 643713811288060970
            }
          }
          Overrides {
            Name: "ma:Shared_BaseMaterial:color"
            Color {
              R: 2
              A: 1
            }
          }
        }
        Collidable_v2 {
          Value: "mc:ecollisionsetting:inheritfromparent"
        }
        Visible_v2 {
          Value: "mc:evisibilitysetting:inheritfromparent"
        }
        CoreMesh {
          MeshAsset {
            Id: 13828127444655325311
          }
          Teams {
            IsTeamCollisionEnabled: true
            IsEnemyCollisionEnabled: true
          }
          EnableCameraCollision: true
          StaticMesh {
            Physics {
            }
          }
        }
      }
      Objects {
        Id: 11195010155753868206
        Name: "Sphere"
        Transform {
          Location {
            Z: 188.89006
          }
          Rotation {
          }
          Scale {
            X: 1
            Y: 1
            Z: 0.63298583
          }
        }
        ParentId: 14382925636785548216
        UnregisteredParameters {
          Overrides {
            Name: "ma:Shared_BaseMaterial:id"
            AssetReference {
              Id: 13996105137076862878
            }
          }
          Overrides {
            Name: "ma:Shared_BaseMaterial:smart"
            Bool: true
          }
          Overrides {
            Name: "ma:Shared_BaseMaterial:utile"
            Float: 0.152663499
          }
          Overrides {
            Name: "ma:Shared_BaseMaterial:vtile"
            Float: 0.125
          }
          Overrides {
            Name: "ma:Shared_BaseMaterial:color"
            Color {
              R: 0.122000009
              G: 0.0815654397
              B: 0.0409012772
              A: 1
            }
          }
        }
        Collidable_v2 {
          Value: "mc:ecollisionsetting:inheritfromparent"
        }
        Visible_v2 {
          Value: "mc:evisibilitysetting:inheritfromparent"
        }
        CoreMesh {
          MeshAsset {
            Id: 6585207450897081622
          }
          Teams {
            IsTeamCollisionEnabled: true
            IsEnemyCollisionEnabled: true
          }
          EnableCameraCollision: true
          StaticMesh {
            Physics {
            }
          }
        }
      }
      Objects {
        Id: 14011053830191137704
        Name: "Cone - Truncated Narrow"
        Transform {
          Location {
            Z: 203.813843
          }
          Rotation {
            Yaw: 120.41172
          }
          Scale {
            X: 0.876078784
            Y: 0.876078784
            Z: 0.646200895
          }
        }
        ParentId: 14382925636785548216
        UnregisteredParameters {
          Overrides {
            Name: "ma:Shared_BaseMaterial:id"
            AssetReference {
              Id: 13996105137076862878
            }
          }
          Overrides {
            Name: "ma:Shared_BaseMaterial:color"
            Color {
              R: 0.122000009
              G: 0.0815654397
              B: 0.0409012772
              A: 1
            }
          }
          Overrides {
            Name: "ma:Shared_BaseMaterial:smart"
            Bool: true
          }
        }
        Collidable_v2 {
          Value: "mc:ecollisionsetting:inheritfromparent"
        }
        Visible_v2 {
          Value: "mc:evisibilitysetting:inheritfromparent"
        }
        CoreMesh {
          MeshAsset {
            Id: 585112705082600373
          }
          Teams {
            IsTeamCollisionEnabled: true
            IsEnemyCollisionEnabled: true
          }
          EnableCameraCollision: true
          StaticMesh {
            Physics {
            }
          }
        }
      }
      Objects {
        Id: 2069222498426768254
        Name: "Cone - Truncated Narrow"
        Transform {
          Location {
            Z: 197.788834
          }
          Rotation {
          }
          Scale {
            X: 0.382453054
            Y: 0.950029135
            Z: 0.950029135
          }
        }
        ParentId: 14382925636785548216
        UnregisteredParameters {
          Overrides {
            Name: "ma:Shared_BaseMaterial:id"
            AssetReference {
              Id: 13996105137076862878
            }
          }
          Overrides {
            Name: "ma:Shared_BaseMaterial:color"
            Color {
              R: 0.122000009
              G: 0.0815654397
              B: 0.0409012772
              A: 1
            }
          }
          Overrides {
            Name: "ma:Shared_BaseMaterial:smart"
            Bool: true
          }
        }
        Collidable_v2 {
          Value: "mc:ecollisionsetting:inheritfromparent"
        }
        Visible_v2 {
          Value: "mc:evisibilitysetting:inheritfromparent"
        }
        CoreMesh {
          MeshAsset {
            Id: 585112705082600373
          }
          Teams {
            IsTeamCollisionEnabled: true
            IsEnemyCollisionEnabled: true
          }
          EnableCameraCollision: true
          StaticMesh {
            Physics {
            }
          }
        }
      }
      Objects {
        Id: 11666313932214334928
        Name: "Cone - Truncated Narrow"
        Transform {
          Location {
            Z: 197.788834
          }
          Rotation {
            Yaw: -61.7213745
          }
          Scale {
            X: 0.382453054
            Y: 0.950029135
            Z: 0.950029135
          }
        }
        ParentId: 14382925636785548216
        UnregisteredParameters {
          Overrides {
            Name: "ma:Shared_BaseMaterial:id"
            AssetReference {
              Id: 13996105137076862878
            }
          }
          Overrides {
            Name: "ma:Shared_BaseMaterial:color"
            Color {
              R: 0.122000009
              G: 0.0815654397
              B: 0.0409012772
              A: 1
            }
          }
          Overrides {
            Name: "ma:Shared_BaseMaterial:smart"
            Bool: true
          }
        }
        Collidable_v2 {
          Value: "mc:ecollisionsetting:inheritfromparent"
        }
        Visible_v2 {
          Value: "mc:evisibilitysetting:inheritfromparent"
        }
        CoreMesh {
          MeshAsset {
            Id: 585112705082600373
          }
          Teams {
            IsTeamCollisionEnabled: true
            IsEnemyCollisionEnabled: true
          }
          EnableCameraCollision: true
          StaticMesh {
            Physics {
            }
          }
        }
      }
      Objects {
        Id: 4703451765142517639
        Name: "Cone - Truncated Narrow"
        Transform {
          Location {
            Z: 197.788834
          }
          Rotation {
            Yaw: 57.2607727
          }
          Scale {
            X: 0.382453054
            Y: 0.950029135
            Z: 0.950029135
          }
        }
        ParentId: 14382925636785548216
        UnregisteredParameters {
          Overrides {
            Name: "ma:Shared_BaseMaterial:id"
            AssetReference {
              Id: 13996105137076862878
            }
          }
          Overrides {
            Name: "ma:Shared_BaseMaterial:color"
            Color {
              R: 0.122000009
              G: 0.0815654397
              B: 0.0409012772
              A: 1
            }
          }
          Overrides {
            Name: "ma:Shared_BaseMaterial:smart"
            Bool: true
          }
        }
        Collidable_v2 {
          Value: "mc:ecollisionsetting:inheritfromparent"
        }
        Visible_v2 {
          Value: "mc:evisibilitysetting:inheritfromparent"
        }
        CoreMesh {
          MeshAsset {
            Id: 585112705082600373
          }
          Teams {
            IsTeamCollisionEnabled: true
            IsEnemyCollisionEnabled: true
          }
          EnableCameraCollision: true
          StaticMesh {
            Physics {
            }
          }
        }
      }
      Objects {
        Id: 15836581975501381171
        Name: "Cone - Hollow"
        Transform {
          Location {
            Z: 279.615753
          }
          Rotation {
            Roll: -179.912949
          }
          Scale {
            X: 0.706250429
            Y: 0.70625329
            Z: 0.430166036
          }
        }
        ParentId: 14382925636785548216
        UnregisteredParameters {
          Overrides {
            Name: "ma:Shared_BaseMaterial:id"
            AssetReference {
              Id: 13996105137076862878
            }
          }
          Overrides {
            Name: "ma:Shared_BaseMaterial:color"
            Color {
              R: 0.122000009
              G: 0.0815654397
              B: 0.0409012772
              A: 1
            }
          }
        }
        Collidable_v2 {
          Value: "mc:ecollisionsetting:inheritfromparent"
        }
        Visible_v2 {
          Value: "mc:evisibilitysetting:inheritfromparent"
        }
        CoreMesh {
          MeshAsset {
            Id: 13877434218455327304
          }
          Teams {
            IsTeamCollisionEnabled: true
            IsEnemyCollisionEnabled: true
          }
          EnableCameraCollision: true
          StaticMesh {
            Physics {
            }
          }
        }
      }
    }
    Assets {
      Id: 12667524768957844711
      Name: "Manticore Logo"
      PlatformAssetType: 1
      PrimaryAsset {
        AssetType: "StaticMeshAssetRef"
        AssetId: "sm_logo_manticore_01"
      }
    }
    Assets {
      Id: 7364460640411375594
      Name: "Ring - Thick"
      PlatformAssetType: 1
      PrimaryAsset {
        AssetType: "StaticMeshAssetRef"
        AssetId: "sm_torus_005"
      }
    }
    Assets {
      Id: 15076015910339775634
      Name: "Rope"
      PlatformAssetType: 2
      PrimaryAsset {
        AssetType: "MaterialAssetRef"
        AssetId: "mi_rope_001"
      }
    }
    Assets {
      Id: 6585207450897081622
      Name: "Sphere"
      PlatformAssetType: 1
      PrimaryAsset {
        AssetType: "StaticMeshAssetRef"
        AssetId: "sm_sphere_002"
      }
    }
    Assets {
      Id: 16825087841517416169
      Name: "Rope"
      PlatformAssetType: 2
      PrimaryAsset {
        AssetType: "MaterialAssetRef"
        AssetId: "mi_rope_001"
      }
    }
    Assets {
      Id: 7511473365680159662
      Name: "Ring - Quarter"
      PlatformAssetType: 1
      PrimaryAsset {
        AssetType: "StaticMeshAssetRef"
        AssetId: "sm_quarter_torus_002"
      }
    }
    Assets {
      Id: 17204133586249156534
      Name: "Horn"
      PlatformAssetType: 1
      PrimaryAsset {
        AssetType: "StaticMeshAssetRef"
        AssetId: "sm_horn_001"
      }
    }
    Assets {
      Id: 13828127444655325311
      Name: "Cylinder - Rounded"
      PlatformAssetType: 1
      PrimaryAsset {
        AssetType: "StaticMeshAssetRef"
        AssetId: "sm_cylinder_rounded_002"
      }
    }
    Assets {
      Id: 643713811288060970
      Name: "Plastic Shiny"
      PlatformAssetType: 2
      PrimaryAsset {
        AssetType: "MaterialAssetRef"
        AssetId: "plastic_shiny_001"
      }
    }
    Assets {
      Id: 585112705082600373
      Name: "Cone - Truncated Narrow"
      PlatformAssetType: 1
      PrimaryAsset {
        AssetType: "StaticMeshAssetRef"
        AssetId: "sm_cone_truncated_002"
      }
    }
    Assets {
      Id: 13877434218455327304
      Name: "Cone - Hollow"
      PlatformAssetType: 1
      PrimaryAsset {
        AssetType: "StaticMeshAssetRef"
        AssetId: "sm_cone-hollow_001"
      }
    }
    PrimaryAssetId {
      AssetType: "None"
      AssetId: "None"
    }
  }
  SerializationVersion: 72
}