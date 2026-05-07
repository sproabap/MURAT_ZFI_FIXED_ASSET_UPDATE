@Metadata.allowExtensions: true
@Metadata.ignorePropagatedAnnotations: true
@EndUserText: {
  label: '###GENERATED Core Data Service Entity'
}
@ObjectModel: {
  sapObjectNodeType.name: 'ZFIFIXED_ASSET'
}
@AccessControl.authorizationCheck: #MANDATORY
define root view entity ZC_FI_FIXED_ASSET
  provider contract transactional_query
  as projection on ZR_FI_FIXED_ASSET
  association [1..1] to ZR_FI_FIXED_ASSET as _BaseEntity on $projection.CompanyCode = _BaseEntity.CompanyCode 
                                                        and $projection.MasterFixedAsset = _BaseEntity.MasterFixedAsset
                                                        and $projection.FixedAsset = _BaseEntity.FixedAsset
                                                        and $projection.Ledger = _BaseEntity.Ledger
                                                        and $projection.AssetRealDepreciationArea = _BaseEntity.AssetRealDepreciationArea 
{
    key CompanyCode,
    key MasterFixedAsset,
    key FixedAsset,
    key Ledger,
    key AssetRealDepreciationArea,
    FixedAssetDescription,
    CostCenter,
    ProfitCenter,
    
    
    DepreciationKey,
    PlannedUsefulLifeInYears,
    DepreciationStartDate,
      @Semantics: {
    user.createdBy: true
  }
  CreatedBy,
  @Semantics: {
    systemDateTime.createdAt: true
  }
  CreatedAt,
  @Semantics: {
    user.lastChangedBy: true
  }
  LastChangedBy,
  @Semantics: {
    systemDateTime.lastChangedAt: true
  }
  LastChangedAt,
  @Semantics: {
    systemDateTime.localInstanceLastChangedAt: true
  }
  LocalLastChangedAt,
    _BaseEntity
}
