Name: "Spinning arm of death_6"
RootId: 3919765587975032039
Objects {
  Id: 610742210611514619
  Name: "Spinner"
  Transform {
    Location {
    }
    Rotation {
    }
    Scale {
      X: 1
      Y: 1
      Z: 1
    }
  }
  ParentId: 3919765587975032039
  ChildIds: 17626264511647740093
  ChildIds: 11387129920627243358
  WantsNetworking: true
  Collidable_v2 {
    Value: "mc:ecollisionsetting:inheritfromparent"
  }
  Visible_v2 {
    Value: "mc:evisibilitysetting:inheritfromparent"
  }
  CoreMesh {
    MeshAsset {
      Id: 13099283958163873646
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
  Id: 11387129920627243358
  Name: "Ball"
  Transform {
    Location {
      X: 234.041519
      Y: -2.87117052
      Z: 20.5518799
    }
    Rotation {
    }
    Scale {
      X: 0.65
      Y: 0.65
      Z: 0.65
    }
  }
  ParentId: 610742210611514619
  ChildIds: 8954527568870414686
  ChildIds: 4523216897312630760
  ChildIds: 2807731708626405520
  UnregisteredParameters {
  }
  WantsNetworking: true
  Collidable_v2 {
    Value: "mc:ecollisionsetting:inheritfromparent"
  }
  Visible_v2 {
    Value: "mc:evisibilitysetting:inheritfromparent"
  }
  CoreMesh {
    MeshAsset {
      Id: 13099283958163873646
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
  Id: 2807731708626405520
  Name: "Kill Zone"
  Transform {
    Location {
      X: -348.677917
      Y: 3.57080841
      Z: 48.0636139
    }
    Rotation {
    }
    Scale {
      X: 1
      Y: 1
      Z: 1
    }
  }
  ParentId: 11387129920627243358
  ChildIds: 8453246892907781489
  ChildIds: 15244913841159666953
  UnregisteredParameters {
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
  InstanceHistory {
    SelfId: 14403593132161909582
    SubobjectId: 13648825478633622894
    InstanceId: 12431709722804586966
    TemplateId: 15889254729575639905
    WasRoot: true
  }
}
Objects {
  Id: 15244913841159666953
  Name: "KillZoneServer"
  Transform {
    Location {
    }
    Rotation {
    }
    Scale {
      X: 1
      Y: 1
      Z: 1
    }
  }
  ParentId: 2807731708626405520
  UnregisteredParameters {
    Overrides {
      Name: "cs:KillTrigger"
      ObjectReference {
        SelfId: 8453246892907781489
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
  Script {
    ScriptAsset {
      Id: 3908110495107565482
    }
  }
  InstanceHistory {
    SelfId: 11140162461386808982
    SubobjectId: 16145483188601114806
    InstanceId: 12431709722804586966
    TemplateId: 15889254729575639905
  }
}
Objects {
  Id: 8453246892907781489
  Name: "KillTrigger"
  Transform {
    Location {
      X: 124
      Y: -2.01361084
      Z: 0.402797699
    }
    Rotation {
    }
    Scale {
      X: 4
      Y: 0.25
      Z: 0.25
    }
  }
  ParentId: 2807731708626405520
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
    TeamSettings {
      IsTeamCollisionEnabled: true
      IsEnemyCollisionEnabled: true
    }
    TriggerShape_v2 {
      Value: "mc:etriggershape:box"
    }
  }
  InstanceHistory {
    SelfId: 14274038126526273412
    SubobjectId: 13591331349196528036
    InstanceId: 12431709722804586966
    TemplateId: 15889254729575639905
  }
}
Objects {
  Id: 4523216897312630760
  Name: "Arm"
  Transform {
    Location {
      X: -223.363983
      Y: -2.09823393e-05
      Z: 35.5645523
    }
    Rotation {
    }
    Scale {
      X: 4
      Y: 0.25
      Z: 0.25
    }
  }
  ParentId: 11387129920627243358
  UnregisteredParameters {
    Overrides {
      Name: "ma:Shared_BaseMaterial:id"
      AssetReference {
        Id: 9728495127137008342
      }
    }
    Overrides {
      Name: "ma:Shared_BaseMaterial:smart"
      Bool: false
    }
  }
  WantsNetworking: true
  Collidable_v2 {
    Value: "mc:ecollisionsetting:inheritfromparent"
  }
  Visible_v2 {
    Value: "mc:evisibilitysetting:inheritfromparent"
  }
  CoreMesh {
    MeshAsset {
      Id: 15553121958877687640
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
  Id: 8954527568870414686
  Name: "Kill Zone"
  Transform {
    Location {
      X: -449.485
      Y: 2.550354
      Z: 0.325149536
    }
    Rotation {
    }
    Scale {
      X: 1
      Y: 1
      Z: 1
    }
  }
  ParentId: 11387129920627243358
  ChildIds: 17881820418618097020
  ChildIds: 10155551183386384071
  UnregisteredParameters {
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
  InstanceHistory {
    SelfId: 8994713364241418725
    SubobjectId: 13648825478633622894
    InstanceId: 6580749216303938131
    TemplateId: 15889254729575639905
    WasRoot: true
  }
}
Objects {
  Id: 10155551183386384071
  Name: "KillZoneServer"
  Transform {
    Location {
      Z: -6.10351562e-05
    }
    Rotation {
    }
    Scale {
      X: 1
      Y: 1
      Z: 1
    }
  }
  ParentId: 8954527568870414686
  UnregisteredParameters {
    Overrides {
      Name: "cs:KillTrigger"
      ObjectReference {
        SelfId: 17881820418618097020
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
  Script {
    ScriptAsset {
      Id: 3908110495107565482
    }
  }
  InstanceHistory {
    SelfId: 2425677929994245181
    SubobjectId: 16145483188601114806
    InstanceId: 6580749216303938131
    TemplateId: 15889254729575639905
  }
}
Objects {
  Id: 17881820418618097020
  Name: "KillTrigger"
  Transform {
    Location {
      X: 449.768494
      Y: -3.22842741
      Z: 69.5278091
    }
    Rotation {
    }
    Scale {
      X: 1.05
      Y: 1.05
      Z: 1.05
    }
  }
  ParentId: 8954527568870414686
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
    TeamSettings {
      IsTeamCollisionEnabled: true
      IsEnemyCollisionEnabled: true
    }
    TriggerShape_v2 {
      Value: "mc:etriggershape:sphere"
    }
  }
  InstanceHistory {
    SelfId: 9018424759476477231
    SubobjectId: 13591331349196528036
    InstanceId: 6580749216303938131
    TemplateId: 15889254729575639905
  }
}
Objects {
  Id: 17626264511647740093
  Name: "Object Rotator Continuous"
  Transform {
    Location {
      X: -351.209167
      Y: -1358.87964
      Z: -3.05175781e-05
    }
    Rotation {
    }
    Scale {
      X: 1
      Y: 1
      Z: 1
    }
  }
  ParentId: 610742210611514619
  UnregisteredParameters {
    Overrides {
      Name: "cs:Object"
      ObjectReference {
        SelfId: 610742210611514619
      }
    }
    Overrides {
      Name: "cs:RotateVelocity"
      Rotator {
        Yaw: 15
      }
    }
    Overrides {
      Name: "cs:RotationMultiplier"
      Float: 10
    }
    Overrides {
      Name: "cs:LocalSpace"
      Bool: true
    }
    Overrides {
      Name: "cs:StartDelayRange"
      Vector2 {
      }
    }
    Overrides {
      Name: "cs:RotationMultiplier:tooltip"
      String: "Optional multiplier for very fast rotations."
    }
    Overrides {
      Name: "cs:StartDelayRange:tooltip"
      String: "Random delay range for the object to take action at the start of the game."
    }
    Overrides {
      Name: "cs:LocalSpace:tooltip"
      String: "Whether RotateTo is in local space"
    }
    Overrides {
      Name: "cs:Object:tooltip"
      String: "Object to transform"
    }
    Overrides {
      Name: "cs:RotateVelocity:tooltip"
      String: "Smoothly rotates the object over time by the given angular velocity."
    }
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
      Id: 2331688389429807128
    }
  }
  InstanceHistory {
    SelfId: 12359821512012950691
    SubobjectId: 5456438743692384211
    InstanceId: 15471548557118390798
    TemplateId: 5089970488358775427
    WasRoot: true
  }
}