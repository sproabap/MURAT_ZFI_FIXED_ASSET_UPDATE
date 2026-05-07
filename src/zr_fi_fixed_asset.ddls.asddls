@AccessControl.authorizationCheck: #MANDATORY
@Metadata.allowExtensions: true
@ObjectModel.sapObjectNodeType.name: 'ZFIFIXED_ASSET'
@EndUserText.label: '###GENERATED Core Data Service Entity'
define root view entity ZR_FI_FIXED_ASSET
as select from I_FixedAsset as FixedAsset
    inner join I_AssetValuationForLedger as AssetValueation
     on FixedAsset.CompanyCode = AssetValueation.CompanyCode
    and FixedAsset.MasterFixedAsset = AssetValueation.MasterFixedAsset
    and FixedAsset.FixedAsset = AssetValueation.FixedAsset
    inner join I_FixedAssetAssgmt as AssetAssignment
     on AssetValueation.CompanyCode = AssetAssignment.CompanyCode
    and AssetValueation.MasterFixedAsset = AssetAssignment.MasterFixedAsset
    and AssetValueation.FixedAsset = AssetAssignment.FixedAsset
    and AssetValueation.ValidityEndDate = AssetAssignment.ValidityEndDate
    left outer join zfi_fixed_asset as ZFixedAsset
     on ZFixedAsset.companycode = AssetValueation.CompanyCode
    and ZFixedAsset.masterfixedasset = AssetValueation.MasterFixedAsset
    and ZFixedAsset.fixedasset = AssetValueation.FixedAsset
    and ZFixedAsset.ledger = AssetValueation.Ledger
    and ZFixedAsset.assetrealdepreciationarea = AssetValueation.AssetRealDepreciationArea
    
     
    
     
 
{

    key FixedAsset.CompanyCode as CompanyCode,
    key FixedAsset.MasterFixedAsset as MasterFixedAsset,
    key FixedAsset.FixedAsset as FixedAsset,
    key AssetValueation.Ledger as Ledger,
    key AssetValueation.AssetRealDepreciationArea as AssetRealDepreciationArea,
    FixedAsset.FixedAssetDescription as FixedAssetDescription,
    AssetAssignment.CostCenter as CostCenter,
    AssetAssignment.ProfitCenter as ProfitCenter,
    AssetValueation.DepreciationKey as DepreciationKey,
    AssetValueation.PlannedUsefulLifeInYears as PlannedUsefulLifeInYears,
    AssetValueation.DepreciationStartDate as DepreciationStartDate,
    @Semantics.user.createdBy: true
    ZFixedAsset.created_by as CreatedBy,
    @Semantics.systemDateTime.createdAt: true
    ZFixedAsset.created_at as CreatedAt,
    @Semantics.user.lastChangedBy: true
    ZFixedAsset.last_changed_by as LastChangedBy,
    @Semantics.systemDateTime.lastChangedAt: true
    ZFixedAsset.last_changed_at as LastChangedAt,
    @Semantics.systemDateTime.localInstanceLastChangedAt: true
    ZFixedAsset.local_last_changed_at as LocalLastChangedAt
    

    
    
    
      
} where AssetValueation.ValidityEndDate = '99991231' 
